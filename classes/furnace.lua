FURNACE_ID = 488
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
FURNACE_FIRE_KEYS = {7,11,10}


Furnace = {
  x = 0,
  y = 0,
  type = 'stone_furnace',
  is_hovered = false,
  updated = false,
  drawn = false,
  item_id = 14,
  fuel_slots = FURNACE_BUFFER_FUEL,
  last_fuel = false,
  output_slots = FURNACE_BUFFER_SIZE,
  output_buffer = {id = 0, count = 0},
  input_buffer = {id = 0, count = 0},
  fuel_buffer = {id = 0, count = 0},
  dummy_keys = {},
  fuel_time = 0,
  smelt_timer = 0,
  ore_type = false,
  is_smelting = false,
}

function Furnace:draw_hover_widget()
  local sx, sy = cursor.x, cursor.y
  local offset = {x = 3, y = 3}
  local w, h = print('Stone Furnace', 0, -10, 0, false, 1, true) + 4, 50
  local x, y = clamp(sx + offset.x, 0, 240 - w - offset.x), clamp(sy + offset.y, 0, 136 - h - offset.y)
  --window fill and border
  ui.draw_panel(x, y, w, h, _, _, 'Stone Furnace', UI_BG)
  -- rectb(x, y, w, h, 9)
  -- rect(x + 1, y + 1, w - 2, h - 2, 8)
  --top bar for text
  rect(x + 1, y + 1, w - 2, 8, 9)
  prints('Stone Furnace', x + 2, y + 2, 0, 4)
  --furnace sprite icon
  self:draw_sprite(x + w/2 - 8, y + 15)
  --item slots
  box(x + 5, y + 18, 10, 10, 0, 9)
  box(x + w - 15, y + 18, 10, 10, 0, 9)
  box(x + w/2 - 5, y + 35, 10, 10, 0, 9)
  if self.input_buffer.count > 0 then
    draw_item_stack(x + 6, y + 19, self.input_buffer)
  end
  if self.output_buffer.count > 0 then
    draw_item_stack(x + w - 14, y + 19, self.output_buffer)
  end
  if self.fuel_buffer.count > 0 then
    draw_item_stack(x + w/2 - 3, y + 36, self.fuel_buffer)
  end
end

