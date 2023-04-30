DRILL_BURNER_SPRITE_ID = 314
DRILL_ELEC_SPRITE_ID = 368
DRILL_MINI_BELT_ID = 321
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

DRILL_MINI_BELT_MAP = {
  [0] = {x =  0, y =  8},
  [1] = {x =  0, y =  0},
  [2] = {x =  8, y =  0},
  [3] = {x =  8, y =  8}
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

DRILL_BELT_OUTPUT_MAP = {
  [0] = {
    [0] = {lane = 1, slot = 8},
    [1] = {lane = 1, slot = 5},
    [2] = nil,
    [3] = {lane = 2, slot = 3}},
  [1] = {
    [0] = {lane = 2, slot = 3},
    [1] = {lane = 1, slot = 8},
    [2] = {lane = 1, slot = 4},
    [3] = nil},
  [2] = {
    [0] = nil,
    [1] = {lane = 2, slot = 3},
    [2] = {lane = 2, slot = 8},
    [3] = {lane = 1, slot = 4}},
  [3] = {
    [0] = {lane = 1, slot = 4},
    [1] = nil,
    [2] = {lane = 2, slot = 3},
    [3] = {lane = 1, slot = 8}},
}

local Drill = {
  pos = {x = 0, y = 0},
  rot = 0,
  --output = {},
  ore_type = nil,
  ore_id = nil,
  output_key = nil,
  output_slots = 5,
  output = nil,
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
  item_id = 13,
}

function Drill.draw_hover_widget(self)
  local sx, sy = cursor.x, cursor.y
  rectb(sx, sy, 50, 50, 13)
  rect(sx + 1, sy + 1, 48, 48, 0)
end

function Drill.yield(self)
  if #self.output < self.output_slots then
    --trace('current key: ' .. self.current_tile)
    local ore_key = self.field_keys[self.current_tile]
    local ore_id
    if ORES[ore_key] then
      --ore_id = ORES[ore_key].sprite_id
      ore_id = ORES[ore_key].id
      ORES[ore_key].ore_remaining = ORES[ore_key].ore_remaining - 1
      if ORES[ore_key].ore_remaining < 1 then
        --trace('ore depleted')
        local wx, wy = ORES[ore_key].wx, ORES[ore_key].wy
        --trace('WX = ' .. wx .. ', WY = ' .. wy)
        TileMan:set_tile(0, wx, wy)
        ORES[ore_key] = nil
      end
      
      table.insert(self.output, ore_id)
    else
      -- self.current_tile = self.current_tile + 1
      -- if self.current_tile > #self.field_keys then self.current_tile = 1 end
      if not self.idle then self.yield_tick = 19 end
      --self:update()
    end
  end
end

function Drill.update(self)
  if self.is_powered and not self.idle then

    --self:consume_electric()
    self.yield_tick = self.yield_tick + 1
    if self.yield_tick > 20 then
      local idle = true
      self.current_tile = self.current_tile + 1
      if self.current_tile > 4 then self.current_tile = 1 end
      self.yield_tick = 0
      self:yield()
    end

    if #self.output > 0 and ENTS[self.output_key] and ENTS[self.output_key].type == 'transport_belt' then
      local output = DRILL_BELT_OUTPUT_MAP[self.rot][ENTS[self.output_key].rot]
      if output then
        if ENTS[self.output_key].lanes[output.lane][output.slot] == 0 then
          --trace('drill @ ' .. self.pos.x .. ',' .. self.pos.y .. ' outputting to belt @ ' .. self.output_key)
          ENTS[self.output_key].lanes[output.lane][output.slot] = self.output[#self.output]
          table.remove(self.output, #self.output)
        end
      end
    end

    local idle = true
    for i = 1, 4 do
      if ORES[self.field_keys[i]] then
        idle = false
        break
      end
    end
    if idle == true and #self.output < 1 then
      self.idle = true
    end
  end
end

function Drill.draw(self)
  if not self.idle then
    --draw main drill body
    local sx, sy = world_to_screen(self.pos.x, self.pos.y)
    local belt_pos = DRILL_MINI_BELT_MAP[self.rot]
    --trace(TICK % 2)
    --sspr(DRILL_BURNER_SPRITE_ID + (DRILL_ANIM_TICK * 2), sx, sy, 0, 1, 0, self.rot, 2, 2)
    sspr(DRILL_BIT_ID, sx + 0 + (DRILL_BIT_TICK), sy + 7, 0, 1, 0, 0, 1, 1)
    sspr(DRILL_BURNER_SPRITE_ID, sx, sy, 0, 1, 0, 0, 2, 2)
    sspr(DRILL_MINI_BELT_ID + DRILL_ANIM_TICK, sx + belt_pos.x, sy + belt_pos.y, 0, 1, 0, self.rot, 1, 1)
  else
    local sx, sy = world_to_screen(self.pos.x, self.pos.y)
    local belt_pos = DRILL_MINI_BELT_MAP[self.rot]
    -- sspr(DRILL_BURNER_SPRITE_ID, sx, sy, 0, 1, 0, self.rot, 2, 2)
    -- sspr(DRILL_BIT_ID, sx, sy + 9, 0, 1, 0, self.rot + 1, 1, 1)
    sspr(DRILL_BURNER_SPRITE_ID, sx, sy, 0, 1, 0, 0, 2, 2)
    sspr(DRILL_BIT_ID, sx + 5, sy + 12, 0, 1, 0, 0, 1, 1)
    sspr(DRILL_MINI_BELT_ID, sx + belt_pos.x, sy + belt_pos.y, 0, 1, 0, self.rot, 1, 1)
  end
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

function newDrill(pos, rot, tiles)
  local out_pos = DRILL_OUTPUT_MAP[rot]
  local output_key = pos.x + out_pos.x .. '-' .. pos.y + out_pos.y
  trace(output_key)
  local newdrill = {pos = pos, rot = rot, field_keys = tiles, output_key = output_key, output = {}}
  setmetatable(newdrill, {__index = Drill})
  return newdrill
end

return newDrill