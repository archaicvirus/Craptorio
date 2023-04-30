local items = {
  [1] = {
    name = 'red_circuit',
    id = 1,
    sprite_id = 256,
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
    sprite_id = 256,
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
    sprite_id = 55,
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
    sprite_id = 54,
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
  [5] = {
    name = 'stone',
    id = 4,
    sprite_id = 53,
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
    id = 4,
    sprite_id = 56,
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
  [7] = {
    name = 'uranium',
    id = 4,
    sprite_id = 57,
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
    id = 4,
    sprite_id = 58,
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
    id = 5,
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
    id = 6,
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
    id = 7,
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
    id = 8,
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
    id = 9,
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