// Copyright © 2017 DWANGO Co., Ltd.

#import "CBBWKWebViewDataBus.h"
#import "WKWebView+NavigationDelegateForwardable.h"

static NSString const* CBBLocationHashPrefix = @"cbb-data-bus://";

@interface CBBWKWebViewDataBus () <WKScriptMessageHandler, WKNavigationDelegate, WKNavigationDelegateForwardable>
@property (readwrite, nullable, weak) WKWebView* webView;
@property (readwrite) CBBDataBusMode mode;
@property (nonatomic, weak) id<WKNavigationDelegate> originalNavigationDelegate;
@property (nonatomic) NSMutableArray<NSString*>* pendingRequests;
@property (nonatomic) BOOL dataBusFound;
@property (nonatomic) BOOL consumingRequests;
@property (nonatomic) void (^evaluateJavaScript)(id, NSError*);
@end

@implementation CBBWKWebViewDataBus

- (instancetype)initWithWKWebView:(WKWebView*)webView
{
    return [self initWithWKWebView:webView mode:CBBDataBusModeAutomatic];
}

- (instancetype)initWithWKWebView:(WKWebView*)webView mode:(CBBDataBusMode)mode
{
    if (self = [super init]) {
        _webView = webView;
        _mode = mode;
        _pendingRequests = [NSMutableArray array];
        [self injectCBBDataBus];
    }
    return self;
}

- (CBBDataBusMode)currentMode
{
    if (_mode == CBBDataBusModeAutomatic) {
        if (9.0 <= [UIDevice currentDevice].systemVersion.doubleValue) {
            return CBBDataBusModeMessageHandler;
        } else {
            return CBBDataBusModeLocationHash;
        }
    } else {
        return self.mode;
    }
}

- (void)injectCBBDataBus
{
    if ([self currentMode] == CBBDataBusModeMessageHandler) {
        [self.webView.configuration.userContentController addScriptMessageHandler:self name:@"CBBDataBus"];
    } else {
        [self.webView cbb_setNavigationDelegateForwardTo:self];
    }
    NSBundle* bundle = [NSBundle bundleForClass:self.classForCoder];
    NSURL* url = [bundle URLForResource:@"CBBDataBus" withExtension:@"js"];
    NSString* script = [NSString stringWithContentsOfURL:url encoding:NSUTF8StringEncoding error:nil];
    WKUserScript* userScript = [[WKUserScript alloc]
          initWithSource:script
           injectionTime:WKUserScriptInjectionTimeAtDocumentStart
        forMainFrameOnly:YES];
    [self.webView.configuration.userContentController addUserScript:userScript];
    [self.webView addObserver:self forKeyPath:@"loading" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)sendData:(NSArray*)data
{
    if (!_webView) {
        return;
    }
    NSError* error = nil;
    NSData* json = [NSJSONSerialization dataWithJSONObject:data options:0 error:&error];
    NSString* jsonString = [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding];
    @synchronized(self)
    {
        [self.pendingRequests addObject:jsonString];
    }
    [self consumeRequestsIfNeeded];
}

- (void)destroy
{
    if (!_webView) {
        return;
    }
    if ([self currentMode] == CBBDataBusModeMessageHandler) {
        [_webView.configuration.userContentController removeScriptMessageHandlerForName:@"CBBDataBus"];
    } else {
        [_webView cbb_setNavigationDelegateForwardTo:nil];
    }
    [_webView removeObserver:self forKeyPath:@"loading"];
    _webView = nil;
    [super destroy];
}

#pragma mark - DataBus operation

- (void)consumeRequestsIfNeeded
{
    if (!self.consumingRequests) {
        self.consumingRequests = YES;
        if ([NSThread isMainThread]) {
            [self _consumeRequestsWithCompletionHandler:^{
                self.consumingRequests = NO;
            }];
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self _consumeRequestsWithCompletionHandler:^{
                    self.consumingRequests = NO;
                }];
            });
        }
    }
}

- (void)_consumeRequestsWithCompletionHandler:(void (^)())completionHandler
{
    NSAssert([NSThread isMainThread],
             @"_consumeRequest should run on main thread.");

    if (self.webView.loading) {
        self.dataBusFound = NO;
        completionHandler();
        return;
    }

    if (!self.dataBusFound) {
        [self.webView evaluateJavaScript:@"CBB != null"
                       completionHandler:^(NSNumber* result, NSError* error) {
                           self.dataBusFound = result.boolValue;
                           if (self.dataBusFound) {
                               dispatch_async(dispatch_get_main_queue(), ^{
                                   [self _consumeRequestsWithCompletionHandler:completionHandler];
                               });
                           } else {
                               assert("CBB is null");
                               completionHandler();
                           }
                       }];
        return;
    }

    __weak __typeof(self) weakSelf = self;
    _evaluateJavaScript = ^(id ret, NSError* error) {
        NSString* data;
        @synchronized (weakSelf) {
            data = weakSelf.pendingRequests.firstObject;
            if (data) {
                [weakSelf.pendingRequests removeObjectAtIndex:0];
            }
        }
        if (data) {
            NSString* script = [NSString stringWithFormat:@"CBB.WebViewDataBus.onData(%@);", data];
            [weakSelf.webView evaluateJavaScript:script
                               completionHandler:weakSelf.evaluateJavaScript];
        } else {
            completionHandler();
        }
    };
    _evaluateJavaScript(nil, nil);
}

