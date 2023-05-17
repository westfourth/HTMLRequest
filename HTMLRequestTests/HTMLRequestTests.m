//
//  HTMLRequestTests.m
//  HTMLRequestTests
//
//  Created by mac on 2023/5/16.
//

#import <XCTest/XCTest.h>
#import "HTMLRequest.h"

@interface HTMLRequestTests : XCTestCase

@end

@implementation HTMLRequestTests

- (void)setUp {
    HTMLRequest *request = HTMLRequest.share;
    request.domain = @"https://miao101.com";
    request.cacheEnabled = NO;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
}

- (void)testExample {
    XCTestExpectation *e = [[XCTestExpectation alloc] initWithDescription:@"testRequest"];
    [HTMLRequest.share request:@"" completion:^(NSError * _Nonnull error, TFHpple * _Nonnull doc) {
        XCTAssertNotNil(doc.data);
        XCTAssertTrue([doc isMemberOfClass:[TFHpple class]]);
        [e fulfill];
    }];
    [self waitForExpectations:@[e] timeout:5];
}

@end
