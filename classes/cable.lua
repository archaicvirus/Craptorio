--draws a hanging cable between two points
return function (p1, p2, color)
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

--Made using ChatGPT and with a little coercion
--In the function I provided, we simulate the shape of the hanging cable by oscillating it up and down along a 
--sine wave. We calculate the length of the cable and the midpoint between the start and end points, then use a 
--sine function to calculate the height of the cable at each point along its length. This creates a wave-like 
--shape that approximates the curve of a hanging cable.
--We use the math.sin() function to calculate the height of the cable at each point, based on its position along 
--the length of the cable. We multiply the x position by math.pi and divide by the length of the cable to create 
--a sine wave that oscillates between positive and negative values. We then multiply the sine wave by a constant 
--value (sag_height) to control the amplitude of the wave, creating the sagging effect of the cable.
--While this method is not as accurate as using the catenary equation, it is much simpler and more efficient 
--to calculate, making it a good choice for applications where speed and efficiency are more important than precision.
