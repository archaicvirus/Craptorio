CRAFTER_ID = 312
CRAFTER_TICKRATE = 5
CRAFTER_TIME_ID = 337

local Crafter = {
  x = 0,
  y = 0,
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
}

function Crafter:draw_hover_widget(sx, sy)
  local sx, sy = sx or cursor.x + 3, sy or cursor.y + 3
  local x, y, w, h = sx, sy, 69, 50
  box(sx, sy, w, h, 8, 9)
  local width = print('Assembly Machine', 0, -10, 0, false, 1, true)
  rect(sx + 1, sy + 1, w - 2, 8, 9)
  prints('Assembly Machine', sx + w/2 - width/2, sy + 2, 0, 4)
end

function Crafter:draw()
  local sx, sy = world_to_screen(self.x, self.y)
  local blink = TICK % 60 < 30
  sspr(CRAFTER_ID, sx, sy, 0, 1, 0, 0, 3, 3)
  if self.recipe then
    sspr(ITEMS[self.recipe.id].sprite_id, sx + 8, sy + 12, 0)
  end
  if self.state == 'crafting' then
    pix(sx + 6, sy + 5, blink and 5 or 7)
    line(sx + 6, sy + 9, sx + 6 + remap(self.progress, 0, self.recipe.crafting_time, 0, 12), sy + 9, 5)
  end
  if self.state == 'idle' then
    pix(sx + 11, sy + 5, blink and 0 or 3)
  end
  if self.state == 'ready' then
    pix(sx + 16, sy + 5, blink and 0 or 2)
  end
end

function Crafter:update()
  --trace('crafter state: ' .. tostring(self.state))
  if self.recipe then
    self:update_requests()
    if self.state ~= 'crafting' and self.state ~= 'idle' then
      local has_enough = true
      for i = 1, #self.recipe.ingredients do
        if self.input[i].count < self.recipe.ingredients[i].count then
          has_enough = false
        end
      end

      if has_enough and self.output.count < 5 then
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

        if has_enough and self.output.count < 5 then
          for i = 1, #self.recipe.ingredients do
            self.input[i].count = self.input[i].count - self.recipe.ingredients[i].count
          end
          self.output.count = self.output.count + self.recipe.count
        end

        if self.output.count >= self.recipe.count * 5 then
          self.state = 'idle'
        end
      end


    end
  end
end

