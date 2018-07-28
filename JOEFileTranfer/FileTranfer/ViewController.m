//
//  ViewController.m
//  FileTranfer
//
//  Created by Joe 楠 on 25/07/2018.
//  Copyright © 2018 JOE. All rights reserved.
//

#import "ViewController.h"
#import <TSocketClient.h>
#import <TFramedTransport.h>
#import <TBinaryProtocol.h>

#import "TransferServ.h"
#import "JOEFileIOer.h"

static NSString *const kServiceHost = @"192.168.1.101";
static const UInt32 kServicePort = 8404;

typedef NS_ENUM(NSUInteger, JFTFileType) {
    JFTFile = 1 << 0,
    JFTDirectory = 1 << 1,
};


@interface ViewController () <JOEFileIOProgressDelegate>
@property (nonatomic, assign) BOOL isConnected;

@property (nonatomic, strong) NSMutableArray <TRFileInfo *> *info;
@property (weak) IBOutlet NSButton *reconnectButton;
@property (weak) IBOutlet NSTextField *statusLabel;

@property (weak) IBOutlet NSPopUpButton *filePopButton;
@property (weak) IBOutlet NSTextField *sizeLabel;
@property (weak) IBOutlet NSButton *downloadButton;

@property (weak) IBOutlet NSTextField *filePathLabel;
@property (weak) IBOutlet NSProgressIndicator *ProgressIndicator;
@property (weak) IBOutlet NSButton *uploadButton;

@property (weak) IBOutlet NSTextField *messageTextField;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupView];
    [self addObserver:self forKeyPath:@"isConnected" options:NSKeyValueObservingOptionNew context:nil];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self setupDataSource];
    });
}

- (void)setupView
{
    [self.downloadButton setEnabled:NO];
    [self.uploadButton setEnabled:NO];
    [self.filePopButton setTarget:self];
    [self.filePopButton setAction:@selector(handlePopButtonTapped:)];
}

- (void)handlePopButtonTapped:(NSPopUpButton *)popUpButton
{
    TRFileInfo *fileInfo = self.info[self.filePopButton.indexOfSelectedItem];
    NSString *sizeText = [NSByteCountFormatter stringFromByteCount:fileInfo.size countStyle:NSByteCountFormatterCountStyleFile];
    [self.sizeLabel setStringValue:sizeText];
    [self.downloadButton setEnabled:YES];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void *)context
{
    id statusValue = [change objectForKey:NSKeyValueChangeNewKey];
    if ([statusValue isKindOfClass:NSNumber.class]) {
        [self.statusLabel setStringValue:self.isConnected? @"✅" : @"🛑"];
    }
}

- (void)setupDataSource
{
    [self.filePopButton removeAllItems];
    
    @try {
        self.info = [self.client find_file_path];
        self.isConnected = YES;
    } @catch (NSException *ex) {
        [self showMessageAlert:@"⚠️" text:ex.userInfo.description];
        self.isConnected = NO;
    }

    for (TRFileInfo *file in self.info) {
        [self.filePopButton addItemWithTitle:file.name];
    }
}

#pragma mark - function
- (IBAction)chooseUploadFile:(id)sender {
    NSString *filePath = [self chooseFilePathOfType:JFTFile];
    if (!filePath) { return; }

    [self.filePathLabel setStringValue:filePath.lastPathComponent];
    TRFileInfo *fileInfo = [[TRFileInfo alloc] initWithName:filePath.lastPathComponent path:nil size:0];
    BOOL fileExistOnRemote = [self.client already_exist:fileInfo];
    [self.uploadButton setEnabled:!fileExistOnRemote];

    if (fileExistOnRemote) {
        [self showMessageAlert:@"⚠️" text:@"文件在远端已存在"];
    } else {
        [self.ProgressIndicator setDoubleValue:0.0];
        self.uploadButton.alternateTitle = filePath;
    }
}

