REFINERY_ID = 371

local Refinery = {
  x = 0,
  y = 0,
  recipe = false,
  input = {},
  output = {},
  type = 'bio_refinery',
  id = 30,
  item_id = 30,
  is_hovered = false,
  updated = false,
  drawn = false,
  state = 'ready',
  requests = false,
  progress = 0,
  requests = {},
  dummy_keys = {},
  tickrate = 5,
}

function Refinery:update()
  --trace('crafter state: ' .. tostring(self.state))
  if not self.recipe then return end
  self:update_requests()
  local max_output = ITEMS[self.output.id].recipe.count * 5
  --self:update_requests()
  if self.state ~= 'crafting' and self.state ~= 'idle' then
    local has_enough = true
    for i = 1, #self.recipe.ingredients do
      if self.input[i].count < self.recipe.ingredients[i].count then
        has_enough = false
      end
    end

    if has_enough and self.output.count < max_output then
      self.state = 'crafting'
    end
  end
  --if crafting in progress, update it
  if self.state == 'crafting' then
    --trace(self.progress)
    self.progress = self.progress + CRAFTER_TICKRATE
    --we have reached full progress, so check for ingredients to make new item
    if self.progress >= self.recipe.crafting_time then
      self.progress = 0
      self.state = 'ready'

      local has_enough = false
      for i = 1, #self.recipe.ingredients do
        if self.input[i].count >= self.recipe.ingredients[i].count then
          has_enough = true
        end
      end

      if has_enough and self.output.count < max_output then
        for i = 1, #self.recipe.ingredients do
          self.input[i].count = self.input[i].count - self.recipe.ingredients[i].count
        end
        self.output.count = self.output.count + self.recipe.count
      end
      --idle mode?
      -- if self.output.count >= ITEMS[self.output.id].stack_size then
      --   self.state = 'idle'
      -- end
    end
  end
end

function Refinery:draw()
  local sx, sy = world_to_screen(self.x, self.y)
  sspr(REFINERY_ID, sx, sy, ITEMS[30].color_key, 1, 0, 0, 3, 3)
  self.drawn = true
end

function Refinery:draw_hover_widget()
  local w, h = 63, 66
  local x, y = clamp(cursor.x + 5, 1, 240 - w - 2), clamp(cursor.y + 5, 1, 135 - h - 1)
  if not self.recipe then
    ui.draw_panel(x, y, w, 10, 8, 9, 'No Recipe Set', 0)
    return
  end
  
  --local txt = ITEMS[ENTS[self.ent_key].id].fancy_name
  ui.draw_panel(x, y, w, h, UI_BG, UI_FG, 'Bio Refinery', UI_SH)
  ui.progress_bar(math.min(1.0, self.progress/self.recipe.crafting_time), x + w/2 - 25, y + 12, 50, 6, UI_BG, UI_FG, 6, 0)
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
  if self.output.count > 0 then
    draw_item_stack(x + w/2 - 4, y + 28, {id = self.output.id, count = self.output.count})
  end
end

function Refinery:deposit_stack(stack)
  if not self.recipe then return end
  for k, v in ipairs(self.input) do
    if v.id == stack.id then
      local stack_size = self.recipe.ingredients[k].count * 5
      if v.count < stack_size then
        if v.count + stack.count <= stack_size then
          v.count = v.count + stack.count
          return true, {id = 0, count = 0}
        elseif v.count + stack.count > stack_size then
          stack.count = stack.count - (stack_size - v.count)
          v.count = stack_size
          return true, stack
        end
        return false, stack
      end
    end
  end
  return false, stack
end

function Refinery:set_recipe(item)
  self.recipe = item.recipe
  for i = 1, #self.recipe.ingredients do
    self.input[i].id = self.recipe.ingredients[i].id
    --self.input[i].count = ITEMS[self.input[i].id].stack_size
  end
  self.output.id = self.recipe.id
  self.requests = {}
  for i = 1, #self.recipe.ingredients do
    self.requests[i] = {[1] = true, [2] = false}
    --[1] = 'do I need this item'
    --[2] = 'is an inserter currently delivering this'
  end
end

