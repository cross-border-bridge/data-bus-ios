// Copyright © 2017 DWANGO Co., Ltd.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NSInteger CBBDataBusHandlerId;
typedef void (^CBBDataBusHandler)(NSArray* data);

@interface CBBDataBus : NSObject
@property (readonly, nonatomic) BOOL destroyed;
- (void)sendData:(NSArray*)data;
- (void)onReceiveData:(NSArray*)data;
- (void)addHandler:(CBBDataBusHandler)handler;
- (void)removeHandler:(CBBDataBusHandler)handler;
- (void)removeAllHandlers;
- (NSInteger)getHandlerCount;
- (void)destroy;
@end

NS_ASSUME_NONNULL_END
