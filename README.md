# Craptorio
A de-make of Factorio for the Tic-80 fantasy computer. 

**Note that at this time this project is an early WIP. Most scripts are either proof-of-concept or slightly beyond.

Core idea for de-make:
To cover the main factorio game loop, which is mining resources and using belts, 
inserters, and machines to craft science-packs which are used to research new technologies.

With that being said, nothing is final right now. Many game-mechanics will likey be left out due to the constraints
imposed by the Tic-80 dev enviornment. This is the point obviously, however 
I do intend to add as many features and mechanics from the original as possible.

Right now there is a test map setup for development.
Belts are working, at a semi-final state. They need optimization for the item drawing routines,
as 500 or so belts that are fully saturated, drag down TPS below 45.
Belts need to support tier 1, 2 & 3 speeds.

![belt_snapping](https://user-images.githubusercontent.com/25288625/222978303-0ff2decd-3981-4e2b-823a-a885bbd344d6.gif)

![video1](https://user-images.githubusercontent.com/25288625/222978373-efa24fc3-2851-46a9-8c2d-35efd1f96f06.gif)

