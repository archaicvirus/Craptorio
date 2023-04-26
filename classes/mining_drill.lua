DRILL_BURNER_SPRITE_ID = 314
DRILL_ELEC_SPRITE_ID = 368
DRILL_BELT_ID = 304
DRILL_BIT_ID = 275
DRILL_TICK_RATE = 8
DRILL_ANIM_TICK = 0
DRILL_BIT_DIR = 1
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
  [0] = {x = -1, y =  1},
  [1] = {x = 0, y = -1},
  [2] = {x = 2, y =  0},
  [3] = {x =  1, y = 2},
}

DRILL_AREA_MAP_BURNER = {
  [1] = {x = 0, y = 0},
  [2] = {x = 1, y = 0},
  [3] = {x = 1, y = 1},
  [4] = {x = 0, y = 1}
}

DRILL_AREA_MAP_ELECTRIC = {
  [1] = {x = 0, y = 0},
  [2] = {x = 1, y = 0},
  [3] = {x = 2, y = 0},
  [4] = {x = 0, y = 1},
  [5] = {x = 1, y = 1},
  [6] = {x = 2, y = 1},
  [7] = {x = 0, y = 2},
  [8] = {x = 1, y = 2},
  [9] = {x = 2, y = 2}
}

local drill = {
  pos = {x = 0, y = 0},
  rot = 0,
  --output = {},
  ore_type = 'iron',
  ore_id = 3,
  output_key = '0-0',
  output_slots = 5,
  output = {
    item_id = 3,
    count = 0
  },
  field_keys = {},
  is_powered = true,
  yield_tick = 0,
  current_tile = 1,
  type = 'mining_drill',
  sub_type = 'burner',
  is_hovered = false,
  drawn = false,
  updated = false,
  idle = false,
}

function drill.yield(self)
  if self.output.count < self.output_slots then
    trace('current key: ' .. self.current_tile)
    local ore_key = self.field_keys[self.current_tile]
    if ORES[ore_key] then
      ORES[ore_key].ore_remaining = ORES[ore_key].ore_remaining - 1
      if ORES[ore_key].ore_remaining < 1 then
        trace('ore depleted')
        local wx, wy = ORES[ore_key].wx, ORES[ore_key].wy
        trace('WX = ' .. wx .. ', WY = ' .. wy)
        TileMan:set_tile(0, wx, wy)
        ORES[ore_key] = nil
      end
      
      self.output.count = self.output.count + 1
    else
      -- self.current_tile = self.current_tile + 1
      -- if self.current_tile > #self.field_keys then self.current_tile = 1 end
      -- if not self.idle then self.yield_tick = 19 end
    end
  end
  

end

function drill.update(self)
  if self.is_powered and not self.idle then
    self.current_tile = self.current_tile + 1
    if self.current_tile > 4 then self.current_tile = 1 end
    --self:consume_electric()
    self.yield_tick = self.yield_tick + 1
    if self.yield_tick > 20 then
      local idle = true
      -- for i = 1, 4 do
      --   if ORES[self.field_keys[i]] then idle = false break end
      -- end
      -- if idle then self.idle = true return end
      self.yield_tick = 0
      self:yield()
    end

    if self.output.count > 0 and ENTS[self.output_key] and ENTS[self.output_key].type == 'transport_belt' then
      local belt = ENTS[self.output_key]
      for i = 1, 2 do
        for j = 1, 8 do
          if ENTS[self.output_key].lanes[i][j] == 0 then
            ENTS[self.output_key].lanes[i][j] = self.output.item_id
            self.output.count = self.output.count - 1
            return
          end
        end
      end
    end

  end

  -- if self.is_powered then
  --   if self.output.item_count == 0 then
  --     self.yield_tick = self.yield_tick + 1
  --     if self.yield_tick > 20 then
  --       self.yield_tick = 0
  --       self.output.item_count = self.output.item_count + 1
  --     end
  --   elseif self.output.item_count > 0 then
  --     local out = DRILL_OUTPUT_MAP[self.rot]
  --     local key = get_key(self.pos.x + out.x, self.pos.y + out.y)
  --     if ENTS[key] and ENTS[key].type == 'transport_belt' then
  --       for i = 2, 1, -1 do
  --         for j = 8, 1, -1 do
  --           if BELTS[key].lanes[i][j] == 0 then
  --             BELTS[key].lanes[i][j] = self.ore_id
  --             self.output.item_count = self.output.item_count - 1
  --             --break
  --             return true
  --           end
  --         end
  --       end
  --     end
  --   end
  -- end
end

function drill.draw(self)
  --draw main drill body
  local sx, sy = world_to_screen(self.pos.x, self.pos.y)
  --trace(TICK % 2)
  sspr(DRILL_BURNER_SPRITE_ID + (DRILL_ANIM_TICK * 2), sx, sy, 0, 1, 0, self.rot, 2, 2)
  sspr(DRILL_BIT_ID, sx + DRILL_BIT_TICK, sy + 9, 0, 1, 0, self.rot + 1, 1, 1)
  --draw two drill-bits
  -- local pos1, pos2 = DRILL_BIT_MAP[self.rot][0], DRILL_BIT_MAP[self.rot][1]
  -- if self.rot == 0 or self.rot == 2 then
  --   spr(DRILL_BIT_ID, self.pos.x + pos1.x + DRILL_BIT_TICK - 4, self.pos.y + pos1.y - 4, 0, 1, 0, pos1.r, 1, 1)
  --   spr(DRILL_BIT_ID, self.pos.x  - 4 + pos2.x + DRILL_BIT_TICK * -1, self.pos.y + pos2.y - 4, 0, 1, 0, pos2.r, 1, 1)
  -- else
  --   spr(DRILL_BIT_ID, self.pos.x + pos1.x - 4, self.pos.y + pos1.y + DRILL_BIT_TICK - 4, 0, 1, 0, pos1.r, 1, 1)
  --   spr(DRILL_BIT_ID, self.pos.x + pos2.x - 4, self.pos.y - 4 + pos2.y + DRILL_BIT_TICK * -1, 0, 1, 0, pos2.r, 1, 1)
  -- end


  -- --draw the output belt
  -- local pos3 = DRILL_BELT_MAP[self.rot]
  -- spr(DRILL_BELT_ID + DRILL_ANIM_TICK, self.pos.x + pos3.x - 4, self.pos.y + pos3.y - 4, 0, 1, 0, self.rot, 1, 1)
end

return function(pos, rot, tiles)
  local out_pos = DRILL_OUTPUT_MAP[rot]
  local output_key = pos.x + out_pos.x .. '-' .. pos.y + out_pos.y
  local new_drill = {pos = pos, rot = rot, field_keys = tiles, output_key = output_key}
  setmetatable(new_drill, {__index = drill})
  return new_drill
end