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
  belt_drawn = false,
  drawn = false,
  output_key = nil,
  output_item_key = nil,
  output = nil,
  exit = {x = -8, y = 0},
  is_hovered = false,
  index = 0,
  curve_checked = false,
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
    [1] = {x =  0, y =  1, flip = 0, rot = 1, key = '10', other_rot = 1},
    [2] = {x =  1, y =  0},
    [3] = {x =  0, y = -1, flip = 2, rot = 1, key = '30', other_rot = 3},
  },
  [1] = {
    [1] = {x = -1, y =  0, flip = 0, rot = 2, key = '21', other_rot = 2},
    [2] = {x =  0, y =  1},
    [3] = {x =  1, y =  0, flip = 2, rot = 0, key = '01', other_rot = 0},
  },
  [2] = {
    [1] = {x =  0, y = -1, flip = 0, rot = 3, key = '32', other_rot = 3},
    [2] = {x = -1, y =  0},
    [3] = {x =  0, y =  1, flip = 2, rot = 3, key = '12', other_rot = 1},
  },
  [3] = {
    [1] = {x =  1, y =  0, flip = 0, rot = 0, key = '03', other_rot = 0},
    [2] = {x =  0, y = -1},
    [3] = {x = -1, y =  0, flip = 1, rot = 0, key = '23', other_rot = 2},
  }
}

