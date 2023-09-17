DRILL_BURNER_SPRITE_ID = 273
DRILL_ELEC_SPRITE_ID = 368
DRILL_INV_ID = 276
DRILL_MINI_BELT_ID = 304
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
  ore_type = false,
  ore_id = nil,
  output_key = nil,
  output_slots = 50,
  output = {},
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
  tickrate = 5,
}

function Drill:draw_hover_widget()
  local sx, sy, w, h = clamp(cursor.x + 3, 1, 240 - 51), clamp(cursor.y + 3, 1, 136 - 51), 50, 50
  ui.draw_panel(sx, sy, w, h, UI_BG, UI_FG, 'Mining Drill', 0)
  box(sx + w/2 - 4, sy + h/2 - 4, 10, 10, 0, UI_FG)
  if self.output and self.output.count > 0 then
    local stack = {id = self.output.id, count = self.output.count}
    draw_item_stack(sx + w/2 - 4 + 1, sy + h/2 - 4 + 1, stack)
  end
    -- rectb(sx, sy, 50, 50, 13)
  -- rect(sx + 1, sy + 1, 48, 48, 0)
end

function Drill:open()
  return {
    x = 240 - 83 - 2,
    y = 1,
    w = 58,
    h = 50,
    ent_key = self.pos.x .. '-' .. self.pos.y,
    close = function(self, sx, sy)
      local btn = {x = self.x + self.w - 9, y = self.y + 1, w = 5, h = 5}
      if sx >= btn.x and sy < btn.x + btn.w and sy >= btn.y and sy <= btn.y + btn.h then
        return true
      end
      return false
    end,
    draw = function(self)
      local txt = ITEMS[ENTS[self.ent_key].item_id].fancy_name
      local ent = ENTS[self.ent_key]
      ui.draw_panel(self.x, self.y, self.w, self.h, UI_BG, UI_FG, 'Mining Drill', UI_SH)
      --box(self.x, self.y, self.w, self.h, 8, 9)
      --rect(self.x + 1, self.y + 1, self.w - 2, 9, 9)
      --close button
      sspr(CLOSE_ID, self.x + self.w - 7, self.y + 2, 15)
      box(self.x + self.w/2 - 5, self.y + 20, 10, 10, 0, 9)
        if ent.output.count > 0 then
          draw_item_stack(self.x + self.w/2 - 4, self.y + 21, {id = ent.output.id, count = ent.output.count})
        end
      if self:is_hovered(cursor.x, cursor.y) and cursor.type == 'item' then
        draw_item_stack(cursor.x + 5, cursor.y + 5, {id = cursor.item_stack.id, count = cursor.item_stack.count})
      end
      if hovered(cursor, {x = self.x + self.w/2 - 5, y = self.y + 20, w = 10, h = 10}) then
        ui.highlight(self.x + self.w/2 - 5, self.y + 20, 8, 8, false, 3, 4)
      end
    end,
    click = function(self, sx, sy)
      local ent = ENTS[self.ent_key]
      if self:close(sx, sy) then
        ui.active_window = nil
        return true
      end
      if hovered(cursor, {x = self.x + self.w/2 - 5, y = self.y + 20, w = 10, h = 10}) then
        if cursor.l and not cursor.ll then
          --item interaction
          if cursor.type == 'pointer' then
            if key(64) and ent.output.count > 0 then
              local old_count = ent.output.count
              local result, stack = inv:add_item({id = ent.output.id, count = ent.output.count})
              if result then
                ent.output.count = stack.count
                sound('deposit')
                ui.new_alert(cursor.x, cursor.y, '+ ' .. (stack.count == 0 and old_count or old_count - stack.count) .. ' ' .. ITEMS[ent.output.id].fancy_name, 1000, 0, 6)
                return true
              end
            else
              if ent.output.count > 0 then
                cursor.type = 'item'
                cursor.item_stack.id = ent.output.id
                cursor.item_stack.count = ent.output.count
                ent.output.count = 0
                return true
              end
            end
          end
        end
      end
      return false
    end,
    is_hovered = function(self, x, y)
      return x >= self.x and x < self.x + self.w and y >= self.y and y < self.y + self.h and true or false
    end,
  }
end

