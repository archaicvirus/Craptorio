# Craptorio
A de-make of Factorio for the Tic-80 fantasy computer. 

**Note that at this time this project is an early WIP. Current scripts are in an unfinished state.

Core idea for de-make:
To cover the main factorio game loop, which is mining resources and using belts, 
inserters, and machines to craft science-packs which are used to research new technologies.

I have more hours in Factorio that I want to admit. I absolutely love this game, 
and it's the best 20-30$ I have ever spent on a video game. This is a passion project for me,
and I am putting as much time into this as I can for now.

With that being said, not much is final ATM. Many game-mechanics will likey be left out due to the constraints
imposed by the Tic-80 dev enviornment. This is the point obviously, (or perhaps not so obvious to some) however 
I do intend to add as many features and mechanics from the original as possible.

Right now there is a test map setup for development.
Belts and inserters are implemented, as well as a placeholder item system (to test belt/inserter functionality), 
at a semi-final state. Belts need optimization for the item drawing routines, as testing has showed noticable TPS drop
with high numbers of items and belts.

I plan on polishing the belt and inserter systems heavily before moving on to other entities/game mechanics.
As Harkonnen said, 'belts are the very heartbeat of factorio'. So I want these systems to function
exceptionally well before trying to implement additional features. I believe once the core systems are worked out, 
I will eventually create a list of proposed features, and try to order them by development priority.

![belt_snapping](https://user-images.githubusercontent.com/25288625/222978303-0ff2decd-3981-4e2b-823a-a885bbd344d6.gif)

![video1](https://user-images.githubusercontent.com/25288625/222978373-efa24fc3-2851-46a9-8c2d-35efd1f96f06.gif)

Belts:
The idea here is to re-create belts VERY similar to factorio, however there are some small differences.
The first difference is the belts in Craptorio are displayed as 8x8 pixel sprites, with 4 animation frames.
When watching the belt animation however, it appears as if the belt has 8 animation frames, which makes it seem like the belt is moving 1-pixel per frame. This is by design - due to making the texture x-tileable. Only 4 frames are needed before the texture 'loops'.

The belts have 2 - lanes, just as in Factorio's belts. Each lane is represented as a table with 8 indices. Each index corresponds to an item id, which itself is a key/index to a table of actual item definitions. When the belt updates each cycle, (not every tick), all lane indices values are shifted to the left (towards 0). Index 1 represents the last item slot a belt has, before the item would output to whatever the belt is facing, with index 8 being the last slot to the right (given the belt is facing left). The items are rendered in order from index 1 to index 8, and the belt's themselves are rendered in order of parent->child. 

Items on belts are allowed to 'stack', which practically means that the items can overlap (by 2-pixels in my case). The items are displayed as 3x3 pixel 'sprites', which aren't actually sprites, but a table of 9 colorkey's {1,2,3,4,5,6,7,8,9} with each index representing a palette color. The item's x,y location is computed during rendering, as their 'positions' are relative to the owning belt, and not needing to be stored or known globally. This approach neglects needing another table to otherwise keep track of all items.

Curved belts are also implemented, again as in the original game. The snapping behavior has been replicated, as well as the lane priority system, or preference to deposit items to specific other belt lanes depending on both belts rotation. The lane-priority-rotational-preferences also apply to inserters when depositing items onto a belt.

Inserters:
Inserters are rendered using 3 - 8x8 sprites, 1 for base, 1 for arm, 1 for angled arm. Rotation, flipping, and position offsets of the inserters arm sprite's are pre-calculated and indexed to a look-up table (based on inserters current rotation), to avoid having many if statements. This also avoids excessive table look-ups, as the inserter only has to access this LUT when the player manually rotates the inserter, or places a new one down. There may be other situations I haven't thought of, but for now this should do.
