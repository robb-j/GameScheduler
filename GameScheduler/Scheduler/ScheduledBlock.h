//
//  ScheduledBlock.h
//  GadgetJoe
//
//  Created by Robert Anderson on 22/08/2014.
//  Copyright (c) 2014 Robert Anderson. All rights reserved.
//

#ifndef GadgetJoe_ScheduledBlock_h
#define GadgetJoe_ScheduledBlock_h


/** A Block that can be scheduled and runs each frame until *cancel = YES */
typedef void(^ScheduleBlock)(CFTimeInterval dt, CFTimeInterval elapsedTime, BOOL *cancel);


#endif
