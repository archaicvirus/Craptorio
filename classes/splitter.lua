SPLITTER_ID       = 322
SPLITTER_ID_SMALL = 323
SPLITTER_ID_TOP   = 322
SPLITTER_ID_BTM   = 338
SPLITTER_TICKRATE = 5

SPLITTER_ROTATION_MAP = {
  --x,y is for drawing second splitter half
  [0] = {x = 0, y =  1},
  [1] = {x = 1, y =  0},
  [2] = {x = 0, y =  1},
  [3] = {x = 1, y =  0},
}

SPLITTER_OUTPUT_MAP = {
  [0] = {left = {x = -1, y =  1}, right = {x = -1, y =  0}, left_in = {x =  1, y =  1}, right_in = {x =  1, y =  0}},
  [1] = {left = {x =  0, y = -1}, right = {x =  1, y = -1}, left_in = {x =  0, y =  1}, right_in = {x =  1, y =  1}},
  [2] = {left = {x =  1, y =  0}, right = {x =  1, y =  1}, left_in = {x = -1, y =  0}, right_in = {x = -1, y =  1}},
  [3] = {left = {x =  1, y =  1}, right = {x =  0, y =  1}, left_in = {x =  1, y = -1}, right_in = {x =  0, y = -1}}
}

SPLITTER_ITEM_MAP = {
  [0] = {a = {x =  0, y =  0}, b = {x = 0, y = 4}, c = {x = 0, y = 8}, d = {x =  0, y = 12}},
  [1] = {a = {x = 13, y =  0}, b = {x = 9, y = 0}, c = {x = 5, y = 0}, d = {x =  1, y =  0}},
  [2] = {a = {x =  5, y = 13}, b = {x = 5, y = 9}, c = {x = 5, y = 5}, d = {x =  5, y =  1}},
  [3] = {a = {x =  0, y =  5}, b = {x = 4, y = 5}, c = {x = 8, y = 5}, d = {x = 12, y =  5}},
}

SPLITTER_BELT_OUTPUT_MAP = {
    ['00'] = {[1] = {lane = 1, slot = 8}, [2] = {lane = 2, slot = 8}},
    ['01'] = {[1] = {lane = 1, slot = 4}, [2] = {lane = 1, slot = 6}},
    ['02'] = nil,
    ['03'] = {[1] = {lane = 2, slot = 6}, [2] = {lane = 2, slot = 4}},
    ['10'] = {[1] = {lane = 2, slot = 1}, [2] = {lane = 2, slot = 4}},
    ['11'] = {[1] = {lane = 1, slot = 8}, [2] = {lane = 2, slot = 8}},
    ['12'] = {[1] = {lane = 1, slot = 5}, [2] = {lane = 1, slot = 3}},
    ['13'] = nil,
    ['20'] = nil,
    ['21'] = {[1] = {lane = 2, slot = 4}, [2] = {lane = 2, slot = 6}},
    ['22'] = {[1] = {lane = 1, slot = 8}, [2] = {lane = 2, slot = 8}},
    ['23'] = {[1] = {lane = 1, slot = 4}, [2] = {lane = 1, slot = 6}},
    ['30'] = {[1] = {lane = 1, slot = 1}, [2] = {lane = 1, slot = 4}},
    ['31'] = nil,
    ['32'] = {[1] = {lane = 2, slot = 6}, [2] = {lane = 2, slot = 4}},
    ['33'] = {[1] = {lane = 1, slot = 8}, [2] = {lane = 2, slot = 8}}
}

local Splitter = {
  x = 0,
  y = 0,
  rot = 0,
  type = 'splitter',
  key2 = '',
  is_hovered = false,
  lanes = {left = {}, right = {}},
  shift = true,
  output_key_l = 'nil',
  output_l = nil,
  output_r = nil,
  output_key_r = 'nil',
  input_key_l  = 'nil',
  input_key_r  = 'nil',
  updated = false,
  --other_key = 'nil',
  drawn = false,
  item_id = 10,
  tickrate = 5,
}

function Splitter:draw_hover_widget()
  local sx, sy = cursor.x, cursor.y
  rectb(sx, sy, 50, 50, 13)
  rect(sx + 1, sy + 1, 48, 48, 0)
end

