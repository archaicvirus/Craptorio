local items = {
  [1] = {
    name = 'red_circuit',
    id = 1,
    sprite_id = 457,
    belt_id = 296,
    type = 'consumable',
    sub_type = 'icon_only',
    stack_size = 200,
    recipie = {
      [1] = {id = 4, count = 2}, --copper_cable
      [2] = {id = 2, count = 2}, --green_circuit
      [3] = {id = 5, count = 2}, --plastic_bar
    },
    pixels = {
      2,2,1,
      3,4,2,
      1,2,4,
    },
  },

  [2] = {
    name = 'green_circuit',
    id = 2,
    sprite_id = 456,
    belt_id = 280,
    type = 'consumable',
    sub_type = 'icon_only',
    stack_size = 200,
    recipie = {
      [1] = {id = 4, count = 2}, --copper_cable
      [2] = {id = 2, count = 2}, --iron_plate
      crafting_time = 4 * 60,
    },
    pixels = {
      6,5,6,
      3,4,5,
      6,5,4,
    },
  },

  [3] = {
    name = 'iron_ore',
    id = 3,
    sprite_id = 38,
    smelted_id = 15,
    belt_id = 55,
    --alt_ids = {256, }
    type = 'ore',
    stack_size = 100,
    smelting_time = 5 * 60,
    mining_time = 4 * 60,
    recipie = false,
    pixels = {
      9,8,0,
      8,15,13,
      0,14,8,
    },
  },

  [4] = {
    name = 'copper_ore',
    id = 4,
    sprite_id = 37,
    belt_id = 54,
    type = 'ore',
    stack_size = 100,
    smelted_id = 16,
    smelting_time = 5 * 60,
    mining_time = 4 * 60,
    recipie = false,
    pixels = {
      9,8,0,
      8,15,13,
      0,14,8,
    },
  },
  [5] = {
    name = 'stone',
    id = 5,
    sprite_id = 53,
    belt_id = 53,
    type = 'ore',
    stack_size = 100,
    smelting_time = 5 * 60,
    mining_time = 4 * 60,
    recipie = false,
    pixels = {
      9,8,0,
      8,15,13,
      0,14,8,
    },
  },
  [6] = {
    name = 'coal',
    id = 6,
    sprite_id = 283,
    belt_id = 56,
    type = 'fuel',
    stack_size = 100,
    smelting_time = 1 * 5 * 60,
    mining_time = 4 * 60,
    recipie = false,
    pixels = {
      9,8,0,
      8,15,13,
      0,14,8,
    },
  },
  [7] = {
    name = 'uranium',
    id = 7,
    sprite_id = 57,
    belt_id = 57,
    type = 'ore',
    stack_size = 100,
    smelting_time = 5 * 60,
    mining_time = 4 * 60,
    recipie = false,
    pixels = {
      9,8,0,
      8,15,13,
      0,14,8,
    },
  },
  [8] = {
    name = 'oil_shale',
    id = 8,
    sprite_id = 58,
    belt_id = 58,
    type = 'ore',
    stack_size = 100,
    smelting_time = 5 * 60,
    mining_time = 4 * 60,
    recipie = false,
    pixels = {
      9,8,0,
      8,15,13,
      0,14,8,
    },
  },
  [9] = {
    name = 'transport_belt',
    id = 9,
    sprite_id = 256,
    type = 'placeable',
    stack_size = 100,
    recipie = {},
    pixels = {
      9,8,0,
      8,15,13,
      0,14,8,
    },
  },
  [10] = {
    name = 'splitter',
    id = 10,
    sprite_id = 500,
    type = 'placeable',
    stack_size = 100,
    recipie = {},
    pixels = {
      9,8,0,
      8,15,13,
      0,14,8,
    },
  },
  [11] = {
    name = 'inserter',
    id = 11,
    sprite_id = 472,
    type = 'placeable',
    stack_size = 100,
    recipie = {},
    pixels = {
      9,8,0,
      8,15,13,
      0,14,8,
    },
  },
  [12] = {
    name = 'power_pole',
    id = 12,
    sprite_id = 478,
    type = 'placeable',
    stack_size = 100,
    recipie = {},
    pixels = {
      9,8,0,
      8,15,13,
      0,14,8,
    },
  },
  [13] = {
    name = 'mining_drill',
    id = 13,
    sprite_id = 487,
    type = 'placeable',
    stack_size = 100,
    recipie = {},
  },
  [14] = {
    name = 'stone_furnace',
    id = 14,
    sprite_id = 503,
    type = 'placeable',
    stack_size = 50,
    recipie = {},
  },
  [15] = {
    name = 'iron_plate',
    id = 15,
    sprite_id = 448,
    belt_id = 299,
    type = 'intermediate',
    stack_size = 100,
    recipie = {[1] = {name = 'iron_ore', item_id = 3, count = 1}},
  },
  [16] = {
    name = 'copper_plate',
    id = 16,
    sprite_id = 449,
    belt_id = 300,
    type = 'intermediate',
    stack_size = 100,
    recipie = {[1] = {name = 'copper_ore', item_id = 4, count = 1}},
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