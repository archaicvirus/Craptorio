INSERTER_BASE_ID = 274
INSERTER_ARM_ID = 275
INSERTER_ARM_ANGLED_ID = 276
INSERTER_ANIM_TICKRATE = 4

INSERTER_ARM_OFFSETS = {
  [0] = {id = INSERTER_ARM_ID,        x = -3, y =  0, rot = 0, item_offset = {x =  2, y =  7}},
  [1] = {id = INSERTER_ARM_ANGLED_ID, x = -3, y = -3, rot = 0, item_offset = {x =  0, y =  5}},
  [2] = {id = INSERTER_ARM_ID,        x =  0, y = -3, rot = 1, item_offset = {x =  0, y =  0}},
  [3] = {id = INSERTER_ARM_ANGLED_ID, x =  3, y = -3, rot = 1, item_offset = {x = -1, y =  2}},
  [4] = {id = INSERTER_ARM_ID,        x =  3, y =  0, rot = 2, item_offset = {x =  2, y = -1}},
  [5] = {id = INSERTER_ARM_ANGLED_ID, x =  3, y =  3, rot = 2, item_offset = {x =  5, y =  0}},
  [6] = {id = INSERTER_ARM_ID,        x =  0, y =  3, rot = 3, item_offset = {x =  4, y =  5}},
  [7] = {id = INSERTER_ARM_ANGLED_ID, x = -3, y =  3, rot = 3, item_offset = {x =  6, y =  3}},
}

INSERTER_GRAB_OFFSETS = {
  [0] = {from = {x = -8, y =  0}, to = {x =  8, y =  0}},
  [1] = {from = {x =  0, y = -8}, to = {x =  0, y =  8}},
  [2] = {from = {x =  8, y =  0}, to = {x = -8, y =  0}},
  [3] = {from = {x =  0, y =  8}, to = {x =  0, y = -8}},
}

INSERTER_ANIM_KEYS = {
  [0] = {0,1,2,3,4},
  [1] = {2,3,4,5,6},
  [2] = {4,5,6,7,0},
  [3] = {6,7,0,1,2}
}

local inserter = {
  pos = {x = 0, y = 0},
  from = {x = 0, y = 0},
  to = {x = 0, y = 0},
  anim_frame = 5,
  state = 'return',
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
  self.from, self.to = INSERTER_GRAB_OFFSETS[rotation].from, INSERTER_GRAB_OFFSETS[rotation].to
end

function inserter.update(self)
  if self.state == 'send' then
    self.anim_frame = self.anim_frame + 1
    if self.anim_frame >= 5 then
      --try to deposit item

      self.held_item_id = 0
      self.state = 'return'
    end    
  end
  if self.state == 'return' then
    self.anim_frame = self.anim_frame - 1
    if self.anim_frame < 1 then
      -- inserter has returned, and waits for another item

      self.anim_frame = 1
      self.state = 'wait'
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
