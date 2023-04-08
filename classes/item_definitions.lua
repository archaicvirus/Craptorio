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
    sprite_id = 256,
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
    sprite_id = 256,
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