function Furnace:open()
  return {
    x = 163,
    y = 2,
    width = 74,
    height = 89,
    input  = {x = 4, y = 45, w = 10, h = 10},
    output = {x = 60, y = 45, w = 10, h = 10},
    fuel   = {x = 4, y = 68, w = 10, h = 10},
    close = function(self, sx, sy)
      -- 5x5 close button sprite
      local cx, cy, cw, ch = self.x + self.width - 9, self.y + 2, 5, 5
      if sx >= cx and sx < cx + cw and sy >= cy and sy < cy + ch then
        return true
      end
      return false
    end,
    ent_key = self.x .. '-' .. self.y,
    click = function(self, sx, sy)
      if self:is_hovered(sx, sy) then
        if self:close(sx, sy) then
          ui.active_window = nil
          return true
        end

        local ent = ENTS[self.ent_key]
        local stack = cursor.item_stack

        if hovered(cursor, {x = self.input.x + self.x, y = self.input.y + self.y, w = self.input.w, h = self.input.h}) then
          --item interaction
          if key(64) then
            local old_count = ent.input_buffer.count
            local result, stack = inv:add_item({id = ent.input_buffer.id, count = ent.input_buffer.count})
            if result then
              ent.input_buffer.count = stack.count
              sound('deposit')
              ui.new_alert(cursor.x, cursor.y, '+ ' .. (stack.count == 0 and old_count or old_count - stack.count) .. ' ' .. ITEMS[ent.input_buffer.id].fancy_name, 1000, 0, 6)
              return true
            end
          end
          if cursor.type == 'pointer' then
            if ent.input_buffer.count > 0 then
              if cursor.r and ent.input_buffer.count > 1 then
                set_cursor_item({id = ent.input_buffer.id, count = math.ceil(ent.input_buffer.count/2)}, false)
                ent.input_buffer.count = floor(ent.input_buffer.count/2)
                return true
              else
                set_cursor_item({id = ent.input_buffer.id, count = ent.input_buffer.count}, false)
                ent.input_buffer.count = 0
                ent.input_buffer.id = 0
                return true
              end
            end
          elseif cursor.type == 'item' and cursor.item_stack.id == ent.input_buffer.id  or (ent.input_buffer.id == 0 and ITEMS[cursor.item_stack.id].type == 'ore') then
            if ITEMS[cursor.item_stack.id].required_tech and not TECH[ITEMS[cursor.item_stack.id].required_tech].completed then
              return false
            end
            local stack_size = ITEMS[cursor.item_stack.id].stack_size
            --try to combine stacks, leaving extra on cursor
            if key(64) then
              if ent.input_buffer.count > 0 then
                local id = ent.input_buffer.id
                local result, stack = inv:add_item({id = ent.input_buffer.id, count = ent.input_buffer.count})
                if result then
                  ent.input_buffer.count = stack.count
                  sound('deposit')
                  ui.new_alert(cursor.x, cursor.y, '+ ' .. (stack.count == 0 and old_count or old_count - stack.count) .. ' ' .. ITEMS[id].fancy_name, 1000, 0, 6)
                end
              end
              return true
            end
            if cursor.r then
              if ent.input_buffer.count + 1 < stack_size then
                ent.input_buffer.count = ent.input_buffer.count + 1
                cursor.item_stack.count = cursor.item_stack.count - 1
                if cursor.item_stack.count < 1 then
                  set_cursor_item()
                end
                return true
              end
            else
              if cursor.item_stack.count + ent.input_buffer.count > stack_size then
                local old_count = ent.input_buffer.count
                ent.input_buffer.count = stack_size
                cursor.item_stack.count = cursor.item_stack.count - (stack_size - old_count)
                return true
              else
                ent.input_buffer.count = ent.input_buffer.count + cursor.item_stack.count
                set_cursor_item()
                return true
              end
            end
          end
        elseif hovered(cursor, {x = self.output.x + self.x, y = self.output.y + self.y, w = self.output.w, h = self.output.h}) then

          --item interaction
          if cursor.type == 'pointer' then
            if key(64) then
              local old_count = ent.output_buffer.count
              local result, stack = inv:add_item({id = ent.output_buffer.id, count = ent.output_buffer.count})
              if result then
                ent.output_buffer.count = stack.count
                sound('deposit')
                ui.new_alert(cursor.x, cursor.y, '+ ' .. (stack.count == 0 and old_count or old_count - stack.count) .. ' ' .. ITEMS[ent.output_buffer.id].fancy_name, 1000, 0, 6)
                return true
              end
            elseif ent.output_buffer.count > 0 then
              if cursor.r and ent.output_buffer.count > 1 then
                set_cursor_item({id = ent.output_buffer.id, count = math.ceil(ent.output_buffer.count/2)}, false)
                ent.output_buffer.count = floor(ent.output_buffer.count/2)
                return true
              else
                set_cursor_item({id = ent.output_buffer.id, count = ent.output_buffer.count}, false)
                ent.output_buffer.count = 0
                return true
              end
            end
          elseif cursor.type == 'item' then
            local stack_size = ITEMS[cursor.item_stack.id].stack_size
            --try to combine stacks, leaving extra on cursor
            if key(64) then
              if ent.output_buffer.count > 0 then
                local result, stack = inv:add_item({id = ent.output_buffer.id, count = ent.output_buffer.count})
                if result then
                  ent.output_buffer.count = stack.count
                  sound('deposit')
                  ui.new_alert(cursor.x, cursor.y, '+ ' .. (stack.count == 0 and old_count or old_count - stack.count) .. ' ' .. ITEMS[ent.output_buffer.id].fancy_name, 1000, 0, 6)
                end
              end
              return true
            end
          end
        elseif hovered(cursor, {x = self.fuel.x + self.x, y = self.fuel.y + self.y, w = self.fuel.w, h = self.fuel.h}) then
          --item interaction
          if cursor.type == 'pointer' then
            if key(64) then
              local old_count = ent.fuel_buffer.count
              local result, stack = inv:add_item({id = ent.fuel_buffer.id, count = ent.fuel_buffer.count})
              if result then
                ent.fuel_buffer.count = stack.count
                sound('deposit')
                ui.new_alert(cursor.x, cursor.y, '+ ' .. (stack.count == 0 and old_count or old_count - stack.count) .. ' ' .. ITEMS[ent.fuel_buffer.id].fancy_name, 1000, 0, 6)
                return true
              end
            elseif ent.fuel_buffer.count > 0 then
              if cursor.r and ent.fuel_buffer.count > 1 then
                set_cursor_item({id = ent.fuel_buffer.id, count = math.ceil(ent.fuel_buffer.count/2)}, false)
                ent.fuel_buffer.count = floor(ent.fuel_buffer.count/2)
                return true
              else
                set_cursor_item({id = ent.fuel_buffer.id, count = ent.fuel_buffer.count}, false)
                ent.fuel_buffer.count = 0
                return true
              end
            end
          elseif cursor.type == 'item' and cursor.item_stack.id == ent.fuel_buffer.id  or (ent.fuel_buffer.id == 0 and ITEMS[cursor.item_stack.id].type == 'fuel') then
            if ITEMS[cursor.item_stack.id].required_tech and not TECH[ITEMS[cursor.item_stack.id].required_tech].completed then
              return false
            end
            local stack_size = ITEMS[cursor.item_stack.id].stack_size
            --try to combine stacks, leaving extra on cursor
            if key(64) then
              if ent.fuel_buffer.count > 0 then
                local result, stack = inv:add_item({id = ent.fuel_buffer.id, count = ent.fuel_buffer.count})
                if result then
                  ent.fuel_buffer.count = stack.count
                  sound('deposit')
                  ui.new_alert(cursor.x, cursor.y, '+ ' .. (stack.count == 0 and old_count or old_count - stack.count) .. ' ' .. ITEMS[ent.fuel_buffer.id].fancy_name, 1000, 0, 6)
                end
              end
              return true
            end
            if cursor.r then
              if ent.fuel_buffer.count + 1 < stack_size then
                ent.fuel_buffer.count = ent.fuel_buffer.count + 1
                cursor.item_stack.count = cursor.item_stack.count - 1
                if cursor.item_stack.count < 1 then
                  set_cursor_item()
                end
                return true
              end
            else
              if cursor.item_stack.count + ent.fuel_buffer.count > stack_size then
                local old_count = ent.fuel_buffer.count
                ent.fuel_buffer.count = stack_size
                cursor.item_stack.count = cursor.item_stack.count - (stack_size - old_count)
                return true
              else
                ent.fuel_buffer.count = ent.fuel_buffer.count + cursor.item_stack.count
                set_cursor_item()
                return true
              end
            end
          end
        end
      end
      return false
    end,
    is_hovered = function(self, x, y)
      return x >= self.x and x < self.x + self.width and y >= self.y and y < self.y + self.height and true or false
    end,
    draw = function(self)
      --trace('drawing furnace UI')
      local bg, fg = 8, 9
      local ent = ENTS[self.ent_key]
      if not ent then return end
      local input, output, fuel = ent.input_buffer, ent.output_buffer, ent.fuel_buffer
      local x, y, w, h = self.x, self.y, self.width, self.height
      local fx, fy = x + (w / 2) - 8, y + 19 --furnace icon screen pos
      --background window and border
      ui.draw_panel(x, y, w, h, bg, fg, 'Stone Furnace', UI_BG)
      -- --close button
       sspr(CLOSE_ID, x + w - 9, y + 2, 15)
      --input slot
      box(self.input.x + self.x, self.input.y + self.y, self.input.w, self.input.h, 0, 9)
      if ent.input_buffer.count > 0 then
        draw_item_stack(self.input.x + self.x + 1, self.input.y + self.y + 1, ent.input_buffer)
      end
       --self.input:draw(self.x, self.y, ent.input_buffer)
       --box(x + 4, y + 45, 10, 10, 0, fg)
       --prints(input.count .. '/' .. FURNACE_BUFFER_INPUT, x + 4, y + 57, 0, 4)
      if input.count > 0 then
        --sspr(ITEMS[input.id].sprite_id, x + 5, y + 46, ITEMS[input.id].color_key)
      end
      --smelting progress bar
      box(x + 16, y + 47, 42, 5, 0, fg)
      if ent.smelt_timer > 0 then
        rect(x + 17, y + 48, 40 - remap(ent.smelt_timer, 0, FURNACE_SMELT_TIME, 0, 40), 3, 6)
      end
      --output slot
      box(self.output.x + self.x, self.output.y + self.y, self.output.w, self.output.h, 0, 9)
      if ent.output_buffer.count > 0 then
        draw_item_stack(self.output.x + self.x + 1, self.output.y + self.y + 1, ent.output_buffer)
      end
      --self.output:draw(self.x, self.y, ent.output_buffer)
      --box(x + w - 14, y + 45, 10, 10, 0, fg)
      local text_width = print(output.count .. '/' .. FURNACE_BUFFER_OUTPUT, 0, -10, 0, false, 1, true)
      --prints(output.count .. '/' .. FURNACE_BUFFER_OUTPUT, x + w - 4 - text_width, y + 57, 0, 4)
      --if output.count > 0 then sspr(ITEMS[output.id].sprite_id, x + w - 13, y + 46, ITEMS[output.id].color_key) end
      -- --divider
      line(x + 4, y + 65, x + w - 5, y + 65, fg)
      -- --fuel slot
      --rectb(x + 4, y + 68, 10, 10, fg)
      box(self.fuel.x + self.x, self.fuel.y + self.y, self.fuel.w, self.fuel.h, 0, 9)
      if ent.fuel_buffer.count > 0 then
        draw_item_stack(self.fuel.x + self.x + 1, self.fuel.y + self.y + 1, ent.fuel_buffer)
      end
      --self.fuel:draw(self.x, self.y, ent.fuel_buffer)
      if fuel.count > 0 then
        --sspr(ITEMS[fuel.id].sprite_id, x + 5, y + 69, ITEMS[fuel.id].color_key)
      else
        sspr(FURNACE_FUEL_ICON, x + 5, y + 69, -1)
      end
      -- --fuel progress bar
      box(x + 16, y + 71, 42, 5, 0, fg)
      if ent.fuel_time > 0 and ent.last_fuel then
        rect(x + 17, y + 72, remap(ent.fuel_time, 0, ITEMS[ent.last_fuel].fuel_time, 0, 40), 3, 2)
      end
      --prints(fuel.count .. '/' .. FURNACE_BUFFER_FUEL, x + 4, y + 80, 0, 4)
      -- --terrain background-------------------------
      local sprite_id = FURNACE_ID
      for i = -1, 2 do
        for j = -3, 4 do
          local tile = TileMan.tiles[ent.y + i][ent.x + j]
          local tile_id = tile.sprite_id
          if tile.ore then
            sspr(biomes[tile.biome].tile_id_offset, fx + (j*8), fy + (i*8), -1, 1, 0, tile.rot)
            sspr(ores[tile.ore].tile_id, fx + (j*8), fy + (i*8), 4, 1, 0, tile.rot)
          elseif tile.is_border and tile.biome == 1 then
            sspr(WATER_SPRITE, fx + (j*8), fy + (i*8), -1, 1, 0, tile.rot)
            sspr(tile.sprite_id, fx + (j*8), fy + (i*8), 0, 1, 0, tile.rot)
          else
            sspr(tile.sprite_id, fx + (j*8), fy + (i*8), -1, 1, 0, tile.rot)
          end
        end
      end
      -- --terrain border
      rectb(fx - 25, fy - 8, 66, 33, fg)
      --furnace graphic
      ent:draw_sprite(fx, fy, ent.is_smelting)
      local hov = self:is_hovered(cursor.x, cursor.y)
      if hov and cursor.type == 'item' and cursor.item_stack.id > 0 then
        draw_item_stack(cursor.x + 5, cursor.y + 5, {id = cursor.item_stack.id, count = cursor.item_stack.count})
      end

      if hov then
        local slots = {[1] = self.input, [2] = self.output, [3] = self.fuel}
        for k, v in ipairs(slots) do
          if hovered({x = cursor.x, y = cursor.y}, {x = v.x + self.x, y = v.y + self.y, w = v.w, h = v.h}) then
            ui.highlight(self.x + v.x, self.y + v.y, 8, 8, false, 3, 4)
          end
        end
      end

    end
  }
