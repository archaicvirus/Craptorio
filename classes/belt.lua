BELT_ID_CURVED    = 260
BELT_ID_STRAIGHT  = 256
BELT_TICKRATE     = 5
BELT_MAXTICK      = 3
BELT_TICK         = 0

local belt = {
  pos = {x = 0, y = 0},
  world_pos = {x = 0, y = 0},
  rot = 0,
  sprite_rot = 0,
  flip = 0,
  lanes = {[1] = {}, [2] = {}},
  id = BELT_ID_STRAIGHT,
  type = 'transport_belt',
  idle = false,
  updated = false,
  drawn = false,
  output_key = nil,
  output_item_key = nil,
  output = nil,
  exit = {x = -8, y = 0},
  is_hovered = false,
  index = 0,
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
  [0] = {x = -1, y =  0},
  [1] = {x =  0, y = -1},
  [2] = {x =  1, y =  0},
  [3] = {x =  0, y =  1},
}
 
BELT_CURVE_MAP = {
  [0] = {
    [1] = {x =  0, y = -1, flip = 2, rot = 1, key = '30', other_rot = 3},
    [2] = {x =  1, y =  0},
    [3] = {x =  0, y =  1, flip = 0, rot = 1, key = '10', other_rot = 1},
  },
  [1] = {
    [1] = {x = -1, y =  0, flip = 0, rot = 2, key = '21', other_rot = 2},
    [2] = {x =  0, y =  1},
    [3] = {x =  1, y =  0, flip = 1, rot = 2, key = '01', other_rot = 0},
  },
  [2] = {
    [1] = {x =  0, y = -1, flip = 0, rot = 3, key = '32', other_rot = 3},
    [2] = {x = -1, y =  0},
    [3] = {x =  0, y =  1, flip = 2, rot = 3, key = '12', other_rot = 1},
  },
  [3] = {
    [1] = {x = -1, y =  0, flip = 1, rot = 0, key = '23', other_rot = 2},
    [2] = {x =  0, y = -1},
    [3] = {x =  1, y =  0, flip = 0, rot = 0, key = '03', other_rot = 0},
  }
}

function belt.get_info(self)
  local info = {
    [1] = 'ROT: ' .. self.rot,
    [2] = 'SID: ' .. self.id,
    [3] = 'OTK: ' .. self.output_key,
    [4] = 'ITM: ',
    [5] = 'NB1: ',
    [6] = 'NB2: ',
    [7] = 'NB3: ',
  }
  local item_count = 0
  for i = 1, 2 do
    for j = 1, 8 do
      if self.lanes[i][j] > 0 then
        item_count = item_count + 1
      end
    end
  end
  info[4] = info[4] .. item_count
  local x, y = self.pos.x, self.pos.y
  local loc1, loc2, loc3 = table.unpack(BELT_CURVE_MAP[self.rot])
  local key1, key2, key3 = get_world_key(loc1.x + x, loc1.y + y), get_world_key(loc2.x + x, loc2.y + y), get_world_key(loc3.x + x, loc3.y + y)
  if ENTS[key1] and ENTS[key1].type == 'transport_belt' and ENTS[key1]:is_facing(self) then info[5] = info[5] .. 'true' else info[5] = info[5] .. 'false' end
  if ENTS[key2] and ENTS[key2].type == 'transport_belt' and ENTS[key2]:is_facing(self) then info[6] = info[6] .. 'true' else info[6] = info[6] .. 'false' end
  if ENTS[key3] and ENTS[key3].type == 'transport_belt' and ENTS[key3]:is_facing(self) then info[7] = info[7] .. 'true' else info[7] = info[7] .. 'false' end
  return info
end

function belt.rotate(self, rotation)
  --self.exit = BELT_ROTATION_MAP[rotation]
  if rotation > 3 then rotation = 0 end
  self.rot = rotation
  --self:set_output()
  self:set_curved()
end

function belt.is_facing(self, other)
  if ENTS[self.output_key] and ENTS[self.output_key].type == 'transport_belt' and ENTS[self.output_key] == other then return true end
  local exit = BELT_ROTATION_MAP[other.rot]
  local key = get_world_key(other.pos.x + exit.x, other.pos.y + exit.y)
  if ENTS[key] and ENTS[key] == self then return true end
  return false
