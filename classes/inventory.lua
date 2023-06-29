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
  hotbar_h = 12,
  hotbor_w = 4 + ((INVENTORY_SLOT_SIZE + 1) * INVENTORY_COLS),
  hotbar_y = 136 - (INVENTORY_SLOT_SIZE + 4) - 2,
  vis = false,
  hotbar_vis = true,
}

function inventory:draw()
  local x, y = mouse()
  local slot = self:get_hovered_slot(x, y)
  local rows, cols = self.rows - 1, self.cols
  local hx, hy = self.x, self.y + (INVENTORY_SLOT_SIZE * INVENTORY_ROWS) + INVENTORY_SLOT_SIZE - 1
  if self.vis then
    ui.draw_panel(self.x, self.y, self.w, self.h, self.bg, self.fg, 'Inventory', self.bg)
    ui.draw_grid(self.x + self.grid_x - 1, self.y + self.grid_y - 1, self.rows, self.cols, self.grid_bg, self.grid_fg, INVENTORY_SLOT_SIZE + 1, false)
    for i = 1, INVENTORY_ROWS do
      for j = 1, INVENTORY_COLS do
        local index = ((i-1)*INVENTORY_COLS) + j
        local x, y = self.x + self.grid_x + ((j - 1) * (INVENTORY_SLOT_SIZE + 1)), self.y + self.grid_y + ((i-1) * (INVENTORY_SLOT_SIZE + 1))
        if self.slots[index] and self.slots[index].item_id ~= 0 then
          local item = ITEMS[self.slots[index].item_id]
          sspr(item.sprite_id, x, y, item.color_key)
          --draw_item_stack(x, y, {id = self.slots[index].item_id, count = self.slots[index].count})
        end
      end
    end
    if show_count then
      for i = 1, INVENTORY_ROWS do
        for j = 1, INVENTORY_COLS do
          local index = ((i-1)*INVENTORY_COLS) + j
          local x, y = self.x + self.grid_x + ((j - 1) * (INVENTORY_SLOT_SIZE + 1)), self.y + self.grid_y + ((i-1) * (INVENTORY_SLOT_SIZE + 1))
          if self.slots[index] and self.slots[index].item_id ~= 0 then
            local item = ITEMS[self.slots[index].item_id]
            local count = self.slots[index].count < 100 and self.slots[index].count or floor(self.slots[index].count/100) .. 'H'
            prints(count, x + 2, y + 4, 0, 4, {x = 1, y = 1})
            --draw_item_stack(x, y, {id = self.slots[index].item_id, count = self.slots[index].count})
          end
        end
      end
    end
    if slot then
      ui.highlight(slot.x - 2, slot.y - 1, 8, 8, false, 3, 4)
    end
    local x, y = hx + ((self.active_slot - 1) * (INVENTORY_SLOT_SIZE+1)), hy + offset - 1
     ui.highlight(x, y, 8, 8, true, 3, 4)
     if cursor.type == 'item' and cursor.item_stack and cursor.item_stack.id ~= 0 and self:is_hovered(cursor.x, cursor.y) then
      draw_item_stack(cursor.x + 2, cursor.y + 2, cursor.item_stack)
    end
  end

  if self.hotbar_vis and not self.vis then
    ui.draw_panel(hx, hy - 1, self.w, INVENTORY_SLOT_SIZE + 4, self.bg, self.fg, false, 8)
    ui.draw_grid(hx + 1, hy, 1, INVENTORY_COLS, self.grid_bg, self.grid_fg, INVENTORY_SLOT_SIZE+1)
    for col = 1, INVENTORY_COLS do
      local x, y = hx + ((col-1) * (INVENTORY_SLOT_SIZE+1)), hy + 4
      prints(col, x + 5, y - 1, 0, 13)
      local id = self.slots[INV_HOTBAR_OFFSET + col].item_id
      if id ~= 0 then
        sspr(ITEMS[id].sprite_id, x + 2, hy + 1, ITEMS[id].color_key)
      end
      if col == self.active_slot then
        ui.highlight(x, hy, 8, 8, true, 3, 4)
      end
    end
  if show_count then
    for col = 1, INVENTORY_COLS do
      local x, y = hx + ((col-1) * (INVENTORY_SLOT_SIZE+1)), self.y + (INVENTORY_ROWS) * (INVENTORY_SLOT_SIZE + 1)
      local id = self.slots[INV_HOTBAR_OFFSET + col].item_id
      if id ~= 0 then
        prints(self.slots[INV_HOTBAR_OFFSET + col].count, x + 4, y + 4, 0, 4, {x = 1, y = 1})
      end
    end
  end
    local xx = (INVENTORY_SLOT_SIZE * INVENTORY_COLS) + INVENTORY_SLOT_SIZE - 2
    pix(self.x + self.grid_x, hy + 1, self.grid_fg)
    pix(self.x + self.grid_x, hy + 8, self.grid_fg)
    pix(self.x + self.grid_x + xx, hy + 1, self.grid_fg)
    pix(self.x + self.grid_x + xx, hy + 8, self.grid_fg)
    if cursor.type == 'item' and cursor.item_stack and cursor.item_stack.id ~= 0 and self:is_hovered(cursor.x, cursor.y) then
      draw_item_stack(cursor.x + 2, cursor.y + 2, cursor.item_stack)
    end
  end

  if slot and self.slots[slot.index].item_id ~= 0 then
    if self.vis or (self.hotbar_vis and slot.index >= 57) then
      local xoff = cursor.type == 'item' and cursor.item_stack.id ~= 0 and 12 or 5
      draw_recipe_widget(cursor.x + xoff, cursor.y + 5, self.slots[slot.index].item_id)
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
  local area = area or 3
  --1st pass, check for same-item
  --check hotbar slots first
  if area == 1 or area == 3 then
    for i = 57, #self.slots do
      local item = ITEMS[self.slots[i].item_id]
      if stack.count > 0 and self.slots[i].item_id == stack.id then
        if self.slots[i].count + stack.count <= item.stack_size then
          --deposit stack to existing stack
          self.slots[i].count = self.slots[i].count + stack.count
          return true
        elseif self.slots[i].count < item.stack_size then
          --deposit partial stack
          local diff = item.stack_size - self.slots[i].count
          local remaining_count = stack.count - diff
          self.slots[i].count =  self.slots[i].count + diff
          stack.count = remaining_count
        end
      elseif stack.count > 0 and self.slots[i].item_id == 0 then
        self.slots[i].item_id = stack.id
        self.slots[i].count = stack.count
        return true
      end
    end
    if area == 1 then
      return false, stack
    end
  end
  --continue checking inventory, excluding hotbar
  if area == 3 or area == 0 then
    for i = 1, #self.slots - INVENTORY_COLS do
      local item = ITEMS[self.slots[i].item_id]
      if stack.count > 0 and self.slots[i].item_id == stack.id then
        if self.slots[i].count + stack.count <= item.stack_size then
          --deposit stack to existing stack
          self.slots[i].count = self.slots[i].count + stack.count
          return true
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
    local item = ITEMS[v.item_id]
    if stack.count > 0 and v.item_id == 0 then
      v.item_id = stack.id
      v.count = stack.count
      return true
    end
  end
  if stack.count > 0 then
    return false, stack
  end
  return false