function Splitter.get_info(self)
  local world_key = self.x .. '-' .. self.y
  local output_map = SPLITTER_OUTPUT_MAP[self.rot]
  local output_key_l = self.x + output_map.left.x .. '-' .. self.y + output_map.left.y
  local output_key_r = self.x + output_map.right.x .. '-' .. self.y + output_map.right.y
  local left_ent, right_ent = ENTS[output_key_l] and ENTS[output_key_l].type or 'NIL', ENTS[output_key_r] and ENTS[output_key_r].type or 'NIL'
  local info = {
    [1] = 'WORLD KEY: ' .. world_key,
    [2] = 'LEFT KEY: ' .. output_key_l,
    [3] = 'LEFT ENT: ' .. left_ent,
    [4] = 'RIGHT KEY: ' .. output_key_r,
    [5] = 'RIGHT ENT: ' .. right_ent,
  }
  return info
end

function Splitter.set_output(self)
  --trace('setting splitter output')
  local output_map = SPLITTER_OUTPUT_MAP[self.rot]
  self.output_key_l = self.x + output_map.left.x .. '-' .. self.y + output_map.left.y
  self.output_key_r = self.x + output_map.right.x .. '-' .. self.y + output_map.right.y
  self.input_key_l = self.x + output_map.left_in.x .. '-' .. self.y + output_map.left_in.y
  self.input_key_r = self.x + output_map.right_in.x .. '-' .. self.y + output_map.right_in.y
  local l, r = ENTS[self.output_key_l], ENTS[self.output_key_r]
  if l then
    if l.type == 'transport_belt' then
      local rot_key = self.rot .. l.rot
      self.output_l = SPLITTER_BELT_OUTPUT_MAP[rot_key]
      -- if rot_key == '02' or rot_key == 13 or rot_key == 20 or rot_key == 31 then
      --   self.output_l = nil
      -- end
      --l:update_neighbors(self.x ..  '-' .. self.y)

      --trace('SPLITTER - setting belt at ' .. self.output_key_l .. ' to curved')
      ENTS[self.output_key_l]:set_curved()
      
      --elseif l.type == 'splitter' then
      
    elseif l.type == 'dummy_splitter' then
      self.output_key_l = l.other_key
      local rot_key = self.rot .. l.rot
      self.output_l = SPLITTER_BELT_OUTPUT_MAP[rot_key]
      -- if rot_key == '02' or rot_key == '13' or rot_key == '20' or rot_key == '31' then
      --   self.output_l = nil
      -- end
    elseif l.type == 'splitter' then
      local rot_key = self.rot .. l.rot
      self.output_l = SPLITTER_BELT_OUTPUT_MAP[rot_key]
      -- if rot_key == '02' or rot_key == '13' or rot_key == '20' or rot_key == '31' then
      --   self.output_l = nil
      -- end
    elseif l.type == 'underground_belt' then
      trace('UB detected LEFT')
      local rot_key = self.rot .. l.rot
      self.output_l = SPLITTER_BELT_OUTPUT_MAP[rot_key]
    elseif l.type == 'underground_belt_exit' then
      local rot_key = self.rot .. l.rot
      self.output_l = SPLITTER_BELT_OUTPUT_MAP[rot_key]
    end
  else
    self.output_l = nil
  end

  if r then
    if r.type == 'transport_belt' then
      local rot_key = self.rot .. r.rot
      self.output_r = SPLITTER_BELT_OUTPUT_MAP[rot_key]
      -- if rot_key == '02' or rot_key == '13' or rot_key == '20' or rot_key == '31' then
      --   self.output_r = nil
      -- end
      --trace('SPLITTER - setting belt at ' .. self.output_key_r .. ' to curved')
      ENTS[self.output_key_r]:set_curved()
      --ENTS[self.output_key_r]:update_neighbors(self.x .. '-' .. self.y)
    elseif r.type == 'dummy_splitter' then
      self.output_key_r = r.other_key
      local rot_key = self.rot .. r.rot
      self.output_r = SPLITTER_BELT_OUTPUT_MAP[rot_key]
      -- if rot_key == '02' or rot_key == '13' or rot_key == '20' or rot_key == '31' then
      --   self.output_r = nil
      -- end
    elseif r.type == 'splitter' then
      local rot_key = self.rot .. r.rot
      self.output_r = SPLITTER_BELT_OUTPUT_MAP[rot_key]
      -- if rot_key == '02' or rot_key == '13' or rot_key == '20' or rot_key == '31' then
      --   self.output_r = nil
      -- end
    elseif r.type == 'underground_belt' then
      trace('UB detected RIGHT')
      local rot_key = self.rot .. r.rot
      self.output_r = SPLITTER_BELT_OUTPUT_MAP[rot_key]
    elseif r.type == 'underground_belt_exit' then
      local rot_key = self.rot .. r.rot
      self.output_r = SPLITTER_BELT_OUTPUT_MAP[rot_key]
    end
  else
    self.output_r = nil
  end

  if ENTS[self.input_key_l] then
    if ENTS[self.input_key_l].type == 'splitter' then
      ENTS[self.input_key_l]:set_output()
    elseif ENTS[self.input_key_l].type == 'dummy_splitter' then
      local key = ENTS[self.input_key_l].other_key
      ENTS[key]:set_output()
    elseif ENTS[self.input_key_l].type == 'transport_belt' then
      ENTS[self.input_key_l]:set_curved()
    end
  end

  if ENTS[self.input_key_r] then
    if ENTS[self.input_key_r].type == 'splitter' then
      ENTS[self.input_key_r]:set_output()
    elseif ENTS[self.input_key_r].type == 'dummy_splitter' then
      local key = ENTS[self.input_key_r].other_key
      ENTS[key]:set_output()
    elseif ENTS[self.input_key_r].type == 'transport_belt' then
      ENTS[self.input_key_r]:set_curved()
    end
  end

