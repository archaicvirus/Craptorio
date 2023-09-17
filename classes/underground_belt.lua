UBELT_IN           = 278
UBELT_OUT          = 277
UBELT_COLORKEY     = 0
UBELT_TICKRATE     = 5
UBELT_MAXTICK      = 3
UBELT_TICK         = 0

local underground_belt = {
  x = 0, y = 0,
  item_id = 18,
  rot = 0,
  flip = 0,
  lanes = {[1] = {}, [2] = {}},
  screen_pos = {x = 0, y = 0},
  u_lanes = false,
  exit_lanes = false,
  is_exit = false,
  type = 'underground_belt',
  is_hovered = false,
  drawn = false,
  updated = false,
  exit_key = false,
  output_key = false,
  exit_output = false,
  tickrate = 5,
}

UBELT_ROT_MAP = {
  [0] = {in_flip = 0, out_flip = 0, search_dir = {x =  1, y =  0}},
  [1] = {in_flip = 1, out_flip = 1, search_dir = {x =  0, y =  1}},
  [2] = {in_flip = 2, out_flip = 2, search_dir = {x = -1, y =  0}},
  [3] = {in_flip = 0, out_flip = 0, search_dir = {x =  0, y = -1}},
}

UBELT_CLIP_IN = {
  [0] = {x = 6, y = 0, w = 2, h = 8},
  [1] = {x = 0, y = 6, w = 8, h = 2},
  [2] = {x = 0, y = 0, w = 2, h = 8},
  [3] = {x = 0, y = 0, w = 8, h = 2},
}

UBELT_CLIP_OUT = {
  [0] = {x = 0, y = 0, w = 2, h = 8},
  [1] = {x = 0, y = 0, w = 8, h = 2},
  [2] = {x = 6, y = 0, w = 2, h = 8},
  [3] = {x = 0, y = 6, w = 8, h = 2},
}

function underground_belt:draw()
  if self.drawn then return end
  local sx, sy = world_to_screen(self.x, self.y)
  self.screen_pos = {x = sx, y = sy}
  if self.is_exit then
    -- local c = UBELT_CLIP_OUT[self.rot]
    -- --rect(sx+c.x,sy+c.y,c.w,c.h,2)
    -- clip(sx+c.x,sy+c.y,c.w,c.h)
    -- sspr(BELT_ID_STRAIGHT + BELT_TICK, sx, sy, 0, 1, 0, self.rot)
    -- clip()
    --sspr(UBELT_OUT + UBELT_TICK, sx, sy, 0, 1, self.flip, self.rot)
  else
    if self.exit_key and ENTS[self.exit_key] then
      local ent = ENTS[self.exit_key]
      local sx, sy = world_to_screen(ent.x, ent.y)
      if sx >= -7 and sx <= 247 and sy >= -7 and sy <= 143 then
        local c = UBELT_CLIP_OUT[self.rot]
        --rect(sx+c.x,sy+c.y,c.w,c.h,2)
        clip(sx+c.x,sy+c.y,c.w,c.h)
        sspr(BELT_ID_STRAIGHT + BELT_TICK, sx, sy, 0, 1, 0, self.rot)
        clip()
        --sspr(UBELT_OUT + UBELT_TICK, sx, sy, 0, 1, ent.flip, ent.rot)
      end
    end
    local c = UBELT_CLIP_IN[self.rot]
    rect(sx+c.x,sy+c.y,c.w,c.h,2)
    clip(sx+c.x,sy+c.y,c.w,c.h)
    sspr(BELT_ID_STRAIGHT + BELT_TICK, sx, sy, 0, 1, 0, self.rot)
    clip()
    --sspr(UBELT_IN + UBELT_TICK, sx, sy, 0, 1, self.flip, self.rot)
  end
  --clip()
end

