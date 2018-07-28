//
//  JOEFileIOer.h
//  FileTranfer
//
//  Created by Joe 楠 on 26/07/2018.
//  Copyright © 2018 JOE. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "JOEFileTransfer-prefix.h"

@protocol JOEFileIOProgressDelegate;

@class TransferServClient;
@class TRFileInfo;

@interface JOEFileIOer : NSObject

@property (nonatomic, weak) id<JOEFileIOProgressDelegate> delegate;

- (instancetype)initWithClient:(TransferServClient *)aClient;
- (void)download:(TRFileInfo *)fileInfo toLocalPath:(NSString *)path;
- (void)upload:(TRFileInfo *)fileInfo;

@end

@protocol JOEFileIOProgressDelegate <NSObject>
- (void)updateDownloadProgress:(double)value;
- (void)updateUploadProgress:(double)value;
@end
