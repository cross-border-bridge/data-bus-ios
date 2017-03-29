// Copyright © 2017 DWANGO Co., Ltd.

#import "CBBMemoryQueueDataBus.h"
#import <WebKit/WebKit.h>
#import <XCTest/XCTest.h>

@interface CBBDataBusTests : XCTestCase
@property (nonatomic) WKWebView* webView;
@property (nonatomic) CBBDataBus* dataBusA;
@property (nonatomic) CBBDataBus* dataBusB;
@property (nonatomic) CBBMemoryQueue* mqA;
@property (nonatomic) CBBMemoryQueue* mqB;
@property (nonatomic) NSInteger counter;
@end

@implementation CBBDataBusTests

- (void)setUp
{
    [super setUp];
    _mqA = [[CBBMemoryQueue alloc] init];
    _mqB = [[CBBMemoryQueue alloc] init];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testSendMessage
{
    _counter = 0;

    _dataBusA = [[CBBMemoryQueueDataBus alloc] initWithSender:_mqA receiver:_mqB];
    [_dataBusA addHandler:^(NSArray* _Nonnull data) {
        NSLog(@"dataBusA received: %@", data);
        // [A] expects message from [B]
        XCTAssertEqualObjects(data[0], @"HELLO");
        XCTAssertEqualObjects(data[1], @"THIS");
        XCTAssertEqualObjects(data[2], @"IS");
        XCTAssertEqualObjects(data[3], @"B");
        XCTAssertEqualObjects(data[4], @(2222));
        _counter++;
    }];

    _dataBusB = [[CBBMemoryQueueDataBus alloc] initWithSender:_mqB receiver:_mqA];
    [_dataBusB addHandler:^(NSArray* _Nonnull data) {
        NSLog(@"dataBusB received: %@", data);
        // [B] expects message from [A]
        XCTAssertEqualObjects(data[0], @"Hello");
        XCTAssertEqualObjects(data[1], @"This");
        XCTAssertEqualObjects(data[2], @"is");
        XCTAssertEqualObjects(data[3], @"A");
        XCTAssertEqualObjects(data[4], @(1111));
        _counter++;
    }];

    // send A -> B
    [_dataBusA sendData:@[ @"Hello", @"This", @"is", @"A", @(1111) ]];

    // send B -> A
    [_dataBusB sendData:@[ @"HELLO", @"THIS", @"IS", @"B", @(2222) ]];

    XCTAssertEqual(_counter, 2);

    [_dataBusA destroy];
    [_dataBusB destroy];
}

- (void)testMultiThread
{
    _counter = 0;
    
    _dataBusA = [[CBBMemoryQueueDataBus alloc] initWithSender:_mqA receiver:_mqB];
    [_dataBusA addHandler:^(NSArray* _Nonnull data) {
        NSLog(@"dataBusA received: %@", data);
        // [A] expects message from [B]
        XCTAssertEqualObjects(data[0], @"HELLO");
        XCTAssertEqualObjects(data[1], @"THIS");
        XCTAssertEqualObjects(data[2], @"IS");
        XCTAssertEqualObjects(data[3], @"B");
        XCTAssertEqualObjects(data[4], @(2222));
        _counter++;
    }];
    
    _dataBusB = [[CBBMemoryQueueDataBus alloc] initWithSender:_mqB receiver:_mqA];

    const int threadNumber = 10;
    NSOperationQueue* threads[threadNumber];

    for (int i = 0; i < threadNumber; i++) {
        threads[i] = [[NSOperationQueue alloc] init];
        [threads[i] addOperationWithBlock:^{
            CBBDataBusHandler handler = ^(NSArray* _Nonnull data) {
                NSLog(@"dataBusB received: %@", data);
                // [B] expects message from [A]
                XCTAssertEqualObjects(data[0], @"Hello");
                XCTAssertEqualObjects(data[1], @"This");
                XCTAssertEqualObjects(data[2], @"is");
                XCTAssertEqualObjects(data[3], @"A");
                XCTAssertEqualObjects(data[4], @(1111));
                _counter++;
                // send B -> A
                [_dataBusB sendData:@[ @"HELLO", @"THIS", @"IS", @"B", @(2222) ]];
                [_dataBusB removeHandler:handler];
            };
            [_dataBusB addHandler:handler];
        }];
    }

    // join
    for (int i = 0; i < threadNumber; i++) {
        [threads[i] waitUntilAllOperationsAreFinished];
    }

    // send A -> B
    [_dataBusA sendData:@[ @"Hello", @"This", @"is", @"A", @(1111) ]];

    
    XCTAssertEqual(_counter, threadNumber * 2);
    
    [_dataBusA destroy];
    [_dataBusB destroy];
}

@end
