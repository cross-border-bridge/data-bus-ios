// Copyright © 2017 DWANGO Co., Ltd.

#import <WebKit/WebKit.h>

@protocol WKNavigationDelegateForwardable
- (void)setOriginalNavigationDelegate:(id<WKNavigationDelegate>)originalNavigationDelegate;
- (id<WKNavigationDelegate>)originalNavigationDelegate;
@end

@interface WKWebView (NavigationDelegateForwardable)
- (void)cbb_setNavigationDelegateForwardTo:(id<WKNavigationDelegateForwardable, WKNavigationDelegate>)forwardableObject;
@end
