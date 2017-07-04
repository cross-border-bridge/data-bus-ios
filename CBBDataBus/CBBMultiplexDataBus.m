// Copyright © 2017 DWANGO Co., Ltd.

#import "CBBMultiplexDataBus.h"

@interface CBBMultiplexDataBus ()
@property (atomic) CBBDataBus* dataBus;
@property (atomic) NSString* dataId;
@property (atomic) CBBDataBusHandler handler;
@end

@implementation CBBMultiplexDataBus

- (instancetype)initWithDataBus:(CBBDataBus*)dataBus
                         dataId:(NSString*)dataId
{
    if (self = [super init]) {
        _dataBus = dataBus;
        _dataId = dataId;
        __weak typeof(self) weakSelf = self;
        _handler = ^(NSArray* packet) {
            if ([weakSelf destroyed] || weakSelf.handlerCount < 1) {
                return;
            }
            if (packet.count < 1 || ![weakSelf.dataId isEqualToString:packet[0]]) {
                return;
            }
            NSMutableArray* data = [NSMutableArray arrayWithCapacity:packet.count - 1];
            for (int i = 1; i < packet.count; i++) {
                [data addObject:packet[i]];
            }
            [weakSelf onReceiveData:data];
        };
        [_dataBus addHandler:_handler];
    }
    return self;
}

- (void)sendData:(NSArray*)data
{
    if ([self destroyed]) {
        return;
    }
    NSMutableArray* packet = [NSMutableArray arrayWithCapacity:data.count + 1];
    [packet addObject:_dataId];
    [packet addObjectsFromArray:data];
    [_dataBus sendData:packet];
}

- (void)destroy
{
    [_dataBus removeHandler:_handler];
    _handler = nil;
    [super destroy];
}

@end