end

function belt.set_output(self)
  self.exit = BELT_ROTATION_MAP[self.rot]
  self.output_key = get_world_key(self.pos.x + self.exit.x, self.pos.y + self.exit.y)
  if ENTS[self.output_key] and ENTS[self.output_key].type == 'transport_belt' then
    local index = self.rot .. ENTS[self.output_key].rot
    self.output = BELT_OUTPUT_MAP[index]
  else
    self.output = nil
  end
  if self.id == BELT_ID_STRAIGHT then
    self.output_item_key = self.rot .. self.rot
  end
end

function belt.set_curved(self)
  --checks left, right, and rear tiles (relative to ENTS rotation) for other ENTS
  --ENTS only curve if loc2 (rear input) is not facing me, loc1 XOR loc3, else belt is straight
  --loc1 = left input
  --loc2 = rear input
  --loc3 = right input
  --local key = get_key(self.pos.x, self.pos.y)
  local x, y = self.pos.x, self.pos.y
  local loc1, loc2, loc3 = table.unpack(BELT_CURVE_MAP[self.rot])
  local key1, key2, key3 = get_world_key(loc1.x + x, loc1.y + y), get_world_key(loc2.x + x, loc2.y + y), get_world_key(loc3.x + x, loc3.y + y)
  if not ENTS[key2] or (ENTS[key2].type == 'transport_belt' and not ENTS[key2]:is_facing(self) or ENTS[key2].type ~= 'transport_belt') then
    --no input belt facing same direction eg. <-<- or ->->
    if     ENTS[key1] and ENTS[key1].type == 'transport_belt' and ENTS[key1]:is_facing(self) and (not ENTS[key3] or (ENTS[key3].type == 'transport_belt' and not ENTS[key3]:is_facing(self)) or ENTS[key3].type ~= 'transport_belt') then
      --found a belt to the left, and belt is facing me, and no other ENTS are facing me
      self.id, self.flip, self.sprite_rot, self.output_item_key = BELT_ID_CURVED, loc1.flip, loc1.rot, loc1.key
    elseif ENTS[key3] and ENTS[key3].type == 'transport_belt' and ENTS[key3]:is_facing(self) and (not ENTS[key1] or (ENTS[key1].type == 'transport_belt' and not ENTS[key1]:is_facing(self)) or ENTS[key1].type ~= 'transport_belt') then
      --found a belt to the right, and belt is facing me, and no other ENTS are facing me
      self.id, self.flip, self.sprite_rot, self.output_item_key = BELT_ID_CURVED, loc3.flip, loc3.rot, loc3.key
    else
      --if (ENTS[key3] and ENTS[key3]:is_facing(self)) or (ENTS[key1] and ENTS[key1]:is_facing(self)) 
      --or (not ENTS[key1]) or (not ENTS[key3]) or (ENTS[key1]) then
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
  if not self.updated and not self.idle then
    self.updated = true
    local should_idle = true
    for i = 1, 2 do
      --check each lane
      for j = 1, 8 do
        --check each lane's slots for an item (0 means no item, else number is an ITEM id)
        local id = self.lanes[i][j]
        if id ~= 0 then
          self.idle = false
          should_idle = false
        end
        if j == 1 and id ~= 0 then
          --if we are the 1st slot (closest to output), check next tile for a belt to output to
          local key = get_world_key(self.pos.x + self.exit.x, self.pos.y + self.exit.y)
          if not ENTS[key] then self.output = nil end
          if self.output ~= nil and ENTS[key] and ENTS[key].type == 'transport_belt' then
            ENTS[key].idle = false
            --if i am facing another belt, update that belt first
            if not ENTS[key].updated then ENTS[key]:update() end
            --if we find a belt, and the ENTS nearest slot is empty (equals 0) then
            --move item to that belt
            if ENTS[self.output_key].id == BELT_ID_CURVED and ENTS[self.output_key].lanes[i][8] == 0 then
              --add item to other belt
              ENTS[self.output_key].lanes[i][8] = id
              
              --remove item from self
              self.lanes[i][j] = 0
            elseif ENTS[self.output_key].lanes[self.output[i].a][self.output[i].b] == 0 then
              ENTS[self.output_key].lanes[self.output[i].a][self.output[i].b] = id
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
    if should_idle then self.idle = true end
  end
  --return true
