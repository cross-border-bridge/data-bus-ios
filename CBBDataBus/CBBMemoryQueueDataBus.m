// Copyright © 2017 DWANGO Co., Ltd.

#import "CBBDataBus.h"
#import "CBBMemoryQueueDataBus.h"

@interface CBBMemoryQueueDataBus ()
@property (readwrite, nonnull) CBBMemoryQueue* sender;
@property (readwrite, nonnull) CBBMemoryQueueHandler handler;
@end

@implementation CBBMemoryQueueDataBus

- (instancetype)initWithSender:(CBBMemoryQueue*)sender
                      receiver:(CBBMemoryQueue*)receiver
{
    if ([super init]) {
        self.sender = sender;
        receiver.handler = ^(NSArray* data) {
            [super onReceiveData:data];
        };
    }
    return self;
}

- (void)sendData:(NSArray*)data
{
    [_sender sendData:data];
}

@end
