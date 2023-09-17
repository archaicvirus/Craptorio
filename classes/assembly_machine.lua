CRAFTER_ID = 312
CRAFTER_TICKRATE = 5
CRAFTER_TIME_ID = 337
CRAFTER_ANIM_FRAME = 0
CRAFTER_ANIM_RATE = 5
CRAFTER_ANIM_DIR = 1

local Crafter = {
  x = 0,
  y = 0,
  id = 19,
  item_id = 19,
  type = 'assembly_machine',
  is_hovered = false,
  updated = false,
  drawn = false,
  state = 'ready',
  input = {},
  output = {},
  requests = false,
  recipe = false,
  progress = 0,
  tickrate = 5,
}

function Crafter:draw_hover_widget(sx, sy)
  sx, sy = sx or cursor.x + 5, sy or cursor.y + 5
  if not self.recipe then
    return
  end
  local w = 73
  local h = 74
  local x = clamp(sx, 1, 240 - w - 1)
  local y = clamp(sy, 1, 136 - h - 1)
  ui.draw_panel(x, y, w, h, UI_BG, UI_FG, 'Assembly Machine', UI_SH)
  ui.progress_bar(math.min(1.0, self.progress/self.recipe.crafting_time), x + w/2 - 30, y + 12, 60, 6, UI_BG, UI_FG, 6, 0)
  prints('Input', x + w/2 - 12, y + h - 24)
  for k, v in ipairs(self.input) do
    box(x + w/2 - ((#self.input*13)/2) + (k-1)*13, y + h - 15, 10, 10, 8, 9)
    if v.id ~= 0 and v.count > 0 then
      draw_item_stack(x + w/2 - ((#self.input*13)/2) + (k-1)*13 + 1, y + h - 15 + 1, v)
    end
  end
  --draw output items
  prints('Output', x + w/2 - 12, y + 19)
  box(x + w/2 - 6, y + 27, 10, 10, 8, 9)
  for k, v in ipairs(self.recipe.ingredients) do
    draw_item_stack(x + 10 + (k-1)*15 + 1, y + h - 35 + 1, v, true)
    if k < #self.recipe.ingredients then
      prints('+', x + 10 + (k-1)*15 + 1 + 10, y + h - 34 + 1)
    else
      prints('=', x + 10 + (k-1)*15 + 1 + 10, y + h - 34 + 1)
    end
  end
  draw_item_stack(x + 12 + #self.recipe.ingredients*15, y + h - 35 + 1, {id = self.recipe.id, count = self.recipe.count}, true)
  if self.output.count > 0 then
    draw_item_stack(x + w/2 - 5, y + 28, {id = self.output.id, count = self.output.count})
  end
end

function Crafter:draw()
  local x, y = world_to_screen(self.x, self.y)
  local offset = 0
  local blink = TICK % 60 < 30
  sspr(CRAFTER_ID, x, y, 0, 1, 0, 0, 3, 3)
  if self.recipe and alt_mode then
    sspr(ITEMS[self.recipe.id].sprite_id, x + 6, y + 5, ITEMS[self.recipe.id].color_key)
  end
  if self.state == 'crafting' then
    if blink then
      sspr(339, x + 16, y + 15, 0)
      --rect(x + 16, y + 15, 2, 2, 7)
    end
    offset = CRAFTER_ANIM_FRAME
    --pix(sx + 6, sy + 5, blink and 5 or 7)
    --line(sx + 6, sy + 9, sx + 6 + remap(self.progress, 0, self.recipe.crafting_time, 0, 12), sy + 9, 5)

  end
  sspr(348, x + 7 + offset, y + 12, 0)
  sspr(348, x + 14, y + (6 - offset), 0, 1, 0, 3)
  if self.state == 'idle' then
    pal({4,2,4,3,6,3})
    sspr(339, x + 16, y + 15, 0)
    pal()
    --pix(sx + 11, sy + 5, blink and 0 or 3)
  end
  if self.state == 'ready' then
    pal({4,2,5,2,6,2})
    sspr(339, x + 16, y + 15, 0)
    pal()
    --pix(sx + 16, sy + 5, blink and 0 or 2)
  end
end

function Crafter:update()
  if self.recipe then
    self:update_requests()
    if self.state == 'ready' or self.state == 'idle' then
      if self.output.count >= self.recipe.count * 5 then
        self.state = 'ready'
        return
      end
      for i = 1, #self.recipe.ingredients do
        if self.input[i].count < self.recipe.ingredients[i].count then
          return
        end
      end
    end

    self.state = 'crafting'

    --if crafting in progress, update it
    self.progress = self.progress + CRAFTER_TICKRATE
    for i = 1, #self.recipe.ingredients do
      if self.input[i].count < self.recipe.ingredients[i].count then
        self.state = 'ready'
        return
      end
    end

    if self.progress >= self.recipe.crafting_time then
      --we have reached full progress, so check for ingredients to make new item
      self.progress = 0
      self.state = 'ready'
      for i = 1, #self.recipe.ingredients do
        self.input[i].count = self.input[i].count - self.recipe.ingredients[i].count
      end
      self.output.count = self.output.count + self.recipe.count
    end
  end
end

function Crafter:open()
  if not self.recipe then
    -------------NO recipe--------------------
    return {
      width = 73,
      height = 55,
      x = 73,
      y = 18,
      bg = 8,
      fg = 9,
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
        --check for close-button
        if self:close(sx, sy) then
          craft_menu.current_output = 'player'
          ui.active_window = false
          return true
        end
        --if no recipe, check the 'set-recipe' button
        local width = print('Select a recipe', 0, -10, 0, false, 1, true) + 4
        local btn = {x = self.x + ((width + 4)/2) - width/2 - 2, y = self.y + 32, w = width + 4, h = 9}
        local x, y, w, h = btn.x, btn.y, btn.w, btn.h
        if sx >= x and sx < x + w and sy >= y and sy < sy + h then
          --open recipe selection widget
          ui.active_window = false
          --ui.assembly_recipe_widget(self)
          craft_menu.current_output = self.ent_key
          toggle_crafting(true)
          return true
        end
        return false
      end,

      is_hovered = function(self, x, y)
        return x >= self.x and x < self.x + self.width and y >= self.y and y < self.y + self.height and true or false
      end,
      draw = function(self)
        local ent = ENTS[self.ent_key]
        if not ent then self = nil return end
        local input, output, fuel = ent.input_buffer, ent.output_buffer, ent.fuel_buffer
        local x, y, w, h, bg, fg = self.x, self.y, self.width, self.height, self.bg, self.fg
        local width = print('Select a recipe', 0, -10, 0, false, 1, true)
        local c = cursor          
        local btn = {x = x + w/2 - width/2 - 2, y = y + 32, w = width + 4, h = 9}
        btn.color = c.x >= btn.x and c.x < btn.x + btn.w and c.y >= btn.y and c.y < btn.y + btn.h and 9 or 8
        --background window and border
        ui.draw_panel(x, y, w, h, bg, fg, ITEMS[ent.id].fancy_name)
        --input input icon, and item count----------------------------------------
        box(btn.x, btn.y, btn.w, btn.h, btn.color, 9)
        prints('Select a recipe', btn.x + 2, btn.y + 2, 0, 4)
        --assembly machine graphic-and terrain background-------------------------
        sspr(483, x + w/2 - 4, y + 16, 1, 1, 0, 0, 1, 1)
        sspr(CLOSE_ID, x + w - 7, y + 2, 15)
      end
    }
  else
    ------------HAS recipe--------------------
    return {
      x = 240 - 85,
      y = 1,
      w = 80,
      h = 74,
      ent_key = self.x .. '-' .. self.y,
      close = function(self, sx, sy)
        local btn = {x = self.x + self.w - 9, y = self.y + 1, w = 5, h = 5}
        if sx >= btn.x and sy < btn.x + btn.w and sy >= btn.y and sy <= btn.y + btn.h then
          return true
        end
        return false
      end,
      draw = function(self)
        local ent = ENTS[self.ent_key]
        ui.draw_panel(self.x, self.y, self.w, self.h, UI_BG, UI_FG, 'Assembly Machine', UI_SH)
        ui.progress_bar(math.min(1.0, ent.progress/ent.recipe.crafting_time), self.x + self.w/2 - 30, self.y + 12, 60, 6, UI_BG, UI_FG, 6, 0)
        sspr(CLOSE_ID, self.x + self.w - 9, self.y + 2, 15)
        prints('Input', self.x + self.w/2 - 12, self.y + self.h - 24)
        for k, v in ipairs(ent.input) do
          box(self.x + self.w/2 - ((#ent.input*13)/2) + (k-1)*13, self.y + self.h - 15, 10, 10, 8, 9)
          if v.id ~= 0 and v.count > 0 then
            draw_item_stack(self.x + self.w/2 - ((#ent.input*13)/2) + (k-1)*13 + 1, self.y + self.h - 15 + 1, v)
          end
        end
      --draw output items
        prints('Output', self.x + self.w/2 - 12, self.y + 19)
        box(self.x + self.w/2 - 6, self.y + 27, 10, 10, 8, 9)
        --draw recipe icons
        local total_width = (#ent.recipe.ingredients + 1) * 15
        local start_x = (self.x + self.w/2) - (total_width/2)
        for k, v in ipairs(ent.recipe.ingredients) do
          draw_item_stack(start_x + (k-1)*15 + 1, self.y + self.h - 35 + 1, v, true)
          if k < #ent.recipe.ingredients then
            prints('+', start_x + (k-1)*15 + 1 + 10, self.y + self.h - 34 + 1)
          else
            prints('=', start_x + (k-1)*15 + 1 + 10, self.y + self.h - 34 + 1)
          end
        end
        draw_item_stack(start_x + total_width - 12, self.y + self.h - 35 + 1, {id = ent.recipe.id, count = ent.recipe.count}, true)
        if ent.output.count > 0 then
          draw_item_stack(self.x + self.w/2 - 5, self.y + 28, {id = ent.output.id, count = ent.output.count})
        end
        if hovered(cursor, {x = self.x + self.w/2 - 6, y = self.y + 27, w = 10, h = 10}) then
          ui.highlight(self.x + self.w/2 - 6, self.y + 27, 8, 8, false, 3, 4)
          draw_recipe_widget(cursor.x + 5, cursor.y + 5, ent.output.id)
        end
        --draw cursor item
        if self:is_hovered(cursor.x, cursor.y) and cursor.type == 'item' then
          draw_item_stack(cursor.x + 5, cursor.y + 5, {id = cursor.item_stack.id, count = cursor.item_stack.count})
        end
        --input slots hover
        for k, v in ipairs(ent.input) do
          if hovered(cursor, {x = self.x + self.w/2 - ((#ent.input*13)/2) + (k-1)*13, y = self.y + self.h - 15, w = 10, h = 10}) then
            ui.highlight(self.x + self.w/2 - ((#ent.input*13)/2) + (k-1)*13, self.y + self.h - 15, 8, 8, false, 3, 4)
            if v.id ~= 0 then draw_recipe_widget(cursor.x + 5, cursor.y + 5, v.id) end
          end
        end
      end,
      click = function(self, sx, sy)
        local ent = ENTS[self.ent_key]
        if self:close(sx, sy) then
          ui.active_window = nil
          return true
        end
        for k, v in ipairs(ent.input) do
          if v.id ~= 0 and hovered(cursor, {x = self.x + self.w/2 - ((#ent.input*13)/2) + (k-1)*13, y = self.y + self.h - 15, w = 10, h = 10}) then
            local stack_size = ITEMS[ent.output.id].recipe.ingredients[k].count * 5
            --item interaction
            -----------------------------------------------------------------------------------------------------
            if cursor.type == 'pointer' then
              if key(64) then
                local old_count = v.count
                local result, stack = inv:add_item({id = v.id, count = v.count})
                if result then
                  v.count = stack.count
                  sound('deposit')
                  ui.new_alert(cursor.x, cursor.y, '+ ' .. (stack.count == 0 and old_count or old_count - stack.count) .. ' ' .. ITEMS[v.id].fancy_name, 1000, 0, 6)
                  return true
                end
              elseif v.count > 0 then
                if cursor.r and v.count > 1 then
                  set_cursor_item({id = v.id, count = math.ceil(v.count/2)}, false)
                  v.count = math.floor(v.count/2)
                  return true
                else
                  set_cursor_item({id = v.id, count = (v.count)}, false)
                  v.count = 0
                  return true
                end
              end
            elseif cursor.type == 'item' and cursor.item_stack.id == v.id then
              --try to combine stacks, leaving extra on cursor
              if key(64) then
                if v.count > 0 then
                  local old_count = v.count
                  local result, stack = inv:add_item({id = v.id, count = v.count})
                  if result then
                    v.count = stack.count
                    sound('deposit')
                    ui.new_alert(cursor.x, cursor.y, '+ ' .. (stack.count == 0 and old_count or old_count - stack.count) .. ' ' .. ITEMS[v.id].fancy_name, 1000, 0, 6)
                  end
                end
                return true
              end
              if cursor.r then
                if v.count + 1 < stack_size then
                  v.count = v.count + 1
                  cursor.item_stack.count = cursor.item_stack.count - 1
                  if cursor.item_stack.count < 1 then
                    set_cursor_item()
                  end
                  return true
                end
              else
                if cursor.item_stack.count + v.count > stack_size then
                  local old_count = v.count
                  v.count = stack_size
                  cursor.item_stack.count = cursor.item_stack.count - (stack_size - old_count)
                  return true
                else
                  v.count = v.count + cursor.item_stack.count
                  set_cursor_item()
                  return true
                end
              end
            end
            --------------------------------------------------------------------------------------------
          end
        end
        --check output slot
        if ent.output.count > 0 and cursor.type == 'pointer' and hovered({x = sx, y = sy}, {x = self.x + self.w/2 - 6, y = self.y + 27, w = 10, h = 10}) then
          if key(64) then
            local old_count = ent.output.count
            local result, stack = inv:add_item({id = ent.output.id, count = ent.output.count})
            if result then
              ent.output.count = stack.count
              ui.new_alert(cursor.x, cursor.y, '+ ' .. (stack.count == 0 and old_count or old_count - stack.count) .. ' ' .. ITEMS[ent.output.id].fancy_name, 1000, 0, 6)
              sound('deposit')
              return true
            end
          else
            if cursor.r and ent.output.count > 1 then
              set_cursor_item({id = ent.output.id, count = math.ceil(ent.output.count/2)}, false)
              ent.output.count = math.floor(ent.output.count/2)
              return true
            else
              set_cursor_item({id = ent.output.id, count = (ent.output.count)}, false)
              ent.output.count = 0
              return true
            end
          end
        end
        return false
      end,
      is_hovered = function(self, x, y)
        return x >= self.x and x < self.x + self.w and y >= self.y and y < self.y + self.h and true or false
      end,
    }
  end
end

function Crafter:set_recipe(item)
  self.recipe = item.recipe
  for i = 1, #self.recipe.ingredients do
    self.input[i].id = self.recipe.ingredients[i].id
  end
  self.output.id = self.recipe.id
  self.output.count = 0
  self.requests = {}
  for i = 1, #self.recipe.ingredients do
    self.requests[i] = {[1] = true, [2] = false}
    --[1] = 'do I need this item'
    --[2] = 'is an inserter currently delivering this'
  end
end

function Crafter:update_requests()
  for i = 1, #self.requests do
    --if ingredients are low, request more items
    if self.input[i].count < self.recipe.ingredients[i].count*2 then
      self.requests[i][1] = true
    end
    --self.requests[i][2] = false
  end
end

function Crafter:get_request()
  for i = 1, #self.requests do
    -- check if inserter is already dispatched for this item
    if self.requests[i][1] and not self.requests[i][2] then
      return self.recipe.ingredients[i].id
    end
  end
  return false
end

function Crafter:assign_delivery(id)
  for k, v in ipairs(self.recipe.ingredients) do
    if v.id == id then
      self.requests[k][2] = true
      --now, an inserter has been dispatched to retrieve this item
      --freeing up other possible inserters for different tasks
      return
    end
  end
end

function Crafter:request_deposit()
  if not self.recipe then return false end
  return self:get_request()
end

function Crafter:deposit(id)
  if not self.recipe then return false end
  for k, v in ipairs(self.recipe.ingredients) do
    if id == self.input[k].id then
      self.input[k].count = self.input[k].count + 1
      self.requests[k][2] = false
      if self.input[k].count >= v.count*2 then
        self.requests[k][1] = false
      end
      return true
    end
  end
  return false
end

function Crafter:item_request(id)
  if not self.recipe then return false end
  if self.output.count > 0 and (self.output.id == id or id == 'any') then
    self.output.count = self.output.count - 1
    return self.output.id
  end
  return false
end

function Crafter:deposit_stack(stack)
  if self.recipe then
    for i = 1, #self.recipe.ingredients do
      local max_stack_per_slot = self.recipe.ingredients[i].count*5
      if self.recipe.ingredients[i].id == stack.id then
        if self.input[i].count + stack.count <= max_stack_per_slot then
          self.input[i].count = self.input[i].count + stack.count
          self.input[i].id = stack.id
          self.state = 'ready'
          -- sound('deposit')
          -- ui.new_alert(cursor.x, cursor.y, stack.count .. ' ' .. ITEMS[stack.id].fancy_name, 1000, 0, 11)
          return true, {id = 0, count = 0}
        elseif self.input[i].count < max_stack_per_slot and self.input[i].count + stack.count > max_stack_per_slot then
          local diff = max_stack_per_slot - self.input[i].count
          self.input[i].count = max_stack_per_slot
          self.input[i].id = stack.id
          self.state = 'ready'
          -- sound('deposit')
          -- ui.new_alert(cursor.x, cursor.y, stack.count .. ' ' .. ITEMS[stack.id].fancy_name, 1000, 0, 11)
          return true, {id = stack.id, count = stack.count - diff}
        end
      end
    end
  end
  return false, {id = stack.id, count = stack.count}
end

function Crafter:return_all()
  if not self.recipe then return end
  for k, v in ipairs(self.input) do
    if v.count > 0 then
      local result, stack = inv:add_item(v)
      if stack.count < v.count then
        sound('deposit')
        ui.new_alert(cursor.x, cursor.y, '+' .. v.count - stack.count .. ' ' .. ITEMS[v.id].fancy_name, 1500, 0, 5)
      end
      v.count = stack.count
    end
  end
  if self.output.count > 0 then
    local result, stack = inv:add_item({id = self.output.id, count = self.output.count})
    if self.output.count > stack.count then
      sound('deposit')
      ui.new_alert(cursor.x, cursor.y, '+' .. self.output.count - stack.count .. ' ' .. ITEMS[self.output.id].fancy_name, 1500, 0, 5)
    end
    self.output.count = stack.count
  end
end

function new_assembly_machine(wx, wy)
  local obj = {x = wx, y = wy}
  obj.output = {id = 0, count = 0, sprite = 0, stack_size = 0}
  obj.input = {
    [1] = {id = 0, count = 10},
    [2] = {id = 0, count = 0},
    [3] = {id = 0, count = 0},
    [4] = {id = 0, count = 0},
  }
  setmetatable(obj, {__index = Crafter})
  return obj
end