INVENTORY_SLOT_SIZE = 8
INVENTORY_BG_COL    = 14
INVENTORY_FG_COL    = 12
INVENTORY_SLOT_COL  = 15
INVENTORY_COLS      = 10
INVENTORY_ROWS      = 10

INVENTORY_WIDTH     = 3 + ((INVENTORY_SLOT_SIZE + 1) * INVENTORY_COLS)
INVENTORY_HEIGHT    = 3 + ((INVENTORY_SLOT_SIZE + 1) * INVENTORY_ROWS)

local inventory = {
  pos = {x = (240 / 2) - (INVENTORY_WIDTH/2), y = 136 - INVENTORY_HEIGHT},
  slots = {},
  hotbar = {},
}

function inventory.draw(self)
  rectb(self.pos.x, self.pos.y, INVENTORY_WIDTH, INVENTORY_HEIGHT, INVENTORY_FG_COL)
  rect(self.pos.x + 1, self.pos.y + 1, INVENTORY_WIDTH - 2, INVENTORY_HEIGHT - 2, INVENTORY_BG_COL)
  for row = 1, INVENTORY_ROWS do
    for col = 1, INVENTORY_COLS do
      local x, y = (self.pos.x + 2) + ((col - 1) * (INVENTORY_SLOT_SIZE + 1)), (self.pos.y + 2) + ((row - 1) * (INVENTORY_SLOT_SIZE + 1))
      rect(x, y, INVENTORY_SLOT_SIZE, INVENTORY_SLOT_SIZE, INVENTORY_SLOT_COL)
      if row == INVENTORY_ROWS then
        if col > 9 then col = 0 end
        print(col, x + 2, y + 1, 0, true, 1, true)        
      end
    end
  end
end

function inventory.draw_hotbar(self)
  rectb(self.pos.x, 136 - (INVENTORY_SLOT_SIZE + 4), INVENTORY_WIDTH, INVENTORY_SLOT_SIZE + 4, INVENTORY_FG_COL)
  rect(self.pos.x + 1, 136 - (INVENTORY_SLOT_SIZE + 3), INVENTORY_WIDTH - 2, INVENTORY_SLOT_SIZE + 2, INVENTORY_BG_COL)
  for col = 1, INVENTORY_COLS do
    local x, y = (self.pos.x + 2) + ((col - 1) * (INVENTORY_SLOT_SIZE + 1)), 136 - (INVENTORY_SLOT_SIZE + 2)
    rect(x, y, INVENTORY_SLOT_SIZE, INVENTORY_SLOT_SIZE, INVENTORY_SLOT_COL)
    if col > 9 then col = 0 end
    print(col, x + 2, y + 1, 0, true, 1, true)
  end
end

function inventory.update(self)

end

function inventory.add_item(self, item)

end

function inventory.remove_item(self, slot)

end

function inventory.get_hovered_slot(self, x, y)
  local inv_x, inv_y = self.pos.x, self.pos.y
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
    return true, slot_pos_x, slot_pos_y, slot_index
  else
    return nil
  end
end

function new_slot(index)
  local slot = {
    item_id = 0,
    count = 0,
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
