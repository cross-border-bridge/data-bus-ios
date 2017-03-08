// Copyright © 2017 DWANGO Co., Ltd.

#import "CBBDataBus.h"
#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CBBDataBusMode) {
    CBBDataBusModeAutomatic,
    CBBDataBusModeMessageHandler,
    CBBDataBusModeLocationHash
};

@interface CBBWKWebViewDataBus : CBBDataBus
@property (readonly, weak) WKWebView* webView;
- (instancetype)initWithWKWebView:(WKWebView*)webView;
- (instancetype)initWithWKWebView:(WKWebView*)webView mode:(CBBDataBusMode)mode;
@end

NS_ASSUME_NONNULL_END