end

function Splitter:input(item_id, lane)
  if self.shift then
    if self.lanes.right[lane][8] == 0 then
      self.lanes.right[lane][8] = item_id
      return true
    elseif self.lanes.left[lane][8] == 0 then
      self.lanes.left[lane][8] = item_id
      return true
    end
  else
    if self.lanes.left[lane][8] == 0 then
      self.lanes.left[lane][8] = item_id
      return true
    elseif self.lanes.right[lane][8] == 0 then
      self.lanes.right[lane][8] = item_id
      return true
    end
  end
  return false
end

function Splitter.give_inserter(self, side)
  if side == 'left' then
    for i = 1, 2 do
      for j = 1, 8 do
        if self.lanes.left[i][j] ~= 0 then
          local item = self.lanes.left[i][j]
          self.lanes.left[i][j] = 0
          return item
        end
      end
    end
  else
    for i = 1, 2 do
      for j = 1, 8 do
        if self.lanes.right[i][j] ~= 0 then
          local item = self.lanes.right[i][j]
          self.lanes.right[i][j] = 0
          return item
        end
      end
    end
  end
  return nil
end

function Splitter.update(self)
  if not self.updated then
    self.shift = not self.shift
    self.updated = true
    for i = 1, 2 do
      for j = 1, 8 do
        if j == 1 then
          local l, r = ENTS[self.output_key_l], ENTS[self.output_key_r]
          if self.output_l ~= nil and l and self.lanes.left[i][1] ~= 0 then
            if l.type == 'splitter' or l.type == 'dummy_splitter' then
              local key = self.output_key_l
              if ENTS[key].type == 'dummy_splitter' then key = ENTS[self.output_key_l].other_key end
              if not ENTS[key].updated then ENTS[key]:update() end
              if ENTS[key]:input(self.lanes.left[i][1], 2) then
                self.lanes.left[i][1] = 0
              end
            elseif l.type == 'transport_belt' then
              if not l.updated then ENTS[self.output_key_l]:update() end
              if l.id == BELT_ID_CURVED and l.lanes[i][8] == 0 then
                --add item to other belt
                ENTS[self.output_key_l].lanes[i][8] = self.lanes.left[i][1]
                --remove item from self
                self.lanes.left[i][1] = 0
              elseif l.lanes[self.output_l[i].lane][self.output_l[i].slot] == 0 then
                ENTS[self.output_key_l].lanes[self.output_l[i].lane][self.output_l[i].slot] = self.lanes.left[i][1]
                --ENTS[self.output_key].idle = false
                self.lanes.left[i][1] = 0                
              end
            elseif l.type == 'underground_belt' then
              if not l.updated then ENTS[self.output_key_l]:update() end
              if l.lanes[self.output_l[i].lane][self.output_l[i].slot] == 0 then
                ENTS[self.output_key_l].lanes[self.output_l[i].lane][self.output_l[i].slot] = self.lanes.left[i][1]
                --ENTS[self.output_key].idle = false
                self.lanes.left[i][1] = 0
              end
            elseif l.type == 'underground_belt_exit' then

            end
          end
          
          if self.output_r ~= nil and r and self.lanes.right[i][1] ~= 0 then
            if r.type == 'splitter' or r.type == 'dummy_splitter' then
              local key = self.output_key_r
              if r.type == 'dummy_splitter' then key = r.other_key end
              if not ENTS[key].updated then ENTS[key]:update() end
              if ENTS[key]:input(self.lanes.right[i][1], 2) then
                self.lanes.right[i][1] = 0
              end
            elseif r.type == 'transport_belt' and r.lanes[i][8] == 0 then
              if not r.updated then ENTS[self.output_key_r]:update() end
              if r.id == BELT_ID_CURVED and r.lanes[i][8] == 0 then
                --add item to other belt
                ENTS[self.output_key_r].lanes[i][8] = self.lanes.right[i][1]
                --remove item from self
                self.lanes.right[i][1] = 0
              elseif r.lanes[self.output_r[i].lane][self.output_r[i].slot] == 0 then
                ENTS[self.output_key_r].lanes[self.output_r[i].lane][self.output_r[i].slot] = self.lanes.right[i][1]
                --ENTS[self.output_key].idle = false
                self.lanes.right[i][1] = 0
              end
            elseif r.type == 'underground_belt' then
              if not r.updated then ENTS[self.output_key_r]:update() end
              if r.lanes[self.output_r[i].lane][self.output_r[i].slot] == 0 then
                ENTS[self.output_key_r].lanes[self.output_r[i].lane][self.output_r[i].slot] = self.lanes.right[i][1]
                --ENTS[self.output_key].idle = false
                self.lanes.right[i][1] = 0
              end
            elseif r.type == 'underground_belt_exit' then

            end
          end
        else
          --left
          if self.lanes.left[i][j] ~= 0 and self.lanes.left[i][j - 1] == 0 then
            self.lanes.left[i][j - 1] = self.lanes.left[i][j]
            self.lanes.left[i][j] = 0
          end
          --flip

          --right
          if self.lanes.right[i][j] ~= 0 and self.lanes.right[i][j - 1] == 0 then
            self.lanes.right[i][j - 1] = self.lanes.right[i][j]
            self.lanes.right[i][j] = 0
          end
        end
      end
    end
  end
