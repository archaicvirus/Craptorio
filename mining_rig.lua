local rig = {
  id = 
}

function rig.update(self)

end

function rig.draw(self)

end

return function(pos, dir)
  local new_rig = {pos = pos, dir = dir}
  setmetatable(new_rig, {__index = rig})
  return new_rig
end