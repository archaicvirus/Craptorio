FURNACE_SPRITE_ACTIVE_ID = 490
FURNACE_SPRITE_INACTIVE_ID = 488
FURNACE_ANIM_TICK = 0
FURNACE_ANIM_TICKRATE = 9
FURNACE_ANIM_TICKS = 2
FURNACE_TICKRATE = 5
FURNACE_BUFFER_INPUT = 50
FURNACE_BUFFER_OUTPUT = 100
FURNACE_BUFFER_FUEL = 50
FURNACE_SMELT_TIME = 3 * 60

--git test 'remote-stone_furnace' checkout

local Furnace = {
  x = 0,
  y = 0,
  type = 'stone_furnace',
  is_hovered = false,
  updated = false,
  drawn = false,
  fuel_slots = FURNACE_BUFFER_FUEL,
  output_slots = FURNACE_BUFFER_SIZE,
  output_buffer = {15},
  input_buffer = {3},
  fuel_buffer = {},
  dummy_keys = {},
  fuel_time = 0,
  smelt_timer = FURNACE_SMELT_TIME,
  ore_type = nil,
  is_smelting = false,
  item_id = 14,
}

function Furnace.draw_hover_widget(self)
  local sx, sy = cursor.x + 5, cursor.y + 5
  local width, height = 65, 50
  --background window and border
  rectb(sx, sy, width, height, 13)
  rect(sx + 1, sy + 1, width - 2, height - 2, 0)

  --input slots icon, and item count------------------------------------------
  local text = #self.input_buffer .. '/' .. FURNACE_BUFFER_INPUT
  local text_width = print(text, 0, -10, 0, true, 1, true)
  local sprite_id = 311
  print('Input - ', sx + 3, sy + 3, 11, true, 1, true)
  print(text, sx + width - 2 - text_width, sy + 3, 4, true, 1, true)
  if #self.input_buffer > 0 then sprite_id = ITEMS[self.input_buffer[1]].sprite_id end
  sspr(sprite_id, sx + width - 12 - text_width, sy + 2, 4)

  --output slots icon and item count---------------------------------------------
  local text = #self.output_buffer .. '/' .. FURNACE_BUFFER_OUTPUT
  local text_width = print(text, 0, -10, 0, true, 1, true)
  local sprite_id = 311
  print('Output - ', sx + 3, sy + 15, 11, true, 1, true)
  print(text, sx + width - 2 - text_width, sy + 15, 4, true, 1, true)
  if #self.output_buffer > 0 then sprite_id = ITEMS[self.output_buffer[1]].sprite_id end
  sspr(sprite_id, sx + width - 12 - text_width, sy + 13, 4)
  
  --fuel buffer slot icon etc-----------------------------------------------------
  local text = #self.fuel_buffer .. '/' .. FURNACE_BUFFER_FUEL
  local text_width = print(text, 0, -10, 0, true, 1, true)
  local sprite_id = 311
  print('Fuel - ', sx + 3, sy + 24, 11, true, 1, true)
  print(text, sx + width - 2 - text_width, sy + 24, 4, true, 1, true)
  if #self.fuel_buffer > 0 then sprite_id = ITEMS[self.fuel_buffer[1]].sprite_id end
  sspr(sprite_id, sx + width - 12 - text_width, sy + 24, 4)



end

