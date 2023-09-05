INSERTER_BASE_ID       = 264
INSERTER_ARM_ID        = 265
INSERTER_ARM_ANGLED_ID = 266
INSERTER_ANIM_TICKRATE = 4
INSERTER_TICKRATE      = 4
INSERTER_COLORKEY = 15

INSERTER_ARM_OFFSETS = {
  [0] = {id = INSERTER_ARM_ID,        x = -3, y =  0, rot = 0, item_offset = {x = -1, y =  2}},
  [1] = {id = INSERTER_ARM_ANGLED_ID, x = -3, y = -3, rot = 0, item_offset = {x =  1, y =  1}},
  [2] = {id = INSERTER_ARM_ID,        x =  0, y = -3, rot = 1, item_offset = {x =  2, y = -1}},
  [3] = {id = INSERTER_ARM_ANGLED_ID, x =  3, y = -3, rot = 1, item_offset = {x =  4, y =  1}},
  [4] = {id = INSERTER_ARM_ID,        x =  3, y =  0, rot = 2, item_offset = {x =  6, y =  3}},
  [5] = {id = INSERTER_ARM_ANGLED_ID, x =  3, y =  3, rot = 2, item_offset = {x =  5, y =  5}},
  [6] = {id = INSERTER_ARM_ID,        x =  0, y =  3, rot = 3, item_offset = {x =  2, y =  6}},
  [7] = {id = INSERTER_ARM_ANGLED_ID, x = -3, y =  3, rot = 3, item_offset = {x =  3, y =  4}},
}

INSERTER_GRAB_OFFSETS = {
  [0] = {from = {x =  1, y =  0}, to = {x = -1, y =  0}},
  [1] = {from = {x =  0, y =  1}, to = {x =  0, y = -1}},
  [2] = {from = {x = -1, y =  0}, to = {x =  1, y =  0}},
  [3] = {from = {x =  0, y = -1}, to = {x =  0, y =  1}},
}

INSERTER_DEPOSIT_MAP = {
  [0] = {[0] = 1, [1] = 2, [2] = 2, [3] = 1},
  [1] = {[0] = 1, [1] = 2, [2] = 2, [3] = 1},
  [2] = {[0] = 1, [1] = 1, [2] = 2, [3] = 2},
  [3] = {[0] = 2, [1] = 2, [2] = 1, [3] = 1},
}

INSERTER_ANIM_KEYS = {
  [0] = {0,1,2,3,4},
  [1] = {2,3,4,5,6},
  [2] = {4,5,6,7,0},
  [3] = {6,7,0,1,2}
}

local Inserter = {
  pos = {x = 0, y = 0},
  rot = 0,
  color_keys = {15},
  from_key = '0-0',
  to_key = '0-0',
  anim_frame = 5,
  state = 'wait',
  held_item_id = 0,
  is_hovered = false,
  type = 'inserter',
  item_id = 11,
  filter = {item_id = 0}
}

function Inserter.draw_hover_widget(self)
  -- local sx, sy = cursor.x, cursor.y
  -- rectb(sx, sy, 50, 50, 13)
  -- rect(sx + 1, sy + 1, 48, 48, 0)
end

function Inserter.get_info(self)
  local info = {
    [1] = 'POS: ' .. get_key(self.pos.x, self.pos.y),
    [2] = 'ROT: ' .. self.rot,
    [3] = 'OUT: ' .. self.to_key,
    [4] = 'INP: ' .. self.from_key,
  }
  return info
end

function Inserter.draw(self)
  local config = INSERTER_ARM_OFFSETS[INSERTER_ANIM_KEYS[self.rot][self.anim_frame]]
  local sx, sy = world_to_screen(self.pos.x, self.pos.y)
  local screen_pos = {x = sx, y = sy}
  local x, y = config.x + screen_pos.x, config.y + screen_pos.y
  spr(INSERTER_BASE_ID, screen_pos.x, screen_pos.y, self.color_keys, 1, 0, self.rot, 1, 1)
  spr(config.id, x, y, self.color_keys, 1, 0, config.rot, 1, 1)
  if self.held_item_id > 0 then
    local sprite_id = ITEMS[self.held_item_id].belt_id
    local ck = {ITEMS[self.held_item_id].color_key}
    spr(sprite_id, x + config.item_offset.x, y + config.item_offset.y, ck)
  end
end

