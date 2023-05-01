INSERTER_BASE_ID       = 264
INSERTER_ARM_ID        = 265
INSERTER_ARM_ANGLED_ID = 266
INSERTER_ANIM_TICKRATE = 4
INSERTER_TICKRATE      = 4

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

function Inserter.draw_hover_widget(self)
  local sx, sy = cursor.x, cursor.y
  rectb(sx, sy, 50, 50, 13)
  rect(sx + 1, sy + 1, 48, 48, 0)
end

function Inserter.get_info(self)
  local info = {
    [1] = 'POS: ' .. get_key(self.pos.x, self.pos.y),
    [2] = 'ROT: ' .. self.rot,
    [3] = 'OUT: ' .. self.to_key,
    [4] = 'INP: ' .. self.from_key,
  }
  return info
end

function Inserter.draw(self)
  local config = INSERTER_ARM_OFFSETS[INSERTER_ANIM_KEYS[self.rot][self.anim_frame]]
  local sx, sy = world_to_screen(self.pos.x, self.pos.y)
  local screen_pos = {x = sx, y = sy}
  local x, y = config.x + screen_pos.x, config.y + screen_pos.y
  spr(INSERTER_BASE_ID, screen_pos.x, screen_pos.y, 0, 1, 0, self.rot, 1, 1)
  spr(config.id, x, y, 0, 1, 0, config.rot, 1, 1)
  if self.held_item_id > 0 then
    local sprite_id = ITEMS[self.held_item_id].belt_id
    spr(sprite_id, x + config.item_offset.x, y + config.item_offset.y, 0)
  end
end

function Inserter.can_deposit(self, other, item_id)
  if ENTS[other] then
    if ENTS[other].type == 'transport_belt' then
      return true
    elseif ENTS[other].type == 'stone_furnace' then
      if ENTS[other].deposit(item_id) then return true end
    elseif ENTS[other].type == 'splitter' then
      if ENTS[other].deposit(item_id) then return true end
    end
  end
  return false
end

function Inserter.set_output(self)
  local from, to = INSERTER_GRAB_OFFSETS[self.rot].from, INSERTER_GRAB_OFFSETS[self.rot].to
  self.from_key = self.pos.x + from.x .. '-' .. self.pos.y + from.y
  self.to_key = self.pos.x  + to.x .. '-' .. self.pos.y + to.y
end

function Inserter.rotate(self, rotation)
  rotation = rotation or self.rot + 1
  self.rot = rotation
  if self.rot > 3 then self.rot = 0 end
  self:set_output()
end