end

function Splitter.draw(self)
  if not self.drawn then
    self.drawn = true
    local rot_map = SPLITTER_ROTATION_MAP[self.rot]
    local wx, wy = world_to_screen(self.x, self.y)
    sspr(BELT_ID_STRAIGHT + BELT_TICK, wx, wy, BELT_COLORKEY, 1, 0, self.rot)
    sspr(BELT_ID_STRAIGHT + BELT_TICK, wx + (rot_map.x * 8), wy + (rot_map.y * 8), BELT_COLORKEY, 1, 0, self.rot)

    -- if ENTS[self.output_key_l] then
    --   if ENTS[self.output_key_l].type == 'transport_belt' then
    --     if not ENTS[self.output_key_l].belt_drawn then ENTS[self.output_key_l]:draw() end
    --     if not ENTS[self.output_key_l].drawn then ENTS[self.output_key_l]:draw_items() end
    --   elseif ENTS[self.output_key_l].type == 'splitter' then
    --     if not ENTS[self.output_key_l].drawn then ENTS[self.output_key_l]:draw() end
    --   elseif ENTS[self.output_key_l].type == 'dummy_splitter' then
    --     local key = ENTS[self.output_key_l].other_key
    --     if not ENTS[key].drawn then ENTS[key]:draw() end
    --   end
    -- end

    -- if ENTS[self.output_key_r] then
    --   if ENTS[self.output_key_r].type == 'transport_belt' then
    --     if not ENTS[self.output_key_r].belt_drawn then ENTS[self.output_key_r]:draw() end
    --     if not ENTS[self.output_key_r].drawn then ENTS[self.output_key_r]:draw_items() end
    --   elseif ENTS[self.output_key_r].type == 'splitter' then
    --     if not ENTS[self.output_key_r].drawn then ENTS[self.output_key_r]:draw() end
    --   elseif ENTS[self.output_key_r].type == 'dummy_splitter' then
    --     local key = ENTS[self.output_key_r].other_key
    --     if not ENTS[key].drawn then ENTS[key]:draw() end
    --   end
    -- end
    if ENTS[self.output_key_r] and ENTS[self.output_key_r].type == 'transport_belt' then
      if ENTS[self.output_key_r].belt_drawn == false then ENTS[self.output_key_r]:draw() end
      ENTS[self.output_key_r]:draw_items()
      --if ENTS[self.output_key_r].drawn == false then ENTS[self.output_key_r]:draw_items() end
    end
    if ENTS[self.output_key_l] and ENTS[self.output_key_l].type == 'transport_belt' then
      if ENTS[self.output_key_l].belt_drawn == false then ENTS[self.output_key_l]:draw() end
      --if ENTS[self.output_key_l].drawn == false then ENTS[self.output_key_l]:draw_items() end
      ENTS[self.output_key_l]:draw_items()
    end
    --if ENTS[self.output_key_l] and ENTS[self.output_key_l].type == 'transport_belt' and not ENTS[self.output_key_l].belt_drawn and ENTS[self.output_key_l].drawn then ENTS[self.output_key_l]:draw_items() end
    self:draw_items()
    sspr(SPLITTER_ID, wx, wy, 0, 1, 0, self.rot, 1, 2)
    --spr(SPLITTER_ID, wx, wy, 0, 1, 0, self.rot, 1)
    --spr(SPLITTER_ID, wx + rot_map.x, wy + rot_map.y, 0, 1, 0, self.rot)
  end
