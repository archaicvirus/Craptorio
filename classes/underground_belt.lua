UBELT_ID           = 374
UBELT_ID_STRAIGHT  = 342
UBELT_TICKRATE     = 5
UBELT_MAXTICK      = 3
UBELT_TICK         = 0

local uBelt = {
  x = 0, y = 0,
  rot = 0,
  lanes = {[1] = {}, [2] = {}},
  is_exit = false,
  type = 'underground_belt',
  is_hovered = false,
  drawn = false,
  updated = false,
}

function uBelt:draw()
  local sx, sy = world_to_screen(self.x, self.y)
  sspr(UBELT_ID + UBELT_TICK, sx, sy, 0, 1, self.flip, self.rot)
end

function uBelt:draw_items()
  for i = 1, 2 do
    for j = 1, 8 do

    end
  end
end

function uBelt:update()
  for i = 1, 2 do
    for j = 1, #self.lanes[i] do

    end
  end
end

function uBelt:create_underground_segment(x, y)
  
end

function uBelt:request_item(keep, lane, slot)
  if not lane and not slot then
    for i = 1, 2 do
      for j = 1, 8 do
        if self.lanes[i][j] ~= 0 then
          local item_id = self.lanes[i][j]
          if not keep then self.lanes[i][j] = 0 end
          return item_id
        end
      end
    end
    return false
  elseif self.lanes[lane][slot] ~= 0 then
    local item_id = self.lanes[lane][slot]
    if not keep then self.lanes[lane][slot] = 0 end
    return item_id
  end
  return false
end

return function (x, y, rot)
  local new_belt = {x = x, y = y, lanes = {[1] = {0,0,0,0,0,0,0,0}, [2] = {0,0,0,0,0,0,0,0}}, rot = rot}
  setmetatable(new_belt, {__index = uBelt})
  return new_belt
end