end

function Furnace:draw_sprite(x, y, smelting)
  local color_keys = {2, 3, 4}
  local fire_keys = {7,11,10}
  sspr(FURNACE_ID, x, y, FURNACE_COLORKEY, 1, 0, 0, 2, 2)
  if self.is_smelting or smelting then
    sspr(490, x + 7, y + 12, 0)
  end
end

function Furnace:update()
  --update fuel ticks
  if self.fuel_time > 0 then
    self.fuel_time = self.fuel_time - FURNACE_TICKRATE
  end

  if self.fuel_time <= 0 then
    --if we run out of fuel_time, check fuel_buffer to re-fuel self
    if self.is_smelting then
      if self.fuel_buffer.count > 0 then
        self.fuel_buffer.count = self.fuel_buffer.count - 1
        self.fuel_time = ITEMS[self.fuel_buffer.id].fuel_time
        self.last_fuel = self.fuel_buffer.id
        if self.fuel_buffer.count == 0 then
          self.fuel_buffer.id = 0
        end
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
      local smelted_ore = self.input_buffer.count > 0 and ITEMS[self.input_buffer.id].smelted_id or false
      self.is_smelting = false
      if not smelted_ore then
        return
      end
      if self.output_buffer.count == 0 then
        self.output_buffer.id = smelted_ore
        self.input_buffer.count = self.input_buffer.count - 1
        self.output_buffer.count = self.output_buffer.count + 1
      elseif self.output_buffer.count < ITEMS[self.output_buffer.id].stack_size then
        self.input_buffer.count = self.input_buffer.count - 1
        self.output_buffer.count = self.output_buffer.count + 1
      end
      return
    end
  end


    --check for incoming ore
  if not self.is_smelting and self.input_buffer.count > 0 and self.output_buffer.count < FURNACE_BUFFER_OUTPUT and (self.fuel_time > 0 or self.fuel_buffer.count > 0) then
    self.is_smelting = true
    self.smelt_timer = FURNACE_SMELT_TIME
  end
  if self.input_buffer.count == 0 and self.output_buffer.count == 0 then
    self.input_buffer.id = 0
    self.output_buffer.id = 0
    self.ore_type = false
  end
