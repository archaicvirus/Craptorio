AVAILABLE_TECH = {1,2,3,4,5,12}
FINISHED_TECH = {}
UNLOCKED_TECH = {}
UNLOCKED_ITEMS = {}
current_research = false
selected_research = false
current_page = 1
current_tab = true --tab to show available or unlocked tech
local starting_items = {2, 9, 20, 17, 21, 23, 15, 16, 3, 4, 5, 6, 7, 8, 12, 14, 30, 13, 14}
for i = 1, #ITEMS do
  UNLOCKED_ITEMS[i] = false
end
for k, v in ipairs(starting_items) do
  UNLOCKED_ITEMS[v] = true
end

TECH = {
  [1] = {
    name = 'Logistics 1',
    progress = 0,
    completed = false,
    time = 3,
    tier = 1,
    science_packs = {
      {id = 23, count = 1},
      {id = 24, count = 1},
      {id = 25, count = 1},
      {id = 26, count = 1},
      {id = 27, count = 1},
      {id = 28, count = 1},
    },
    required_tech = {},
    item_unlocks = {18, 10, 11},
    tech_unlocks = {},
    sprite = {{id=12,tw=3,th=3,w=24,h=24,rot=0,ck=1,page=1,offset={x=0,y=0}}},
  },
  [2] = {
    name = 'Automation 1',
    progress = 0,
    completed = false,
    time = 5,
    tier = 1,
    science_packs = {
      {id = 23, count = 2}
    },
    required_tech = {},
    item_unlocks = {19, 22},
    tech_unlocks = {},
    sprite = {{id=312,tw=3,th=3,w=24,h=24,rot=0,ck=0,page=0,offset={x=0,y=0}}},
  },
  [3] = {
    name = 'Logistics Pack',
    progress = 0,
    completed = false,
    time = 3,
    science_packs = {
      {id = 23, count = 1}
    },
    required_tech = {},
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
      {id = 23, count = 2}
    },
    required_tech = {},
    item_unlocks = {29},
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
      {id = 23, count = 1}
    },
    required_tech = {},
    item_unlocks = {1, 30},
    tech_unlocks = {},    
    sprite = {
      {id=309,tw=2,th=2,w=16,h=16,rot=0,ck=1,page=0,offset={x=4,y=4}},
    },
  },
  [6] = {
    name = 'Automation 2',
    progress = 0,
    completed = false,
    time = 30,
    tier = 2,
    science_packs = {
      {id = 23, count = 50}
    },
    required_tech = {2,3},
    item_unlocks = {30},
    tech_unlocks = {},    
    sprite = {{id=312,tw=3,th=3,w=24,h=24,rot=0,ck=0,page=0,offset={x=0,y=0}}},
  },
  [7] = {
    name = 'Logistics 2',
    progress = 0,
    completed = false,
    time = 60,
    tier = 2,
    science_packs = {
      {id = 23, count = 100}
    },
    required_tech = {1, 3},
    item_unlocks = {},
    tech_unlocks = {},
    sprite = {{id=12,tw=3,th=3,w=24,h=24,rot=0,ck=1,page=1,offset={x=0,y=0}}},
  },
  [8] = {
    name = 'Solar Energy',
    progress = 0,
    completed = false,
    time = 5,
    science_packs = {
      {id = 23, count = 1},
      {id = 24, count = 1},
    },
    required_tech = {1, 3},
    item_unlocks = {31},
    tech_unlocks = {},
    sprite = {{id=475,tw=3,th=3,w=24,h=24,rot=0,ck=1,page=0,offset={x=0,y=0}}},
  },
  [9] = {
    name = 'Bio-Oil Processing',
    progress = 0,
    completed = false,
    time = 5,
    science_packs = {
      {id = 23, count = 1},
      {id = 24, count = 1},
      {id = 25, count = 1},
    },
    required_tech = {1, 3},
    item_unlocks = {32},
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
      {id = 23, count = 50}
    },
    required_tech = {5},
    item_unlocks = {30},
    tech_unlocks = {},
    sprite = {
      {id=309,tw=2,th=2,w=16,h=16,rot=0,ck=1,page=0,offset={x=0,y=0}},
      {id=309,tw=2,th=2,w=16,h=16,rot=0,ck=1,page=0,offset={x=8,y=8}},
    },
  },
  [11] = {
    name = 'Biofuel Engine',
    progress = 0,
    completed = false,
    time = 30,
    science_packs = {
      {id = 23, count = 100}
    },
    required_tech = {},
    item_unlocks = {33},
    tech_unlocks = {},
    sprite = {
      {id=483,tw=1,th=1,w=8,h=8,rot=0,ck=1,page=0,offset={x=15,y=3}},
      {id=452,tw=1,th=1,w=8,h=8,rot=0,ck=0,page=0,offset={x=1,y=3}},
      {id=468,tw=1,th=1,w=8,h=8,rot=0,ck=1,page=0,offset={x=8,y=14}},
    },
  },
  [12] = {
    name = 'Fiber Extraction',
    progress = 0,
    completed = false,
    time = 5,
    science_packs = {
      {id = 23, count = 1}
    },
    required_tech = {},
    item_unlocks = {34},
    tech_unlocks = {},
    sprite = {
      {id=451,tw=1,th=1,w=8,h=8,rot=0,ck=0,page=0,offset={x=0,y=3}},
      {id=270,tw=1,th=1,w=8,h=8,rot=2,ck=0,page=0,offset={x=8,y=5}},
      {id=268,tw=1,th=1,w=8,h=8,rot=0,ck=0,page=0,offset={x=16,y=2}},
    },
  },
}

for k, v in ipairs(TECH) do
  FINISHED_TECH[k] = false
end
--copy defs so runtime changes are independant
RESEARCH = TECH