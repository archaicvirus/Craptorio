--callbacks for placeable items, (belts, inserters, splitters, etc) ex: click/dragging while holding item stack
--main cursor/input function needs to check for ents under cursor FIRST, for quick-depositing held items
--as some placeable items are also accepted as input items in other ents (ex: assembly machines)
--else run callback for held item here, giving mouse coords as parameters

callbacks = {
  ['transport_belt'] = {
    place_item = function(x, y)
      local tile, wx, wy = get_world_cell(x, y)
      if not tile.is_land then
        sound('deny')
        return false
      end
      local key = wx .. '-' .. wy
      if not cursor.drag and cursor.l and cursor.ll then
        --drag locking/placing belts
        cursor.drag = true

        cursor.drag_loc = {x = wx, y = wy}
        cursor.drag_dir = cursor.rot
      elseif not cursor.l then
        cursor.drag = false
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
          return false
        end

        if not ENTS[k] then
          ENTS[k] = new_belt({x = cell_x, y = cell_y}, rot)
          ENTS[k]:rotate(rot)
          ENTS[k]:update_neighbors()
          sound('place_belt')
          return true
        elseif ENTS[k] and ENTS[k].type == 'transport_belt' and ENTS[k].rot ~= cursor.rot then
          ENTS[k]:rotate(cursor.rot)
          ENTS[k]:update_neighbors()
          sound('rotate_r')
          return false
        end
      end
      return false
    end,
    remove_item = function(x, y)
      local k = get_key(x, y)
      local tile, cell_x, cell_y = get_world_cell(x, y)
      if not ENTS[k] then return end
      if ENTS[k] and ENTS[k].type == 'transport_belt' then
        sound('delete')
        --ENTS[k]:return_all()
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
    draw_item = function(x, y)
      if cursor.drag then
        local sx, sy = world_to_screen(cursor.drag_loc.x, cursor.drag_loc.y)
        if cursor.drag_dir == 0 or cursor.drag_dir == 2 then
          ui.highlight(cursor.tx-2, sy-2, 10, 10, false, 3, 4)
          --sspr(CURSOR_HIGHLIGHT, cursor.tx - 1, sy - 1, 0, 1, 0, 0, 2, 2)
        else
          ui.highlight(sx - 2, cursor.ty-2, 10, 10, false, 3, 4)
          --sspr(CURSOR_HIGHLIGHT, sx - 1, cursor.ty - 1, 0, 1, 0, 0, 2, 2)
        end
        --arrow to indicate drag direction
        sspr(BELT_ARROW_ID, cursor.tx, cursor.ty, 0, 1, 0, cursor.drag_dir, 1, 1)
      elseif not ENTS[k] or (ENTS[k] and ENTS[k].type == 'transport_belt' and ENTS[k].rot ~= cursor.rot) then
        sspr(BELT_ID_STRAIGHT + BELT_TICK, cursor.tx, cursor.ty, BELT_COLORKEY, 1, 0, cursor.rot, 1, 1)
        ui.highlight(cursor.tx-1, cursor.ty-1, 8, 8, false, 3, 4)
        --sspr(CURSOR_HIGHLIGHT, cursor.tx - 1, cursor.ty - 1, 0, 1, 0, 0, 2, 2)
      else
        ui.highlight(cursor.tx-1, cursor.ty-1, 8, 8, false, 3, 4)
        --sspr(CURSOR_HIGHLIGHT, cursor.tx - 1, cursor.ty - 1, 0, 1, 0, 0, 2, 2)
      end
    end
  },
  ['splitter'] = {
    place_item = function(x, y)
      local child = SPLITTER_ROTATION_MAP[cursor.rot]
      local tile, wx, wy = get_world_cell(x, y)
      if not tile.is_land then
        sound('deny')
        return
      end
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
        return true
      else
        sound('deny')
      end
      return false
      --add_splitter(x, y)
    end,
    remove_item = function(x, y)
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
    draw_item = function(x, y)
      local loc = SPLITTER_ROTATION_MAP[cursor.rot]
      local tile, wx, wy = get_world_cell(x, y)
      wx, wy = wx + loc.x, wy + loc.y
      local tile2, cell_x, cell_y = get_world_cell(x, y)
      local sx, sy = get_screen_cell(x, y)
      local key1 = get_key(x, y)
      local key2 = wx .. '-' .. wy
      local x, y, w, h, col1, col2 = sx-1, sy-1, 16, 8, 5, 7
      local ox, oy = 0, 8
      if cursor.rot == 0 or cursor.rot == 2 then
        w, h = h, w
      else
        ox, oy = 8, 0
      end
      if ENTS[key1] or ENTS[key2] then col1, col2 = 2, 2 end
      ui.highlight(x, y, w, h, false, col1, col2)
      sspr(BELT_ID_STRAIGHT + BELT_TICK, sx, sy, -1, 1, 0, cursor.rot)
      sspr(BELT_ID_STRAIGHT + BELT_TICK, sx + ox, sy + oy, -1, 1, 0, cursor.rot)
      sspr(SPLITTER_ID, sx, sy, 0, 1, 0, cursor.rot, 1, 2)
    end
  },
  ['inserter'] = {
    place_item = function(x, y)
      local k = get_key(x, y)
      local tile, cell_x, cell_y = get_world_cell(x, y)
      if not tile.is_land then
        sound('deny')
        return
      end
      if ENTS[k] and ENTS[k].type == 'inserter' then
        if ENTS[k].rot ~= cursor.rot then
          ENTS[k]:rotate(rotation)
          sound('rotate_r')
        end
      elseif not ENTS[k] then
        ENTS[k] = new_inserter({x = cell_x, y = cell_y}, cursor.rot)
        sound('place_belt')
        return true
      else
        sound('deny')
      end
      return false
      --add_inserter(x, y, cursor.rot)
    end,
    remove_item = function(x, y)
      local k = get_key(x, y)
      if not ENTS[k] then return end
      if ENTS[k] and ENTS[k].type == 'inserter' then
        if ENTS[k].held_item_id > 0 then
          if inv:add_item({id = ENTS[k].held_item_id, count = 1}) == true then
            sound('deposit')
            ui.new_alert(cursor.x, cursor.y, '+ ' .. 1 .. ' ' .. ITEMS[ENTS[k].held_item_id].fancy_name, 1000, 0, 6)
          end
        end
        ENTS[k] = nil
        sound('delete')
      end
    end,
    draw_item = function(x, y)
      local tile, world_x, world_y = get_world_cell(x, y)
      local temp_inserter = new_inserter({x = world_x, y = world_y}, cursor.rot)
      local k = get_key(x, y)
      temp_inserter:draw()
      if not ENTS[k] or (ENTS[k].type == 'inserter' and ENTS[k].rot ~= cursor.rot) then
        ui.highlight(cursor.tx-1, cursor.ty-1, 8, 8, false, 5, 6)
        --sspr(CURSOR_HIGHLIGHT, cursor.tx - 1, cursor.ty - 1, 0, 1, 0, 0, 2, 2)
      else
        ui.highlight(cursor.tx-1, cursor.ty-1, 8, 8, false, 2, 2)
      end
      --sspr(CURSOR_HIGHLIGHT, cursor.tx - 1, cursor.ty - 1, 0, 1, 0, 0, 2, 2)
    end
  },
  ['power_pole'] = {
    place_item = function(x, y)
      local k = get_key(x,y)
      local tile, cell_x, cell_y = get_world_cell(x, y)
      if not tile.is_land then
        sound('deny')
        return
      end
      if not ENTS[k] then
        ENTS[k] = new_pole({x = cell_x, y = cell_y})
        sound('place_belt')
        return true
      else
        sound('deny')
      end
      return false
      --add_pole(x, y)
    end,
    remove_item = function(x, y)
      local k = get_key(x, y)
      if not ENTS[k] then return end
      if ENTS[k] and ENTS[k].type == 'power_pole' then
        ENTS[k] = nil
        sound('delete')
      end
    end,
    draw_item = function(x, y)
      local tile, world_x, world_y = get_world_cell(cursor.tx, cursor.ty)
      local temp_pole = new_pole({x = world_x, y = world_y})
      temp_pole:draw(true)
      --check around cursor to attach temp cables to other poles
    end
  },
  ['mining_drill'] = {
    place_item = function(x, y)
      local k = get_key(x, y)
      local tile, wx, wy = get_world_cell(x, y)
      if not tile.is_land then
        sound('deny')
        return
      end
      local found_ores = {}
      local field_keys = {}
      --local sx, sy = get_screen_cell(x, y)
      for i = 1, 4 do
        local pos = DRILL_AREA_MAP_BURNER[i]
        local sx, sy = x + (pos.x * 8), y + (pos.y * 8)
        local tile, wx, wy = get_world_cell(sx, sy)
        local k = get_key(sx, sy)
        field_keys[i] = k
        if tile.ore then
          table.insert(found_ores, i)
    
          if not ORES[k] then
            local max_ore = floor(math.random(250,5000))
            local ore = {
              type = ores[tile.ore].name,
              tile_id = ores[tile.ore].tile_id,
              sprite_id = ores[tile.ore].sprite_id,
              id = ores[tile.ore].id,
              total_ore = max_ore,
              ore_remaining = max_ore,
              wx = wx,
              wy = wy,
            }
            ORES[k] = ore
          end
        end
        if ENTS[k] or (i == 4 and #found_ores == 0) then
          sound('deny')
          return false
        end
      end
    
      if not ENTS[k] then
        --local tile, wx, wy = get_world_cell(x, y)
        sound('place_belt')
        --trace('creating drill @ ' .. key)
        ENTS[k] = new_drill({x = wx, y = wy}, cursor.rot, field_keys)
        ENTS[wx + 1 .. '-' .. wy] = {type = 'dummy_drill', other_key = k}
        ENTS[wx + 1 .. '-' .. wy + 1] = {type = 'dummy_drill', other_key = k}
        ENTS[wx .. '-' .. wy + 1] = {type = 'dummy_drill', other_key = k}
        return true
      elseif ENTS[k] and ENTS[k].type == 'mining_drill' then
        sound('place_belt')
        sound('rotate_r')
        --ENTS[k].rot = cursor.rot
      end
      return false
      --add_drill(x, y)
    end,
    remove_item = function(x, y)
      local k = get_key(x, y)
      local _, wx, wy = get_world_cell(x, y)
      local _, wx, wy = get_world_cell(x, y)
      if ENTS[k].type == 'dummy_drill' then
        k = ENTS[k].other_key
      end
      if ENTS[k] then
        --ENTS[k]:return_all()
        local wx, wy = ENTS[k].pos.x, ENTS[k].pos.y
        ENTS[k] = nil
        ENTS[wx + 1 .. '-' .. wy] = nil
        ENTS[wx + 1 .. '-' .. wy + 1] = nil
        ENTS[wx .. '-' .. wy + 1] = nil
        sound('delete')
      end
    end,
    draw_item = function(x, y)
      local found_ores = {}
      local color_keys = {[1] = {0, 2, 1}, [2] = {0, 2, 1}, [3] = {0, 2, 1}, [4] = {0, 2, 1}}
      for i = 1, 4 do
        local pos = DRILL_AREA_MAP_BURNER[i]
        local sx, sy = x + (pos.x * 8), y + (pos.y * 8)
        local tile, wx, wy = get_world_cell(sx, sy)
        local k = get_key(sx, sy)
        if not tile.ore or ENTS[k] then
          color_keys[i] = {0, 5, 1}
        end
      end
      
      local sx, sy = get_screen_cell(x, y)
      local belt_pos = DRILL_MINI_BELT_MAP[cursor.rot]
      sspr(CURSOR_HIGHLIGHT_CORNER, sx - 1, sy - 1, color_keys[1], 1, 0, 0, 1, 1)
      sspr(CURSOR_HIGHLIGHT_CORNER, sx + 9, sy - 1, color_keys[2], 1, 0, 1, 1, 1)
      sspr(CURSOR_HIGHLIGHT_CORNER, sx + 9, sy + 9, color_keys[3], 1, 0, 2, 1, 1)
      sspr(CURSOR_HIGHLIGHT_CORNER, sx - 1, sy + 9, color_keys[4], 1, 0, 3, 1, 1)
      sspr(DRILL_BIT_ID, sx + 0 + (DRILL_BIT_TICK), sy + 5, 0, 1, 0, 0, 1, 1)
      sspr(DRILL_BURNER_SPRITE_ID, sx, sy, 0, 1, 0, 0, 2, 2)
      sspr(DRILL_MINI_BELT_ID + DRILL_ANIM_TICK, sx + belt_pos.x, sy + belt_pos.y, 0, 1, 0, cursor.rot, 1, 1)
    end
  },
  ['stone_furnace'] = {
    place_item = function(x, y)
      local k = get_key(x, y)
      local tile, wx, wy = get_world_cell(x, y)
      if not tile.is_land then
        sound('deny')
        return
      end
      local key1 = get_key(x, y)
      local key2 = get_key(x + 8, y)
      local key3 = get_key(x + 8, y + 8)
      local key4 = get_key(x, y + 8)
      if not ENTS[key1] and not ENTS[key2] and not ENTS[key3] and not ENTS[key4] then
        --local wx, wy = screen_to_world(x, y)
        ENTS[key1] = new_furnace(wx, wy, {key2, key3, key4})
        ENTS[key2] = {type = 'dummy_furnace', other_key = key1}
        ENTS[key3] = {type = 'dummy_furnace', other_key = key1}
        ENTS[key4] = {type = 'dummy_furnace', other_key = key1}
        sound('place_belt')
        return true
      end
      sound('deny')
      return false
      --add_furnace(x, y)
    end,
    remove_item = function(x, y)
      local k = get_ent(x, y)
      if ENTS[k] then
        --ENTS[k]:return_all()
        for k, v in ipairs(ENTS[k].dummy_keys) do
          ENTS[v] = nil
        end
        ENTS[k] = nil
        sound('delete')
      end
    end,
    draw_item = function(x, y)
      local sx, sy = get_screen_cell(x, y)
      sspr(FURNACE_ID, sx, sy, FURNACE_COLORKEY, 1, 0, 0, 2, 2)
    end
  },
  ['underground_belt'] = {
    place_item = function(x, y)
      local tile, wx, wy = get_world_cell(x, y)
      if not tile.is_land then
        sound('deny')
        return
      end
      local k = wx .. '-' .. wy
      if not ENTS[k] then
        local result, other_key, cells = get_ubelt_connection(x, y, cursor.rot)
        --found suitable connection
        --don't create a new ENT, use the found ubelt as the 'host', and update it with US as it's output
        if result then
          ENTS[k] = {
            type = 'underground_belt_exit',
            flip = UBELT_ROT_MAP[cursor.rot].out_flip,
            rot = cursor.rot,
            x = wx, y = wy,
            other_key = other_key,
            is_exit = true,
            item_request = function(self, desired_item, inserter)
              return ENTS[self.other_key]:item_request(desired_item, inserter, true)
            end,
            request_deposit = function(self)
              return ENTS[self.other_key]:request_deposit()
            end,
            deposit = function(self, id, other_rot)
              return ENTS[self.other_key]:deposit(id, other_rot, true)
            end,
          }
          trace(#cells - 1)
          ENTS[other_key]:connect(wx, wy, #cells - 1)
          ENTS[other_key]:update_neighbors_exit()
          sound('place_belt')
        else
          ENTS[k] = new_underground_belt(wx, wy, cursor.rot)
          ENTS[k]:update_neighbors()
        end
        sound('place_belt')
        return true
      else
        sound('deny')
      end
      return false
    end,
    remove_item = function(x, y)
      local k = get_ent(x, y)
      if ENTS[k] and ENTS[k].type == 'underground_belt' then
        --return underground items if any and
        --remove hidden belts, since we removed the head
        ENTS[k]:return_all()

        local exit = false
        local start = {x = ENTS[k].x, y = ENTS[k].y}

        if ENTS[ENTS[k].exit_key] then
          --if we have an exit ubelt
          exit = {x = ENTS[ENTS[k].exit_key].x, y = ENTS[ENTS[k].exit_key].y}
        end
        ENTS[ENTS[k].exit_key] = nil
        ENTS[k] = nil
        
        local function update(x, y)
          local cell_x, cell_y = x, y
          local tiles = {
            [1] = {x = cell_x, y = cell_y - 1},
            [2] = {x = cell_x + 1, y = cell_y},
            [3] = {x = cell_x, y = cell_y + 1},
            [4] = {x = cell_x - 1, y = cell_y}}
          for i = 1, 4 do
            local k = tiles[i].x .. '-' .. tiles[i].y
            if ENTS[k] then
              if ENTS[k].type == 'transport_belt' then ENTS[k]:set_curved() end
              if ENTS[k].type == 'splitter' then ENTS[k]:set_output() end
              if ENTS[k].type == 'dummy_splitter' then ENTS[ENTS[k].other_key]:set_output() end
              if ENTS[k].type == 'underground_belt_exit' then ENTS[ENTS[k].other_key]:set_output() end
              if ENTS[k].type == 'underground_belt' then ENTS[k]:set_output() end
            end
          end
        end

        if exit then update(exit.x, exit.y) end
        update(start.x, start.y)

        sound('delete')
      end
    end,
    draw_item = function(x, y)
      local flip = UBELT_ROT_MAP[cursor.rot].in_flip
      local result, other_key, cells = get_ubelt_connection(cursor.x, cursor.y, cursor.rot)
      -- trace('result: ' .. tostring(result))
      -- trace('other_key: ' .. tostring(other_key))
      -- trace('cells: ' .. tostring(cells))
      if result then
        local sx, sy = cursor.tx, cursor.ty
        ui.highlight(sx - 2, sy - 1, 7, 7, false, 3, 4)
        local c = UBELT_CLIP_OUT[cursor.rot]
        --rect(sx+c.x,sy+c.y,c.w,c.h,2)
        clip(sx+c.x,sy+c.y,c.w,c.h)
        sspr(BELT_ID_STRAIGHT + BELT_TICK, sx, sy, 0, 1, 0, cursor.rot)
        clip()
        sspr(UBELT_OUT, cursor.tx, cursor.ty, ITEMS[18].color_key, 1, UBELT_ROT_MAP[ENTS[other_key].rot].out_flip, cursor.rot)
          --sspr(UBELT_OUT + UBELT_TICK, sx, sy, 0, 1, ent.flip, ent.rot)
        
        --sspr(CURSOR_HIGHLIGHT, sx - 1, sy - 1, 0, 1, 0, 0, 2, 2)
        for i, cell in ipairs(cells) do
          ui.highlight(cell.x - 2, cell.y - 1, 7, 7, false, 3, 4)
          --sspr(CURSOR_HIGHLIGHT, cell.x - 1, cell.y - 1, 0, 1, 0, 0, 2, 2)
        end
      else


        local c = UBELT_CLIP_IN[cursor.rot]
        local sx, sy = cursor.tx, cursor.ty
        rect(sx+c.x,sy+c.y,c.w,c.h,2)
        clip(sx+c.x,sy+c.y,c.w,c.h)
        sspr(BELT_ID_STRAIGHT + BELT_TICK, sx, sy, 0, 1, 0, cursor.rot)
        clip()
        sspr(UBELT_IN, cursor.tx, cursor.ty, ITEMS[18].color_key, 1, flip, cursor.rot)


      end
      ui.highlight(cursor.tx - 2, cursor.ty - 1, 7, 7, false, 3, 4)
      --sspr(CURSOR_HIGHLIGHT, cursor.tx - 1, cursor.ty - 1, 0, 1, 0, 0, 2, 2)
    end
  },
  ['assembly_machine'] = {
    place_item = function(x, y)
      local tile, wx, wy = get_world_cell(x, y)
      if not tile.is_land then
        sound('deny')
        return
      end
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
        ENTS[k] = new_assembly_machine(wx, wy)
        sound('place_belt')
        return true
      else
        sound('deny')
      end
      return false
    end,
    remove_item = function(x, y)
      local tile, wx, wy = get_world_cell(x, y)
      local k = wx .. '-' .. wy
      if ENTS[k].other_key then
        k = ENTS[k].other_key
        wx, wy = ENTS[k].x, ENTS[k].y
      end
      if ENTS[k] and ENTS[k].type == 'assembly_machine' then
        --ENTS[k]:return_all()
        for i = 0, 2 do
          for j = 0, 2 do
            ENTS[wx + j .. '-' .. i + wy] = nil
          end
        end
        ENTS[k] = nil
        sound('delete')
      end
    end,
    draw_item = function(x, y)
      sspr(CRAFTER_ID, cursor.tx, cursor.ty, ITEMS[19].color_key, 1, 0, 0, 3, 3)
      sspr(348, cursor.tx + 7 + offset, cursor.ty + 12, 0)
      sspr(348, cursor.tx + 14, cursor.ty + (6 - offset), 0, 1, 0, 3)
    end
  },
  ['research_lab'] = {
    place_item = function(x, y)
      local tile, wx, wy = get_world_cell(x, y)
      if not tile.is_land then
        sound('deny')
        return
      end
      local k = wx .. '-' ..wy
      if not ENTS[k] then
        for i = 0, 2 do
          for j = 0, 2 do
            if ENTS[wx + j .. '-' .. i + wy] then 
              sound('deny')
              return false
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
        return true
      end
      return false
    end,
    remove_item = function(x, y)
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
    draw_item = function(x, y)
      sspr(LAB_ID, cursor.tx, cursor.ty, ITEMS[22].color_key, 1, 0, 0, 3, 3)
    end
  },
  ['chest'] = {
    place_item = function(x, y)
      local tile, wx, wy = get_world_cell(x, y)
      if not tile.is_land then
        sound('deny')
        return
      end
      local k = wx .. '-' .. wy
      if not ENTS[k] then
        ENTS[k] = new_chest(wx, wy, 1)
        sound('place_belt')
        return true
      end
      sound('deny')
      return false
    end,
    remove_item = function(x, y)
      local tile, wx, wy = get_world_cell(x, y)
      local k = wx .. '-' .. wy
      if ENTS[k] then
        --ENTS[k]:return_all()
        ENTS[k] = nil
        sound('delete')
        return true
      end
      return false
    end,
    draw_item = function(x, y)
      sspr(CHEST_ID, cursor.tx, cursor.ty, -1)
      ui.highlight(cursor.tx-1, cursor.ty-1, 8, 8, false, 2, 2)
    end
  },
  ['bio_refinery'] = {
    place_item = function(x, y)
      local tile, wx, wy = get_world_cell(x, y)
      if not tile.is_land or tile.is_tree then
        sound('deny')
        return false
      end
      local k = wx .. '-' .. wy
      if not ENTS[k] then
        --check 3x3 area for ents
        for i = 0, 2 do
          for j = 0, 2 do
            if ENTS[wx + j .. '-' .. i + wy] then 
              sound('deny')
              return false
            end
          end
        end
        --else place dummy ents to reserve 3x3 tile area, and create the crafter
        local dummy_keys = {}
        for i = 0, 2 do
          for j = 0, 2 do
            if not (i == 0 and j == 0) then
              local dk = wx + j .. '-' .. i + wy
              table.insert(dummy_keys, dk)
              ENTS[dk] = {type = 'dummy_refinery', other_key = k}
            end
          end
        end
        ENTS[k] = new_refinery(wx, wy)
        ENTS[k].dummy_keys = dummy_keys
        sound('place_belt')
        return true
      else
        sound('deny')
      end
      return false
    end,
    remove_item = function(x, y)
      local tile, wx, wy = get_world_cell(x, y)
      local k = wx .. '-' .. wy
      if ENTS[k].other_key then
        k = ENTS[k].other_key
        wx, wy = ENTS[k].x, ENTS[k].y
      end
      if ENTS[k] and ENTS[k].type == 'bio_refinery' then
        for k, v in ipairs(ENTS[k].dummy_keys) do
          ENTS[v] = nil
        end
        ENTS[k] = nil
        sound('delete')
      end
    end,
    draw_item = function(x, y)
      sspr(REFINERY_ID, cursor.tx, cursor.ty, ITEMS[30].color_key, 1, 0, 0, 3, 3)
    end
  },
  ['rocket_silo'] = {
    place_item = function(x, y)
      local tile, wx, wy = get_world_cell(x, y)
      if not tile.is_land or tile.is_tree then
        sound('deny')
        return false
      end
      local k = wx .. '-' .. wy
      if not ENTS[k] then
        --check 4x4 area for ents
        for i = 0, 3 do
          for j = 0, 3 do
            if ENTS[wx + j .. '-' .. i + wy] then 
              sound('deny')
              return false
            end
          end
        end
        --else place dummy ents to reserve 4x4 tile area, and create the silo
        local dummy_keys = {}
        for i = 0, 3 do
          for j = 0, 3 do
            if not (i == 0 and j == 0) then
              local dk = wx + j .. '-' .. i + wy
              table.insert(dummy_keys, dk)
              ENTS[dk] = {type = 'dummy_silo', other_key = k}
            end
          end
        end
        ENTS[k] = new_silo(wx, wy)
        ENTS[k].dummy_keys = dummy_keys
        sound('place_belt')
        return true
      else
        sound('deny')
      end
      return false
    end,
    remove_item = function(x, y)
      local tile, wx, wy = get_world_cell(x, y)
      local k = wx .. '-' .. wy
      if ENTS[k].other_key then
        k = ENTS[k].other_key
        wx, wy = ENTS[k].x, ENTS[k].y
      end
      if ENTS[k] and ENTS[k].type == 'rocket_silo' then
        for k, v in ipairs(ENTS[k].dummy_keys) do
          ENTS[v] = nil
        end
        ENTS[k] = nil
        sound('delete')
      end
    end,
    draw_item = function()
      local sx, sy = cursor.tx, cursor.ty
      spr(ROCKET_SILO_ID, sx, sy, 1, 1, 0, 0, 2, 2)
      spr(ROCKET_SILO_ID, sx + 16, sy, 1, 1, 1, 0, 2, 2)
      spr(ROCKET_SILO_ID, sx + 16, sy + 16, 1, 1, 3, 0, 2, 2)
      spr(ROCKET_SILO_ID, sx, sy + 16, 1, 1, 2, 0, 2, 2)
      for y = 0, 1 do
        for x = 0, 1 do
          spr(370, sx + 8 + x*8, sy + 8 + y*8)
        end
      end
    end
  },
}