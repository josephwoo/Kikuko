//
//  JOEFileIOer.m
//  FileTranfer
//
//  Created by Joe 楠 on 26/07/2018.
//  Copyright © 2018 JOE. All rights reserved.
//

#import "JOEFileIOer.h"
#import "TransferServ.h"

static const NSUInteger kBufferSize = 1024 * 1024;  // 1MB
static unsigned char buffer[kBufferSize];

@interface JOEFileIOer ()
@property (nonatomic, strong) TransferServClient *client;
@end

@implementation JOEFileIOer

- (instancetype)initWithClient:(TransferServClient *)aClient
{
    self = [super init];
    if (self) {
        _client = aClient;
    }
    return self;
}

- (void)download:(TRFileInfo *)fileInfo toLocalPath:(NSString *)path
{
    if (!self.client) { return; }

    NSOutputStream *oStream = [[NSOutputStream alloc] initWithURL:[NSURL fileURLWithPath:path] append:YES];
    [oStream open];

    double totalSize = (double)fileInfo.size;
    for (int32_t sizeDownloaded = 0; totalSize-sizeDownloaded > 0; ) {
        @autoreleasepool {
            NSData *payload = [self.client download:fileInfo length:kBufferSize offset:sizeDownloaded];
            sizeDownloaded += [oStream write:payload.bytes maxLength:payload.length];
        }

        @async_main_thread(^void() {
            if ([self.delegate respondsToSelector:@selector(updateDownloadProgress:)]) {
                [self.delegate updateDownloadProgress: sizeDownloaded/totalSize];
            }
        });
    }

    [oStream close];
}

- (void)upload:(TRFileInfo *)fileInfo
{
    if (!self.client) { return; }

    NSInputStream *iStream = [[NSInputStream alloc] initWithFileAtPath:fileInfo.path];
    [iStream open];
    
    double sizeUploaded = 0;
    const long long totalSize = fileInfo.size;
    fileInfo.size = 0;
    NSInteger cnt = totalSize/kBufferSize;
    while (--cnt > -1) {
        [iStream setProperty:@(sizeUploaded) forKey:NSStreamFileCurrentOffsetKey];
        [self _uploadWithIputStream:iStream fileInfo:fileInfo size:kBufferSize];
        
        sizeUploaded += kBufferSize;
        fileInfo.size = sizeUploaded;
        @async_main_thread(^void() {
            if ([self.delegate respondsToSelector:@selector(updateUploadProgress:)]) {
                [self.delegate updateUploadProgress: sizeUploaded/totalSize];
            }
        });
    }
    
    unsigned remainSize = totalSize & (kBufferSize - 1);
    if (remainSize) {
        [iStream setProperty:@(sizeUploaded) forKey:NSStreamFileCurrentOffsetKey];
        [self _uploadWithIputStream:iStream fileInfo:fileInfo size:remainSize];
       
        sizeUploaded += remainSize;
        @async_main_thread(^void() {
            if ([self.delegate respondsToSelector:@selector(updateUploadProgress:)]) {
                [self.delegate updateUploadProgress: sizeUploaded/totalSize];
            }
        });
    }
    
    [iStream close];
}

- (void)_uploadWithIputStream:(NSInputStream *)iStream fileInfo:(TRFileInfo *)fileInfo size:(unsigned)size
{
    memset(buffer, 0, size);
    @autoreleasepool {
        [iStream read:buffer maxLength:size];
        NSData *data = [NSData dataWithBytes:buffer length:size];
        [self.client upload:fileInfo payload:data];
    }
}
@end
