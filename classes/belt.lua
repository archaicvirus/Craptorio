BELT_ID_CURVED = 277
BELT_ID_STRAIGHT = 342

local belt = {
  pos = {x = 0, y = 0},
  rot = 0,
  sprite_rot = 0,
  flip = 0,
  lanes = {[1] = {}, [2] = {}},
  id = BELT_ID_STRAIGHT,
  type = 'straight',
  updated = false,
  drawn = false,
  output_key = nil,
  output_item_key = nil,
  output = nil,
  exit = {x = -8, y = 0},
}

BELT_OUTPUT_MAP = {
  ['00'] = {[1] = {a = 1, b = 8}, [2] = {a = 2, b = 8}},
  ['01'] = {[1] = {a = 1, b = 4}, [2] = {a = 1, b = 6}},
  ['02'] = nil,
  ['03'] = {[1] = {a = 2, b = 6}, [2] = {a = 2, b = 4}},
  ['10'] = {[1] = {a = 2, b = 1}, [2] = {a = 2, b = 4}},
  ['11'] = {[1] = {a = 1, b = 8}, [2] = {a = 2, b = 8}},
  ['12'] = {[1] = {a = 1, b = 5}, [2] = {a = 1, b = 3}},
  ['13'] = nil,
  ['20'] = nil,
  ['21'] = {[1] = {a = 2, b = 4}, [2] = {a = 2, b = 6}},
  ['22'] = {[1] = {a = 1, b = 8}, [2] = {a = 2, b = 8}},
  ['23'] = {[1] = {a = 1, b = 4}, [2] = {a = 1, b = 6}},
  ['30'] = {[1] = {a = 1, b = 1}, [2] = {a = 1, b = 4}},
  ['31'] = nil,
  ['32'] = {[1] = {a = 2, b = 6}, [2] = {a = 2, b = 4}},
  ['33'] = {[1] = {a = 1, b = 8}, [2] = {a = 2, b = 8}}
}

