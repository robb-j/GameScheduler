//
//  GameSchedulerTests.m
//  GameSchedulerTests
//
//  Created by Robert Anderson on 09/11/2014.
//  Copyright (c) 2014 Rob Anderson. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "Scheduler.h"
#import "Scheduler+Parent.h"
#import "MockUpdatable.h"



@interface GameSchedulerTests : XCTestCase
@end

@implementation GameSchedulerTests {
	
	Scheduler *_testScheduler;
}


#pragma mark - Test Lifecycle
- (void)setUp {
    [super setUp];
    
	// Create a scheduler to test
	_testScheduler = [Scheduler new];
}

- (void)tearDown {
    
	// Any tidy-ups
	
    [super tearDown];
}


#pragma mark - Basic Tests
- (void)testCreation {
	
	// Test the scheduler was created
	XCTAssertNotNil(_testScheduler);
}


#pragma mark - Test Addition
- (void)testAddObject {
		
	__block BOOL wasCalled = NO;
	
	MockUpdatable *object = [MockUpdatable updatableWithCondition:^{
		
		wasCalled = YES;
	}];
	
	[_testScheduler scheduleObject:object];
	
	[_testScheduler tickScheduler:0];
	
	XCTAssert(wasCalled, @"The Object should have recieved a tick");
}

- (void)testAddGroup {
	
	__block BOOL wasCalled = NO;
	
	MockUpdatable *object = [MockUpdatable updatableWithCondition:^{
		
		wasCalled = YES;
	}];
	
	[_testScheduler scheduleGroup:@[object] identifier:@""];
	
	[_testScheduler tickScheduler:0];
	
	XCTAssert(wasCalled);
}

- (void)testAddBlock {
	
	__block BOOL wasCalled = NO;
	
	[_testScheduler scheduleBlock:^(CFTimeInterval dt, CFTimeInterval elapsedTime, BOOL *cancel) {
		
		wasCalled = YES;
		
	} identifier:@""];
	
	[_testScheduler tickScheduler:0];
	
	XCTAssert(wasCalled);
}


#pragma mark - Test Removal
- (void)testObjectRemove {
	
	MockUpdatable *object = [MockUpdatable updatableWithCondition:^{
		XCTFail(@"This object shouldn't get a tick");
	}];
	[_testScheduler scheduleObject:object];
	
	[_testScheduler unscheduleObject:object];
	
	[_testScheduler tickScheduler:0];
}

- (void)testGroupRemove {
	
	MockUpdatable *object = [MockUpdatable updatableWithCondition:^{
		XCTFail(@"This object shouldn't get a tick");
	}];
	NSString *identifier = @"TestId";
	
	[_testScheduler scheduleGroup:@[object] identifier:identifier];
	
	[_testScheduler unscheduleGroup:identifier];
	
	[_testScheduler tickScheduler:0];
}

- (void)testBlockRemove {
	
	NSString *identifier = @"TestId";
	
	[_testScheduler scheduleBlock:^(CFTimeInterval dt, CFTimeInterval elapsedTime, BOOL *cancel) {
		XCTFail(@"This block shouldn't get a tick");
	} identifier:identifier];
	
	[_testScheduler unscheduleBlock:identifier];
	
	[_testScheduler tickScheduler:0];
}


#pragma mark - Test More
- (void)testPriorityAdd {
	
	NSString *id1 = @"A";
	NSString *id2 = @"B";
	
	NSInteger p1 = 5;
	NSInteger p2 = 10;
	
	__block BOOL flag = NO;
	
	
	// This should be run second
	[_testScheduler scheduleBlock:^(CFTimeInterval dt, CFTimeInterval elapsedTime, BOOL *cancel) {
		
		flag = YES;
		
	} priority:p1 identifier:id1];
	
	
	// This should be run first
	[_testScheduler scheduleBlock:^(CFTimeInterval dt, CFTimeInterval elapsedTime, BOOL *cancel) {
		
		XCTAssert( ! flag );
		
	} priority:p2 identifier:id2];
	
	
	[_testScheduler tickScheduler:0];
}

