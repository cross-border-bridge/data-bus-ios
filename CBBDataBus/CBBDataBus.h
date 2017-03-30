// Copyright © 2017 DWANGO Co., Ltd.

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^CBBDataBusHandler)(NSArray* data);

@interface CBBDataBus : NSObject
@property (readonly, nonatomic) BOOL destroyed;
@property (nonatomic, readonly) NSInteger handlerCount;
- (void)sendData:(NSArray*)data;
- (void)onReceiveData:(NSArray*)data;
- (void)addHandler:(CBBDataBusHandler)handler;
- (void)removeHandler:(CBBDataBusHandler)handler;
- (void)removeAllHandlers;
- (void)destroy;
@end

NS_ASSUME_NONNULL_END
