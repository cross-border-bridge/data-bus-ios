// Copyright © 2017 DWANGO Co., Ltd.

#import "CBBWKWebViewDataBus.h"
#import "ViewController.h"
#import <WebKit/WebKit.h>

@interface ViewController () <WKNavigationDelegate, WKUIDelegate>
@property (nonatomic) WKWebView* webView;
@property (nonatomic) CBBDataBus* dataBus;
@property (nonatomic) NSMutableArray* handlerIds;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    _handlerIds = [[NSMutableArray alloc] init];
    CGFloat width = self.view.frame.size.width;
    CGFloat height = self.view.frame.size.height;

    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(4, 30, width - 8, 30)];
    label.text = @"CBBWKWebViewDataBus (native)";
    [self.view addSubview:label];

    // ボタンを準備
    [self addButton:CGRectMake(4, 70, 200, 30) title:@"Add handler" action:@selector(addHandler:)];
    [self addButton:CGRectMake(4, 110, 200, 30) title:@"Send message" action:@selector(sendMessage:)];
    [self addButton:CGRectMake(4, 150, 200, 30) title:@"Remove a handler" action:@selector(removeHandler:)];
    [self addButton:CGRectMake(4, 190, 200, 30) title:@"destroy" action:@selector(destroy:)];

    // WKWebViewを準備（※この時点ではまだコンテンツを読み込まない）
    _webView = [[WKWebView alloc]
        initWithFrame:CGRectMake(4, height / 2 + 4, width - 8, height / 2 - 8)];
    _webView.layer.borderWidth = 2.0f;
    _webView.layer.borderColor = [[UIColor blueColor] CGColor];
    _webView.layer.cornerRadius = 10.0f;
    _webView.navigationDelegate = self;
    _webView.autoresizingMask =
        UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _webView.UIDelegate = self;
    // WKWebView　は App bundle のファイルを読めない為, bundleの内容を tmp
    // へコピーしてそこから読み込む
    [self copyWithTarget:@"index.html"];
    [self copyWithTarget:@"script.js"];
    [self.view addSubview:_webView];

    // CBBDataBusを準備
    _dataBus = [[CBBWKWebViewDataBus alloc] initWithWKWebView:_webView];

    // WKWebView にコンテンツを読み込む（CBBDataBusがインジェクトされる）
    NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"file://%@/index.html", [self getTmpDirectory]]];
    [_webView loadFileURL:url allowingReadAccessToURL:url];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)addButton:(CGRect)frame title:(NSString*)title action:(SEL)sel
{
    UIButton* b = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    b.frame = frame;
    b.layer.cornerRadius = 2.0;
    b.layer.borderColor = [[UIColor blueColor] CGColor];
    b.layer.borderWidth = 1.0;
    [b setTitle:title forState:UIControlStateNormal];
    [b addTarget:self action:sel forControlEvents:UIControlEventTouchDown];
    [self.view addSubview:b];
}

- (void)addHandler:(id)inSender
{
    __weak id _self = self;
    CBBDataBusHandler h = ^(NSArray* _Nonnull message) {
        // JavaScript側メッセージ受信時の処理
        for (int i = 0; i < message.count; i++) {
            NSLog(@"DATA[%d]: %@", i, message[i]);
        }
        UIAlertController* alert = [UIAlertController
            alertControllerWithTitle:@"Alert from Native"
                             message:[NSString
                                         stringWithFormat:@"Received message\n%@",
                                                          message]
                      preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction* ok = [UIAlertAction
            actionWithTitle:@"OK"
                      style:UIAlertActionStyleDefault
                    handler:^(UIAlertAction* action) {
                        [alert dismissViewControllerAnimated:YES completion:nil];
                    }];
        [alert addAction:ok];
        [_self presentViewController:alert animated:YES completion:nil];
    };
    [_dataBus addHandler:h];
}

- (void)sendMessage:(id)inSender
{
    [_dataBus sendData:@[ @"This", @"is", @"test", @(1234) ]];
}

- (void)removeHandler:(id)inSender
{
    [_dataBus removeAllHandlers];
}

- (void)destroy:(id)inSender
{
    [_dataBus destroy];
}

- (NSString*)getTmpDirectory
{
    return [NSTemporaryDirectory() stringByAppendingPathComponent:@"www"];
}

// AppBundleの内容はWKWebViewから参照できないのでテンポラリディレクトリにコピーして用いる
- (BOOL)copyWithTarget:(NSString*)target
{
    NSBundle* mainBundle = [NSBundle mainBundle];
    NSString* sourceFile = [mainBundle pathForResource:target
                                                ofType:@""
                                           inDirectory:@"www"];
    NSString* tmpFolder = [self getTmpDirectory];
    [[NSFileManager defaultManager] createDirectoryAtPath:tmpFolder
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
    NSString* destFile = [tmpFolder stringByAppendingPathComponent:target];
    NSError* err;
    NSFileManager* fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:sourceFile]) {
        return NO;
    }
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef uuidString = CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
    CFRelease(uuidString);
    CFRelease(uuidRef);
    BOOL destExists = [fileManager fileExistsAtPath:destFile];
    if (destExists && ![fileManager removeItemAtPath:destFile error:nil])
        return NO;
    if (!destExists && ![fileManager createDirectoryAtPath:[destFile stringByDeletingLastPathComponent]
                               withIntermediateDirectories:YES
                                                attributes:nil
                                                     error:nil]) {
        return NO;
    }
    BOOL result = [fileManager copyItemAtPath:sourceFile toPath:destFile error:nil];
    if (err)
        NSLog(@"error: %@", err);
    NSLog(@"copy \"%@\" to \"%@\" <%s>", sourceFile, destFile, result ? "succeed" : "failed");
    return result;
}

// JavaScript側でalertを発行した時の処理
- (void)webView:(WKWebView*)webView
    runJavaScriptAlertPanelWithMessage:(NSString*)message
                      initiatedByFrame:(WKFrameInfo*)frame
                     completionHandler:(void (^)(void))completionHandler
{
    UIAlertController* alert =
        [UIAlertController alertControllerWithTitle:@"Alert from JS"
                                            message:message
                                     preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* ok = [UIAlertAction actionWithTitle:@"OK"
                                                 style:UIAlertActionStyleDefault
                                               handler:^(UIAlertAction* action) {
                                                   [alert dismissViewControllerAnimated:YES completion:nil];
                                                   completionHandler();
                                               }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
