local ItemSlot = {
  x = 0,
  y = 0,
  w = 8,
  h = 8,
  stack = {
    id = 0,
    count = 0,
  }
  locked = false,
}

function ItemSlot.clicked()
  local x, y = cursor.x, cursor.y
  local left, right = false, false
  if x >= self.x and x < self.x + self.w and y >= self.y and y < self.y + self.h then
    if cursor.l and not cursor.ll then
      left = true
    elseif cursor.r and not cursor.lr then
      right = true
    end
    if cursor.type == 'item' then
      if left then

      elseif right then

      end
    elseif cursor.type == 'pointer' then

    end
  end
end


function newItemSlot(x,y,stack)
  local slot = {}

  return slot
end