# A SpriteKit Scheduling Singleton
- Rob Anderson
- robb-j
- Dec 2014


## Features
- Schedule objects to recieve a 'tick' message each frame
- Schedule groups of objects at the same time
- Schedule an annonymous block which will be called each frame
- Give your schedules a priority to determine how early / late are called (relative to each other)


## Instructions For Setup
#### Using Submodules (Best)
1. Open Terminal
2. Type: `cd to/your/project` (where you .h .m & .swift files are)
3. Type: `git submodule add`
4. Open your project in Xcode
5. Import the files in GameScheduler/Scheduler to your project
6. Wherever you need the Scheduler use `#import "Scheduler.h"`

#### Manually (Dirty)
1. Download the repository
2. Open Xcode
3. Add the files in GameScheduler/Scheduler to your project

#### Final Step (Required)
In your SKScene subclass:
- At the top `#import "Scheduler+Parent.h"`
- In `sceneUpdate:` call `[[Scheduler sharedScheduler] tickScheduler: currentTime];`



## Usage
### Sceduling
- Schedule one of your objects to recieve a `sceneUpdate:` message each frame. 
- Your objects must implement the Updatable interface (`#import "Updatable.h"`)
- The higher the priority (if given) the earlier your object will get its `sceneUpdate`

#### Scheduling Objects
- `[[Scheduler sharedScheduler] scheduleObject: myObject];`
- `[[Scheduler sharedScheduler] scheduleObject: myObject priority: 100];`
- `[[Scheduler sharedScheduler] unScheduleObject: myObject];`

### Schedule a Group of Objects
The objects will be called in the order they are in the array.
- `[[Scheduler sharedScheduler] scheduleGroup: @[objectA, objectB, objectC] identifier: @"MyUniqueID"];`
- `[[Scheduler sharedScheduler] scheduleGroup: myArrayOfUpdatables identifier: myUniqueIdentifier];`
- `[[Scheduler sharedScheduler] unscheduleGroup: @"MyUniqueID"];`
- `[[Scheduler sharedScheduler] unscheduleGroup: myUniqueIdentifier];`

### Sceduling An Annonymous Block
If you just hit return on the block's suggestion bubble it'll prefill the nasty stuff.
- `[[Scheduler sharedScheduler] scheduleBlock:^(CFTimeInterval dt, CFTimeInterval elapsedTime, BOOL *cancel) { ... } identifier: myUniqueIdentifier];`
- `[[Scheduler sharedScheduler] unscheduleBlock: myUniqueIdentifier];`



## Warnings
- Remeber to unschedule your objects when they've been removed. I use an extra interface on game objects which gives them an `addedToScene:` and `removedFromScene:` message from their parent, which allows the object to unschedule itself.