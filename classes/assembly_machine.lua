local Crafter = {}

function Crafter:draw()

end

function Crafter:update()

end

function 

function Crafter:new(x, y)
  local obj = {x = x, y = y}
  setmetatable(obj, {__index = self})
  return obj
end