BELT_CURVED_ITEM_MAP = {
  ['01'] = {
    [1] = {[1] = {x =  5, y =  0}, [2] = {x =  1, y =  0}},
    [2] = {[1] = {x =  5, y =  0}, [2] = {x =  1, y =  1}},
    [3] = {[1] = {x =  5, y =  0}, [2] = {x =  1, y =  2}},
    [4] = {[1] = {x =  5, y =  0}, [2] = {x =  2, y =  3}},
    [5] = {[1] = {x =  5, y =  0}, [2] = {x =  3, y =  4}},
    [6] = {[1] = {x =  5, y =  0}, [2] = {x =  4, y =  4}},
    [7] = {[1] = {x =  6, y =  0}, [2] = {x =  5, y =  4}},
    [8] = {[1] = {x =  7, y =  0}, [2] = {x =  7, y =  4}},
  },
  ['00'] = {
    [1] = {[1] = {x =  0, y =  0}, [2] = {x =  0, y =  4}},
    [2] = {[1] = {x =  1, y =  0}, [2] = {x =  1, y =  4}},
    [3] = {[1] = {x =  2, y =  0}, [2] = {x =  2, y =  4}},
    [4] = {[1] = {x =  3, y =  0}, [2] = {x =  3, y =  4}},
    [5] = {[1] = {x =  4, y =  0}, [2] = {x =  4, y =  4}},
    [6] = {[1] = {x =  5, y =  0}, [2] = {x =  5, y =  4}},
    [7] = {[1] = {x =  6, y =  0}, [2] = {x =  6, y =  4}},
    [8] = {[1] = {x =  7, y =  0}, [2] = {x =  7, y =  4}},
  },
  ['03'] = {
    [1] = {[1] = {x =  0, y =  5}, [2] = {x =  4, y =  5}},
    [2] = {[1] = {x =  0, y =  4}, [2] = {x =  4, y =  5}},
    [3] = {[1] = {x =  0, y =  3}, [2] = {x =  4, y =  5}},
    [4] = {[1] = {x =  0, y =  2}, [2] = {x =  4, y =  5}},
    [5] = {[1] = {x =  1, y =  1}, [2] = {x =  5, y =  4}},
    [6] = {[1] = {x =  2, y =  0}, [2] = {x =  5, y =  4}},
    [7] = {[1] = {x =  4, y =  0}, [2] = {x =  6, y =  4}},
    [8] = {[1] = {x =  7, y =  0}, [2] = {x =  7, y =  4}},
  },
  ['10'] = {
    [1] = {[1] = {x =  0, y =  0}, [2] = {x =  0, y =  4}},
    [2] = {[1] = {x =  1, y =  0}, [2] = {x =  0, y =  4}},
    [3] = {[1] = {x =  2, y =  0}, [2] = {x =  1, y =  5}},
    [4] = {[1] = {x =  3, y =  0}, [2] = {x =  1, y =  5}},
    [5] = {[1] = {x =  4, y =  1}, [2] = {x =  1, y =  6}},
    [6] = {[1] = {x =  5, y =  3}, [2] = {x =  1, y =  6}},
    [7] = {[1] = {x =  5, y =  5}, [2] = {x =  1, y =  7}},
    [8] = {[1] = {x =  5, y =  7}, [2] = {x =  1, y =  7}},
  },
  ['11'] = {
    [1] = {[1] = {x =  5, y =  0}, [2] = {x =  1, y =  0}},
    [2] = {[1] = {x =  5, y =  1}, [2] = {x =  1, y =  1}},
    [3] = {[1] = {x =  5, y =  2}, [2] = {x =  1, y =  2}},
    [4] = {[1] = {x =  5, y =  3}, [2] = {x =  1, y =  3}},
    [5] = {[1] = {x =  5, y =  4}, [2] = {x =  1, y =  4}},
    [6] = {[1] = {x =  5, y =  5}, [2] = {x =  1, y =  5}},
    [7] = {[1] = {x =  5, y =  6}, [2] = {x =  1, y =  6}},
    [8] = {[1] = {x =  5, y =  7}, [2] = {x =  1, y =  7}},
  },
  ['12'] = {
    [1] = {[1] = {x =  5, y =  5}, [2] = {x =  5, y =  1}},
    [2] = {[1] = {x =  5, y =  5}, [2] = {x =  4, y =  1}},
    [3] = {[1] = {x =  5, y =  5}, [2] = {x =  3, y =  1}},
    [4] = {[1] = {x =  5, y =  5}, [2] = {x =  2, y =  2}},
    [5] = {[1] = {x =  5, y =  5}, [2] = {x =  1, y =  4}},
    [6] = {[1] = {x =  5, y =  5}, [2] = {x =  1, y =  5}},
    [7] = {[1] = {x =  5, y =  6}, [2] = {x =  1, y =  6}},
    [8] = {[1] = {x =  5, y =  7}, [2] = {x =  1, y =  7}},
  },
  ['21'] = {
    [1] = {[1] = {x =  5, y =  0}, [2] = {x =  1, y =  0}},
    [2] = {[1] = {x =  5, y =  2}, [2] = {x =  1, y =  0}},
    [3] = {[1] = {x =  5, y =  3}, [2] = {x =  0, y =  1}},
    [4] = {[1] = {x =  5, y =  3}, [2] = {x =  0, y =  1}},
    [5] = {[1] = {x =  4, y =  4}, [2] = {x = -1, y =  1}},
    [6] = {[1] = {x =  3, y =  5}, [2] = {x = -1, y =  1}},
    [7] = {[1] = {x =  1, y =  5}, [2] = {x = -2, y =  1}},
    [8] = {[1] = {x =  0, y =  5}, [2] = {x = -2, y =  1}},
  },
  ['22'] = {
    [1] = {[1] = {x =  5, y =  5}, [2] = {x =  5, y =  1}},
    [2] = {[1] = {x =  4, y =  5}, [2] = {x =  4, y =  1}},
    [3] = {[1] = {x =  3, y =  5}, [2] = {x =  3, y =  1}},
    [4] = {[1] = {x =  2, y =  5}, [2] = {x =  2, y =  1}},
    [5] = {[1] = {x =  1, y =  5}, [2] = {x =  1, y =  1}},
    [6] = {[1] = {x =  0, y =  5}, [2] = {x =  0, y =  1}},
    [7] = {[1] = {x = -1, y =  5}, [2] = {x = -1, y =  1}},
    [8] = {[1] = {x = -2, y =  5}, [2] = {x = -2, y =  1}},
  },
  ['23'] = {
    [1] = {[1] = {x =  0, y =  5}, [2] = {x =  4, y =  5}},
    [2] = {[1] = {x =  0, y =  5}, [2] = {x =  4, y =  4}},
    [3] = {[1] = {x =  0, y =  5}, [2] = {x =  4, y =  3}},
    [4] = {[1] = {x =  0, y =  5}, [2] = {x =  3, y =  2}},
    [5] = {[1] = {x =  0, y =  5}, [2] = {x =  2, y =  1}},
    [6] = {[1] = {x =  0, y =  5}, [2] = {x =  0, y =  1}},
    [7] = {[1] = {x = -1, y =  5}, [2] = {x = -1, y =  1}},
    [8] = {[1] = {x = -2, y =  5}, [2] = {x = -2, y =  1}},
  },
  ['30'] = {
    [1] = {[1] = {x =  0, y =  0}, [2] = {x =  0, y =  4}},
    [2] = {[1] = {x =  0, y =  0}, [2] = {x =  1, y =  4}},
    [3] = {[1] = {x =  0, y =  0}, [2] = {x =  2, y =  4}},
    [4] = {[1] = {x =  0, y =  0}, [2] = {x =  3, y =  3}},
    [5] = {[1] = {x =  0, y = -1}, [2] = {x =  4, y =  2}},
    [6] = {[1] = {x =  0, y = -1}, [2] = {x =  4, y =  1}},
    [7] = {[1] = {x =  0, y = -2}, [2] = {x =  4, y = -1}},
    [8] = {[1] = {x =  0, y = -2}, [2] = {x =  4, y = -2}},
  },
  ['33'] = {
    [1] = {[1] = {x =  0, y =  5}, [2] = {x =  4, y =  5}},
    [2] = {[1] = {x =  0, y =  4}, [2] = {x =  4, y =  4}},
    [3] = {[1] = {x =  0, y =  3}, [2] = {x =  4, y =  3}},
    [4] = {[1] = {x =  0, y =  2}, [2] = {x =  4, y =  2}},
    [5] = {[1] = {x =  0, y =  1}, [2] = {x =  4, y =  1}},
    [6] = {[1] = {x =  0, y =  0}, [2] = {x =  4, y =  0}},
    [7] = {[1] = {x =  0, y = -1}, [2] = {x =  4, y = -1}},
    [8] = {[1] = {x =  0, y = -2}, [2] = {x =  4, y = -2}},
  },
  ['32'] = {
    [1] = {[1] = {x =  5, y =  5}, [2] = {x =  5, y =  1}},
    [2] = {[1] = {x =  4, y =  5}, [2] = {x =  5, y =  1}},
    [3] = {[1] = {x =  3, y =  5}, [2] = {x =  5, y =  1}},
    [4] = {[1] = {x =  1, y =  4}, [2] = {x =  4, y =  0}},
    [5] = {[1] = {x =  0, y =  2}, [2] = {x =  4, y =  0}},
    [6] = {[1] = {x =  0, y =  0}, [2] = {x =  4, y = -1}},
    [7] = {[1] = {x =  0, y = -1}, [2] = {x =  4, y = -2}},
    [8] = {[1] = {x =  0, y = -2}, [2] = {x =  4, y = -2}},
  },
}

