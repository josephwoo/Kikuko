/**
 * Autogenerated by Thrift Compiler (0.9.3)
 *
 * DO NOT EDIT UNLESS YOU ARE SURE THAT YOU KNOW WHAT YOU ARE DOING
 *  @generated
 */

#import <Foundation/Foundation.h>

#import "TProtocol.h"
#import "TApplicationException.h"
#import "TProtocolException.h"
#import "TProtocolUtil.h"
#import "TProcessor.h"
#import "TObjective-C.h"
#import "TBase.h"
#import "TAsyncTransport.h"
#import "TProtocolFactory.h"
#import "TBaseClient.h"


@interface TRFileInfo : NSObject <TBase, NSCoding> {
  NSString * __name;
  NSString * __path;
  int64_t __size;

  BOOL __name_isset;
  BOOL __path_isset;
  BOOL __size_isset;
}

#if TARGET_OS_IPHONE || (MAC_OS_X_VERSION_MAX_ALLOWED >= MAC_OS_X_VERSION_10_5)
@property (nonatomic, retain, getter=name, setter=setName:) NSString * name;
@property (nonatomic, retain, getter=path, setter=setPath:) NSString * path;
@property (nonatomic, getter=size, setter=setSize:) int64_t size;
#endif

- (id) init;
- (id) initWithName: (NSString *) name path: (NSString *) path size: (int64_t) size;

- (void) read: (id <TProtocol>) inProtocol;
- (void) write: (id <TProtocol>) outProtocol;

- (void) validate;

#if !__has_feature(objc_arc)
- (NSString *) name;
- (void) setName: (NSString *) name;
#endif
- (BOOL) nameIsSet;

#if !__has_feature(objc_arc)
- (NSString *) path;
- (void) setPath: (NSString *) path;
#endif
- (BOOL) pathIsSet;

#if !__has_feature(objc_arc)
- (int64_t) size;
- (void) setSize: (int64_t) size;
#endif
- (BOOL) sizeIsSet;

@end

@protocol TransferServ <NSObject>
- (NSMutableArray *) find_file_path;  // throws TException
- (NSData *) download: (TRFileInfo *) file_info length: (int32_t) length offset: (int32_t) offset;  // throws TException
- (BOOL) already_exist: (TRFileInfo *) file_info;  // throws TException
- (void) upload: (TRFileInfo *) file_info payload: (NSData *) payload;  // throws TException
- (void) print_message: (NSString *) msg;  // throws TException
@end

@interface TransferServClient : TBaseClient <TransferServ> - (id) initWithProtocol: (id <TProtocol>) protocol;
- (id) initWithInProtocol: (id <TProtocol>) inProtocol outProtocol: (id <TProtocol>) outProtocol;
@end

@interface TransferServProcessor : NSObject <TProcessor> {
  id <TransferServ> mService;
  NSDictionary * mMethodMap;
}
- (id) initWithTransferServ: (id <TransferServ>) service;
- (id<TransferServ>) service;
@end

@interface TransferServConstants : NSObject {
}
@end
