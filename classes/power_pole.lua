POWER_POLE_TOP_ID = 292
POWER_POLE_MID_ID = 308
POWER_POLE_BTM_ID = 324
POWER_CABLE_COLOR = 4
POWER_CABLE_GREEN = 6
POWER_CABLE_RED   = 2
POWER_CURSOR_ID   = 320
POWER_AREA_ID     = 336

--for drawing sprites to show powered area
POWER_AREA_MAP = {
  [1] = {pos = {x = -16, y = -16}, rot = 0},
  [2] = {pos = {x =  16, y = -16}, rot = 1},
  [3] = {pos = {x =  16, y =  16}, rot = 2},
  [4] = {pos = {x = -16, y =  16}, rot = 3}}

  --for drawing the cables
POWER_POLE_ANCHOR_POINTS = {
  ['power'] = {[1] = {x = 3, y = 1}, [2] = {x = 1, y = 4}},
  ['red']   = {[1] = {x = 0, y = 1}, [2] = {x = 1, y = 7}},
  ['green'] = {[1] = {x = 7, y = 1}, [2] = {x = 1, y = 0}}}

  --tiles to check around self for other poles or powered objects
POWER_POLE_CONNECT_MAP = {}

local pole = {
  pos = {x = 0, y = 0},
  cables = {
    ['power'] = {},
    ['red']   = {},
    ['green'] = {}},
  range = 3,
  has_power = false,
  is_hovered = false,
  type = 'power_pole',
}

function pole.draw(self, show_area)
  show_area = show_area or false
  local loc_x, loc_y = world_to_screen(self.pos.x, self.pos.y)
  spr(POWER_POLE_TOP_ID, loc_x, loc_y - 16, 0)
  spr(POWER_POLE_MID_ID, loc_x, loc_y -  8, 0)
  spr(POWER_POLE_BTM_ID, loc_x, loc_y     , 0)
  for k, v in ipairs(self.cables) do
    if #v > 0 then
      if k == 1 then col = 1
      --if there are cables, draw them
      --poles can have multiple connections to other poles
      end
    end
  end
  if show_area or self.is_hovered then
    for k, v in ipairs(POWER_AREA_MAP) do
      spr(POWER_AREA_ID, loc_x + v.pos.x, loc_y + v.pos.y, 0, 1, 0, v.rot)
    end
    --spr(POWER_CURSOR_ID, loc_x, loc_y, 0)
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