end

function belt.draw(self)
  local rot = self.rot
  local flip = 0
  if self.id == BELT_ID_CURVED then rot = self.sprite_rot flip = self.flip end
  local wx, wy = world_to_screen(self.pos.x, self.pos.y)
  self.world_pos = {x = wx, y = wy}
  spr(self.id + BELT_TICK, wx, wy, 0, 1, flip, rot, 1, 1)
end

function belt.draw_itemsOLD(self)
  if not self.drawn then
    self.drawn = true
    if ENTS[self.output_key] and ENTS[self.output_key].type == 'transport_belt' and vis_ents[self.output_key] and not vis_ents[self.output_key].drawn then ENTS[self.output_key]:draw_items() end
    local item_locations = BELT_CURVED_ITEM_MAP[self.output_item_key]
    for i = 1, 2 do
      for j = 1, 8 do
        if self.lanes[i][j] > 0 then
          --local loc_x, loc_y = cam.x - 120 + (self.pos.x*8), cam.y - 64 + (self.pos.y*8)
          local x, y = item_locations[j][i].x + self.world_pos.x, item_locations[j][i].y + self.world_pos.y
          local input_key = self.pos.x + (self.exit.x * -1) .. '-' .. self.pos.y + (self.exit.y * -1)
          local next1, next2 = 0, 0
          if j == 7 then
            next1, next2 = self.lanes[i][8], vis_ents[input_key] and vis_ents[input_key].lanes[i][1] or 0
          elseif j == 8 then  
            next1, next2 = vis_ents[input_key] and vis_ents[input_key].lanes[i][1] or 0, vis_ents[input_key] and vis_ents[input_key].lanes[i][2] or 0
          elseif j < 7 then
            next1, next2 = self.lanes[i][j + 1], self.lanes[i][j + 2]
          end
          if self.id == -1 then
            local pixels = ITEMS[self.lanes[i][j]].pixels
            draw_pixel_column(pixels, x, y, 1)
            if next1 == 0 then
              draw_pixel_column(pixels, x, y, 2)
            end
            if next2 == 0 then
              draw_pixel_column(pixels, x, y, 3)
            end
          else
            draw_pixel_sprite(ITEMS[self.lanes[i][j]].pixels, x, y)
          end
          --draw_pixel_sprite(self.lanes[i][j], x, y, next1, next2)
        end
      end
    end
  end
end

function belt.draw_items(self)
  if not self.drawn and not self.idle then
    self.drawn = true
    if ENTS[self.output_key] and ENTS[self.output_key].type == 'transport_belt' and vis_ents[self.output_key] and not vis_ents[self.output_key].drawn then ENTS[self.output_key]:draw_items() end
    local item_locations = BELT_CURVED_ITEM_MAP[self.output_item_key]
    for i = 1, 2 do
      for j = 1, 8 do
        if self.lanes[i][j] > 0 then
          --local loc_x, loc_y = cam.x - 120 + (self.pos.x*8), cam.y - 64 + (self.pos.y*8)
          local x, y = item_locations[j][i].x + self.world_pos.x, item_locations[j][i].y + self.world_pos.y
          spr(297, x, y, 0)
        end
      end
    end    
  end
end

return function(pos, rotation, children)
  local newBelt = {pos = pos, rot = rotation or 0}
  newBelt.id = BELT_ID_STRAIGHT
  if children then
    newBelt.lanes = children
  else
    newBelt.lanes = {}
    for i = 1, 2 do
      newBelt.lanes[i] = {}
      for j = 1, 8 do
        newBelt.lanes[i][j] = 0
      end
    end
  end
  setmetatable(newBelt, {__index = belt})
  newBelt:rotate(rotation or 0)
  return newBelt
end