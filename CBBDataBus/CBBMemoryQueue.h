// Copyright © 2017 DWANGO Co., Ltd.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^CBBMemoryQueueHandler)(NSArray* data);

@interface CBBMemoryQueue : NSObject
@property (readwrite, nullable) CBBMemoryQueueHandler handler;
- (void)sendData:(NSArray*)data;
@end

NS_ASSUME_NONNULL_END