end

function Furnace:draw()
  local sx, sy = world_to_screen(self.x, self.y)
  self:draw_sprite(sx, sy)
  --if self.is_hovered then self:draw_hover_widget() end
end

function Furnace:deposit_stack(stack)
  local item = ITEMS[stack.id]
  if item.type == 'fuel' then
    if self.fuel_buffer.id == 0 or self.fuel_buffer.id == stack.id then
      if self.fuel_buffer.count + stack.count <= ITEMS[stack.id].stack_size then
        --add stack to fuel slot, return true\
        self.fuel_buffer.id = stack.id
        self.fuel_buffer.count = self.fuel_buffer.count + stack.count
        return true, {id = 0, count = 0}
      elseif self.fuel_buffer.count + stack.count > ITEMS[self.fuel_buffer.id].stack_size then
        --fill slot count, return partial stack
        local remaining = stack.count - (ITEMS[self.fuel_buffer.id].stack_size - self.fuel_buffer.count)
        self.fuel_buffer.count = ITEMS[self.fuel_buffer.id].stack_size
        stack.count = remaining
        return true, stack
      end
    end
  elseif item.type == 'ore' then
    if item.required_tech and not TECH[item.required_tech].completed then
      return false, stack
    end
    if self.input_buffer.id == 0 or self.input_buffer.id == stack.id then
      if self.input_buffer.count + stack.count <= ITEMS[stack.id].stack_size then
        --add stack to input slot, return true\
        self.input_buffer.id = stack.id
        self.input_buffer.count = self.input_buffer.count + stack.count
        return true, {id = 0, count = 0}
      elseif self.input_buffer.count + stack.count > ITEMS[self.input_buffer.id].stack_size then
        --fill slot count, return partial stack
        local remaining = stack.count - (ITEMS[self.input_buffer.id].stack_size - self.input_buffer.count)
        self.input_buffer.count = ITEMS[self.input_buffer.id].stack_size
        stack.count = remaining
        return true, stack
      end
    end
  -- elseif item.type == 'intermediate' then
  --   if self.output_buffer.id == stack.id then
  --     if self.output_buffer.count + stack.count <= ITEMS[stack.id].stack_size then
  --       --add stack to input slot, return true\
  --       self.output_buffer.count = self.output_buffer.count + stack.count
  --       return true, {id = 0, count = 0}
  --     elseif self.output_buffer.count + stack.count > ITEMS[self.output_buffer.id].stack_size then
  --       --fill slot count, return partial stack
  --       local remaining = stack.count - (ITEMS[self.output_buffer.id].stack_size - self.output_buffer.count)
  --       self.output_buffer.count = ITEMS[self.output_buffer.id].stack_size
  --       stack.count = remaining
  --       return true, stack
  --     end
  --   end
  end
  return false, stack
