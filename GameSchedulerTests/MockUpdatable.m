//
//  MockUpdatable.m
//  GameScheduler
//
//  Created by Robert Anderson on 09/11/2014.
//  Copyright (c) 2014 Rob Anderson. All rights reserved.
//

#import "MockUpdatable.h"

@implementation MockUpdatable {	
	
	void (^_block)(void);  
}
+ (instancetype)updatableWithConition:(void(^)(void))block {
	
	return [[self alloc] initWithConition:block];
}

- (instancetype)initWithConition:(void(^)(void))block {
	
	self = [super init];
	
	if (self) {
		
		_block = block;
	}
	return self;
}

- (void)sceneUpdate:(CFTimeInterval)dt {
	
	if (_block) {
		_block();
	}
}
@end
