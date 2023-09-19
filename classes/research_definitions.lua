AVAILABLE_TECH = {1,2,5,6}--{1,2,3,4,5,6,12,13}--,6,7,8,9,10,11,12,13}
FINISHED_TECH = {}
UNLOCKED_TECH = {}
UNLOCKED_ITEMS = {}
current_research = false
selected_research = false
current_page = 1
current_tab = true --tab to show available or unlocked tech
local starting_items = {9, 20, 17, 21, 23, 15, 16, 3, 4, 5, 6, 7, 8, 14, 33, 22, 2}
for i = 1, #ITEMS do
  UNLOCKED_ITEMS[i] = false
end
for k, v in ipairs(starting_items) do
  UNLOCKED_ITEMS[v] = true
end

TECH = {
  [1] = {
    name = 'Logistics',
    progress = 0,
    completed = false,
    time = 3,
    tier = 1,
    science_packs = {
      {id = 23, count = 5},
    },
    required_tech = {},
    item_unlocks = {18, 10, 11},
    tech_unlocks = {},
    sprite = {{id=12,tw=3,th=3,w=24,h=24,rot=0,ck=1,page=1,offset={x=0,y=0}}},
    callback = function(self)
      trace(self.name .. ' - callback triggered after research was completed')
    end,
  },
  [2] = {
    name = 'Automation',
    progress = 0,
    completed = false,
    time = 5,
    tier = 1,
    science_packs = {
      {id = 23, count = 15}
    },
    required_tech = {},
    item_unlocks = {19, 13},
    tech_unlocks = {},
    sprite = {{id=312,tw=3,th=3,w=24,h=24,rot=0,ck=0,page=0,offset={x=0,y=0}}},
  },
  [3] = {
    name = 'Logistics Pack',
    progress = 0,
    completed = false,
    time = 3,
    science_packs = {
      {id = 23, count = 30}
    },
    required_tech = {1},
    item_unlocks = {24},
    tech_unlocks = {},
    sprite = {
      {id=269,tw=2,th=2,w=16,h=16,rot=0,ck=1,page=1,offset={x=4,y=4}},
      {id=461,tw=1,th=1,w=8,h=8,rot=0,ck=0,page=0,offset={x=1,y=1}},
      {id=399,tw=1,th=1,w=8,h=8,rot=0,ck=0,page=0,offset={x=15,y=1}},
    },
  },
  [4] = {
    name = 'Steel Processing',
    progress = 0,
    completed = false,
    time = 1,
    science_packs = {
      {id = 23, count = 35}
    },
    required_tech = {3},
    item_unlocks = {27},
    tech_unlocks = {},
    sprite = {
      {id=448,tw=1,th=1,w=8,h=8,rot=0,ck=1,page=0,offset={x=1,y=3}},
      {id=448,tw=1,th=1,w=8,h=8,rot=0,ck=1,page=0,offset={x=2,y=5}},
      {id=270,tw=1,th=1,w=8,h=8,rot=2,ck=0,page=0,offset={x=8,y=2}},
      {id=503,tw=1,th=1,w=8,h=8,rot=0,ck=6,page=0,offset={x=15,y=2}},
      {id=468,tw=1,th=1,w=8,h=8,rot=0,ck=1,page=0,offset={x=8,y=13}}
    },
  },
  [5] = {
    name = 'Electronics 1',
    progress = 0,
    completed = false,
    time = 5,
    tier = 1,
    science_packs = {
      {id = 23, count = 10}
    },
    required_tech = {},
    item_unlocks = {1},
    tech_unlocks = {},
    sprite = {
      {id=309,tw=2,th=2,w=16,h=16,rot=0,ck=1,page=0,offset={x=4,y=4}},
    },
  },
  [6] = {
    name = 'Laser Mining 1',
    progress = 0,
    completed = false,
    time = 5,
    tier = 1,
    science_packs = {
      {id = 23, count = 35}
    },
    required_tech = {},
    item_unlocks = {34},
    info = {'Increases mining speed', 'by 150%'},
    tech_unlocks = {},
    sprite = {
      {id=341,tw=1,th=1,w=8,h=8,rot=0,ck=1,page=0,offset={x=4,y=4}},
      {id=342,tw=1,th=1,w=8,h=8,rot=0,ck=1,page=0,offset={x=12,y=4}},
      {id=357,tw=1,th=1,w=8,h=8,rot=0,ck=1,page=0,offset={x=4,y=12}},
      {id=358,tw=1,th=1,w=8,h=8,rot=0,ck=1,page=0,offset={x=12,y=12}},
    },
    callback = function(self)
      trace(self.name .. ' - callback triggered after research was completed')
      CURSOR_MINING_SPEED = floor(CURSOR_MINING_SPEED - (CURSOR_MINING_SPEED*0.5))
      trace('set CURSOR_MINING_SPEED to ' .. CURSOR_MINING_SPEED)
    end,
  },
  [7] = {
    name = 'Laser Mining 2',
    progress = 0,
    completed = false,
    time = 5,
    tier = 1,
    science_packs = {
      {id = 23, count = 50},
      {id = 24, count = 50},
    },
    required_tech = {6, 10},
    item_unlocks = {38},
    info = {'Increases mining speed', 'by 150%'},
    tech_unlocks = {},
    sprite = {
      {id=343,tw=1,th=1,w=8,h=8,rot=0,ck=1,page=0,offset={x=4,y=4}},
      {id=342,tw=1,th=1,w=8,h=8,rot=0,ck=1,page=0,offset={x=12,y=4}},
      {id=357,tw=1,th=1,w=8,h=8,rot=0,ck=1,page=0,offset={x=4,y=12}},
      {id=359,tw=1,th=1,w=8,h=8,rot=0,ck=1,page=0,offset={x=12,y=12}},
    },
    callback = function(self)
      trace(self.name .. ' - callback triggered after research was completed')
      CURSOR_MINING_SPEED = floor(CURSOR_MINING_SPEED - (CURSOR_MINING_SPEED*0.5))
      trace('set CURSOR_MINING_SPEED to ' .. CURSOR_MINING_SPEED)
    end,
  },
  [8] = {
    name = 'Laser Mining 3',
    progress = 0,
    completed = false,
    time = 5,
    tier = 1,
    science_packs = {
      {id = 23, count = 100},
      {id = 24, count = 100},
      {id = 25, count = 100},
    },
    required_tech = {7, 15},
    item_unlocks = {39},
    info = {'Increases mining speed', 'by 150%'},
    tech_unlocks = {},
    sprite = {
      {id=327,tw=1,th=1,w=8,h=8,rot=0,ck=1,page=0,offset={x=4,y=4}},
      {id=342,tw=1,th=1,w=8,h=8,rot=0,ck=1,page=0,offset={x=12,y=4}},
      {id=357,tw=1,th=1,w=8,h=8,rot=0,ck=1,page=0,offset={x=4,y=12}},
      {id=360,tw=1,th=1,w=8,h=8,rot=0,ck=1,page=0,offset={x=12,y=12}},
    },
    callback = function(self)
      trace(self.name .. ' - callback triggered after research was completed')
      CURSOR_MINING_SPEED = floor(CURSOR_MINING_SPEED - (CURSOR_MINING_SPEED*0.5))
      trace('set CURSOR_MINING_SPEED to ' .. CURSOR_MINING_SPEED)
    end,
  },
  [9] = {
    name = 'Oil Processing',
    progress = 0,
    completed = false,
    time = 5,
    science_packs = {
      {id = 23, count = 50},
      {id = 24, count = 50},
    },
    required_tech = {1, 3, 4},
    item_unlocks = {30, 45},
    tech_unlocks = {},
    sprite = {{id=371,tw=3,th=3,w=24,h=24,rot=0,ck=1,page=0,offset={x=0,y=0}}},
  },
  [10] = {
    name = 'Electronics 2',
    progress = 0,
    completed = false,
    time = 30,
    tier = 2,
    science_packs = {
      {id = 23, count = 25},
      {id = 24, count = 25},
    },
    required_tech = {5, 13},
    item_unlocks = {37},
    tech_unlocks = {},
    sprite = {
      {id=309,tw=2,th=2,w=16,h=16,rot=0,ck=1,page=0,offset={x=0,y=0}},
      {id=309,tw=2,th=2,w=16,h=16,rot=0,ck=1,page=0,offset={x=8,y=8}},
    },
  },
  [11] = {
    name = 'Biofuel Processing',
    progress = 0,
    completed = false,
    time = 30,
    science_packs = {
      {id = 23, count = 25},
      {id = 24, count = 25},
      {id = 25, count = 25},
    },
    required_tech = {12, 3, 9, 14},
    item_unlocks = {31, 35},
    tech_unlocks = {},
    sprite = {
      {id=462,tw=1,th=1,w=8,h=8,rot=0,ck=0,page=0,offset={x=2,y=2}},
      {id=165,tw=1,th=1,w=8,h=8,rot=0,ck=4,page=0,offset={x=15,y=2}},
      {id=483,tw=1,th=1,w=8,h=8,rot=0,ck=1,page=0,offset={x=2,y=13}},
      {id=482,tw=1,th=1,w=8,h=8,rot=0,ck=6,page=0,offset={x=15,y=14}},
    },
  },
  [12] = {
    name = 'Fiber Extraction',
    progress = 0,
    completed = false,
    time = 5,
    science_packs = {
      {id = 25, count = 10}
    },
    required_tech = {14},
    item_unlocks = {32},
    tech_unlocks = {},
    sprite = {
      {id=451,tw=1,th=1,w=8,h=8,rot=0,ck=0,page=0,offset={x=0,y=3}},
      {id=270,tw=1,th=1,w=8,h=8,rot=2,ck=0,page=0,offset={x=8,y=5}},
      {id=268,tw=1,th=1,w=8,h=8,rot=0,ck=0,page=0,offset={x=16,y=2}},
    },
  },
  [13] = {
    name = 'Plastic Bar',
    progress = 0,
    completed = false,
    time = 5,
    science_packs = {
      {id = 23, count = 25},
      {id = 24, count = 25},
      {id = 25, count = 25},
    },
    required_tech = {9},
    item_unlocks = {36},
    tech_unlocks = {},
    sprite = {
      {id=283,tw=1,th=1,w=8,h=8,rot=0,ck=4,page=0,offset={x=0,y=2}},
      {id=268,tw=1,th=1,w=8,h=8,rot=0,ck=0,page=0,offset={x=16,y=1}},
      {id=165,tw=1,th=1,w=8,h=8,rot=0,ck=4,page=0,offset={x=8,y=2}},
      {id=270,tw=1,th=1,w=8,h=8,rot=3,ck=0,page=0,offset={x=8,y=6}},
      {id=374,tw=1,th=1,w=8,h=8,rot=0,ck=1,page=0,offset={x=9,y=14}},
    },
  },
  [14] = {
    name = 'Biology Pack',
    progress = 0,
    completed = false,
    time = 3,
    science_packs = {
      {id = 23, count = 25},
      {id = 24, count = 25},
    },
    required_tech = {3, 9, 11, 12},
    item_unlocks = {25},
    tech_unlocks = {},
    sprite = {
      {id=301,tw=2,th=2,w=16,h=16,rot=0,ck=1,page=1,offset={x=4,y=4}},
      {id=462,tw=1,th=1,w=8,h=8,rot=0,ck=0,page=0,offset={x=1,y=1}},
      {id=399,tw=1,th=1,w=8,h=8,rot=0,ck=0,page=0,offset={x=15,y=1}},
    },
  },
  [15] = {
    name = 'Production Pack',
    progress = 0,
    completed = false,
    time = 3,
    science_packs = {
      {id = 23, count = 100},
      {id = 24, count = 100},
      {id = 25, count = 100}
    },
    required_tech = {14},
    item_unlocks = {26},
    tech_unlocks = {},
    sprite = {
      {id=333,tw=2,th=2,w=16,h=16,rot=0,ck=1,page=1,offset={x=4,y=4}},
      {id=463,tw=1,th=1,w=8,h=8,rot=0,ck=0,page=0,offset={x=1,y=1}},
      {id=399,tw=1,th=1,w=8,h=8,rot=0,ck=0,page=0,offset={x=15,y=1}},
    },
  },
  -- [16] = {
  --   name = 'Iron Chest',
  --   progress = 0,
  --   completed = false,
  --   time = 3,
  --   science_packs = {
  --     {id = 23, count = 1},
  --     {id = 24, count = 1},
  --     {id = 25, count = 1}
  --   },
  --   required_tech = {14},
  --   item_unlocks = {26},
  --   tech_unlocks = {},
  --   sprite = {
  --     {id=333,tw=2,th=2,w=16,h=16,rot=0,ck=1,page=1,offset={x=4,y=4}},
  --     {id=463,tw=1,th=1,w=8,h=8,rot=0,ck=0,page=0,offset={x=1,y=1}},
  --     {id=399,tw=1,th=1,w=8,h=8,rot=0,ck=0,page=0,offset={x=15,y=1}},
  --   },
  -- },
}

for k, v in ipairs(TECH) do
  FINISHED_TECH[k] = false
end
--copy defs so runtime changes are independant
RESEARCH = TECH