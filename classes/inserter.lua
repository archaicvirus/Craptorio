INSERTER_BASE_ID       = 264
INSERTER_ARM_ID        = 265
INSERTER_ARM_ANGLED_ID = 266
INSERTER_ANIM_TICKRATE = 4
INSERTER_TICKRATE      = 4
INSERTER_COLORKEY = 15

INSERTER_ARM_OFFSETS = {
  [0] = {id = INSERTER_ARM_ID,        x = -3, y =  0, rot = 0, item_offset = {x = -1, y =  2}},
  [1] = {id = INSERTER_ARM_ANGLED_ID, x = -3, y = -3, rot = 0, item_offset = {x =  1, y =  1}},
  [2] = {id = INSERTER_ARM_ID,        x =  0, y = -3, rot = 1, item_offset = {x =  2, y = -1}},
  [3] = {id = INSERTER_ARM_ANGLED_ID, x =  3, y = -3, rot = 1, item_offset = {x =  4, y =  1}},
  [4] = {id = INSERTER_ARM_ID,        x =  3, y =  0, rot = 2, item_offset = {x =  6, y =  3}},
  [5] = {id = INSERTER_ARM_ANGLED_ID, x =  3, y =  3, rot = 2, item_offset = {x =  5, y =  5}},
  [6] = {id = INSERTER_ARM_ID,        x =  0, y =  3, rot = 3, item_offset = {x =  2, y =  6}},
  [7] = {id = INSERTER_ARM_ANGLED_ID, x = -3, y =  3, rot = 3, item_offset = {x =  3, y =  4}},
}

INSERTER_GRAB_OFFSETS = {
  [0] = {from = {x =  1, y =  0}, to = {x = -1, y =  0}},
  [1] = {from = {x =  0, y =  1}, to = {x =  0, y = -1}},
  [2] = {from = {x = -1, y =  0}, to = {x =  1, y =  0}},
  [3] = {from = {x =  0, y = -1}, to = {x =  0, y =  1}},
}

INSERTER_DEPOSIT_MAP = {
  [0] = {[0] = 1, [1] = 2, [2] = 2, [3] = 1},
  [1] = {[0] = 1, [1] = 2, [2] = 2, [3] = 1},
  [2] = {[0] = 1, [1] = 1, [2] = 2, [3] = 2},
  [3] = {[0] = 2, [1] = 2, [2] = 1, [3] = 1},
}

INSERTER_ANIM_KEYS = {
  [0] = {0,1,2,3,4},
  [1] = {2,3,4,5,6},
  [2] = {4,5,6,7,0},
  [3] = {6,7,0,1,2}
}

local Inserter = {
  pos = {x = 0, y = 0},
  rot = 0,
  color_keys = {15},
  from_key = '0-0',
  to_key = '0-0',
  anim_frame = 5,
  state = 'wait',
  held_item_id = 0,
  is_hovered = false,
  type = 'inserter',
  item_id = 11,
  filter = {item_id = 0},
  tickrate = 5,
}

function Inserter:draw_hover_widget()
if TICK % 60 == 0 then
  trace('state: ' .. self.state)
  trace('id = ' .. self.held_item_id)
end
end

function Inserter:get_info()
  local info = {
    [1] = 'POS: ' .. get_key(self.pos.x, self.pos.y),
    [2] = 'ROT: ' .. self.rot,
    [3] = 'OUT: ' .. self.to_key,
    [4] = 'INP: ' .. self.from_key,
  }
  return info
end

function Inserter:draw()
  local config = INSERTER_ARM_OFFSETS[INSERTER_ANIM_KEYS[self.rot][self.anim_frame]]
  local sx, sy = world_to_screen(self.pos.x, self.pos.y)
  local screen_pos = {x = sx, y = sy}
  local x, y = config.x + screen_pos.x, config.y + screen_pos.y
  spr(INSERTER_BASE_ID, screen_pos.x, screen_pos.y, self.color_keys, 1, 0, self.rot, 1, 1)
  spr(config.id, x, y, self.color_keys, 1, 0, config.rot, 1, 1)
  if self.held_item_id > 0 then
    local sprite_id = ITEMS[self.held_item_id].belt_id
    local ck = {ITEMS[self.held_item_id].color_key}
    spr(sprite_id, x + config.item_offset.x, y + config.item_offset.y, ck)
  end
