--callbacks for placeable items, (belts, inserters, splitters, etc) ex: click/dragging while holding item stack
--main cursor/input function needs to check for ents under cursor FIRST, for quick-depositing held items
--as some placeable items are also accepted as input items in other ents (ex: assembly machines)
--else run callback for held item here, giving mouse coords as parameters
place_item = {
  ['transport_belt'] = function(x, y)
    local screen_tile_x, screen_tile_y = get_screen_cell(x, y)
    local screen_x, screen_y = get_screen_cell(x, y)
    local tile, wx, wy = get_world_cell(x, y)
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
    local child = SPLITTER_ROTATION_MAP[cursor.rot]
    local tile, wx, wy = get_world_cell(x, y)
    wx, wy = wx + child.x, wy + child.y
    local tile2, cell_x, cell_y = get_world_cell(x, y)
    local key1 = get_key(x, y)
    local key2 = wx .. '-' .. wy
    if not ENTS[key1] and not ENTS[key2] then
      local splitr = new_splitter(cell_x, cell_y, cursor.rot)
      splitr.other_key = key2
      ENTS[key1] = splitr
      ENTS[key2] = {type = 'dummy_splitter', other_key = key1, rot = cursor.rot}
      ENTS[key1]:set_output()
      sound('place_belt')
    else
      sound('deny')
    end
    --add_splitter(x, y)
  end,

  ['inserter'] = function(x, y)
    local k = get_key(x, y)
    local tile, cell_x, cell_y = get_world_cell(x, y)
    if ENTS[k] and ENTS[k].type == 'inserter' then
      if ENTS[k].rot ~= rotation then
        ENTS[k]:rotate(rotation)
        sound('rotate')
      end
    elseif not ENTS[k] then
      ENTS[k] = new_inserter({x = cell_x, y = cell_y}, rotation)
      sound('place_belt')
    else
      sound('deny')
    end
    --add_inserter(x, y, cursor.rot)
  end,

  ['power_pole'] = function(x, y)
    local k = get_key(x,y)
    local tile, cell_x, cell_y = get_world_cell(x, y)
    if not ENTS[k] then
      ENTS[k] = new_pole({x = cell_x, y = cell_y})
      sound('place_belt')
    else
      sound('deny')
    end
    --add_pole(x, y)
  end,

  ['mining_drill'] = function(x, y)
    local k = get_key(x, y)
    local found_ores = {}
    local field_keys = {}
    --local sx, sy = get_screen_cell(x, y)
    for i = 1, 4 do
      local pos = DRILL_AREA_MAP_BURNER[i]
      local sx, sy = cursor.tx + (pos.x * 8), cursor.ty + (pos.y * 8)
      local tile, wx, wy = get_world_cell(sx, sy)
      local k = get_key(sx, sy)
      field_keys[i] = k
      if tile.ore then
        table.insert(found_ores, i)
  
        if not ORES[k] then
          local ore = {
            type = ores[tile.ore].name,
            tile_id = ores[tile.ore].tile_id,
            sprite_id = ores[tile.ore].sprite_id,
            id = ores[tile.ore].id,
            ore_remaining = 100,
            wx = wx,
            wy = wy,
          }
          ORES[k] = ore
        end
      end
      if ENTS[k] or (i == 4 and #found_ores == 0) then
        sound('deny')
        return
      end
    end
  
    if not ENTS[k] then
      local tile, wx, wy = get_world_cell(x, y)
      sound('place_belt')
      --trace('creating drill @ ' .. key)
      ENTS[k] = new_drill({x = wx, y = wy}, cursor.rot, field_keys)
      ENTS[wx + 1 .. '-' .. wy] = {type = 'dummy_drill', other_key = k}
      ENTS[wx + 1 .. '-' .. wy + 1] = {type = 'dummy_drill', other_key = k}
      ENTS[wx .. '-' .. wy + 1] = {type = 'dummy_drill', other_key = k}
    elseif ENTS[k] and ENTS[k].type == 'mining_drill' then
      sound('place_belt')
      sound('rotate')
      --ENTS[k].rot = cursor.rot
    end
    --add_drill(x, y)
  end,

  ['stone_furnace'] = function(x, y)
    local key1 = get_key(x, y)
    local key2 = get_key(x + 8, y)
    local key3 = get_key(x + 8, y + 8)
    local key4 = get_key(x, y + 8)
    if not ENTS[key1] and not ENTS[key2] and not ENTS[key3] and not ENTS[key4] then
      local wx, wy = screen_to_world(x, y)
      ENTS[key1] = new_furnace(wx, wy, {key2, key3, key4})
      ENTS[key2] = {type = 'dummy_furnace', other_key = key1}
      ENTS[key3] = {type = 'dummy_furnace', other_key = key1}
      ENTS[key4] = {type = 'dummy_furnace', other_key = key1}
      sound('place_belt')
    end
    --add_furnace(x, y)
  end,
  
  ['underground_belt'] = function(x, y)
    local tile, wx, wy = get_world_cell(x, y)
    local k = wx .. '-' .. wy
    if not ENTS[k] then
      local result, other_key, cells = get_ubelt_connection(x, y, cursor.rot)
      --found suitable connection
      --don't create a new ENT, use the found ubelt as the 'host', and update it with US as it's output
      if result then
        ENTS[k] = {type = 'underground_belt_exit', flip = UBELT_ROT_MAP[cursor.rot].out_flip, rot = cursor.rot, x = wx, y = wy, other_key = other_key}
        ENTS[other_key]:connect(wx, wy, #cells - 1)
        sound('place_belt')
      else
        ENTS[k] = new_underground_belt(wx, wy, cursor.rot)
      end
      sound('place_belt')
    else
      sound('deny')
    end
  end,

  ['assembly_machine'] = function(x, y)
    local tile, wx, wy = get_world_cell(x, y)
    local k = wx .. '-' .. wy
    if not ENTS[k] then
      --check 3x3 area for ents
      for i = 0, 2 do
        for j = 0, 2 do
          if ENTS[wx + j .. '-' .. i + wy] then 
            sound('deny')
            return
          end
        end
      end
      --else place dummy ents to reserve 3x3 tile area, and create the crafter
      for i = 0, 2 do
        for j = 0, 2 do
          ENTS[wx + j .. '-' .. i + wy] = {type = 'dummy_assembler', other_key = k}
        end
      end
      sound('place_belt')
      ENTS[k] = new_assembly_machine(wx, wy)
    else
      sound('deny')
    end
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

remove_item = {
  ['transport_belt'] = function(x, y)
    local k = get_key(x, y)
    local tile, cell_x, cell_y = get_world_cell(x, y)
    if not ENTS[k] then return end
    if ENTS[k] and ENTS[k].type == 'transport_belt' then
      sound('delete')
      ENTS[k] = nil
    end
    local tiles = {
      [1] = {x = cell_x, y = cell_y - 1},
      [2] = {x = cell_x + 1, y = cell_y},
      [3] = {x = cell_x, y = cell_y + 1},
      [4] = {x = cell_x - 1, y = cell_y}}
    for i = 1, 4 do
      local k = tiles[i].x .. '-' .. tiles[i].y
      if ENTS[k] and ENTS[k].type == 'transport_belt' then
        ENTS[k]:set_curved()
      end
    end
  end,

  ['splitter'] = function(x, y)
    local k = get_key(x, y)
    if not ENTS[k] then return end
    if ENTS[k].type == 'dummy_splitter' then k = ENTS[k].other_key end
    if ENTS[k] and ENTS[k].type == 'splitter' then    
      local key_l, key_r = ENTS[k].output_key_l, ENTS[k].output_key_r
      local key2 = ENTS[k].other_key
      ENTS[k] = nil
      ENTS[key2] = nil
      if ENTS[key_l] and ENTS[key_l].type == 'transport_belt' then ENTS[key_l]:update_neighbors(k) end
      if ENTS[key_r] and ENTS[key_r].type == 'transport_belt' then ENTS[key_r]:update_neighbors(k) end
      sound('delete')
    end
  end,

  ['inserter'] = function(x, y)
    local k = get_key(x, y)
    if not ENTS[k] then return end
    if ENTS[k] and ENTS[k].type == 'inserter' then
      ENTS[k] = nil
      sound('delete')
    end
  end,

  ['power_pole'] = function(x, y)
    local k = get_key(x, y)
    if not ENTS[k] then return end
    if ENTS[k] and ENTS[k].type == 'power_pole' then
      ENTS[k] = nil
      sound('delete')
    end
  end,

  ['mining_drill'] = function(x, y)
    local k = get_key(x, y)
    local _, wx, wy = get_world_cell(x, y)
    local _, wx, wy = get_world_cell(x, y)
    if ENTS[k].type == 'dummy_drill' then
      k = ENTS[k].other_key
    end
    if ENTS[k] then
      local wx, wy = ENTS[k].pos.x, ENTS[k].pos.y
      ENTS[k] = nil
      ENTS[wx + 1 .. '-' .. wy] = nil
      ENTS[wx + 1 .. '-' .. wy + 1] = nil
      ENTS[wx .. '-' .. wy + 1] = nil
      sound('delete')
    end
  end,

  ['stone_furnace'] = function(x, y)
    local k = get_key(x, y)
    if ENTS[k] then
      if ENTS[k].type == 'dummy_furnace' then
        k = ENTS[k].other_key
      end
      for k, v in ipairs(ENTS[k].dummy_keys) do
        ENTS[v] = nil
      end
      ENTS[k] = nil
      sound('delete')
    end
  end,

  ['underground_belt'] = function(x, y)
    local k = get_ent(x, y)
    if ENTS[k] then
      --return underground items if any
      --remove hidden belts, since we removed the head
      if ENTS[ENTS[k].other_key] then ENTS[ENTS[k].other_key] = nil end
      if ENTS[k].type == 'underground_belt_exit' then ENTS[ENTS[k].exit_key] = nil end
      ENTS[k] = nil
      sound('delete')
    end
  end,

  ['assembly_machine'] = function(x, y)
    local tile, wx, wy = get_world_cell(x, y)
    local k = wx .. '-' .. wy
    if ENTS[k].other_key then
      k = ENTS[k].other_key
      wx, wy = ENTS[k].x, ENTS[k].y
    end
    if ENTS[k] and ENTS[k].type == 'assembly_machine' then
      for i = 0, 2 do
        for j = 0, 2 do
          ENTS[wx + j .. '-' .. i + wy] = nil
        end
      end
      ENTS[k] = nil
      sound('delete')
    end
  end,

  ['research_lab'] = function(x, y)
    local tile, wx, wy = get_world_cell(x, y)
    local k = wx .. '-' .. wy
    if not ENTS[k] then return end
    if ENTS[k].type == 'dummy_lab' then
      k = ENTS[k].other_key
    end
  
    if ui.active_window and ui.active_window.ent_key == k then ui.active_window = nil end
    local keys = ENTS[k].dummy_keys
    for dk, v in ipairs(keys) do
      ENTS[v] = nil
      sound('delete')
    end
  end,
}