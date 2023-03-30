SPLITTER_ID_TOP = 409
SPLITTER_ID_BTM = 425
SPLITTER_TICKRATE = 5

local splitter = {
  pos = {x = 0, y = 0},
  rot = 0,
  type = 'splitter',
  is_hovered = false,
}

function splitter.update(self)

end

function splitter.draw(self)

end

return function(pos, rot)
  local new_splitter = {pos = pos, rot = rot}
  setmetatable(new_splitter, {__index = splitter})
  return new_splitter
end