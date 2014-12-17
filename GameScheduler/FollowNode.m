//
//  FollowNode.m
//  GameScheduler
//
//  Created by Robert Anderson on 14/11/2014.
//  Copyright (c) 2014 Rob Anderson. All rights reserved.
//

#import "FollowNode.h"
#import "Scheduler.h"

@interface FollowNode () <Updatable>
@end

@implementation FollowNode {
	
	SKNode *_target;
}

+ (instancetype)followNode:(SKNode *)node {
	
	return [[self alloc] initWithNode:node];
}

- (instancetype)initWithNode:(SKNode *)node {
	
	self = [super initWithColor:[SKColor purpleColor] size:CGSizeMake(50, 50)];
	
	if (self) {
		
		_target = node;
		
		[[Scheduler sharedScheduler] scheduleObject:self];
	}
	return self;
}



- (void)sceneUpdate:(CFTimeInterval)dt {
	
	CGPoint diff = CGPointMake(_target.position.x - self.position.x, _target.position.y - self.position.y);
	
	CGFloat max = 1.5f;
	
	CGPoint move = CGPointMake([self limit:diff.x by:max], [self limit:diff.y by:max]);
	
	self.position = CGPointMake(self.position.x + move.x, self.position.y + move.y);
}

- (CGFloat)limit:(CGFloat)input by:(CGFloat)limit {
	
	return (input > 0)? MIN(input, limit) : MAX(input, -limit);
}

@end
