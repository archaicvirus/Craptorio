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
    tree_id = 201,
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
callbacks = {
  ['transport_belt'] = function(x, y)
    local screen_tile_x, screen_tile_y = get_screen_cell(x, y)
    local screen_x, screen_y = get_screen_cell(x, y)
    local tile, wx, wy = get_world_cell(x, y)
    if not tile.is_land then sound('deny') return end
    local key = wx .. '-' .. wy
    if not cursor.drag and cursor.l and cursor.ll then
      --drag locking/placing belts
      cursor.drag = true

      cursor.drag_loc = {x = wx, y = wy}
      cursor.drag_dir = cursor.rot
    end
  
    local dx, dy = world_to_screen(cursor.drag_loc.x, cursor.drag_loc.y)
    local rot, place = cursor.drag_dir, false
    if cursor.drag then
      if (cursor.drag_dir == 0 or cursor.drag_dir == 2) then
        dx, dy, rot, place = x, dy, cursor.drag_dir, true
        --add_belt(x, dy, cursor.drag_dir)
      elseif (cursor.drag_dir == 1 or cursor.drag_dir == 3) then
        dx, dy, rot, place = dx, y, cursor.drag_dir, true
        --add_belt(dx, y, cursor.drag_dir)
      end
    elseif cursor.l and not cursor.ll then
      dx, dy, rot, place = x, y, cursor.rot, true
      --add_belt(x, y, cursor.rot)
    end
    --add belt--
    if place then
      local tile, cell_x, cell_y = get_world_cell(dx, dy)
      local k = cell_x .. '-' .. cell_y
      local belt = {}
      if ENTS[k] and ENTS[k].type ~= 'transport_belt' then
        sound('deny')
        return
      end

      if not ENTS[k] then
        ENTS[k] = new_belt({x = cell_x, y = cell_y}, rot)
        ENTS[k]:rotate(rot)
        ENTS[k]:update_neighbors()
        sound('place_belt')
      elseif ENTS[k] and ENTS[k].type == 'transport_belt' and ENTS[k].rot ~= rot then
        ENTS[k]:rotate(rot)
        sound('rotate')
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

  ['assembly_machine'] = function(x, y)
    add_assembly_machine(x, y)
  end,

  ['research_lab'] = function(x, y)
    local tile, wx, wy = get_world_cell(x, y)
    local k = wx .. '-' ..wy
    if tile.is_land and not ENTS[k] then
      for i = 0, 2 do
        for j = 0, 2 do
          if ENTS[wx + j .. '-' .. i + wy] then 
            sound('deny')
            return
          end
        end      
    end
      --else place dummy ents to reserve 3x3 tile area, and create the crafter
    local dummy_keys = {k}
    for i = 0, 2 do
      for j = 0, 2 do
        local dk = wx + j .. '-' .. i + wy
        ENTS[dk] = {type = 'dummy_lab', other_key = k}
        table.insert(dummy_keys, dk)
      end
    end
    sound('place_belt')
    ENTS[k] = new_lab(wx, wy, dummy_keys)
    end
  end,
}
--Item entry Template
-- [] = {
--  name = '',
--  fancy_name = '',
--  id = ,
--  sprite_id = ,
--  belt_id = ,
--  color_key = 0,
--  type = '',
--  sub_type = '',
--  stack_size = ,
--  recipe = {
--  id = 20,
--  crafting_time = 120,
--  count = 1,
--  ingredients = {
--    [1] = {id = 15, count = 2}
--  }
-- }

----ITEMS----
-- 3  = 'iron_ore'
-- 4  = 'copper_ore'
-- 6  = 'coal_ore'
-- 5  = 'stone_ore'
-- 8  = 'oil_shale'
-- 7  = 'uranium'
-- 0  = 'raw_wood'
-- 15 = 'iron_plate'
-- 20 = 'gear'
-- 16 = 'copper_plate'
-- 21 = 'copper_cable'
-- 17 = 'stone_brick'
-- 0  = 'plastic_bar'
-- 0  = 'iron_stick'
-- 14 = 'stone_furnace'
-- 13 = 'mining_drill'
-- 9  = 'transport_belt'
-- 18 = 'underground_belt'
-- 10 = 'splitter'
-- 11 = 'inserter'
-- 2  = 'electronic_circuit'
-- 1  = 'advanced_circuit'
-- 0  = 'processing_unit'
-- 12 = 'power_pole'
-- 19 = 'assembly_machine'
-- 0  = 'wooden_chest'
-- 0  = 'iron_chest'
-- 0  = 'steel_chest'
-- 0  = 'lab'
-- 0  = ''
-- 0  = ''
-- 0  = ''
-- 0  = ''
-- 0  = ''
-- 0  = ''
-- 0  = ''