// Copyright © 2017 DWANGO Co., Ltd.

#import "CBBMemoryQueueDataBus.h"
#import "CBBMultiplexDataBus.h"
#import <XCTest/XCTest.h>

@interface MultiplexDataBusTests : XCTestCase
@property (nonatomic) CBBMemoryQueue* mqA;
@property (nonatomic) CBBMemoryQueue* mqB;
@property (atomic) NSInteger counter;
@end

@implementation MultiplexDataBusTests

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

- (void)test
{
    CBBMemoryQueueDataBus* dbA = [[CBBMemoryQueueDataBus alloc] initWithSender:_mqA receiver:_mqB];
    CBBMemoryQueueDataBus* dbB = [[CBBMemoryQueueDataBus alloc] initWithSender:_mqB receiver:_mqA];
    CBBMultiplexDataBus* dbA1 = [[CBBMultiplexDataBus alloc] initWithDataBus:dbA dataId:@"layer1"];
    CBBMultiplexDataBus* dbB1 = [[CBBMultiplexDataBus alloc] initWithDataBus:dbB dataId:@"layer1"];
    CBBMultiplexDataBus* dbA2 = [[CBBMultiplexDataBus alloc] initWithDataBus:dbA1 dataId:@"layer2"];
    CBBMultiplexDataBus* dbB2 = [[CBBMultiplexDataBus alloc] initWithDataBus:dbB1 dataId:@"layer2"];
    CBBMultiplexDataBus* dbA3 = [[CBBMultiplexDataBus alloc] initWithDataBus:dbA2 dataId:@"layer3"];
    CBBMultiplexDataBus* dbB3 = [[CBBMultiplexDataBus alloc] initWithDataBus:dbB2 dataId:@"layer3"];

    _counter = 0;

    [dbB addHandler:^(NSArray* _Nonnull data) {
        NSLog(@"dbB receive: %@", data);
        XCTAssertEqual(data.count, 4);
        XCTAssertEqual(data[0], @"layer1");
        XCTAssertEqual(data[1], @"layer2");
        XCTAssertEqual(data[2], @"layer3");
        XCTAssertEqual(data[3], @"data");
        _counter++;
    }];

    [dbB1 addHandler:^(NSArray* _Nonnull data) {
        NSLog(@"dbB1 receive: %@", data);
        XCTAssertEqual(data.count, 3);
        XCTAssertEqual(data[0], @"layer2");
        XCTAssertEqual(data[1], @"layer3");
        XCTAssertEqual(data[2], @"data");
        _counter++;
    }];

    [dbB2 addHandler:^(NSArray* _Nonnull data) {
        NSLog(@"dbB2 receive: %@", data);
        XCTAssertEqual(data.count, 2);
        XCTAssertEqual(data[0], @"layer3");
        XCTAssertEqual(data[1], @"data");
        _counter++;
    }];

    [dbB3 addHandler:^(NSArray* _Nonnull data) {
        NSLog(@"dbB3 receive: %@", data);
        XCTAssertEqual(data.count, 1);
        XCTAssertEqual(data[0], @"data");
        _counter++;
    }];

    [dbA3 sendData:@[ @"data" ]];
    XCTAssertEqual(_counter, 4);

    [dbA3 destroy];
    [dbB3 destroy];
    [dbA2 destroy];
    [dbB2 destroy];
    [dbA1 destroy];
    [dbB1 destroy];
    [dbA destroy];
    [dbB destroy];
}

@end
