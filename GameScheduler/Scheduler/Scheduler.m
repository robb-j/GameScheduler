//
//  Scheduler.m
//  GameScheduler
//
//  Created by Robert Anderson on 09/11/2014.
//  Copyright (c) 2014 Rob Anderson. All rights reserved.
//

#import "Scheduler.h"
#import "Scheduler+Parent.h"
#import "ScheduleObject.h"

#define kDeltaThreashold							0.1f



NSInteger const kNoPriority = NSIntegerMax;
NSInteger const kAltPriority = NSIntegerMax - 1;



@implementation Scheduler {
	
	BOOL _isIterating;
	CFTimeInterval _lastTime;
	CFTimeInterval _lastAltTime;
	
	NSMutableArray *_allSchedules;
	NSMutableArray *_allAltSchedules;
	
	NSMutableArray *_addedDuringIteration;
	NSMutableArray *_removedDuringIteration;
}

#pragma mark - Singleton
static Scheduler *_sharedInstance;
+ (instancetype)sharedScheduler {
	
	@synchronized(self) {
		if (_sharedInstance == nil) {
			_sharedInstance = [self new];
		}
	}
	return _sharedInstance;
}

- (instancetype)init {
	
	self = [super init];
	
	if (self) {
		
		// Custom Setup
		_isIterating = NO;
		_allSchedules = [NSMutableArray array];
		_allAltSchedules = [NSMutableArray array];
		
		_addedDuringIteration = [NSMutableArray array];
		_removedDuringIteration = [NSMutableArray array];
		
		_maxInterval = kDeltaThreashold;
	}
	return self;
}



#pragma mark - Annonymous Run Later
- (void)afterDelay:(CFTimeInterval)delay runBlock:(void(^)(void))block {
	
	[self scheduleBlock:^(CFTimeInterval dt, CFTimeInterval elapsedTime, BOOL *cancel) {
		
		if (elapsedTime > delay) {
			
			block();
			*cancel = YES;
		}
		
	} identifier:@""];
}



#pragma mark - Object Scheduling
- (void)scheduleObject:(id<Updatable>)object {
	
	// Schedule with a default priority
	[self scheduleObject:object priority:kNoPriority];
}

- (void)scheduleObject:(id<Updatable>)object priority:(NSInteger)priority {
	
	// Schedule with a priority
	[self schedule:[ScheduleObject objectWithObject:object priority:priority]];
}

- (void)unscheduleObject:(id<Updatable>)object {
	
	// Unschedule, using the object
	[self unschedule:object];
}



#pragma mark - Group Scheduling
- (void)scheduleGroup:(NSArray *)group identifier:(NSString *)identifier {
	
	// Schedule with a default priority
	[self scheduleGroup:group priority:kNoPriority identifier:identifier];
}

- (void)scheduleGroup:(NSArray *)group priority:(NSInteger)priority identifier:(NSString *)identifier {
	
	// Schedule with a priority
	[self schedule:[ScheduleObject objectWithGroup:group identifier:identifier priority:priority]];
}

- (void)unscheduleGroup:(NSString *)identifier {
	
	// Unschedule using the identifier
	[self unschedule:identifier];
}



#pragma mark - Block Scheduling
- (void)scheduleBlock:(ScheduleBlock)block identifier:(NSString *)identifier {
	
	// Schedule with a default priority
	[self scheduleBlock:block priority:kNoPriority identifier:identifier];
}

- (void)scheduleBlock:(ScheduleBlock)block priority:(NSInteger)priority identifier:(NSString *)identifier {
	
	// Schedule with a priority
	[self schedule:[ScheduleObject objectWithBlock:block identifier:identifier priority:priority]];
}

- (void)unscheduleBlock:(NSString *)identifier {
	
	// Unschedule using the priority
	[self unschedule:identifier];
}



