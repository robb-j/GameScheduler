//
//  Scheduler.h
//  GameScheduler
//
//  Created by Robert Anderson on 09/11/2014.
//  Copyright (c) 2014 Rob Anderson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Updatable.h"
#import "ScheduledBlock.h"


/** An object that schedules objects and blocks for a 'tick' update. ie for each frame of a game. 
 For best practise, have priority in a constants file so you can see the order things get scheduled */
@interface Scheduler : NSObject

// Higher priority means execution earlier


/** Get the singleton scheduler */
+ (instancetype)sharedScheduler;



/** Runs a block after a delay */
- (void)afterDelay:(CFTimeInterval)delay runBlock:(void(^)(void))block;



/** Schedules an object that responds to Updatable */
- (void)scheduleObject:(id<Updatable>)object;

/** Schedules an object that responds to Updatable 
 @param priority When the tick should be run, higher means earlier */
- (void)scheduleObject:(id<Updatable>)object priority:(NSInteger)priority;

/** Stop an Updatable from recieving ticks */
- (void)unscheduleObject:(id<Updatable>)object;




/** Schedules an group of Updatable object that responds to Updatable
 @param group An array of Objects that conform to Updatable 
 @param identifier A Unique identifier used when unscheduling */
- (void)scheduleGroup:(NSArray *)group identifier:(NSString *)identifier;

/** Schedules an group of Updatable object that responds to Updatable
 @param group An array of Objects that conform to Updatable 
 @param identifier A Unique identifier used when unscheduling
 @param priority When the tick should be run, higher means earlier */
- (void)scheduleGroup:(NSArray *)group priority:(NSInteger)priority identifier:(NSString *)identifier;

/** Stop a group from being scheduled, using its identifier */
- (void)unscheduleGroup:(NSString *)identifier;




/** Schedules an block to be called each tick
 @param identifier A Unique identifier used when unscheduling */
- (void)scheduleBlock:(ScheduleBlock)object identifier:(NSString *)identifier;

/** Schedules an block to be called each tick
 @param identifier A Unique identifier used when unscheduling
 @param priority When the tick should be run, higher means earlier */
- (void)scheduleBlock:(ScheduleBlock)object priority:(NSInteger)priority identifier:(NSString *)identifier;

/** Stop a block from being scheduled, using its identifier */
- (void)unscheduleBlock:(NSString *)identifier;



/** Stop everything from being scheduled */
- (void)unscheduleAll;




@end
