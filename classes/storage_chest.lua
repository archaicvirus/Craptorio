CHEST_ID = 464

local Chest = {
  x = 0,
  y = 0,
  slots = {},
  type = 'chest',
  rows = 2,
  cols = 8,
  is_hovered = false,
  item_id = 33,
  id = CHEST_ID,
  updated = false,
  drawn = false,
}

function Chest:draw()
  local sx, sy = world_to_screen(self.x, self.y)
  sspr(CHEST_ID, sx, sy)
end

function Chest:draw_hover_widget(x, y)
  self:draw_inventory(x or cursor.x + 5, y or cursor.y + 5)
end

function Chest:draw_inventory(x, y)
  local grid_x = 2
  local grid_y = 9
  local rows = self.rows
  local cols = self.cols
  local w = (self.cols * 9) + 4
  local h = (self.rows * 9) + 11
  local name = 'Wooden Chest'
  x = clamp(x, 1, 240 - w - 2)
  y = clamp(y, 1, 136 - h - 2)
  
  ui.draw_panel(x, y, w, h, UI_BG, UI_FG, name, UI_BG)
  ui.draw_grid(x + grid_x, y + grid_y, rows, cols, UI_BG, UI_FG, 9, true, true)
  local i = 1
  for j = 1, rows do
    for k = 1, cols do
      local item = ITEMS[self.slots[i].id]
      if item then
        local sx, sy = x + grid_x + 1 + ((k-1)*9), y + grid_y + 1 + ((j-1)*9)
        sspr(item.sprite_id, sx, sy, item.color_key)
      end
      i = i + 1
    end
  end
if show_count then
    i = 1
    for j = 1, rows do
      for k = 1, cols do
        local item = ITEMS[self.slots[i].id]
        if item then
          local sx, sy = x + grid_x + 1 + ((k-1)*9), y + grid_y + 1 + ((j-1)*9)
          local count = self.slots[i].count < 100 and self.slots[i].count or floor(self.slots[i].count/100) .. 'H'
          prints(count, sx + 2, sy + 4, 0, 4)
        end
        i = i + 1
      end
    end
  end
end

function Chest:deposit_stack(stack)
  for k, v in ipairs(self.slots) do
    local item = ITEMS[v.id]
    if item then
      if v.id == stack.id and v.count + stack.count <= item.stack_size then
        v.count = v.count + stack.count
        return true, {id = 0, count = 0}
      elseif v.id == stack.id and v.count < item.stack_size and v.count + stack.count > item.stack_size then
        local diff = item.stack_size - v.count
        v.count = item.stack_size
        stack.count = stack.count - diff
      end
    elseif v.id == 0 then
      v.count = stack.count
      v.id = stack.id
      return true, {id = 0, count = 0}
    end
  end
  return false, stack
end

function Chest:deposit(id)
  for k, v in ipairs(self.slots) do
    if v.id == 0 or (v.id == id and v.count < ITEMS[id].stack_size) then
      v.id = id
      v.count = v.count + 1
      return true
    end
  end
  return false
end

function Chest:can_deposit(stack)
  for k, v in ipairs(self.slots) do
    if (v.id == id and v.count + stack.count <= ITEMS[id].stack_size) or v.id == 0 then
      return true
    end
  end
  return false
end

