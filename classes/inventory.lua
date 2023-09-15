INVENTORY_SLOT_SIZE = 8
INVENTORY_BG_COL    = 8
INVENTORY_FG_COL    = 9
INVENTORY_GRID_BG   = 8
INVENTORY_GRID_FG   = 9
INVENTORY_SLOT_COL  = 0
INVENTORY_COLS      = 8
INVENTORY_ROWS      = 8
INV_SELECT_TICK     = 0
INV_SELECT_TICKRATE = 10
INV_HOTBAR_OFFSET   = INVENTORY_ROWS * INVENTORY_COLS - INVENTORY_COLS

INVENTORY_WIDTH     = 3 + ((INVENTORY_SLOT_SIZE + 1) * INVENTORY_COLS)
INVENTORY_HEIGHT    = 10 + ((INVENTORY_SLOT_SIZE + 1) * INVENTORY_ROWS)

local inventory = {
  x = (240 / 2) - (INVENTORY_WIDTH/2),
  y = 136 - INVENTORY_HEIGHT - 3,
  w = INVENTORY_WIDTH,
  h = INVENTORY_HEIGHT,
  rows = INVENTORY_ROWS,
  cols = INVENTORY_COLS,
  bg = INVENTORY_BG_COL,
  fg = INVENTORY_FG_COL,
  grid_x = 2,
  grid_y = 9,
  grid_bg = INVENTORY_GRID_BG,
  grid_fg = INVENTORY_GRID_FG,
  slots = {},
  hotbar = {},
  hovered_slot = 0,
  active_slot = 1,
  hotbar_h = INVENTORY_SLOT_SIZE + 4,
  hotbor_w = 4 + ((INVENTORY_SLOT_SIZE + 1) * INVENTORY_COLS),
  hotbar_y = 135 - (INVENTORY_SLOT_SIZE + (INVENTORY_SLOT_SIZE/2)) - 2,
  vis = false,
  hotbar_vis = true,
}

function inventory:draw()
  local x, y = mouse()
  local slot = self:get_hovered_slot(x, y)
  local rows, cols = self.rows - 1, self.cols
  local hx, hy = self.x, self.hotbar_y
  if self.vis and not show_mini_map then
    ui.draw_panel(self.x, self.y, self.w, self.h, self.bg, self.fg, 'Inventory', self.bg)
    ui.draw_grid(self.x + self.grid_x - 1, self.y + self.grid_y - 1, self.rows, self.cols, self.grid_bg, self.grid_fg, INVENTORY_SLOT_SIZE + 1, false)
    for i = 1, INVENTORY_ROWS do
      for j = 1, INVENTORY_COLS do
        local index = ((i-1)*INVENTORY_COLS) + j
        local x, y = self.x + self.grid_x + ((j - 1) * (INVENTORY_SLOT_SIZE + 1)), self.y + self.grid_y + ((i-1) * (INVENTORY_SLOT_SIZE + 1))
        if self.slots[index] and self.slots[index].id ~= 0 then
          local item = ITEMS[self.slots[index].id]
          draw_item_stack(x, y, {id = self.slots[index].id, count = self.slots[index].count})
        end
        if index-56 == self.active_slot then
          ui.highlight(x-1, y-1, INVENTORY_SLOT_SIZE, INVENTORY_SLOT_SIZE, true, 3, 4)
        end
      end
    end
    if slot then
      ui.highlight(slot.x - 1, slot.y - 1, INVENTORY_SLOT_SIZE, INVENTORY_SLOT_SIZE, false, 3, 4)
    end
    local x, y = hx + ((self.active_slot - 1) * (INVENTORY_SLOT_SIZE+1)), hy + offset - 1
     ui.highlight(x, y, INVENTORY_SLOT_SIZE, INVENTORY_SLOT_SIZE, true, 3, 4)
     if cursor.type == 'item' and cursor.item_stack and cursor.item_stack.id ~= 0 and self:is_hovered(cursor.x, cursor.y) then
      draw_item_stack(cursor.x + 5, cursor.y + 5, cursor.item_stack)
    end
  end

  if self.hotbar_vis and not self.vis then
    ui.draw_panel(hx, hy, self.w, INVENTORY_SLOT_SIZE + 4, self.bg, self.fg, false, 8)
    ui.draw_grid(hx + 1, hy + 1, 1, INVENTORY_COLS, self.grid_bg, self.grid_fg, INVENTORY_SLOT_SIZE+1)
    for col = 1, INVENTORY_COLS do
      local x, y = hx + ((col-1) * (INVENTORY_SLOT_SIZE+1)), hy + 4
      if alt_mode then prints(col, x + 5, y - 1, 0, 13) end
      local id, count = self.slots[INV_HOTBAR_OFFSET + col].id, self.slots[INV_HOTBAR_OFFSET + col].count
      if id ~= 0 then
        draw_item_stack(x + 2, hy + 2, {id = id, count = count})
      end
      if col == self.active_slot then
        ui.highlight(x+1, hy+1, INVENTORY_SLOT_SIZE, INVENTORY_SLOT_SIZE, true, 3, 4)
      end
    end
    local xx = (INVENTORY_SLOT_SIZE * INVENTORY_COLS) + INVENTORY_SLOT_SIZE - 2
    pix(self.x + self.grid_x, hy + 1, self.grid_fg)
    pix(self.x + self.grid_x, hy + INVENTORY_SLOT_SIZE, self.grid_fg)
    pix(self.x + self.grid_x + xx, hy + 1, self.grid_fg)
    pix(self.x + self.grid_x + xx, hy + INVENTORY_SLOT_SIZE, self.grid_fg)
    if cursor.type == 'item' and cursor.item_stack and cursor.item_stack.id ~= 0 and self:is_hovered(cursor.x, cursor.y) then
      draw_item_stack(cursor.x + 5, cursor.y + 5, cursor.item_stack)
    end
  end

  if slot and self.slots[slot.index].id ~= 0 then
    if self.vis or (self.hotbar_vis and slot.index >= 57) then
      --local xoff = cursor.type == 'item' and cursor.item_stack.id ~= 0 and 12 or 5
      if key(64) then draw_recipe_widget(cursor.x + 5, cursor.y + 5, self.slots[slot.index].id) end
    end
  end