function Crafter:open()
  if not self.recipe then
    -------------NO recipe--------------------
    return {
      width = 80,
      height = 55,
      x = 70,
      y = 18,
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
            window = nil
            craft_menu.current_output = 'player'
            return true
        end
        --if no recipe, check the 'set-recipe' button
        local width = print('Select a recipe', 0, -10, 0, false, 1, true) + 4
        local x, y, w, h = (self.x + self.width/2) - (width/2), self.y + 40, width + 4, 10
        if sx >= x and sx < x + w and sy >= y and sy < sy + h then
          --open recipe selection widget
          window = nil
          --ui.assembly_recipe_widget(self)
          craft_menu.current_output = self.ent_key
          toggle_crafting(true)
          trace('selecting recipe')
          return true
        end
        return false
      end,

      is_hovered = function(self, x, y)
        return x >= self.x and x < self.x + self.width and y >= self.y and y < self.y + self.height and true or false
      end,
      draw = function(self)
        if not self.recipe then
          local ent = ENTS[self.ent_key]
          if not ent then self = nil return end
          local input, output, fuel = ent.input_buffer, ent.output_buffer, ent.fuel_buffer
          local x, y, w, h = self.x, self.y, self.width, self.height
          local width = print('Select a recipe', 0, -10, 0, false, 1, true)
          local c = cursor          
          local btn = {x = x + w/2 - width/2 - 2, y = y + 40, w = width + 4, h = 9}
          btn.color = c.x >= btn.x and c.x < btn.x + btn.w and c.y >= btn.y and c.y < btn.y + btn.h and 9 or 8
          --background window and border
          box(x, y, w, h, 8, 9)
          rect(x + 1, y + 1, w - 2, 8, 9)
          --input input icon, and item count------------------------------------------

          --input slot
          --box(x + 3, y + 40, 10, 10, 0, 9)
          box(btn.x, btn.y, btn.w, btn.h, btn.color, 9)
          prints('Select a recipe', x + w/2 - width/2 + 1, y + 42, 0, 4)
          --assembly machine graphic-and terrain background-------------------------
          line(x + 1, y + 35, x + w - 2, y + 35, 9)
          sspr(CRAFTER_ID, x + w/2 - 12, y + 10, 0, 1, 0, 0, 3, 3)
          sspr(CLOSE_ID, x + w - 7, y + 2, 0)
          local width = print('Assembly Machine', 0, -10, 0, false, 1, true)
          prints('Assembly Machine', x + w/2 - width/2 + 1, y + 2, 0, 4)
        else

        end
      end
    }
  else
    ------------HAS recipe--------------------
    return {
      width = 100,
      height = 75,
      x = 139,
      y = 1,
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
          window = nil
          return true
        end
          --check for other clicked input
        return false
      end,

      is_hovered = function(self, x, y)
        return x >= self.x and x < self.x + self.width and y >= self.y and y < self.y + self.height
      end,
      draw = function(self)
        local ent = ENTS[self.ent_key]
        if not ent then self = nil return end
        local x, y, w, h = self.x, self.y, self.width, self.height
        --background window and border
        box(x, y, w, h, 8, 9)
        rect(x + 1, y + 1, w - 2, 9, 9)
        --recipe info and icon
        prints(ITEMS[ent.recipe.id].fancy_name, x + 3, y + 14, 0, 4)
        for k, v in ipairs(ent.recipe.ingredients) do
          draw_item_stack(x + 3 + (k-1)*14, y + 24, {id = v.id, count = v.count})
          if k < #ent.recipe.ingredients then prints('+', x + 3 + (k-1)*14 + 10, y + 25, 0, 11) end
          -- sspr(ITEMS[v.id].sprite_id, x + 30 + (k-1)*15, y + 24, 0)
          -- print(v.count, x + 38 + ((k-1)*15) - 3, y + 28, 0, true, 1, true)
          -- print(v.count, x + 39 + ((k-1)*15) - 3, y + 29, 4, true, 1, true)
        end
        local xx = x + 3 + (#ent.recipe.ingredients * 14) + 2
        prints('= ', xx - 5, y + 25, 0, 11)
        draw_item_stack(xx, y + 24, {id = ent.recipe.id, count = ent.recipe.count})
        --crafting progress bar
        box(x + 3, y + 38, 69, 6, 0, 9)
        if ent.state == 'crafting' then
          rect(x + 29, y + 39, remap(ent.progress, 0, ent.recipe.crafting_time, 0, 67), 4, 5)
        end
        --input slots and items
        prints('Input', x + 16, y + 50, 0, 4)
        for i = 1, 4 do
          box(x + 3 + (i - 1)*15, y + 58, 10, 10, 0, 9)
        end
        for i = 1, 4 do
          if ent.input[i].count > 0 and ent.input[i].id ~= 0 then
            draw_item_stack(x + 4 + (i - 1)*15, y + 59, ent.input[i])
          end
        end
        --output slot/items
        prints('Output', x + 66 + 4, y + 50, 0, 4)
        box(x + w - 28 + 4, y + 58, 10, 10, 0, 9)
        if ent.output.count > 0 then
          draw_item_stack(x + w - 28 + 5, y + 59, {id = ent.output.id, count = ent.output.count})
        end
        --assembly machine graphic-and terrain background-------------------------
        local sprite_id = CRAFTER_ID
        local fx, fy = x + w - 26, y + 12 --crafter icon screen pos
        --rectb(fx - 33, fy - 17, w - 18, 50, 14)
        line(x + 1, y + 10, x + w - 2, y + 10, 9)
        line(x + 1, y + 47, x + w - 2, y + 47, 9)
        sspr(sprite_id, fx, fy, 0, 1, 0, 0, 3, 3)
        sspr(CLOSE_ID, x + w - 7, y + 2, 0)
        local width = print('Assembly Machine', 0, -10, 0, true, 1, true)
        prints('Assembly Machine', x + w/2 - width/2 + 1, y + 3, 0, 4)
        -- print('Assembly Machine', x + w/2 - width/2 + 1, y + 3, 0, true, 1, true)
        -- print('Assembly Machine', x + w/2 - width/2 + 0, y + 3, 4, true, 1, true)
        --Input ingredient icons and count
        for k, v in ipairs(ent.input) do
          
        end
      end
    }
  end
end

function Crafter:set_recipe(item)
  self.recipe = item.recipe
  for i = 1, #self.recipe.ingredients do
    self.input[i].id = self.recipe.ingredients[i].id
  end
  self.output.id = self.recipe.id
  self:set_requests()
  trace('set recipe to: ' .. item.fancy_name)
end

function Crafter:set_requests()
  self.requests = {}
  for i = 1, #self.recipe.ingredients do
    self.requests[i] = {true, false}
    --[1] = 'do I need this item'
    --[2] = 'is an inserter currently delivering this'
  end
end

function Crafter:update_requests()
  for i = 1, #self.requests do
    --if ingredients are low, request more items
    if self.requests[i][1] and not self.requests[i][2] then
      self.requests[i][1] = self.input[i].count < self.recipe.ingredients[i].count
    end
  end
end

function Crafter:get_request()
  for i = 1, #self.recipe.ingredients do
    if self.requests[i][1] and not self.requests[i][2] and #self.output < 5 then
      self.requests[i][2] = true
      return self.recipe.ingredients[i].id
      --now an inserter has been dispatched to retrieve this item
    end
  end
  return false
end

function Crafter:deposit(id)
  if self.state ~= 'idle' and self.recipe then
    for i = 1, #self.recipe.ingredients do
      if self.input[i].count < self.recipe.ingredients[i].count*5 and self.recipe.ingredients[i].id == id then
        self.input[i].count = self.input[i].count + 1
        self.input[i].id = id
        return true
      end
    end
  end
  return false
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