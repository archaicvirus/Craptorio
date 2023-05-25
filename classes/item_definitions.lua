local items = {
  [1] = {
    name = 'advanced_circuit',
    fancy_name = 'Advanced Circuit',
    id = 1,
    sprite_id = 457,
    belt_id = 296,
    color_key = 0,
    type = 'consumable',
    sub_type = 'icon_only',
    stack_size = 200,
    recipe = {
      [1] = {id = 4, count = 2}, --copper_cable
      [2] = {id = 2, count = 2}, --green_circuit
      [3] = {id = 5, count = 2}, --plastic_bar
    },
  },

  [2] = {
    name = 'electronic_circuit',
    fancy_name = 'Electronic Circuit',
    sprite_id = 456,
    belt_id = 280,
    color_key = 0,
    type = 'consumable',
    sub_type = 'icon_only',
    stack_size = 200,
    recipe = {
      id = 2,
      [1] = {id = 4, count = 2}, --copper_cable
      [2] = {id = 2, count = 2}, --iron_plate
      crafting_time = 4 * 60,
    },
  },

  [3] = {
    name = 'iron_ore',
    fancy_name = 'Iron Ore',
    id = 3,
    sprite_id = 162,
    smelted_id = 15,
    belt_id = 178,
    color_key = 0,
    --alt_ids = {256, }
    type = 'ore',
    stack_size = 100,
    smelting_time = 5 * 60,
    mining_time = 4 * 60,
    recipe = false,
  },

  [4] = {
    name = 'copper_ore',
    fancy_name = 'Copper Ore',
    id = 4,
    sprite_id = 161,
    belt_id = 177,
    color_key = 0,
    type = 'ore',
    stack_size = 100,
    smelted_id = 16,
    smelting_time = 5 * 60,
    mining_time = 4 * 60,
    recipe = false,
  },
  [5] = {
    name = 'stone',
    fancy_name = 'Stone',
    id = 5,
    sprite_id = 160,
    belt_id = 176,
    color_key = 0,
    type = 'ore',
    stack_size = 100,
    smelted_id = 17,
    smelting_time = 5 * 60,
    mining_time = 4 * 60,
    recipe = false,
  },
  [6] = {
    name = 'coal',
    fancy_name = 'Coal',
    id = 6,
    sprite_id = 163,
    belt_id = 179,
    color_key = 0,
    type = 'fuel',
    stack_size = 100,
    smelting_time = 1 * 5 * 60,
    mining_time = 4 * 60,
    recipe = false,
  },
  [7] = {
    name = 'uranium',
    fancy_name = 'Uranium',
    id = 7,
    sprite_id = 164,
    belt_id = 180,
    color_key = 0,
    type = 'liquid',
    stack_size = 100,
    smelting_time = 5 * 60,
    mining_time = 4 * 60,
    recipe = false,
  },
  [8] = {
    name = 'oil_shale',
    fancy_name = 'Oil Shale',
    id = 8,
    sprite_id = 165,
    belt_id = 181,
    color_key = 0,
    type = 'liquid',
    stack_size = 100,
    smelting_time = 5 * 60,
    mining_time = 4 * 60,
    recipe = false,
  },
  [9] = {
    name = 'transport_belt',
    fancy_name = 'Transport Belt',
    sprite_id = 256,
    belt_id = 434,
    color_key = 0,
    type = 'placeable',
    stack_size = 100,
    recipe = {
      id = 9,
      crafting_time = 2.0,
      count = 2,
      ingredients = {
        [1] = {id = 20, count = 1}, --gear
        [2] = {id = 15, count = 1}, --plate
      }
    },
  },
  [10] = {
    name = 'splitter',
    fancy_name = 'Splitter',
    sprite_id = 500,
    belt_id = 433,
    color_key = 0,
    type = 'placeable',
    stack_size = 100,
    recipe = {
      id = 10,
      crafting_time = 2.0,
      count = 2,
      ingredients = {
        [1] = {id = 2, count = 5}, --green_circuit
        [2] = {id = 15, count = 5}, --plate
        [3] = {id = 9, count = 5}, -- transport_belt
      }
    },
  },
  [11] = {
    name = 'inserter',
    fancy_name = 'Inserter',
    sprite_id = 472,
    type = 'placeable',
    stack_size = 100,
    recipe = {
      id = 11,
      crafting_time = 1.0,
      count = 1,
      ingredients = {
        [1] = {id = 2, count = 1}, --circuit
        [2] = {id = 20, count = 1}, --gear
        [3] = {id = 15, count = 1}, --plate
      }
    },
  },
  [12] = {
    name = 'power_pole',
    fancy_name = 'Power Pole',
    id = 12,
    sprite_id = 478,
    type = 'placeable',
    stack_size = 100,
    recipe = {},
  },
  [13] = {
    name = 'mining_drill',
    fancy_name = 'Mining Drill',
    id = 13,
    sprite_id = 487,
    type = 'placeable',
    stack_size = 100,
    recipe = {},
  },
  [14] = {
    name = 'stone_furnace',
    fancy_name = 'Stone Furnace',
    id = 14,
    sprite_id = 503,
    type = 'placeable',
    stack_size = 50,
    recipe = {},
  },
  [15] = {
    name = 'iron_plate',
    fancy_name = 'Iron Plate',
    id = 15,
    sprite_id = 448,
    belt_id = 299,
    type = 'intermediate',
    stack_size = 100,
    recipe = {[1] = {name = 'iron_ore', item_id = 3, count = 1}},
  },
  [16] = {
    name = 'copper_plate',
    fancy_name = 'Copper Plate',
    id = 16,
    sprite_id = 449,
    belt_id = 300,
    type = 'intermediate',
    stack_size = 100,
    recipe = {[1] = {name = 'copper_ore', item_id = 4, count = 1}},
  },
  [17] = {
    name = 'stone_brick',
    fancy_name = 'Stone Brick',
    id = 17,
    sprite_id = 449,
    belt_id = 300,
    type = 'intermediate',
    stack_size = 100,
    recipe = {nil},
  },
  [18] = {
    name = 'underground_belt',
    fancy_name = 'Underground Belt',
    sprite_id = 374,
    belt_id = 300,
    type = 'placeable',
    stack_size = 50,
    recipe = {
      id = 18,
      crafting_time = 1.0,
      count = 1,
      ingredients = {
        [1] = {id = 15, count = 10}, --plate
        [2] = {id = 9, count = 5}, --transport_belt
      }
    },
  },
  [19] = {
    name = 'assembly_machine',
    fancy_name = 'Assembly Machine',
    id = 19,
    sprite_id = 483,
    belt_id = 312,
    type = 'placeable',
    stack_size = 50,
    recipe = {}
  },
  [20] = {
    name = 'gear',
    fancy_name = 'Gear',
    id = 20,
    sprite_id = 452,
    belt_id = 432,
    type = 'intermediate',
    stack_size = 100,
    recipe = {
      id = 20,
      crafting_time = 120,
      count = 1,
      ingredients = {
        [1] = {id = 15, count = 2}
      }
    }
  },
}

local item_types = {
  ['ore'] = {
    stack_size = 50,
  },
  ['consumable'] = {
    stack_size = 100,
  },
  ['placeable'] = {
    stack_size = 50,
  },
}

return items