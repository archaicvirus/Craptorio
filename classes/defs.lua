ores = {
  [1] = {
    name = 'water',
    offset = 37994,
    id = 15,
    scale = 0.011,
    min = 13,
    max = 16,
    color_keys = 4,
    tile_id = 15,
    sprite_id = 58,
  },
  [2] = {
    name = 'iron',
    offset = 15000,
    id = 38,
    scale = 0.011,
    min = 14,
    max = 16,
    color_keys = 4,
    tile_id = 38,
    sprite_id = 55,
  },
  [3] = {
    name = 'copper',
    offset = 10000,
    id = 37,
    scale = 0.013,
    min = 15,
    max = 16,
    color_keys = 4,
    tile_id = 37,
    sprite_id = 54,
  },
  [4] = {
    name = 'coal',
    offset = 50000,
    id = 39,
    scale = 0.018,
    min = 14,
    max = 16,
    color_keys = 4,
    tile_id = 39,
    sprite_id = 56,
  },
  [5] = {
    name = 'stone',
    offset = 22500,
    id = 36,
    scale = 0.018,
    min = 14,
    max = 16,
    color_keys = 4,
    tile_id = 36,
    sprite_id = 53,
  },
  [6] = {
    name = 'oil_shale',
    offset = 37994,
    id = 41,
    scale = 0.019,
    min = 14,
    max = 16,
    color_keys = 4,
    tile_id = 41,
    sprite_id = 58,
  },
  [7] = {
    name = 'uranium',
    offset = 76500,
    id = 40,
    scale = 0.022,
    min = 15,
    max = 16,
    color_keys = 4,
    tile_id = 40,
    sprite_id = 57,
  },
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
    end
  },
}

return defs