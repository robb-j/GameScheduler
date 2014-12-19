//
//  GameScene.m
//  GameScheduler
//
//  Created by Robert Anderson on 09/11/2014.
//  Copyright (c) 2014 Rob Anderson. All rights reserved.
//

#import "GameScene.h"

#import "Scheduler.h"
#import "Scheduler+Parent.h"

#import "RandomNode.h"
#import "AvoidNode.h"
#import "FollowNode.h"

@implementation GameScene



- (void)didMoveToView:(SKView *)view {
    
	[self demoBlockUpdate];
	
	[self demoUpdatables];
	
	[self demoDelay];
}


- (void)demoBlockUpdate {
	
	// Create a label to play with
	SKLabelNode *label = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
	label.text = @"Hello:";
	label.fontSize = 42;
	label.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
	[self addChild:label];
	
	
	// Some properties for the block
	__block CGFloat direction = 1;
	__block NSInteger count = 0;
	
	CGFloat max = self.size.height * 0.6f;
	CGFloat min = self.size.height * 0.4f;
	
	
	// Schedule a block to be run every frame
	[[Scheduler sharedScheduler] scheduleBlock:^(CFTimeInterval dt, CFTimeInterval elapsedTime, BOOL *cancel) {
		
		// Move the label
		label.position = CGPointMake(label.position.x, label.position.y + (direction * 2));
		
		
		// Update the label
		label.text = [NSString stringWithFormat:@"Hello:%.1f", elapsedTime];
		
		
		// Bounds check it
		if (label.position.y > max || label.position.y < min) {
			
			// Reverse movement
			direction *= -1;
			count ++;
			
			
			// Only run 4 times
			if (count > 5) {
				
				*cancel = YES;
			}
		}
		
	} identifier:@"ABlock"];
	
	
	// Alternativly you could cancel the block with
	//[[Scheduler sharedScheduler] unscheduleBlock:@"ABlock"];
}

- (void)demoUpdatables {
	
	// Add some nodes that show how Scheduling Updatables works
	RandomNode *random = [RandomNode randomNodeOn:self.size];
	AvoidNode *avoid = [AvoidNode avoidNode:random on:self.size];
	FollowNode *follow = [FollowNode followNode:random];
	
	[self addChild:random];
	[self addChild:avoid];
	[self addChild:follow];
}

- (void)demoDelay {
	
	
	[[Scheduler sharedScheduler] afterDelay:2.0f runBlock:^{
		
		NSLog(@"I waited!");
	}];
}

- (void)update:(CFTimeInterval)currentTime {
    
	/* 
		Just remember to tell the Schedule to tick each frame!
	 */
	[[Scheduler sharedScheduler] tickScheduler:currentTime];
}

@end