function Furnace.open(self)
  return {
    x = cursor.x + 5,
    y = 3,
    width = 100,
    height = 100,
    close = function(self, sx, sy)
      -- 5x5 close button sprite
      local cx, cy, cw, ch = self.x + self.width - 7, self.y + 2, 5, 5
      if sx >= cx and sx < sx + cw and sy >= cy and sy < cy + ch then
        return true
      end
      return false
    end,
    ent_key = self.x .. '-' .. self.y,
    click = function(self, sx, sy)
      if sx >= self.x and sx < self.x + self.width and sy >= self.y and sy < self.y + self.height then
        if self:close(sx, sy) then window = nil; return true end
      end
      return false
    end,
    is_hovered = function(self, x, y)
      return x >= self.x and x < self.x + self.width and y >= self.y and y < self.y + self.height and true or false
    end,
    draw = function(self)
      local ent = ENTS[self.ent_key]
      if not ent then return end
      local input, output, fuel = ent.input_buffer, ent.output_buffer, ent.fuel_buffer
      local x, y, w, h = self.x, self.y, self.width, self.height
      --background window and border
      rectb(x, y, w, h, 13)
      rect(x + 1, y + 1, w - 2, h - 2, 0)

      --input slots icon, and item count------------------------------------------
      -- local text = #input .. '/' .. FURNACE_BUFFER_INPUT
      -- local text_width = print(text, 0, -10, 0, true, 1, true)
      -- local sprite_id = 311
      -- print('Input - ', x + 3, y + 3, 11, true, 1, true)
      -- print(text, x + w - 2 - text_width, y + 3, 4, true, 1, true)
      -- if #input > 0 then sprite_id = ITEMS[input[1]].sprite_id end
      -- sspr(sprite_id, x + w - 12 - text_width, y + 2, 4)

      --output slots icon and item count---------------------------------------------
      -- local text = #output .. '/' .. FURNACE_BUFFER_OUTPUT
      -- local text_width = print(text, 0, -10, 0, true, 1, true)
      -- local sprite_id = 311
      -- print('Output - ', x + 3, y + 15, 11, true, 1, true)
      -- print(text, x + w - 2 - text_width, y + 15, 4, true, 1, true)
      -- if #output > 0 then sprite_id = ITEMS[output[1]].sprite_id end
      -- sspr(sprite_id, x + w - 12 - text_width, y + 13, 4)
      
      --fuel buffer slot icon etc-----------------------------------------------------
      -- local text = #fuel .. '/' .. FURNACE_BUFFER_FUEL
      -- local text_width = print(text, 0, -10, 0, true, 1, true)
      -- local sprite_id = 311
      -- print('Fuel - ', x + 3, y + 24, 11, true, 1, true)
      -- print(text, x + w - 2 - text_width, y + 24, 4, true, 1, true)
      -- if #fuel > 0 then sprite_id = ITEMS[fuel[1]].sprite_id end
      -- sspr(sprite_id, x + w - 12 - text_width, y + 24, 4)
      --large stone furnace graphic------------------------------------------------
      local sprite_id = FURNACE_SPRITE_INACTIVE_ID
      local fx, fy = x + (w / 2) - 8, y + 22 --furnace icon screen pos
      if ent.is_smelting then sprite_id = FURNACE_SPRITE_ACTIVE_ID + (FURNACE_ANIM_TICK * 2) end
      for i = -2, 3 do
        for j = -4, 5 do
          local tile = TileMan.tiles[ent.y + i][ent.x + j]
          local tile_id = tile.tile
          if tile.is_ore then tile_id = ores[tile.index].tile_id end
          sspr(tile_id, fx + (j*8), fy + (i*8), 0, 1, 0, tile.rot)
        end
      end
      rectb(fx - 33, fy - 17, w - 18, 50, 14)
      sspr(sprite_id, fx, fy, 0, 1, 0, 0, 2, 2)
      sspr(437, x + w - 7, y + 2, 0)
    end
  }
end

function Furnace.update(self)
  --update fuel ticks
  if self.fuel_time <= 0 then
    if #self.fuel_buffer > 0 then
      local item_id = table.remove(self.fuel_buffer)
      self.fuel_time = ITEMS[item_id].smelting_time
    end
  end


  if self.is_smelting then
    --update smelting countdown timer
    self.smelt_timer = self.smelt_timer - FURNACE_TICKRATE
    if self.smelt_timer <= 0 then
      --smelting operation completed
      --pop last item from output_buffer to input_buffer
      self.is_smelting = false
      if #self.input_buffer > 0 then
        local ore = table.remove(self.input_buffer)
        local smelted_ore = ITEMS[ore].smelted_id
        table.insert(self.output_buffer, smelted_ore)
        return
      end
    end
  else
    --check for incoming ore
    if not self.is_smelting and #self.input_buffer > 0 and self.fuel_time > 0 and #self.output_buffer < FURNACE_BUFFER_OUTPUT then
      self.is_smelting = true
      self.smelt_timer = FURNACE_SMELT_TIME
    end

  end
end

function Furnace.draw(self)
  local sx, sy = world_to_screen(self.x, self.y)
  if self.is_smelting then
    sspr(FURNACE_SPRITE_ACTIVE_ID + (FURNACE_ANIM_TICK * 2), sx, sy, 0, 1, 0, 0, 2, 2)
  else
    sspr(FURNACE_SPRITE_INACTIVE_ID, sx, sy, 0, 1, 0, 0, 2, 2)
  end  
end

function Furnace.deposit(self, item_id, keep)
  local item = ITEMS[item_id]
  trace(item.type)
  if item.type == 'fuel' then
    if #self.fuel_buffer < 5 then
      if not keep then table.insert(self.fuel_buffer, item_id) end
      return true
    end
  end
  if item.type ~= 'ore' then return end
  if not self.ore_type then
    if not keep then
      self.ore_type = item.name
      table.insert(self.input_buffer, item_id)
    end
    return true
  elseif #self.input_buffer < FURNACE_BUFFER_INPUT and self.ore_type == item.name then
    if not keep then
      table.insert(self.input_buffer, item_id) 
    end
    return true
  end
  return false
end

function NewFurnace(x, y, keys)
  local new_furnace = {x = x, y = y, dummy_keys = keys}
  setmetatable(new_furnace, {__index = Furnace})
  return new_furnace
end

return NewFurnace