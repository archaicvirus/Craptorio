FURNACE_SPRITE_ACTIVE_ID = 490
FURNACE_SPRITE_INACTIVE_ID = 488
FURNACE_ANIM_TICK = 0
FURNACE_ANIM_TICKRATE = 5
FURNACE_ANIM_TICKS = 2
FURNACE_TICKRATE = 1

--git test 'remote-stone_furnace' checkout

local Furnace = {
  x = 0,
  y = 0,
  type = 'stone_furnace',
  is_hovered = false,
  updated = false,
  drawn = false,
  fuel_slots = 50,
  output_slots = 50,
  output = {},
  fuel_time = 0,
  is_smelting = false,
  item_id = 14,
}

function Furnace.update(self)
  if self.is_smelting then
    --update smelting countdown timer
  else
    --check for incoming ore
  end
end

function Furnace.draw(self)
  local sx, sy = world_to_screen(self.x, self.y)
  if self.is_smelting then
    sspr(FURNACE_SPRITE_ACTIVE_ID + FURNACE_ANIM_TICK, sx, sy, 0, 1, 0, 0, 2, 2)
  else
    sspr(FURNACE_SPRITE_INACTIVE_ID, sx, sy, 0, 1, 0, 0, 2, 2)
  end  
end

function NewFurnace(x, y)
  local new_furnace = {x = x, y = y}
  setmetatable(new_furnace, {__index = Furnace})
  return new_furnace
end

return NewFurnace