end

-- function Furnace:deposit(id, keep)
--   --trace('attempting quick-deposit')
--   keep = keep or false
--   local item = ITEMS[id]
--   if (item.type ~= 'ore' and item.type ~= 'fuel') and not item.smelted_id then return false end
--   if item.type == 'fuel' and (id == self.fuel_buffer.id or self.fuel_buffer.id == 0 or self.fuel_buffer.count == 0) then
--     if self.fuel_buffer.count < 5 then
--       if not keep then
--         self.fuel_buffer.id = id
--         self.fuel_buffer.count = self.fuel_buffer.count + 1
--       end
--       return true
--     end
--   end
--   if item.type ~= 'ore' and not item.smelted_id then return false end
--   if self.input_buffer.count < FURNACE_BUFFER_INPUT and (self.ore_type == item.name or not self.ore_type) then
--     if (item.required_tech and TECH[item.required_tech].completed) or not item.required_tech then
--       if not keep then
--         self.ore_type = item.name
--         self.input_buffer.id = id
--         self.input_buffer.count = self.input_buffer.count + 1
--       end
--       return true
--     end
--   end
--   return false
-- end

function Furnace:request()
  if self.fuel_buffer.count < 5 and self.input_buffer.count > 0 then
    local desired_fuel = 'any'
    if self.fuel_buffer.count > 0 then
      desired_fuel = ITEMS[self.fuel_buffer.id].name
    end
    return 'fuel', desired_fuel
  elseif self.input_buffer.count < 5 then
    local desired_ore = 'any'
    if self.input_buffer.count > 0 then
      desired_ore = ITEMS[self.input_buffer.id].name
    end
    return 'ore', desired_ore
  end
  return false
