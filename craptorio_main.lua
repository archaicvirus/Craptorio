-- title:   Craptorio
-- author:  @ArchaicVirus
-- desc:    De-make of Factorio
-- site:    website link
-- license: MIT License
-- version: 0.3
-- script: lua

require('classes/item_definitions')
require('classes/images')
require('classes/ores')
require('classes/biomes')
require('classes/callbacks')
require('classes/ui')
require('classes/inventory')
require('classes/underground_belt')
require('classes/transport_belt')
require('classes/splitter')
require('classes/inserter')
require('classes/cable')
require('classes/power_pole')
require('classes/mining_drill')
require('classes/furnace')
require('classes/assembly_machine')
require('classes/research_lab')
require('classes/open_simplex_noise')
require('classes/TileManager')
require('classes/crafting_definitions')
require('classes/research_definitions')
require('classes/solar_panel')
require('classes/storage_chest')

local seed = tstamp() * time()
--seed = math.random(-1000000000, 1000000000)
--local seed = 902404786
--local seed = 747070313
--math.randomseed(53264)
math.randomseed(seed)
offset = math.random(100000, 500000)
simplex.seed()
TileMan = TileManager:new()
floor = math.floor
sspr = spr
biome = 1
db_time = 0.0
last_frame_time = time()
STATE = 'start'
--image = require('\\assets\\fullscreen_images')
--------------------COUNTERS--------------------------
TICK = 0
-------------GAME-OBJECTS-AND-CONTAINERS---------------
ENTS = {}
ORES = {}
--window = nil
CURSOR_POINTER = 286
CURSOR_HIGHLIGHT = 309
CURSOR_HIGHLIGHT_CORNER = 307
CURSOR_HIGHLIGHT_CORNER_S = 336
CURSOR_HAND_ID = 320
CURSOR_GRAB_ID = 321
WATER_SPRITE = 224
technology = {}
logo = {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,4,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,3,2,2,2,3,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,3,3,3,3,3,3,3,3,3,3,3,0,0,1,1,1,1,1,1,1,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,1,1,1,1,1,1,1,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,1,1,1,1,1,1,1,1,1,1,1,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,1,1,1,1,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,1,1,1,1,1,1,1,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,1,1,1,1,1,1,1,1,1,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,1,1,1,1,1,1,1,1,3,3,3,3,3,3,3,3,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,4,2,2,2,2,2,2,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,3,2,2,2,2,2,2,2,2,2,2,3,2,0,0,1,1,1,1,1,2,3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,1,1,1,1,1,3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,2,3,1,1,1,1,1,1,1,1,2,2,3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,3,3,2,3,1,1,1,3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,1,1,1,0,0,3,2,1,2,2,2,2,2,3,2,3,2,2,2,2,2,2,2,2,2,3,3,1,1,1,1,1,1,2,3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,1,1,1,1,1,1,3,1,2,2,2,2,2,2,2,3,1,1,1,1,1,1,1,1,1,1,1,4,4,1,1,1,1,1,1,1,1,4,2,2,2,2,2,2,4,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,2,3,3,3,3,2,2,2,2,2,2,2,2,3,2,0,0,1,1,1,1,1,3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,0,1,1,1,1,3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,3,3,2,3,1,1,1,1,1,1,0,2,3,3,3,3,2,2,2,2,2,2,2,2,2,2,2,2,2,3,3,2,3,3,1,1,2,3,3,3,3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,0,1,1,0,0,3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,3,1,1,1,15,1,3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,0,1,1,1,1,3,2,2,2,2,2,2,2,2,2,3,0,1,1,1,1,1,1,1,1,1,2,2,2,4,2,1,1,1,2,2,2,2,2,2,2,2,2,2,2,4,2,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,0,2,3,3,3,3,3,3,3,2,2,2,2,2,2,3,2,0,0,1,1,1,0,0,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,3,3,3,2,3,1,1,1,1,1,0,2,3,3,3,3,3,3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,3,0,1,2,3,3,3,3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,1,1,0,0,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,1,1,1,0,3,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,1,1,0,0,3,2,2,2,2,2,2,2,2,2,3,0,1,1,1,1,1,1,1,1,1,0,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,0,1,4,4,2,2,1,1,1,1,1,1,1,1,0,2,3,3,3,3,3,3,2,2,2,3,2,2,2,2,2,0,0,1,1,1,0,2,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,1,1,1,1,2,2,2,2,3,3,3,3,3,3,3,3,3,2,2,2,2,2,2,2,3,3,2,0,1,1,1,1,1,2,3,3,3,3,3,3,3,3,0,0,0,0,2,3,2,2,2,2,2,2,3,3,0,1,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,2,2,2,2,0,0,1,1,0,0,2,2,2,2,2,2,2,3,3,3,3,3,3,2,2,2,2,2,2,2,2,2,2,0,1,1,0,3,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,1,1,0,0,2,2,3,2,2,2,2,3,3,2,0,0,1,1,1,1,1,1,1,1,1,1,0,0,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,1,2,1,1,1,1,1,1,1,0,2,3,3,3,3,3,3,1,0,0,0,0,0,0,0,0,0,0,1,1,1,0,1,2,2,2,2,2,2,2,2,1,1,1,2,1,1,1,1,0,0,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,2,0,1,1,1,1,2,2,3,3,3,3,3,3,3,3,0,0,0,0,0,2,2,2,2,2,2,2,3,3,0,1,0,2,2,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,0,1,1,0,0,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,0,1,1,0,1,2,2,2,2,2,2,2,2,1,1,1,2,1,1,1,1,0,0,1,1,0,0,2,2,2,2,2,2,2,2,2,2,0,0,1,1,1,1,1,1,1,1,1,1,0,2,2,2,2,2,2,2,1,1,0,0,0,0,0,1,2,2,2,2,2,2,2,2,2,1,1,1,0,1,1,1,1,1,1,1,0,2,3,3,3,3,3,3,2,0,0,0,0,0,0,0,0,0,0,1,1,1,0,1,2,2,2,2,2,2,2,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,2,2,2,2,3,2,0,1,1,1,1,2,2,3,3,3,3,3,3,3,3,0,0,0,0,0,3,2,2,2,2,2,2,3,3,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,3,2,2,2,2,2,2,2,2,0,1,1,0,1,2,2,2,2,2,2,2,1,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,4,2,2,2,2,2,2,2,2,0,0,0,0,0,0,0,0,1,3,4,3,2,2,2,2,2,2,0,0,0,1,1,1,1,1,1,1,0,2,3,3,3,3,3,3,2,0,0,0,0,0,0,0,0,0,0,1,1,1,0,1,2,3,3,2,2,2,3,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,2,2,2,2,2,3,2,0,1,1,1,1,2,2,3,3,3,3,3,3,3,3,1,1,1,1,1,3,2,2,2,2,2,2,3,3,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,2,2,2,2,2,2,2,2,0,1,1,0,1,2,3,3,2,2,2,3,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,4,2,2,2,2,2,2,2,1,0,0,0,0,0,0,0,0,0,0,1,2,2,3,3,2,2,2,2,2,0,0,1,1,1,1,1,1,1,0,2,3,3,3,3,3,3,2,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,2,3,3,3,2,3,3,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,2,3,3,2,2,3,3,2,0,1,1,1,1,2,2,3,3,3,3,3,3,3,3,1,1,1,1,3,3,2,2,2,3,3,3,3,3,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,3,2,2,3,3,2,2,2,2,0,1,1,0,1,2,3,3,3,2,3,3,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,4,4,4,2,3,2,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,4,4,2,2,2,2,2,2,15,1,1,1,1,1,1,1,0,2,3,3,3,3,3,3,2,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,2,3,3,3,3,3,3,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,3,3,3,3,3,3,2,0,1,1,1,1,2,2,3,3,3,3,3,3,3,3,3,3,3,3,2,2,3,3,3,3,3,3,3,3,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,3,2,2,2,2,3,3,2,2,0,1,1,0,1,2,3,3,3,3,3,3,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,4,2,2,2,2,3,2,2,2,2,2,0,0,0,0,0,1,1,1,1,1,1,1,0,0,0,3,12,2,2,3,2,2,2,4,4,4,1,1,1,1,1,0,2,3,3,3,3,3,3,2,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,3,3,3,3,3,3,3,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,2,0,1,1,1,1,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,2,0,1,1,1,1,15,3,2,3,2,2,3,3,3,3,3,3,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,2,2,1,1,1,1,1,1,3,3,3,3,3,3,3,2,2,0,1,1,0,1,3,3,3,3,3,3,3,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,2,2,2,2,2,3,2,2,2,2,2,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,2,4,2,2,3,3,2,2,2,2,2,4,1,1,1,1,0,2,3,3,3,3,3,3,2,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,3,3,3,3,3,3,3,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,2,0,1,1,1,1,2,3,4,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,2,0,0,1,1,1,1,15,3,3,3,3,3,3,3,3,3,3,3,1,1,1,1,1,1,1,1,1,1,1,1,4,3,3,3,3,3,2,2,2,1,1,1,1,1,3,3,3,3,3,3,3,3,2,0,1,1,0,1,3,3,3,3,3,3,3,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,3,3,3,3,3,3,3,3,3,2,2,1,1,1,1,2,1,2,2,2,2,3,2,2,2,2,2,1,0,0,1,1,1,1,1,1,1,1,1,1,1,0,1,4,2,2,3,3,2,2,2,2,2,2,4,1,1,1,0,2,3,3,3,3,3,3,2,1,1,1,1,1,1,1,1,1,1,1,1,1,0,2,3,3,3,3,3,3,3,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,2,0,1,1,1,1,2,3,4,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,0,0,0,1,1,1,1,15,3,3,3,3,3,3,3,3,3,3,3,0,1,1,1,1,1,1,1,1,1,1,1,4,3,3,3,3,3,3,2,2,1,1,1,1,1,3,3,2,3,3,3,3,2,2,0,1,1,0,2,3,3,3,3,3,3,3,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,3,3,3,3,3,3,3,3,3,2,1,1,1,1,1,0,0,0,0,0,0,3,2,2,2,3,2,2,0,1,1,1,1,1,1,1,1,1,1,1,1,1,2,3,3,3,3,3,2,2,2,2,2,2,0,0,1,1,0,3,3,3,3,3,3,3,2,1,1,1,1,1,1,1,1,1,1,1,1,1,0,2,3,3,3,3,3,3,3,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,3,3,3,3,3,3,3,3,2,2,2,2,2,2,3,3,3,3,3,3,3,2,0,1,1,1,1,2,3,4,3,3,3,3,3,3,3,2,1,1,1,1,1,1,2,1,1,1,0,0,0,0,1,1,1,1,0,3,3,3,3,3,3,3,3,3,3,3,0,1,1,1,1,1,1,1,1,1,1,1,4,3,3,3,3,3,2,2,1,1,1,1,1,1,3,2,2,2,3,3,3,2,2,0,1,1,0,2,3,3,3,3,3,3,3,0,1,1,1,1,1,1,1,1,1,1,1,1,1,3,3,3,3,3,3,3,3,3,3,3,0,1,1,1,1,0,0,0,0,0,0,2,3,2,2,3,3,2,2,1,1,1,1,1,1,1,1,1,1,1,1,3,2,2,3,3,3,2,2,0,0,0,0,0,0,0,1,1,0,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,2,2,1,1,1,1,0,1,2,3,3,3,3,3,3,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,3,3,3,3,3,3,3,2,0,0,0,0,0,0,3,3,3,3,3,3,3,2,0,1,1,1,1,2,2,4,3,3,3,3,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,3,3,3,3,3,3,3,3,3,3,3,2,1,1,1,1,1,1,1,1,1,1,2,4,3,3,3,3,3,2,2,2,2,2,2,2,2,2,2,2,2,3,3,3,2,2,0,1,1,0,1,2,3,3,3,3,3,3,0,1,1,1,1,1,1,1,1,1,1,1,1,1,3,2,3,3,3,2,2,3,3,3,3,1,0,1,1,1,1,0,0,0,0,0,1,3,3,3,2,2,3,2,2,2,2,1,1,1,1,1,1,1,1,3,2,2,3,3,3,2,1,0,0,0,0,0,0,0,0,1,1,0,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,2,2,1,1,1,1,0,1,2,3,3,3,3,3,3,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,3,3,3,3,3,3,3,0,0,0,0,0,0,0,3,3,3,3,3,3,3,2,0,1,1,1,1,1,2,3,3,3,3,3,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,3,3,3,3,3,3,3,3,3,3,3,2,1,1,1,1,1,1,1,1,1,1,2,4,3,3,3,3,3,3,2,2,2,2,2,3,2,2,2,2,3,3,3,2,2,2,0,1,1,0,1,2,3,3,3,3,3,3,0,1,1,1,1,1,1,1,1,1,1,1,1,1,3,2,3,2,3,2,2,2,2,3,3,1,0,1,1,1,1,1,1,0,0,0,1,3,4,3,3,2,2,2,2,2,2,2,2,2,2,2,3,2,2,2,3,3,3,3,2,2,0,0,0,0,0,0,0,0,1,1,1,0,2,3,3,3,3,3,3,3,3,3,3,3,3,3,3,2,2,0,1,1,1,0,1,2,3,3,3,3,3,3,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,2,3,3,3,3,3,3,0,0,0,0,0,0,0,3,3,3,3,3,3,3,2,0,1,1,1,1,1,2,3,3,3,3,3,3,3,3,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,3,3,3,3,3,3,3,3,3,3,3,1,1,1,1,1,1,1,1,1,1,1,1,4,3,3,3,3,3,3,3,2,2,2,3,3,3,3,3,3,3,3,2,2,2,2,0,1,1,0,1,2,3,3,3,3,3,3,0,1,1,1,1,1,1,1,1,1,1,1,1,1,3,2,3,2,2,2,2,2,2,2,3,1,0,1,1,1,1,1,1,1,0,0,4,2,3,3,3,3,2,2,2,2,2,2,2,2,2,2,2,2,3,3,3,3,3,2,2,0,4,0,0,0,1,1,1,1,1,1,1,0,0,1,2,3,3,3,3,3,3,3,3,3,3,3,3,2,1,0,1,1,1,0,0,2,2,2,3,3,2,3,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,2,2,3,3,3,3,3,1,0,0,0,0,0,0,3,3,3,3,3,3,3,2,0,1,1,1,1,1,2,3,3,3,3,3,3,3,2,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,3,3,3,3,3,3,3,3,3,3,3,1,1,1,1,1,1,1,1,1,1,0,0,4,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,3,2,2,2,2,1,0,1,1,0,0,2,2,2,3,3,2,3,0,1,1,1,1,1,1,1,1,1,1,1,1,1,3,2,2,2,2,2,2,2,2,3,2,0,0,1,1,1,1,1,1,1,0,4,3,2,2,3,4,3,2,2,2,2,2,2,3,3,3,2,2,3,3,3,3,3,2,0,1,1,1,4,0,1,1,1,1,1,1,1,1,0,0,0,0,2,2,2,2,2,2,2,2,2,2,2,2,1,0,0,1,1,1,0,0,0,1,2,2,2,2,3,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,1,2,3,3,3,3,3,0,0,0,0,0,0,0,2,3,3,3,2,2,2,0,0,1,1,1,1,0,1,2,2,2,2,2,2,2,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,3,2,2,2,2,3,3,3,3,3,3,0,1,1,1,1,1,1,1,1,1,1,0,3,3,3,3,3,3,3,3,2,2,2,3,3,3,3,3,3,2,2,2,2,0,0,0,1,1,0,0,0,1,2,2,2,2,3,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,3,2,2,2,2,2,2,2,2,0,0,0,1,1,1,1,1,1,1,0,4,2,2,2,1,0,4,4,1,2,2,2,2,2,2,2,2,2,2,2,2,1,0,0,0,2,2,2,4,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,2,2,2,1,2,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,2,2,2,2,2,2,0,1,1,1,1,1,0,2,2,2,2,2,1,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,2,3,3,1,1,2,2,2,2,2,2,0,1,1,1,1,1,1,1,1,1,2,1,0,3,3,3,3,3,3,2,2,2,2,2,2,2,2,2,2,2,1,0,0,0,0,0,1,1,0,0,0,0,2,2,2,1,2,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,3,2,2,2,2,2,2,1,0,0,0,1,1,1,1,1,1,1,0,0,0,1,0,0,0,0,0,0,0,0,2,2,2,2,2,2,1,0,0,0,0,0,0,2,2,2,2,1,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,4,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,1,1,0,0,0,0,4,2,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,4,2,2,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,1,1,1,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1}
cursor = {
  x = 8,
  y = 8,
  id = 352,
  lx = 8,
  ly = 8,
  tx = 8,
  ty = 8,
  wx = 0,
  wy = 0,
  sx = 0,
  sy = 0,
  lsx = 0,
  lsy = 0,
  l = false,
  ll = false,
  m = false,
  lm = false,
  r = false,
  lr = false,
  prog = false,
  rot = 0,
  last_rotation = 0,
  hold_time = 0,
  type = 'pointer',
  item = 'transport_belt',
  drag = false,
  panel_drag = false,
  drag_dir = 0,
  drag_loc = {x = 0, y = 0},
  hand_item = {id = 0, count = 0},
  drag_offset = {x = 0, y = 0},
  item_stack = {id = 9, count = 100}
}
player = {
  x = 15 * 8, y = 600 * 8,
  spr = 362,
  lx = 0, ly = 0,
  shadow = 382,
  anim_frame = 0, anim_speed = 8, anim_dir = 0, anim_max = 4,
  last_dir = '0,0', move_speed = 0.125,
  directions = {
    ['0,0'] = {id = 362, flip = 0, rot = 0},  --straight
    ['0,-1'] = {id = 365, flip = 0, rot = 0},  --up
    ['0,1'] = {id = 365, flip = 2, rot = 0},  --down
    ['-1,0'] = {id = 363, flip = 1, rot = 0},  --left
    ['1,0'] = {id = 363, flip = 0, rot = 0},  --right
    ['1,-1'] = {id = 364, flip = 0, rot = 0},  --up-right
    ['-1,-1'] = {id = 364, flip = 1, rot = 0},  --up-left
    ['-1,1'] = {id = 364, flip = 3, rot = 0},  --down-left
    ['1,1'] = {id = 364, flip = 2, rot = 0}   --down-right
  },
}

dummies = {
  ['dummy_furnace'] = true,
  ['dummy_assembler'] = true,
  ['dummy_drill'] = true,
  ['dummy_lab'] = true,
  ['dummy_splitter'] = true
}

opensies = {
  ['stone_furnace'] = true,
  ['assembly_machine'] = true,
  ['research_lab'] = true,
  ['chest'] = true,
}

inv = make_inventory()
inv.slots[1].item_id  = 35 inv.slots[1].count = 100
inv.slots[57].item_id = 9  inv.slots[57].count = 100
inv.slots[58].item_id = 10 inv.slots[58].count = 100
inv.slots[59].item_id = 11 inv.slots[59].count = 100
inv.slots[60].item_id = 13 inv.slots[60].count = 100
inv.slots[61].item_id = 14 inv.slots[61].count = 100
inv.slots[62].item_id = 18 inv.slots[62].count = 100
inv.slots[63].item_id = 19 inv.slots[63].count = 100
inv.slots[64].item_id = 22 inv.slots[64].count = 100
craft_menu = ui.NewCraftPanel(135, 1)
vis_ents = {}
show_mini_map = false
show_tile_widget = false
debug = false
alt_mode = false
show_tech = false
show_count = false
--water effect defs
local num_colors = 3
local start_color = 8
local tileSize = 8
local tileCount = 1
local amplitude = num_colors
local frequency = 0.185
local speed = 0.0022
--------------------
sounds = {
  ['deny']        = {id = 5, note = 'C-3', duration = 22, channel = 0, volume = 15, speed = 0},
  ['place_belt']  = {id = 4, note = 'B-3', duration = 10, channel = 0, volume = 15, speed = 4},
  ['delete']      = {id = 2, note = 'C-3', duration =  4, channel = 0, volume = 15, speed = 5},
  ['rotate_r']    = {id = 3, note = 'E-5', duration = 10, channel = 0, volume = 15, speed = 3},
  ['rotate_l']    = {id = 7, note = 'E-5', duration =  5, channel = 0, volume = 15, speed = 4},
  ['move_cursor'] = {id = 0, note = 'C-4', duration =  4, channel = 0, volume = 15, speed = 5},
  ['axe']         = {id = 9, note = 'D-3', duration = 20, channel = 0, volume = 15, speed = 5},
}