BELT_ROTATION_MAP = {
  [0] = {x = -8, y =  0},
  [1] = {x =  0, y = -8},
  [2] = {x =  8, y =  0},
  [3] = {x =  0, y =  8},
}
 
BELT_CURVE_MAP = {
  [0] = {
    [1] = {x = 0, y = -8, flip = 2, rot = 1, key = '30'},
    [2] = {x = 8, y =  0},
    [3] = {x = 0, y =  8, flip = 0, rot = 1, key = '10'},
  },
  [1] = {
    [1] = {x = -8, y =  0, flip = 0, rot = 2, key = '21'},
    [2] = {x =  0, y =  8},
    [3] = {x =  8, y =  0, flip = 1, rot = 2, key = '01'},
  },
  [2] = {
    [1] = {x =  0, y = -8, flip = 0, rot = 3, key = '32'},
    [2] = {x = -8, y =  0},
    [3] = {x =  0, y =  8, flip = 2, rot = 3, key = '12'},
  },
  [3] = {
    --right up
    [1] = {x = -8, y =  0, flip = 1, rot = 0, key = '23'},
    [2] = {x =  0, y = -8},
    [3] = {x =  8, y =  0, flip = 0, rot = 0, key = '03'},
  }
}

function belt.rotate(self, rotation)
  self.exit = BELT_ROTATION_MAP[rotation]
  self.rot = rotation
  self:set_output()
end

function belt.is_facing(self, other)
  if BELTS[self.output_key] ~= nil then
    if BELTS[self.output_key] == other then return true end
  end
    return false
end

function belt.set_output(self)
  self.exit = BELT_ROTATION_MAP[self.rot]
  local key = tostring(self.pos.x + self.exit.x) .. '-' .. tostring(self.pos.y + self.exit.y)
  if BELTS[key] then
    self.output_key = key
    local index = self.rot .. BELTS[key].rot
    self.output = BELT_OUTPUT_MAP[index]
  else
    self.output = nil
    self.output_key = nil
  end
  if self.id == BELT_ID_STRAIGHT then
    self.output_item_key = self.rot .. self.rot
  end
end