end

function Inserter:can_deposit(other, item_id)
  if ENTS[other] then
    if ENTS[other].type == 'transport_belt' then
      return true
    elseif ENTS[other].type == 'stone_furnace' then
      if ENTS[other]:deposit({id = item_id, count = 1}, true) then return true end
    elseif ENTS[other].type == 'splitter' then
      if ENTS[other]:deposit({id = item_id, count = 1}, true) then return true end
    end
  end
  return false
end

function Inserter:request_deposit()
  if not self.state == 'wait' or self.held_item_id ~= 0 then return false end
  return 'any'
end

function Inserter:deposit(id)
  if self.state == 'wait' and self.held_item_id == 0 then
    self.held_item_id = id
    self.state = 'send'
    return true
  end
  return false
end

function Inserter:item_request(id)
  if not self.recipe then return false end
  if self.output.count > 0 and (self.output.id == id or id == 'any') then
    self.output.count = self.output.count - 1
    return self.output.id
  end
  return false
end

function Inserter:set_output()
  local from, to = INSERTER_GRAB_OFFSETS[self.rot].from, INSERTER_GRAB_OFFSETS[self.rot].to
  self.from_key = self.pos.x + from.x .. '-' .. self.pos.y + from.y
  self.to_key = self.pos.x  + to.x .. '-' .. self.pos.y + to.y
end

function Inserter:rotate(rotation)
  rotation = rotation or self.rot + 1
  self.rot = rotation
  if self.rot > 3 then self.rot = 0 end
  self:set_output()
end

function Inserter:update()
  local from, to = self.from_key, self.to_key
  if ENTS[from] and dummies[ENTS[from].type] then
    self.from_key = ENTS[from].other_key
    from = self.from_key
  end
  if ENTS[to] and dummies[ENTS[to].type] then
    self.to_key = ENTS[to].other_key
    to = self.to_key
  end
  if not ENTS[self.from_key] or not ENTS[self.to_key] then
    self:set_output()
    return
  end

  if self.state == 'send' then
    if not ENTS[to] then return end
    self.anim_frame = self.anim_frame - 1
    if self.anim_frame <= 1 then
      self.anim_frame = 1
      --try to deposit item
      --trace('looking for output')
      if ENTS[to] then
        if ENTS[to]:deposit(self.held_item_id, self.rot) then
          self.state = 'return'
          self.held_item_id = 0
          return
        end
      else
        return
      end
    end
  elseif self.state == 'return' then
    self.anim_frame = self.anim_frame + 1
    if self.anim_frame >= 5 then
      -- inserter has returned, and waits for another item
      self.anim_frame = 5
      self.state = 'wait'
    end
  elseif self.state == 'wait' then
    trace('inserter waiting')
    local desired_item = ENTS[to]:request_deposit(self)
    --if desired_item then trace('inserter: desired item = ' .. tostring(ITEMS[desired_item].fancy_name)) end
    if not desired_item then return end
    local retrieved_item = ENTS[from]:item_request(desired_item, self)
    --if retrieved_item ~= false then trace('inserter: retrieved_item = ' .. tostring(ITEMS[retrieved_item].fancy_name or false)) end
    if not retrieved_item then return end
    if ENTS[to].assign_delivery then ENTS[to]:assign_delivery(retrieved_item) end
    self.held_item_id = retrieved_item
    self.state = 'send'
  end
end

function new_inserter(position, rotation)
  local new_inserter = {
    pos = position,
    rot = rotation,
    color_keys = {15},
    from_key = '0-0',
    to_key = '0-0',
    anim_frame = 5,
    state = 'wait',
    held_item_id = 0,
    is_hovered = false,
    type = 'inserter',
    item_id = 11,
    filter = {item_id = 0}
  }
  setmetatable(new_inserter, {__index = Inserter})
  --new_Inserter.pos = position
  --new_Inserter.rot = rotation
  new_inserter:set_output()
  return new_inserter
end