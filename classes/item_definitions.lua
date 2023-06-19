ITEMS = {
  [0] = false,
  [1] = {
    name = 'advanced_circuit',
    fancy_name = 'Advanced Circuit',
    id = 1,
    sprite_id = 457,
    belt_id = 296,
    color_key = 0,
    type = 'consumable',
    craftable = {'player', 'machine'},
    sub_type = 'icon_only',
    stack_size = 200,
    recipe = {
      id = 1,
      crafting_time = 60*6,
      count = 1,
      ingredients = {
        [1] = {id = 21, count = 2}, --copper_cable
        [2] = {id = 2, count = 2}, --green_circuit
        [3] = {id = 5, count = 2}, --plastic_bar
      },
    }
  },
  [2] = {
    name = 'electronic_circuit',
    fancy_name = 'Electronic Circuit',
    sprite_id = 456,
    belt_id = 280,
    color_key = 0,
    type = 'consumable',
    craftable = {'player', 'machine'},
    sub_type = 'icon_only',
    stack_size = 200,
    recipe = {
      id = 2,
      crafting_time = 60*0.5,
      count = 1,
      ingredients = {
        [1] = {id = 21, count = 2}, --copper_cable
        [2] = {id = 15, count = 2}, --iron_plate
      }
    },
  },
  [3] = {
    name = 'iron_ore',
    fancy_name = 'Iron Ore',
    id = 3,
    sprite_id = 162,
    smelted_id = 15,
    belt_id = 178,
    color_key = 4,
    --alt_ids = {256, }
    type = 'ore',
    craftable = false,
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
    color_key = 1,
    type = 'ore',
    craftable = false,
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
    color_key = 4,
    type = 'ore',
    craftable = false,
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
    color_key = 4,
    type = 'fuel',
    craftable = false,
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
    color_key = 4,
    type = 'liquid',
    craftable = false,
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
    color_key = 4,
    type = 'liquid',
    craftable = false,
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
    color_key = 1,
    type = 'placeable',
    craftable = {'player', 'machine'},
    stack_size = 100,
    recipe = {
      id = 9,
      crafting_time = 60*0.5,
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
    sprite_id = 323,
    belt_id = 433,
    color_key = 0,
    type = 'placeable',
    craftable = {'player', 'machine'},
    stack_size = 100,
    recipe = {
      id = 10,
      crafting_time = 60*1,
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
    sprite_id = 267,
    belt_id = 417,
    color_key = 0,
    type = 'placeable',
    craftable = {'player', 'machine'},
    stack_size = 100,
    recipe = {
      id = 11,
      crafting_time = 60*0.5,
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
    belt_id = 433,
    color_key = 0,
    type = 'placeable',
    craftable = {'player', 'machine'},
    stack_size = 100,
    recipe = {},
  },
  [13] = {
    name = 'mining_drill',
    fancy_name = 'Mining Drill',
    id = 13,
    sprite_id = 276,
    belt_id = 416,
    color_key = 0,
    type = 'placeable',
    craftable = {'player', 'machine'},
    stack_size = 100,
    recipe = {
      id = 21,
      crafting_time = 60*2,
      count = 2,
      ingredients = {
        [1] = {id = 20, count = 3},
        [2] = {id = 15, count = 3},
        [3] = {id = 14, count = 1}
      },
    }
  },
  [14] = {
    name = 'stone_furnace',
    fancy_name = 'Stone Furnace',
    id = 14,
    sprite_id = 503,
    belt_id = 433,
    color_key = 6,
    type = 'placeable',
    craftable = {'player', 'machine'},
    stack_size = 50,
    recipe = {
      id = 21,
      crafting_time = 60*0.5,
      count = 2,
      ingredients = {
        [1] = {id = 16, count = 1}
      },
    }
  },
  [15] = {
    name = 'iron_plate',
    fancy_name = 'Iron Plate',
    id = 15,
    sprite_id = 448,
    belt_id = 299,
    color_key = 1,
    type = 'intermediate',
    craftable = false,
    stack_size = 100,
    smelting_time = 10,
    recipe = {[1] = {name = 'iron_ore', item_id = 3, count = 1}},
  },
  [16] = {
    name = 'copper_plate',
    fancy_name = 'Copper Plate',
    id = 16,
    sprite_id = 449,
    belt_id = 300,
    color_key = 1,
    type = 'intermediate',
    craftable = false,
    stack_size = 100,
    smelting_time = 10,
    recipe = {[1] = {name = 'copper_ore', item_id = 4, count = 1}},
  },
  [17] = {
    name = 'stone_brick',
    fancy_name = 'Stone Brick',
    id = 17,
    sprite_id = 450,
    belt_id = 282,
    color_key = 1,
    type = 'intermediate',
    craftable = false,
    stack_size = 100,
    smelting_time = 10,
    recipe = {nil},
  },
  [18] = {
    name = 'underground_belt',
    fancy_name = 'Underground Belt',
    sprite_id = 374,
    belt_id = 418,
    color_key = 0,
    type = 'placeable',
    craftable = {'player', 'machine'},
    stack_size = 50,
    recipe = {
      id = 18,
      crafting_time = 60*1,
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
    sprite_id = 331,
    belt_id = 347,
    color_key = 0,
    type = 'placeable',
    craftable = {'player', 'machine'},
    sub_type = 'craftable',
    stack_size = 50,
    recipe = {
      id = 21,
      crafting_time = 60*0.5,
      count = 2,
      ingredients = {
        [1] = {id = 2, count = 3},
        [1] = {id = 20, count = 5},
        [1] = {id = 15, count = 1},
      },
    }
  },
  [20] = {
    name = 'gear',
    fancy_name = 'Gear',
    id = 20,
    sprite_id = 452,
    belt_id = 432,
    color_key = 0,
    type = 'intermediate',
    craftable = {'player', 'machine'},
    stack_size = 100,
    recipe = {
      id = 20,
      crafting_time = 60*0.5,
      count = 1,
      ingredients = {
        [1] = {id = 15, count = 2}
      }
    }
  },
  [21] = {
    name = 'copper_cable',
    fancy_name = 'Copper Cable',
    sprite_id = 453,
    belt_id = 281,
    color_key = 0,
    type = 'intermediate',
    craftable = {'player', 'machine'},
    sub_type = 'craftable',
    stack_size = 100,
    recipe = {
      id = 21,
      crafting_time = 60*0.5,
      count = 2,
      ingredients = {
        [1] = {id = 16, count = 1}
      },
    }
  },
  [22] = {
    name = 'research_lab',
    fancy_name = 'Research Lab',
    sprite_id = 399,
    belt_id = 281,
    color_key = 0,
    type = 'placeable',
    craftable = {'player', 'machine'},
    sub_type = 'craftable',
    stack_size = 50,
    recipe = {
      id = 22,
      crafting_time = 60*2,
      count = 1,
      ingredients = {
        [1] = {id = 2, count = 10},
        [2] = {id = 20, count = 10},
        [3] = {id = 9, count = 4}
      },
    }
  },
  [23] = {
    name = 'automation_pack',
    fancy_name = 'Automation Pack',
    sprite_id = 460,
    belt_id = 444,
    color_key = 0,
    type = 'intermediate',
    craftable = {'player', 'machine'},
    sub_type = 'craftable',
    stack_size = 50,
    recipe = {
      id = 23,
      crafting_time = 60*5,
      count = 1,
      ingredients = {
        [1] = {id = 16, count = 1},
        [2] = {id = 20, count = 1}
      },
    }
  },
  [24] = {
    name = 'logistics_pack',
    fancy_name = 'Logistics Pack',
    sprite_id = 461,
    belt_id = 445,
    color_key = 0,
    type = 'intermediate',
    craftable = {'player', 'machine'},
    sub_type = 'craftable',
    stack_size = 50,
    recipe = {
      id = 24,
      crafting_time = 60*6,
      count = 1,
      ingredients = {
        [1] = {id = 11, count = 1},
        [2] = {id =  9, count = 1}
      },
    }
  },
  [25] = {
    name = 'biology_pack',
    fancy_name = 'Biology Pack',
    sprite_id = 462,
    belt_id = 446,
    color_key = 0,
    type = 'intermediate',
    craftable = {'machine'},
    sub_type = 'craftable',
    stack_size = 50,
    recipe = {
      id = 25,
      crafting_time = 60*10,
      count = 1,
      ingredients = {
        [1] = {id = 4, count = 2}, --copper
        [2] = {id = 6, count = 5}, --coal
        [3] = {id = 8, count = 10} --oil
      },
    }
  },
  [26] = {
    name = 'production_pack',
    fancy_name = 'Production Pack',
    sprite_id = 463,
    belt_id = 447,
    color_key = 0,
    type = 'intermediate',
    craftable = {'machine'},
    sub_type = 'craftable',
    stack_size = 50,
    recipe = {
      id = 26,
      crafting_time = 60*20,
      count = 1,
      ingredients = {
        [1] = {id = 4, count = 2}, --copper
        [2] = {id = 6, count = 5}, --coal
        [3] = {id = 8, count = 10} --oil
      },
    }
  },
  [27] = {
    name = 'chemical_pack',
    fancy_name = 'Chemical Pack',
    sprite_id = 496,
    belt_id = 480,
    color_key = 0,
    type = 'intermediate',
    craftable = {'machine'},
    sub_type = 'craftable',
    stack_size = 50,
    recipe = {
      id = 27,
      crafting_time = 60*25,
      count = 1,
      ingredients = {
        [1] = {id = 4, count = 2}, --copper
        [2] = {id = 6, count = 5}, --coal
        [3] = {id = 8, count = 10} --oil
      },
    }
  },
  [28] = {
    name = 'fungal_pack',
    fancy_name = 'Fungal Pack',
    sprite_id = 497,
    belt_id = 481,
    color_key = 0,
    type = 'intermediate',
    craftable = {'machine'},
    sub_type = 'craftable',
    stack_size = 50,
    recipe = {
      id = 28,
      crafting_time = 60*30,
      count = 1,
      ingredients = {
        [1] = {id = 4, count = 2}, --copper
        [2] = {id = 6, count = 5}, --coal
        [3] = {id = 8, count = 10}, --oil
        [4] = {id = 17, count = 50} --oil
      },
    }
  },
  [29] = {
    name = 'steel_plate',
    fancy_name = 'Steel Plate',
    id = 29,
    sprite_id = 387,
    belt_id = 299,
    color_key = 0,
    type = 'intermediate',
    craftable = false,
    stack_size = 100,
    smelting_time = 10,
    recipe = {[1] = {name = 'iron_plate', item_id = 29, count = 2}},
  },
}