function Drill.yield(self)
  if self.output.count < self.output_slots then
    --trace('current key: ' .. self.current_tile)
    local ore_key = self.field_keys[self.current_tile]
    local ore_id
    if ORES[ore_key] then
      --ore_id = ORES[ore_key].sprite_id
      ore_id = ORES[ore_key].id
      if self.output.id == 0 or self.output.count == 0 then self.output.id = ore_id end
      if ore_id == self.output.id then
        ORES[ore_key].ore_remaining = ORES[ore_key].ore_remaining - 1
        self.output.count = self.output.count + 1
      end
      if ORES[ore_key].ore_remaining < 1 then
        --trace('ore depleted')
        local wx, wy = ORES[ore_key].wx, ORES[ore_key].wy
        --trace('WX = ' .. wx .. ', WY = ' .. wy)
        TileMan:set_tile(wx, wy)
        ORES[ore_key] = nil
      end
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
    local item = ITEMS[self.output.id]
    if item and self.output.count == item.stack_size then return end
    --self:consume_electric()
    self.yield_tick = self.yield_tick + 1
    if self.yield_tick > 20 then
      local idle = true
      self.current_tile = self.current_tile + 1
      if self.current_tile > 4 then self.current_tile = 1 end
      self.yield_tick = 0
      self:yield()
    end

    --if TICK % 60 == 0 then trace(tostring(ENTS[self.output_key] and ENTS[self.output_key].type or 'nil')) end
    --check for other ents
    if self.output.count > 0 and ENTS[self.output_key] then
      if ENTS[self.output_key].type == 'transport_belt' or
      ENTS[self.output_key].type == 'underground_belt' or
      ENTS[self.output_key].type == 'underground_belt_exit' then
        local output = DRILL_BELT_OUTPUT_MAP[self.rot][ENTS[self.output_key].rot]
        if output then
          if ENTS[self.output_key].type == 'underground_belt_exit' then
            if ENTS[ENTS[self.output_key].other_key].exit_lanes[output.lane][output.slot] == 0 then
              --trace('drill @ ' .. self.pos.x .. ',' .. self.pos.y .. ' outputting to belt @ ' .. self.output_key)
              ENTS[ENTS[self.output_key].other_key].exit_lanes[output.lane][output.slot] = self.output.id
              self.output.count = self.output.count - 1
              if self.output.count < 1 then self.output.id = 0 end
              return
            end
          elseif ENTS[self.output_key].lanes[output.lane][output.slot] == 0 then
            --trace('drill @ ' .. self.pos.x .. ',' .. self.pos.y .. ' outputting to belt @ ' .. self.output_key)
            ENTS[self.output_key].lanes[output.lane][output.slot] = self.output.id
            self.output.count = self.output.count - 1
            if self.output.count < 1 then self.output.id = 0 end
          end
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
    if idle == true and self.output.count < 1 then
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
    sspr(DRILL_BIT_ID, sx + 0 + (DRILL_BIT_TICK), sy + 5, 0, 1, 0, 0, 1, 1)
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

function Drill:return_all()
  if self.output.count > 0 then
    local result, stack = inv:add_item({id = self.output.id, count = self.output.count})
    if stack.count < self.output.count then
      sound('deposit')
      ui.new_alert(cursor.x, cursor.y, '+ ' .. self.output.count - stack.count .. ' ' .. ITEMS[self.output.id].fancy_name, 1000, 0, 6)
    end
    self.output.count = stack.count
  end
end

function Drill:deposit()
  return false
end

function Drill:request_deposit()
  return false
end

function Drill:item_request(id)
  trace('DRILL: requested item id = ' .. tostring(id))
  if self.output.count < 1 then return false end
  if self.output.id == id or id == 'any' or
  (id == 'ore' and ITEMS[self.output.id].type == 'ore') or
  (id == 'fuel' and ITEMS[self.output.id].type == 'fuel') then
    self.output.count = self.output.count - 1
    return self.output.id
  end
  return false
end

function return_all()
  if self.output.count > 0 then
    return {id = self.output.id, count = self.output.count}
  end
end

function new_drill(pos, rot, tiles)
  local out_pos = DRILL_OUTPUT_MAP[rot]
  local output_key = pos.x + out_pos.x .. '-' .. pos.y + out_pos.y
  local newdrill = {pos = pos, rot = rot, field_keys = tiles, output_key = output_key, output = {id = 0, count = 0}}
  setmetatable(newdrill, {__index = Drill})
  return newdrill
end