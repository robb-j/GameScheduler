//
//  Scheduler+Parent.h
//  GameScheduler
//
//  Created by Robert Anderson on 09/11/2014.
//  Copyright (c) 2014 Rob Anderson. All rights reserved.
//

#import "Scheduler.h"


/** Imported by an Object that tells the schedulelr when to tick its objects */
@interface Scheduler (Parent)


/** Tell the scheduler to tick its objects */
- (void)tickScheduler:(CFTimeInterval)currentTime;


@end