function Inserter.update(self)
  if self.state == 'send' then
    self.anim_frame = self.anim_frame - 1
    if self.anim_frame <= 1 then
      self.anim_frame = 1
      --try to deposit item
      --trace('looking for output')
      if ENTS[self.to_key] then 
        if ENTS[self.to_key].type == 'transport_belt' then
          ENTS[self.to_key].idle = false
          --trace('FOUND belt')
          for i = 8, 1, -1 do
            local index = ENTS[self.to_key].rot
            local lane = INSERTER_DEPOSIT_MAP[self.rot][index]
            if ENTS[self.to_key].lanes[lane][i] == 0 then
              ENTS[self.to_key].lanes[lane][i] = self.held_item_id
              self.held_item_id = 0
              self.state = 'return'
              break
            end
          end
          --return
        elseif ENTS[self.to_key].type == 'stone_furnace' or ENTS[self.to_key].type == 'dummy_furnace' then
          --trace('furnace detected')
          if ENTS[self.to_key].type == 'dummy_furnace' then
            self.to_key = ENTS[self.to_key].other_key
          end
          if ENTS[self.to_key]:deposit(self.held_item_id, nil) then
            self.held_item_id = 0
            self.state = 'return'
          end
          return
        end
      end
      -- if not ENTS[self.to_key].type == 'ground-items' or (ENTS[self.to_key].type == 'ground-items' and ENTS[self.to_key][1] == 0) then
      --   local to = INSERTER_GRAB_OFFSETS[self.rot].to
      --   --create ground item entity with belt lanes
      --   local gnd_item = {id = self.held_item_id, pos = {self.pos.x + to.x, self.pos.y + to.y}, type = 'gound-item'}
      --   table.insert(GROUND_ITEMS, gnd_item)
      --   local index = #GROUND_ITEMS
      --   GROUND_ITEMS[self.to_key] = GROUND_ITEMS[index]
      --   self.held_item_id = 0
      --   self.state = 'return'
      -- --drop on ground
      -- end
      
      -- self.held_item_id = 0
      -- self.state = 'return'
    end    
  elseif self.state == 'return' then
    self.anim_frame = self.anim_frame + 1
    if self.anim_frame >= 5 then
      -- inserter has returned, and waits for another item
      self.anim_frame = 5
      self.state = 'wait'
    end
  elseif self.state == 'wait' then
    if ENTS[self.from_key] then
      if ENTS[self.from_key].type == 'transport_belt' then
        if ENTS[self.to_key] and ENTS[self.to_key].type == 'stone_furnace' then
          --check if output destination can take an item
          --before we pick it up from the belt
          --to prevent inserter stuck holding item
          local item_id = ENTS[self.from_key]:request_item(true)
          if item_id and ENTS[self.to_key]:deposit(item_id, true) then
            ENTS[self.to_key]:deposit(item_id, false)
            self.held_item_id = item_id
            self.state = 'send'
          end
          return
        end

        local item_id = ENTS[self.from_key]:request_item(false)
        if item_id then
          self.held_item_id = item_id
          self.state = 'send'
          return
        end
        -- for i = 1, 8 do
        --   local lane = 0
        --   if ENTS[self.from_key].lanes[1][i] ~= 0 then
        --     lane = 1
        --   elseif ENTS[self.from_key].lanes[2][i] ~= 0 then
        --     lane = 2
        --   end
        --   if lane > 0 then
        --     self.held_item_id = ENTS[self.from_key].lanes[lane][i]
        --     ENTS[self.from_key].lanes[lane][i] = 0
        --     self.state = 'send'
        --     return
        --     --break
        --   end
        -- end
      elseif ENTS[self.from_key].type == 'splitter' or ENTS[self.from_key].type == 'dummy' then
        if ENTS[self.from_key].type == 'dummy' then
          local item = ENTS[ENTS[self.from_key].other_key]:give_inserter('right')
          if item then
            self.held_item_id = item
            self.state = 'send'
            return
          end
        else
          local item = ENTS[self.from_key]:give_inserter('left')
          if item then
            self.held_item_id = item
            self.state = 'send'
            return
          end
        end
      elseif ENTS[self.from_key].type == 'stone_furnace' or ENTS[self.from_key].type == 'dummy_furnace' then
        --trace('furnace detected')
        local key = self.from_key
        if ENTS[key].type == 'dummy_furnace' then key = ENTS[key].other_key end
        if #ENTS[key].output_buffer > 0 then
          self.held_item_id = table.remove(ENTS[key].output_buffer, #ENTS[key].output_buffer)
          self.state = 'send'
          return
        end
      end
    else
      -- if GROUND_ITEMS[self.from_key] and GROUND_ITEMS[self.from_key][1] ~= 0 then
      -- --try to pick from ground
      --   self.held_item_id = GROUND_ITEMS[self.from_key][1]
      --   GROUND_ITEMS[self.from_key][1] = 0
      --   self.state = 'send'
      -- end
    end
  end
end

return function(position, rotation)
  local new_inserter = {pos = position, rot = rotation}
  setmetatable(new_inserter, {__index = Inserter})
  --new_Inserter.pos = position
  --new_Inserter.rot = rotation
  new_inserter:set_output()
  return new_inserter
end