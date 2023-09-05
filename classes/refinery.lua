REFINERY_ID = 371

local Refinery = {
  x = 0,
  y = 0,
  recipe = false,
  input = {},
  output = {id = 0, count = 0},
  type = 'bio_refinery',
  id = 30,
  item_id = 30,
}

function Refinery:update()

end

function Refinery:draw()
  local sx, sy = world_to_screen(self.x, self.y)
  sspr(REFINERY_ID, sx, sy, ITEMS[30].color_key, 1, 0, 0, 3, 3)
end

function Refinery:draw_hover_widget()
  local w, h = 50, 50
  local x, y = clamp(cursor.x + 5, 1, 240 - w - 2), clamp(cursor.y + 5, 1, 135 - h - 1)
  ui.draw_panel(x, y, w, h, 8, 9, ITEMS[self.item_id].fancy_name, 0)
end

function Refinery:deposit_stack(stack)

end

function Refinery:set_recipe(item)
  self.recipe = item.recipe
  for i = 1, #self.recipe.ingredients do
    self.input[i].id = self.recipe.ingredients[i].id
  end
  self.output.id = self.recipe.id
  --self:set_requests()
  --trace('set recipe to: ' .. item.fancy_name)
end

function Refinery:open()
  if self.recipe then
    return {
      x = 240 - 83 - 2,
      y = 1,
      w = 83,
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
        sspr(CLOSE_ID, self.x + self.w - 9, self.y + 2, 15)
        for k, v in ipairs(ent.input) do
          box(self.x + self.w/2 - ((#ent.input*13)/2) + (k-1)*13, self.y + self.h - 21, 10, 10, 0, 9)
          if v.id ~= 0 then
            draw_item_stack(v)
          end
        end
      --draw output items
        if ent.output.count > 0 then
          draw_item_stack(self.x + self.w/2 - 4, self.y + 21, {id = ent.output.id, count = ent.output.count})
        end
        --draw cursor item
        if self:is_hovered(cursor.x, cursor.y) and cursor.type == 'item' then
          draw_item_stack(cursor.x + 5, cursor.y + 5, {id = cursor.item_stack.id, count = cursor.item_stack.count})
        end
        --input slots hover
        for k, v in ipairs(ent.input) do
          if hovered(cursor, {x = self.x + self.w/2 - ((#ent.input*13)/2) + (k-1)*13, y = self.y + self.h - 21, w = 10, h = 10}) then
            ui.highlight(self.x + self.w/2 - ((#ent.input*13)/2) + (k-1)*13, self.y + self.h - 21, 8, 8, false, 3, 4)
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
          if hovered(cursor, {x = self.x + 2 + k*13, y = self.y + 20, w = 10, h = 10}) then
              -- ui.highlight(self.x + 13 + (i - 1)*13, self.y + 49, 10, 10, false, 3, 4)
            if cursor.l and not cursor.ll then
              --item interaction
              if cursor.type == 'pointer' then
                if key(64) and ent.output.count > 0 then
                  local old_count = ent.output.count
                  local result, stack = inv:add_item({id = ent.output.id, count = ent.output.count})
                  if result then
                    ent.output.count = stack.count
                    sound('deposit')
                    ui.new_alert(cursor.x, cursor.y, '+ ' .. (stack.count == 0 and old_count or old_count - stack.count) .. ' ' .. ITEMS[ent.output.id].fancy_name, 1000, 0, 6)
                    return true
                  end
                else

                  if ent.output.count > 0 then
                    cursor.type = 'item'
                    cursor.item_stack.id = ent.output.id
                    cursor.item_stack.count = ent.output.count
                    ent.output.count = 0
                    return true
                  end
                end
              elseif cursor.type == 'item' then
                local stack_size = ITEMS[ent.output.id].stack_size
                if cursor.item_stack.id == ent.output.id or ent.output.id == 0 then
                  if ent.output.id == 0 or ent.output.count == 0 then
                    ent.output.count = ent.output.count + cursor.item_stack.count
                    cursor.type = 'pointer'
                    cursor.item_stack.id = 0
                    cursor.item_stack.count = 0
                    return true
                  end
                  if ent.output.count + cursor.item_stack.count <= stack_size then
                    ent.output.count = ent.output.count + cursor.item_stack.count
                    cursor.type = 'pointer'
                    cursor.item_stack.id = 0
                    cursor.item_stack.count = 0
                    return true
                  elseif ent.output.count + cursor.item_stack.count > stack_size then
                    local old_count = ent.output.count
                    ent.output.count = stack_size
                    cursor.item_stack.count = cursor.item_stack.count - (stack_size - old_count)
                  end
                end
              end
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
        if not self.recipe then
          local ent = ENTS[self.ent_key]
          if not ent then self = nil return end
          local input, output, fuel = ent.input_buffer, ent.output_buffer, ent.fuel_buffer
          local x, y, w, h, bg, fg = self.x, self.y, self.width, self.height, self.bg, self.fg
          local width = print('Select a recipe', 0, -10, 0, false, 1, true)
          local c = cursor
          local btn = {x = x + w/2 - width/2 - 2, y = y + 32, w = width + 4, h = 9}
          btn.color = c.x >= btn.x and c.x < btn.x + btn.w and c.y >= btn.y and c.y < btn.y + btn.h and 9 or 8
          --background window and border
          --trace('ent id: ' .. ent.id)
          ui.draw_panel(x, y, w, h, bg, fg, ITEMS[ent.item_id].fancy_name)
          --box(x, y, w, h, 8, 9)
          --rect(x + 1, y + 1, w - 2, 8, 9)
          --input input icon, and item count------------------------------------------

          --input slot
          --box(x + 3, y + 40, 10, 10, 0, 9)
          box(btn.x, btn.y, btn.w, btn.h, btn.color, 9)
          prints('Select a recipe', btn.x + 2, btn.y + 2, 0, 4)
          --assembly machine graphic-and terrain background-------------------------
          --line(x + 1, y + 35, x + w - 2, y + 35, 9)
          sspr(482, x + w/2 - 8, y + 14, 6, 2, 0, 0, 1, 1)
          sspr(CLOSE_ID, x + w - 7, y + 2, 15)
          --local width = print('Assembly Machine', 0, -10, 0, false, 1, true)
          --prints('Assembly Machine', x + w/2 - width/2 + 1, y + 2, 0, 4)
        else

        end
      end
    }
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