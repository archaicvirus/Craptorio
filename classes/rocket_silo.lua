ROCKET_SILO_ID = 368
ROCKET_DOOR_ID = 370
ROCKET_ID = 394
ROCKET_CRAFT_TIME = 100

local Silo = {
  x = 0,
  y = 0,
  anim_frame = 0,
  input = {},
  output = {},
  progress = {},
  type = 'rocket_silo',
  updated = false,
  drawn = false,
  is_hovered = false,
  item_id = 40,
  state = 'wait',
  wait = 0,
  delay = 200,
  requests = {},
}

function Silo:draw()
  local sx, sy = world_to_screen(self.x, self.y)
  
  rect(sx + 8, sy + 8, 16, 16, 0)
  spr(ROCKET_SILO_ID, sx, sy, 1, 1, 0, 0, 2, 2)
  spr(ROCKET_SILO_ID, sx + 16, sy, 1, 1, 1, 0, 2, 2)
  
  if self.state == 'raise' then
    clip(sx + 8, (sy + 24) - 56, 16, 56)
    spr(ROCKET_ID, sx + 8, sy + 16 - self.anim_frame, 1, 1, 0, 0, 2, 6)
    clip()
  end

  if self.state == 'opening' then
    clip(sx + 8, (sy + 24) - 56, 16, 56)
    spr(ROCKET_ID, sx + 8, sy + 16, 1, 1, 0, 0, 2, 1)
    clip()
  end

  spr(ROCKET_SILO_ID, sx + 16, sy + 16, 1, 1, 3, 0, 2, 2)
  spr(ROCKET_SILO_ID, sx, sy + 16, 1, 1, 2, 0, 2, 2)
  
  clip(sx + 8, sy + 8, 16, 16)
  local offset = ((self.state == 'opening' or self.state == 'closing' or self.state == 'launch_ready') and self.anim_frame) or 0
  if self.state == 'raise' then offset = 8 end
  for y = 0, 1 do
    for x = 0, 1 do
      if x == 0 then
        spr(370, sx + 8 + x*8 - offset, sy + 8 + y*8)
      else
        spr(370, offset + sx + 8 + x*8, sy + 8 + y*8)
      end
    end
  end
  clip()
  if self.state == 'launch_ready' then
    clip(sx + 8, (sy + 24) - 56, 16, 56)
    spr(ROCKET_ID, sx + 8, (sy + 16) - 32, 1, 1, 0, 0, 2, 6)
    clip()
  end
end

