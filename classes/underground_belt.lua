UBELT_IN           = 373
UBELT_OUT          = 438
UBELT_TICKRATE     = 5
UBELT_MAXTICK      = 3
UBELT_TICK         = 0

local uBelt = {
  x = 0, y = 0,
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
  other_key = false,
  output_key = false,
  exit_output = false,
}

UBELT_ROT_MAP = {
  [0] = {in_flip = 0, out_flip = 0, search_dir = {x =  1, y =  0}},
  [1] = {in_flip = 1, out_flip = 1, search_dir = {x =  0, y =  1}},
  [2] = {in_flip = 2, out_flip = 2, search_dir = {x = -1, y =  0}},
  [3] = {in_flip = 0, out_flip = 0, search_dir = {x =  0, y = -1}},
}

function uBelt:draw()
  self.drawn = true
  local sx, sy = world_to_screen(self.x, self.y)
  self.screen_pos = {x = sx, y = sy}
  if self.is_exit then
    sspr(UBELT_OUT + UBELT_TICK, sx, sy, 0, 1, self.flip, self.rot)
  else
    if self.other_key and ENTS[self.other_key] then
      local ent = ENTS[self.other_key]
      local sx, sy = world_to_screen(ent.x, ent.y)
      if sx >= -7 and sx <= 247 and sy >= -7 and sy <= 143 then
        sspr(UBELT_OUT + UBELT_TICK, sx, sy, 0, 1, ent.flip, ent.rot)
      end
    end
    sspr(UBELT_IN + UBELT_TICK, sx, sy, 0, 1, self.flip, self.rot)
  end
end

function uBelt:draw_items()
  local item_locations = BELT_CURVED_ITEM_MAP[self.rot .. self.rot]
  for i = 1, 2 do
    for j = 5, 8 do
      if self.lanes[i][j] > 0 then
        --local loc_x, loc_y = cam.x - 120 + (self.pos.x*8), cam.y - 64 + (self.pos.y*8)
        local x, y = item_locations[j][i].x + self.screen_pos.x, item_locations[j][i].y + self.screen_pos.y
        local sprite_id = ITEMS[self.lanes[i][j]].belt_id
        sspr(sprite_id, x, y, 0)
      end
    end
  end

  if self.exit_lanes then
    --trace('try draw exit items')
    local sx, sy = world_to_screen(ENTS[self.other_key].x, ENTS[self.other_key].y)
    for i = 1, 2 do
      for j = 1, 2 do
        if self.exit_lanes[i][j] ~= 0 then
          local x, y = item_locations[j][i].x + sx, item_locations[j][i].y + sy
          local sprite_id = ITEMS[self.exit_lanes[i][j]].belt_id
          sspr(sprite_id, x, y, 0)
        end
      end
    end
  end
end

