//
//  VEOUpdatable.h
//  Gadget Joe
//
//  Created by Robert Anderson on 06/05/2014.
//  Copyright (c) 2014 Robert Anderson. All rights reserved.
//

#import <Foundation/Foundation.h>


/** An object that recives update messages each frame */
@protocol Updatable <NSObject>


/** To be called when the scene updates
 @param dt The time difference since the last frame */
- (void)sceneUpdate:(CFTimeInterval)dt;


@end