function Refinery:open()
  if self.recipe then
    return {
      x = 240 - 65,
      y = 1,
      w = 63,
      h = 66,
      ent_key = self.x .. '-' .. self.y,
      close = function(self, sx, sy)
        local btn = {x = self.x + self.w - 9, y = self.y + 1, w = 5, h = 5}
        if sx >= btn.x and sy < btn.x + btn.w and sy >= btn.y and sy <= btn.y + btn.h then
          return true
        end
        return false
      end,
      draw = function(self)
        --local txt = ITEMS[ENTS[self.ent_key].id].fancy_name
        local ent = ENTS[self.ent_key]
        ui.draw_panel(self.x, self.y, self.w, self.h, UI_BG, UI_FG, 'Bio Refinery', UI_SH)
        ui.progress_bar(math.min(1.0, ent.progress/ent.recipe.crafting_time), self.x + self.w/2 - 25, self.y + 12, 50, 6, UI_BG, UI_FG, 6, 0)
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
        if ent.output.count > 0 then
          draw_item_stack(self.x + self.w/2 - 4, self.y + 28, {id = ent.output.id, count = ent.output.count})
        end
        if hovered(cursor, {x = self.x + self.w/2 - 6, y = self.y + 27, w = 10, h = 10}) then
          ui.highlight(self.x + self.w/2 - 6, self.y + 27, 8, 8, false, 3, 4)
          if key(64) then draw_recipe_widget(cursor.x + 5, cursor.y + 5, ent.output.id) end
        end
        --draw cursor item
        if self:is_hovered(cursor.x, cursor.y) and cursor.type == 'item' then
          draw_item_stack(cursor.x + 5, cursor.y + 5, {id = cursor.item_stack.id, count = cursor.item_stack.count})
        end
        --input slots hover
        for k, v in ipairs(ent.input) do
          if hovered(cursor, {x = self.x + self.w/2 - ((#ent.input*13)/2) + (k-1)*13, y = self.y + self.h - 15, w = 10, h = 10}) then
            ui.highlight(self.x + self.w/2 - ((#ent.input*13)/2) + (k-1)*13, self.y + self.h - 15, 8, 8, false, 3, 4)
            if key(64) then draw_recipe_widget(cursor.x + 5, cursor.y + 5, v.id) end
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
          if hovered(cursor, {x = self.x + self.w/2 - ((#ent.input*13)/2) + (k-1)*13, y = self.y + self.h - 15, w = 10, h = 10}) then
            -- ui.highlight(self.x + 13 + (i - 1)*13, self.y + 49, 10, 10, false, 3, 4)
            
            trace('refinery slot # ' .. k .. ' clicked')
            trace('item slot is ' .. ITEMS[v.id].fancy_name)
            trace('k = ' .. tostring(k))
            local stack_size = ITEMS[ent.output.id].recipe.ingredients[k].count * 5
            --item interaction
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
                  v.count = floor(v.count/2)
                  return true
                else
                  set_cursor_item({id = v.id, count = v.count}, false)
                  v.count = 0
                  return true
                end
              end
            elseif cursor.type == 'item' and cursor.item_stack.id == v.id then
              --try to combine stacks, leaving extra on cursor
              if key(64) then
                if v.count > 0 then
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
            
          end
        end
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
            if cursor.r and v.count > 1 then
              set_cursor_item({id = ent.output.id, count = math.ceil(ent.output.count/2)}, false)
              v.count = floor(ent.output.count/2)
              return true
            else
              set_cursor_item({id = ent.output.id, count = ent.output.count})
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
  else
    return {
      width = 80,
      height = 55,
      x = 70,
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
          --trace('selecting recipe')
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
        local x, y, w, h, bg, fg = self.x, self.y, self.width, self.height, self.bg, self.fg
        local width = print('Select a recipe', 0, -10, 0, false, 1, true)
        local c = cursor
        local btn = {x = x + w/2 - width/2 - 2, y = y + 32, w = width + 4, h = 9}
        btn.color = c.x >= btn.x and c.x < btn.x + btn.w and c.y >= btn.y and c.y < btn.y + btn.h and 9 or 8
        ui.draw_panel(x, y, w, h, bg, fg, ITEMS[ent.item_id].fancy_name)
        box(btn.x, btn.y, btn.w, btn.h, btn.color, 9)
        prints('Select a recipe', btn.x + 2, btn.y + 2, 0, 4)
        sspr(482, x + w/2 - 8, y + 14, 6, 2, 0, 0, 1, 1)
        sspr(CLOSE_ID, x + w - 7, y + 2, 15)
      end
    }
  end
end

function Refinery:update_requests()
  for i = 1, #self.requests do
    --if ingredients are low, request more items
    if self.input[i].count < self.recipe.ingredients[i].count*2 then
      self.requests[i][1] = true
    end
    --self.requests[i][2] = false 
  end
end

function Refinery:get_request()
  for i = 1, #self.requests do
    if self.requests[i][1] and not self.requests[i][2] then
      --self.requests[i][2] = true
      return self.recipe.ingredients[i].id
      --now an inserter has been dispatched to retrieve this item
    end
  end
  return false
end

function Refinery:deposit(id)
  if not self.recipe then return false end
  for k, v in ipairs(self.recipe.ingredients) do
    if id == v.id then
      self.input[k].count = self.input[k].count + 1
      self.requests[k][2] = false
      if self.input[k].count >= self.recipe.ingredients[k].count*2 then
        self.requests[k][1] = false
      end
      return true
    end
  end
  return false
end

function Refinery:request_deposit()
  if not self.recipe then return false end
  local item = self:get_request()
  return item
  -- for k, v in ipairs(self.input) do
  --   if v.count < self.recipe.ingredients[k].count then
  --     return v.id
  --   end
  -- end
  -- return false
end

function Refinery:item_request(id)
  if (self.output.id == id or id == 'any') and self.output.count > 0 then
    self.output.count = self.output.count - 1
    return self.output.id
  end
end

function Refinery:assign_delivery(id)
  for k, v in ipairs(self.recipe.ingredients) do
    if v.id == id then
      self.requests[k][2] = true
      return
    end
  end
end

function Refinery:return_all()
  if not self.recipe then return end
  for k, v in ipairs(self.input) do
    if v.count > 0 then
      local _, stack = inv:add_item({id = v.id, count = v.count})
      if stack.count ~= v.count then
        ui.new_alert(cursor.x, cursor.y, '+ ' .. v.count - stack.count .. ' ' .. ITEMS[v.id].fancy_name, 1000, 0, 6)
        v.count = stack.count
      end
    end
  end
  if self.output.count > 0 then
    local _, stack = inv:add_item({id = self.output.id, count = self.output.count})
    if stack.count ~= self.output.count then
      ui.new_alert(cursor.x, cursor.y, '+ ' .. self.output.count - stack.count .. ' ' .. ITEMS[self.output.id].fancy_name, 1000, 0, 6)
      self.output.count = stack.count
    end
  end
end

function new_refinery(x, y)
  local newRefinery = {x = x, y = y}
  newRefinery.input = {
    {id = 0, count = 0},
    {id = 0, count = 0},
    {id = 0, count = 0},
  }
  newRefinery.output = {id = 0, count = 0}
  return setmetatable(newRefinery, {__index = Refinery})
end