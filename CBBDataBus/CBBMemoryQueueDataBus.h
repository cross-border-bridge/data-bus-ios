// Copyright © 2017 DWANGO Co., Ltd.

#import "CBBDataBus.h"
#import "CBBMemoryQueue.h"

@interface CBBMemoryQueueDataBus : CBBDataBus
- (instancetype)initWithSender:(CBBMemoryQueue*)sender
                      receiver:(CBBMemoryQueue*)receiver;
@end
