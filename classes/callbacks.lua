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