end

function inventory:draw_hotbar()
  if self.hotbar_vis and not self.vis then
    rectb(self.x, 136 - 2 - (INVENTORY_SLOT_SIZE + 4), self.w, INVENTORY_SLOT_SIZE + 4, INVENTORY_FG_COL)
    rect(self.x + 1, 136 - 2 - (INVENTORY_SLOT_SIZE + 3), self.w - 2, INVENTORY_SLOT_SIZE + 2, INVENTORY_BG_COL)
    for col = 1, INVENTORY_COLS do
      local x, y = (self.x + 2) + ((col - 1) * (INVENTORY_SLOT_SIZE + 1)), 136 - 2 - (INVENTORY_SLOT_SIZE + 2)
      rect(x, y, INVENTORY_SLOT_SIZE, INVENTORY_SLOT_SIZE, INVENTORY_SLOT_COL)
      if col == self.active_slot then
        spr(CURSOR_HIGHLIGHT, x, y, 0)
      end
      if col == 10 then col = 0 end
      print(col, x + 2, y + 1, 0, true, 1, true)
    end
  end
end

function inventory:update()

end

function inventory:add_item(stack, area)
  --trace('adding item - stack: id = ' .. stack.id .. ', count = ' .. stack.count)
  local area = area or 3
  --1st pass, check for same-item
  --check hotbar slots first
  if area == 1 or area == 3 then
    for i = 57, #self.slots do
      local item = ITEMS[self.slots[i].id]
      if stack.count > 0 and self.slots[i].id == stack.id then
        if self.slots[i].count + stack.count <= item.stack_size then
          --deposit stack to existing stack
          self.slots[i].count = self.slots[i].count + stack.count
          return true, {id = 0, count = 0}
        elseif self.slots[i].count < item.stack_size then
          --deposit partial stack
          local diff = item.stack_size - self.slots[i].count
          local remaining_count = stack.count - diff
          self.slots[i].count =  self.slots[i].count + diff
          stack.count = remaining_count
        end
      elseif stack.count > 0 and self.slots[i].id == 0 then
        self.slots[i].id = stack.id
        self.slots[i].count = stack.count
        return true, {id = 0, count = 0}
      end
    end
    if area == 1 then
      return false, stack
    end
  end
  --continue checking inventory, excluding hotbar
  if area == 3 or area == 0 then
    for i = 1, #self.slots - INVENTORY_COLS do
      local item = ITEMS[self.slots[i].id]
      if stack.count > 0 and self.slots[i].id == stack.id then
        if self.slots[i].count + stack.count <= item.stack_size then
          --deposit stack to existing stack
          self.slots[i].count = self.slots[i].count + stack.count
          return true, {id = 0, count = 0}
        elseif self.slots[i].count < item.stack_size then
          --deposit partial stack
          local diff = item.stack_size - self.slots[i].count
          local remaining_count = stack.count - diff
          self.slots[i].count =  self.slots[i].count + diff
          stack.count = remaining_count
        end
      end
    end
    -- if area == 0 then
    --   return false, stack
    -- end
  end
  --2nd pass, look for empty slot to deposit remaining (or possibly full) stack
  for k, v in ipairs(self.slots) do
    local item = ITEMS[v.id]
    if stack.count > 0 and v.id == 0 then
      v.id = stack.id
      v.count = stack.count
      return true, {id = 0, count = 0}
    end
  end
  if stack.count > 0 then
    return false, stack
  end
  return false, stack
