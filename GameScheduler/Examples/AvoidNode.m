//
//  AvoidNode.m
//  GameScheduler
//
//  Created by Robert Anderson on 13/11/2014.
//  Copyright (c) 2014 Rob Anderson. All rights reserved.
//

#import "AvoidNode.h"
#import "Scheduler.h"

#define kMinimumDistance 			100.0f
#define kMovement					4.0f


@interface AvoidNode () <Updatable>
@end

@implementation AvoidNode {
	
	SKNode *_target;
	CGSize _area;
}

+ (instancetype)avoidNode:(SKNode *)node on:(CGSize)size {
	
	return [[self alloc] initWithNode:node on:size];
}

- (instancetype)initWithNode:(SKNode *)node on:(CGSize)size  {
	
	self = [super initWithColor:[SKColor cyanColor] size:CGSizeMake(50, 50)];
	
	if (self) {
		
		_target = node;
		_area = size;
		
		[[Scheduler sharedScheduler] scheduleObject:self];
		
		self.position = CGPointMake(size.width * 0.5f, size.height * 0.5f);
	}
	return self;
}


- (void)sceneUpdate:(CFTimeInterval)dt {
	
	CGFloat x = self.position.x;
	CGFloat y = self.position.y;
	
	CGPoint diff = CGPointMake(_target.position.x-self.position.x, _target.position.y-self.position.y);
	
	CGFloat dist = sqrtf( diff.x*diff.x + diff.y*diff.y );
	
	if (dist < kMinimumDistance) {
		
		// Move away
		
		// Get angle
		CGFloat n = 1.0f/dist;
		CGPoint normal = CGPointMake(n * diff.x, n * diff.y);
		
		
		// Move opposite direction
		x -= normal.x * kMovement;
		y -= normal.y * kMovement;
	}
	
	
	
	if (x > _area.width) {
		
		x = 0;
	}
	else if (x < 0) {
		
		x = _area.width;
	}
	
	
	if (y > _area.height) {
		
		y = 0;
	}
	else if (y < 0) {
		
		y = _area.height;
	}
	
	self.position = CGPointMake(x, y);
}

@end
