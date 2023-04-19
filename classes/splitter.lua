SPLITTER_ID       = 343
SPLITTER_ID_TOP   = 409
SPLITTER_ID_BTM   = 425
SPLITTER_TICKRATE = 5

SPLITTER_ROTATION_MAP = {
  --x,y is for drawing second splitter half
  [0] = {x = 0, y =  1},
  [1] = {x = 1, y =  0},
  [2] = {x = 0, y =  1},
  [3] = {x = 1, y =  0},
}

SPLITTER_OUTPUT_MAP = {
  [0] = {left = {x = -1, y =  1}, right = {x = -1, y =  0}},
  [1] = {left = {x =  0, y = -1}, right = {x =  1, y = -1}},
  [2] = {left = {x =  1, y =  0}, right = {x =  1, y =  1}},
  [3] = {left = {x =  1, y =  1}, right = {x =  0, y = -1}}
}

SPLITTER_ITEM_MAP = {
  [0] = {a = {x = 0, y = 0}, b = {x = 0, y = 5}, c = {x = 0, y = 8}, d = {x = 0, y = 13}},
  [1] = {a = {x = 13, y = 0}, b = {x = 8, y = 0}, c = {x = 5, y = 0}, d = {x = 0, y = 0}},
  [2] = {a = {x = 5, y = 13}, b = {x = 5, y = 9}, c = {x = 5, y = 5}, d = {x = 5, y = 1}},
  [3] = {a = {x = 0, y = 5}, b = {x = 5, y = 5}, c = {x = 8, y = 5}, d = {x = 12, y = 5}},
}

local Splitter = {
  x = 0,
  y = 0,
  rot = 0,
  type = 'splitter',
  key2 = '',
  is_hovered = false,
  lanes = {left = {}, right = {}},
  shift = false,
  output_key_l = 'nil',
  output_key_r = 'nil',
  input_key_l  = 'nil',
  input_key_r  = 'nil',
  updated = false,
  other_key = 'nil',
}

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
  local output_map = SPLITTER_OUTPUT_MAP[self.rot]
  self.output_key_l = self.x + output_map.left.x .. '-' .. self.y + output_map.left.y
  self.output_key_r = self.x + output_map.right.x .. '-' .. self.y + output_map.right.y
  if ENTS[self.output_key_l] and ENTS[self.output_key_l].type == 'transport_belt' then
    --trace('SPLITTER - setting belt at ' .. self.output_key_l .. ' to curved')
    --ENTS[self.output_key_l]:set_curved()
    ENTS[self.output_key_l]:update_neighbors()
  end
  if ENTS[self.output_key_r] and ENTS[self.output_key_r].type == 'transport_belt' then
    --trace('SPLITTER - setting belt at ' .. self.output_key_r .. ' to curved')
    --ENTS[self.output_key_r]:set_curved()
    ENTS[self.output_key_r]:update_neighbors()
  end
end

function Splitter.update(self)
  self.updated = true
  self.shift = not self.shift
  for i = 1, 2 do
    for j = 1, 8 do
      if j == 1 then
        --local l, r = ENTS[self.output_key_l], ENTS[self.output_key_r]
        if ENTS[self.output_key_l] and not ENTS[self.output_key_l].updated then ENTS[self.output_key_l]:update() end
        if ENTS[self.output_key_r] and not ENTS[self.output_key_r].updated then ENTS[self.output_key_r]:update() end

        if self.lanes.left[i][j] ~= 0 and ENTS[self.output_key_l] and ENTS[self.output_key_l].type == 'transport_belt' and ENTS[self.output_key_l].lanes[i][8] == 0 then
          trace('SPLITTER: belt output detected LEFT')
          ENTS[self.output_key_l].lanes[i][8] = self.lanes.left[i][j]
          ENTS[self.output_key_l].idle = false
          self.lanes.left[i][j] = 0
        end

        if self.lanes.right[i][j] ~= 0 and ENTS[self.output_key_r] and ENTS[self.output_key_r].type == 'transport_belt' and ENTS[self.output_key_r].lanes[i][8] == 0 then
          trace('SPLITTER: belt output detected RIGHT')
          ENTS[self.output_key_r].lanes[i][8] = self.lanes.right[i][j]
          ENTS[self.output_key_r].idle = false
          self.lanes.right[i][j] = 0
        end


        --left
        -- if self.lanes.left[i][j] ~= 0 and
        -- ENTS[self.output_key_l] and
        -- ENTS[self.output_key_l].type == 'transport_belt' and
        -- ENTS[self.output_key_l].lanes[i][8] == 0 then          
        --     ENTS[self.output_key_l].lanes[i][8] = self.lanes.left[i][j]
        --     self.lanes.left[i][j] = 0
        -- end
        -- --right
        -- if self.lanes.right[i][j] ~= 0 and
        -- ENTS[self.output_key_l] and
        -- ENTS[self.output_key_l].type == 'transport_belt' and
        -- ENTS[self.output_key_l].lanes[i][8] == 0 then
          
        --   ENTS[self.output_key_l].lanes[i][8] = self.lanes.right[i][j]
        --   self.lanes.right[i][j] = 0
        -- end

      else
        --left
        if self.lanes.left[i][j] ~= 0 and self.lanes.left[i][j - 1] == 0 then
          self.lanes.left[i][j - 1] = self.lanes.left[i][j]
          self.lanes.left[i][j] = 0
        end
        --right
        if self.lanes.right[i][j] ~= 0 and self.lanes.right[i][j - 1] == 0 then
          self.lanes.right[i][j - 1] = self.lanes.right[i][j]
          self.lanes.right[i][j] = 0
        end
      end
    end
  end