resources = {
  ['2']  = {id = 5, min =  5, max = 20}, --rocks
  ['7']  = {id = 5, min =  5, max = 10},
  ['8']  = {id = 5, min =  1, max =  3},
  ['24'] = {id = 5, min =  1, max =  3},
  ['26'] = {id = 5, min =  4, max = 15},
  ['40'] = {id = 5, min =  4, max = 15},
  ['42'] = {id = 5, min =  4, max = 15},

  ['3']  = {id = 34, min = 5, max = 12}, --fiber
  ['4']  = {id = 34, min = 5, max = 12},
  ['5']  = {id = 34, min = 5, max = 12},
  ['6']  = {id = 34, min = 5, max = 12},
  ['1']  = {id = 34, min = 5, max = 12},
  ['17'] = {id = 34, min = 5, max = 12},
  ['18'] = {id = 34, min = 5, max = 12},
  ['19'] = {id = 34, min = 5, max = 12},
  ['20'] = {id = 34, min = 5, max = 12},
  ['22'] = {id = 34, min = 5, max = 12},
  ['33'] = {id = 34, min = 5, max = 12},
  ['34'] = {id = 34, min = 5, max = 12},
  ['35'] = {id = 34, min = 5, max = 12},
  ['36'] = {id = 34, min = 5, max = 12},
  ['37'] = {id = 34, min = 5, max = 12},
  ['39'] = {id = 34, min = 5, max = 12},

}

dust = {}

_t = 0
sprites = {}
loaded = false

function BOOT()
  spawn_player()
  -- local tile, _, _ = get_world_cell(player.x, player.y)
  -- biome = tile.biome
   poke(0x3FF8, 0)
   --poke(0x03FF8, 0)
   
end

function hovered(_mouse, _box)
  local mx, my, bx, by, bw, bh = _mouse.x, _mouse.y, _box.x, _box.y, _box.w, _box.h
  return mx >= bx and mx < bx + bw and my >= by and my < by + bh
end

function pokey(bnk,sid,tw,th,x,y,ck,rot)
  rot = rot or 0
  if bnk == 0 then sspr(sid, x, y, ck, 1, 0, rot, tw, th) return end
  for ty=0,th-1 do
    for tx=0,tw-1 do
      for sy=0,7 do
        for sx=0,7 do
          local px = x + tx * 8 + sx
          local py = y + ty * 8 + sy
          local pixel = sprites[bnk][(sid + tx + ty * 16)][sy * 8 + sx]

          -- Check if pixel matches color_key
          local skip_pixel = false
          if type(ck) == 'table' then
            -- If color_key is a table, check if pixel is in the table
            for _, value in ipairs(ck) do
              if pixel == value then
                skip_pixel = true
                break
              end
            end
          else
            -- If color_key is a single value, directly compare with pixel
            if pixel == ck then
              skip_pixel = true
            end
          end

          -- Skip drawing this pixel if it matches the color_key
          if skip_pixel then
            goto continue
          end

          local addr = (py * 240 + px) // 2
          if px % 2 == 0 then
            -- Modify the least significant nibble
            local byte = peek(addr)
            byte = (byte & 0xF0) | pixel
            poke(addr, byte)
          else
            -- Modify the most significant nibble
            local byte = peek(addr)
            byte = (byte & 0x0F) | (pixel << 4)
            poke(addr, byte)
          end

          ::continue::
        end
      end
    end
  end
end

