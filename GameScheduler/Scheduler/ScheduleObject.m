//
//  ScheduleObject.m
//  GameScheduler
//
//  Created by Robert Anderson on 09/11/2014.
//  Copyright (c) 2014 Rob Anderson. All rights reserved.
//

#import "ScheduleObject.h"
#import "Scheduler.h"


typedef NS_ENUM(NSUInteger, ScheduleType) {
	ScheduleTypeObject,
	ScheduleTypeGroup,
	ScheduleTypeBlock,
};

@implementation ScheduleObject {
	
	ScheduleType _type;
	NSString *_identifier;
	
	CFTimeInterval _elapsedTime;
	
	id<Updatable> _object;
	NSArray *_group;
	ScheduleBlock _block;
}


#pragma mark - Schedule Lifecycle
+ (instancetype)objectWithObject:(id<Updatable>)object priority:(NSInteger)priority {
	
	return [[self alloc] initWithObject:object group:nil block:nil identifier:nil type:ScheduleTypeObject priority:priority];
}

+ (instancetype)objectWithGroup:(NSArray *)group identifier:(NSString *)identifier priority:(NSInteger)priority {
	
	return [[self alloc] initWithObject:nil group:group block:nil identifier:identifier type:ScheduleTypeGroup priority:priority];
}

+ (instancetype)objectWithBlock:(ScheduleBlock)block identifier:(NSString *)identifier priority:(NSInteger)priority {
	
	return [[self alloc] initWithObject:nil group:nil block:block identifier:identifier type:ScheduleTypeBlock priority:priority];
}

- (instancetype)initWithObject:(id<Updatable>)object 
						 group:(NSArray *)group 
						 block:(ScheduleBlock)block 
					identifier:(NSString *)identifier 
						  type:(ScheduleType)type 
					  priority:(NSInteger)priority  {
	
	self = [super init];
	
	if (self) {
		
		_identifier = identifier;
		_type = type;
		_priority = priority;
		_elapsedTime = 0.0f;
		_isCancelled = NO;
		
		_object = object;
		_group = group;
		_block = block;
	}
	return self;
}


#pragma mark - Comparison
- (BOOL)scheduleComparison:(id)object {
	
	if (self == object) {
		
		return YES;
	}
	
	if (_type == ScheduleTypeObject && [object conformsToProtocol:@protocol(Updatable)]) {
		
		return _object == object;
	}
	
	if (_type == ScheduleTypeGroup && [object isKindOfClass:[NSString class]]) {
		
		return [_identifier isEqualToString:object];
	}
	
	if (_type == ScheduleTypeBlock && [object isKindOfClass:[NSString class]]) {
		
		return [_identifier isEqualToString:object];
	}
	
	return NO;
}


#pragma mark - Tick Tock
- (void)tickObject:(CFTimeInterval)dt scheduler:(Scheduler *)scheduler {
	
	_elapsedTime += dt;
	
	switch (_type) {
		
		case ScheduleTypeObject: {
			[_object sceneUpdate:dt];
			break;
		}
			
		case ScheduleTypeGroup: {
			for (id<Updatable> object in _group) {
				[object sceneUpdate:dt];
			}
			break;
		}
			
		case ScheduleTypeBlock: {
			BOOL flag = NO;
			
			_block(dt, _elapsedTime, &flag);
			
			if ( flag ) {
				
				[scheduler unscheduleBlock:_identifier];
			}
			
			break;
		}
			
	}
}

@end