end

function Furnace:request_output(keep)
  if self.output_buffer.count > 0 then
    local id = self.output_buffer.id
    if self.output_buffer.count < 0 then
      --set ore_type to nil?
      --self.output_buffer.id = 0
    end
    if keep then
      return true
    else
      self.output_buffer.count = self.output_buffer.count - 1
      return id
    end
  end
  return false
end

function Furnace:request_deposit(inserter)
  if self.fuel_buffer.count < 5 then
    if self.input_buffer.count < 1 and self.fuel_buffer.count > 1  then
      return self.input_buffer.id > 0 and self.input_buffer.id or 'ore'
    else
      return self.fuel_buffer.id > 0 and self.fuel_buffer.id or 'fuel'
    end
  end
  if self.input_buffer.count < 5 then
    if self.fuel_buffer.count < 1 and self.fuel_buffer.count > 1  then
      return self.fuel_buffer.id > 0 and self.fuel_buffer.id or 'fuel'
    else
      return self.input_buffer.id > 0 and self.input_buffer.id or 'ore'
    end
  end
  return false
end

function Furnace:deposit(id)
  local item = ITEMS[id]
  if not item or item.type ~= 'fuel' and not item.smelted_id then return false end
  if item.type == 'fuel' then
    if self.fuel_buffer.id == id or self.fuel_buffer.id == 0 then
      self.fuel_buffer.id = id
      if self.fuel_buffer.count < ITEMS[id].stack_size then
        self.fuel_buffer.count = self.fuel_buffer.count + 1
        return true
      end
    end
  elseif ((item.required_tech and TECH[item.required_tech].completed) or not item.required_tech) and (self.input_buffer.id == id or self.input_buffer.id == 0) then
    self.input_buffer.id = id
    if self.input_buffer.count < ITEMS[id].stack_size then
      self.input_buffer.count = self.input_buffer.count + 1
      return true
    end
  end
  return false