function load_sprites()
  local s = "Loading Bank ".. _t .. (("."):rep((_t+1)%4))
  local _w = print(s,0,-6)
  prints(s,(240//2)-(_w//2),65)
  if _t==8 then sync(0,0,false) loaded = true return end
  sync(0,_t,false)
  sprites[_t] = {}
  for i=0,511 do
    sprites[_t][i] = {}
    for j=0,31 do
      local byte = peek(0x4000 + i * 32 + j)
      sprites[_t][i][j*2] = byte & 0x0F
      sprites[_t][i][j*2 + 1] = (byte >> 4) & 0x0F
    end
  end
  _t=_t+1
end

function move(o)
  o.x = o.x + o.vx
  o.y = o.y + o.vy
end

function particles()
  for i,d in pairs(dust) do
    move(d)
    d.vx, d.vy = d.vx * 1.015, d.vy * 1.015    
    --if (d.t//1)%5==0 and d.c>3 then d.c=d.c-1 end    
    if d.t < 5 then d.r = d.r/1.1 d.c = d.c - (d.c > 3 and 1 or 0) end
    d.t = d.t - 1 + math.random()
    if d.r < 1 then	table.remove(dust, i) end
  end
end

function new_dust(x_, y_, r_, vx_, vy_)
  for i = 0, 1 do
    table.insert(dust, {x = x_, y = y_, c = 4, ty = math.random(-1, 1), vx = vx_, vy = vy_, r = math.random() * r_, t = 5 * r_})
  end
end

function get_sprite_pixel(sprite_id, x, y)
  -- Arguments: sprite_id (0-511), x (0-7), y (0-7)
  local byte = peek(0x04000 + sprite_id * 32 + y * 4 + math.floor(x / 2))
  return x % 2 == 0 and byte % 16 or byte // 16
end

function set_sprite_pixel(sprite_id, x, y, color)
  -- Arguments: sprite_id (0-511), x (0-7), y (0-7), color (palette index 0-15)
  local addr = 0x04000 + sprite_id * 32 + y * 4 + math.floor(x / 2)
  local byte = peek(addr)
  if x % 2 == 0 then poke(addr, (byte - byte % 16) + color) else poke(addr, (color * 16) + byte % 16) end
end

function sound(name)
  if sounds[name] then
    local s = sounds[name]
    sfx(s.id, s.note, s.duration, s.channel, s.volume, s.speed)
  end
end

function update_water_effect(time)
  for sprite_id = 0, (tileCount * tileCount) - 1 do
    for y = 0, tileSize - 1 do
      for x = 0, tileSize - 1 do
        -- Get the world coordinates for the current pixel
        local worldX = (sprite_id % tileCount) * tileSize + x
        local worldY = math.floor(sprite_id / tileCount) * tileSize + y
        
        -- Apply modulo operation to create a tiling texture
        local tileX = worldX % (tileSize * tileCount)
        local tileY = worldY % (tileSize * tileCount)
        
        -- Calculate the noise value using world coordinates and time
        --time = time + math.sin(time)
        local noiseValue = simplex.Noise2D(((tileX + time * speed) * frequency), (tileY + time * speed) * frequency)
        
        -- Convert the noise value to a pixel color (palette index 0-15)
        local color = math.floor(((noiseValue + 1) / 2) * amplitude) + start_color
        --local color = math.floor(((noiseValue + 1) / 2) * amplitude)
        -- Set the pixel color in the sprite
        set_sprite_pixel(224, x, y, color)
      end
    end
  end
end

function get_visible_ents()
  vis_ents = {
    ['transport_belt'] = {},
    ['inserter'] = {},
    ['power_pole'] = {},
    ['splitter'] = {},
    ['mining_drill'] = {},
    ['stone_furnace'] = {},
    ['underground_belt'] = {},
    --['underground_belt_exit'] = {},
    ['assembly_machine'] = {},
    ['research_lab'] = {},
    ['chest'] = {},
  }
  for x = 1, 31 do
    for y = 1, 18 do
      local worldX = (x*8) + (player.x - 116)
      local worldY = (y*8) + (player.y - 64)
      local cellX = floor(worldX / 8)
      local cellY = floor(worldY / 8)
      local k = cellX .. '-' .. cellY
      --if ENTS[key] and ENTS[key].type ~= 'dummy_splitter' and ENTS[key].type ~= 'dummy_drill' and ENTS[key].type ~= 'dummy_furnace' and ENTS[key] ~= then
      if ENTS[k] and vis_ents[ENTS[k].type] then
        local type = ENTS[k].type
        local index = #vis_ents[type] + 1
        --vis_ents[type][key] = ENTS[key]
        vis_ents[type][index] = k
      end
    end
  end
end

function get_ent(x, y)
  local k = get_key(x, y)
  if not ENTS[k] then
    return false
  end

  if ENTS[k].type == 'splitter' then return k end
  if ENTS[k].type == 'underground_belt_exit' then return ENTS[k].other_key, true end
  if ENTS[k].type == 'underground_belt' then return k end
  if ENTS[k].other_key then return ENTS[k].other_key else return k end
  return false
end

function get_key(x, y)
  local _, wx, wy = get_world_cell(x, y)
  return wx .. '-' .. wy
end

function get_world_key(x, y)
  return x .. '-' .. y
end

function world_to_screen(world_x, world_y)
  local screen_x = world_x * 8 - (player.x - 116)
  local screen_y = world_y * 8 - (player.y - 64)
  return screen_x - 8, screen_y - 8
end

function screen_to_world(screen_x, screen_y)
  local cam_x = player.x - 116
  local cam_y = player.y - 64
  local sub_tile_x = cam_x % 8
  local sub_tile_y = cam_y % 8
  local sx = floor((screen_x + sub_tile_x) / 8)
  local sy = floor((screen_y + sub_tile_y) / 8)
  local wx = floor(cam_x / 8) + sx + 1
  local wy = floor(cam_y / 8) + sy + 1
  return wx, wy
end

function get_cell(x, y)
  return x - (x % 8), y - (y % 8)
end

function get_screen_cell(mouse_x, mouse_y)
  local cam_x, cam_y = 116 - player.x, 64 - player.y
  local mx = floor(cam_x) % 8
  local my = floor(cam_y) % 8
  return mouse_x - ((mouse_x - mx) % 8), mouse_y - ((mouse_y - my) % 8)
end

function get_world_cell(mouse_x, mouse_y)
  local cam_x = player.x - 116
  local cam_y = player.y - 64
  local sub_tile_x = cam_x % 8
  local sub_tile_y = cam_y % 8
  local sx = floor((mouse_x + sub_tile_x) / 8)
  local sy = floor((mouse_y + sub_tile_y) / 8)
  local wx = floor(cam_x / 8) + sx + 1
  local wy = floor(cam_y / 8) + sy + 1
  return TileMan.tiles[wy][wx], wx, wy
end

function highlight_ent(k)

end

function pal(c0, c1)
  if not c0 and not c1 then
    for i = 0, 15 do
      poke4(0x3FF0 * 2 + i, i)
    end
  elseif type(c0) == 'table' then
    for i = 1, #c0, 2 do
      poke4(0x3FF0*2 + c0[i], c0[i + 1])
    end
  else
    poke4(0x3FF0*2 + c0, c1)
  end
end

function draw_item_stack(x, y, stack)
  --trace('stack count: ' .. stack.count .. ' Stack ID: ' .. stack.id)
  x, y = clamp(x, 1, 232), clamp(y, 1, 127)
  sspr(ITEMS[stack.id].sprite_id, x, y, ITEMS[stack.id].color_key)
  if show_count then
    local sx, sy = x + 2, y + 4
    local count = stack.count < 100 and stack.count or floor(stack.count/100) .. 'H'
    prints(count, sx, sy)
  end
end

function clamp(val, min, max)
  return math.max(min, math.min(val, max))
end

function prints(text, x, y, bg, fg, shadow_offset)
  shadow_offset = shadow_offset or {x = 1, y = 0}
  bg, fg = bg or 0, fg or 4
  print(text, x + shadow_offset.x, y + shadow_offset.y, bg, false, 1, true)
  print(text, x, y, fg, false, 1, true)
end

function lerp(a,b,mu)
  return a*(1-mu)+b*mu
end
--------------------------------------------------------------------------------------

function spawn_player()
  local tile = get_world_cell(116, 76)
  if not tile.is_land then
    while tile.is_land == false do
      player.x = player.x + 1
      tile = get_world_cell(116, 76)
    end
  end
end

function remap(n, a, b, c, d)
  return c + (n - a) * (d - c) / (b - a)
end

function is_water(x, y)
  local tile = get_world_cell(x, y)
  if not tile.is_land then
    sound('deny')
    return true
  end
  return false
end

function new_item_stack(id, count)
  return{
    id = id,
    count = count,
    name = ITEMS[id].name
  }
end

function is_facing(self, other, side)
  local rotations = {
    [0] = {['left'] = 1, ['right'] = 3},
    [1] = {['left'] = 2, ['right'] = 0},
    [2] = {['left'] = 3, ['right'] = 1},
    [3] = {['left'] = 0, ['right'] = 2},
  }
  if rotations[self.rot][side] == other.rot then return true else return false end
end

function move_player(x, y)
  local tile, wx, wy = get_world_cell(116 + x, 76 + y)
  local sx, sy = world_to_screen(wx, wy)
  --sspr(349, 116 + x, 77 + y, 0)
  --if tile.is_land then player.x, player.y = player.x + x, player.y + y end
  player.x, player.y = player.x + x, player.y + y
  -- local tile_nw = TileMan.tiles[y][x]
  -- local tile_ne = TileMan.tiles[y][x+1]
  -- local tile_se = TileMan.tiles[y+1][x+1]
  -- local tile_sw = TileMan.tiles[y+1][x]
  -- -- local info = {
  -- --   [1] = 'tile_nw:' .. tostring(tile_nw),
  -- --   [2] = 'tile_ne:' .. tostring(tile_ne),
  -- --   [3] = 'tile_se:' .. tostring(tile_se),
  -- --   [4] = 'tile_sw:' .. tostring(tile_sw),
  -- -- }
  -- --draw_debug_window(info, 10)
  -- if tile_nw.is_land and tile_ne.is_land and tile_se.is_land and tile_sw.is_land then
  --   player.lx, player.ly = player.x, player.y
  --   player.x, player.y = x, y
  -- end
end

function update_player()
  local dt = time() - last_frame_time
  if TICK % player.anim_speed == 0 then
    if player.anim_dir == 0 then
      player.anim_frame = player.anim_frame + 1
      if player.anim_frame > player.anim_max then
        player.anim_dir = 1
        player.anim_frame = player.anim_max
      end
    else
      player.anim_frame = player.anim_frame - 1
      if player.anim_frame < 0 then
        player.anim_dir = 0
        player.anim_frame = 0
      end
    end
  end
  player.lx, player.ly = player.x, player.y
  local x_dir, y_dir = 0, 0
  if key(23) then --w
    y_dir = -1
  end
  if key(19) then --s
    y_dir = 1
  end
  if key(1)  then --a
    x_dir = -1
  end
  if key(4)  then --d
    x_dir = 1
  end
  if not cursor.prog then
    if x_dir ~= 0 or y_dir ~= 0 then
      new_dust(120 + (-x_dir * 4), 76 + player.anim_frame + (-y_dir*4), 2, (math.random(-1, 1)/2) + (1.75 * -x_dir), (math.random(1, 1)/2) + (1.75 * -y_dir))
    elseif TICK % 24 == 0 then
      new_dust(120, 76 + player.anim_frame, 2, (math.random(-1, 1)/2) + (0.75 * -x_dir), (math.random(1, 1)/2) + (0.75 * -y_dir))
    end
    move_player(x_dir * (not show_mini_map and player.move_speed*dt or player.move_speed*dt * 8), y_dir * (not show_mini_map and player.move_speed*dt or player.move_speed*dt * 8))
  end
    player.last_dir = x_dir .. ',' .. y_dir
end

function draw_player()
  local sx, sy = world_to_screen(player.x//8 + 1, player.y//8 + 3)
  local tile, wx, wy = get_world_cell(sx, sy)
  -- if biome ~= tile.biome and not show_tech then
  --   biome = tile.biome
  --   poke(0x03FF8, biomes[tile.biome].map_col)
  -- end
  ui.highlight(sx, sy, 8, 8, false, 5, 6)
  local sprite = player.directions[player.last_dir] or player.directions['0,0']
  sspr(player.shadow - player.anim_frame, 240/2 - 4, 136/2 + 8, 0)
  sspr(sprite.id, 240/2 - 4, 136/2 - 4 + player.anim_frame, 0, 1, sprite.flip)
end

function cycle_hotbar(dir)
  inv.active_slot = inv.active_slot + dir
  if inv.active_slot < 1 then inv.active_slot = INVENTORY_COLS end
  if inv.active_slot > INVENTORY_COLS then inv.active_slot = 1 end
  set_active_slot(inv.active_slot)
end

function set_active_slot(slot)
  inv.active_slot = slot
  local id = inv.slots[slot + INV_HOTBAR_OFFSET].item_id
  if id ~= 0 then
    --trace('setting item to: ' .. ITEMS[id].name)
    cursor.item = ITEMS[id].name
    cursor.item_stack = {id = id, count = inv.slots[slot + INV_HOTBAR_OFFSET].count, slot = slot + INV_HOTBAR_OFFSET}
    cursor.type = 'item'
  else
    cursor.item = false
    cursor.type = 'pointer'
    cursor.item_stack = {id = 0, count = 0}
  end
end

function add_item(x, y, id)
  local k = get_key(x, y)
  if ENTS[k] and ENTS[k].type == 'transport_belt' then
    ENTS[k].idle = false
    ENTS[k].lanes[1][8] = id
    ENTS[k].lanes[2][8] = id
  end
end

function draw_debug_window(data, x, y)
  if debug then
    x, y = x or 2, y or 2
    local width = 74
    local height = (#data * 6) + 5
    ui.draw_panel(x, y, width, height, 0, 2, _, 0)
    for i = 1, #data do
      prints(data[i], x + 4, i*6 + y - 3, 0, 11)
    end
  end
end

function draw_ground_items()
  -- for i = 1, #GROUND_ITEMS do
  --   if GROUND_ITEMS[i][1] > 0 then
  --     draw_pixel_ssprite(GROUND_ITEMS[i][1], GROUND_ITEMS[i][2], GROUND_ITEMS[i][3])
  --   end
  -- end
end

function move_cursor(dir, x, y)
  if dir == 'up' then
    if get_flags(cursor.tx, cursor.ty - 8, 0) then cursor.ty = cursor.ty - 8 sound('move_cursor') end
  elseif dir == 'down' then
    if get_flags(cursor.tx, cursor.ty + 8, 0) then cursor.ty = cursor.ty + 8 sound('move_cursor') end
  elseif dir == 'left' then
    if get_flags(cursor.tx - 8, cursor.ty, 0) then cursor.tx = cursor.tx - 8 sound('move_cursor') end
  elseif dir == 'right' then
    if get_flags(cursor.tx + 8, cursor.ty, 0) then cursor.tx = cursor.tx + 8 sound('move_cursor') end
  end
  if dir == 'mouse' then
    cursor.tx, cursor.ty = get_screen_cell(x, y)
  end 
end

function draw_cursor()
  local x, y = cursor.x, cursor.y
  local k = get_key(x, y)

  if inv:is_hovered(x, y) or craft_menu:is_hovered(x, y) then
    if cursor.panel_drag then
      sspr(CURSOR_GRAB_ID, cursor.x - 1, cursor.y - 1, 0, 1, 0, 0, 1, 1)
    else
      sspr(CURSOR_HAND_ID, cursor.x - 2, cursor.y, 0, 1, 0, 0, 1, 1)
    end
  return
  end

  if cursor.type == 'item' and ITEMS[cursor.item_stack.id].type == 'placeable' then
    if cursor.item == 'transport_belt' then
      if cursor.drag then
        local sx, sy = world_to_screen(cursor.drag_loc.x, cursor.drag_loc.y)
        if cursor.drag_dir == 0 or cursor.drag_dir == 2 then
          ui.highlight(cursor.tx-2, sy-1, 9, 9, false, 3, 4)
          --sspr(CURSOR_HIGHLIGHT, cursor.tx - 1, sy - 1, 0, 1, 0, 0, 2, 2)
        else
          ui.highlight(sx - 2, cursor.ty-2, 9, 9, false, 3, 4)
          --sspr(CURSOR_HIGHLIGHT, sx - 1, cursor.ty - 1, 0, 1, 0, 0, 2, 2)
        end
        --arrow to indicate drag direction
        sspr(BELT_ARROW_ID, cursor.tx, cursor.ty, 0, 1, 0, cursor.drag_dir, 1, 1)
      elseif not ENTS[k] or (ENTS[k] and ENTS[k].type == 'transport_belt' and ENTS[k].rot ~= cursor.rot) then
        sspr(BELT_ID_STRAIGHT + BELT_TICK, cursor.tx, cursor.ty, BELT_COLORKEY, 1, 0, cursor.rot, 1, 1)
        ui.highlight(cursor.tx-2, cursor.ty-1, 8, 8, false, 3, 4)
        --sspr(CURSOR_HIGHLIGHT, cursor.tx - 1, cursor.ty - 1, 0, 1, 0, 0, 2, 2)
      else
        ui.highlight(cursor.tx-2, cursor.ty-1, 8, 8, false, 3, 4)
        --sspr(CURSOR_HIGHLIGHT, cursor.tx - 1, cursor.ty - 1, 0, 1, 0, 0, 2, 2)
      end
    elseif cursor.item == 'inserter' then
      if not ENTS[k] or (ENTS[k] and ENTS[k].type == 'inserter' and ENTS[k].rot ~= cursor.rot) then
        local tile, world_x, world_y = get_world_cell(cursor.tx, cursor.ty)
        local temp_inserter = new_inserter({x = world_x, y = world_y}, cursor.rot)
        temp_inserter:draw()
        ui.highlight(cursor.tx-2, cursor.ty-2, 8, 8, false, 5, 6)
        --sspr(CURSOR_HIGHLIGHT, cursor.tx - 1, cursor.ty - 1, 0, 1, 0, 0, 2, 2)
      end
      ui.highlight(cursor.tx-2, cursor.ty-2, 8, 8, false, 2, 2)
      --sspr(CURSOR_HIGHLIGHT, cursor.tx - 1, cursor.ty - 1, 0, 1, 0, 0, 2, 2)
    elseif cursor.item == 'power_pole' then
      local tile, world_x, world_y = get_world_cell(cursor.tx, cursor.ty)
      local temp_pole = new_pole({x = world_x, y = world_y})
      temp_pole:draw(true)
      --check around cursor to attach temp cables to other poles
    elseif cursor.item == 'splitter' then
      local loc = SPLITTER_ROTATION_MAP[cursor.rot]
      local tile, wx, wy = get_world_cell(x, y)
      wx, wy = wx + loc.x, wy + loc.y
      local tile2, cell_x, cell_y = get_world_cell(x, y)
      local key1 = get_key(x, y)
      local key2 = wx .. '-' .. wy
      local x, y, w, h, col1, col2 = cursor.tx-2, cursor.ty-1, 16, 8, 5, 7
      if cursor.rot == 0 or cursor.rot == 2 then
        w, h = h, w
      end
      if ENTS[key1] or ENTS[key2] then col1, col2 = 2, 2 end
      ui.highlight(x, y, w, h, false, col1, col2)
      sspr(SPLITTER_ID, cursor.tx, cursor.ty, 0, 1, 0, cursor.rot, 1, 2)
    elseif cursor.item == 'mining_drill' then
      local found_ores = {}
      local color_keys = {[1] = {0, 2}, [2] = {0, 2}, [3] = {0, 2}, [4] = {0, 2}}
      for i = 1, 4 do
        local pos = DRILL_AREA_MAP_BURNER[i]
        local k = get_key(cursor.tx + (pos.x * 8), cursor.ty + (pos.y * 8))
        local sx, sy = cursor.tx + (pos.x * 8), cursor.ty + (pos.y * 8)
        local tile, wx, wy = get_world_cell(sx, sy)
        if not tile.ore or ENTS[k] then
          color_keys[i] = {0, 5}
        end
      end
      
      -- sspr(CURSOR_HIGHLIGHT_CORNER, cursor.tx - 1, cursor.ty - 1, color_keys[1], 1, 0, 0, 1, 1)
      -- sspr(CURSOR_HIGHLIGHT_CORNER, cursor.tx + 9, cursor.ty - 1, color_keys[2], 1, 0, 1, 1, 1)
      -- sspr(CURSOR_HIGHLIGHT_CORNER, cursor.tx + 9, cursor.ty + 9, color_keys[3], 1, 0, 2, 1, 1)
      -- sspr(CURSOR_HIGHLIGHT_CORNER, cursor.tx - 1, cursor.ty + 9, color_keys[4], 1, 0, 3, 1, 1)
      local sx, sy = get_screen_cell(x, y)
      local belt_pos = DRILL_MINI_BELT_MAP[cursor.rot]
      sspr(DRILL_BIT_ID, sx + 0 + (DRILL_BIT_TICK), sy + 5, 0, 1, 0, 0, 1, 1)
      sspr(DRILL_BURNER_SPRITE_ID, sx, sy, 0, 1, 0, 0, 2, 2)
      sspr(DRILL_MINI_BELT_ID + DRILL_ANIM_TICK, sx + belt_pos.x, sy + belt_pos.y, 0, 1, 0, cursor.rot, 1, 1)
    elseif cursor.item == 'stone_furnace' then
      local sx, sy = get_screen_cell(x, y)
      sspr(FURNACE_ID, sx, sy, FURNACE_COLORKEY, 1, 0, 0, 2, 2)
    elseif cursor.item == 'underground_belt' then
      local flip = UBELT_ROT_MAP[cursor.rot].in_flip
      local result, other_key, cells = get_ubelt_connection(cursor.x, cursor.y, cursor.rot)
      -- trace('result: ' .. tostring(result))
      -- trace('other_key: ' .. tostring(other_key))
      -- trace('cells: ' .. tostring(cells))
      if result then
        local sx, sy = world_to_screen(ENTS[other_key].x, ENTS[other_key].y)
        ui.highlight(sx - 2, sy - 1, 7, 7, false, 3, 4)
        sspr(UBELT_OUT, cursor.tx, cursor.ty, ITEMS[18].color_key, 1, UBELT_ROT_MAP[cursor.rot].out_flip, cursor.rot)
        --sspr(CURSOR_HIGHLIGHT, sx - 1, sy - 1, 0, 1, 0, 0, 2, 2)
        for i, cell in ipairs(cells) do
          ui.highlight(cell.x - 2, cell.y - 1, 7, 7, false, 3, 4)
          --sspr(CURSOR_HIGHLIGHT, cell.x - 1, cell.y - 1, 0, 1, 0, 0, 2, 2)
        end
      else
        sspr(UBELT_IN, cursor.tx, cursor.ty, ITEMS[18].color_key, 1, flip, cursor.rot)
      end
      ui.highlight(cursor.tx - 2, cursor.ty - 1, 7, 7, false, 3, 4)
      --sspr(CURSOR_HIGHLIGHT, cursor.tx - 1, cursor.ty - 1, 0, 1, 0, 0, 2, 2)
    elseif cursor.item == 'assembly_machine' then
      sspr(CRAFTER_ID, cursor.tx, cursor.ty, ITEMS[19].color_key, 1, 0, 0, 3, 3)
    elseif cursor.item == 'research_lab' then
      sspr(LAB_ID, cursor.tx, cursor.ty, ITEMS[22].color_key, 1, 0, 0, 3, 3)
    elseif cursor.item == 'chest' then
      sspr(CHEST_ID, cursor.tx, cursor.ty, -1)
      ui.highlight(cursor.tx-2, cursor.ty-1, 8, 8, false, 2, 2)
    end
  elseif cursor.type == 'item' and ITEMS[cursor.item_stack.id].type ~= 'placeable' then
    draw_item_stack(cursor.x + 5, cursor.y + 5, {id = cursor.item_stack.id, count = cursor.item_stack.count})
  end
  if cursor.type == 'pointer' then
    local k = get_key(cursor.x, cursor.y)
    if ui.active_window and ui.active_window:is_hovered(cursor.x, cursor.y) then
      
    end
    sspr(CURSOR_POINTER, cursor.x, cursor.y, 0, 1, 0, 0, 1, 1)
    if show_tile_widget then
      local y_off = TICK%8
      --line(cursor.tx, cursor.ty + y_off, cursor.tx + 8, cursor.ty + y_off, 10 + TICK%5)
      ui.highlight(cursor.tx-2, cursor.ty-1, 8, 8, false, 2, 2)
    
    end
  end
end

function rotate_cursor(dir)
  dir = dir or 'r'
  --sfx(3, 'E-5', 10, 0, 15, 3)
  if not cursor.drag then
    cursor.rot = (dir == 'r' and cursor.rot + 1) or (cursor.rot - 1)
    if cursor.rot > 3 then cursor.rot = 0 end
    if cursor.rot < 0 then cursor.rot = 3 end
    local k = get_key(cursor.x, cursor.y)
    local tile, cell_x, cell_y = get_world_cell(cursor.x, cursor.y)
    if ENTS[k] then
      if ENTS[k].type == 'transport_belt' and cursor.type == 'pointer' then
        sound('rotate_' .. dir)
        ENTS[k]:rotate(ENTS[k].rot + 1)
        local tiles = {
          [1] = {x = cell_x, y = cell_y - 1},
          [2] = {x = cell_x + 1, y = cell_y},
          [3] = {x = cell_x, y = cell_y + 1},
          [4] = {x = cell_x - 1, y = cell_y}}
        for i = 1, 4 do
          local k = get_world_key(tiles[i].x, tiles[i].y)
          if ENTS[k] and ENTS[k].type == 'transport_belt' then ENTS[k]:set_curved() end
        end
      end
      if ENTS[k].type == 'inserter' and cursor.type == 'pointer' then
        sound('rotate_' .. dir)
        ENTS[k]:rotate(ENTS[k].rot + 1)
      end
    end
  elseif cursor.drag and cursor.type == 'item' and cursor.item == 'transport_belt' then
    --trace('drag-rotating')
    sound('rotate_' .. dir)
    cursor.rot = cursor.rot + 1
    if cursor.rot > 3 then cursor.rot = 0 end
    cursor.drag_dir = cursor.rot
    --trace('rotated while dragging')
    local tile, wx, wy
    local dx, dy = world_to_screen(cursor.drag_loc.x, cursor.drag_loc.y)
    if (cursor.drag_dir == 0 or cursor.drag_dir == 2) then
      _, wx, wy = get_world_cell(cursor.x, dy)
    elseif (cursor.drag_dir == 1 or cursor.drag_dir == 3) then
      _, wx, wy = get_world_cell(dx, cursor.y)
    end
    -- cursor.rot = cursor.rot + 1
    -- if cursor.rot > 3 then cursor.rot = 0 end
    --cursor.drag_offset = 
    cursor.drag_loc = {x = wx, y = wy}
  end
  if cursor.type == 'item' then sound('rotate_' .. dir) end
end

function remove_tile(x, y)
  local tile, wx, wy = get_world_cell(x, y)
  local k = get_ent(x, y)
  if k and cursor.tx == cursor.ltx and cursor.ty == cursor.lty then
    --add item back to inventory
    local stack = {id = ENTS[k].item_id, count = 1}
    remove_item[ENTS[k].type](x, y)
    --trace('adding item_id: ' .. tostring(stack.id) .. ' to inventory')
    ui.new_alert(cursor.x, cursor.y, '+ 1 ' .. ITEMS[stack.id].fancy_name, 1000, 0, 4)
    inv:add_item(stack)
    return
  end
  if cursor.held_right and cursor.tx == cursor.ltx and cursor.ty == cursor.lty then
    local result = resources[tostring(tile.sprite_id)]
    if result then
      local deposit = {id = result.id, count = floor(math.random(result.min, result.max))}
      ui.new_alert(cursor.x, cursor.y, '+ 1 ' .. ITEMS[deposit.id].fancy_name, 1000, 0, 4)
      inv:add_item(deposit)
      --trace('adding mined resource to inventory')
      TileMan:set_tile(wx, wy)
      sound('delete')
    end


    if tile.is_tree then
      --deposit wood to inventory
      local count = floor(math.random(3, 10))
      local result, stack = inv:add_item({id = 30, count = count})
      if result then 
        ui.new_alert(cursor.x, cursor.y, '+ ' .. count .. ' ' .. ITEMS[30].fancy_name, 1000, 0, 2)
      end
      TileMan:set_tile(wx, wy)
      sound('delete')
    end

    if tile.ore then
      local k = get_key(x, y)
      if not ORES[k] then
        local max_ore = floor(math.random(250, 5000))
        local ore = {
          type = ores[tile.ore].name,
          tile_id = ores[tile.ore].tile_id,
          sprite_id = ores[tile.ore].sprite_id,
          id = ores[tile.ore].id,
          total_ore = max_ore,
          ore_remaining = max_ore,
          wx = wx,
          wy = wy,
        }
        ORES[k] = ore
      end
      if ORES[k].ore_remaining > 0 then
        ORES[k].ore_remaining = ORES[k].ore_remaining - 1
        ui.new_alert(cursor.x, cursor.y, '+ 1 ' .. ITEMS[ORES[k].id].fancy_name, 1000, 0, 2)
        inv:add_item({id = ORES[k].id, count = 1})
        sound('delete')
      end
      if ORES[k].ore_remaining < 1 then
        TileManager:set_tile(wx, wy)
      end
    end
    -- local result = rocks[tostring(tile.sprite_id)]
    -- if result then
    --   --deposit stone ore to inventory
    --   local _, stack = inv:add_item({id = 5, count = floor(math.random(result[1], result[2]))})
    --   TileMan:set_tile(wx, wy)
    -- end
    -- if stack then
    --   --TODO: deposit remaing stack to ground
    -- end
  end
end

function pipette()
  if cursor.type == 'pointer' then
    local k = get_ent(cursor.x, cursor.y)
    local ent = ENTS[k]
    if ent then
      if dummies[ent.type] then
        ent = ENTS[ent.other_key]
      end
      for i = 57, #inv.slots do
        if inv.slots[i].item_id == ENTS[k].item_id then
          cursor.type = 'item'
          cursor.item = ent.type
          cursor.item_stack = {id = ent.item_id, count = inv.slots[i].count, slot = i}
          if ent.rot then
            cursor.rot = ent.rot
          end
          return
        end
      end
      for i = 1, #inv.slots - INVENTORY_COLS do
        if inv.slots[i].item_id == ENTS[k].item_id then
          cursor.type = 'item'
          cursor.item = ent.type
          cursor.item_stack = {id = ent.item_id, count = inv.slots[i].count, slot = i}
          if ent.rot then
            cursor.rot = ent.rot
          end
          return
        end
      end
      -- cursor.type = 'item'
      -- cursor.item = ent.type
      -- cursor.item_stack = {id = ent.item_id, count = 5}
      -- if ent.rot then
      --   cursor.rot = ent.rot
      -- end
      -- return
    end
  elseif cursor.type == 'item' then
    if not cursor.item_stack.slot then
      inv:add_item(cursor.item_stack)
    end
    cursor.item = false
    cursor.item_stack = {id = 0, count = 0}
    cursor.type = 'pointer'
  end
end

function update_cursor_state()
  local x, y, l, m, r, sx, sy = mouse()
  local _, wx, wy = get_world_cell(x, y)
  local tx, ty = get_screen_cell(x, y)
  --update hold state for left and right click
  if l and cursor.l and not cursor.held_left and not cursor.r then
    cursor.held_left = true
  end

  if r and cursor.r and not cursor.held_right and not cursor.l then
    cursor.held_right = true
  end

  if cursor.held_left or cursor.held_right then
    cursor.hold_time = cursor.hold_time + 1
  end

  if not l and cursor.held_left then
    cursor.held_left = false
    cursor.hold_time = 0
  end

  if not r and cursor.held_right then
    cursor.held_right = false
    cursor.hold_time = 0
  end

  cursor.ltx, cursor.lty = cursor.tx, cursor.ty
  cursor.wx, cursor.wy, cursor.tx, cursor.ty, cursor.sx, cursor.sy = wx, wy, tx, ty, sx, sy
  cursor.lx, cursor.ly, cursor.ll, cursor.lm, cursor.lr, cursor.lsx, cursor.lsy = cursor.x, cursor.y, cursor.l, cursor.m, cursor.r, cursor.sx, cursor.sy
  cursor.x, cursor.y, cursor.l, cursor.m, cursor.r, cursor.sx, cursor.sy = x, y, l, m, r, sx, sy
  if cursor.tx ~= cursor.ltx or cursor.ty ~= cursor.lty then
    cursor.hold_time = 0
  end
end

function dispatch_keypress()
  --F
  if key(6) then add_item(cursor.x, cursor.y, 1) end
  --G
  if key(7) then add_item(cursor.x, cursor.y, 2) end
  --M
  if keyp(13) then show_mini_map = not show_mini_map end
  --R
  if keyp(18) then
    if not key(64) then
      rotate_cursor('r')
    else
      rotate_cursor('l')
    end
  end
  --Q
  if keyp(17) then pipette() end
  --I or TAB
  if keyp(9) or keyp(49) then inv.vis = not inv.vis end
  --H
  if keyp(8) then toggle_hotbar() end
  --C
  if keyp(3) then toggle_crafting() end
  --Y
  if keyp(25) then debug = not debug end
  --SHIFT
  if key(64) and not keyp(18) and alt_mode then show_tile_widget = true else show_tile_widget = false end
  --ALT
  if keyp(65) then alt_mode = not alt_mode end
  --CTRL
  if keyp(63) then show_count = not show_count end
  --E
  if keyp(5) then inv:add_item({id = 1, count = 10}) end
  --T
  if keyp(20) then
    show_tech = not show_tech
    if show_tech then
      biome = 10
      poke(0x03FF8, UI_FG)
    end
  end
  --0-9
  for i = 1, INVENTORY_COLS do
    local key_n = 27 + i
    --if i == 10 then key_n = 27 end
    if keyp(key_n) then set_active_slot(i) end
  end
end

function dispatch_input()
  update_cursor_state()
  dispatch_keypress()
  if show_tech then

    return
  end

  local k = get_ent(cursor.x, cursor.y)
  if cursor.sy ~= 0 then cycle_hotbar(cursor.sy*-1) end
  if not cursor.l then
    cursor.panel_drag = false
    cursor.drag = false
  end
  
  --begin mouse-over priority dispatch
  if ui.active_window and ui.active_window:is_hovered(cursor.x, cursor.y) then
    if cursor.l and not cursor.ll then
      if ui.active_window:click(cursor.x, cursor.y) then
        --trace('clicked active window')
      end
    end
    return
  end
  
  if craft_menu.vis and craft_menu:is_hovered(cursor.x, cursor.y) then
    if cursor.l and not cursor.ll then
      if craft_menu:click(cursor.x, cursor.y, 'left') then return end
    elseif cursor.r and cursor.lr then
      if craft_menu:click(cursor.x, cursor.y, 'right') then return end
    end
    if craft_menu.vis and cursor.panel_drag then
      craft_menu.x = math.max(1, math.min(cursor.x + cursor.drag_offset.x, 239 - craft_menu.w))
      craft_menu.y = math.max(1, math.min(cursor.y + cursor.drag_offset.y, 135 - craft_menu.h))
      return
      --consumed = true
    end
    if craft_menu.vis and not cursor.panel_drag and cursor.l and not cursor.ll and craft_menu:is_hovered(cursor.x, cursor.y) then
      if craft_menu:click(cursor.x, cursor.y) then
        return
      elseif not craft_menu.docked then
        cursor.panel_drag = true
        cursor.drag_offset.x = craft_menu.x - cursor.x
        cursor.drag_offset.y = craft_menu.y - cursor.y
        return
      end
    end
    return
  end
  
  if inv:is_hovered(cursor.x, cursor.y) then
    if cursor.l and not cursor.ll then
      inv:clicked(cursor.x, cursor.y)
    end
    return
  end

  if cursor.type == 'item' and cursor.item_stack.id ~= 0 then
    --check other visible widgets
    local item = ITEMS[cursor.item_stack.id]
    local count = cursor.item_stack.count
    --check for ents to deposit item stack
    if ENTS[k] and ENTS[k].type == 'none' then --TODO
      if cursor.l then
        if ENTS[k]:can_accept(item.id) then
          local result = ENTS[k]:deposit(cursor.item_stack)
        end
      elseif cursor.r then
        --remove_tile(cursor.x, cursor.y)
        return
      end
    else
    --if item is placeable, run callback for item type
    --checking transport_belt's first (for drag-placement), then other items
      if cursor.l and cursor.item_stack.id == 9 then
        --trace('placing belt')
        local slot = cursor.item_stack.slot
        local item_consumed = place_item[cursor.item](cursor.x, cursor.y)
        if slot and item_consumed then
          inv.slots[slot].count = inv.slots[slot].count - 1
          cursor.item_stack = {id = cursor.item_stack.id, count = cursor.item_stack.count - 1, slot = cursor.item_stack.slot}
        elseif item_consumed then
          cursor.item_stack.count = cursor.item_stack.count - 1
          if cursor.item_stack.count <= 0 then
            cursor.item_stack = {id = 0, count = 0}
            cursor.item = false
            cursor.type = 'pointer'
          end
        end
        if slot and inv.slots[slot].count <= 0 then
          inv.slots[slot].item_id = 0
          inv.slots[slot].count = 0
          cursor.item = false
          cursor.type = 'pointer'
          cursor.item_stack = {id = 0, count = 0}
        end
        return
      elseif cursor.l and not cursor.ll and ITEMS[cursor.item_stack.id].type == 'placeable' then
        if place_item[cursor.item] and place_item[cursor.item](cursor.x, cursor.y) then
          if cursor.item_stack.slot then
            inv.slots[cursor.item_stack.slot].count = inv.slots[cursor.item_stack.slot].count - 1
            cursor.item_stack.count = cursor.item_stack.count - 1
            if inv.slots[cursor.item_stack.slot].count <= 0 then
              inv.slots[cursor.item_stack.slot].item_id = 0
              inv.slots[cursor.item_stack.slot].count = 0
              cursor.item_stack = {id = 0, count = 0}
              cursor.type = 'pointer'
            else
            end
          else
            cursor.item_stack.count = cursor.item_stack.count - 1
            if cursor.item_stack.count <= 0 then 
              cursor.item_stack = {id = 0, count = 0}
              cursor.type = 'pointer'
            end
          end
        end
        return
      elseif cursor.r then
        --remove_tile(cursor.x, cursor.y)
        return
      end
    end
  end

  if cursor.held_right then
    local tile, wx, wy = get_world_cell(cursor.x, cursor.y)
    local result = resources[tostring(tile.sprite_id)]
    local k = get_ent(cursor.x, cursor.y)
    if not result and not tile.is_tree and not ENTS[k] and not tile.ore then cursor.prog = false return end
    if tile.is_tree then
      local sx, sy = world_to_screen(wx, wy)
      local c1, c2 = 3, 4
      if tile.biome < 2 then c1, c2 = 2, 3 end
      ui.highlight(sx - 9 + tile.offset.x, sy - 27 + tile.offset.y, 24, 32, false, c1, c2)
      ui.highlight(cursor.tx - 2 + tile.offset.x, cursor.ty - 1 + tile.offset.y, 8, 8, false, c1, c2)
    end
    if result or tile.ore or ENTS[k] then
      ui.highlight(cursor.tx - 2, cursor.ty - 1, 8, 8, false, 2, 2)
    end
    if (ENTS[k] or tile.is_tree or tile.ore or result) then
      if TICK % 20 == 0 then
        sound('axe')
      end
      cursor.prog = clamp((cursor.hold_time/120) * 15, 0, 9)
      -- line(cursor.x - 4, cursor.y + 7, cursor.x + 5, cursor.y + 7, 0)
      -- line(cursor.x - 4, cursor.y + 7, cursor.x - 4 + prog, cursor.y + 7, 2)
      --and tile.is_tree or ENTS[k]
      if cursor.prog >= 9 then
        remove_tile(cursor.x, cursor.y)
        cursor.prog = false
        cursor.held_right = false
        cursor.hold_time = 0
        return
      end
    end
  else
    cursor.prog = false
  end

    --check for held item placement/deposit to other ents
  if ENTS[k] then ENTS[k].is_hovered = true end
  if cursor.l and not cursor.ll and not craft_menu:is_hovered(cursor.x, cursor.y) and inv:is_hovered(cursor.x, cursor.y) then
    local slot = inv:get_hovered_slot(cursor.x, cursor.y)
    if slot then
      --trace(slot.index)
      inv.slots[slot.index]:callback()
      return
    end
    
    --consumed = true
  end

  if cursor.l and not cursor.ll and ENTS[k] then

    if dummies[ENTS[k].type] then
      k = ENTS[k].other_key
    end

    if opensies[ENTS[k].type] then
      ui.active_window = ENTS[k]:open()
    end

    return
    --consumed = true
  end
end

function render_cursor_progress()
  if not cursor.prog or not cursor.r then return end
  cursor.prog = clamp((cursor.hold_time/120) * 15, 0, 9)
  line(cursor.x - 4, cursor.y + 7, cursor.x + 5, cursor.y + 7, 0)
  line(cursor.x - 4, cursor.y + 7, cursor.x - 4 + cursor.prog, cursor.y + 7, 2)
end

function toggle_hotbar()
  if not inv.hotbar_vis then
    inv.hotbar_vis = true
  else
    inv.hotbar_vis = false
    inv.hovered_slot = -1
  end
end

function toggle_crafting(force)
  if force then craft_menu.vis = true else craft_menu.vis = not craft_menu.vis end
end

function update_ents()
  if TICK % 5 == 0 then
    for k, v in pairs(ENTS) do
      if vis_ents[v.type] then
        v:update()
      end
    end
  end
end

function draw_ents()
  for i, k in pairs(vis_ents['transport_belt']) do
    if ENTS[k] then ENTS[k]:draw() end
  end
  local start = time()
  for i, k in pairs(vis_ents['transport_belt']) do
    if ENTS[k] then ENTS[k]:draw_items() end
  end
  db_time = floor((time() - start) * 1000)
  for i, k in pairs(vis_ents['stone_furnace']) do
    if ENTS[k] then ENTS[k]:draw() end
  end
  for i, k in pairs(vis_ents['underground_belt']) do
    if ENTS[k] then ENTS[k]:draw() end
  end
  for i, k in pairs(vis_ents['underground_belt']) do
    if ENTS[k] then ENTS[k]:draw_items() end
  end
  for i, k in pairs(vis_ents['splitter']) do
    if ENTS[k] then ENTS[k]:draw() end
  end
  for i, k in pairs(vis_ents['mining_drill']) do
    if ENTS[k] then ENTS[k]:draw() end
  end
  for i, k in pairs(vis_ents['assembly_machine']) do
    if ENTS[k] then ENTS[k]:draw() end
  end
  for i, k in pairs(vis_ents['research_lab']) do
    if ENTS[k] then ENTS[k]:draw() end
  end
  for i, k in pairs(vis_ents['chest']) do
    if ENTS[k] then ENTS[k]:draw() end
  end
  for i, k in pairs(vis_ents['inserter']) do
    if ENTS[k] then ENTS[k]:draw() end
  end
  for i, k in pairs(vis_ents['power_pole']) do
    if ENTS[k] then ENTS[k]:draw() end
  end
end

function draw_terrain()
  TileMan:draw_terrain(player, 31, 18)
end

function draw_tile_widget()
  local x, y = cursor.x, cursor.y
  local tile, wx, wy = get_world_cell(x, y)
  local k = get_key(x, y)
  local tile_type = tile.ore and ores[tile.ore].name .. ' Ore' or tile.is_land and 'Land' or 'Water'
  local biome = tile.is_land and biomes[tile.biome].name or 'Ocean'
  local info = {
    [1] = 'Biome: ' .. biome,
    [2] = 'Type: ' .. tile_type,
    -- [3] = 'X,Y: ' .. wx .. ',' .. wy,
    -- [4] = 'Noise: '  .. tile.noise,
    -- [5] = 'Border: ' .. tostring(tile.is_border),
  }
  if tile.is_tree then
    info[3] = 'Tree'
    info[4] = 'Gives 5-10 Wood Planks when harvested'
    local sx, sy = world_to_screen(wx, wy)
    local c1, c2 = 3, 4
    if tile.biome < 2 then c1, c2 = 2, 3 end
    ui.highlight(sx - 9 + tile.offset.x, sy - 27 + tile.offset.y, 24, 32, false, c1, c2)
  end
  if tile.ore then
    if ORES[k] then
      info[3] = 'Remainig Ore:'
      info[4] = tostring(ORES[k].ore_remaining) .. '/' .. tostring(ORES[k].total_ore)
    end
  end
  ui.draw_text_window(info, x + 8, y + 5, 'Scanning...')
end

function lapse(fn, ...)
	local t = time()
	fn(...)
	return floor((time() - t))
end

function TIC()
  if not loaded then
    load_sprites()
    return
  end
  --change mouse cursor
  poke(0x3FFB, 286)

  --draw main menu
  if STATE ~= "game" then
    update_cursor_state()
    ui.draw_menu()
    return
  end
  
  local start = time()
  TICK = TICK + 1
  update_water_effect(time())
  cls(0)

  local gv_time = lapse(get_visible_ents)
  local m_time = lapse(draw_terrain)
  --update_player()
  local up_time = lapse(update_player)
  --handle_input()
  local hi_time = lapse(dispatch_input)

  if TICK % BELT_TICKRATE == 0 then
    BELT_TICK = BELT_TICK + 1
    if BELT_TICK > BELT_MAXTICK then BELT_TICK = 0 end
  end

  if TICK % UBELT_TICKRATE == 0 then
    UBELT_TICK = UBELT_TICK + 1
    if UBELT_TICK > UBELT_MAXTICK then UBELT_TICK = 0 end
  end

  if TICK % DRILL_TICK_RATE == 0 then
    DRILL_BIT_TICK = DRILL_BIT_TICK + DRILL_BIT_DIR
    if DRILL_BIT_TICK > 7 or DRILL_BIT_TICK < 0 then DRILL_BIT_DIR = DRILL_BIT_DIR * -1 end
    DRILL_ANIM_TICK = DRILL_ANIM_TICK + 1
    if DRILL_ANIM_TICK > 2 then DRILL_ANIM_TICK = 0 end
  end

  if TICK % FURNACE_ANIM_TICKRATE == 0 then
    FURNACE_ANIM_TICK = FURNACE_ANIM_TICK + 1
    for y = 0, 3 do
      set_sprite_pixel(490, 0, y, floor(math.random(2, 4)))
      set_sprite_pixel(490, 1, y, floor(math.random(2, 4)))
    end
    if FURNACE_ANIM_TICK > FURNACE_ANIM_TICKS then
      FURNACE_ANIM_TICK = 0
    end
  end

  local ue_time = lapse(update_ents)
  --draw_ents()
  local de_time = lapse(draw_ents)
  local dcl_time = 0
  if not show_mini_map then
    local st_time = time()
    TileMan:draw_clutter(player, 31, 18)
    dcl_time = floor(time() - st_time)
  end
  --draw dust
  particles()
  for i,d in pairs(dust) do
    if d.ty>=0 then	circ(d.x,d.y,d.r,d.c)
    else circb(d.x,d.y,d.r,d.c+1) end
  end
  draw_player()

  local dc_time = lapse(draw_cursor)
  local x, y, l, m, r = mouse()
  local col = 5
  if r then col = 2 end
  -- if (l or r) and TICK % 3 == 0 then
  --   sspr(346 + BELT_TICK, x - 4, y - 4, 0, 1)
  --   line(x, y, 119, 66 + player.anim_frame, 4 + BELT_TICK)
  -- end

  if show_tile_widget then draw_tile_widget() end

  inv:draw()
  --inv:draw_hotbar()
  craft_menu:draw()
  if ui.active_window then
    if ENTS[ui.active_window.ent_key] then
      ui.active_window:draw()
    else
      ui.active_window = nil
    end
  end

  --draw_cursor()

  local info = {
    [1] = 'draw_clutter: ' .. dcl_time,
    [2] = 'draw_terrain: ' .. m_time,
    [3] = 'update_player: ' .. up_time,
    [4] = 'handle_input: ' .. hi_time,
    [5] = 'draw_ents: ' .. de_time,
    [6] = 'update_ents:' .. ue_time,
    [7] = 'draw_cursor: ' .. dc_time,    
    [8] = 'draw_belt_items: ' .. db_time,
    [9] = 'get_vis_ents: ' .. gv_time,
  }
  --draw_debug_window(info)
  local ents = 0
  for k, v in pairs(vis_ents) do
    for _, ent in ipairs(v) do
      ents = ents + 1
    end
  end

  info[9] = 0
  if show_mini_map then
    local st_time = time()
    TileMan:draw_worldmap(player, 70, 18, 75, 75, true)
    pix(121, 69, 2)
    info[9] = 'draw_worldmap: ' .. floor(time() - st_time) .. 'ms'
  end

  local tile, wx, wy = get_world_cell(cursor.x, cursor.y)
  local sx, sy = get_screen_cell(cursor.x, cursor.y)
  local k
  info[10] = 'Frame Time: ' .. floor(time() - start) .. 'ms'
  info[11] = 'Seed: ' .. seed
  info[12] = 'hold time: ' .. cursor.hold_time
  local _, wx, wy  = get_world_cell(cursor.x, cursor.y)
  local k = wx .. '-' .. wy
  if ENTS[k] and alt_mode then
    if ENTS[k].type == 'underground_belt_exit' then
      ENTS[ENTS[k].other_key]:draw_hover_widget(k)
    else
      k = get_ent(cursor.x, cursor.y)
      ENTS[k]:draw_hover_widget()
    end
  end
  for k, v in pairs(ENTS) do
    v.updated = false
    v.drawn = false
    v.is_hovered = false
    if v.type == 'transport_belt' then v.belt_drawn = false; v.curve_checked = false; end
  end
  if show_tech then draw_research_screen() end
  if debug then ui.draw_text_window(info, 2, 2, _, 0, 2, 0, 4) end
  render_cursor_progress()
  ui.update_alerts()
  last_frame_time = time()
end

-- <TILES>
-- 000:4444444444444444444444444444444444444444444444444444444444444444
-- 001:7544447677544765677475774777677444767744444234444443344444423444
-- 002:4444444444cdcc444dcdcdc4dcdcdcdccddbbdce4cdddde444eeee4444444444
-- 003:4774444474474444474764744447474744476747446747444447476444474744
-- 004:4b444b44b2c4b3c44b447c4b47447bca44b4babc4b1c4c4744b4474444744444
-- 005:44476744445626544662326746562657467757774467777f444667f444444444
-- 006:44b444444b2b4774b252b4474b3b744444747444457447544475474447545744
-- 007:444444444444444444cbcd444cbcdcd44bcdcdd44cdcdde444eeee4444444444
-- 008:44444444444444444444de444444cdc444444cd4444444444444444444444444
-- 009:4444444d44b444444bb44444444b44444444b4444d444bb444444b4444444444
-- 010:4444444444bbbbe44bbbbbbe4b0b0bbe4bbebbbe44bbbbe444bebe4444444444
-- 011:0000000000044000004444000444444004444440004444000004400000000000
-- 012:0000000044000404044444444444044444444444444444444444444444444444
-- 013:0000000000000044000004440000440400004444004444440404444404444444
-- 014:0000000000000000000000000000000000000000004444000444444044444444
-- 015:0404444004444440004444044044440000404400044444400044440404444440
-- 016:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 017:ddddd5dddddd6ddd5dd57dddd6d67dd7d6d67d7dd6d67d7ddddddddddddddddd
-- 018:ddddddddddbddddddb2bddcdddbddc2cdd7dddcddd7ddd7ddddddddddddddddd
-- 019:dddddddddddddddddd5ddddddd67dddddd67dd7ddd67d7ddddddd7dddddddddd
-- 020:dd7dddddd75ddddd7d5ddddd7dd4dddd7dddd7ddddddd57dddddd5d7dddd3dd7
-- 021:dddddddddddddddddddddddddddddbddddddbabddddddbddddddd7dddddddddd
-- 022:ddd9dddddd949dddddd8ddddddd7ddddddd7ddddddd7dddddddddddddddddddd
-- 023:dd2222ddd22b222dd222222ddd2222dddddbcdddddebcedddddeeddddddbcddd
-- 024:ddddddddddddddddddbcdddddbcdcddddeccedddddeedddddddddddddddddddd
-- 025:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 026:ddddddddddddddddddbcbddddbcbccdddcbcccdddecccfddddeefddddddddddd
-- 027:44444444444dd44444dddd444dddddd44dddddd444dddd44444dd44444444444
-- 028:44444444dd444d4d4ddddddddddd4ddddddddddddddddddddddddddddddddddd
-- 029:44444444444444d444444ddd4444dd4d444ddddd44d4dddd44dddddd4ddddddd
-- 030:444444444444444444444444444444444444444444dddd444dddddd4dddddddd
-- 031:4d4dddd44dddddd444dddd4dd4dddd4444d4dd444dddddd444dddd4d4dddddd4
-- 032:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 033:eeeeeeeeeeeeeeeee6eeeeeeee6eee6ee66ee66ee66ee66eee6ee6eeeeeeeeee
-- 034:eeeeeeeeeee6eeeee6ee6eeeee6e6ee6ee6e6e6eee6e6e6eee6e6e6eeeeeeeee
-- 035:eeeeeeeee6eeeeeeee6eeeeeee56eee66e56ee6ee666e56eee56566eee66566e
-- 036:ee2deeeee232eeeeee264eeeeee454eeeee64eeeee56eeeeeee6eeeeeeeeeeee
-- 037:eeeeeeeeee6eeeeee626eeeeee6eeeeeeeeeeeeeeeeee6eeeeee636eeeeee6ee
-- 038:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 039:eeeeeeeeeeeeeeeeeeeeee6eee6ee6e6e6e6e6eeeee6e6eeeee6e6eeeeeeeeee
-- 040:eeeeeeeeeeeeeeeeeedcdceeedcdcdfeecdcdffeefcdfffeeeffffeeeeeeeeee
-- 041:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 042:eeeeeeeeeecdcdeeecdcdcdfcdcdcddfdcddddcffddddcffeffffffeeeeeeeee
-- 043:dddddddddddeedddddeeeedddeeeeeeddeeeeeedddeeeedddddeeddddddddddd
-- 044:ddddddddeedddededeeeeeeeeeeedeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 045:ddddddddddddddeddddddeeeddddeededddeeeeeddedeeeeddeeeeeedeeeeeee
-- 046:ddddddddddddddddddddddddddddddddddddddddddeeeedddeeeeeedeeeeeeee
-- 047:deeeededdeeeeeededeeeeddddeeeededdeededddeeeeeededeeeedddeeeeeed
-- 096:0011110001111100111888001188880011888800118888000000000000000000
-- 097:b0000000bb000000bbc00000bde0000000000000000000000000000000000000
-- 112:1111111111141111111c4111111cc411111cc211111c21111112111111111111
-- 113:144411114ccc1111cccc1111cccc1111cccc1111cccc11112ccc111112221111
-- 135:1111111111111111111111111157575615656565575756566676676767677676
-- 136:1111111511111156111115755611176765611177565611176767111176756561
-- 137:7571111156561111757571116767611177771111775757711565656657575757
-- 138:1111111511111155111115551111156611111677111157671115677511167756
-- 139:6565611156565657656565657676767767676766777777777777777757777777
-- 140:1111111156711111656611115756711175676111767677117767666177756571
-- 151:6777777716777777116757571115656511575757117676761567777756567777
-- 152:7756565675656565767676766767676757775656767565577565656556565757
-- 153:76767676677777777177777761e7777176e65111577551116566561157577571
-- 154:1116757511165767115676771565677756565676666767676676767666676766
-- 155:7575767767676757777765657777575777767676677767677776767666677777
-- 156:7776776165676771667775615767765676776565677676767667676677777776
-- 160:4ce4ce44cdd4edc4dec44cf4444444444ecd4de4edf44ece4ee4ecdc444444e4
-- 161:42111121342f331133f144f1124142f1111111111431142ff323132f142f1f11
-- 162:4ce4cf448bd4fdb49ee449f444444444edcb4ff4f98e49cf4ff4ffbc44444ef4
-- 163:4400400440fe40ef400f44f0440444444044440f000e40f00ef040e44f044444
-- 164:45646544f6644664564f4654444444444f544f545664456645664f5644f44444
-- 165:41f40f440114f114410141f4444444440f104104f11f411f410411f0444440f4
-- 167:676767657676767667777777167777b711677b3b111153b21111153311111173
-- 168:656576767676777767676777777777777777777e177773223173333333153322
-- 169:7676565677757575776767672777777715e77771152111115211111151111111
-- 170:1666776311666633111111131111111111111111111111111111111111111111
-- 171:2116777732216666332222111333221111133223111322221113322111133211
-- 172:7667777661366661132211113221111122111111211111111111111111111111
-- 176:dc444444ccd444444ee444444444444444444444444444444444444444444444
-- 177:1341111144211111231111111111111111111111111111111111111111111111
-- 178:be444444cd8444444cd444444444444444444444444444444444444444444444
-- 179:4f0444440e044444f04444444444444444444444444444444444444444444444
-- 180:4574444477544444f74444444444444444444444444444444444444444444444
-- 181:4ff4444411144444ff4444444444444444444444444444444444444444444444
-- 183:1111111111111111111111111111111111111111111111111111111111111111
-- 184:2335332513335552113333321113332211233331113332211133333111333221
-- 185:e111111111111111111111111111111111111111111111111111111111111111
-- 186:1111111111111111111111111111111111111111111111111111111111111111
-- 187:1113321111132211111332111113221111133211111322111113321111132211
-- 188:1111111111111111111111111111111111111111111111111111111111111111
-- 194:0077777707556466746646567665656466677777677000007007777700746565
-- 195:0000000077000000657000076657007476650656776607567076755657576760
-- 196:0777700074746700565765706566666756777776677000070000000077770000
-- 197:1111111111111115111111551111155611111557111155611157575715577676
-- 198:11157571655656565575757557175656577565b565565bab571767b776761676
-- 199:1111111111111111757111116656111165757111565767116571761176676711
-- 200:1111111111111111111111111157575615656561575751566671676767677676
-- 201:1111111511111156111115755611676765617771565117776767717116756567
-- 202:7571111156561111157571116767611177177611775751717565656657575157
-- 204:0000000000000000000050000057770000077700000757000007775000077700
-- 205:0507700000777700077775700577777507777770077757700777777057577770
-- 210:0756665674665777766777007577700076670000676000000770000000700000
-- 211:6677777770733766002332700032230000333300000333300003333000023320
-- 212:6767700076756700776676700777657000077660000077600000067000000760
-- 213:55157775575757517676b677177b3b771177b7571111cc0611111c0511111bc1
-- 214:67676767575775717676767667617b7577776b67565677716165777711117c01
-- 215:6756576175616567565b57577576b67767b77771717777117bc7b111bb1b2b11
-- 216:6771717116777777116757571113211111113757117676761567177156567777
-- 217:7777561673276513113676316532673157365136765375577163656557573757
-- 218:717676766777b776166beb561777b66176325111573211111566561157577571
-- 220:0007777700057777000077750000050000000000000000000000000000000000
-- 221:7777767077777776777677707777777007777770067776700777777707776777
-- 222:0005000000777500007770000075700005777000000770000077000075775000
-- 224:9999999999999999999999999999999999999999999999999999999999999999
-- 227:0003223000033330000033300000333300002332000032230003333300033333
-- 228:0000070000000000000000000000000000000000000000000000000000000000
-- 229:11111c0c111111cb1111111c1111111b1111111b111111111111111111111111
-- 230:1111bb011111bc01b111cb0100110c010b11cbc1b0110c1c1bc1b0cb1b0c0cb1
-- 231:c011b111b0111111cc111111b0111111cc111111b11111111111111111111111
-- 232:67676765767176636777776116177711111711111171111111761111111b1111
-- 233:6515635626117367321733673217532613213321113233111133321111133211
-- 234:1676561675727575173767661567717613216661133211111321111133211111
-- 237:0757767707777776077677706777777507777770067776700777777067776770
-- 238:7770000000000000000000000000000000000000000000000000000000000000
-- 243:0003333000023320000322300003333000033330002333200032223000333300
-- 245:1111111111111111111111111111111111111111111111111111111111111111
-- 246:1cb0bb1111cc0c11111bc0111110bc11111b0b11111cb01111100c111110b011
-- 247:1111111111111111111111111111111111111111111111111111111111111111
-- 248:11b9b111111b1111111111111111111111111111111111111111111111111111
-- 249:1113321311133233111333321113332111133211111332111113321111333221
-- 250:3211111121111111111111111111111111111111111111111111111111111111
-- 253:0776757607777770076777600777777007777776075767706777777007677770
-- </TILES>

-- <TILES1>
-- 000:0000000000000000000000000000000c00000ccb000cc89b0cc8989bc898989b
-- 001:00000cc0000cc89c0cc8989cc898989b9898989b9898989b9898989b9898989b
-- 003:edde1111d00d1111edde11111ee111111dd111111dd1111b1dd111be1dd111b0
-- 004:eddedddedddedddedd111111ee111111dd111111bbb1111100eb1111b00bdbbd
-- 005:dde11111ddd111111dd111111ee111111dd111111dd111111dd111111dd11111
-- 010:cdeeeeeed000dddde00c32eee00d232de00c323cd00d23eee000eccce000c000
-- 011:eeeeeedcdddd000deeeee00ecdcdc00edcdcd00eeeeee00dccce000e000c000e
-- 012:11111111111111111111111111111f441111143f111114f31111114411ff1144
-- 013:1111111111111111111111f411111f4444443441444434411111114411ff1114
-- 014:111111111111111144f111111111111111111111111111111111111144111111
-- 016:c898989bc898989bc898989bc898989bc898989cc8989cc0c89cc0000cc00000
-- 017:9898989b98989bb0989bb0009bb0d000ce00d0000e00d00000e0d000000dd000
-- 019:1dd111b01dd111be1dd1111b1dd111111dd111ce1dd11cbb1dd1cbbb1dd1cbeb
-- 020:000bdbbb00eb11bbbbb111bbdd1111bbddeccebbeebbbbeebbbbbbbbdddddddd
-- 021:1dd111111dd111111ee111111dd11111ebbc1111bbbbc111bbbbbc11ddbebc11
-- 026:fddddddde0000000ddd00000ff4c0000f4feceecff4c0000ddd00000cdeeeeee
-- 027:ddddddde0000000e0000000d0000000eceecceed0000000e0000000deeeeeedc
-- 028:1f44f1441f444f4411f44433111f4f44111f4f44111f44ff1111f44411111f4d
-- 029:1f44f1dff444fdee444fdeeef4fdffe4f4dffffe4deeffffdeeeefffffe4440f
-- 030:fdf11111ffdf1111effdf111440fdf11e40ffdf1e40efdf1feeedf11ffedf111
-- 035:1ee1cbbd1dd1cbbd1ddecbbd1dddcbbd1eddcbeb11111bbb111111bb11111111
-- 036:d000000000b0000000000000d0000000ddddddddbbbbbbbbbbbbbbbb11111111
-- 037:0ddbbc1100dbbc1100dbbc110ddbbc11ddbebc11bbbbb111bbbb111111111111
-- 044:11111f4d11111144111111ff1111111111111111111111111111111111111111
-- 045:fffee40fdfffe40efdfffeee1fdfffed11fdffdf111fddf11111ff1111111111
-- 046:ffdf1111fdf11111d1111111f111111111111111111111111111111111111111
-- 080:00000000000a999900a99fff0a99f9990a9f9fff0a9f9fef0a9f9fff0a9f9999
-- 081:0000000099999999ffffffff9999999999fff99f99fef99f99fff99f99999999
-- 082:0000000099999000fff99900999f9990ff99f990ef99f990ff99f9909999f990
-- 096:0a9f9fff0aafffee0aafafff0aafaaae0aafaaae0aafaaae0aafaaae0aafaaae
-- 097:ffffffffeeeeeeeeffffffffeeeeeeeeffffffffffffffffffffffffffffffff
-- 098:fff9f990eefffa90fffafa90eaaafa90eaaafa90eaaafa90eaaafa90eaaafa90
-- 099:0aaaaaa0ae9e9e9aa9ffff9aafeeeefaaaffffaaaaaeeaaa9aaeeaa909999990
-- 112:0aafaaae0aafaaae0aafaaae0aaafaae0aaaaffe009aaaaa0009999900000000
-- 113:ffffffffffffffffffffffffffffffffeeeeeeeeaaaaaaaa9999999900000000
-- 114:eaaafa90eaaafa90eaaafa90eaafaa90effaaa90aaaaa9009999900000000000
-- 128:000000000003444400344fff0344f444034f4fff034f4fef034f4fff034f4444
-- 129:0000000044444444ffffffff4444444444fff44f44fef44f44fff44f44444444
-- 130:0000000044444000fff44400444f4440ff44f440ef44f440ff44f4404444f440
-- 144:034f4fff033fffee033f3fff033f333e033f333e033f333e033f333e033f333e
-- 145:ffffffffeeeeeeeeffffffffeeeeeeeeffffffffffffffffffffffffffffffff
-- 146:fff4f440eefff340fff3f340e333f340e333f340e333f340e333f340e333f340
-- 147:033333303e4e4e4334ffff433feeeef333ffff33333ee333433ee33404444440
-- 160:033f333e033f333e033f333e0333f33e03333ffe004333330004444400000000
-- 161:ffffffffffffffffffffffffffffffffeeeeeeee333333334444444400000000
-- 162:e333f340e333f340e333f340e33f3340eff33340333334004444400000000000
-- 176:00000000000bcccc00bccfff0bccfccc0bcfcfff0bcfcfef0bcfcfff0bcfcccc
-- 177:00000000ccccccccffffffffccccccccccfffccfccfefccfccfffccfcccccccc
-- 178:00000000ccccc000fffccc00cccfccc0ffccfcc0efccfcc0ffccfcc0ccccfcc0
-- 192:0bcfcfff0bbfffee0bbfbfff0bbfbbbe0bbfbbbe0bbfbbbe0bbfbbbe0bbfbbbe
-- 193:ffffffffeeeeeeeeffffffffeeeeeeeeffffffffffffffffffffffffffffffff
-- 194:fffcfcc0eefffbc0fffbfbc0ebbbfbc0ebbbfbc0ebbbfbc0ebbbfbc0ebbbfbc0
-- 195:0bbbbbb0becececbbcffffcbbfeeeefbbbffffbbbbbeebbbcbbeebbc0cccccc0
-- 208:0bbfbbbe0bbfbbbe0bbfbbbe0bbbfbbe0bbbbffe00cbbbbb000ccccc00000000
-- 209:ffffffffffffffffffffffffffffffffeeeeeeeebbbbbbbbcccccccc00000000
-- 210:ebbbfbc0ebbbfbc0ebbbfbc0ebbfbbc0effbbbc0bbbbbc00ccccc00000000000
-- 226:00fddf0d0fc77cfc0c7657c00ce77ec00decced002ceec20200dd00200300300
-- 227:00fddf000fcee7f00dee76500deee7700cdccec0003ee2d0030d200d00020000
-- 242:00000000000000000000000000ffff000ffffff00ffffff000ffff0000000000
-- 243:00000000000000000000000000ffff000ffffff00ffffff000ffff0000000000
-- </TILES1>

-- <SPRITES>
-- 000:ffffffffeeeeeeee4fdd4fddfdd4fdd4fdd4fdd44fdd4fddeeeeeeeeffffffff
-- 001:ffffffffeeeeeeeefdd4fdd4dd4fdd4fdd4fdd4ffdd4fdd4eeeeeeeeffffffff
-- 002:ffffffffeeeeeeeedd4fdd4fd4fdd4fdd4fdd4fddd4fdd4feeeeeeeeffffffff
-- 003:ffffffffeeeeeeeed4fdd4fd4fdd4fdd4fdd4fddd4fdd4fdeeeeeeeeffffffff
-- 004:00ffffff0feeeeeefeed4fddfed4fdd4fed4fdd4fedd4fddfefddfdefe4ff4ef
-- 005:00ffffff0feeeeeefeddddd4fefddf4ffe4ff44ffed44dd4fedddddefefddfef
-- 006:00ffffff0feeeeeefeeddd4ffeddd4fdfefdd4fdfe4ff44ffed44ddefeddddef
-- 007:00ffffff0feeeeeefeedd4fdfedd4fddfedd4fddfefdf4fdfe4ff4defed44def
-- 008:ffffffd1fffffd11ffffd11fdddd11ff111111ffffff111ffffff111ffffff1d
-- 009:ffffffff444fffff0044ffffff044434ff0444340044ffff444fffffffffffff
-- 010:ff04fffffff04fff0ff04fff40004ffff44444ffffff444ffffff444ffffff44
-- 011:f40ff04ff40ff04fff4004fffff44fffff1441fff114411f11133111c1f44f1c
-- 012:000000000600500000506060006b65000b6766b00bc77cb00bccccb000bbbb00
-- 013:b6b0000067600000b6b000000000000000000000000000000000000000000000
-- 014:00000000000f000000fc00000fcffff00cccccc000cf0000000c000000000000
-- 015:00dddd00020000d0d020000dd002000dd000200dd000020d0d00002000dddd00
-- 016:3000000300000000000000000000000000000000000000000000000030000003
-- 017:bbbbccddb0000000b0000000b0000000cf000000cedddddddf000000d0000000
-- 018:ddccbbbb0000000b0000000b0000000b000000fcddddddec000000fd0000000d
-- 019:000b0000000c00000bcbcb0000bcb000000b0000000000000000000000000000
-- 020:deecceedeffffffeecccccceeffffffeeffffffeeffffffeefff404edeee040d
-- 021:00fff00000fdcf0000fe43f000f43ddf00f43ccf00fc43df00efcdcf00fffff0
-- 022:000fff0000fcdf000fe43f00fd43df00fc43cf00fdc43f00fcdcfe000fffff00
-- 023:e4f000004df00000d4f000000000000000000000000000000000000000000000
-- 024:6560000034500000654000000000000000000000000000000000000000000000
-- 025:0300000034300000030000000000000000000000000000000000000000000000
-- 026:0cd000000cc000000dc000000000000000000000000000000000000000000000
-- 027:44444444444ef04444f000444400f0044f000004400f00f444f00f4444444444
-- 030:b0000000bb000000bbc00000bde0000000000000000000000000000000000000
-- 031:0000000000300000034000003433333344444444040000000040000000000000
-- 032:3030303000000003300000000000000330000000000000033000000003030303
-- 033:d0000000d0000000c0000000c0000000b0000000b0000000b0000000bbbbccdd
-- 034:0000000d0000000d0000000c0000000c0000000b0000000b0000000bddccbbbb
-- 035:000000000fcccc000fc0fc000fcccce00fcccce00fcccc00fcccccc000000000
-- 036:00000000d00cd00decccccce000dd000000ee000000320000003300000023000
-- 040:2210000034200000124000000000000000000000000000000000000000000000
-- 041:0ed00000efe00000dd0000000000000000000000000000000000000000000000
-- 042:fe000000efd000000ef000000000000000000000000000000000000000000000
-- 043:bcc11111ccc11111ccd111111111111111111111111111111111111111111111
-- 044:433fffff333fffff334fffffffffffffffffffffffffffffffffffffffffffff
-- 045:000fffff00fcdfee0fe43fcdfd43dfd4fc43cfd4fdc43fcdfcdcfeee0fffffff
-- 046:000fffff00fcdfee0fe21fcdfd21dfd2fc21cfd2fdc21fcdfcdcfeee0fffffff
-- 047:000fffff00fcdfee0fea9fcdfda9dfd9fca9cfd9fdca9fcdfcdcfeee0fffffff
-- 048:0000000000000000ddd00000f4ec00004ff4c000f4ec0000ddd0000000000000
-- 049:0000000000000000ddd000004fec0000ff4ec0004fec0000ddd0000000000000
-- 050:0000000000000000ddd00000ff4c0000f4fec000ff4c0000ddd0000000000000
-- 052:0003200000023000000330000002300000033000000230000002300000033000
-- 053:111111111111111c1111111011111c0011111000111c000b111000b01c000000
-- 054:11111111011111110011111100011111b00011110000011100b000110b000c11
-- 056:00000000000bcccc00bccfff0bccfccc0bcfcfff0bcfcfef0bcfcfff0bcfcccc
-- 057:00000000ccccccccffffffffccccccccccfffccfccfefccfccfffccfcccccccc
-- 058:00000000ccccc000fffccc00cccfccc0ffccfcc0efccfcc0ffccfcc0ccccfcc0
-- 060:00ed0e00edfddfd0efdeedfe0dedfeddddefded0efdeedfe0dfddfde00e0de00
-- 061:11111111111111111111111111111f441111143f111114f31111114411ff1144
-- 062:1111111111111111111111f411111f4444443441444434411111114411ff1114
-- 063:111111111111111144f111111111111111111111111111111111111144111111
-- 064:00b0000000b0000000bbb000b0bbb0000bbbb00000dd00000000000000000000
-- 065:000000000bb000000bbb0000bbbb0000bbbb00000dd000000000000000000000
-- 066:000efffe000fccdf00f4dde00f4defd00f4dfed000f4dde0000fccf0000fccff
-- 067:004ecd0004eeede0004ecde0000dcd00000dcd00004ecde004eeede0004ecd00
-- 068:0002300000032000000cd000000dc000000ce000000cd0000000000000000000
-- 069:100000001100000b1110000011110000111110001111110c1111111d11111111
-- 070:b0001d11000c1111001d11110c1111111d111111111111111111111111111111
-- 072:0bcfcfff0bbfff770bbfbfff0bbfbbbe0bbfbbbe0bbfbbbe0bbfbbbe0bbfbbbe
-- 073:ffffffff77777777ffffffffeeeeeeeeffffffffffffffffffffffffffffffff
-- 074:fffcfcc077fffbc0fffbfbc0ebbbfbc0ebbbfbc0ebbbfbc0ebbbfbc0ebbbfbc0
-- 075:0bbbbbb0becececbbcffffcbbf7777fbbbffffbbbbbeebbbcbbeebbc0cccccc0
-- 077:1f44f1441f444f4411f44433111f4f44111f4f44111f44ff1111f44411111f4d
-- 078:1f44f1dff444fdee444fdeeef4fdffe4f4dffffe4deeffffdeeeefffffe4440f
-- 079:fdf11111ffdf1111effdf111440fdf11e40ffdf1e40efdf1feeedf11ffedf111
-- 080:0000000000212000020000000100000002000000000000000000000000000000
-- 081:1aaa0111a969a011a967a011a999a0111aaa0111111111111111111111111111
-- 082:000fccff000fccf000f4dde00f4dfed00f4defd000f4dde0000fccdf000efffe
-- 088:0bbfbbbe0bbfbbbe0bbfbbbe0bbbfbbe0bbbbffe00cbbbbb000ccccc00000000
-- 089:ffffffffffffffffffffffffffffffffeeeeeeeebbbbbbbbcccccccc00000000
-- 090:ebbbfbc0ebbbfbc0ebbbfbc0ebbfbbc0effbbbc0bbbbbc00ccccc00000000000
-- 091:ece00000f6f00000cfc000000000000000000000000000000000000000000000
-- 093:11111f4d11111144111111ff1111111111111111111111111111111111111111
-- 094:fffee40fdfffe40efdfffeee1fdfffed11fdffdf111fddf11111ff1111111111
-- 095:ffdf1111fdf11111df111111f111111111111111111111111111111111111111
-- 096:0011110001111100111888001188880011888800118888000000000000000000
-- 097:1111111111141111111c4111111cc411111cc211111c21111112111111111111
-- 098:111111111111111111141411111c1c11111c1c11111c1c111112121111111111
-- 099:44444111c0c0c111cc0cc111c0c0c111ccccc111222221111111111111111111
-- 100:111111111111111111144111114cc41111cccc11112cc2111112211111111111
-- 106:00fddf0d0fc77cfc0c7657c00ce77ec00decced002ceec20200dd00200300300
-- 107:00fddf000fcee7f00dee76500deee7700cdccec0003ee2d0030d200d00020000
-- 108:000fff0002fecef020dc75ef0dccc7cf0dceccefcedccdf00cedd02000c00200
-- 109:00feef000feccef00dceecd0ecdccdce0d2dd2d002deed202003300200300300
-- 110:00300300200330022cdeedc202cddc20ecdccdc00dc77cd00f7557f000feef00
-- 112:ccffffffcdf00000ff000000f0000000f0000000f0000000f0000000f0000000
-- 113:fcccccff00cdc000000e0000000c0000000e0000000c0000000e0000000c0000
-- 114:ffffffcc00000fdc000000ff0000000f0000000f0000000f0000000f0000000f
-- 115:111111bb11111bbd1111bbbb1fe1bbcb1dddbc0c1fe1bc0c1fe1bbcb1fe1bbbb
-- 116:bbbbbbb1bdbdbdbbbbbbbbbbbbcbbbcbbc0cbc0cbc0cbc0cbbcbbbcbbbbbbbbb
-- 117:111111111111bb11b11cccc1b1bbccbbbdbe000bb1c0000cbdb0000bb1bbccbb
-- 118:111bb11111cccc111dbccbd11be000b11c0000c11b0000b111bccb111dddddd1
-- 119:111111b1f1111b0bf1bbb1befbc00b1feb000b1eeb000bef11bbb1111deded11
-- 122:00000000000000000000000000ffff000ffffff00ffffff000ffff0000000000
-- 123:00000000000000000000000000ffff000ffffff00ffffff000ffff0000000000
-- 124:000000000000000000000000000ff00000ffff0000ffff00000ff00000000000
-- 125:00000000000000000000000000000000000ff00000ffff00000ff00000000000
-- 126:0000000000000000000000000000000000000000000ff0000000000000000000
-- 128:f0000000f0000000f00000d0f0000de0f000defdf0000ff0f00000e0f0000000
-- 129:000e0000000c0000000e0000000c0000ddcedddd000c0000000e0000000c0000
-- 130:0000000f0000000fe000000fff00000ffed0000fed00000fd000000f0000000f
-- 131:1fe11bbd1fe1bb001fe1b00c1fe1b0001dddb0001fe1b0001feebb001fffbbbd
-- 132:bdbdbdbb0000000b000000000000000000000000000000000000000bbdbdbdbb
-- 133:111cccc1b111bb11b111ef11b111ef11b1eeef11bdefff11b1ef1111bdef1111
-- 134:bcb11111c0c11111bcb111111111111111111111111111111111111111111111
-- 136:000000000000000000000000000cccc000cfefed00cfefbc00eddbff00eeebff
-- 137:000000000000000000ee00000effe0000feef0000ffff000ceffeeb4ceeeebb3
-- 138:000000000000000000000000000000000000000000000000dddd0000dddded00
-- 140:0000000d00000dbb000ecbbb00eccbb900cbbab90cccaabc0cc9acbb0ddcbbbb
-- 141:cbbbbbcdbbbcbbbbbbbbb9cb9abbbccc9bbccaaabb9cc989a98abc8bbbcaacbb
-- 142:d0000000ddd00000b9cdd000bb8ddd00cbcdcd00bbdddcd0b9d8ddd099d88de0
-- 143:00bbbd000bbbbbc0ccbbccdcc9acb9dfd9caccdfdcaad9efe9dc9d8f0e9ee8f0
-- 144:f0000000f0000000f0000000f0000000f0000000ff000000cdf00000ccffffff
-- 145:000e0000000c0000000e000000ccc00000d4d0000dfffd000d4f4d00fdf4fdff
-- 146:0000000f0000000f0000000f0000000f0000000f000000ff00000fdcffffffcc
-- 147:11111bbb111111bb111111bd11eccccc1ecccced11eccccc111eeeee11111111
-- 148:bbbbbbbbbbbbbbb1ddddddb1ccccccccededdeddcccccccceeeeeeee11111111
-- 149:11ee111111dd11111eeee111ccccce11eecccce1ccccce11eeeee11111111111
-- 150:0000000000c423320c43cdcc0ccccdcd0dc432330d4221220c31cccc0c21deee
-- 151:00000d003000d0d03323edf0feedeef02332eff01221eef0eddceffddddceefd
-- 152:00feeccc00fffcdd00999cac09889aac09cccc9909ddd99909ceeeee08ceeeee
-- 153:eddeebd2edddeee2aeddeeeeaeeeebbc9eeeebcc9fffffffedddddddeddddddd
-- 154:dedeeed0eeeefee0eeedfee04ddefe003eeeedd0fffdffd0ddddfe00dffdfe00
-- 156:ddd9cbcadd89ccccdd8cc99cdecca9acedee9a9cdeefccbce8fc89cef88c999e
-- 157:ccbbbbc9aaaacdcdaaabbccd99bbaadacbbaaac9dbaaaadaecaaaacdffccdcdd
-- 158:888d88df989d8deedd8dceef98dddffe99ddffff9cdeeeffcd8e88ffa89e88ff
-- 160:cec00000efe00000cec000000000000000000000000000000000000000000000
-- 161:4310000000400000431000000000000000000000000000000000000000000000
-- 163:000ff00000cffe0000cdde0004deed200433232044222222432ff212432ff212
-- 164:ccc000dec33233dee2cdccdedefdccbceeffeefddefe34eddefdddd00dd00000
-- 165:0ccc00000dddedd099bbeb4c99daec3d89a9edde88eecce0c8ec33ce0cefccfe
-- 166:0ecdefee0deefffc0edeefc30deeffc20deedfcc00dd0ddd0000000000000000
-- 167:eeeeccdfcccfeeff232ceefd342ceefdcccceed0dddddd000000000000000000
-- 168:08d888df00d88dff00de8dff0cee0dff0eccdfff00eedfff0000dfff00000000
-- 169:efffffffffccccccec343343fc344443ec222222ffccccccefffffff00000000
-- 170:effdff00ffffdf00cfffdf00cfffdf00cffffd00fffffd00effffd0000000000
-- 172:0e8d89d90fefedd800ffff980000ffe8000000ff000000000000000000000000
-- 173:faaaa8dd9d8998ed98d88e8a88fee888ffeddeff000000000000000000000000
-- 174:da8e8ff0eeffeff08effff00efff0000ff000000000000000000000000000000
-- 176:0d000000cec000000d0000000000000000000000000000000000000000000000
-- 177:0f4d000000fc00000f4d00000000000000000000000000000000000000000000
-- 178:f4f000004cd00000f4f000000000000000000000000000000000000000000000
-- 179:fdffffffdbdfffffbfbfffffbbbfffffbbbfffffffffffffffffffffffffffff
-- 180:fbffffffbdbfffffdfbfffffbbbfffffbbbfffffffffffffffffffffffffffff
-- 181:22222fff20202fff22022fff20202fff22222fffffffffffffffffffffffffff
-- 188:0200000032200000212000000000000000000000000000000000000000000000
-- 189:0700000057700000767000000000000000000000000000000000000000000000
-- 190:0f0000004ff00000f6e000000000000000000000000000000000000000000000
-- 191:09000000a9900000989000000000000000000000000000000000000000000000
-- 192:111b011111bcc0111bccbc01bcccccc01ccccc0111ccc011111c011111111111
-- 193:1114011111433011143333014333333013333301113330111113011111111111
-- 194:1111111111cc01111ccdc0111cdcdc0111cdcdc0111cdcc01111cc0111111111
-- 195:0000000003332230032232200000000003332230023223200000000000000000
-- 196:00ec0e00ecfccfc0efceecfe0cecfeccccefcec0efceecfe0cfccfce00e0ce00
-- 197:0000000000003f00003003f003f303f003f303f003fff3f000333f0000000000
-- 198:000000000c0d00000d0c00000d0d00000c0d00000c0c00000d0d000000000000
-- 199:000000000cd00000cccd00000cccd00000cccd00000cccd00000cd0000000000
-- 200:0666666734444466666664663444644466646666006444440066666600000000
-- 201:0222222134444422222224223444244422242222002444440022222200000000
-- 202:0999999834444499999994993444944499949999009444440099999900000000
-- 203:0ccccccd344444ccccccc4cc3444c444ccc4cccc00c4444400cccccc00000000
-- 204:000dd000000ee000000cc00000d32d000d3222d00c2232c00d2222d000dd3d00
-- 205:000dd000000ee000000cc00000d56d000d5666d00c6656c00d6666d000d77d00
-- 206:000dd000000ee000000dd00000dffc000cf4ffc00dffffc00dffffe000cddc00
-- 207:000dd000000ee000000cc00000da9d000d8998d00c9999c00d99a9d000d89d00
-- 208:3334444331222223323333433222334332332223131111211322222111111111
-- 209:cccccccccf88888cc823ccdcc83ccc4cc8ccc34cf0ffff82f08888811fffff11
-- 210:ccccccccc8f8f8fcfa8a8a8fca8a8a8ccccccccc8f0f0f088f0f0f0888888888
-- 211:3230000000000000233000000000000000000000000000000000000000000000
-- 212:1111111111111111bbbbbbbbdcdcdcdccdcdcdcdbbbbbbbb1111111111111111
-- 213:bbb11111dcd11111bbb111111111111111111111111111111111111111111111
-- 214:4430000032200000133000000000000000000000000000000000000000000000
-- 219:11111111111111111111bb11111b9b1111b89b111b9a9b1bb8989bc8baaaabca
-- 220:111111111111111111bb11111b9b111bb89b11b89a9b1b9a989bc898aaabcaaa
-- 221:1111111111111111bb1111bb9b111b9b9b11b89b9b1b9a9b9bc8989babcaaaab
-- 222:0e0e0e0000dcd0000001000000010000000100000001000000010000000e0000
-- 223:e00cd00e0eedcee0000cd000000dc000000cd000000dc000000cd000000dc000
-- 224:0b000000cbb00000bdb000000000000000000000000000000000000000000000
-- 225:0400000054400000464000000000000000000000000000000000000000000000
-- 226:1110111111000111110f011110e0001110000011100000111100011111111111
-- 227:11eccd311ccedcc31ecdcc3b22dcc3dbe23c3ddbe2b3ddb1febcdb111fcbb111
-- 228:cc31111123b11111ebc111111111111111111111111111111111111111111111
-- 232:66666cff66666cf06666fcf06666fcff666cfcee666cfeee664cffff664ce000
-- 233:ff0666660ff666660f006666fff06666ee0fe666eee0e666ffffe266000fe266
-- 235:b8989bc8baaaabcab898bbc8baababcab8b89bc8bbaaabcbb8989bc8baaaabca
-- 236:989bc898aaabcaaa98bbc898ababcaabb89bc8b8aaabcbaa989bc898aaabcaaa
-- 237:9bc8989babcaaaabbbc898bbabcaabab9bc8b89babcbaaab9bc8989babcaaaab
-- 238:bab1111198911111bab111111111111111111111111111111111111111111111
-- 240:000dd000000ee000000cc00000dbbd000dcbbbd00cbbcbc00dbbbbd000ddcd00
-- 241:000dd000000ee000000cc00000d54d000d5444d00c4454c00d4444d000d5dd00
-- 246:6e666666431666664f2666666666666666666666666666666666666666666666
-- 247:666ff66666cffe6666cdde6664deed266433232644222222432ff212432ff212
-- 248:644cedde644eddde444e1122443233ee443233e043222ee043233ec066233ec0
-- 249:eddfe226edddf2262211f222ee3321220e3321220ee221120ce332120ce33266
-- 251:b8989bc8baaaabcab8989bc8baaabfbab89b1eb8babfeebabb1111bb11111111
-- 252:989bc898aaabcaaa989bc898aabfbaaa9b1eb89bbfeebabf1111bb1111111111
-- 253:9bc8989babcaaaab9bc8989bbfbaaabf1eb89b1eeebabfee11bb111111111111
-- 254:1bbbbbb1baaaaaabb898989bbaaaaaabb898989bbaaaaaabb898989b1bbbbbb1
-- </SPRITES>

-- <SPRITES1>
-- 000:1118f11111bdde111ebdcce11bbddcce1ccdf1fffee88f1f1118f11111ff811c
-- 001:1111111111111111111ddde111dbdce11ee8881f1effff1111111111deef1111
-- 002:1ce11f118bdefdb18e1ff8f111f18111ed1beff1fc8ef8cf1ffcffbc111ffefe
-- 003:111111111edc1111f4434ef1c433322e2432233fe2f2332ff11f3322e11f2f31
-- 004:112222201333331cf3333423f33334f2d2222ff1e2ff3f1111e111f1111fc111
-- 005:1f11133cd33f23422232cf21f13211f111ff4431f44124311221ff121ff11111
-- 006:111111111100f11110fe00111000001f1f0001ec11111100111111ff1110f111
-- 007:11111111f0f00111ef0000e10d0000f1f00000f1000000f100000fe1fffffe11
-- 008:1f1fff01f00ef00010001f00ff0f1ef00f1f1111e0011f000001f00ef10000f1
-- 009:f0f1110f000110e0f0e1000f1ff1f011111f110ff00010e00e0f100ff0f1f0f1
-- 010:111111fc11111fcc1111fccd111fccdd11fcdddd1fcdddddfcddddddccdddddd
-- 011:cf111111ccf11111dccf1111ddccf111dddccf11ddddccf1dddddccfdddddccc
-- 012:111ff11111fcdf111fcdddf1fcdddddffdddddcf1fcddcf111fcdf11111ff111
-- 013:111111db111111ce111111bd111111c6111111b6111111b611111c661111c666
-- 014:cd111111ec111111dc1111116c1111116c1111115c11111166c11111665c1111
-- 015:111dd111111ee111111cc11111d56d111d5666d11c6656c11d6666d111d77d11
-- 016:1bd811cbfedde1edfedee1c8f8c1ffe81ff1111f188f11111111111111111111
-- 017:beeece11bdcceee1beca81f1ef18f1f1ff1ee1f11118f11111188f1111111111
-- 019:11ffffff1111e1f11e334f11e23334f111f322ff1fff1f111ff111111f1eef11
-- 020:14443211343332e1244332f1ff4433211f2ff22fe1ff113111f1fff111111111
-- 021:c2111121342f331133f144f112c142f11f22f1111333f42ff321142f1d2f1f11
-- 022:1f00f0111fdff0111fef0f011ff0ff0110fff001100f00011100001111111111
-- 023:111111111111111111fe00f11f00d0011000000f10e0000f11000ff111111111
-- 024:f0f1f0f10e0f100ff00010e0111f110f1ff1f011f0e1000f000110e0f0f1110f
-- 025:f0111f0f0e011000f0001e0f110f1ff1f011f1110e01000ff001f0e01f0f1f0f
-- 026:eccdddddfeccdddd1fecccdd11fecccc111feecc1111feec11111fee111111fe
-- 027:ddddddccdddddddfddddddf1ddddcf11ccccf111cccf1111eef11111ef111111
-- 029:111b6656111c566611b6666611b6657711c67666111b76561111d77711111cbb
-- 030:6666c1116566c11166666c1177766c1166676c116665c111777c1111bcb11111
-- 032:000000000000000c000000dd00000ded00000decddd00de0f4eccdc04ff4cddd
-- 033:00000000c0000000dd000000ced00000ded000000ed000000cdc0000ddddc000
-- 048:f4ecec0dddcdec0d00dec00d0cdec00d0dec0fefcdec00fedec0000fdec00000
-- 049:e0cedc00e0cedc00e00ced00e00cedc0cf00ced0f000cedc00000ced00000ced
-- </SPRITES1>

-- <WAVES>
-- 000:eeeeeeedcb9687777777778888888888
-- 001:0123456789abcdeffedcba9876543210
-- 002:06655554443333344556789989abcdef
-- 004:777662679abccd611443377883654230
-- 005:eeedddccbbaaaaaaabbbbcccb9210000
-- 007:55556777777776655555666778877776
-- 008:f00070c00600b00550dd000009a0cc00
-- 009:44444456789aabb97a654dc831347213
-- 012:67777777777777778888888888888999
-- </WAVES>

-- <SFX>
-- 000:00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000030b000000000
-- 001:8000800080009000a000c000e000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000220000000000
-- 002:090009000900090009000900090009000900090009000900090009000900090009000900090009000900090009000900090009000900090009000900a00000000000
-- 003:050005100520153025504560659085b095f0a5f0b5f0c5f0d5f0e5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0414000000000
-- 004:00ec00c170a4f076f037f00ff00df00af008f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000a0b000000000
-- 005:34073407340734073407f400f400f400f400040704070407040704070407040704070407040704070407040704070407040704070407040704070407200000000000
-- 006:09000900090009000900090009000900090009000900090009000900090009000900090009000900090009000900090009000900090009000900090030b000000000
-- 007:05f005b0159025604550653075209510a500b500c500d500e500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500404000000000
-- 008:00e800c970aaf07cf03ef00ff00ff000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000a0b000000000
-- 009:46e09680f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600202000000000
-- 010:080008000800080008000800080008000800080008000800080008000800080008000800080008000800080008000800080008000800080008000800304000000000
-- </SFX>

-- <PATTERNS>
-- 000:800024000020100000000000800024000000100000000000800024000000100000000000800024000000100000000000900024000000100000000000900024000000100000000000900024000000100000000000900024000000100000000000400024000000100000000000400024000000100000000000400024000000100000000000400024000000100000000000400024000000100000000000400024000000100000000000400024000000100000000000400024000000100000000000
-- 001:500026000000800028000020c00028000000500026000020800028000020c00028000000800028000000500026000000700026000000800028000000c00028000000700026000000800028000000c00028000000800028000000700028000000800026000000c00028000000d00028000000800026000000c00028000000d00028000000c00028000000800028000000700026000000800028000000a00028000000800028000000c00028000000a00028000000800028000000700028000000
-- 002:500024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 003:50002a80002aa0002ac0002a50002a80002aa0002ac0002a83a62a00000000000000000000062000000000000000000050002a80002aa0002ac0002a50002a80002aa0002ac0002aa7d62a00000000000000000000062000000000000000000050002a80002aa0002ac0002ad0002ac0002aa0002a80002ac0002aa0002a80002aa0002ac0002ad0002ac0002a80002aa0002a80002aa0002a80002aa0002ac0002aa0002a80002ac0002aa0002a80002a70002aa0002a80002a70002af00028
-- </PATTERNS>

-- <TRACKS>
-- 000:2000002c0000480300000000000000000000000000000000000000000000000000000000000000000000000000000000000020
-- </TRACKS>

-- <FLAGS>
-- 000:00000000000000001000000000000000000000000000000010000000000000000000000000000000101000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </FLAGS>

-- <SCREEN>
-- 004:00000000000000000000000000000000000000000000000f0000000000f00f00f00f00f00f00f00f00000f00f000f0f0000000000f0f0ff0fee0ef8eff00f0f0f0ee0ff0f00fe000f000000000f000000000000000000f00f00f00f00f00f000000000000000000000000000000000000000000000000000
-- 005:0000000000000000000000000000000000000000000000000f0000000000000000000000000000f00e0000000f00e00f0f0f00000e00fef0eeeefeeee20fe0fefeefeeef00fef0ffef0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 006:00000000000000000000000000000000000000000000000000000000000f00f0f0f00f0ff0f0f00000000000000fe0ee00e000000f00000feeeeeeeeee0fee000000000eeee00feef00000000000000000000000000000f0f00f0f0ff0f0f000000000000000000000000000000000000000000000000000
-- 007:000000000000000000000000000000000000000000000000f0f0000000000000000fe00e00000000f000000000feeeee00ee800f0fe0feeeefeeeeeeefeeeef0000000000eefe0ee00ee0000000000000f000000000f00000feefeeeeeef000f000000000000000000000000000000000000000000000000
-- 008:000000000000000000000000000000000000000000000000000f000000000f0f000fef000ff0f0fef0000000000efeef00fe000000000eeeeeeeeeeee0ee0e0ef0f0f0000eeef0ee0ff0f000000000000000000000000f00feeeeeeeeeeeff000f000000000000000000000000f00f000000000000000000
-- 009:0000000000000000000000f0000000000000000000000000000000000000f000f00ee00f0eeeeeef8000000000eeef00efe00000000f0eeeeeeeeeeeeeffeefef0000000d000ef0fee00000000000000000000000f000000eeeeeeeeeeeeeefe000f00000000000f000000000000000f0f00000000000000
-- 010:0000000000000000000000000000000000000000000000000000008f00000000eefef000feeeeeeeef00000000f000ef0fe8000f00f00eeeeeeeeeeeeeeeeeeeeef000fee000ff00dd0000000000000f000000000000f0f0eeeeeeeeeeeeeeeef00000f0f0000000000000f00f0f0f000000000000000000
-- 011:0000000000000000f0000000000000f0000000000000000feef000f000000000feee00f0eeeeeeeee0000000f0eeffef000000f0000000eeeeedeeeeee0eefeeef00000f000fe000ff0fef000000000000f0000f000f0000feeeeeeeeeeeeeeee0f0f0000000000000000000f000000f00f0000000000000
-- 012:000000000000000f00000f000000f00000f0000000000f00fe0000000000000eeeeef0000eeeeeeeef000000008fee000000000000000feeeeddeee0ffeee0eee0008008280000edeeefff000000000000000000000000000eeeeeeeeeeeeeeeee0000f00f00000e0000f0f000000f000000f00000000000
-- 013:00000000000000000f00000f0f0000f0f000f000000f000000000ef00000ee00eeee00000feeeeeee00f00000f000e0fe0000000000000eeeeeeeee000f0ffee00000003353e0e00feeeeee00fe00000000f00f00f0000f000eeeeeeeeeeeeeeef000000000f0f00f0000000f00f000f0f00000000000000
-- 014:0000000000000000000f0f000000f00000000000000000f0feee0ff00f0f0ee00eeeef0000eedfeef000000000000e00000f000ef000f00eeefef00000000eee0000000224330f0000000e0ee00000000000000f00000000eeeeeeeeeeeeeeeee000f00f0f00000f0000f0f00f000000000f000000000000
-- 015:000000000000000f00f0000f0f0000f00f0f000000f0f0000feeeee0000000fe0feeee000ee7edeeee0000000f000000fefef000000000000eefe00e0000fefe000022082224f000ef000000f000f00ef00f0000f0000000efeeeeeeeeeddeeeee0000f0000f0000f000f000000f0f00f000000000000000
-- 016:000000000000000000000f000000f00000000f00f00f00f0000000eef000eeeeeeffeeeeefddddfeee000000f00f0e0000000f000f000f00ef0f0ef0eee00eef002434422232e00ee8e00eee00edf00fdf0000f00000000000eeeeeeeeeddeeeeef0f00000000f00000000f00f000000000f000000000000
-- 017:000000000000000f00f0000f00f000e0f00f000000000f000feeeeeef0eeeeeeee0e0feeeddddddeef0000000000e00f00ef0000000f000f0fefeeeee0e0eefe002243222280fef0de000eeee0fdddefe00f000000000000f0e0eeeeeee7eeeeee0000f0f00f000000f00000000f00f00f00000000000000
-- 018:0000000000000000f000f00000000000e000000f0f0000000feeeeeeeeee0eee0eef00e0ed5fddddee000000f0f0000000ef00000000000000ee000000eeee0ee8234422220ddf000e00eeeeee0f5e0000000000f0000000000e0eeeeeeeeeeeeef0000000000f000f000f0f0f00000f0000f00000000000
-- 019:00000000000000f0000000f0f0f0f00000f00f000000f00f0000feeeee00f000efe000efefdfcddeee00000000000f00f0000f0000000f0000fef0ee00eeeef0002243222200fd00ef00eeeeeeeeed0f00f00000000000000f00eeeeeeeeeeeeeee0f00ffee0000f0000f000000f00000f00000000000000
-- 020:000000000000000000f0f000000000f0f000000f000f00000feef0efeeee0ee00e0000feeeeedeeeef0000000000000f0000f00000000fe0ffefeefeeee00000082243223800ed0f0eedeeecfeeeee8eeee00f0000000000f00000eeeeeeeeeeeeee00feeeef0f0000f000000f000f0f0000000000000000
-- 021:0000000000000000f00000f00f000000000f00000f0eff8eeeeeeeeee0eee0e00000000eeee7d5eeef00000000f00fe0f000e8ff00f0000f0efee0eeee0f0000022342222000feee2dddddddeeeeeeeeeeef000f0000000f000f00eeeeeeddeeeee0feefeee0000f0000f0f0000000000f00000000000000
-- 022:00000000000000000000f0000000f0f000000f0f000eeeeeeeeeeeeeeeeeee000000000feeeedde0f0000000ee0ff8ff0f00000e0e00000fef00ff0f0000000000233422800f0eeddddddddddeeeeeeeee000000f000f00ef0000f0eeeeeddeeeeeeeeeeeeef000000f0000000f0f0f000f0000000000000
-- 023:0000000000000000f00000000f0000000000f00000feeeeeeeeffeeeeeeee0000000000eeeeeee7000000000eeeeeeeee0000fefffff0f00000ef00ef0000f000024d2320e0eeddddddddddddedddeeeeee0f0000000000f000000feeeeeddeeeeeeeeeeeeeff0f00000f00f00000000f000f00000000000
-- 024:0000000000000000f0f0f0000000f0000000000000eeeeeeeeeeeeeeeeeeefe000000008eed7ede00f000000feffe000000f008efe0e00000000ef0000000000f00334400eeeeeddddddddddeedfeeeeeeef000f00f00000000ff00effeeeddeeeeeeeeeeeeedf00f0f00000f00f00f00000000000000000
-- 025:000000000000000000000000f0f000000000000fffeeeeeeeeeeeeeeeeeeee000000f0f0eecdedeff000000000ee0f00f0000000000020ff00f80000f0000000f000d3deeededdddddddddddddddeeeeede00f000f00f0fef00ee00f0eeeeedeeeeeeeeeeeeeee000000f00000f00000f00f000000000000
-- 026:00000000000000000f00f0000000000000000000ee0f80ee0eeeeeeeeeeeee00000000efdeeceeeee000000f00ee0e0f0000f000000000eef0ff00f000f000000f003d28eeddddddddddde2fddddeeee0eff0000000feeee000e0e0eeeeeeeeeeeeeeeeeeeeeeefefef00000f0000f000f00000000000000
-- 027:0000000000000f000e0000000000000000000008ef0000eeeeedeeeeeeeeeee00ff0000eeeeeeeddf000000ee0ee0fef00000000000000eee00000000000000f00e02d02dddddddddddedddddedeeeef00ef00fe00000fee0eee0f0edeeeeedeeeeeeeeeeeeeeeeef0efe0f0000f0000000f0f0000000000
-- 028:00000000000000000f00000ff0f0f0f000f00f002000000eeeeeddeeeeeeede0000000feefeeeeddef00000feeee00f0000f0000eef000feef000f0000000000fef02200eddddddddeddd2eeedddeefeeee0000f00f0008f000f0e00eeeeeededeeeedeeeeeeeeee000eeee00f0000000f00000000000000
-- 029:00000000000000000000000000000000000000000000000feeeeeeeeeeeedee000000000f0eeee5eef00000eeeeeee00f0000000e0000000fe00000000000000020000000dddddddddddddddeddeedeeef0ef0000f000f00000e0f00fffedddddeeeeeeeeeeeeeee000eeee00000000f000f00f000000000
-- 030:0000000000000000000000000000000000000f00e0f00000eeeeefeeeeeeeef0000f00fe0000eeee00000000f0ee0f000f000000ffd00000000000000000f00f000000000dddeddddddddddddeedeeeeef0f000fe00000fef0000000000feeddddd00deeeeeeeeee0e0feef0f00e00000000000000000000
-- 031:00000000000000000000000000f00f0f000f000ff000000eeeeeeeefef000ce0000000000ee0eeee00000f000e00fe000000f0000dd00000000f0000000000ff000000000ceddddddddddddddeeeffeee0000000eefeefefeef0e00000eeede0dde00feee7eeeeef00000ee0fe0f00e00f0e000000000000
-- 032:0000000000000000000000000000000000000000000000eeeeeeeef0000000e00000000ef0eeeeee0000000000f0000000ef000000f0000008000000000000fee0000000edddddddddddddddeeedeeeede00eeeeee0e0000eeeef0edefddfee0ddee00e7eddddee00e0f0e0e0f00000000e0000000000000
-- 033:000000000000000f000000000000f00f0e00f0ef000000eeeeeeeee00ef000e00e00000ef0eeeee00000000f0000f0efe0fe0000000000002200000000000eeeee0000000cdddddddddddddddecdeeeeeeeeeeeee08fe0000e0000ee00002ce0dd00ceddeddfeeef0f00feefefef000000fd0f0000000000
-- 034:00000000000000f00000000000000f000e00000fe00000eeeeeefef0000e0000eee00fef0efcee00e000000ef0f0000e0eee00000f00f0003000000000f0eeee0000000d00dd5eddddddddddddfeeeeeee00f0eeeefefeee0000ff0000000ee0ddf0ee0ddfddeeef000000eeee0000000000000000000000
-- 035:00000000000000000000000000000000000f000eef0f00e0eeef00000000f00feeee00e0000eeee000f0f0000000eeeeeeeee0000000000020ff0000f0eeee0008000000e0dddd2eddddeddddddeddeefef000000ee0000ef000000000000f00ee000000ddeddef00f000000000000000000000000000000
-- 036:000000000000000000000000ef0ef0f0f0000f00e00e0000eeeee00f0f000000eeef0eeff0ee000f000000000f0feeeeeeeef0000f00000230ee0ff00fe00fe0ef00000000d5eddd2dddddddddddeeeeeee0e000000000000000000000000000000000000e00ff0000000000000000000000000f00000000
-- 037:000000000000000000000000000eef000000feeeee0ee0f0eeeef000000ee0000eee0fef0e000000f00000f000eeeeee00fef000000f000022eeddde0e0deee2e000000000ddddedde5ddddddddddddeeeeeef000f00000000000000000000f0f000000000000000f0000000000000000000000000000000
-- 038:00000000000000000f000000f0fe0e0f00f000feeee0ef00eeeee000f002e00f0fe00eeeee000000000000000f0eeeeef00e00000fe0ee2000edefeedecddedddfe00000e000ddd2dddddddddddddddddeeeee0f000000000000000000000e00e0f0f00f000fe00000f00000000000000000000000000000
-- 039:0000000000000000000000f00000000f0e00fee000fe0e0f00f0000ef00de00e00f00ee0eee00000000000000ef0eeeeefeef0000e00000000eeeedddddddddeee00000fd000edddddddddddddddddddddddeee000000000000000000000000feeeee000000000000e000000000000000000000000000000
-- 040:0000000000000000000fffff0f000eeeef0feeeef00f0ee0ffe00f00000d000f00000000eee0000000000000feeeeeeeeeeef000000ef00022ededddddddde000000000000eddddd5ddddddddddddddddddddeef00000000000000000000fe0eef00f0000000000000000000000000000000000000000000
-- 041:0000000000000000f00eeee008e0feeeef00fef0ff000eefeef0000f000e0000000f0000eee0e000f000000feeeeeeeeeeeef0000e0ee00020ddddddddddd0000000000e000dddddddddde2ddddddddddddddeee0f000000000000000000f00ee00000000000000000000000000000000000000000000000
-- 042:00000000000000000000f000000ee0efeef00f0000000feeee00f0000000000000fef0000feef0f0ef00000eeeeeeeeeeefef0000eeee0002eeddddd8fddd00e00080e0000edddedddddeddddddddddddddddef000000000000000000000ef0fe000ff000f00000000000000000000000000000f00000000
-- 043:000000000000000000efef00f00f0000f000000f00ff0eeeee0ff0fffef0f00000eeff0f00eef0e0000f00feeeeeeeeedefee00000eee000ef2dddd000ddd0ed00000f0800ddddeedddefdddddddddddddddde000f000000000000000000ff0fdf00dd00ff00f00000000000000000000000000000000000
-- 044:0000000000000000feeeeef00000000000f0000000ef0ef808feeefeee0e000000e00ee000fee0f0ff00000feeeeeeedd2eef00000eee0800fddddd000ddd0ee0000000000deddeedde00eddddddddddddddee0f0000000000f00f000000000fd00fdd0000000000000f0000000000000000000000000000
-- 045:00000000000000000feeeeff0000000000ee000000f00000000eefef000e00e00000000000eee0000000feefeeeeeeee000de00000ff000000fedde000eed0ee000000000fddddefdd000eddedddddddddddee0000000000f000000efef0000fe0efde000f0f0f0f0f000000000000000000000000000000
-- 046:0000000000000000e0f0ffe000fee000e0e00f000000e000000f000000ee0eef0000f0efef00000000efeeeeeeeeeee00000f00000000000000fdd0000edd0fd000000000eedddfedd000edeedddddddddddde00f00000f0000f00ffee00000000e0ff0f0000000000000000000000000000000000000000
-- 047:0000000000000000e000eeeef0eeeeee0e0000000f002000000eef00fefe0eeee0ffefe0ef00e00efeedeeeeeeeeeee08000000000000000000ede000f0e00ee00000000f0edde02dd0000ededddddddddddeee000f0000000000000f000ff0000f00000f000f000f00f0000000000000000000000000000
-- 048:00000000000000e0e0feeeee000eeeeeee00f00f000e0f000000e0feeeeeefe0000ef00f00eee0eefe2ddeeeeee00f0000000000000000000000ee00000000fd0000000000e0edef0f00f00e0de2dddddddddee0f000f00f00000000fe00eeef0000f000000000fe0000000f00f000000000000000000000
-- 049:00000000000f0f0f0eeeeeddf0eeeeeeee00000ef0000f00000eeeeeeedee0e00fe0eef0fdee000eeedddd00000000000f0000000000000000000e00000000de0000000000eeede0000e000f0cdde5dddddddeee000000000f0000f00f000fede0000000000f0000e00eee00feff00000000000000000000
-- 050:00000000000000000eeeeeedeffeedeeee00f00ee000000000edeeeeeeecf0000fefe0edee00eeeeeddddeef00ee00f000000000e000000000000000ee00000f00000f0000eedd0000000f0000eddddddddddeee000f0f0f00000000000feddddce000f0000000ef000eee00000000000000000000000000
-- 051:000000000000f0ede0eeeeeee0eeeeee0ee0000fe000000000eeeee0ef0e0000f00fee0fe00ecdeeddddddeeeeeee00fe0f00000000000000000dd00ee0000000000000000eeeeeee000000f000d6ddddddddeee0f0000000f00ce000feeeeefdee0f0000000f0000f0e0e0f00f000000000000000000000
-- 052:000000000000efeeeeee0feeee0eede0fee000000ef00000000eeeeee8df00000000eee0ef000cdeedddddeeedeec0ee000000000000f0000000ddf0eee0f0000000f00000eeeeeeeeeeef0000fedddddddddee00000f0000000ddeeeeeeeeeeeeeeee00fe0000fef0000e00000000f00000000000000000
-- 053:00000000000000000e00fefeeefeefeee00f00000000000f00f00feee0de00000efeeeefee0f0cdeddddddeeedeefeeefe0f00000000000000000e00eee00000000000f000eeeeeeeeeeee00000fdddddddddeef00f000f00f0eeeeeeef0feee8ee0e00000f00000ef000e00f0f0f000f000000000000000
-- 054:00000000000000000000feeeee0eeeee000000000ef0000000000edde00e00000feeeeeeeeeeeddeddddddeeedce0feeff0000000f000000000000f0000f000000000f0000e0eeeeeef0000f0f08eedddddddeee00000000000007eeee00000000eee000f000f0f0eeef0000000000000000000000000000
-- 055:00000000000000f0fee000eeeeeeeef0f00000000000000000f0eefef00000000feeeeeeef0eeddeddddddeeeddf0eee000000000000000000000e0000ee00000000f000000000000ef0000000000000ddddeeeef00f0f00f000000000f0f0f000eeee00effeeeeeefee00f00f000f0f0000000000000000
-- 056:000000000000f0eeeeef00feeeeeeee800e0000000000000008eeee00000000080eeeeeefee0fdfeededddeeeddef0ef00000000000000000000080000ee000000000000000000f000ef000000f00000edddeeeee0f00000000f000f000000000f00ee0eeeeeeeeeeeef00000000f0000000000000000000
-- 057:00000000000000eef0ff00feeeeeee000000000000000000ffeeeeef000000feef0eeed2eee0fdefde0eddeeeddee0ee000000000000f000000000f000ee00000000f00000000000f000ff00ff0000000eddeeeeeeeff0f00f000f000f000f00f00000feeeeeeeeeeeeef000ff0fef00f000000000000000
-- 058:00000000000f00e00000f0eeeeeeeee000000000000000f00efeeeeef00000edee0eedeeeff00deeeeedddeeeceee0ef00000000000000000000000000ee0f008f00000000000000000feeeeeeff0000008eedeeeeeeeeeefe0f0000000000000000f00eeeeeeedeeeeeefffeeeeef000f00000000000000
-- 059:00000000000000e0efede0eeeeeeeee0e0000000000000f0feeeeef00000f00eeeefd2ee0e000efefdfdddeeeeeef0ee00000000000000000000000000fe0000000000000000000000eeefefe0ef8ff00000fddeeeeeeeef00000f0f000f00f00f00000feeeeddddeeeeeeeeeeefe0000000000000000000
-- 060:00000000000000e0eeed2eeeeeeeeeefe0000000000000000efee000e0000e0f00f00eee0ffefeff0efeddeeeeff00ee0000000000000000000000000000e000000000000000000000efe00f00000000000f00dfffefef00000000000f00f00000000f00eeeedeedeeeee00fee00000f00f0f00000000000
-- 061:00000000000000e0e008feeeeedeeeeeeef000000000000fe0eeffeeff000f00f80000eee00feee0eeeeedeeed0e000f000000000000000000000f00eeffe0000000f000000000000feeeefee00000f0800000000000000000000000000000f00000000feeeeeddeeeeeefeeeef00ff00000000000000000
-- 062:0000000000000000f0000feeeedddeee0ff00000000000008fdf0fee000f0000ddf0000fef00eee0fee80f0e0dde0000000000000000000000000000eee0f00000000000000000000eeeeeeef00feeeedf00e0000f000000000000000000f0000f0000000feeeeeefe0f22eeeeefe00000f00f0000000000
-- 063:00000000000000000e0feede7ddddeee000000000000000f0ed00ee000000f00ff0000000f00efefeff0fef00dee0000000000000000000000000000eee0000000000000000000000eeeeeeeee00eef0ef00f0000000000000000000000000f0000000000feeeeee0f32223feeeee0ef0000f00000000000
-- 064:00000000000000022222222222200dee000020020082280002e00ff00222222222222222220e00eeeeef0222222222222222200f0f02022200222222222280000000008222222222222222edef00f0020820882288000000000002222220f0000000000000feefef03222222eee000f00e00000f00000000
-- 065:000000000000002232222222223200eed0022222222222222220000822222222222222223220e000fe2222222222222222233220002222222222222222222200000228222223222222222280e00000222222222222222000000282222220000000000002000000f0222222208ef0f0000e000f0000000000
-- 066:000000000000002333322222222200ede00222222222222222800ef02222222222222222332280f0000333322222222222223230f023332222222222222222000000222222222222222222200000022222222222222228000022222222220000000000222200f022222222222000000000e0000000000000
-- 067:000000000000023333333222223200000002222222222222222000002222222222222223333220f0000233333222222222222230002333322222222222222200000222222222222222222222000f0022222222222222200000222222222000000000000222222222222222222220002220e0f00000000000
-- 068:00000000000002333332222222220000f0202222222222222220f00222233433334222222234200000223333333222223222223200233333343433343322220000022222224333422222222220000202222222222222200000224222233000000000f000022222222222222222222222020000f000000000
-- 069:0000000000000233333300000000000f000222222208028088000002222222222222222222232000f0223333333222222222223200022822222222222222220000022222222222222222222220000222222228002808000000222222222000000e000000222222000000002222222208000f000000000000
-- 070:000000000000022333332000000000000002222220000000000000f000000000000002222223200f00223333333200000022222200000000000000000000000000000000000000000222222220000022222200000000000000000000000000000e0e0e022222220000000004422222200000000000000000
-- 071:0000000000000233333200000000000000024222300000000000f0000000000000000022222420fee0223333333000000002223200000000000000000000000000000000000000000022222220000223222300000000000000000000000000000000003222220000000000002242222200f00f0000000000
-- 072:000000000000023333332000000000000002332240000000000000000000000000000023223320eeee223333333200000002333200000000000000000000000000000000000000000222322220000023323300000000000000000000000000000f2222322220000000000000004222222f00000000000000
-- 073:00000000000002333333200000000000002233333000000000000f0000000f00000f0233333320feee223333333200000002333200000000000000020000000000ee0000000000000222233220ff02233333000000000000000000000000000000222232222000000000e000002223222200000000000000
-- 074:000000000000023333322000000000000003333330000f0000000f022222232222222223333320e00e2433333333222222223332000000323233333400000000000222222220000002333332200e023333340000f00000000000000000000000222222322220000000f00000003422422222200000000000
-- 075:00000000000002333333000000000000002333333f00000f0000fe003433333333333333333320e000244333333333333333333000000033333333330000000000034333322200000233333220f0023333330f0000f000000033333333320000000000322222000000000000803323322222200000000000
-- 076:000000000000023333332000000000000023333330000000e0000f082333333322222333333320000e244333333333333333330000f000233333332400000f000003333332200000002233322000023333340ef0f00000000033333333220000000000322232200000000008022233220000000000000000
-- 077:00000000000002333332222222220000002233333f00000000000f80233333320000023333332000fe234333333022222222220000f00023333333330000000f000442333222020e0222334220ff022333330ee0000f000002233322333200000000002322222202f0000000222332200000000000000000
-- 078:0000000000000233333334333332200000023333300000000000000033333330000002333333200000233333333000000000000000000023333333332000000008233333322222222222332220f0002333340eeef0000f000223232222420000000000044222222220002202223322000000000000000000
-- 079:0000000000000233333333333332200f0022333330000000e0000000233233300000023333332000000233333330000000000000000000233333333300000eeff004433333322232322332222000022333330eeeef0000ff0223222222220000000000224332222222222222334220000000000000000000
-- 080:00000000000000023333333333322000000222323f000000fe000000223333380000023333332000002233333330000000000000000000e3333333330e0feeeeef03333333333333333322220000002223230eeeeef0f0eef222222222320000000f00322442222223332233333008000000000000000000
-- 081:000000000000000022222222222000e000002222300000000f0000f00233333000000033322200000002222222000000000000000000f022222333340eeeeeeeee0f3333333222333332222000e0000222230e0feeee0feee022222222000000000000222000022222222222200002220f00000000000000
-- 082:000000000000000000000000000000c000000220200000000e00000002222220eef0002222000000000000000000000000000000f0000000002222220eeeeeeee220022222222222222200000000000022020e00eee0feeee000222222800000000000000000000222222000000022200000000000000000
-- 083:000000000f0f0000000000000000000000000000000000000e00000000000000ee0ff000000000000000000000000e0000000000000f0000000000000eeeeeeeef00000000000000000000000043000000000c00eeeeeeeeee00000000000000000000000000000002220000000000000000000000000000
-- 084:000000000000000000000000000000f000000000000000000000000000000000eeede000000000f0fe0000000000000000000eef0000f000000000000eeeeeeeef00000000000000000000000035000000000e00dedeeeeee00000000000000000000000000ef00082220000000000000000000000000000
-- 085:0000000000f0000000000000000000f0f00000000000000000000f0000000000eeede000000000000000000000000000f0efeeeeeeee0000000000000eeeeeeeef00000000000000000000000002000000000000eeeeeeeee000000000000000000f0efe2eeedcf002220000000000000000000000000000
-- 086:0000000000000000000000000000000000000000000000000000eee000000000eeede0000000000000000000000000000fe000eeee0e0000000000000eeeeeeee0000000000000000000000000000000000000000eeeeeeee000000000000800000e000eeeeedd0000000000ee00000000f0000000000000
-- 087:0000000000000000000000000000000000000000000000000f0feee800000000eeeef000000000f0000000000000000e00eef0feee000000000000000eeeeeeeef000000000000000000000000280000000000000e0f0feee0000000000000000000eeeeeeeeedf000000000000e0ef00000000000000000
-- 088:000000000f0000000000000000000f000fe0000000000000000000ef000000000fe0ee00000000e0f0000000000ee00e00ef000e0ee0000000000000eedeeeedeeef000000000000000000000220000000000000000000feeee0000000000f000000000feeeeeee0000000e00f000fe00000000000000000
-- 089:00000000000000f000000ff00000000f00000000000000000000feee0000000e000fede0000000f000ef00f000eee00ff0ff00f00fe000000000000eeeeeeeeeeeee000000000000000f0000322220000000000000000000fee00000000000000000000feeeeeeee00000eeee0f0f0000000000000000000
-- 090:000000000000000000000000000f000000000000000000000f00eeeeeeeeee00fdeeeeeee0000000ffe2eddddefeee00ef000000ffe8ff000f00eeeeeeeeeeeedddedeeeeeeeeeeeeeedf0d0322200000000000f00000000eee00f000000f000000000feeeeeeeeeeeeeeeeeeee000000000000000000000
-- 091:0000000000000000000000000000f0000ff000000000e0000ef00feef0f0fe00edde7dde0000000ededddddddddee0e000000000ee0eeef00000eeeeeeeeeeedddddddeeeeeeeeeeeeff000032208000000000f000000000fee00f0000000000f0000000feeeeeeeeeeeeeeeeeeef000f000000000000000
-- 092:00000000000000000e00000000f0000000e000000000e0f000f000000f0e00f0eeeeedde0f0f0feddeddddddedcfe0f000000f0f000eeee000f0feeeeeeeeeedddd2edeeeeeeeeeeee00000e0220000000000000000000000ef0000000000000000000000fefeeeeeeeeeeeeeeefe0f00000000000000000
-- 093:00000000000000000e0000000000f00f00ef000e00000ef00000000feefe00ff0eeedddeeefeddddddddddddeddee00ef0f00f0000f0eef0f0000eeeeeeeeeede8f0edeeeeeeeeeeef0000f0f00e000000000f00f000000000000f0f00000000000000000000ffeefeeeeeeeeeeef0000000000000000000
-- 094:0000000000000000000ef0000ff00000000800080800000000000f0fee00feeeffeddddeeddedddddddddddeedeee0eef000000000000f0000f00eeeeeeeeeeef0e0ee0fffffff0fe00008eef0000000000000000000f000f0000e000000000000000000000000f00efeeffeeff00f000000000000000000
-- 095:00000000000000000e0e00eeeef00f00000ee00000000000000000eee0ee0eeee0feddddddddddddddddddeeddeeeffe000000000000fef000000feeee0eeeeef0ee0eee000000008000e80f0f000000000000e0f0000000f0000d0000000000000000000f000000000fe000f00000000000000000000000
-- 096:000000000000f00e0f0f0eeeeeee000000e0f00000000000f0f0000feeee0e0eef00edddddddddddddddddee2efefefe0f000002ef00eeef000f00eeefe0fe0e000ee0eee000e0ee000000000fef000000feefe0ffef00000000000000000000000f000000000000000000000000f0000000000000000000
-- 097:000000000000000f0000eeeefeef0f0000e0000000000000e0f000000f0feeeeeef00eddddddddddddddddddeeeeee0f00000e0ed0feeeeeef000eeeeee000000000f8f0eeef000fee000e000000000000feeee000f0000000000e0000f000000000000000000000000000000f0000000000000000000000
-- 098:00000000000000e00f0feee00000e0000e00f0000000f00e0000f0f000eeee0eeeeeefeddde5ddddddddddddeeeeeef000f0080fc00feeeeeef00ef0ff0000000000e0000fef0feeeee0fdee0f00000ef00e0df0000f000000000e00f000000000000000000000000000000f000f00000000000000000000
-- 099:00000000000000e0000000000000e0f00e000000000000000000000000eeeeeeeed8effdddddedddddddeeedeeeeeefee0000000df00edeeee000000000f0fe0fe00000000feeeeeeeeeed7de0000fdf00000000000ef00000000e0000000f00f0e00000000000000000000000000f000000000000000000
-- 100:0000000000000f00000000000000000000ff0000000000000f000f0ee0eeeeeedeeeeeedd2e5dddddddddeddeeeee00f00000000eceeeeef000f00e0000080000e00000f000feeeeeedddddcf0000000000000000000000000f0fd0f0000f00000e000000f00000000f0000fe0f0f0000000000000000000
-- 101:000000000000000f0f000000000f0f0000000000000000f0008e000f000e0eeeeeeeeeddddddddddddddeeeeeeeee000000f000e00eeeeeddef0000ee0e0e0f000efef0000feeeeeeeddddceeee000000f00000000000000000f0000000000f0e00e000000000000000d0000000000000000000000000000
-- 102:0000000000000000000000000000000f000000000000e00000fe0000000000eddffddefddddedd2ddd2edeeeeee0e00000eddeeed00eeeeeee00f00eeee0fe00e0eee0f0f00eeeeeeedee0000000000f000000f00deeefee00000e00000f000eee00e000000000000000000f0f0000000000000000000000
-- 103:0000000000000000000000000000f0f0000000000000ec00000f0000f000eeefeeeeeeeddd2ddeddddddeeeeeeeeeee0feddeeecfcceedde0ef00000000ee000f0000e0f000feeee0000000000000000000ed0e00eeeeeee00f0f000000000f0eef0de000000000000000000000f00000f00000000000000
-- 104:0000000000000000000000000000000000000000000000000000000000f0eee00eeeeeddddddd5ddddddeeeeeeeeeeeeeddddcddeddee7ee00000e000ee000fef0000f000f0000000000f0f0000000feddcdd0e00feeef0000000000000f0eeee000ee0000000000000f000000f000000000000000000000
-- 105:00000000000000000000000000000000000000000000000000000000000efeeeeeeeeeddde5ddddddddeeeeeeeeeeeeeddddddddddddeee8000ef08000000feeeeeeee0000000000000000000000fdddddddd0e00f0eeee000f00000000feeeeee0000000000000000fee000000000000000000000000000
-- 106:000000000000000000000000000000000000000000000000000000f00f00eeeeeeeeddddddddddddddddeeeeeeddddddddddddddddddeeef0000ff00000000eeeeeeee0f0000000000000f00000000eddeede0ee000eeeef00000f000000eeeeeee000000000000000000000000000000000000000000000
-- 107:000000000000000000000f0000f00000000000000000000000000000f0fe0feeeeeeedddddddddddddddeedd5eedddddddddddddddd0ef00000f00fe0000feeeeeeeee0000000000f0fedef00000000edeeefdeeef0eeee000f00000000eeeeeeee00000000000000f000000000000000000000000000000
-- 108:00000000000000000000ff000f000000000000000000000000000000e0e80e00feefeedddddddddddddddefdddeddddddeddddeefeeefe000000000000000eeeeeeeee000000fefeddeed0e00000000edeed0deee0eeee00000f00f0f0ffefeeefe000000000000f000f0000000000000f00000000000000
-- 109:00000000000000f0000fe0e0000000000000000000000000000000000000000ffeeedededdeddddddddddddddeeefdddeeeedeeefef0000000000000f000feeffeeeee000f00fdeeeeeed0e000e0000eeeed0deee0eeef0f00f000e00000000feee00000000000000f0000f0000000000000000000000000
-- 110:0000000000000000000f000000000000000000000000000000000f0f0f00f000f00feedd2ddddddddddddddddffeeedeeeee000fe0000f00000000000000eef0feeeee0000000feeeeeee0f000f000fedeee0deee0eeeefef00000000f00f000ff200000000000ff0ee00000000000000000000000000000
-- 111:0000000000000000000e0f0000000000000000000000000000000000000f0feee000ee2eddddddddddddddeeef0ecfee00000000e08ff000f0000000000ff00000ffee00f0f0000feeeee0000e00000ddeee0eeeffeefeee00f000f00000000fe0e000000000008000e00000000000000000000000000000
-- 112:0000000000000000000f0e0000000000000000000000000000000000000f00ff000ffeeeeedddddddddedddeeeededeef00000000fe0f00000000000000000fe000e00f000000000feeeee000000000edddffeeef00f0eee0000000000f0f0ff0fd00000000000000000f000000000000000000000000000
-- 113:0000000000000000000000000000000000000000000000000000000000000eef000f00eeeeeedddddddddddeddddeee0000000000f00000000000000000000000000f00000000f0000eeee0000000000eee0eeee0ee00fee00f00f0fef0000000ef00000000ff0000f0000f000000000000f000000000000
-- 114:0000000000000000000000000000000000000000000000000000000ff0000fff000ff0f0eeeeeddddddddddeeeee0ee0000000000000f0000eee0e00000f000f0000f0e000000e8f00eeee000000000000000eee0ef000eef000e000ff0000000e00000000f0f0000000f000f00f000f0000000000000000
-- 115:00000000000000000000000000000000000000000000000f00008f0f000e0000e000ef00eededdddddddddeeeeedddd2000000000f0000000f000ee000f00fe000f000fe0f0000f00f0eee0000000000000000ee0e0000fe00e0e00000feff000ef0000000000000f0f000f000000f000f0f000000000000
-- 116:00000000000000000000fe00000000000000000000000f000000f00000f0eee0f0000f00eeddeddddddddedeeeeddddde000000000000f0000ef00e0000000f000000e0e0000000000feef00000000000000000e0000000e8000ee000000f0000e000f0000000000000000000f0f0000000000f000000000
-- 117:0000000000000000000000000000000000000000000f0000fe0000ef0000f00e00000000eeecdddddddddddddeeedddd0e0000000f0f0000000000ee00f00000f00f0e0ee0f00f000efee000000000000000000000f0000f0000e00f000feef00ef00000000f0000f00f0f0000000f0f00f0000000000000
-- 118:000000000000000000000000000000000f00000000000f0d0000000000000e00f0000000ee0eddddddddddeddefeeeee00e000000000000000f000f00000f0f000000000e000fe000eeeef0000000000eee000f0f000000000f0e00000eeee00ee000000000000000f000000f00f00000000000000000000
-- 119:000000000000000000000000000000000000000f00f00000000f000e00e0000000000000fe00eeeeeeeeeeedeeddfeee000ee00000f00f0000000000000000000f0000e0ee0feee00000d000000000000000ee000f00000e000e00f0f0fe000000f00fef000f0000000f00f000000f00f00f000000000000
-- 120:00000000000000000000f00f000f0000f0000000000000f00000f00000000000000000eeee0f000000f800eeddddedf0f00000e00f0000f0000000000ee0000feeeef00eeeee00000000d00000000000000f000fe000000ef000000000000000f000000000000000f000f0000f0f00000f000f0000000000
-- 121:0000000000000000000000000f00f0000f0f00f000000f0000000000000000000000000000e0f00000ffeeeddeeeddeee000000e0000000000000f00000e0000eeeeef0e00000ee0dd00e0000000000000000fe0ee0000f00f0f00f00000f0f000f0f00000000000000000f000000f00000f000000000000
-- 122:00000000000000000000f00f00000000000000000f00f0f0f0000f000000f0000000000000000000000f0fdedeeefeddff0000f0000000f00000000000f000feeeeeee0ee0e0fee00000e00000000000000000fe0000ffeef0ee0000f0f00000f0000f000000000000f0f000f00f000f0f000f0000000000
-- 123:000000000000f000000000f000000000f0f0f0000000000000000000000000fe000000000000000000080eeefdeeddddef2f0000e0000000000000000000000feeeeee0e0eee00000000e0000f0000000000000ffef00feeefee0000000000f00000000f00000000f000000000000f000000000000000000
-- 124:00000000000000000000f0000000000000000000000f0f0000f0000000000000000000000000000000000eeefeddddddeeee0000000000f000000000000000feeeefef000000000000ed2000f0000fe00000000eeeefe0eeef0e000f0000000f00f0f0000000000000000f0f0f0f0000f000f00000000000
-- 125:00000000000000f00000000000000000000000000000000000000000000000000000000f0000f0000000feeeeede2ddddeeef0f0f00f00000000000000000000fe000000000fe0000feee000000000000000000eeeeeff0eeefe00000000000f000000f0000000000f0f000000000f000000000000000000
-- 126:00000000000000000000f00f0000000000000000000000000000000000000000000000000000e0000000feeeeedddededdeef0e0e0f00000000000000000000000000000000f000000fee000f000000000000000fefe000feeee00f0000000000f00f0000000000000000000f00000000000000000000000
-- 127:0000000000000000000000000000000000000000000000000000000000000000000000000000000000000feeefeddef000ffef0000e0000000000000000000000000000000000000000ef0000000000000000000eeff000ef00e000000000000000000000000000000000f00000000000000000000000000
-- 128:00000000000000000000000000000000000000000000000000000000000000000000000000000000000000eee0feeeeeee000000000000000000000000000000000000000000f000000ef00000000000000000000f00000f000e0f00000000000000f0f0f0000000f0000000000000000000000000000000
-- 129:00000000000000000000000000000000000000000000000000000000000000000000000000000000000000fe000eee82de00f0000000000000000000000000000000e00000000000000f000f00000000000000000000f000000f000000000000000000000000000000000000000000000000000000000000
-- 130:00000000000000000000000000000000000000000000000000000000000000000000000000000000000000ff0f00ef008f000000000000000000000000000000000000000000f000000000000000000000000000000000f00f00000000000000000000000000000000000000000000000000000000000000
-- 131:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f00000000000000000000000000000000000000000000f00f000f00ff00000f0000000000000000f000000f00f0f0000000000000000000000000000000000000000000000000000000000
-- </SCREEN>

-- <PALETTE>
-- 000:1010105d245db13e50ef9157ffff6daee65061be3c047f5005344c185dc95999f6e6eaf2b6baba8d8d9d444460282038
-- </PALETTE>

-- <PALETTE1>
-- 000:1010105d245db13e50ef9157ffff6daee65061be3c047f5005344c185dc95999f6e6eaf2b6baba8d8d9d444460282038
-- </PALETTE1>

-- <PALETTE2>
-- 000:1010105d245db13e50ef9157ffff6daee65061be3c047f5005344c185dc95999f6e6eaf2b6baba8d8d9d444460282038
-- </PALETTE2>

-- <PALETTE3>
-- 000:1010105d245db13e50ef9157ffff6daee65061be3c047f5005344c185dc95999f6e6eaf2b6baba8d8d9d444460282038
-- </PALETTE3>

-- <PALETTE4>
-- 000:1010105d245db13e50ef9157ffff6daee65061be3c047f5005344c185dc95999f6e6eaf2b6baba8d8d9d444460282038
-- </PALETTE4>

-- <PALETTE5>
-- 000:1010105d245db13e50ef9157ffff6daee65061be3c047f5005344c185dc95999f6e6eaf2b6baba8d8d9d444460282038
-- </PALETTE5>

-- <PALETTE6>
-- 000:1010105d245db13e50ef9157ffff6daee65061be3c047f5005344c185dc95999f6e6eaf2b6baba8d8d9d444460282038
-- </PALETTE6>

-- <PALETTE7>
-- 000:1010105d245db13e50ef9157ffff6daee65061be3c047f5005344c185dc95999f6e6eaf2b6baba8d8d9d444460282038
-- </PALETTE7>

