CRAFTER_ID = 312
CRAFTER_TICKRATE = 5

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

function Crafter:draw()
  local sx, sy = world_to_screen(self.x, self.y)
  local blink = TICK % 60 < 30
  sspr(CRAFTER_ID, sx, sy, 0, 1, 0, 0, 3, 3)
  if self.recipe then
    sspr(ITEMS[self.recipe.id].sprite_id, sx + 8, sy + 12, 0)
  end
  if self.state == 'crafting' then
    pix(sx + 7, sy + 5, blink and 5 or 7)
    line(sx + 6, sy + 9, sx + 6 + remap(self.progress, 0, self.recipe.crafting_time, 0, 12), sy + 9, 5)
  end
  if self.state == 'idle' then
    pix(sx + 11, sy + 5, blink and 0 or 3)
  end
  if self.state == 'ready' then
    pix(sx + 15, sy + 5, blink and 0 or 2)
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
      width = 100,
      height = 75,
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
        if sx >= self.x and sx < self.x + self.width and sy >= self.y and sy < self.y + self.height then
          if self:close(sx, sy) then
            window = nil
            craft_menu.current_output = 'player'
            return true
          end
          --check for other clicked input
        end

        --if no recipe, check the 'set-recipe' button
        if not self.recipe then
          local width = print('Select a recipe', 0, -10, 0, true, 1, true) + 4
          local x, y, w, h = (self.x + self.width/2) - (width/2), self.y + 50, width + 4, 10
          if sx >= x and sx < x + w and sy >= y and sy < sy + h then
            --open recipe selection widget
            window = nil
            --ui.assembly_recipe_widget(self)
            craft_menu.current_output = self.ent_key
            toggle_crafting(true)
            trace('selecting recipe')
            return true
          end
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
          --background window and border
          box(x, y, w, h, 8, 9)
          --input input icon, and item count------------------------------------------

          --input slot
          --box(x + 3, y + 40, 10, 10, 0, 9)
          local width = print('Select a recipe', 0, -10, 0, true, 1, true)
          box(x + w/2 - width/2 - 2, y + 50, width + 4, 10, 15, 9)
          print('Select a recipe', x + w/2 - width/2 + 1, y + 52, 0, true, 1, true)
          print('Select a recipe', x + w/2 - width/2, y + 52, 4, true, 1, true)
          --assembly machine graphic-and terrain background-------------------------
          local sprite_id = CRAFTER_ID
          local fx, fy = x + w/2 - 12, y + 12 --crafter icon screen pos
          --rectb(fx - 33, fy - 17, w - 18, 50, 14)
          line(x + 1, y + 10, x + w - 2, y + 10, 9)
          line(x + 1, y + 37, x + w - 2, y + 37, 9)
          sspr(sprite_id, fx, fy, 0, 1, 0, 0, 3, 3)
          sspr(437, x + w - 7, y + 2, 0)
          local width = print('Assembly Machine', 0, -10, 0, true, 1, true)
          print('Assembly Machine', x + w/2 - width/2 + 1, y + 3, 0, true, 1, true)
          print('Assembly Machine', x + w/2 - width/2 + 0, y + 3, 4, true, 1, true)
        else

        end
      end
    }
  else
    ------------HAS recipe--------------------
    return {
      width = 100,
      height = 75,
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
        if sx >= self.x and sx < self.x + self.width and sy >= self.y and sy < self.y + self.height then
          if self:close(sx, sy) then
            window = nil
            return true
          end
          --check for other clicked input

        end

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
        --recipe info and icon
        print(ITEMS[ent.recipe.id].fancy_name, x + 31, y + 14, 0, true, 1, true)
        print(ITEMS[ent.recipe.id].fancy_name, x + 30, y + 14, 4, true, 1, true)
        for k, v in ipairs(ent.recipe.ingredients) do
          sspr(ITEMS[v.id].sprite_id, x + 30 + (k-1)*15, y + 24, 0)
          print(v.count, x + 38 + ((k-1)*15) - 3, y + 28, 0, true, 1, true)
          print(v.count, x + 39 + ((k-1)*15) - 3, y + 29, 4, true, 1, true)
        end
        local xx = x + 33 + (#ent.recipe.ingredients * 15) + 1
        print('= ', xx - 7, y + 26, 0)
        print('= ', xx - 6, y + 26, 4)
        sspr(ITEMS[ent.recipe.id].sprite_id, xx, y + 24, 0)
        print(ent.recipe.count, xx + 4, y + 27, 0, true, 1, true)
        print(ent.recipe.count, xx + 4, y + 28, 4, true, 1, true)
        --crafting progress bar
        box(x + 28, y + 38, 69, 6, 0, 9)
        if ent.state == 'crafting' then
          rect(x + 29, y + 39, remap(ent.progress, 0, ent.recipe.crafting_time, 0, 67), 4, 5)
        end
        --input slots and items
        print('Input', x + 16, y + 50, 0, true, 1, true)
        print('Input', x + 15, y + 50, 4, true, 1, true)
        for i = 1, 4 do
          box(x + 3 + (i - 1)*11, y + 58, 10, 10, 0, 9)
        end
        for i = 1, 4 do
          if ent.input[i].count > 0 and ent.input[i].id ~= 0 then
            local id = ent.input[i].id
            sspr(ITEMS[id].sprite_id, x + 4 + (i - 1)*11, y + 59, 0)
            print(ent.input[i].count, x + 3 + (i - 1)*11 + 6, y + 63, 0, true, 1, true)
            print(ent.input[i].count, x + 3 + (i - 1)*11 + 7, y + 63, 4, true, 1, true)
          end
        end
        --output slot/items
        print('Output', x + 66 + 4, y + 50, 0, true, 1, true)
        print('Output', x + 65 + 4, y + 50, 4, true, 1, true)
        box(x + w - 28 + 4, y + 58, 10, 10, 0, 9)
        if ent.output.count > 0 then
          sspr(ITEMS[ent.output.id].sprite_id, x + w - 28 + 5, y + 59, 0)
          print(ent.output.count, x + w - 28 + 10, y + 63, 0, true, 1, true)
          print(ent.output.count, x + w - 28 + 11, y + 63, 4, true, 1, true)
        end
        --assembly machine graphic-and terrain background-------------------------
        local sprite_id = CRAFTER_ID
        local fx, fy = x + 3, y + 12 --crafter icon screen pos
        --rectb(fx - 33, fy - 17, w - 18, 50, 14)
        line(x + 1, y + 10, x + w - 2, y + 10, 9)
        line(x + 1, y + 47, x + w - 2, y + 47, 9)
        sspr(sprite_id, fx, fy, 0, 1, 0, 0, 3, 3)
        sspr(437, x + w - 7, y + 2, 0)
        local width = print('Assembly Machine', 0, -10, 0, true, 1, true)
        print('Assembly Machine', x + w/2 - width/2 + 1, y + 3, 0, true, 1, true)
        print('Assembly Machine', x + w/2 - width/2 + 0, y + 3, 4, true, 1, true)
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

return function(wx, wy)
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