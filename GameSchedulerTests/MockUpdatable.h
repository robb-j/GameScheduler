//
//  MockUpdatable.h
//  GameScheduler
//
//  Created by Robert Anderson on 09/11/2014.
//  Copyright (c) 2014 Rob Anderson. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Updatable.h"

@interface MockUpdatable : NSObject <Updatable>

+ (instancetype)updatableWithCondition:(void(^)(void))block;

@end