end

function inventory:remove_item(slot)
  local stack = {id = self.slots[slot].item_id, count = self.slots[slot].count}
  self.slots[slot].item_id = 0
  self.slots[slot].count = 0
  return stack
end

function inventory:remove_stack(stack)
  for k, v in ipairs(self.slots) do
    if v.item_id == stack.id and v.count >= stack.count then
      v.count = v.count - stack.count
      if v.count <= 0 then
        v.count = 0
        v.item_id = 0
      end
      return true
    end
  end
  return false
end

function inventory:slot_clicked(index, button)
  button = button or cursor.ll
  if cursor.type == 'item' and not button then
    if self.slots[index].item_id == 0 then
      --trace('depositing to slot: ' .. index)
      --deposit
      self.slots[index].item_id = cursor.item_stack.id
      self.slots[index].count = cursor.item_stack.count
      cursor.item_stack = {id = 0, count = 0, slot = 0}
      cursor.type = 'pointer'
    elseif self.slots[index].item_id == cursor.item_stack.id then
      local item = ITEMS[self.slots[index].item_id]
      if self.slots[index].count == item.stack_size then
        local stack = {id = self.slots[index].item_id, count = self.slots[index].count}
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
      local inv_item = {id = self.slots[index].item_id, count = self.slots[index].count}
      self.slots[index].item_id = cursor.item_stack.id
      self.slots[index].count = cursor.item_stack.count
      cursor.item_stack = {id = inv_item.id, count = inv_item.count}
      cursor.type = 'item'
      cursor.item = ITEMS[inv_item.id].name
    end
  elseif cursor.type == 'pointer' and not button then
    local id, count = self.slots[index].item_id, self.slots[index].count
    if id ~= 0 then
      --try to move to hotbar first
      if index < 57 and key(64) then
        local stack = {id = id, count = count}
        self.slots[index].item_id = 0
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
      cursor.item_stack = {id = id, count = count}
      cursor.type = 'item'
      cursor.item = ITEMS[id].name
      self.slots[index].item_id = 0
      self.slots[index].count = 0
    end
  end