function belt.get_info(self)
  local info = {
    [1] = 'ROT: ' .. self.rot,
    [2] = 'SID: ' .. self.id,
    [3] = 'OTK: ' .. self.output_key,
    [4] = '#IM: ',
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
  local left, rear, right = get_world_key(loc1.x + x, loc1.y + y), get_world_key(loc2.x + x, loc2.y + y), get_world_key(loc3.x + x, loc3.y + y)
  if ENTS[left]  and ENTS[left].type  == 'transport_belt' and ENTS[left]:is_facing(self)  then info[5] = info[5] .. 'true' else info[5] = info[5] .. 'false' end
  if ENTS[rear]  and ENTS[rear].type  == 'transport_belt' and ENTS[rear]:is_facing(self)  then info[6] = info[6] .. 'true' else info[6] = info[6] .. 'false' end
  if ENTS[right] and ENTS[right].type == 'transport_belt' and ENTS[right]:is_facing(self) then info[7] = info[7] .. 'true' else info[7] = info[7] .. 'false' end
  info[8] = 'OIK: ' .. tostring(self.output_item_key)
  return info
end

function belt.rotate(self, rotation)
  --self.exit = BELT_ROTATION_MAP[rotation]
  if rotation > 3 then rotation = 0 end
  self.rot = rotation
  self:set_output()
  self:set_curved()
  --self:update_neighbors()
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
  local key = self.pos.x + self.exit.x .. '-' .. self.pos.y + self.exit.y
  self.output_key = key
  local ent = ENTS[key]
  if ENTS[key] then
    if ENTS[key].type == 'transport_belt' then
      self.output = BELT_OUTPUT_MAP[self.rot .. ENTS[key].rot]
    elseif ENTS[key].type == 'splitter' or ENTS[key].type == 'dummy' and ENTS[key].rot == self.rot then
      if ENTS[key].type == 'dummy' then self.output_key = ENTS[key].other_key end
      self.output = BELT_OUTPUT_MAP[self.rot .. ENTS[key].rot]
    else
      self.output = nil
    end
  else
    self.output = nil
  end
  if self.id == BELT_ID_STRAIGHT then
    self.output_item_key = self.rot .. self.rot
  end
end

function belt:has_items()
  for i = 1, 2 do
    for j = 1, 8 do
      if self.lanes[i][j] ~= 0 then return true end
    end
  end
  return false
end

function belt.update_neighbors(self, key)
  local cell_x, cell_y = self.pos.x, self.pos.y
  local tiles = {
    [1] = {x = cell_x, y = cell_y - 1},
    [2] = {x = cell_x + 1, y = cell_y},
    [3] = {x = cell_x, y = cell_y + 1},
    [4] = {x = cell_x - 1, y = cell_y}}
  for i = 1, 4 do
    local k = tiles[i].x .. '-' .. tiles[i].y
    if ENTS[k] or (key and ENTS[key] and ENTS[k] ~= ENTS[key]) then
      if ENTS[k].type == 'transport_belt' then ENTS[k]:set_curved() end
      if ENTS[k].type == 'splitter' then ENTS[k]:set_output() end
      if ENTS[k].type == 'dummy' then ENTS[ENTS[k].other_key]:set_output() end
    end
  end
  self:set_curved()
end

function belt.set_curved(self)
  if not self.curve_checked then
    self.curve_checked = true
    --checks left, right, and rear tiles (relative to ENTS rotation) for other ENTS
    --ENTS only curve if loc2 (rear input) is not facing me, loc1 XOR loc3, else belt is straight
    --loc1 = left input
    --loc2 = rear input
    --loc3 = right input
    local x, y = self.pos.x, self.pos.y
    local loc1, loc2, loc3 = table.unpack(BELT_CURVE_MAP[self.rot])
    local left, rear, right = get_world_key(loc1.x + x, loc1.y + y), get_world_key(loc2.x + x, loc2.y + y), get_world_key(loc3.x + x, loc3.y + y)
    --if ENTS[left] and is_facing(self, ENTS[left], 'left') then trace('ent facing belt on left') else trace('no ent to the left') end
    --if ENTS[right] and is_facing(self, ENTS[right], 'right') then trace('ent facing belt on right') else trace('no ent to the right') end
    --conditions to curve:
    --no belt/splitter behind me that's facing me
    --curve left if no belt/splitter to the right facing me AND  >
    --splitter/belt on left facing me
    ------------------------------------------------------------------------------------------
      if not ENTS[rear] or (ENTS[rear] and ENTS[rear].rot ~= self.rot) then
        --can curve left or right now, since no REAR connection preventing snapping
        --------------------------------------------------------------------------------------
        if ENTS[left]
        and
        (ENTS[left].type == 'transport_belt' or ENTS[left].type == 'splitter' or ENTS[left].type == 'dummy')
        and
        ENTS[left].rot == loc1.other_rot
        and
        (not ENTS[right] or (ENTS[right] and ENTS[right].rot ~= loc3.other_rot))
        --is_facing(self, ENTS[left], 'left') and
        --(not ENTS[right] or (ENTS[right] and not is_facing(self, ENTS[right], 'right')))
        then
          self.id, self.flip, self.sprite_rot, self.output_item_key = BELT_ID_CURVED, loc1.flip, loc1.rot, loc1.key
        --------------------------------------------------------------------------------------
        elseif ENTS[right]
        and
        (ENTS[right].type == 'transport_belt' or ENTS[right].type == 'splitter' or ENTS[right].type == 'dummy')
        and
        ENTS[right].rot == loc3.other_rot
        and
        (not ENTS[left] or (ENTS[left] and ENTS[left].rot ~= loc1.other_rot))
      then
          self.id, self.flip, self.sprite_rot, self.output_item_key = BELT_ID_CURVED, loc3.flip, loc3.rot, loc3.key
        --------------------------------------------------------------------------------------
        else
          self.id = BELT_ID_STRAIGHT
          self.output_item_key = self.rot .. self.rot
        end
      ------------------------------------------------------------------------------------------
      else
        self.id = BELT_ID_STRAIGHT
        self.output_item_key = self.rot .. self.rot
      end
      self:set_output()
  end
end

function belt.update(self)
  --self.idle = false
  -- if we have NOT updated this frame, continue
  if self.updated then return end
  if not self.updated then
    self.updated = true
    local should_idle = true
    for i = 1, 2 do
      --check each lane
      for j = 1, 8 do
        --check each lane's slots for an item (0 means no item, else number is an ITEM id)
        local id = self.lanes[i][j]
        if id ~= 0 then
          should_idle = false
        end
        if j == 1 and id ~= 0 then
          --if we are the 1st slot (closest to output), check next tile for a belt to output to
          self.output_key = self.pos.x + self.exit.x .. '-' .. self.pos.y + self.exit.y
          if not ENTS[self.output_key] then self.output = nil end
          if self.output ~= nil and ENTS[self.output_key] then
            if ENTS[self.output_key].type == 'transport_belt' then
              ENTS[self.output_key].idle = false
              --if i am facing another belt, update that belt first
              if not ENTS[self.output_key].updated then ENTS[self.output_key]:update() end
              --if we find a belt, and the ENTS nearest slot is empty (equals 0) then
              --move item to that belt
              if ENTS[self.output_key].id == BELT_ID_CURVED and ENTS[self.output_key].lanes[i][8] == 0 then
                --add item to other belt
                ENTS[self.output_key].lanes[i][8] = id
                --remove item from self
                self.lanes[i][j] = 0
              elseif ENTS[self.output_key].lanes[self.output[i].a][self.output[i].b] == 0 then
                ENTS[self.output_key].lanes[self.output[i].a][self.output[i].b] = id
                --ENTS[self.output_key].idle = false
                self.lanes[i][j] = 0
              end
            --------------------------------------------------------------------------------------------------
            elseif ENTS[self.output_key].type == 'splitter' or ENTS[self.output_key].type == 'dummy' then
              local key = self.output_key
              --if key is a dummy splitter, then get the parent splitter's key
              if ENTS[key].type == 'dummy' then
                key = ENTS[self.output_key].other_key
              end
              --if not ENTS[key].updated then ENTS[key]:update() end
              if ENTS[key]:input(id, i) then
                self.lanes[i][1] = 0
              end
              --if should_shift then ENTS[key].shift = not ENTS[key].shift end
            end
          ------------------------------------------------------------------------------------------------------
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
    --self.updated = true
    --if should_idle then self.idle = true end
    --self.idle = false
  end
end

function belt.draw(self)
  --trace('Drawing belt: ' .. self.pos.x .. '-' .. self.pos.y)
  --trace('BELT DRAWN: ' .. tostring(self.belt_drawn))
  --trace('ITEMS DRAWN: ' .. tostring(self.drawn))
  if self.belt_drawn == false then
    self.belt_drawn = true
    if ENTS[self.output_key] then
      local key = self.output_key
      -- if ENTS[key].type == 'dummy' then key = ENTS[key].other_key end
      -- if ENTS[key].type == 'splitter' and ENTS[key].drawn == false then ENTS[key]:draw() end
      if ENTS[key].type == 'transport_belt' and ENTS[key].belt_drawn == false then ENTS[key]:draw() end
    end
    local rot = self.rot
    local flip = 0
    if self.id == BELT_ID_CURVED then rot = self.sprite_rot flip = self.flip end
    local wx, wy = world_to_screen(self.pos.x, self.pos.y)
    self.world_pos = {x = wx, y = wy}
    spr(self.id + BELT_TICK, wx, wy, 0, 1, flip, rot, 1, 1)
  end
end

function belt.draw_items(self)
  --if self.drawn == true then return end
  if self.drawn == false then
    self.drawn = true
    if ENTS[self.output_key] and ENTS[self.output_key].type == 'transport_belt' and ENTS[self.output_key].drawn == false then ENTS[self.output_key]:draw_items() end
    if ENTS[self.output_key] and 
    (ENTS[self.output_key].type == 'splitter' or 
    ENTS[self.output_key].type == 'dummy') then
      local key = self.output_key
      if ENTS[self.output_key].type == 'dummy' then key = ENTS[self.output_key].other_key end
      if ENTS[key].drawn == false then ENTS[key]:draw() end
    end
    --trace('belt output_item_key = ' .. tostring(self.output_item_key) or 'NIL')
    --if self.output_item_key == nil then self:set_output() end
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
  --newBelt:rotate(rotation or 0)
  return newBelt
end