function uBelt:update()
  self.updated = true
  --trace('UPDATED UBELT @TICK ' .. TICK)
    --update exit 'belt'
    if self.exit_lanes then
      for i = 1, 2 do
        for j = 1, 8 do
          if j == 1 then
            -- local exit = ENTS[self.other_key]
            -- local sx, sy = world_to_screen(exit.x, exit.y)
            -- local wx, wy = screen_to_world(exit.x - 8, exit.y)
            -- local key = wx .. '-' .. wy
            -- if ENTS[key] and ENTS[key].type == 'transport_belt' then

            -- end
            -- self.exit_lanes[i][8] = self.u_lanes[i][j]
            -- self.u_lanes[i][j] = 0
            
            -- if self.output_item_key and ent then
            --   if ENTS[self.output_key] and ENTS[self.output_key].lanes[i][8]
            -- end

            if self.exit_lanes[i][1] ~= 0 and self.output_key and self.exit_output and ENTS[self.output_key] then
              local ent = ENTS[self.output_key]
              local key = self.output_key
              if ent.type == 'transport_belt' and self.exit_lanes[i][1] ~= 0 then
                --trace('try depositing [' .. tostring(self.exit_lanes[i][1]) .. '] to transport_belt')
                ENTS[key].idle = false
                --if i am facing another belt, update that belt first
                if not ent.updated then ENTS[key]:update() end
                --if we find a belt, and the ENTS nearest slot is empty (equals 0) then
                --move item to that belt
                if ent.id == BELT_ID_CURVED and ent.lanes[i][8] == 0 then
                  --add item to other belt
                  ENTS[key].lanes[i][8] = self.exit_lanes[i][1]
                  --remove item from self
                  self.exit_lanes[i][1] = 0
                elseif ent.lanes[self.exit_output[i].a][self.exit_output[i].b] == 0 then
                  ENTS[key].lanes[self.exit_output[i].a][self.exit_output[i].b] = self.exit_lanes[i][1]
                  --ENTS[self.output_key].idle = false
                  self.exit_lanes[i][1] = 0
                end
              elseif ent.type == 'underground_belt' or ent.type == 'underground_belt_exit' then
                if ent.type == 'underground_belt_exit' then
                  self.output_key = ENTS[key].other_key
                  key = self.output_key
                end
                if ENTS[key].lanes[self.output[i].a][self.output[i].b] == 0 then
                  ENTS[key].lanes[self.output[i].a][self.output[i].b] = self.exit_lanes[i][j]
                  --ENTS[self.output_key].idle = false
                  self.exit_lanes[i][j] = 0
                end
              --------------------------------------------------------------------------------------------------
              elseif ENTS[key].type == 'splitter' or ENTS[key].type == 'dummy_splitter' then
                --if key is a dummy splitter, then get the parent splitter's key
                if ENTS[key].type == 'dummy_splitter' then
                  self.output_key = ENTS[key].other_key
                  key = ENTS[key].other_key
                end
                --if not ENTS[key].updated then ENTS[key]:update() end
                if ENTS[key]:input(self.exit_lanes[i][1], i) then
                  self.exit_lanes[i][1] = 0
                end
                --if should_shift then ENTS[key].shift = not ENTS[key].shift end
              end
            ------------------------------------------------------------------------------------------------------
            end


          elseif self.exit_lanes[i][j] ~= 0 and self.exit_lanes[i][j - 1] == 0 then
            self.exit_lanes[i][j - 1] = self.exit_lanes[i][j]
            self.exit_lanes[i][j] = 0
          end
        end
      end
    end

  --update hidden underground belt
  if self.u_lanes then
    for i = 1, 2 do
      for j = 1, #self.u_lanes[i] do
        if j == 1 and self.u_lanes[i][1] ~= 0 and self.exit_lanes[i][8] == 0 then
          self.exit_lanes[i][8] = self.u_lanes[i][1]
          self.u_lanes[i][1] = 0
        elseif j > 1 and self.u_lanes[i][j] ~= 0 and self.u_lanes[i][j - 1] == 0 then
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
        if self.u_lanes and self.lanes[i][1] ~= 0 and self.u_lanes[i][#self.u_lanes[i]] == 0 then
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

function uBelt:connect(world_x, world_y, distance)
  self.u_lanes = {}
  self.exit_lanes = {}
  for i = 1, 2 do
    self.exit_lanes[i] = {}
    for j = 1, 8 do
      self.exit_lanes[i][j] = 0
    end
  end
  for i = 1, 2 do
    self.u_lanes[i] = {}
    for j = 1, distance * 8 do
      self.u_lanes[i][j] = 0
    end
  end
  self.other_key = world_x .. '-' .. world_y
  local exit = BELT_ROTATION_MAP[self.rot]
  local key = world_x + exit.x .. '-' .. world_y + exit.y
  self.output_key = key
  self:set_output()
end

function uBelt:set_output()
  if not ENTS[self.other_key] then return end
  local exit = BELT_ROTATION_MAP[self.rot]
  local key = ENTS[self.other_key].x + exit.x .. '-' .. ENTS[self.other_key].y + exit.y
  self.output_key = key

  local ent = ENTS[key]
  if ent then

    if ent.type == 'dummy_splitter' or ent.type == 'underground_belt_exit' then
      self.output_key = ent.other_key
      ent = ENTS[self.output_key]
    end

    if ent.type == 'transport_belt'
    or ent.type == 'splitter' and ENTS[key].rot == self.rot
    or ent.type == 'underground_belt' then

      self.exit_output = BELT_OUTPUT_MAP[self.rot .. ent.rot]

    else
      self.exit_output = nil
    end
  else
    self.exit_output = nil
  end
end

function uBelt:request_item(keep, lane, slot)
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

function uBelt:request_item_exit(keep, lane, slot)
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
      local key = wx + (dir.x * i) .. '-' .. wy + (dir.y * i)
      local ent = ENTS[key]
      if ent and (ent.type == 'underground_belt' or ent.type == 'underground_belt_exit') then
        if ent.type == 'underground_belt_exit' then key = ent.other_key end
        if ENTS[key].rot == rot then
          --found another ubelt, that is facing our same direction
          --trace('found suitable connection')
          local cells = {}
          for j = 1, i do
            local sx, sy = world_to_screen(wx + (dir.x * j), wy + (dir.y * j))
            cells[j] = {x = sx, y = sy}
          end
          return true, key, cells
        end
      end
    end


  --end
  return false
end

function uBelt:deposit(id, side)
  --side 0 is entrance, 1 is exit
  if side == 1 then
    if self.exit_lanes[1][8] == 0 then
      self.exit_lanes[1][8] = id
      return true
    elseif self.exit_lanes[2][8] == 0 then
      self.exit_lanes[2][8] = id
      return true
    end
  else
    if self.lanes[1][8] == 0 then
      self.lanes[1][8] = id
      return true
    elseif self.lanes[2][8] == 0 then
      self.lanes[2][8] = id
      return true
    end
  end
  return false
end

return function (x, y, rot)
  local new_belt = {x = x, y = y, lanes = {[1] = {0,0,0,0,0,0,0,0}, [2] = {0,0,0,0,0,0,0,0}}, rot = rot, flip = UBELT_ROT_MAP[rot].in_flip}
  setmetatable(new_belt, {__index = uBelt})
  return new_belt
end