function Chest:open()
  trace('opening chest')
  return {
    ent_key = self.x .. '-' .. self.y,
    x = 240/2 - (((self.cols * 9) + 4)/2),
    y = 20,
    grid_x = 2,
    grid_y = 9,
    rows = self.rows,
    cols = self.cols,
    w = (self.cols * 9) + 4,
    h = (self.rows * 9) + 11,
    name = 'Wooden Chest',
    vis = true,
    draw = function(self)
      if self.vis then
        local slot = self:get_hovered_slot(cursor.x, cursor.y)
        ENTS[self.ent_key]:draw_inventory(self.x, self.y)
        self:close(cursor.x, cursor.y)
        if self:is_hovered(cursor.x, cursor.y) then
          sspr(CURSOR_POINTER, cursor.x, cursor.y, 0)
          if cursor.item_stack.id ~= 0 then
            draw_item_stack(cursor.x + 5, cursor.y + 5, cursor.item_stack)
          end
          if slot then ui.highlight(slot.x, slot.y, 8, 8, false, 3, 4) end
          if (alt_mode and key(64)) and slot and ENTS[self.ent_key].slots[slot.index].id > 0 then
            draw_recipe_widget(cursor.x + 5, cursor.y + 5, ENTS[self.ent_key].slots[slot.index].id)
          end
        end
      end
    end,
    close = function(self)
      if ui.draw_button(self.x + self.w - 10, self.y + 2, 0, UI_CLOSE, 2, 0, 3) then
        return true
      end
      return false
    end,
    click = function(self, x, y)
      local slot = self:get_hovered_slot(x, y)
      local ent = ENTS[self.ent_key]
      if slot then
        --trace('slot# ' .. slot.index .. ' clicked')
        if key(64) then
          local result, stack = inv:add_item({id = ent.slots[slot.index].id, count = ent.slots[slot.index].count})
          if result then
            sound('deposit')
            ui.new_alert(cursor.x, cursor.y, '+' .. ent.slots[slot.index].count - stack.count .. ' ' .. ITEMS[ent.slots[slot.index].id].fancy_name, 1500, 0, 4)
            ent.slots[slot.index].id = stack.id
            ent.slots[slot.index].id = stack.count
            return true
          end
          return false
        end
        if cursor.type == 'pointer' and ent.slots[slot.index].id ~= 0 then
          if cursor.r then
            set_cursor_item({id = ent.slots[slot.index].id, count = math.ceil(ent.slots[slot.index].count/2)})
            ent.slots[slot.index].count = floor(ent.slots[slot.index].count/2)
            if ent.slots[slot.index].count < 1 then
              ent.slots[slot.index].id = 0
              ent.slots[slot.index].count = 0
              return true
            end
          else
            set_cursor_item({id = ent.slots[slot.index].id, count = ent.slots[slot.index].count})
            ent.slots[slot.index].id = 0
            ent.slots[slot.index].count = 0
            return true
          end
        elseif cursor.type == 'item' then
          if cursor.item_stack.id ~= ent.slots[slot.index].id and ent.slots[slot.index].count > 0 then
            --swap stacks
            local chest_stack = {id = ent.slots[slot.index].id, count = ent.slots[slot.index].count}
            ent.slots[slot.index].id = cursor.item_stack.id
            ent.slots[slot.index].count = cursor.item_stack.count
            set_cursor_item({id = chest_stack.id, count = chest_stack.count})
            return true
          end

          ent.slots[slot.index].id = cursor.item_stack.id

          if cursor.r then
            ent.slots[slot.index].count = ent.slots[slot.index].count + 1
            cursor.item_stack.count = cursor.item_stack.count - 1
            if cursor.item_stack.count < 1 then
              set_cursor_item()
            end
          elseif cursor.l then
            --try deposit whole stack
            trace('left-click detected on storage chest')
            local stack_size = ITEMS[ent.slots[slot.index].id].stack_size
            if ent.slots[slot.index].id == 0 then
              ents.slots[slot.index].id = cursor.item_stack.id
              ent.slots[slot.index].count = cursor.item_stack.count
              set_cursor_item()
              return true
            elseif ent.slots[slot.index].count + cursor.item_stack.count <= stack_size then
              ent.slots[slot.index].count = ent.slots[slot.index].count + cursor.item_stack.count
              set_cursor_item()
              return true
            elseif ent.slots[slot.index].count + cursor.item_stack.count > stack_size then
              local old_count = ent.slots[slot.index].count
              ent.slots[slot.index].count = stack_size
              cursor.item_stack.count = cursor.item_stack.count - (stack_size - old_count)
              return true
            end
          end
          
          return false
        end
      end
      if self:close(x, y) then
        ui.active_window = false
      end
    end,
    is_hovered = function(self, x, y)
      return x >= self.x and x <= self.x + self.w and y >= self.y and y <= self.y + self.h
    end,
    get_hovered_slot = function(self, x, y)
      return get_hovered_slot(x, y, self.x + self.grid_x, self.y + self.grid_y, 9, 2, 8)
    end,
  }
end

function Chest:request(stack, keep)
  for k, v in ipairs(self.slots) do
    if v.id == stack.id and v.count >= stack.count then
      if not keep then
        v.count = v.count - stack.count
        if v.count <= 0 then
          v.count = 0
          v.id = 0
        end
      end
      return true
    end
  end
  return false
end

function Chest:item_request(id)
  for k, v in ipairs(self.slots) do
    local item = ITEMS[v.id]
    if v.id > 0 and (v.id == id or id == 'any' or (item and id == item.type)) then
      v.count = v.count - 1
      if v.count < 1 then v.id = 0 end
      return v.id
    end
  end
  return nil
end

function Chest:request_deposit()
  return 'any'
end

function Chest:request_inserter()
  local result = false
  for k, v in ipairs(self.slots) do
    if v.id ~= 0 and v.count > 0 then
      result = v.id
      v.count = v.count - 1
      if v.count < 1 then
        v.count = 0
        v.id = 0
      end
      return result
    end
  end
  return result
end

function Chest:return_all()
  for k, v in ipairs(self.slots) do
    if ITEMS[v.id] and v.count > 0 then
      local old_stack = {id = v.id, count = v.count}
      local result, stack = inv:add_item(old_stack)
      v.id = stack.id
      v.count = stack.count
      if v.count < old_stack.count then
        ui.new_alert(cursor.x, cursor.y, '+' .. (old_stack.count - v.count) .. ' ' .. ITEMS[old_stack.id].fancy_name, 1000, 0, 4)
        sound('deposit')
      end
    end
  end
end

function new_chest(x, y, tier)
  local new_chest = {x = x, y = y, slots = {}}
  setmetatable(new_chest, {__index = Chest})
  for i = 1, Chest.rows*Chest.cols do
    new_chest.slots[i] = {id = 0, count = 0}
  end
  -- chest.slots[1] = {id = 5, count = 10}
  return new_chest
end