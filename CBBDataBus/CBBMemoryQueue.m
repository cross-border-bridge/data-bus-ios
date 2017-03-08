// Copyright © 2017 DWANGO Co., Ltd.

#import "CBBMemoryQueue.h"

@implementation CBBMemoryQueue

- (void)sendData:(NSArray*)data
{
    if (_handler) {
        _handler(data);
    }
}

@end
