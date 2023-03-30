DRILL_SPRITE_ID = 273
DRILL_BELT_ID = 304
DRILL_BIT_ID = 275
DRILL_TICK_RATE = 4
DRILL_ANIM_TICK = 0
DRILL_BIT_DIR = 0
DRILL_BIT_TICK = 0

--for placing and animating the drill bits, rotated
DRILL_BIT_MAP = {
  [0] = {[0] = {x =  2, y =  2, r = 0}, [1] = {x = 6, y = 5, r = 2}},
  [1] = {[0] = {x =  3, y =  0, r = 3}, [1] = {x = 6, y = 8, r = 1}},
  [2] = {[0] = {x =  2, y =  3, r = 0}, [1] = {x = 6, y = 6, r = 2}},
  [3] = {[0] = {x =  2, y = -1, r = 3}, [1] = {x = 5, y = 7, r = 1}},
}

--for placing and animating the ore-output belt, rotated
DRILL_BELT_MAP = {
  [0] = {x = -4, y =  3},
  [1] = {x =  5, y = -4},
  [2] = {x = 12, y =  5},
  [3] = {x =  3, y = 12},
}

DRILL_OUTPUT_MAP = {
  [0] = {x = -16, y =   0},
  [1] = {x =   0, y = -16},
  [2] = {x =  16, y =   0},
  [3] = {x =   0, y =  16},
}

local drill = {
  pos = {x = 0, y = 0},
  rot = 0,
  output = {},
  ore_type = 'iron',
  ore_id = 3,
  output_key = '0-0',
  output = {
    item_id = 3,
    item_count = 0
  },
  is_powered = true,
  yield_tick = 0,
  type = 'mining-drill',
  is_hovered = false,
}

function drill.update(self)
  if self.is_powered then
    if self.output.item_count == 0 then
      self.yield_tick = self.yield_tick + 1
      if self.yield_tick > 20 then
        self.yield_tick = 0
        self.output.item_count = self.output.item_count + 1
      end
    elseif self.output.item_count > 0 then
      local out = DRILL_OUTPUT_MAP[self.rot]
      local key = get_key(self.pos.x + out.x, self.pos.y + out.y)
      if BELTS[key] then
        for i = 2, 1, -1 do
          for j = 8, 1, -1 do
            if BELTS[key].lanes[i][j] == 0 then
              BELTS[key].lanes[i][j] = self.ore_id
              self.output.item_count = self.output.item_count - 1
              --break
              return true
            end
          end
        end
      end
    end
  end
end

function drill.draw(self)
  --draw main drill body
  spr(DRILL_SPRITE_ID, self.pos.x - 4, self.pos.y - 4, 0, 1, 0, self.rot, 2, 2)

  --draw two drill-bits
  local pos1, pos2 = DRILL_BIT_MAP[self.rot][0], DRILL_BIT_MAP[self.rot][1]
  if self.rot == 0 or self.rot == 2 then
    spr(DRILL_BIT_ID, self.pos.x + pos1.x + DRILL_BIT_TICK - 4, self.pos.y + pos1.y - 4, 0, 1, 0, pos1.r, 1, 1)
    spr(DRILL_BIT_ID, self.pos.x  - 4 + pos2.x + DRILL_BIT_TICK * -1, self.pos.y + pos2.y - 4, 0, 1, 0, pos2.r, 1, 1)
  else
    spr(DRILL_BIT_ID, self.pos.x + pos1.x - 4, self.pos.y + pos1.y + DRILL_BIT_TICK - 4, 0, 1, 0, pos1.r, 1, 1)
    spr(DRILL_BIT_ID, self.pos.x + pos2.x - 4, self.pos.y - 4 + pos2.y + DRILL_BIT_TICK * -1, 0, 1, 0, pos2.r, 1, 1)
  end


  --draw the output belt
  local pos3 = DRILL_BELT_MAP[self.rot]
  spr(DRILL_BELT_ID + DRILL_ANIM_TICK, self.pos.x + pos3.x - 4, self.pos.y + pos3.y - 4, 0, 1, 0, self.rot, 1, 1)
end

return function(pos, dir)
  local new_drill = {pos = pos, dir = dir}
  setmetatable(new_drill, {__index = drill})
  return new_drill
end