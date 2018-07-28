//
//  JOEFileTransfer.h
//  JOEFileTransfer
//
//  Created by Joe 楠 on 26/7/2018.
//

#ifndef JOEFileTransfer_prefix_h
#define JOEFileTransfer_prefix_h

#define async_main_thread(block,...) \
try {} @finally {} \
do { \
if ([[NSThread currentThread] isMainThread]) { \
if (block) { \
block(__VA_ARGS__); \
} \
} else { \
if (block) { \
dispatch_async(dispatch_get_main_queue(), ^(){ \
block(__VA_ARGS__); \
}); \
} \
} \
} while(0)

#endif
