// Copyright © 2017 DWANGO Co., Ltd.

#import "WKWebView+NavigationDelegateForwardable.h"
#import <objc/runtime.h>

static void* CBBWKWebViewForwardableObjectKey;

@implementation WKWebView (NavigationDelegateForwardable)

+ (void)load
{
    Method originalSetter = class_getInstanceMethod([self class], @selector(setNavigationDelegate:));
    Method replaceSetter = class_getInstanceMethod([self class], @selector(cbb_setNavigationDelegate:));
    method_exchangeImplementations(originalSetter, replaceSetter);
    Method originalGetter = class_getInstanceMethod([self class], @selector(navigationDelegate));
    Method replaceGetter = class_getInstanceMethod([self class], @selector(cbb_navigationDelegate));
    method_exchangeImplementations(originalGetter, replaceGetter);
}

- (void)cbb_setNavigationDelegateForwardTo:(id<WKNavigationDelegateForwardable, WKNavigationDelegate>)forwardableObject
{
    id<WKNavigationDelegate> originalDelegate = self.navigationDelegate;
    [forwardableObject setOriginalNavigationDelegate:originalDelegate];
    objc_setAssociatedObject(self, &CBBWKWebViewForwardableObjectKey, forwardableObject, OBJC_ASSOCIATION_ASSIGN);
    [self cbb_setNavigationDelegate:(id<WKNavigationDelegate>)forwardableObject];
}

- (void)cbb_setNavigationDelegate:(id<WKNavigationDelegate>)navigationDelegate
{
    id<WKNavigationDelegateForwardable> forwardObject = objc_getAssociatedObject(self, &CBBWKWebViewForwardableObjectKey);
    forwardObject ? [forwardObject setOriginalNavigationDelegate:navigationDelegate] : [self cbb_setNavigationDelegate:navigationDelegate];
}

- (id<WKNavigationDelegate>)cbb_navigationDelegate
{
    id<WKNavigationDelegateForwardable> forwardObject = objc_getAssociatedObject(self, &CBBWKWebViewForwardableObjectKey);
    return forwardObject ? [forwardObject originalNavigationDelegate] : [self cbb_navigationDelegate];
}

@end
