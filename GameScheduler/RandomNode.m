//
//  RandomNode.m
//  GameScheduler
//
//  Created by Robert Anderson on 13/11/2014.
//  Copyright (c) 2014 Rob Anderson. All rights reserved.
//

#import "RandomNode.h"
#import "Scheduler.h"

@interface RandomNode () <Updatable>
@end

@implementation RandomNode {
	
	CGPoint _destination;
	CGSize _area;
}

+ (instancetype)randomNodeOn:(CGSize)size {
	
	return [[self alloc] initWithSize:size];
}

- (instancetype)initWithSize:(CGSize)size {
	
	self = [super initWithColor:[SKColor greenColor] size:CGSizeMake(40, 40)];
	
	if (self) {
		
		_area = size;
		_destination = [self randomPositionOn:size];
		
		
		self.position = [self randomPositionOn:size];
		
		
		[[Scheduler sharedScheduler] scheduleObject:self];
		
	}
	return self;
}



- (CGFloat)random {
	
	return ((CGFloat)rand() / RAND_MAX);
}

- (CGPoint)randomPositionOn:(CGSize)size {
	
	
	if ([self random] > 0.5f) {
		
		return CGPointMake([self random]*(size.width), [self random]>0.5f? 0 : size.height);
	}
	else {
		
		return CGPointMake([self random]>0.5f? 0 : size.width, [self random]*(size.height));
	}
}

- (BOOL)isCloseTo:(CGPoint)point {
	
	CGFloat var = 5.0f;
	if(self.position.x - var <= point.x && point.x <= self.position.x + var) {
		
		if(self.position.y - var <= point.y && point.y <= self.position.y + var) {
			
			return true;
		}
	}
	
	return false;
}


- (void)sceneUpdate:(CFTimeInterval)dt {
	
	// If we've arrived, move somewhere else
	if ([self isCloseTo:_destination]) {
		
		_destination = [self randomPositionOn:_area];
	}
	
	
	// Move to the destination
	CGPoint diff = CGPointMake(_destination.x - self.position.x, _destination.y - self.position.y);

	CGFloat norm = 1.0/sqrtf(diff.x*diff.x + diff.y*diff.y);
	CGFloat factor = 2.0f;
	
	CGPoint normal = CGPointMake(diff.x*norm*factor, diff.y*norm*factor);
	
	self.position = CGPointMake(self.position.x+normal.x, self.position.y+normal.y);
}

@end
