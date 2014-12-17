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
### Using Submodules
1. Open Terminal
2. Type: 'cd to/your/project (where you .h .m & .swift files are)'
3. Type: 'git submodule add'
4. Open your project in Xcode
5. Import the files GameScheduler/Scheduler to your project
6. Wherever you need the Scheduler use '#import "Scheduler.h"'


