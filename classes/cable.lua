--draws a hanging cable between two points
function draw_cable(p1, p2, color)
  -- calculate the length and midpoint of the cable
  local dx = p2.x - p1.x
  local dy = p2.y - p1.y
  local length = math.sqrt(dx * dx + dy * dy)
  local midpoint = { x = (p1.x + p2.x) / 2, y = (p1.y + p2.y) / 2 }

  -- calculate the height of the sag
  local sag_height = math.max(length / 8, 8)

  -- draw the cable
  for x = 0, length do
    local y = math.sin(x / length * math.pi) * sag_height
    local px = p1.x + dx * x / length + 0.5
    local py = p1.y + dy * x / length + y + 0.5
    if x > 0 then
      local px_prev = p1.x + dx * (x - 1) / length + 0.5
      local py_prev = p1.y + dy * (x - 1) / length + math.sin((x - 1) / length * math.pi) * sag_height + 0.5
      line(px_prev, py_prev, px, py, color)
    else
      pix(px, py, color)
    end
  end
end

-- return function (p1, p2, col)
--   local dx = p2.x - p1.x
--   local dy = p2.y - p1.y
--   local dist = math.sqrt(dx*dx + dy*dy)
--   --local sag = math.max(dist/8, 8)
--   local segments = math.floor(dist)
--   local sagAmount = sag or 0.2
  
--   -- calculate initial angle and velocity
--   local angle = math.atan2(dy, dx)
--   local velocity = dist / segments
  
--   -- draw cable segments
--   local prevX, prevY = p1.x, p1.y
--   for i=1,segments do
--     -- calculate new position based on simplified catenary equation
--     local x = p1.x + i * dx / segments
--     local y = p1.y + sagAmount * math.cosh(i * angle / sagAmount)
    
--     -- draw segment
--     line(prevX, prevY, x, y, col)
    
--     prevX, prevY = x, y
--   end
  
--   -- draw final segment
--   line(prevX, prevY, p2.x, p2.y, col)
-- end
