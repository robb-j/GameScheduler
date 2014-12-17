//
//  ScheduleObject.h
//  GameScheduler
//
//  Created by Robert Anderson on 09/11/2014.
//  Copyright (c) 2014 Rob Anderson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Updatable.h"
#import "ScheduledBlock.h"

@class Scheduler;



/** An internal object that stores things that are scheduled */
@interface ScheduleObject : NSObject


/** Create a schedule with an Updatable object */
+ (instancetype)objectWithObject:(id<Updatable>)object priority:(NSInteger)priority;

/** Create a schedule with a group & identifier */
+ (instancetype)objectWithGroup:(NSArray *)group identifier:(NSString *)identifier priority:(NSInteger)priority;

/** Create a schedule with a block & identifier */
+ (instancetype)objectWithBlock:(ScheduleBlock)block identifier:(NSString *)identifier priority:(NSInteger)priority;




/** Compares the schedule to an object for equality
 @param object Can be a ScheduleObject or a ShceduleObject's identifier */
- (BOOL)scheduleComparison:(id)object;



/** Ticks the object, called from Scheduler */
- (void)tickObject:(CFTimeInterval)dt scheduler:(Scheduler *)scheduler;



/** The priority of this schedule */
@property (nonatomic, readonly) NSInteger priority;



@end