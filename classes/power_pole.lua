POWER_POLE_TOP_ID = 292
POWER_POLE_MID_ID = 308
POWER_POLE_BTM_ID = 324
POWER_CABLE_COLOR = 4
POWER_CABLE_GREEN = 6
POWER_CABLE_RED   = 2
POWER_POLE_ANCHOR_POINTS = {
  ['power'] = {[1] = {x = 3, y = 1}, [2] = {x = 1, y = 4}},
  ['red']   = {[1] = {x = 0, y = 1}, [2] = {x = 1, y = 7}},
  ['green'] = {[1] = {x = 7, y = 1}, [2] = {x = 1, y = 0}}}
POWER_POLE_CONNECT_MAP = {

}
local pole = {
  pos = {x = 0, y = 0},
  cables = {
    ['power'] = {},
    ['red']   = {},
    ['green'] = {}},
  range = 3,
  has_power = false,
}

function pole.draw(self)
  spr(POWER_POLE_TOP_ID, self.pos.x, self.pos.y - 16)
  spr(POWER_POLE_MID_ID, self.pos.x, self.pos.y - 8 )
  spr(POWER_POLE_BTM_ID, self.pos.x, self.pos.y     )
  for k, v in ipairs(self.cables) do
    if #v > 0 then
      if k == 1 then col = 
      --if there are cables, draw them
      --poles can have multiple connections to other poles
    end
  end
end

function pole.update(self)

end

function pole.connect(self, other)
  local other_pwr, other_red, other_grn = other:get_sockets()

end

function pole.get_sockets(self)
  local pwr = POWER_POLE_ANCHOR_POINTS['power'][1]
  local red = POWER_POLE_ANCHOR_POINTS['red'][1]
  local grn = POWER_POLE_ANCHOR_POINTS['green'][1]
  local pwr_socket = {x = self.pos.x + pwr.x, y = self.pos.y + pwr.y - 16}
  local red_socket = {x = self.pos.x + red.x, y = self.pos.y + red.y - 16}
  local grn_socket = {x = self.pos.x + grn.x, y = self.pos.y + grn.y - 16}
  return pwr_socket, red_socket, grn_socket
end

return function(pos)
  local new_pole = {pos = pos}
  setmetatable(new_pole, {__index = pole})
  return new_pole
end
