![craptorio_intro_screen2](https://github.com/archaicvirus/Craptorio/assets/25288625/d7617eda-aeee-45b1-941e-1cfa05e74992)

A de-make of Factorio for the [TIC-80](https://tic80.com/) fantasy console. 


![furnace_stack_demo_4](https://github.com/archaicvirus/Craptorio/assets/25288625/7d1ec8f1-e66a-4146-bb75-e83adba0bdc6)

**Note, this project is a WIP.
- If you have found this page and would like to contribute to the project, please open a discussion and we can talk about the details.
# Core idea for de-make
- To cover the main factorio game loop, which is mining resources and using belts, 
inserters, and machines to craft science-packs which are used to research new technologies.

- This is a passion project for me, and I am putting as much time into this as I can for now. That is between IRL work and daily obligations.

- Certain game-mechanics will likey be left out, due to the constraints
imposed by TIC80. This is the point obviously, (or perhaps not so obvious to some) however 
I do intend to add as many features and mechanics from the original as technically feasible.

# Updates - Will post development and progress updates here
- Updated palette
- Added assembly machine
- Added trees
- Big updates to worldgen system
- Added burner mining drill
- Added stone furnace
- Added underground belts
- Research will include upgrades to the player robot, such as increased fly speed, further range, etc
- You now play as an advanced logistics robot, capable of flying over any terrain or obstacles
- ~Working on finishing new splitters~
 ~Currently working on crafting mechanics, inventory, and item systems.~
 -![new_recipe_widgets](https://github.com/archaicvirus/Craptorio-Internal/assets/25288625/90b5c7d6-3b59-43c2-be45-35783bc8732b)
- ![lab_research_test](https://github.com/archaicvirus/Craptorio-Internal/assets/25288625/9294fb0f-8e91-41e4-bbcc-46e668efbb34)
- ![tech_hover_ex](https://github.com/archaicvirus/Craptorio-Internal/assets/25288625/33f77957-508f-4127-b120-758bbee6a32c)
- ![tech_scrn_active](https://github.com/archaicvirus/Craptorio-Internal/assets/25288625/ebf71445-6970-4d6f-8b39-5a775934bd48)
- ![furnace_ui_v5](https://github.com/archaicvirus/Craptorio-Internal/assets/25288625/8197e646-1259-421f-b6cf-b210370a55bb)
- ![new_furnace_ui](https://github.com/archaicvirus/Craptorio/assets/25288625/6ed8d134-03e4-4e61-b566-973309a34b36)
- ![assembly_ui_layout_4](https://github.com/archaicvirus/Craptorio/assets/25288625/7f3aef5d-6e93-4471-95db-4b4932bc33be)
- ![assembly_recipie_overlay_demo](https://github.com/archaicvirus/Craptorio/assets/25288625/53389950-9337-43ef-aa96-f9320457ea73)
- ![screen2](https://github.com/archaicvirus/Craptorio-Internal/assets/25288625/088a6b57-7863-4003-8cd3-11ccaf7e8413)
- ![worldgen_demo](https://github.com/archaicvirus/Craptorio-Internal/assets/25288625/4a151e15-a226-4ce3-966a-7de3ef9d6062)
- ![worldgen_update3](https://github.com/archaicvirus/Craptorio-Internal/assets/25288625/343df362-d373-4240-b7f6-7974bcab28c4)
- ![f4rt-1](https://github.com/archaicvirus/Craptorio-Internal/assets/25288625/989fa482-22f1-4b12-9b68-caa3deed29ae)
- ![worldmap_discovery](https://github.com/archaicvirus/Craptorio-Internal/assets/25288625/dc3e7129-e8bc-41cd-8257-d36b8ea812f1)
- ![ubelt_test1](https://github.com/archaicvirus/Craptorio/assets/25288625/7638a38c-8823-49d5-be13-911b5a2f873c)
- ![ubelt_test2](https://github.com/archaicvirus/Craptorio/assets/25288625/c76fa145-b73c-4960-a058-f8cf051e807b)
- ![forest_demo](https://github.com/archaicvirus/Craptorio/assets/25288625/ccbcea60-1ac6-4772-a3af-81cf631ef3d5)
- ![becoming_the_bot](https://user-images.githubusercontent.com/25288625/233747874-5dfce2ab-9124-4e01-b493-294773ee6e85.gif)
- ![crafting_menu_test](https://user-images.githubusercontent.com/25288625/229274215-6586e950-eccf-4b99-a30b-f95d4678e94b.gif)
- ![ui_test_05](https://user-images.githubusercontent.com/25288625/229348513-abfbc5e8-b86c-4a69-987f-53a673d63163.gif)
- ![craft_menu](https://github.com/archaicvirus/Craptorio/assets/25288625/2cc45a1e-c548-44f0-ac09-15d591d13d6b)


https://github.com/archaicvirus/Craptorio/assets/25288625/d650e794-95a6-487c-966f-d57d29cd6d68


# Transport Belt
- The idea here is to re-create belts VERY similar to factorio, however there are some differences.
- The belts in Craptorio are displayed as 8x8 pixel sprites, with 4 animation frames. 
- When watching the belt animation however, it appears as if the belt has 8 animation frames, which makes it seem like the belt is moving 1-pixel per frame. This is by design - due to making the texture x-tileable. Only 4 frames are needed before the texture 'loops'.
- This behavior is needed due to items on belts needing to shift 1-pixel per game tick to move along the belt.
- The belts have 2 - lanes, just as in Factorio's belts. Each lane is represented as a table with 8 indices, so 1 item slot per belt pixel, 8 item slots per lane. This means that each belt, when fully compressed can hold 16 items. This is a few more total items per belt than Factorio belts allow (14 I believe), so further optimization will be necessary. Each index corresponds to an item id, which itself is a key/index to a look-up table of item definitions. When the belt updates each cycle, (not every tick), all lane indices values are shifted to the left (towards 0). Index 1 represents the last item slot a belt has, before the item would output to whatever the belt is facing, with index 8 being the last slot to the right (given the belt is facing left). The items are rendered in order from index 1 to index 8, and the belt's themselves are rendered in order of parent->child.
  
![circuits3x_8x](https://github.com/archaicvirus/Craptorio/assets/25288625/b60c490d-f7d2-4324-8381-85e740fc8e9e)
![copper_iron_items](https://github.com/archaicvirus/Craptorio/assets/25288625/01ca1ca4-6ec4-4c72-b98e-06a2f996b92c)
![red_green_circuit_demo](https://github.com/archaicvirus/Craptorio/assets/25288625/742adaa6-aad5-4280-92cf-8f5ee147e5cc)
  
  
- Items on belts are allowed to 'stack', which practically means that the items can overlap (by 2-pixels in my case). The items are displayed as 3x3 pixel 'sprites', which aren't actually sprites, but a table of 9 colorkey's {1,2,3,4,5,6,7,8,9} with each index representing a palette color. The item's x,y location is computed during rendering, as their 'positions' are relative to the owning belt, and not needing to be stored or known globally. This approach neglects needing another table to otherwise keep track of all items.

- Curved belts are also implemented, again as in the original game. The snapping behavior has been replicated, as well as the lane priority system, or preference to deposit items to specific other belt lanes depending on both belts rotation. The lane-priority-rotational-preferences also apply to inserters when depositing items onto a belt.

**Update: ~Right now, the belt system is pretty far along. Most features/mechanics from the original are already implemented, excluding red and blue belts, (which are just faster belts). The 'drag locking' feature has just been implemented, which was an addition to the original from the devs at some point. Players love this feature beacause it locks belt-placing to either x or y, depending on the direction you drag your mouse while placing belts. Helps prevent unwanted belt placement.~ - Completed!

![drag_lock_demo](https://user-images.githubusercontent.com/25288625/224528837-a106bc2c-11fe-4817-95ad-4086f3deb01b.gif)

~I plan on polishing the belt and inserter systems heavily before moving on to other entities/game mechanics.~ - Done!
As Harkonnen said, 'belts are the very heartbeat of factorio'. So I want these systems to function
exceptionally well before trying to implement additional features. I believe once the core systems are worked out, 
I will eventually create a list of proposed features, and try to order them by development priority.

![belt_snapping](https://user-images.githubusercontent.com/25288625/222978303-0ff2decd-3981-4e2b-823a-a885bbd344d6.gif)

![video1](https://user-images.githubusercontent.com/25288625/222978373-efa24fc3-2851-46a9-8c2d-35efd1f96f06.gif)



# Inserters
Inserters are rendered using 2 8x8 sprites, 1 for base, and 1 for straight arm or angled arm.    

 ![inserters_newest](https://user-images.githubusercontent.com/25288625/224526206-13c4cf53-72e3-4a7f-8751-882f974cc4ca.PNG)

- Rotation, flipping, and position offsets of the inserters arm sprite's are pre-calculated and indexed to a look-up table (based on inserters current rotation), to avoid having many if statements. This also avoids excessive table look-ups, as the inserter only has to access this LUT when the player manually rotates the inserter, or places a new one down. There may be other situations I haven't thought of, but for now this should do.   


![inserter_compression](https://user-images.githubusercontent.com/25288625/223278786-12aab20c-7b2d-4715-b91a-6608e8ad559a.gif)
![inserters](https://user-images.githubusercontent.com/25288625/223278793-1f127a68-ccfd-4077-9afc-1702033ee9d3.gif)

# World Generation
- See more recent updates to worldgen at top ^
- ~Skeleton system in place~
- Uses open simplex noise to generate terrain, ore fields, forests, etc
- Infinite procedural generation - completed
- Auto-tile system to have smooth borders around 8x8 terrain tiles
- Generates separate fields for iron, copper, stone, etcetera.
- ~Currently focused on ore distrubution and implementing remaining ore types (stone, coal, uranium, oil)~ - done
- ~(TODO) Need to implement similar method above to generate forests~ - done
- Still in heavy development

![simplex_ore_test](https://user-images.githubusercontent.com/25288625/227750297-cfbe41e4-0ff5-4e54-9685-22fbac108bc7.gif)
![worldgen_collision_test](https://user-images.githubusercontent.com/25288625/228401155-64cea2ba-a3d4-49bd-a124-20e3677ce22e.gif)