function Inserter.can_deposit(self, other, item_id)
  if ENTS[other] then
    if ENTS[other].type == 'transport_belt' then
      return true
    elseif ENTS[other].type == 'stone_furnace' then
      if ENTS[other]:deposit({id = item_id, count = 1}, true) then return true end
    elseif ENTS[other].type == 'splitter' then
      if ENTS[other]:deposit({id = item_id, count = 1}, true) then return true end
    end
  end
  return false
end

function Inserter.set_output(self)
  local from, to = INSERTER_GRAB_OFFSETS[self.rot].from, INSERTER_GRAB_OFFSETS[self.rot].to
  self.from_key = self.pos.x + from.x .. '-' .. self.pos.y + from.y
  self.to_key = self.pos.x  + to.x .. '-' .. self.pos.y + to.y
end

function Inserter.rotate(self, rotation)
  rotation = rotation or self.rot + 1
  self.rot = rotation
  if self.rot > 3 then self.rot = 0 end
  self:set_output()
end

function Inserter.update(self)
  local from, to = self.from_key, self.to_key
  if ENTS[from] and ENTS[from].type == 'dummy_assembler' then
    self.from_key = ENTS[from].other_key
    from = self.from_key
  end
  if self.state == 'send' then
    self.anim_frame = self.anim_frame - 1
    if self.anim_frame <= 1 then
      self.anim_frame = 1
      --try to deposit item
      --trace('looking for output')
      if ENTS[to] then
        local k = to
        local ent = ENTS[to]
        if ent.type == 'dummy_assembler' then k = ENTS[k].other_key; ent = ENTS[k] end
        if ent.type == 'transport_belt' then
          ENTS[to].idle = false
          --trace('FOUND belt')
          for i = 8, 1, -1 do
            local index = ENTS[to].rot
            local lane = INSERTER_DEPOSIT_MAP[self.rot][index]
            if ENTS[to].lanes[lane][i] == 0 then
              ENTS[to].lanes[lane][i] = self.held_item_id
              self.held_item_id = 0
              self.state = 'return'
              break
            end
          end
          --return
        elseif ent.type == 'stone_furnace' or ent.type == 'dummy_furnace' then
          --trace('furnace detected')
          if ent.type == 'dummy_furnace' then
            self.to_key = ent.other_key
            k = ent.other_key
          end
          if ENTS[k]:deposit(self.held_item_id, false) then
            self.held_item_id = 0
            self.state = 'return'
          end
          --return
        elseif ent.type == 'underground_belt' then
          if ENTS[k]:deposit(self.held_item_id, 0) then
            self.held_item_id = 0
            self.state = 'return'
          end
        elseif ent.type == 'underground_belt_exit' then
          if ENTS[k]:deposit(self.held_item_id, 1) then
            self.held_item_id = 0
            self.state = 'return'
          end
        elseif ent.type == 'splitter' or ent.type == 'dummy_splitter' then
          if ent.type == 'dummy_splitter' then
            self.to_key = ent.other_key
            k = ent.other_keyaw
          end
          if ENTS[k]:input(self.held_item_id, 2) then
            self.held_item_id = 0
            self.state = 'return'
          end
        elseif ent.type == 'assembly_machine' then
          --trace('attempt assembler deposit')
          if ENTS[k]:deposit(self.held_item_id) then
            self.held_item_id = 0
            self.state = 'return'
          end
        elseif ent.type == 'chest' then
          --trace('attempting chest deposit')
          if ENTS[k]:can_deposit({id = self.held_item_id, count = 1}) then
            ENTS[k]:deposit(self.held_item_id)
            self.held_item_id = 0
            self.state = 'return'
          end
        end
      end
      -- if not ENTS[to].type == 'ground-items' or (ENTS[to].type == 'ground-items' and ENTS[to][1] == 0) then
      --   local to = INSERTER_GRAB_OFFSETS[self.rot].to
      --   --create ground item entity with belt lanes
      --   local gnd_item = {id = self.held_item_id, pos = {self.pos.x + to.x, self.pos.y + to.y}, type = 'gound-item'}
      --   table.insert(GROUND_ITEMS, gnd_item)
      --   local index = #GROUND_ITEMS
      --   GROUND_ITEMS[self.to_key] = GROUND_ITEMS[index]
      --   self.held_item_id = 0
      --   self.state = 'return'
      -- --drop on ground
      -- end
      
      -- self.held_item_id = 0
      -- self.state = 'return'
    end    
  elseif self.state == 'return' then
    self.anim_frame = self.anim_frame + 1
    if self.anim_frame >= 5 then
      -- inserter has returned, and waits for another item
      self.anim_frame = 5
      self.state = 'wait'
    end
  elseif self.state == 'wait' then
    if ENTS[from] then
      if ENTS[from].type == 'transport_belt' then

        if ENTS[to] and ENTS[to].type == 'dummy_furnace' then
          self.to_key = ENTS[to].other_key
          to = self.to_key
        end

        if ENTS[to] and ENTS[to].type == 'stone_furnace' then
          --check if output destination can take an item
          --before we pick it up from the belt
          --to prevent inserter stuck holding item
          local desired_type, sub_type = ENTS[to]:request()
          local item_id = ENTS[from]:request_item_furnace(true, desired_type, sub_type)

          if item_id and ENTS[to]:deposit(item_id, true) then
            --ENTS[to]:deposit(item_id, false)
            self.held_item_id = ENTS[from]:request_item_furnace(false, desired_type, sub_type)
            self.state = 'send'
          end
          return
        end

        local item_id = ENTS[from]:request_item(false)
        if item_id then
          self.held_item_id = item_id
          self.state = 'send'
          return
        end

        -- for i = 1, 8 do
        --   local lane = 0
        --   if ENTS[from].lanes[1][i] ~= 0 then
        --     lane = 1
        --   elseif ENTS[from].lanes[2][i] ~= 0 then
        --     lane = 2
        --   end
        --   if lane > 0 then
        --     self.held_item_id = ENTS[from].lanes[lane][i]
        --     ENTS[from].lanes[lane][i] = 0
        --     self.state = 'send'
        --     return
        --     --break
        --   end
        -- end
      elseif ENTS[from].type == 'splitter' or ENTS[from].type == 'dummy_splitter' then
        if ENTS[from].type == 'dummy_splitter' then
          local item = ENTS[ENTS[from].other_key]:give_inserter('left')
          if item then
            self.held_item_id = item
            self.state = 'send'
            return
          end
        else
          local item = ENTS[from]:give_inserter('right')
          if item then
            self.held_item_id = item
            self.state = 'send'
            return
          end
        end
      elseif ENTS[from].type == 'stone_furnace' or ENTS[from].type == 'dummy_furnace' then
        --trace('furnace detected')
        local k = self.from_key
        if ENTS[k].type == 'dummy_furnace' then
          k = ENTS[k].other_key
        end

        --if ENTS[k].output_buffer.count > 0 then
        if ENTS[k]:request_output(true) then
          self.held_item_id = ENTS[k]:request_output(false)
          self.state = 'send'
        end
        return
      elseif ENTS[from].type == 'underground_belt' then
        local result = ENTS[from]:request_item(false)
        if result then
          self.held_item_id = result
          self.state = 'send'
        end
        return
      elseif ENTS[from].type == 'underground_belt_exit' then
        local result = ENTS[ENTS[from].other_key]:request_item_exit(false)
        if result then
          self.held_item_id = result
          self.state = 'send'
        end
        return
      elseif ENTS[from].type == 'assembly_machine' then
        --trace('inserter: found assembler')
        if ENTS[from].output.id > 0 and ENTS[from].output.count > 0 then
          ENTS[from].output.count = ENTS[from].output.count - 1
          self.held_item_id = ENTS[from].output.id
          self.state = 'send'
        end
        return
      elseif ENTS[from].type == 'chest' then
        --trace('attempting chest retrieval')
        local result = ENTS[from]:request_inserter()
        if result then
          self.held_item_id = result
          self.state = 'send'
        end
        return
      end
      
      -- if GROUND_ITEMS[self.from_key] and GROUND_ITEMS[self.from_key][1] ~= 0 then
      -- --try to pick from ground
      --   self.held_item_id = GROUND_ITEMS[self.from_key][1]
      --   GROUND_ITEMS[self.from_key][1] = 0
      --   self.state = 'send'
      -- end
    end
  end
end

function new_inserter(position, rotation)
  local new_inserter = {pos = position, rot = rotation}
  setmetatable(new_inserter, {__index = Inserter})
  --new_Inserter.pos = position
  --new_Inserter.rot = rotation
  new_inserter:set_output()
  return new_inserter
end