function underground_belt:draw_hover_widget(other)
  local txt = other and 'Underg. Belt Exit' or 'Underground Belt'
  local x, y = cursor.x + 3, cursor.y + 3
  local width = print(txt, 0, -10, 0, false, 1, true)
  local w, h = width + 4, 50
  ui.draw_panel(x, y, w, h, UI_BG, UI_FG, txt)
  --box(x, y, w, h, 8, 9)
  --rect(x + 1, y + 1, w - 2, 9, 9)
  --prints(txt, x + w/2 - width/2, y + 2, 0, 4)
  local c
  if other then
    c = UBELT_CLIP_OUT[self.rot]
  else
    c = UBELT_CLIP_IN[self.rot]
  end
  --rect(sx+c.x,sy+c.y,c.w,c.h,2)
  clip(x + (c.x*3) + w/2 - 12, y + 15+(c.y*3),c.w*3,c.h*3)
  --rect(x + (c.x*3) + w/2 - 12, y + 15+(c.y*3),c.w*3,c.h*3, 2)
  sspr(BELT_ID_STRAIGHT + BELT_TICK, x + w/2 - 12, y + 15, 0, 3, 0, other and ENTS[other].rot or self.rot)
  clip()
  if other then
    sspr(UBELT_OUT, x + w/2 - 12, y + 15, UBELT_COLORKEY, 3, ENTS[other].flip, ENTS[other].rot)
  else
    sspr(UBELT_IN, x + w/2 - 12, y + 15, UBELT_COLORKEY, 3, self.flip, self.rot)
  end  
end

function underground_belt:draw_items()
  --main head unit
  if self.drawn then return end
  self.drawn = true
  local item_locations = BELT_CURVED_ITEM_MAP[self.rot .. self.rot]
  for i = 1, 2 do
    for j = 5, 8 do
      if self.lanes[i][j] > 0 then
        --local loc_x, loc_y = cam.x - 120 + (self.pos.x*8), cam.y - 64 + (self.pos.y*8)
        local x, y = item_locations[j][i].x + self.screen_pos.x, item_locations[j][i].y + self.screen_pos.y
        local item = ITEMS[self.lanes[i][j]]
        sspr(item.belt_id, x, y, item.color_key)
      end
    end
  end
  if not self.is_exit then
    local sx, sy = world_to_screen(self.x, self.y)
    sspr(UBELT_IN, sx, sy, 0, 1, self.flip, self.rot)
  end

  --output head
  if self.exit_lanes then
    if ENTS[self.output_key] and (ENTS[self.output_key].type == 'underground_belt' or ENTS[self.output_key].type == 'transport_belt') and
    not ENTS[self.output_key].drawn then
      ENTS[self.output_key]:draw()
      ENTS[self.output_key]:draw_items()
    end
    --trace('try draw exit items')
    local sx, sy = world_to_screen(ENTS[self.exit_key].x, ENTS[self.exit_key].y)
    for i = 1, 2 do
      for j = 1, 2 do
        if self.exit_lanes[i][j] > 0 then
          local x, y = item_locations[j][i].x + sx, item_locations[j][i].y + sy
          local item = ITEMS[self.exit_lanes[i][j]]
          sspr(item.belt_id, x, y, item.color_key)
        end
      end
    end
    sspr(UBELT_OUT, sx, sy, 0, 1, self.flip, self.rot)
  end
end