end

function Splitter.draw_items(self)
  --if not self.drawn then
   -- self.drawn = true
    local item_map = SPLITTER_ITEM_MAP[self.rot]
    local a, b, c, d = item_map.a, item_map.b, item_map.c, item_map.d
    local wx, wy = world_to_screen(self.x, self.y)

    -- for i = 1, 2 do
    --   for j = 1, 8 do
    --     if self.lanes.right[i][j] ~= 0 then
    --       local sprite_id = ITEMS[self.lanes[i][j]].sprite_id
    --       sspr(sprite_id)
    --     end
    --   end
    -- end
  local function get_id(side, lane, slot)
    if side == 1 then --left
      return ITEMS[self.lanes.left[lane][slot]]
    else
      return ITEMS[self.lanes.right[lane][slot]]
    end
  end


    for k = 1, 8 do
      if self.rot == 0 then
        if self.lanes.right[1][k] ~= 0 then local item = get_id(0, 1, k) sspr(item.belt_id, wx + a.x + (k - 1), wy + a.y, item.color_key) end
        if self.lanes.right[2][k] ~= 0 then local item = get_id(0, 2, k) sspr(item.belt_id, wx + b.x + (k - 1), wy + b.y, item.color_key) end
        if self.lanes.left[1][k] ~= 0  then local item = get_id(1, 1, k) sspr(item.belt_id, wx + c.x + (k - 1), wy + c.y, item.color_key) end
        if self.lanes.left[2][k] ~= 0  then local item = get_id(1, 2, k) sspr(item.belt_id, wx + d.x + (k - 1), wy + d.y, item.color_key) end
      elseif self.rot == 1 then
        if self.lanes.right[1][k] ~= 0 then local item = get_id(0, 1, k) sspr(item.belt_id, wx + a.x, wy + a.y + (k - 1), item.color_key) end
        if self.lanes.right[2][k] ~= 0 then local item = get_id(0, 2, k) sspr(item.belt_id, wx + b.x, wy + b.y + (k - 1), item.color_key) end
        if self.lanes.left[1][k] ~= 0  then local item = get_id(1, 1, k) sspr(item.belt_id, wx + c.x, wy + c.y + (k - 1), item.color_key) end
        if self.lanes.left[2][k] ~= 0  then local item = get_id(1, 2, k) sspr(item.belt_id, wx + d.x, wy + d.y + (k - 1), item.color_key) end
      elseif self.rot == 2 then
        if self.lanes.right[1][k] ~= 0 then local item = get_id(0, 1, k) sspr(item.belt_id, wx + a.x - (k - 1), wy + a.y, item.color_key) end
        if self.lanes.right[2][k] ~= 0 then local item = get_id(0, 2, k) sspr(item.belt_id, wx + b.x - (k - 1), wy + b.y, item.color_key) end
        if self.lanes.left[1][k] ~= 0  then local item = get_id(1, 1, k) sspr(item.belt_id, wx + c.x - (k - 1), wy + c.y, item.color_key) end
        if self.lanes.left[2][k] ~= 0  then local item = get_id(1, 2, k) sspr(item.belt_id, wx + d.x - (k - 1), wy + d.y, item.color_key) end
      else
        if self.lanes.right[1][k] ~= 0 then local item = get_id(0, 1, k) sspr(item.belt_id, wx + a.x, wy + a.y - (k - 1), item.color_key) end
        if self.lanes.right[2][k] ~= 0 then local item = get_id(0, 2, k) sspr(item.belt_id, wx + b.x, wy + b.y - (k - 1), item.color_key) end
        if self.lanes.left[1][k] ~= 0  then local item = get_id(1, 1, k) sspr(item.belt_id, wx + c.x, wy + c.y - (k - 1), item.color_key) end
        if self.lanes.left[2][k] ~= 0  then local item = get_id(1, 2, k) sspr(item.belt_id, wx + d.x, wy + d.y - (k - 1), item.color_key) end
      end
    end

  -- if self.lanes.left[i][k] ~= 0 then 
  --   local id = self.lanes.left[i][k]
  --   sspr(297, wx + k - 1, wy + (i*4) - 4, 0)
  -- end


  -- if self.lanes.right[i][k] ~= 0 then 
  --   local id = self.lanes.left[i][k]
  --   sspr(297, wx + k - 1, wy + (i*8) - 8, 0)
  -- end
