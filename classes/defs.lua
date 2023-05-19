ores = {
  [1] = {
    name = 'Iron',
    offset = 15000,
    id = 3,
    scale = 0.011,
    min = 15,
    max = 16,
    bmin = 45,
    bmax = 100,
    color_keys = 4,
    tile_id = 162,
    sprite_id = 178,
    biome_id = 2,
    map_cols = {8,11,12,13,14,15},
  },
  [2] = {
    name = 'Copper',
    offset = 10000,
    id = 4,
    scale = 0.013,
    min = 15,
    max = 16,
    bmin = 33,
    bmax = 40,
    color_keys = 1,
    tile_id = 161,
    sprite_id = 177,
    biome_id = 2,
    map_cols = {2,3,4,15},
  },
  [3] = {
    name = 'Coal',
    offset = 50000,
    id = 6,
    scale = 0.020,
    min = 14,
    max = 17,
    bmin = 35,
    bmax = 75,
    color_keys = 4,
    tile_id = 163,
    sprite_id = 179,
    biome_id = 3,
    map_cols = {0,14,15},
  },
  [4] = {
    name = 'Stone',
    offset = 22500,
    id = 5,
    scale = 0.018,
    min = 15,
    max = 16,
    bmin = 20,
    bmax = 70,
    color_keys = 4,
    tile_id = 160,
    sprite_id = 176,
    biome_id = 1,
    map_cols = {12,13,14,15},
  },
  [5] = {
    name = 'Oil Shale',
    offset = 37994,
    id = 8,
    scale = 0.019,
    min = 15,
    max = 16,
    bmin = 22,
    bmax = 29,
    color_keys = 4,
    tile_id = 165,
    sprite_id = 181,
    map_cols = {0,1,15},
  },
  [6] = {
    name = 'Uranium',
    offset = 76500,
    id = 7,
    scale = 0.022,
    min = 15,
    max = 16,
    bmin = 65,
    bmax = 70,
    color_keys = 4,
    tile_id = 164,
    sprite_id = 180,
    map_cols = {5,6,7,15},
  },
}

biomes = {
  [1] = {
    name = 'Desert',
    tile_id_offset = 0,
    min = 20,
    max = 30,
    t_min = 21,
    t_max = 25,
    tree_id = 198,
    tree_density = 0.05,
    color_key = 4,
    map_col = 4,
    clutter = 0.05
  },
  [2] = {
    name = 'Prarie',
    tile_id_offset = 16,
    min = 30,
    max = 45,
    t_min = 33,
    t_max = 40,
    tree_id = 201,
    tree_density = 0.175,
    color_key = 4,
    map_col = 6,
    clutter = 0.25
  },
  [3] = {
    name = 'Forest',
    tile_id_offset = 32,
    min = 45,
    max = 101,
    t_min = 47,
    t_max = 99,
    tree_id = 198,
    tree_density = 0.20,
    color_key = 4,
    map_col = 7,
    clutter = 0.05
  },
}

auto_map = {
  --N E S W
  --tiles surrounding land
  --0 is land, 1 is water or other biome

  ['1000'] = {sprite_id = 1, rot = 0},
  ['0100'] = {sprite_id = 1, rot = 1},
  ['0010'] = {sprite_id = 1, rot = 2},
  ['0001'] = {sprite_id = 1, rot = 3},

  ['1100'] = {sprite_id = 2, rot = 1},
  ['0110'] = {sprite_id = 2, rot = 2},
  ['0011'] = {sprite_id = 2, rot = 3},
  ['1001'] = {sprite_id = 2, rot = 0},

  ['1101'] = {sprite_id = 3, rot = 0},
  ['1110'] = {sprite_id = 3, rot = 1},
  ['0111'] = {sprite_id = 3, rot = 2},
  ['1011'] = {sprite_id = 3, rot = 3},
  ['0101'] = {sprite_id = 4, rot = 0},
  ['1010'] = {sprite_id = 4, rot = 1},
  ['1111'] = {sprite_id = 0, rot = 0},
}


--callbacks for placeable items, (belts, inserters, splitters, etc) ex: click/dragging while holding item stack
--main cursor/input function needs to check for ents under cursor FIRST, for quick-depositing held items
--as some placeable items are also accepted as input items in other ents (ex: assembly machines)
--else run callback for held item here, giving mouse coords as parameters
local defs = {

  callbacks = {
    ['transport_belt'] = function(x, y)
      if is_water(x, y) then return end
      local screen_tile_x, screen_tile_y = get_screen_cell(x, y)
      local screen_x, screen_y = get_screen_cell(x, y)
      local tile, wx, wy = get_world_cell(x, y)
      local key = wx .. '-' .. wy
      if not cursor.drag and cursor.left and cursor.last_left then
        --drag locking/placing belts
        cursor.drag = true

        cursor.drag_loc = {x = wx, y = wy}
        cursor.drag_dir = cursor.rot
      end
    
      if cursor.drag then
        local dx, dy = world_to_screen(cursor.drag_loc.x, cursor.drag_loc.y)
        if (cursor.drag_dir == 0 or cursor.drag_dir == 2) then
          -- trace('tile_x: ' .. screen_x)
          -- trace('tile_y: ' .. screen_y)
          -- trace('last_tile_x: ' .. cursor.last_tile_x)
          --trace('last_tile_y: ' .. cursor.last_tile_y)
          add_belt(x, dy, cursor.drag_dir)
        elseif (cursor.drag_dir == 1 or cursor.drag_dir == 3) then
          add_belt(dx, y, cursor.drag_dir)
          -- trace('tile_x: ' .. screen_x)
          -- trace('tile_y: ' .. screen_y)
          -- trace('last_tile_x: ' .. cursor.last_tile_x)
          -- trace('last_tile_y: ' .. cursor.last_tile_y)
        end
      end
    end,

    ['splitter'] = function(x, y)
      if is_water(x, y) then return end
      add_splitter(x, y)
    end,

    ['inserter'] = function(x, y)
      if is_water(x, y) then return end
      add_inserter(x, y, cursor.rot)
    end,

    ['power_pole'] = function(x, y)
      if is_water(x, y) then return end
      add_pole(x, y)
    end,

    ['mining_drill'] = function(x, y)
      if is_water(x, y) then return end
      add_drill(x, y)
    end,

    ['stone_furnace'] = function(x, y)
      add_furnace(x, y)
    end,
    ['underground_belt'] = function(x, y)
      add_underground_belt(x, y)
    end,
  },
}

return defs