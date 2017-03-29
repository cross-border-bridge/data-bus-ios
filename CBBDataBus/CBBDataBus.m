// Copyright © 2017 DWANGO Co., Ltd.

#import "CBBDataBus.h"

@interface CBBDataBus ()
@property (readwrite, nonatomic) BOOL destroyed;
@property (readwrite, atomic) NSMutableArray<CBBDataBusHandler>* handlers;
@property (atomic) CBBDataBusHandlerId nextHandlerId;
@end

@implementation CBBDataBus

- (instancetype)init
{
    if (self = [super init]) {
        _nextHandlerId = 1;
        _handlers = [NSMutableArray array];
    }
    return self;
}

- (void)sendData:(NSArray*)data
{
    NSAssert(NO, @"must be overridden");
}

- (void)onReceiveData:(NSArray*)data
{
    if (_destroyed) {
        return;
    }
    @synchronized (self) {
        NSArray* handlers = [_handlers copy];
        for (CBBDataBusHandler handler in handlers) {
            handler(data);
        }
    }
}

- (void)addHandler:(CBBDataBusHandler)handler
{
    if (_destroyed) {
        return;
    }
    @synchronized(self)
    {
        if ([_handlers indexOfObject:handler] != NSNotFound) {
            return;
        }
        [_handlers addObject:handler];
    }
}

- (void)removeHandler:(CBBDataBusHandler)handler
{
    if (_destroyed) {
        return;
    }
    @synchronized(self)
    {
        [_handlers removeObject:handler];
    }
}

- (void)removeAllHandlers
{
    if (_destroyed) {
        return;
    }
    @synchronized(self)
    {
        [_handlers removeAllObjects];
    }
}

- (NSInteger)getHandlerCount
{
    NSInteger result;
    @synchronized (self) {
        result = _handlers.count;
    }
    return result;
}

- (void)destroy
{
    _handlers = nil;
    _destroyed = YES;
}

- (void)dealloc
{
    [self destroy];
}

@end