end

function inventory:remove_item(slot)
  local stack = {id = self.slots[slot].id, count = self.slots[slot].count}
  self.slots[slot].id = 0
  self.slots[slot].count = 0
  return stack
end

function inventory:remove_stack(stack)
  for k, v in ipairs(self.slots) do
    if v.id == stack.id and v.count >= stack.count then
      v.count = v.count - stack.count
      if v.count <= 0 then
        v.count = 0
        v.id = 0
      end
      return true
    end
  end
  return false
end

function inventory:slot_clicked(index, button)
  --trace('clicked slot: ' .. index)
  --trace('cursor.item_stack.slot = ' .. tostring(cursor.item_stack.slot))
  --trace('inv.active_slot = ' .. inv.active_slot)
  if index == cursor.item_stack.slot then return end
  if cursor.type == 'item' and cursor.item_stack.slot and index ~= cursor.item_stack.slot then
    --trace('swapping active slot for CLICKED slot')
    local old_item = self.slots[index]
    self.slots[cursor.item_stack.slot].id = self.slots[index].id
    self.slots[cursor.item_stack.slot].count = self.slots[index].count
    self.slots[index].id = cursor.item_stack.id
    self.slots[index].count = cursor.item_stack.count
    set_cursor_item()
    return
  end
  if cursor.type == 'item' then
    if self.slots[index].id == 0 then
      --trace('depositing to slot: ' .. index)
      --deposit
      self.slots[index].id = cursor.item_stack.id

      if cursor.r then
        self.slots[index].count = 1
        cursor.item_stack.count = cursor.item_stack.count - 1
        if cursor.item_stack.count < 1 then
          set_cursor_item()
        end
      else
        self.slots[index].count = cursor.item_stack.count
        if cursor.item_stack.slot and cursor.item_stack.slot ~= index then
          self.slots[cursor.item_stack.slot].id = 0
          self.slots[cursor.item_stack.slot].count = 0
        end
        set_cursor_item()
      end


    elseif self.slots[index].id == cursor.item_stack.id then
      if cursor.r then
        if self.slots[index].count < ITEMS[self.slots[index].id].stack_size then
          self.slots[index].count = self.slots[index].count + 1
          cursor.item_stack.count = cursor.item_stack.count - 1
          if cursor.item_stack.count < 1 then
            set_cursor_item()
          end
          return true
        end
      end

      local item = ITEMS[self.slots[index].id]
      --swap held partial stack with full stack
      if self.slots[index].count == item.stack_size then
        local stack = {id = self.slots[index].id, count = self.slots[index].count}
        self.slots[index].count = cursor.item_stack.count
        cursor.item_stack = stack
      elseif self.slots[index].count + cursor.item_stack.count <= item.stack_size then
        self.slots[index].count = self.slots[index].count + cursor.item_stack.count
        cursor.item_stack.count = 0
      elseif self.slots[index].count < item.stack_size then
        local diff = item.stack_size - self.slots[index].count
        cursor.item_stack.count = cursor.item_stack.count - diff
        self.slots[index].count = item.stack_size
      end

      if cursor.item_stack.count <= 0 then
        cursor.item_stack = {id = 0, count = 0}
        cursor.type = 'pointer'
      end
    else
      --swap stacks
      local inv_item = {id = self.slots[index].id, count = self.slots[index].count}
      self.slots[index].id = cursor.item_stack.id
      self.slots[index].count = cursor.item_stack.count
      cursor.item_stack = {id = inv_item.id, count = inv_item.count, slot = false}
      cursor.type = 'item'
      cursor.item = ITEMS[inv_item.id].name
    end
  elseif cursor.type == 'pointer' then
    local id, count = self.slots[index].id, self.slots[index].count
    if id ~= 0 then
      if cursor.r and not cursor.lr then
        set_cursor_item({id = id, count = math.ceil(count/2)}, false)
        self.slots[index].count = math.floor(count/2)
        return true
      end
      --try to move to hotbar first
      if index < 57 and key(64) then
        local stack = {id = id, count = count}
        self.slots[index].id = 0
        self.slots[index].count = 0
        local res, stk = self:add_item(stack)
        if res then
          return true
        else
          self.slots[index].id = stk.id
          self.slots[index].count = stk.count
        end
        return true
      end
      --trace('setting item stack from inv')
      cursor.item_stack.id = id
      cursor.item_stack.count = count
      cursor.item_stack.slot = false
      cursor.type = 'item'
      cursor.item = ITEMS[id].name
      self.slots[index].id = 0
      self.slots[index].count = 0
    end
  end