#pragma mark - Internal Scheduling
- (void)schedule:(ScheduleObject *)object {
	
	if ( _isIterating ) {
		
		// If we are iterationg, cache to add after the iteration
		[_addedDuringIteration addObject:object];
	}
	else if (object.priority == kNoPriority) {
			
		// If no priority is given, just put it on the end
		[_allSchedules addObject:object];
		
	}
	else if (object.priority == kAltPriority) {
		
		[_allAltSchedules addObject:object];
	}
	else {
		
		// Otherwise, get the insertion index, based on priority (Higher means earlier in the iteration)
		NSInteger index = [_allSchedules indexOfObject:object inSortedRange:NSMakeRange(0, _allSchedules.count) options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(ScheduleObject *obj1, ScheduleObject *obj2) {
			
			if (obj1.priority == obj2.priority)
				return NSOrderedSame;
			
			return (obj1.priority > obj2.priority)? NSOrderedAscending : NSOrderedDescending;
		}];
		
		// Store the object being scheduled at that index
		[_allSchedules insertObject:object atIndex:index];
	}
}

- (void)unschedule:(id)comparison {
	
	NSArray *bothSchedules = @[_allSchedules, _allAltSchedules];
	
	
	// Run with both schedules, do the normal first though
	for (NSMutableArray *aSchedule in bothSchedules) {
		
		
		NSInteger count = aSchedule.count;
		ScheduleObject *object;
		
		
		// Iterate through, comparing them with the provided object
		for (int i = 0; i < count; i++) {
			object = aSchedule[i];
			
			if ([object scheduleComparison:comparison]) {
				
				if (_isIterating) {
					
					object.isCancelled = YES;
					[_removedDuringIteration addObject:comparison];
				}
				else {
					
					[aSchedule removeObjectAtIndex:i];
				}
				
				// Breaks the loop but still checks the other schedule(s)
				break;
			}
		}
	}
}

- (void)unscheduleAll {
	
	if (_isIterating) {
		
		// If we are iterating, cache to remove after the iteration
		[_removedDuringIteration addObjectsFromArray:_allSchedules];
		[_removedDuringIteration addObjectsFromArray:_allAltSchedules];
	}
	else {
		
		// Copy the array so we can modify ours in the loop
		NSArray *toRemove = [_allSchedules arrayByAddingObjectsFromArray:_allAltSchedules];
		
		
		// Remove all scheduled objects
		for (ScheduleObject *object in toRemove) {
			
			[self unschedule:object];
		}
	}
}






@end


@implementation Scheduler (Parent)

- (void)tickScheduler:(CFTimeInterval)currentTime {
	
	// Calculate the differenct in time since the last frame
	CFTimeInterval dt = MIN(currentTime - _lastTime, _maxInterval);
	_lastTime = currentTime;
	
	
	// Tick with that dt
	[self tick:dt alt:NO];
}

- (void)tickAltScheduler:(CFTimeInterval)currentTime {
	
	CFTimeInterval dt = MIN(currentTime - _lastAltTime, kDeltaThreashold);
	_lastAltTime = currentTime;
	
	[self tick:dt alt:YES];
}

- (void)resetTick:(CFTimeInterval)currentTime {
	
	// Update the current time
	_lastTime = currentTime;
}

- (void)tick:(CFTimeInterval)dt alt:(BOOL)isAlt {
	
	
	// Remember we're iterating
	_isIterating = YES;
	
	
	// Tick each object
	NSArray *schedules = isAlt ? _allAltSchedules : _allSchedules;
	for (ScheduleObject *object in schedules) {
		
		if ( ! object.isCancelled) {
			
			[object tickObject:dt scheduler:self];
		}
	}
	
	
	// We're no-longer iterating
	_isIterating = NO;
	
	
	// Handle adds during iteration
	if (_addedDuringIteration.count > 0) {
		
		for (ScheduleObject *object in _addedDuringIteration) {
			
			[self schedule:object];
		}
		
		[_addedDuringIteration removeAllObjects];
	}
	
	// Handle removes during iteration
	if (_removedDuringIteration.count > 0) {
		
		for (ScheduleObject *object in _removedDuringIteration) {
			
			[self unschedule:object];
		}
		
		[_removedDuringIteration removeAllObjects];
	}
}

@end
