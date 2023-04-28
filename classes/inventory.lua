INVENTORY_SLOT_SIZE = 8
INVENTORY_BG_COL    = 14
INVENTORY_FG_COL    = 12
INVENTORY_SLOT_COL  = 15
INVENTORY_COLS      = 10
INVENTORY_ROWS      = 10

INVENTORY_WIDTH     = 3 + ((INVENTORY_SLOT_SIZE + 1) * INVENTORY_COLS)
INVENTORY_HEIGHT    = 3 + ((INVENTORY_SLOT_SIZE + 1) * INVENTORY_ROWS)

local inventory = {
  x = (240 / 2) - (INVENTORY_WIDTH/2), 
  y = 136 - INVENTORY_HEIGHT - 2,
  w = INVENTORY_WIDTH,
  h = INVENTORY_HEIGHT,
  slots = {},
  hotbar = {},
  hovered_slot = 0,
  active_slot = 1,
  hotbar_h = 12,
  hotbar_y = 136 - (INVENTORY_SLOT_SIZE + 4) - 2,
  vis = false,
  hotbar_vis = true,
}

function inventory.draw(self)
  local x, y = mouse()
  local slot = self:get_hovered_slot(x, y)
  if self.vis then
    rectb(self.x, self.y, self.w, self.h, INVENTORY_FG_COL)
    rect(self.x + 1, self.y + 1, self.w - 2, self.h - 2, INVENTORY_BG_COL)
    for row = 1, INVENTORY_ROWS do
      for col = 1, INVENTORY_COLS do
        local x, y = (self.x + 2) + ((col - 1) * (INVENTORY_SLOT_SIZE + 1)), (self.y + 2) + ((row - 1) * (INVENTORY_SLOT_SIZE + 1))
        rect(x, y, INVENTORY_SLOT_SIZE, INVENTORY_SLOT_SIZE, INVENTORY_SLOT_COL)
        if row == INVENTORY_ROWS then
          local num = col
          if col > 9 then num = 0 end
          print(num, x + 2, y + 1, 0, true, 1, true)
          local id = self.slots[90 + col].item_id
          if id ~= 0 then
            sspr(ITEMS[id].sprite_id, x, y, 0)
          end
        end
      end
    end
    -- local x, y = mouse()
    -- local slot = self:get_hovered_slot(x, y)
    if slot then spr(CURSOR_HIGHLIGHT, slot.x - 1, slot.y - 1, 0, 1, 0, 0, 2, 2) end
  end

  if self.hotbar_vis and not self.vis then
    rectb(self.x, 136 - 2 - (INVENTORY_SLOT_SIZE + 4), self.w, INVENTORY_SLOT_SIZE + 4, INVENTORY_FG_COL)
    rect(self.x + 1, 136 - 2 - (INVENTORY_SLOT_SIZE + 3), self.w - 2, INVENTORY_SLOT_SIZE + 2, INVENTORY_BG_COL)
    for col = 1, INVENTORY_COLS do
      local x, y = (self.x + 2) + ((col - 1) * (INVENTORY_SLOT_SIZE + 1)), 136 - 2 - (INVENTORY_SLOT_SIZE + 2)
      rect(x, y, INVENTORY_SLOT_SIZE, INVENTORY_SLOT_SIZE, INVENTORY_SLOT_COL)
      if col == self.active_slot then
        --spr(CURSOR_HIGHLIGHT, x, y, 0)
        rectb(x - 1, y - 1, 10, 10, 4)
      end
      local num = col
      if col > 9 then num = 0 end
      print(num, x + 2, y + 1, 0, true, 1, true)
      local id = self.slots[90 + col].item_id
      if id ~= 0 then
        sspr(ITEMS[id].sprite_id, x, y, 0)
      end
    end
  end
end

function inventory.draw_hotbar(self)
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

function inventory.update(self)

end

function inventory.add_item(self, item)

end

function inventory.remove_item(self, slot)

end

function inventory.clicked(self, x, y)
  --local x, y, l, m, r, scrx, scryy = mouse()
  if self.vis and self:is_hovered(x, y) then
    local result = self:get_hovered_slot(x, y)
    if l or r and result then
      if self.slots[result.index].item_id ~= 0 then
        self.slots[result.index]:callback()
      end
      return true
    end
  end
  return false
end

function inventory.is_hovered(self, x, y)
  if self.vis then
    return x >= self.x and x < self.x + self.w and y >= self.y and y < self.y + self.h and true or false
  elseif self.hotbar_vis then
    return x >= self.x and x < self.x + self.w and y >= self.hotbar_y and y < self.hotbar_y + self.hotbar_h and true or false
  end
  return false
end

function inventory.get_hovered_slot(self, x, y)
  local inv_x, inv_y = self.x, self.y
  local start_x = inv_x + 2
  local start_y = inv_y + 2
  
  local rel_x = x - start_x + 1
  local rel_y = y - start_y + 1
  
  local slot_x = math.floor(rel_x / 9)
  local slot_y = math.floor(rel_y / 9)
  
  local slot_pos_x = start_x + slot_x * 9
  local slot_pos_y = start_y + slot_y * 9
  local slot_index = slot_y * 10 + slot_x + 1
  if slot_x >= 0 and slot_x < 10 and slot_y >= 0 and slot_y < 10 then
    return {x = slot_pos_x, y = slot_pos_y, index = slot_index}
  else
    return nil
  end
end

function new_slot(index)
  local slot = {
    item_id = 0,
    count = 0,
    callback = function (self) trace('hello world! From Slot: ' .. self.index) end,
    index = index,
  }
  return slot
end

function create_inventory()
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

return create_inventory