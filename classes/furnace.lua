FURNACE_SPRITE_ACTIVE_ID = 490
FURNACE_SPRITE_INACTIVE_ID = 488
FURNACE_FUEL_ICON = 291
FURNACE_ANIM_TICK = 0
FURNACE_ANIM_TICKRATE = 9
FURNACE_ANIM_TICKS = 2
FURNACE_TICKRATE = 5
FURNACE_BUFFER_INPUT = 50
FURNACE_BUFFER_OUTPUT = 100
FURNACE_BUFFER_FUEL = 50
FURNACE_SMELT_TIME = 3 * 60
FURNACE_COLORKEY = 6


local Furnace = {
  x = 0,
  y = 0,
  type = 'stone_furnace',
  is_hovered = false,
  updated = false,
  drawn = false,
  fuel_slots = FURNACE_BUFFER_FUEL,
  output_slots = FURNACE_BUFFER_SIZE,
  output_buffer = {},
  input_buffer = {},
  fuel_buffer = {},
  dummy_keys = {},
  fuel_time = 0,
  smelt_timer = 0,
  ore_type = false,
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
  local sprite_id = 283
  print('Fuel - ', sx + 3, sy + 24, 11, true, 1, true)
  print(text, sx + width - 2 - text_width, sy + 24, 4, true, 1, true)
  if #self.fuel_buffer > 0 then sprite_id = ITEMS[self.fuel_buffer[1]].sprite_id end
  sspr(sprite_id, sx + width - 12 - text_width, sy + 24, 4)
end

function Furnace.open(self)
  return {
    x = 240 - 103,
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
      local bg, fg = 8, 9
      local ent = ENTS[self.ent_key]
      if not ent then return end
      local input, output, fuel = ent.input_buffer, ent.output_buffer, ent.fuel_buffer
      local x, y, w, h = self.x, self.y, self.width, self.height
      --background window and border
      rectb(x, y, w, h, fg)
      rect(x + 1, y + 1, w - 2, h - 2, bg)

      --input slots icon, and item count------------------------------------------

      --input slot
      rectb(x + 9, y + 58, 10, 10, fg)
      rect(x + 10, y + 59, 8, 8, 0)
      print(#input .. '/' .. FURNACE_BUFFER_INPUT, x + 9, y + 70, 4, true, 1, true)
      if #input > 0 then sspr(ITEMS[input[1]].sprite_id, x + 10, y + 59, 4) end

      --smelting progress bar
      rectb(x + 20, y + 61, 60, 5, fg)
      rect(x + 21, y + 62, 58, 3, 0)
      if ent.smelt_timer > 0 then
        rect(x + 21, y + 62, 58 - remap(ent.smelt_timer, 0, FURNACE_SMELT_TIME, 0, 58), 3, 6)
      end
      --output slot
      rectb(x + w - 19, y + 58, 10, 10, fg)
      rect(x + w - 18, y + 59, 8, 8, 0)
      local text_width = print(#output .. '/' .. FURNACE_BUFFER_OUTPUT, 0, -10, 0, true, 1, true)
      print(#output .. '/' .. FURNACE_BUFFER_OUTPUT, x + w - 8 - text_width, y + 70, 4, true, 1, true)
      if #output > 0 then sspr(ITEMS[output[1]].sprite_id, x + w - 18, y + 59, 0) end

      --divider
      line(x + 9, y + 77, x + w - 10, y + 77, fg)

      --fuel slot
      rectb(x + 9, y + 80, 10, 10, fg)
      if #fuel > 0 then
        --rect(x + 10, y + 81, 8, 8, )
        sspr(ITEMS[fuel[1]].sprite_id, x + 10, y + 81, 4)
      else
        sspr(FURNACE_FUEL_ICON, x + 10, y + 81, -1)
      end
      --fuel progress bar
      rectb(x + 20, y + 84, 60, 5, fg)
      rect(x + 21, y + 85, 58, 3, 0)
      if ent.fuel_time > 0 then
        rect(x + 21, y + 85, remap(ent.fuel_time, 0, ITEMS[6].smelting_time, 0, 58), 3, 2)
      end
      print(#fuel .. '/' .. FURNACE_BUFFER_FUEL, x + 9, y + 91, 4, true, 1, true)

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

      --large stone furnace graphic-and terrain background-------------------------
      local sprite_id = FURNACE_SPRITE_INACTIVE_ID
      local fx, fy = x + (w / 2) - 8, y + 22 --furnace icon screen pos
      if ent.is_smelting then sprite_id = FURNACE_SPRITE_ACTIVE_ID + (FURNACE_ANIM_TICK * 2) end
      for i = -2, 3 do
        for j = -4, 5 do
          local tile = TileMan.tiles[ent.y + i][ent.x + j]
          local tile_id = tile.sprite_id
          if tile.ore then
            sspr(biomes[tile.biome].tile_id_offset, fx + (j*8), fy + (i*8), -1, 1, 0, tile.rot)
            sspr(ores[tile.ore].tile_id, fx + (j*8), fy + (i*8), 4, 1, 0, tile.rot)
          elseif tile.is_border and tile.biome > 1 then
            sspr(biomes[tile.biome - 1].tile_id_offset, fx + (j*8), fy + (i*8), -1, 1, 0, tile.rot)
            sspr(tile.sprite_id, fx + (j*8), fy + (i*8), 9, 1, 0, tile.rot)
          else
            sspr(tile.sprite_id, fx + (j*8), fy + (i*8), -1, 1, 0, tile.rot)
          end
        end
      end
      rectb(fx - 33, fy - 17, w - 18, 50, fg)
      sspr(sprite_id, fx, fy, FURNACE_COLORKEY, 1, 0, 0, 2, 2)
      sspr(437, x + w - 7, y + 2, 0)
      print('Stone Furnace', fx - 17, y + 7, 0, true, 1, true)
      print('Stone Furnace', fx - 18, y + 7, 4, true, 1, true)
    end
  }
end

function Furnace.update(self)
  --update fuel ticks
  if self.fuel_time > 0 then
    self.fuel_time = self.fuel_time - FURNACE_TICKRATE
  end

  if self.fuel_time <= 0 then
    --if we run out of fuel_time, check fuel_buffer to re-fuel self
    if self.is_smelting then
      if #self.fuel_buffer > 0 then
        self.fuel_time = ITEMS[table.remove(self.fuel_buffer)].smelting_time
      else
        --otherwise we have ran out of fuel completely, so shut-down
        self.is_smelting = false
      end
    end
  end

  if self.is_smelting then
    --update smelting countdown timer
    self.smelt_timer = self.smelt_timer - FURNACE_TICKRATE
    if self.smelt_timer <= 0 then
      --smelting operation completed
      --pop last item from output_buffer to input_buffer
      self.is_smelting = false
      local ore = table.remove(self.input_buffer)
      local smelted_ore = ITEMS[ore].smelted_id
      table.insert(self.output_buffer, smelted_ore)
      return
    end
  end


    --check for incoming ore
  if not self.is_smelting and #self.input_buffer > 0 and #self.output_buffer < FURNACE_BUFFER_OUTPUT then
    self.is_smelting = true
    self.smelt_timer = FURNACE_SMELT_TIME
  end
  --trace('#FURNACE INPUT BUFFER: ' .. #self.input_buffer)
  --trace('#FURNACE OUTPUT BUFFER: ' .. #self.output_buffer)
  if #self.input_buffer == 0 and #self.output_buffer == 0 then
    self.ore_type = false
  end
end

function Furnace.draw(self)
  local sx, sy = world_to_screen(self.x, self.y)
  --if self.is_hovered then self:draw_hover_widget() end
  if self.is_smelting then
    sspr(FURNACE_SPRITE_ACTIVE_ID + (FURNACE_ANIM_TICK * 2), sx, sy, FURNACE_COLORKEY, 1, 0, 0, 2, 2)
  else
    sspr(FURNACE_SPRITE_INACTIVE_ID, sx, sy, FURNACE_COLORKEY, 1, 0, 0, 2, 2)
  end  
end

function Furnace.deposit(self, item_id, keep)
  keep = keep or false
  local item = ITEMS[item_id]
  if item.type ~= 'ore' and item.type ~= 'fuel' then return false end
  --trace(item.type)
  if item.type == 'fuel' then
    if #self.fuel_buffer < 5 then
      if not keep then table.insert(self.fuel_buffer, item_id) end
      return true
    end
  end
  --trace('try deposit ore')
  --trace('FURNACE ORE TYPE: ' .. tostring(self.ore_type))
  --trace('ITEM ORE TYPE: ' .. item.name)
  --trace('#FURNACE INPUT BUFFER: ' .. #self.input_buffer)
  --trace('#FURNACE OUTPUT BUFFER: ' .. #self.output_buffer)
  -- if not self.ore_type then
  --   if not keep then
  --     self.ore_type = item.name
  --     table.insert(self.input_buffer, item_id)
  --   end
  --   return true
  if item.type ~= 'ore' then return false end

  if #self.input_buffer < FURNACE_BUFFER_INPUT
  and self.ore_type == item.name or not self.ore_type then

    if not keep then
      self.ore_type = item.name
      table.insert(self.input_buffer, item_id) 
    end
    return true

  end

  return false
end

function Furnace.request(self)
  if #self.fuel_buffer < 5 then
    local desired_fuel = 'any'
    if #self.fuel_buffer > 0 then
      desired_fuel = ITEMS[self.fuel_buffer[1]].name
    end
    return 'fuel', desired_fuel
  elseif #self.input_buffer < 5 then
    local desired_ore = 'any'
    if #self.input_buffer > 0 then
      desired_ore = ITEMS[self.input_buffer[1]].name
    end
    return 'ore', desired_ore
  end
  return false
end

function NewFurnace(x, y, keys)
  local new_furnace = --{x = x, y = y, dummy_keys = keys}
  {
  x = x,
  y = y,
  type = 'stone_furnace',
  is_hovered = false,
  updated = false,
  drawn = false,
  fuel_slots = FURNACE_BUFFER_FUEL,
  output_slots = FURNACE_BUFFER_SIZE,
  output_buffer = {},
  input_buffer = {},
  fuel_buffer = {},
  dummy_keys = keys,
  fuel_time = 0,
  smelt_timer = 0,
  ore_type = false,
  is_smelting = false,
  item_id = 14,
}
  setmetatable(new_furnace, {__index = Furnace})
  return new_furnace
end

return NewFurnace