end

function Furnace:item_request(id)
  if self.output_buffer.id < 1 or self.output_buffer.count < 1 then return false end
  if self.output_buffer.id == id or id == 'any' or ITEMS[self.output_buffer.id].type == id then
    local item_id = self.output_buffer.id
    self.output_buffer.count = self.output_buffer.count - 1
    if self.output_buffer.count == 0 and self.input_buffer == 0 then
      self.output_buffer.id = 0
    end
    return item_id
  end
  return false
end

function Furnace:return_all()
  local x, y = cursor.x, cursor.y
  if self.output_buffer.count > 0 then
    local result, stack = inv:add_item({id = self.output_buffer.id, count = self.output_buffer.count})
    if stack.count < self.output_buffer.count then
      sound('deposit')
      ui.new_alert(x, y, '+' .. self.output_buffer.count - stack.count .. ' ' .. ITEMS[self.output_buffer.id].fancy_name, 1500, 0, 5)
      y = y + 7
    end
    self.output_buffer.count = stack.count
  end
  if self.input_buffer.count > 0 then
    local result, stack = inv:add_item({id = self.input_buffer.id, count = self.input_buffer.count})
    if stack.count < self.input_buffer.count then
      sound('deposit')
      ui.new_alert(x, y, '+' .. self.input_buffer.count - stack.count .. ' ' .. ITEMS[self.input_buffer.id].fancy_name, 1500, 0, 5)
      y = y + 7
    end
    self.input_buffer.count = stack.count
  end
  if self.fuel_buffer.count > 0 then
    local result, stack = inv:add_item({id = self.fuel_buffer.id, count = self.fuel_buffer.count})
    if stack.count < self.fuel_buffer.count then
      sound('deposit')
      ui.new_alert(x, y, '+' .. self.fuel_buffer.count - stack.count .. ' ' .. ITEMS[self.fuel_buffer.id].fancy_name, 1500, 0, 5)
    end
    self.fuel_buffer.count = stack.count
  end
end

function new_furnace(x, y, keys)
  local new_furnace = {
    x = x,
    y = y,
    type = 'stone_furnace',
    is_hovered = false,
    updated = false,
    drawn = false,
    fuel_slots = FURNACE_BUFFER_FUEL,
    output_slots = FURNACE_BUFFER_SIZE,
    output_buffer = {id = 0, count = 0},
    input_buffer = {id = 0, count = 0},
    fuel_buffer = {id = 0, count = 0},
    dummy_keys = keys,
    fuel_time = 0,
    smelt_timer = 0,
    ore_type = false,
    is_smelting = false,
  }
  setmetatable(new_furnace, {__index = Furnace})
  return new_furnace
end