end

function Splitter.draw(self)
  local rot_map = SPLITTER_ROTATION_MAP[self.rot]
  local wx, wy = world_to_screen(self.x, self.y)
  sspr(BELT_ID_STRAIGHT + BELT_TICK, wx, wy, 0, 1, 0, self.rot)
  sspr(BELT_ID_STRAIGHT + BELT_TICK, wx + (rot_map.x * 8), wy + (rot_map.y * 8), 0, 1, 0, self.rot)
  self:draw_items()
  sspr(SPLITTER_ID, wx, wy, 0, 1, 0, self.rot, 1, 2)
  --spr(SPLITTER_ID, wx, wy, 0, 1, 0, self.rot, 1)
  --spr(SPLITTER_ID, wx + rot_map.x, wy + rot_map.y, 0, 1, 0, self.rot)
end

function Splitter.draw_items(self)
  local item_map = SPLITTER_ITEM_MAP[self.rot]
  local a, b, c, d = item_map.a, item_map.b, item_map.c, item_map.d
  local wx, wy = world_to_screen(self.x, self.y)

  for k = 1, 8 do
    if self.rot == 0 then
      if self.lanes.right[1][k] ~= 0 then sspr(297, wx + a.x + (k - 1), wy + a.y, 0) end
      if self.lanes.right[2][k] ~= 0 then sspr(297, wx + b.x + (k - 1), wy + b.y, 0) end
      if self.lanes.left[1][k] ~= 0  then sspr(297, wx + c.x + (k - 1), wy + c.y, 0) end
      if self.lanes.left[2][k] ~= 0  then sspr(297, wx + d.x + (k - 1), wy + d.y, 0) end
    elseif self.rot == 1 then
      if self.lanes.right[1][k] ~= 0 then sspr(297, wx + a.x, wy + a.y + (k - 1), 0) end
      if self.lanes.right[2][k] ~= 0 then sspr(297, wx + b.x, wy + b.y + (k - 1), 0) end
      if self.lanes.left[1][k] ~= 0  then sspr(297, wx + c.x, wy + c.y + (k - 1), 0) end
      if self.lanes.left[2][k] ~= 0  then sspr(297, wx + d.x, wy + d.y + (k - 1), 0) end
    elseif self.rot == 2 then
      if self.lanes.right[1][k] ~= 0 then sspr(297, wx + a.x - (k - 1), wy + a.y, 0) end
      if self.lanes.right[2][k] ~= 0 then sspr(297, wx + b.x - (k - 1), wy + b.y, 0) end
      if self.lanes.left[1][k] ~= 0  then sspr(297, wx + c.x - (k - 1), wy + c.y, 0) end
      if self.lanes.left[2][k] ~= 0  then sspr(297, wx + d.x - (k - 1), wy + d.y, 0) end
    else
      if self.lanes.right[1][k] ~= 0 then sspr(297, wx + a.x, wy + a.y - (k - 1), 0) end
      if self.lanes.right[2][k] ~= 0 then sspr(297, wx + b.x, wy + b.y - (k - 1), 0) end
      if self.lanes.left[1][k] ~= 0  then sspr(297, wx + c.x, wy + c.y - (k - 1), 0) end
      if self.lanes.left[2][k] ~= 0  then sspr(297, wx + d.x, wy + d.y - (k - 1), 0) end
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

return function(x, y, rot)
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