end

function Splitter:item_request(id)
  for i = 1, 2 do
    for j = 8, 1, -1 do
      local side = (self.lanes.left[i][j] > 0 and {id = self.lanes.left[i][j], lane = 'left'}) or (self.lanes.right[i][j] > 0 and {id = self.lanes.right[i][j], lane = 'right'})
      local item = side and ITEMS[side.id]
      if item then
        if item.type == id or side.id == id or id == 'any' then
          if side.lane == 'left' then
            self.lanes.left[i][j] = 0
          elseif side.lane == 'right' then
            self.lanes.right[i][j] = 0
          end
          return item.id
        end
      end
      -- if self.lanes.left[i][j] == id or (self.lanes.left[i][j] ~= 0 and id == 'any') then
      --   return self.lanes.left[i][j]
      -- end
      -- if self.lanes.right[i][j] == id or (self.lanes.right[i][j] ~= 0 and id == 'any') then
      --   return self.lanes.right[i][j]
      -- end
    end
  end
  return false
end

function Splitter:request_deposit()
  return 'any'
end

function Splitter:deposit(id, other_rot)
  local lane = INSERTER_DEPOSIT_MAP[other_rot][self.rot]
  return self:input(id, lane)
  -- for i = 8, 1, -1 do
  --   if self.lanes.left[lane][i] == 0 then
  --     self.lanes.left[lane][i] = id
  --     return true
  --   end
  -- end
  -- return false
end

function Splitter:return_all()
  local item_stacks = {}
  for i = 1, 2 do
    for j = 1, 8 do
      if self.lanes.left[i][j] > 0 then
        local id = self.lanes.left[i][j]
        if not item_stacks[id] then item_stacks[id] = 0 end
        item_stacks[id] = item_stacks[id] + 1
        self.lanes.left[i][j] = 0
      end
      if self.lanes.right[i][j] > 0 then
        local id = self.lanes.right[i][j]
        if not item_stacks[id] then item_stacks[id] = 0 end
        item_stacks[id] = item_stacks[id] + 1
        self.lanes.right[i][j] = 0
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

function new_splitter(x, y, rot)
  local new_splitter = {x = x, y = y, rot = rot}
  setmetatable(new_splitter, {__index = Splitter})
  new_splitter.lanes = {}
  new_splitter.lanes.left = {}
  new_splitter.lanes.right = {}
  for i = 1, 2 do
    new_splitter.lanes.left[i] = {}
    new_splitter.lanes.right[i] = {}
    for j = 1, 8 do
      new_splitter.lanes.left[i][j] = 0
      new_splitter.lanes.right[i][j] = 0
    end
  end
  --new_splitter:set_output()
  return new_splitter
end