- (void)_processReceiveArguments:(NSArray*)data
{
    [self onReceiveData:data];
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString*)keyPath
                      ofObject:(id)object
                        change:(NSDictionary<NSString*, id>*)change
                       context:(void*)context
{
    if (![keyPath isEqualToString:@"loading"]) {
        return;
    }
    [self consumeRequestsIfNeeded];
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController*)userContentController didReceiveScriptMessage:(WKScriptMessage*)message
{
    if (![message.name isEqualToString:@"CBBDataBus"]) {
        return;
    }
    [self _processReceiveArguments:message.body[0]];
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView*)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation*)navigation
{
    if (self.originalNavigationDelegate && [self.originalNavigationDelegate respondsToSelector:@selector(webView:didReceiveServerRedirectForProvisionalNavigation:)]) {
        [self.originalNavigationDelegate webView:webView didReceiveServerRedirectForProvisionalNavigation:navigation];
    }
}

- (void)webView:(WKWebView*)webView didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge*)challenge completionHandler:(void (^)(NSURLSessionAuthChallengeDisposition, NSURLCredential* _Nullable))completionHandler
{
    if (self.originalNavigationDelegate && [self.originalNavigationDelegate respondsToSelector:@selector(webView:didReceiveAuthenticationChallenge:completionHandler:)]) {
        [self.originalNavigationDelegate webView:webView didReceiveAuthenticationChallenge:challenge completionHandler:completionHandler];
    }
}

- (void)webView:(WKWebView*)webView didStartProvisionalNavigation:(WKNavigation*)navigation
{
    if (self.originalNavigationDelegate && [self.originalNavigationDelegate respondsToSelector:@selector(webView:didStartProvisionalNavigation:)]) {
        [self.originalNavigationDelegate webView:webView didStartProvisionalNavigation:navigation];
    }
}

- (void)webView:(WKWebView*)webView didFailProvisionalNavigation:(null_unspecified WKNavigation*)navigation withError:(NSError*)error
{
    if (self.originalNavigationDelegate && [self.originalNavigationDelegate respondsToSelector:@selector(webView:didFailProvisionalNavigation:withError:)]) {
        [self.originalNavigationDelegate webView:webView didFailProvisionalNavigation:navigation withError:error];
    }
}

- (void)webView:(WKWebView*)webView didCommitNavigation:(WKNavigation*)navigation
{
    if (self.originalNavigationDelegate && [self.originalNavigationDelegate respondsToSelector:@selector(webView:didCommitNavigation:)]) {
        [self.originalNavigationDelegate webView:webView didCommitNavigation:navigation];
    }
}

- (void)webView:(WKWebView*)webView didFinishNavigation:(WKNavigation*)navigation
{
    if (self.originalNavigationDelegate && [self.originalNavigationDelegate respondsToSelector:@selector(webView:didFinishNavigation:)]) {
        [self.originalNavigationDelegate webView:webView didFinishNavigation:navigation];
    }
}

- (void)webView:(WKWebView*)webView didFailNavigation:(WKNavigation*)navigation withError:(NSError*)error
{
    if (self.originalNavigationDelegate && [self.originalNavigationDelegate respondsToSelector:@selector(webView:didFailNavigation:withError:)]) {
        [self.originalNavigationDelegate webView:webView didFailNavigation:navigation withError:error];
    }
}

- (void)webViewWebContentProcessDidTerminate:(WKWebView*)webView
{
    if (self.originalNavigationDelegate && [self.originalNavigationDelegate respondsToSelector:@selector(webViewWebContentProcessDidTerminate:)]) {
        [self.originalNavigationDelegate webViewWebContentProcessDidTerminate:webView];
    }
}

- (void)webView:(WKWebView*)webView decidePolicyForNavigationAction:(WKNavigationAction*)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler
{
    NSString* fragment = navigationAction.request.URL.fragment;
    if ([fragment hasPrefix:(NSString*)CBBLocationHashPrefix]) {
        NSString* escapedJSON = [fragment substringFromIndex:CBBLocationHashPrefix.length];
        NSString* json = [escapedJSON stringByRemovingPercentEncoding];
        id jsonObject = [NSJSONSerialization
            JSONObjectWithData:[json dataUsingEncoding:NSUTF8StringEncoding]
                       options:0
                         error:nil];
        [self _processReceiveArguments:jsonObject];
        decisionHandler(WKNavigationActionPolicyCancel);
    } else {
        if (self.originalNavigationDelegate && [self.originalNavigationDelegate respondsToSelector:@selector(webView:decidePolicyForNavigationAction:decisionHandler:)]) {
            return [self.originalNavigationDelegate webView:webView decidePolicyForNavigationAction:navigationAction decisionHandler:decisionHandler];
        } else {
            decisionHandler(WKNavigationActionPolicyAllow);
        }
    }
}

- (void)webView:(WKWebView*)webView decidePolicyForNavigationResponse:(WKNavigationResponse*)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler
{
    if (self.originalNavigationDelegate && [self.originalNavigationDelegate respondsToSelector:@selector(webView:decidePolicyForNavigationResponse:decisionHandler:)]) {
        [self.originalNavigationDelegate webView:webView decidePolicyForNavigationResponse:navigationResponse decisionHandler:decisionHandler];
    } else {
        decisionHandler(WKNavigationResponsePolicyAllow);
    }
}

@end