- (void)testAddDuringIteration {
	
	__block BOOL flag = NO;
	
	[_testScheduler scheduleBlock:^(CFTimeInterval dt, CFTimeInterval elapsedTime, BOOL *cancel) {
		
		if ( ! flag ) {
		
			[_testScheduler scheduleBlock:^(CFTimeInterval dt, CFTimeInterval elapsedTime, BOOL *cancel) {
				
				flag = YES;
				
			} identifier:@""];
		}
		
	} identifier:@""];
	
	
	// First tick will mean the second gets added
	[_testScheduler tickScheduler:0];
	
	
	// Second tick should tick both blocks
	[_testScheduler tickScheduler:0];
	
	
	// Test the second iteration was called
	XCTAssert(flag);
}

- (void)testBlockIterationRemove {
	
	__block NSInteger callCount = 0;
	
	[_testScheduler scheduleBlock:^(CFTimeInterval dt, CFTimeInterval elapsedTime, BOOL *cancel) {
		
		callCount ++;
		
		*cancel = YES;
		
	} identifier:@""];
	
	
	// First tick unschedules
	[_testScheduler tickScheduler:0];
	
	
	// Second shouldn't call the block (it's unscheduled)
	[_testScheduler tickScheduler:0];
	
	
	// The block should only have been called once
	XCTAssertEqual(callCount, 1);
}

- (void)testRemoveDuringIteration {
	
	NSString *id1 = @"A";
	NSString *id2 = @"B";
	
	__block NSInteger callCount = 0;
	__block BOOL flag = NO;
	
	[_testScheduler scheduleBlock:^(CFTimeInterval dt, CFTimeInterval elapsedTime, BOOL *cancel) {
		
		callCount ++;
		
	} priority:2 identifier:id1];
	
	[_testScheduler scheduleBlock:^(CFTimeInterval dt, CFTimeInterval elapsedTime, BOOL *cancel) {
		
		if ( ! flag ) {
			
			[_testScheduler unscheduleBlock:id1];
		}
		
		flag = YES;
		
	} priority: 1 identifier:id2];
	
	
	// First tick unschedules the block
	[_testScheduler tickScheduler:0];
	
	
	// Second tick 
	[_testScheduler tickScheduler:0];
	
	
	// The block should only have been called once
	XCTAssertEqual(callCount, 1);
}

- (void)testRemoveAllDuringIteration {
	
	__block NSInteger callCount = 0;
	
	MockUpdatable *o1 = [MockUpdatable updatableWithCondition:^{
		
		if (callCount == 0) {
		
			callCount ++;
			[_testScheduler unscheduleAll];
		}
		else {
		
			XCTFail("This should have been unscheduled by the second iteration");
		}
	}];
	
	[_testScheduler scheduleObject:o1];
	
	
	// First tick should unschedule everything
	[_testScheduler tickScheduler:0.0];
	
	
	// Second tick shouldn't have anything to tick
	[_testScheduler tickScheduler:0.0];
}

- (void)testExtraCallWhenRemoved {
	
	__block BOOL flag = YES;
	
	
	// This one sets a flag to yes
	MockUpdatable *o1 = [MockUpdatable updatableWithCondition:^{
		
		// This shouldn't get called
		flag = NO;
	}];
	
	
	// This one cancels the first
	MockUpdatable *o2 = [MockUpdatable updatableWithCondition:^{
		
		[[Scheduler sharedScheduler] unscheduleObject:o1];
	}];
	
	
	// Schedule so o2 before o1
	[[Scheduler sharedScheduler] scheduleObject:o1 priority:1];
	[[Scheduler sharedScheduler] scheduleObject:o2 priority:2];
	
	
	// Tick the scheduler
	[[Scheduler sharedScheduler] tickScheduler:0.0];
	
	
	// The flag should still be true
	XCTAssertTrue(flag);
}










@end