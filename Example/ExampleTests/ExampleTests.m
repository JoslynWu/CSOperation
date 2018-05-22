//
//  ExampleTests.m
//  ExampleTests
//
//  Created by Joslyn Wu on 2018/5/19.
//  Copyright © 2018年 Joslyn Wu. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CSSUnitTestDefine.h"
#import "CSSOperation.h"

@interface ExampleTests : XCTestCase

@end

@implementation ExampleTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testBlockOperation {
    NSMutableArray<NSString *> *mArr = [NSMutableArray array];
    NSString *outsideFlag = @"outsideFlag";
    NSString *insideFlag = @"insideFlag";
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    NSBlockOperation *outOp = [NSBlockOperation blockOperationWithBlock:^{
        // NSLog(@"--outoutout-->%@,%@", @"outOp", [NSThread currentThread]);
        @synchronized(mArr) {
            [mArr addObject:outsideFlag];
            dispatch_async(dispatch_get_main_queue(), ^{
                CSS_POST_NOTIF
            });
        }
    }];
    
    for (NSInteger i = 0; i < 999; i++) {
        NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
            // NSLog(@"--in-->%ld,%@", i, [NSThread currentThread]);
            @synchronized(mArr) {
                [mArr addObject:insideFlag];
            }
        }];
        [outOp addDependency:op];
        [queue addOperation:op];
    }
    [queue addOperation:outOp];
    
    CSS_WAIT
    XCTAssertTrue([mArr.lastObject isEqualToString:outsideFlag]);
}

- (void)testAddDependency {
    NSMutableArray<NSString *> *mArr = [NSMutableArray array];
    NSInteger opCount = 999;
    NSString *outsideFlag = @"outsideFlag";
    NSString *insideFlag = @"insideFlag";
    CSSOperation *outOp = [CSSOperation new];
    outOp.blockOnCurrentThread = ^(__kindof CSSOperation *maker) {
        @synchronized(mArr) {
            [mArr addObject:outsideFlag];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            CSS_POST_NOTIF
        });
        maker.finished = YES;
    };
    
    for (NSInteger i = 0; i < opCount; i++) {
        CSSOperation *op = [CSSOperation new];
        op.blockOnCurrentThread = ^(__kindof CSSOperation *maker) {
            @synchronized(mArr) {
                [mArr addObject:insideFlag];
            };
            maker.finished = YES;
        };
        [outOp addDependency:op];
        [op asyncStart];
    }
    [outOp asyncStart];
    
    CSS_WAIT
    XCTAssertTrue(mArr.count == opCount + 1);
    XCTAssertTrue([mArr.lastObject isEqualToString:outsideFlag]);
}

- (void)testRemoveDependency {
    NSMutableArray<NSString *> *mArr = [NSMutableArray array];
    NSInteger opCount = 99;
    NSString *outsideFlag = @"outsideFlag";
    NSString *insideFlag = @"insideFlag";
    CSSOperation *outOp = [CSSOperation new];
    outOp.blockOnCurrentThread = ^(__kindof CSSOperation *maker) {
        NSLog(@"--oooooouuuuuuuuttttttttt-->%@", outsideFlag);
        @synchronized(mArr) {
            [mArr addObject:outsideFlag];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            CSS_POST_NOTIF
        });
        maker.finished = YES;
    };
    
    for (NSInteger i = 0; i < opCount; i++) {
        CSSOperation *op = [CSSOperation new];
        op.name = [NSString stringWithFormat:@"%ld", i];
        op.blockOnCurrentThread = ^(__kindof CSSOperation *maker) {
            [NSThread sleepForTimeInterval:0.01];
            if (i > 4 && i < 11) {
                NSLog(@"--in-->%ld", i);
            }
            @synchronized(mArr) {
//                NSLog(@"--in lock-->%ld", i);
                [mArr addObject:insideFlag];
            }
            maker.finished = YES;
        };
        
        if (i > 4 && i < 11) {
            [outOp addDependency:op];
            op.completionBlock = ^{
                NSLog(@"---->%ld,%@", i, @"completionBlock");
            };
        }
        if (i > 4 && i < 8) {
            [outOp removeDependency:op];
        }
        [op asyncStart];
    }
    [outOp asyncStart];
    
    CSS_WAIT
    NSLog(@"--mArr count-->%ld", mArr.count);
    XCTAssertTrue(mArr.count <= opCount + 1);
}


@end
