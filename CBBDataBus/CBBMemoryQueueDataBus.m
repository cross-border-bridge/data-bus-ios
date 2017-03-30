// Copyright © 2017 DWANGO Co., Ltd.

#import "CBBDataBus.h"
#import "CBBMemoryQueueDataBus.h"

@interface CBBMemoryQueueDataBus ()
@property (readwrite, nonnull) CBBMemoryQueue* sender;
@property (readwrite, nonnull) CBBMemoryQueue* receiver;
@property (readwrite, nonnull) CBBMemoryQueueHandler handler;
@end

@implementation CBBMemoryQueueDataBus

- (instancetype)initWithSender:(CBBMemoryQueue*)sender
                      receiver:(CBBMemoryQueue*)receiver
{
    __weak typeof(self) weakSelf = self;
    if ([super init]) {
        _sender = sender;
        _receiver = receiver;
        _receiver.handler = ^(NSArray* data) {
            [weakSelf onReceiveData:data];
        };
    }
    return self;
}

- (void)sendData:(NSArray*)data
{
    [_sender sendData:data];
}

- (void)destroy
{
    _sender = nil;
    if (_receiver) {
        _receiver.handler = nil;
        _receiver = nil;
    }
    [super destroy];
}

- (void)dealloc
{
    [self destroy];
}

@end
