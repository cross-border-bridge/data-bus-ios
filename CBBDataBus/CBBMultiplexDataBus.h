// Copyright © 2017 DWANGO Co., Ltd.

#import "CBBDataBus.h"

NS_ASSUME_NONNULL_BEGIN

@interface CBBMultiplexDataBus : CBBDataBus
- (instancetype)initWithDataBus:(CBBDataBus*)dataBus
                         dataId:(NSString*)dataId;
@end

NS_ASSUME_NONNULL_END
