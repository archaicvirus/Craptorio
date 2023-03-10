![logo](https://user-images.githubusercontent.com/25288625/224469588-27f335bb-28e2-4beb-bf83-33e6c2ca1434.png)


A de-make of Factorio for the Tic-80 fantasy console. 

**Note that at this time this project is an early WIP. Current scripts are in an unfinished state.

Core idea for de-make:
To cover the main factorio game loop, which is mining resources and using belts, 
inserters, and machines to craft science-packs which are used to research new technologies.

This is a passion project for me, and I am putting as much time into this as I can for now. That is between IRL work and daily obligations.

With that being said, not much is final ATM. Many game-mechanics will likey be left out due to the constraints
imposed by the Tic-80 dev enviornment. This is the point obviously, (or perhaps not so obvious to some) however 
I do intend to add as many features and mechanics from the original as technically feasible.

**Update: Right now, the belt system is pretty far along. Most features/mechanics from the original are already implemented, excluding red and blue belts, (which are just faster belts). The 'drag locking' feature has just been implemented, which was an addition to the original from the devs at some point. Players love this feature beacause it locks belt-placing to either x or y, depending on the direction you drag your mouse while placing belts. Helps prevent unwanted belt placement.

![drag_lock_demo](https://user-images.githubusercontent.com/25288625/224528837-a106bc2c-11fe-4817-95ad-4086f3deb01b.gif)

I plan on polishing the belt and inserter systems heavily before moving on to other entities/game mechanics.
As Harkonnen said, 'belts are the very heartbeat of factorio'. So I want these systems to function
exceptionally well before trying to implement additional features. I believe once the core systems are worked out, 
I will eventually create a list of proposed features, and try to order them by development priority.

![belt_snapping](https://user-images.githubusercontent.com/25288625/222978303-0ff2decd-3981-4e2b-823a-a885bbd344d6.gif)

![video1](https://user-images.githubusercontent.com/25288625/222978373-efa24fc3-2851-46a9-8c2d-35efd1f96f06.gif)

Belts:
The idea here is to re-create belts VERY similar to factorio, however there are some differences.
The belts in Craptorio are displayed as 8x8 pixel sprites, with 4 animation frames.
When watching the belt animation however, it appears as if the belt has 8 animation frames, which makes it seem like the belt is moving 1-pixel per frame. This is by design - due to making the texture x-tileable. Only 4 frames are needed before the texture 'loops'.

The belts have 2 - lanes, just as in Factorio's belts. Each lane is represented as a table with 8 indices, so 1 item slot per belt pixel, 8 item slots per lane. This means that each belt, when fully compressed can hold 16 items. This is a few more total items per belt than Factorio belts allow (14 I believe), so further optimization will be necessary. Each index corresponds to an item id, which itself is a key/index to a look-up table of item definitions. When the belt updates each cycle, (not every tick), all lane indices values are shifted to the left (towards 0). Index 1 represents the last item slot a belt has, before the item would output to whatever the belt is facing, with index 8 being the last slot to the right (given the belt is facing left). The items are rendered in order from index 1 to index 8, and the belt's themselves are rendered in order of parent->child. 

Items on belts are allowed to 'stack', which practically means that the items can overlap (by 2-pixels in my case). The items are displayed as 3x3 pixel 'sprites', which aren't actually sprites, but a table of 9 colorkey's {1,2,3,4,5,6,7,8,9} with each index representing a palette color. The item's x,y location is computed during rendering, as their 'positions' are relative to the owning belt, and not needing to be stored or known globally. This approach neglects needing another table to otherwise keep track of all items.

Curved belts are also implemented, again as in the original game. The snapping behavior has been replicated, as well as the lane priority system, or preference to deposit items to specific other belt lanes depending on both belts rotation. The lane-priority-rotational-preferences also apply to inserters when depositing items onto a belt.

Inserters:
Inserters are rendered using 2 8x8 sprites, 1 for base, and 1 for straight arm or angled arm.    

 ![inserters_newest](https://user-images.githubusercontent.com/25288625/224526206-13c4cf53-72e3-4a7f-8751-882f974cc4ca.PNG)

Rotation, flipping, and position offsets of the inserters arm sprite's are pre-calculated and indexed to a look-up table (based on inserters current rotation), to avoid having many if statements. This also avoids excessive table look-ups, as the inserter only has to access this LUT when the player manually rotates the inserter, or places a new one down. There may be other situations I haven't thought of, but for now this should do.   


![inserter_compression](https://user-images.githubusercontent.com/25288625/223278786-12aab20c-7b2d-4715-b91a-6608e8ad559a.gif)
![inserters](https://user-images.githubusercontent.com/25288625/223278793-1f127a68-ccfd-4077-9afc-1702033ee9d3.gif)
