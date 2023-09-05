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
    stack_size = 100,
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
    id = 2,
    sprite_id = 456,
    belt_id = 280,
    color_key = 0,
    type = 'consumable',
    craftable = {'player', 'machine'},
    sub_type = 'icon_only',
    stack_size = 100,
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
    info = 'Collected by laser, or mining drill. Found at iron ore deposits in the wild',
    id = 3,
    sprite_id = 162,
    smelted_id = 15,
    belt_id = 178,
    color_key = 4,
    --alt_ids = {256, }
    type = 'ore',
    craftable = false,
    stack_size = 100,
    smelting_time = 1 * 60,
    mining_time = 4 * 60,
    recipe = false,
  },
  [4] = {
    name = 'copper_ore',
    fancy_name = 'Copper Ore',
    info = 'Collected by laser, or mining drill. Found at copper ore deposits in the wild',
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
    fancy_name = 'Stone Ore',
    info = 'Collected by laser, or mining drill. Found at stone ore deposits, and loose stones in the wild',
    id = 5,
    sprite_id = 160,
    belt_id = 176,
    color_key = 4,
    type = 'ore',
    craftable = false,
    stack_size = 100,
    smelted_id = 17,
    smelting_time = 2 * 60,
    mining_time = 2 * 60,
    recipe = false,
  },
  [6] = {
    name = 'coal',
    fancy_name = 'Coal',
    info = 'Collected by laser, or mining drill. Found at coal ore deposits in the wild',
    id = 6,
    sprite_id = 163,
    belt_id = 179,
    color_key = 4,
    type = 'fuel',
    craftable = false,
    stack_size = 100,
    fuel_time = 1 * 5 * 60,
    mining_time = 1 * 60,
    recipe = false,
  },
  [7] = {
    name = 'uranium',
    fancy_name = 'Uranium Ore',
    info = 'Collected by mining drill only. Found at uranium ore deposits in the wild',
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
    info = 'Collected by laser, or mining drill. Found at oil-shale deposits in the wild',
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
    id = 9,
    sprite_id = 256,
    belt_id = 434,
    color_key = 0,
    type = 'placeable',
    craftable = {'player', 'machine'},
    stack_size = 100,
    recipe = {
      id = 9,
      crafting_time = 60*0.5,
      count = 2,
      ingredients = {
        [1] = {id = 20, count = 1},
        [2] = {id = 15, count = 1},
      }
    },
  },
  [10] = {
    name = 'splitter',
    fancy_name = 'Splitter',
    id = 10,
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
        [1] = {id = 2, count = 5},
        [2] = {id = 15, count = 5},
        [3] = {id = 9, count = 5},
      }
    },
  },
  [11] = {
    name = 'inserter',
    fancy_name = 'Inserter',
    id = 11,
    sprite_id = 267,
    belt_id = 417,
    color_key = 15,
    type = 'placeable',
    craftable = {'player', 'machine'},
    stack_size = 100,
    recipe = {
      id = 11,
      crafting_time = 60*0.5,
      count = 1,
      ingredients = {
        [1] = {id = 2, count = 1},
        [2] = {id = 20, count = 1},
        [3] = {id = 15, count = 1},
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
    stack_size = 50,
    recipe = {
      id = 13,
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
    belt_id = 502,
    color_key = 6,
    type = 'placeable',
    craftable = {'player', 'machine'},
    stack_size = 50,
    recipe = {
      id = 14,
      crafting_time = 60*0.5,
      count = 1,
      ingredients = {
        [1] = {id = 5, count = 5}
      },
    }
  },
  [15] = {
    name = 'iron_plate',
    fancy_name = 'Iron Plate',
    info = 'Obtained via smelting iron ore in a furnace',
    id = 15,
    sprite_id = 448,
    belt_id = 299,
    color_key = 1,
    type = 'intermediate',
    craftable = false,
    stack_size = 50,
    smelted_id = 27,
    required_tech = 4,
    smelting_time = 5 * 60,
    recipe = false,
  },
  [16] = {
    name = 'copper_plate',
    fancy_name = 'Copper Plate',
    info = 'Obtained via smelting copper ore in a furnace',
    id = 16,
    sprite_id = 449,
    belt_id = 300,
    color_key = 1,
    type = 'intermediate',
    craftable = false,
    stack_size = 50,
    smelting_time = 10,
    recipe = false,
  },
  [17] = {
    name = 'stone_brick',
    fancy_name = 'Stone Brick',
    info = 'Obtained via smelting stone ore in a furnace',
    id = 17,
    sprite_id = 450,
    belt_id = 282,
    color_key = 1,
    type = 'intermediate',
    craftable = false,
    stack_size = 50,
    smelting_time = 10,
    recipe = false,
  },
  [18] = {
    name = 'underground_belt',
    fancy_name = 'Underground Belt',
    id = 18,
    sprite_id = 301,
    belt_id = 279,
    color_key = 0,
    type = 'placeable',
    craftable = {'player', 'machine'},
    stack_size = 50,
    recipe = {
      id = 18,
      crafting_time = 60*1,
      count = 2,
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
    id = 21,
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
    id = 22,
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
    id = 23,
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
    id = 24,
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
    info = 'Crafed in a Bio Refinery',
    id = 25,
    sprite_id = 462,
    belt_id = 446,
    color_key = 0,
    type = 'oil',
    craftable = {'machine'},
    sub_type = 'craftable',
    stack_size = 50,
    recipe = {
      id = 25,
      crafting_time = 60*10,
      count = 1,
      ingredients = {
        [1] = {id = 32, count = 25},
        [2] = {id = 6, count = 5},
        [3] = {id = 8, count = 10}
      },
    }
  },
  [26] = {
    name = 'production_pack',
    fancy_name = 'Production Pack',
    id = 26,
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
        [1] = {id = 30, count = 1},
        [2] = {id = 27, count = 5},
        [3] = {id = 37, count = 1}
      },
    }
  },
  [27] = {
    name = 'steel_plate',
    fancy_name = 'Steel Plate',
    info = 'Obtained via smelting 2x iron plates in a furnace',
    id = 27,
    sprite_id = 468,
    belt_id = 469,
    color_key = 1,
    type = 'intermediate',
    craftable = false,
    stack_size = 50,
    smelting_time = 30,
    recipe = false,
  },
  [28] = {
    name = 'wood',
    fancy_name = 'Wood Planks',
    info = 'Obtained via chopping trees in the wild',
    id = 28,
    sprite_id = 451,
    belt_id = 467,
    color_key = 0,
    type = 'fuel',
    craftable = false,
    stack_size = 100,
    fuel_time = 1 * 2 * 60,
    recipe = false
  },
  [29] = {
    name = 'solar_panel',
    fancy_name = 'Solar Panel',
    id = 29,
    sprite_id = 510,
    belt_id = 493,
    color_key = 1,
    type = 'placeable',
    craftable = true,
    stack_size = 50,
    recipe = {
      id = 29,
      crafting_time = 4.5 * 60,
      count = 1,
      ingredients = {
        [1] = {id = 16, count = 5},
        [2] = {id = 2, count = 15},
        [3] = {id = 27, count = 5},
      },
    }
  },
  [30] = {
    name = 'bio_refinery',
    fancy_name = 'Bio-Refinery',
    id = 30,
    sprite_id = 374,
    belt_id = 390,
    color_key = 1,
    type = 'placeable',
    craftable = true,
    stack_size = 10,
    recipe = {
      id = 30,
      crafting_time = 10 * 60,
      count = 1,
      ingredients = {
        [1] = {id = 16, count = 5},
        [2] = {id = 2, count = 15},
        [3] = {id = 27, count = 5},
      },
    }
  },
  [31] = {
    name = 'engine_unit',
    fancy_name = 'Biofuel Engine',
    id = 31,
    sprite_id = 483,
    belt_id = 484,
    color_key = 1,
    type = 'intermediate',
    craftable = false,
    stack_size = 5,
    recipe = {
      id = 31,
      crafting_time = 10 * 60,
      count = 1,
      ingredients = {
        [1] = {id = 20, count = 3},
        [2] = {id = 27, count = 2},
        [3] = {id = 2, count = 1},
      },
    }
  },
  [32] = {
    name = 'fiber',
    fancy_name = 'Organic Fibers',
    info = 'Acquired via laser mining or made in Bio Refinery',
    id = 32,
    sprite_id = 268,
    belt_id = 269,
    color_key = 0,
    type = 'oil',
    craftable = false,
    stack_size = 200,
    recipe = {
      id = 32,
      crafting_time = 60 * 3,
      count = 50,
      ingredients = {
        [1] = {id = 28, count = 10},
      },
    },
  },
  [33] = {
    name = 'chest',
    fancy_name = 'Storage Chest',
    id = 33,
    sprite_id = 464,
    belt_id = 470,
    color_key = 0,
    type = 'placeable',
    craftable = true,
    stack_size = 50,
    recipe = {
      id = 33,
      crafting_time = 60 * 3,
      count = 1,
      ingredients = {
        [1] = {id = 28, count = 10},
      },
    },
  },
  [34] = {
    name = 'laser_mining_speed',
    fancy_name = 'Laser Mining 1 Upgrade',
    info = 'Increases mining speed by 150%',
    id = 34,
    sprite_id = 358,
    belt_id = -1,
    color_key = 1,
    type = 'upgrade',
    craftable = false,
    recipe = false,
  },
  [35] = {
    name = 'biofuel',
    fancy_name = 'Solid Biofuel',
    info = 'Crafed in a Bio Refinery',
    id = 35,
    sprite_id = 482,
    belt_id = 481,
    color_key = 6,
    type = 'oil',
    craftable = false,
    stack_size = 20,
    recipe = {
      id = 35,
      crafting_time = 60 * 3,
      count = 5,
      ingredients = {
        [1] = {id = 6, count = 1},
        [2] = {id = 8, count = 5},
        [3] = {id = 32, count = 10},
      },
    },
  },
  [36] = {
    name = 'plastic_bar',
    fancy_name = 'Plastic Bar',
    info = 'Crafed in a Bio Refinery',
    id = 36,
    sprite_id = 455,
    belt_id = 471,
    color_key = 1,
    type = 'oil',
    craftable = false,
    stack_size = 100,
    recipe = {
      id = 36,
      crafting_time = 10,
      count = 2,
      ingredients = {
        [1] = {id = 6, count = 1},
        [2] = {id = 8, count = 5},
        [3] = {id = 32, count = 10},
      },
    },
  },
  [37] = {
    name = 'processing_unit',
    fancy_name = 'Plastic Bar',
    info = 'Crafed in a Bio Refinery',
    id = 36,
    sprite_id = 458,
    belt_id = 295,
    color_key = 1,
    type = 'oil',
    craftable = false,
    stack_size = 100,
    recipe = {
      id = 37,
      crafting_time = 10,
      count = 2,
      ingredients = {
        [1] = {id = 2, count = 10},
        [2] = {id = 1, count = 10},
        [3] = {id = 35, count = 10},
      },
    },
  },
  [38] = {
    name = 'laser_mining_speed2',
    fancy_name = 'Laser Mining 2 Upgrade',
    info = 'Increases mining speed by +150%',
    id = 38,
    sprite_id = 359,
    belt_id = -1,
    color_key = 1,
    type = 'upgrade',
    craftable = false,
    recipe = false,
  },
  [39] = {
    name = 'laser_mining_speed3',
    fancy_name = 'Laser Mining 3 Upgrade',
    info = 'Increases mining speed by +150%',
    id = 39,
    sprite_id = 359,
    belt_id = -1,
    color_key = 1,
    type = 'upgrade',
    craftable = false,
    recipe = false,
  },
}