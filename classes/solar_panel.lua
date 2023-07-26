local solar_panel = {
  x = 0,
  y = 0,
  powered = false,
  max_power = 200.0,
  min_power = 20.0,
}

SOLAR_DUMMY_KEYS = {
  vec2(-1, -1), vec2(0, -1), vec2(1, -1),
  vec2(-1, 0),               vec2(1, 0),
  vec2(-1, 1), vec2(0, 1), vec2(1, 1)
}

function solar_panel:draw()

end

function solar_panel:update()

end

function new_solar_panel(x, y)
  return setmetatable({x = x, y = y}, {__index = solar_panel})
end