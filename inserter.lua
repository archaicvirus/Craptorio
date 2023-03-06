INSERTER_BASE_ID = 274
INSERTER_ARM_ID = 275
INSERTER_ARM_ANGLED_ID = 276
INSERTER_ANIM_TICKRATE = 4

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
  [0] = {from = {x =  8, y =  0}, to = {x = -8, y =  0}},
  [1] = {from = {x =  0, y =  8}, to = {x =  0, y = -8}},
  [2] = {from = {x = -8, y =  0}, to = {x =  8, y =  0}},
  [3] = {from = {x =  0, y = -8}, to = {x =  0, y =  8}},
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

local inserter = {
  pos = {x = 0, y = 0},
  from_key = '0-0',
  to_key = '0-0',
  anim_frame = 5,
  state = 'wait',
  held_item_id = 0,
  rot = 0,
}

function inserter.draw(self)
  local config = INSERTER_ARM_OFFSETS[INSERTER_ANIM_KEYS[self.rot][self.anim_frame]]
  local x, y = config.x + self.pos.x, config.y + self.pos.y
  spr(INSERTER_BASE_ID, self.pos.x, self.pos.y, 00, 1, 0, self.rot, 1, 1)
  --spr(INSERTER_ARM_ID, x, y, 00, 1, 0, 0, 1, 1)
  spr(config.id, x, y, 00, 1, 0, config.rot, 1, 1)
  
  if self.held_item_id > 0 then
    draw_pixel_sprite(self.held_item_id, x + config.item_offset.x, y + config.item_offset.y)
  end
  -- debug to show item path when moving
  -- for k, v in pairs(self.itemLocations) do
  --   spr(272, self.pos.x + v.x, self.pos.y + v.y, 00, 1, 0, 0, 1, 1)
  --   print(tostring(k), self.pos.x + v.x + 2, self.pos.y + v.y + 2, 2)
  -- end
end

function inserter.rotate(self, rotation)
  self.rot = rotation
  local from, to = INSERTER_GRAB_OFFSETS[rotation].from, INSERTER_GRAB_OFFSETS[rotation].to
  self.from_key = self.pos.x + from.x .. '-' .. self.pos.y + from.y
  self.to_key = self.pos.x  + to.x .. '-' .. self.pos.y + to.y
end

function inserter.update(self)
  if self.state == 'send' then
    self.anim_frame = self.anim_frame - 1
    if self.anim_frame <= 1 then
      self.anim_frame = 1
      --try to deposit item
      trace('looking for output')
      if BELTS[self.to_key] then
        trace('FOUND belt')
        for i = 8, 1, -1 do
          local index = BELTS[self.to_key].rot
          local lane = INSERTER_DEPOSIT_MAP[self.rot][index]
          if BELTS[self.to_key].lanes[lane][i] == 0 then
            BELTS[self.to_key].lanes[lane][i] = self.held_item_id
            self.held_item_id = 0
            self.state = 'return'
            break
          end
        end
      end
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
    if BELTS[self.from_key] then
      for i = 1, 8 do
        local lane = 0
        if BELTS[self.from_key].lanes[1][i] ~= 0 then
          lane = 1
        elseif BELTS[self.from_key].lanes[2][i] ~= 0 then
          lane = 2
        end
        if lane > 0 then
          self.held_item_id = BELTS[self.from_key].lanes[lane][i]
          BELTS[self.from_key].lanes[lane][i] = 0
          self.state = 'send'
          return
          --break
        end
      end
    end
  end
end

return function(position, rotation)
  local new_inserter = {}
  setmetatable(new_inserter, {__index = inserter})
  new_inserter.pos = position
  new_inserter.rot = rotation
  new_inserter:rotate(rotation)
  return new_inserter
end