function belt.set_curved(self)
  --checks left, right, and rear tiles (relative to belts rotation) for other belts
  --belts only curve if loc2 (rear input) is not facing me, loc1 XOR loc3, else belt is straight
  --loc1 = left input
  --loc2 = rear input
  --loc3 = right input
  local key = tostring(self.pos.x) .. '-' .. tostring(self.pos.y)
  local x, y = self.pos.x, self.pos.y
  local loc1, loc2, loc3 = table.unpack(BELT_CURVE_MAP[self.rot])
  local key1, key2, key3 = loc1.x + x .. '-' .. loc1.y + y, loc2.x + x .. '-' .. loc2.y + y, loc3.x + x .. '-' .. loc3.y + y
  if not BELTS[key2] or (BELTS[key2] and not BELTS[key2]:is_facing(self)) then
    --no input belt facing same direction eg. <-<- or ->->
    if BELTS[key1] and BELTS[key1]:is_facing(self) and (not BELTS[key3] or not BELTS[key3]:is_facing(self)) then
      --found a belt to the left, and belt is facing me, and no other belts are facing me
      self.id, self.flip, self.sprite_rot, self.output_item_key = BELT_ID_CURVED, loc1.flip, loc1.rot, loc1.key
    elseif BELTS[key3] and BELTS[key3]:is_facing(self) and (not BELTS[key1] or not BELTS[key1]:is_facing(self)) then
      --found a belt to the right, and belt is facing me, and no other belts are facing me
      self.id, self.flip, self.sprite_rot, self.output_item_key = BELT_ID_CURVED, loc3.flip, loc3.rot, loc3.key
    elseif (BELTS[key3] and BELTS[key3]:is_facing(self) and BELTS[key1] and BELTS[key1]:is_facing(self)) or (not BELTS[key1] and not BELTS[key3]) then
      self.id = BELT_ID_STRAIGHT
      self.output_item_key = self.rot .. self.rot
    end 
  else
    self.id = BELT_ID_STRAIGHT
    self.output_item_key = self.rot .. self.rot
  end
  self:set_output()
end

function belt.update(self)
  -- if we have NOT updated this frame, continue
  if self.updated == false then
    self.updated = true
    for i = 1, 2 do
      --check each lane
      for j = 1, 8 do
        --check each lane's slots for an item (0 means no item, else number is an ITEM id)
        local id = self.lanes[i][j]
        if j == 1 and id ~= 0 then
          --if we are the 1st slot (closest to output), check next tile for a belt to output to
          local key = tostring(self.pos.x + self.exit.x) .. '-' .. tostring(self.pos.y + self.exit.y)
          if not BELTS[key] then self.output = nil end
          if self.output ~= nil and BELTS[key] then
            --if i am facing another belt, update that belt first
            if not BELTS[key].updated then BELTS[key]:update() end
            --if we find a belt, and the belts nearest slot is empty (equals 0) then
            --move item to that belt
            if BELTS[self.output_key].id == BELT_ID_CURVED and BELTS[self.output_key].lanes[i][8] == 0 then
              --add item to other belt
              BELTS[self.output_key].lanes[i][8] = id
              --remove item from self
              self.lanes[i][j] = 0
            elseif BELTS[self.output_key].lanes[self.output[i].a][self.output[i].b] == 0 then
              BELTS[self.output_key].lanes[self.output[i].a][self.output[i].b] = id
              self.lanes[i][j] = 0
            end
          end
        elseif id ~= 0 and j > 1 and j < 9 and self.lanes[i][j-1] == 0 then
          --shift item up 1-index if next slot is empty -> (== 0)
          self.lanes[i][j-1] = id
          --set current space as empty now
          self.lanes[i][j] = 0
        end
      end
    end
    --set flag so we don't update twice in certain cases
    self.updated = true
  end
  --return true
end

function belt.draw(self)
  local rot = self.rot
  if self.id == BELT_ID_CURVED then rot = self.sprite_rot end
  spr(self.id + BELT_TICK, self.pos.x, self.pos.y, 00, 1, self.flip, rot, 1, 1)
end

function belt.draw_items(self)
  self.drawn = true
  if self.output_key ~= nil and not BELTS[self.output_key].drawn then BELTS[self.output_key]:draw_items() end
  local item_locations = BELT_CURVED_ITEM_MAP[self.output_item_key]
  for i = 1, 2 do
    for j = 1, 8 do
      if self.lanes[i][j] > 0 then
        local x, y = item_locations[j][i].x + self.pos.x, item_locations[j][i].y + self.pos.y
        draw_pixel_sprite(self.lanes[i][j], x, y)
      end
    end
  end
end

return function(pos, rotation, children)
  local new_belt = {pos = pos, rot = rotation or 0}
  new_belt.id = BELT_ID_STRAIGHT
  if children then
    new_belt.lanes = children
  else
    new_belt.lanes = {}
    for i = 1, 2 do
      new_belt.lanes[i] = {}
      for j = 1, 8 do
        new_belt.lanes[i][j] = 0
      end
    end
  end
  setmetatable(new_belt, {__index = belt})
  new_belt:rotate(rotation)
  return new_belt
end