function underground_belt:update()
  self.updated = true
    --update exit 'belt'
  if self.exit_lanes then
    for i = 1, 2 do
      for j = 1, 8 do
        if j == 1 and self.exit_lanes[i][j] > 0 then
          if self.output_key and ENTS[self.output_key] then
            local ent = ENTS[self.output_key]
            local k = self.output_key
            if ent.type == 'transport_belt' then
              if not ent.updated then ENTS[k]:update() end
              if self.exit_lanes[i][1] ~= 0 then
                ENTS[k].idle = false
                --if i am facing another belt, update that belt first
                if not ent.updated then ENTS[k]:update() end
                --if we find a belt, and the ENTS nearest slot is empty (equals 0) then
                --move item to that belt
                if ent.id == BELT_ID_CURVED and ent.lanes[i][8] == 0 then
                  --add item to other belt
                  ENTS[k].lanes[i][8] = self.exit_lanes[i][1]
                  --remove item from self
                  self.exit_lanes[i][1] = 0
                elseif ent.lanes[self.exit_output[i].a][self.exit_output[i].b] == 0 then
                  ENTS[k].lanes[self.exit_output[i].a][self.exit_output[i].b] = self.exit_lanes[i][1]
                  --ENTS[self.output_key].idle = false
                  self.exit_lanes[i][1] = 0
                end
              end
            elseif ent.type == 'underground_belt' or ent.type == 'underground_belt_exit' then
              if ent.type == 'underground_belt_exit' then
                self.output_key = ENTS[key].other_key
                key = self.output_key
              end
              if ENTS[k].lanes[self.exit_output[i].a][self.exit_output[i].b] == 0 then
                ENTS[k].lanes[self.exit_output[i].a][self.exit_output[i].b] = self.exit_lanes[i][j]
                --ENTS[self.output_key].idle = false
                self.exit_lanes[i][j] = 0
              end
            elseif ENTS[k].type == 'splitter' or ENTS[k].type == 'dummy_splitter' then
              --if key is a dummy splitter, then get the parent splitter's key
              if ENTS[k].type == 'dummy_splitter' then
                self.output_key = ENTS[k].exit_key
                k = ENTS[k].exit_key
              end
              --if not ENTS[k].updated then ENTS[key]:update() end
              if ENTS[k]:input(self.exit_lanes[i][1], i) then
                self.exit_lanes[i][1] = 0
              end
              --if should_shift then ENTS[k].shift = not ENTS[k].shift end
            end
          end
        elseif j > 1 and self.exit_lanes[i][j] > 0 and self.exit_lanes[i][j - 1] == 0 then
          self.exit_lanes[i][j - 1] = self.exit_lanes[i][j]
          self.exit_lanes[i][j] = 0
        end
      end
    end
  end
  --update hidden underground belt
  if self.u_lanes then
    for i = 1, 2 do
      for j = 1, #self.u_lanes[1] do
        if j == 1 and self.exit_lanes and self.u_lanes[i][j] > 0 and self.exit_lanes[i][8] == 0 then
          self.exit_lanes[i][8] = self.u_lanes[i][j]
          self.u_lanes[i][j] = 0
        elseif j > 1 and self.u_lanes[i][j] > 0 and self.u_lanes[i][j - 1] == 0 then
          self.u_lanes[i][j - 1] = self.u_lanes[i][j]
          self.u_lanes[i][j] = 0
        end
      end
    end
  end


  --update entrance 'belt'
  for i = 1, 2 do
    for j = 1, 8 do

      if j == 1 then
        if not self.u_lanes and self.exit_lanes and self.lanes[i][1] ~= 0 and self.exit_lanes[i][8] == 0 then
          self.exit_lanes[i][8] = self.lanes[i][1]
          self.lanes[i][1] = 0
        elseif self.u_lanes and self.lanes[i][1] ~= 0 and self.u_lanes[i][#self.u_lanes[i]] == 0 then
          self.u_lanes[i][#self.u_lanes[i]] = self.lanes[i][1]
          self.lanes[i][1] = 0
        end
      elseif self.lanes[i][j] ~= 0 and self.lanes[i][j - 1] == 0 then
        self.lanes[i][j - 1] = self.lanes[i][j]
        self.lanes[i][j] = 0
      end

    end
  end

end

function underground_belt:connect(world_x, world_y, distance)
  self.exit_lanes = {}
  for i = 1, 2 do
    self.exit_lanes[i] = {}
    for j = 1, 8 do
      self.exit_lanes[i][j] = 0
    end
  end
  
  if distance > 0 then
    self.u_lanes = {}
    for i = 1, 2 do
      self.u_lanes[i] = {}
      for j = 1, distance * 8 do
        self.u_lanes[i][j] = 0
      end
    end
  end

  self.exit_key = world_x .. '-' .. world_y
  local exit = BELT_ROTATION_MAP[self.rot]
  local key = world_x + exit.x .. '-' .. world_y + exit.y
  self.output_key = key
  self:set_output()
end

function underground_belt:set_output()
  if not ENTS[self.exit_key] then return end
  local exit = BELT_ROTATION_MAP[self.rot]
  local k = ENTS[self.exit_key].x + exit.x .. '-' .. ENTS[self.exit_key].y + exit.y
  self.output_key = k

  local ent = ENTS[k]
  if ent then

    if ent.type == 'dummy_splitter' or ent.type == 'underground_belt_exit' then
      self.output_key = ent.other_key
      ent = ENTS[self.output_key]
    end

    if ent.type == 'transport_belt'
    or ent.type == 'splitter' and ENTS[k].rot == self.rot
    or ent.type == 'underground_belt' then

      self.exit_output = BELT_OUTPUT_MAP[self.rot .. ent.rot]

    else
      self.exit_output = nil
    end
  else
    self.exit_output = nil
  end
end

function underground_belt:update_neighbors()
  local cell_x, cell_y = self.x, self.y
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

function underground_belt:update_neighbors_exit()
  if ENTS[self.exit_key] then
    local cell_x, cell_y = ENTS[self.exit_key].x, ENTS[self.exit_key].y
    local tiles = {
      [1] = {x = cell_x, y = cell_y - 1},
      [2] = {x = cell_x + 1, y = cell_y},
      [3] = {x = cell_x, y = cell_y + 1},
      [4] = {x = cell_x - 1, y = cell_y}
    }
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
end

function underground_belt:request_item(keep, lane, slot)
  if not lane and not slot then
    for i = 1, 2 do
      for j = 1, 8 do
        if self.lanes[i][j] ~= 0 then
          local item_id = self.lanes[i][j]
          if not keep then self.lanes[i][j] = 0 end
          return item_id
        end
      end
    end
    return false
  elseif self.lanes[lane][slot] ~= 0 then
    local item_id = self.lanes[lane][slot]
    if not keep then self.lanes[lane][slot] = 0 end
    return item_id
  end
  return false
end

function underground_belt:request_item_exit(keep, lane, slot)
  if not lane and not slot then
    for i = 1, 2 do
      for j = 1, 8 do
        if self.exit_lanes[i][j] ~= 0 then
          local item_id = self.exit_lanes[i][j]
          if not keep then self.exit_lanes[i][j] = 0 end
          return item_id
        end
      end
    end
    return false
  elseif self.exit_lanes[lane][slot] ~= 0 then
    local item_id = self.exit_lanes[lane][slot]
    if not keep then self.exit_lanes[lane][slot] = 0 end
    return item_id
  end
  return false
end

function get_ubelt_connection(x, y, rot)
  local _, wx, wy = get_world_cell(x, y)
  local dir = UBELT_ROT_MAP[rot].search_dir
  --if rot == 0 then
    local found_key = false
    -- always search going opposite of belt flow
    -- looking for another underground-belt to try connect to first

    --Tier-1 belts can span 4 tiles, 5 being the entrance/exit
    for i = 1, 5 do
      local k = wx + (dir.x * i) .. '-' .. wy + (dir.y * i)
      local ent = ENTS[k]
      if ent and i == 1 and ent.type ==  'underground_belt_exit' and ent.rot == rot then
        --ent = ENTS[ent.other_key]
        return false
      end
      if ent and ent.type == 'underground_belt' then
        --if ent.type == 'underground_belt_exit' then k = ent.other_key end
        if ENTS[k].rot == rot then
          --found another underground_belt, that is facing our same direction
          --trace('found suitable connection')
          local cells = {}
          for j = 1, i do
            local sx, sy = world_to_screen(wx + (dir.x * j), wy + (dir.y * j))
            cells[j] = {x = sx, y = sy}
          end
          return true, k, cells
        end
      end
    end


  --end
  return false
end

-- function underground_belt:deposit(id, side)
--   --side 0 is entrance, 1 is exit
--   if side == 1 then
--     if self.exit_lanes[1][8] == 0 then
--       self.exit_lanes[1][8] = id
--       return true
--     elseif self.exit_lanes[2][8] == 0 then
--       self.exit_lanes[2][8] = id
--       return true
--     end
--   else
--     if self.lanes[1][8] == 0 then
--       self.lanes[1][8] = id
--       return true
--     elseif self.lanes[2][8] == 0 then
--       self.lanes[2][8] = id
--       return true
--     end
--   end
--   return false
-- end

function underground_belt:request_deposit()
  return 'any'
end

function underground_belt:deposit(id, other_rot, is_exit)
  local lane = INSERTER_DEPOSIT_MAP[other_rot][self.rot]
  if is_exit then
    --for lane = 1, 2 do
      for slot = 8, 1, -1 do
        if self.exit_lanes[lane][slot] == 0 then
          self.exit_lanes[lane][slot] = id
          return true
        end
      end
    --end
  else
    --for lane = 1, 2 do
      for slot = 8, 1, -1 do
        if self.lanes[lane][slot] == 0 then
          self.lanes[lane][slot] = id
          return true
        end
      end
    --end
  end
  return false
end

function underground_belt:item_request(id, is_exit)
  is_exit = is_exit or false
  for i = 1, 2 do
    for j = 8, 1, -1 do
      if is_exit and self.exit_lanes then
        if self.exit_lanes[i][j] > 0 and (self.exit_lanes[i][j] == id or id == 'any' or ITEMS[self.exit_lanes[i][j]].type == id) then
          local item_id = self.exit_lanes[i][j]
          self.exit_lanes[i][j] = 0
          return item_id
        end
      else
        if self.lanes[i][j] > 0 and (self.lanes[i][j] == id or id == 'any' or ITEMS[self.lanes[i][j]].type == id) then
          local item_id = self.lanes[i][j]
          self.lanes[i][j] = 0
          return item_id
        end
      end
    end
  end
  return false
end

function underground_belt:deposit_stack(stack)
  if self.recipe then
    for i = 1, #self.recipe.ingredients do
      local max_stack_per_slot = self.recipe.ingredients[i].count*5
      if self.recipe.ingredients[i].id == stack.id then
        if self.input[i].count + stack.count <= max_stack_per_slot then
          self.input[i].count = self.input[i].count + stack.count
          self.input[i].id = stack.id
          self.state = 'ready'
          -- sound('deposit')
          -- ui.new_alert(cursor.x, cursor.y, stack.count .. ' ' .. ITEMS[stack.id].fancy_name, 1000, 0, 11)
          return true, {id = 0, count = 0}
        elseif self.input[i].count < max_stack_per_slot and self.input[i].count + stack.count > max_stack_per_slot then
          local diff = max_stack_per_slot - self.input[i].count
          self.input[i].count = max_stack_per_slot
          self.input[i].id = stack.id
          self.state = 'ready'
          -- sound('deposit')
          -- ui.new_alert(cursor.x, cursor.y, stack.count .. ' ' .. ITEMS[stack.id].fancy_name, 1000, 0, 11)
          return true, {id = stack.id, count = stack.count - diff}
        end
      end
    end
  end
  return false, {id = stack.id, count = stack.count}
end

function underground_belt:return_all()
  local item_stacks = {}
  for i = 1, 2 do
    for j = 1, 8 do
      if self.lanes[i][j] > 0 then
        local id = self.lanes[i][j]
        if not item_stacks[id] then item_stacks[id] = 0 end
        item_stacks[id] = item_stacks[id] + 1
        self.lanes[i][j] = 0
      end
    end
  end

  if self.u_lanes then
    for i = 1, 2 do
      for j = 1, #self.u_lanes[1] do
        if self.u_lanes[i][j] > 0 then
          local id = self.u_lanes[i][j]
          if not item_stacks[id] then item_stacks[id] = 0 end
          item_stacks[id] = item_stacks[id] + 1
          self.u_lanes[i][j] = 0
        end
      end
    end
  end

  if self.exit_lanes then
    for i = 1, 2 do
      for j = 1, 8 do
        if self.exit_lanes[i][j] > 0 then
          local id = self.exit_lanes[i][j]
          if not item_stacks[id] then item_stacks[id] = 0 end
          item_stacks[id] = item_stacks[id] + 1
          self.exit_lanes[i][j] = 0
        end
      end
    end
  end

  local offset = 0
  for k, v in pairs(item_stacks) do
    inv:add_item({id = k, count = v})
    ui.new_alert(cursor.x, cursor.y + offset, '+' .. v .. ' ' .. ITEMS[k].fancy_name, 1000, 0, 11)
    offset = offset + 6
  end
end

function new_underground_belt(x, y, rot)
  local new_belt = {x = x, y = y, lanes = {[1] = {0,0,0,0,0,0,0,0}, [2] = {0,0,0,0,0,0,0,0}}, rot = rot, flip = UBELT_ROT_MAP[rot].in_flip}
  setmetatable(new_belt, {__index = underground_belt})
  return new_belt
end