end

function inventory:clicked(x, y)
  if self:is_hovered(x, y) then
    local result = self:get_hovered_slot(x, y)
    if ((cursor.l and not cursor.ll) or (cursor.r and not cursor.lr)) and result then
      --if self.slots[result.index].item_id == 0 then
      if key(64) then
        if result and self.slots[result.index].item_id ~= 0 and ui.active_window and ENTS[ui.active_window.ent_key].type == 'chest' then
          local ent = ENTS[ui.active_window.ent_key]
          local deposited, stack = ENTS[ui.active_window.ent_key]:deposit({id = self.slots[result.index].item_id, count = self.slots[result.index].count}, 0)
          --trace('deposited: ' .. tostring(deposited))
          --trace('stack: ' .. (stack and ' id: ' .. stack.id .. ' count: ' .. stack.count) or '- no remaining items')
          if deposited then
            self.slots[result.index].item_id = 0
            self.slots[result.index].count = 0
          else
            self.slots[result.index].count = stack.count
          end
          return true
        end

        if result.index >= 57 then
          trace('hotbar slot# ' .. result.index .. ' clicked')
          local stack = {id = self.slots[result.index].item_id, count = self.slots[result.index].count}
          self.slots[result.index].item_id = 0
          self.slots[result.index].count = 0
          local res, stack = self:add_item(stack, 0)
          trace('result: ' .. tostring(res) .. (stack and ' stack id: ' .. stack.id .. ' count: ' .. stack.count or 'no stack returned'))
          if stack then
            self.slots[result.index].item_id = stack.id
            self.slots[result.index].count = stack.count
          end
        end
        -- for i = 57, #self.slots do
        --   local item = ITEMS[self.slots[i].item_id]
        --   if self.slots[result.index].count > 0 and self.slots[i].item_id == self.slots[result.index].item_id then
        --     if self.slots[i].count + self.slots[result.index].count <= item.stack_size then
        --       --deposit stack to existing stack
        --       self.slots[i].count = self.slots[i].count + self.slots[result.index].count
        --       self.slots[result.index].count = 0
        --       self.slots[result.index].item_id = 0
        --       return true
        --     elseif self.slots[i].count < item.stack_size then
        --       --deposit partial stack
        --       local diff = item.stack_size - self.slots[i].count
        --       local remaining_count = self.slots[result.index].count - diff
        --       self.slots[i].count =  self.slots[i].count + diff
        --       self.slots[result.index].count = remaining_count
        --     end
        --   elseif self.slots[result.index].count > 0 and self.slots[i].item_id == 0 then
        --     self.slots[i].item_id = self.slots[result.index].item_id
        --     self.slots[i].count = self.slots[result.index].count
        --     self.slots[result.index].count = 0
        --     self.slots[result.index].item_id = 0
        --     return true
        --   end
        -- end
      end
      self.slots[result.index]:callback()
      --end
      return true
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
  
  local slot_x = math.floor(rel_x / 9)
  local slot_y = math.floor(rel_y / 9)
  
  local slot_pos_x = start_x + slot_x * 9
  local slot_pos_y = start_y + slot_y * 9
  local slot_index = slot_y * INVENTORY_ROWS + slot_x + 1
  if slot_x >= 0 and slot_x < INVENTORY_COLS and slot_y >= 0 and slot_y < INVENTORY_ROWS then
    return {x = slot_pos_x, y = slot_pos_y, index = slot_index}
  else
    return nil
  end
end

function inventory:has_stack(stack)
  for k, v in ipairs(self.slots) do
    if v.item_id == stack.id and v.count >= stack.count then
      return true
    end
  end
  return false
end

function new_slot(index)
  local slot = {
    item_id = 0,
    count = 0,
    callback = function (self)
      inv:slot_clicked(index)
      -- if self.index > INV_HOTBAR_OFFSET then
      --   set_active_slot(self.index - INV_HOTBAR_OFFSET)
      -- end
    end,
    index = index,
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