end

function inventory:clicked(x, y)
  if self:is_hovered(x, y) then
    local result = self:get_hovered_slot(x, y)
    if result then
      --if self.slots[result.index].id == 0 then
      if key(64) then
        local ent = ui.active_window and ENTS[ui.active_window.ent_key] or false
        if result and ent and self.slots[result.index].id ~= 0 and ui.active_window and ent.deposit_stack then
          local old_stack = {id = self.slots[result.index].id, count = self.slots[result.index].count}
          local deposited, stack = ent:deposit_stack(old_stack, false)
          --trace('deposited: ' .. tostring(deposited))
          --trace('stack: ' .. (stack and ' id: ' .. stack.id .. ' count: ' .. stack.count) or '- no remaining items')
          -- if stack then
          --   self.slots[result.index].id = stack.id
          --   self.slots[result.index].count = stack.count
          -- end
          if deposited then
            ui.new_alert(cursor.x, cursor.y, '-' .. self.slots[result.index].count - stack.count .. ' ' .. ITEMS[old_stack.id].fancy_name, 1000, 0, 2)
            self.slots[result.index].id = stack.id
            self.slots[result.index].count = stack.count
            sound('deposit')
            return true
          end
        end

        if result.index >= 57 then
          --trace('hotbar slot# ' .. result.index .. ' clicked')
          local stack = {id = self.slots[result.index].id, count = self.slots[result.index].count}
          self.slots[result.index].id = 0
          self.slots[result.index].count = 0
          local res, stack = self:add_item(stack, 0)
          --trace('result: ' .. tostring(res) .. (stack and ' stack id: ' .. stack.id .. ' count: ' .. stack.count or 'no stack returned'))
          if stack then
            self.slots[result.index].id = stack.id
            self.slots[result.index].count = stack.count
          end
        end

      end
      self.slots[result.index]:callback()
      
      return true
    --elseif cursor.r and not cursor.lr and result then
      -- if self.slots[result.index].id ~= 0 then
      --   set_cursor_item({id = self.slots[result.index].id, count = math.ceil(self.slots[result.index].count/2)}, false)
      --   self.slots[result.index].count = math.floor(self.slots[result.index].count/2)
      -- end
      --try to take half stack
    end
  end
  return false
end

function inventory:is_hovered(x, y)
  if self.vis then
    return x >= self.x and x < self.x + self.w and y >= self.y and y < self.y + self.h
  elseif self.hotbar_vis and not self.vis then
    return x >= self.x and x < self.x + self.w and y >= self.hotbar_y and y < self.hotbar_y + self.hotbar_h
  end
  return false
end

function inventory:get_hovered_slot(x, y)
  local start_x = self.x + self.grid_x
  local start_y = self.y + self.grid_y
  
  local rel_x = x - start_x
  local rel_y = y - start_y
  
  local slot_x = math.floor(rel_x / (INVENTORY_SLOT_SIZE + 1))
  local slot_y = math.floor(rel_y / (INVENTORY_SLOT_SIZE + 1))
  
  local slot_pos_x = start_x + slot_x * (INVENTORY_SLOT_SIZE + 1)
  local slot_pos_y = start_y + slot_y * (INVENTORY_SLOT_SIZE + 1)
  local slot_index = slot_y * INVENTORY_ROWS + slot_x + 1
  if slot_x >= 0 and slot_x < INVENTORY_COLS and slot_y >= 0 and slot_y < INVENTORY_ROWS then
    return {x = slot_pos_x, y = slot_pos_y, index = slot_index}
  else
    return nil
  end
end

function inventory:has_stack(stack)
  for k, v in ipairs(self.slots) do
    if v.id == stack.id and v.count >= stack.count then
      return true
    end
  end
  return false
end

function new_slot(index)
  local slot = {
    id = 0,
    count = 0,
    index = index,
    callback = function (self)
      inv:slot_clicked(self.index)
      -- if self.index > INV_HOTBAR_OFFSET then
      --   set_active_slot(self.index - INV_HOTBAR_OFFSET)
      -- end
    end,
  }
  return slot
end

function make_inventory()
  local inv = {}
  setmetatable(inv, {__index = inventory})
  local i = 1
  for row = 1, INVENTORY_ROWS do
    for col = 1, INVENTORY_COLS do
      inv.slots[i] = new_slot(i)
      i = i + 1
    end
  end
  return inv
end

function add_stack(from, to)
  if to.count == 0 then
    
  elseif to.id == from.id then

  end


  return from, to
end