- (IBAction)upload:(NSButton *)sender
{
    NSString *filePath = sender.alternateTitle;
    if (!filePath) { return; }

    unsigned long long fileSize = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil].fileSize;
    TRFileInfo *fileInfo = [[TRFileInfo alloc] initWithName:filePath.lastPathComponent path:filePath size:fileSize];
    
    // start upload
    [self.uploadButton setEnabled:NO];
    [self.reconnectButton setEnabled:NO];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        JOEFileIOer *ioer = [[JOEFileIOer alloc] initWithClient:self.client];
        [ioer setDelegate:self];
        [ioer upload:fileInfo];

        @async_main_thread(^void() {
            [self.reconnectButton setEnabled:YES];
        });
    });
}

- (IBAction)download:(id)sender
{
    NSString *savePath = [self chooseFilePathOfType:JFTDirectory];
    if (!savePath) { return; }

    TRFileInfo *fileInfo = self.info[self.filePopButton.indexOfSelectedItem];
    savePath = [NSString pathWithComponents:@[savePath, fileInfo.name]];

    if ([[NSFileManager defaultManager] fileExistsAtPath:savePath]) {
        NSString *message = [@"文件已存在 => " stringByAppendingString:savePath];
        [self showMessageAlert:@"⚠️" text:message];
        return;
    }

    //  start download
    [self.downloadButton setEnabled:NO];
    [self.filePopButton setEnabled:NO];
    [self.reconnectButton setEnabled:NO];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        JOEFileIOer *ioer = [[JOEFileIOer alloc] initWithClient:self.client];
        [ioer setDelegate:self];
        [ioer download:fileInfo toLocalPath:savePath];

        @async_main_thread(^void() {
            [self.filePopButton setEnabled:YES];
            [self.reconnectButton setEnabled:YES];
        });
    });
}

- (IBAction)sendMessage:(id)sender {
    NSString *message = self.messageTextField.stringValue;
    if (!message.length) {
        [self.messageTextField setPlaceholderString:@"message 😃"];
        return;
    }

    [self.client print_message:message];
    [self.messageTextField setStringValue:@""];
}

#pragma mark - UI
- (NSString *)chooseFilePathOfType:(JFTFileType)type
{
    NSString *downloadsDirectory = NSSearchPathForDirectoriesInDomains(NSDownloadsDirectory, NSUserDomainMask, YES).firstObject;
    NSURL *downloadsURL = [NSURL fileURLWithPath:downloadsDirectory];
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseDirectories:type==JFTDirectory];
    [panel setCanChooseFiles:type==JFTFile];
    [panel setDirectoryURL:downloadsURL];

    NSString *savePath = nil;
    if ([panel runModal] == NSModalResponseOK) {
        savePath = [panel URLs].firstObject.path;
    }

    return savePath;
}

- (void)updateDownloadProgress:(double)value
{
    value *= 100;
    [self.sizeLabel setStringValue:[NSString stringWithFormat:@"%.2f %%", value]];
}

-(void)updateUploadProgress:(double)value
{
    value *= 100;
    [self.ProgressIndicator setDoubleValue:value];
}

- (void)showMessageAlert:(NSString *)title text:(NSString *)text
{
    if (!title.length || !text.length) {
        return;
    }

    NSAlert *alert = [NSAlert new];
    [alert addButtonWithTitle:@"确定"];
    [alert setMessageText:title];
    [alert setInformativeText:text];
    [alert setAlertStyle:NSAlertStyleInformational];
    [alert beginSheetModalForWindow:[self.view window] completionHandler:nil];
}


#pragma mark - connection
- (IBAction)refreshFileList:(id)sender
{
    [self setupDataSource];
}

- (TransferServClient *)client
{
    TSocketClient *socket = [[TSocketClient alloc] initWithHostname:kServiceHost port:kServicePort];
    TFramedTransport *transport = [[TFramedTransport alloc] initWithTransport:socket];
    TBinaryProtocol *protocol = [[TBinaryProtocol alloc] initWithTransport:transport];
    return [[TransferServClient alloc] initWithProtocol:protocol];
}

@end