function Silo:draw_hover_widget(x, y)
  x, y = clamp(x or cursor.x + 5, 1, 240 - 63), clamp(y or cursor.y + 5, 1, 136 - 66)
  local w, h = 63, 66
  --local txt = ITEMS[ENTS[self.ent_key].id].fancy_name
  ui.draw_panel(x, y, w, h, UI_BG, UI_FG, 'Rocket Silo', UI_SH)
  ui.progress_bar(math.min(1.0, self.progress/ROCKET_CRAFT_TIME), x + w/2 - 25, y + 12, 50, 6, UI_BG, UI_FG, 6, 0)
  prints('Input', x + w/2 - 12, y + h - 24)
  for k, v in ipairs(self.input) do
    box(x + w/2 - ((#self.input*13)/2) + (k-1)*13, y + h - 15, 10, 10, 8, 9)
    if v.id ~= 0 and v.count > 0 then
      draw_item_stack(x + w/2 - ((#self.input*13)/2) + (k-1)*13 + 1, y + h - 15 + 1, v)
    end
  end
  --draw output items
  prints('Output', x + w/2 - 12, y + 19)
  box(x + w/2 - 6, y + 27, 10, 10, 8, 9)
  if self.output.count > 0 then
    draw_item_stack(x + w/2 - 4, y + 28, {id = self.output.id, count = self.output.count})
  end
end

function Silo:open()
  return {
    x = 240 - 65,
    y = 1,
    w = 63,
    h = 66,
    ent_key = self.x .. '-' .. self.y,
    close = function(self, sx, sy)
      local btn = {x = self.x + self.w - 9, y = self.y + 1, w = 5, h = 5}
      if sx >= btn.x and sy < btn.x + btn.w and sy >= btn.y and sy <= btn.y + btn.h then
        return true
      end
      return false
    end,
    draw = function(self)
      --local txt = ITEMS[ENTS[self.ent_key].id].fancy_name
      local ent = ENTS[self.ent_key]
      ui.draw_panel(self.x, self.y, self.w, self.h, UI_BG, UI_FG, 'Rocket Silo', UI_SH)
      ui.progress_bar(math.min(1.0, ent.progress/ROCKET_CRAFT_TIME), self.x + self.w/2 - 25, self.y + 12, 50, 6, UI_BG, UI_FG, 6, 0)
      sspr(CLOSE_ID, self.x + self.w - 9, self.y + 2, 15)
      prints('Input', self.x + self.w/2 - 12, self.y + self.h - 24)
      for k, v in ipairs(ent.input) do
        box(self.x + self.w/2 - ((#ent.input*13)/2) + (k-1)*13, self.y + self.h - 15, 10, 10, 8, 9)
        if v.id ~= 0 and v.count > 0 then
          draw_item_stack(self.x + self.w/2 - ((#ent.input*13)/2) + (k-1)*13 + 1, self.y + self.h - 15 + 1, v)
        end
      end
      --draw output items
      prints('Output', self.x + self.w/2 - 12, self.y + 19)
      box(self.x + self.w/2 - 6, self.y + 27, 10, 10, 8, 9)
      if ent.output.count > 0 then
        draw_item_stack(self.x + self.w/2 - 4, self.y + 28, {id = ent.output.id, count = ent.output.count})
      end
      if hovered(cursor, {x = self.x + self.w/2 - 6, y = self.y + 27, w = 10, h = 10}) then
        ui.highlight(self.x + self.w/2 - 6, self.y + 27, 8, 8, false, 3, 4)
        if key(64) then draw_recipe_widget(cursor.x + 5, cursor.y + 5, ent.output.id) end
      end
      --draw cursor item
      if self:is_hovered(cursor.x, cursor.y) and cursor.type == 'item' then
        draw_item_stack(cursor.x + 5, cursor.y + 5, {id = cursor.item_stack.id, count = cursor.item_stack.count})
      end
      --input slots hover
      for k, v in ipairs(ent.input) do
        if hovered(cursor, {x = self.x + self.w/2 - ((#ent.input*13)/2) + (k-1)*13, y = self.y + self.h - 15, w = 10, h = 10}) then
          ui.highlight(self.x + self.w/2 - ((#ent.input*13)/2) + (k-1)*13, self.y + self.h - 15, 8, 8, false, 3, 4)
          if key(64) then draw_recipe_widget(cursor.x + 5, cursor.y + 5, v.id) end
        end
      end
    end,
    click = function(self, sx, sy)
      local ent = ENTS[self.ent_key]
      if self:close(sx, sy) then
        ui.active_window = nil
        return true
      end
      for k, v in ipairs(ent.input) do
        if hovered(cursor, {x = self.x + self.w/2 - ((#ent.input*13)/2) + (k-1)*13, y = self.y + self.h - 15, w = 10, h = 10}) then
          -- ui.highlight(self.x + 13 + (i - 1)*13, self.y + 49, 10, 10, false, 3, 4)
          
          trace('silo slot # ' .. k .. ' clicked')
          trace('item slot is ' .. ITEMS[v.id].fancy_name)
          trace('k = ' .. tostring(k))
          local stack_size = 100
          --item interaction
          if cursor.type == 'pointer' then
            if key(64) then
              local old_count = v.count
              local result, stack = inv:add_item({id = v.id, count = v.count})
              if result then
                v.count = stack.count
                sound('deposit')
                ui.new_alert(cursor.x, cursor.y, '+ ' .. (stack.count == 0 and old_count or old_count - stack.count) .. ' ' .. ITEMS[v.id].fancy_name, 1000, 0, 6)
                return true
              end
            elseif v.count > 0 then
              if cursor.r and v.count > 1 then
                set_cursor_item({id = v.id, count = math.ceil(v.count/2)}, false)
                v.count = floor(v.count/2)
                return true
              else
                set_cursor_item({id = v.id, count = v.count}, false)
                v.count = 0
                return true
              end
            end
          elseif cursor.type == 'item' and cursor.item_stack.id == v.id then
            --try to combine stacks, leaving extra on cursor
            if key(64) then
              if v.count > 0 then
                local result, stack = inv:add_item({id = v.id, count = v.count})
                if result then
                  v.count = stack.count
                  sound('deposit')
                  ui.new_alert(cursor.x, cursor.y, '+ ' .. (stack.count == 0 and old_count or old_count - stack.count) .. ' ' .. ITEMS[v.id].fancy_name, 1000, 0, 6)
                end
              end
              return true
            end
            if cursor.r then
              if v.count + 1 < stack_size then
                v.count = v.count + 1
                cursor.item_stack.count = cursor.item_stack.count - 1
                if cursor.item_stack.count < 1 then
                  set_cursor_item()
                end
                return true
              end
            else
              if cursor.item_stack.count + v.count > stack_size then
                local old_count = v.count
                v.count = stack_size
                cursor.item_stack.count = cursor.item_stack.count - (stack_size - old_count)
                return true
              else
                v.count = v.count + cursor.item_stack.count
                set_cursor_item()
                return true
              end
            end
          end
          
        end
      end
      if ent.output.count > 0 and cursor.type == 'pointer' and hovered({x = sx, y = sy}, {x = self.x + self.w/2 - 6, y = self.y + 27, w = 10, h = 10}) then
        if key(64) then
          local old_count = ent.output.count
          local result, stack = inv:add_item({id = ent.output.id, count = ent.output.count})
          if result then
            ent.output.count = stack.count
            ui.new_alert(cursor.x, cursor.y, '+ ' .. (stack.count == 0 and old_count or old_count - stack.count) .. ' ' .. ITEMS[ent.output.id].fancy_name, 1000, 0, 6)
            sound('deposit')
            return true
          end
        else
          if cursor.r and v.count > 1 then
            set_cursor_item({id = v.id, count = math.ceil(v.count/2)}, false)
            v.count = floor(v.count/2)
            return true
          else
            set_cursor_item({id = ent.output.id, count = ent.output.count})
            ent.output.count = 0
            return true
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

function Silo:update()
  if self.state == 'opening' then
    self.anim_frame = self.anim_frame + 1
    if self.anim_frame > 7 then
      self.anim_frame = 0
      self.state = 'raise'
    end
  elseif self.state == 'closing' then
    self.anim_frame = self.anim_frame - 1
    if self.anim_frame < 1 then
      self.state = 'return'
    end
  elseif self.state == 'wait' then
    for k, v in ipairs(self.input) do
      if v.count < 100 then return end
    end
    self.state = 'opening'
  elseif self.state == 'return' then
    self.wait = self.wait + 5
    if time() > self.wait + self.delay then
      self.wait = 0
      self.state = 'opening'
    end

  elseif self.state == 'raise' then
    self.anim_frame = self.anim_frame + 1
    if self.anim_frame > 32 then
      self.anim_frame = 32
      self.state = 'launch_ready'
    end
  end
end

function Silo:update_requests()
  for i = 1, #self.requests do
    --if ingredients are low, request more items
    if self.input[i].count < 100 then
      self.requests[i][1] = true
    end
    --self.requests[i][2] = false 
  end
end

function Silo:get_request()
  for i = 1, #self.requests do
    if self.requests[i][1] and not self.requests[i][2] then
      --self.requests[i][2] = true
      return self.input[i].id
      --now an inserter has been dispatched to retrieve this item
    end
  end
  return false
end

function Silo:deposit(id)
  for k, v in ipairs(self.input) do
    if id == v.id then
      self.input[k].count = self.input[k].count + 1
      self.requests[k][2] = false
      if self.input[k].count > 100 then
        self.requests[k][1] = false
      end
      return true
    end
  end
  return false
end

function Silo:deposit_stack(stack)
  for k, v in ipairs(self.input) do
    if v.id == stack.id then
      local stack_size = 100
      if v.count < stack_size then
        if v.count + stack.count <= stack_size then
          v.count = v.count + stack.count
          return true, {id = 0, count = 0}
        elseif v.count + stack.count > stack_size then
          stack.count = stack.count - (stack_size - v.count)
          v.count = stack_size
          return true, stack
        end
        return false, stack
      end
    end
  end
  return false, stack
end

function Silo:request_deposit()
  return self:get_request()
end

function Silo:item_request(id)
  if (id == 'any' or id == self.output.id) and self.output.count > 0 then
    self.output.count = self.output.count - 1
    return self.output.id
  end
  return false
end

function Silo:assign_delivery(id)
  for k, v in ipairs(self.input) do
    if v.id == id then
      self.requests[k][2] = true
      return
    end
  end
end

function Silo:return_all()
  for k, v in ipairs(self.input) do
    if v.count > 0 then
      local _, stack = inv:add_item({id = v.id, count = v.count})
      if stack.count ~= v.count then
        ui.new_alert(cursor.x, cursor.y, '+ ' .. v.count - stack.count .. ' ' .. ITEMS[v.id].fancy_name, 1000, 0, 6)
        v.count = stack.count
      end
    end
  end
  if self.output.count > 0 then
    local _, stack = inv:add_item({id = self.output.id, count = self.output.count})
    if stack.count ~= self.output.count then
      ui.new_alert(cursor.x, cursor.y, '+ ' .. self.output.count - stack.count .. ' ' .. ITEMS[self.output.id].fancy_name, 1000, 0, 6)
      self.output.count = stack.count
    end
  end
end

function new_silo(x, y)
  local newSilo = {
    x = x,
    y = y,
    anim_frame = 0,
    input = {
      {id = 41, count = 0},
      {id = 42, count = 0},
      {id = 43, count = 0}
    },
    requests = {
      {true, false},
      {true, false},
      {true, false},
    },
    output = {id = 44, count = 0},
    progress = 0,
  }
  setmetatable(newSilo, {__index = Silo})
  return newSilo
end