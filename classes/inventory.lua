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
        --pix(x,y,2)
        if self.slots[index] and self.slots[index].item_id ~= 0 then
          --trace('drawing item ')
          draw_item_stack(x, y, {id = self.slots[index].item_id, count = self.slots[index].count})
        end
          -- local x, y = (self.x + 2) + ((i - 1) * (INVENTORY_SLOT_SIZE + 1)), 136 - 2 - (INVENTORY_SLOT_SIZE + 6)
        -- if self.slots[i + INV_HOTBAR_OFFSET].item_id ~= 0 then
        --   sspr(ITEMS[self.slots[i + INV_HOTBAR_OFFSET].item_id].sprite_id, x, y + 2, ITEMS[self.slots[i + INV_HOTBAR_OFFSET].item_id].color_key)
        --   --draw_item_stack(x, y, {id = self.slots[i + INV_HOTBAR_OFFSET].item_id, count = self.slots[i + INV_HOTBAR_OFFSET].count})
        -- end
      end
    end
    if slot then
      sspr(CURSOR_HIGHLIGHT, slot.x - 1, slot.y - 1, 0, 1, 0, 0, 2, 2)
    end
    pal({5,4,6,3})
    local offset = floor(player.anim_frame/4)
    local x, y = hx + ((self.active_slot - 1) * (INVENTORY_SLOT_SIZE+1)), hy + offset - 1
    sspr(CURSOR_HIGHLIGHT_CORNER_S, x + 0 + offset, y, {0,1,2})
    sspr(CURSOR_HIGHLIGHT_CORNER_S, x + 4 - offset, y, {0,1,2}, 1, 1, 0)
    sspr(CURSOR_HIGHLIGHT_CORNER_S, x + 4 - offset, hy + 3 - offset, {0,1,2}, 1, 3, 0)
    sspr(CURSOR_HIGHLIGHT_CORNER_S, x + 0 + offset, hy + 3 - offset, {0,1,2}, 1, 2, 0)
    pal()
    if cursor.type == 'item' and cursor.item_stack and cursor.item_stack.id ~= 0 and self:is_hovered(cursor.x, cursor.y) then
      draw_item_stack(cursor.x + 3, cursor.y + 3, cursor.item_stack)
    end
  end

  if self.hotbar_vis and not self.vis then
    ui.draw_panel(hx, hy - 1, self.w, INVENTORY_SLOT_SIZE + 4, self.bg, self.fg, false, 8)
    ui.draw_grid(hx + 1, hy, 1, INVENTORY_COLS, self.grid_bg, self.grid_fg, INVENTORY_SLOT_SIZE+1)
    -- rect(self.x + 1, 136 - 2 - (INVENTORY_SLOT_SIZE + 3) + 2, self.w, INVENTORY_SLOT_SIZE + 2, 15)
    -- rectb(self.x, 136 - 2 - (INVENTORY_SLOT_SIZE + 4), self.w, INVENTORY_SLOT_SIZE + 4, INVENTORY_FG_COL)
    -- rect(self.x + 1, 136 - 2 - (INVENTORY_SLOT_SIZE + 3), self.w - 2, INVENTORY_SLOT_SIZE + 2, INVENTORY_BG_COL)
    for col = 1, INVENTORY_COLS do
      local x, y = hx + ((col-1) * (INVENTORY_SLOT_SIZE+1)), hy + 4
      --rect(x, y, INVENTORY_SLOT_SIZE, INVENTORY_SLOT_SIZE, INVENTORY_SLOT_COL)
      prints(col, x + 5, y - 1, 0, 13)
      local id = self.slots[INV_HOTBAR_OFFSET + col].item_id
      if id ~= 0 then
        sspr(ITEMS[id].sprite_id, x + 2, hy + 1, ITEMS[id].color_key)
      end
      if col == self.active_slot then
        --spr(CURSOR_HIGHLIGHT, x, y, 0)
        --rectb(x, hy, 10, 10, 4)
        pal({5,4,6,3})
        local offset = floor(player.anim_frame/4)
          sspr(CURSOR_HIGHLIGHT_CORNER_S, x + 0 + offset, hy - 1 + offset, {0,1,2})
          sspr(CURSOR_HIGHLIGHT_CORNER_S, x + 4 - offset, hy - 1 + offset, {0,1,2}, 1, 1, 0)
          sspr(CURSOR_HIGHLIGHT_CORNER_S, x + 4 - offset, hy + 3 - offset, {0,1,2}, 1, 3, 0)
          sspr(CURSOR_HIGHLIGHT_CORNER_S, x + 0 + offset, hy + 3 - offset, {0,1,2}, 1, 2, 0)
        pal()
      end
    end
    local xx = (INVENTORY_SLOT_SIZE * INVENTORY_COLS) + INVENTORY_SLOT_SIZE - 2
    pix(self.x + self.grid_x, hy + 1, self.grid_fg)
    pix(self.x + self.grid_x, hy + 8, self.grid_fg)
    pix(self.x + self.grid_x + xx, hy + 1, self.grid_fg)
    pix(self.x + self.grid_x + xx, hy + 8, self.grid_fg)
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

function inventory:add_item(item)

end

function inventory:remove_item(slot)

end

function inventory:slot_clicked(index)
  if cursor.type == 'item' and not cursor.ll then
    if self.slots[index].item_id == 0 then
      trace('depositing to slot: ' .. index)
      --deposit
      self.slots[index].item_id = cursor.item_stack.id
      self.slots[index].count = cursor.item_stack.count
      cursor.item_stack = {id = 0, count = 0}
      cursor.type = 'pointer'
    else
      --swap stacks
      local inv_item = {id = self.slots[index].item_id, count = self.slots[index].count}
      self.slots[index].item_id = cursor.item_stack.id
      self.slots[index].count = cursor.item_stack.count
      cursor.item_stack = {id = inv_item.id, count = inv_item.count}
      cursor.type = 'item'
      cursor.item = ITEMS[inv_item.id].name
    end
  elseif cursor.type == 'pointer' and not cursor.ll then
    local id, count = self.slots[index].item_id, self.slots[index].count
    if id ~= 0 then
      cursor.item_stack = {id = id, count = count}
      cursor.type = 'item'
      cursor.item = ITEMS[id].name
      self.slots[index].item_id = 0
      self.slots[index].count = 0
    end
  end
end

function inventory:clicked(x, y)
  if self.vis and self:is_hovered(x, y) then
    local result = self:get_hovered_slot(x, y)
    if ((cursor.l and not cursor.ll) or (cursor.r and not cursor.lr)) and result then
      --if self.slots[result.index].item_id == 0 then
        self.slots[result.index]:callback()
      --end
      return true
    end
  end
  return false
end

function inventory:is_hovered(x, y)
  if self.vis then
    return x >= self.x and x < self.x + self.w and y >= self.y and y < self.y + self.h and true or false
  elseif self.hotbar_vis then
    return x >= self.x and x < self.x + self.w and y >= self.hotbar_y and y < self.hotbar_y + self.hotbar_h and true or false
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