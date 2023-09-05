LAB_ID = 396
LAB_TICKRATE = 5
LAB_ANIM_TICKRATE = 0
LAB_ANIM_TICK = 0

local Lab = {
  x = 0,
  y = 0,
  item_id = 22,
  type = 'research_lab',
  input = {},
  dummy_keys = {},
  progress = 0,
}

function Lab:open()
  return {
    x = 240 - 83 - 2,
    y = 1,
    w = 83,
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
      local txt = ITEMS[ENTS[self.ent_key].id].fancy_name
      local txt2 = current_research and TECH[AVAILABLE_TECH[current_research]].name or 'No Active Research'
      local ent = ENTS[self.ent_key]
      ui.draw_panel(self.x, self.y, self.w, self.h, UI_BG, UI_FG, 'Research Lab', UI_SH)
      --box(self.x, self.y, self.w, self.h, 8, 9)
      --rect(self.x + 1, self.y + 1, self.w - 2, 9, 9)
      --close button
      sspr(CLOSE_ID, self.x + self.w - 9, self.y + 2, 15)
      prints(txt, self.x + self.w/2 - print(txt, 0, -10, 0, false, 1, true)/2, self.y + 2, 0, 4)
      prints(txt2, self.x + self.w/2 - print(txt2, 0, -10, 0, false, 1, true)/2, self.y + 12, 0, 4)
      for i = 1, 4 do
        box(self.x + 14 + (i - 1)*13, self.y + 50, 10, 10, 0, 9)
        if ent.input[i].count > 0 then
          draw_item_stack(self.x + 15 + (i - 1)*13, self.y + 51, ent.input[i])
        end
      end
      --progress bar
      --box(self.x + 10, self.y + 20, self.w - 20, 6, 0, 9)
      local time = current_research and TECH[AVAILABLE_TECH[current_research]].time or 0
      ui.progress_bar(ent.progress/(time * 60), self.x + 10, self.y + 20, self.w - 20, 6, UI_BG, UI_FG, 6, 2)

      if self:is_hovered(cursor.x, cursor.y) and cursor.type == 'item' then
        draw_item_stack(cursor.x + 5, cursor.y + 5, cursor.item_stack)
      end
      for i = 1, 4 do
        if hovered(cursor, {x = self.x + 14 + (i - 1)*13, y = self.y + 50, w = 10, h = 10}) then
          ui.highlight(self.x + 13 + (i - 1)*13, self.y + 49, 10, 10, false, 3, 4)
        end
      end
    end,
    click = function(self, sx, sy)
      local ent = ENTS[self.ent_key]
      if self:close(sx, sy) then
        ui.active_window = nil
        return true
      end
      for i = 1, 4 do
        if hovered(cursor, {x = self.x + 14 + (i - 1)*13, y = self.y + 50, w = 10, h = 10}) then
          -- ui.highlight(self.x + 13 + (i - 1)*13, self.y + 49, 10, 10, false, 3, 4)
          if cursor.l and not cursor.ll then
            --item interaction
            if cursor.type == 'pointer' then
              if key(64) then
                local old_count = ent.input[i].count
                local result, stack = inv:add_item(ent.input[i])
                if result then
                  ent.input[i].count = stack.count
                  sound('deposit')
                  ui.new_alert(cursor.x, cursor.y, '+ ' .. (stack.count == 0 and old_count or old_count - stack.count) .. ' ' .. ITEMS[ent.input[i].id].fancy_name, 1000, 0, 6)
                  return true
                end
              else

                if ent.input[i].count > 0 then
                  cursor.type = 'item'
                  cursor.item_stack.id = ent.input[i].id
                  cursor.item_stack.count = ent.input[i].count
                  ent.input[i].count = 0
                  return true
                end
              end
            elseif cursor.type == 'item' then
              local stack_size = ITEMS[ent.input[i].id].stack_size
              if cursor.item_stack.id == ent.input[i].id then
                if ent.input[i].count + cursor.item_stack.count <= stack_size then
                  ent.input[i].count = ent.input[i].count + cursor.item_stack.count
                  cursor.type = 'pointer'
                  cursor.item_stack.id = 0
                  cursor.item_stack.count = 0
                elseif ent.input[i].count + cursor.item_stack.count > stack_size then
                  local old_count = ent.input[i].count
                  ent.input[i].count = stack_size
                  cursor.item_stack.count = cursor.item_stack.count - (stack_size - old_count)
                end
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

function Lab:draw()
  local sx, sy = world_to_screen(self.x, self.y)
  if self.progress > 0 and TICK%60 > math.random(60) then
    local r =  math.random()
    if r > 0.75 then
      pal(9, 4)
    elseif r > 0.5 then
      pal(10, 4)
    else
      pal(10, 11)
    end
    sspr(LAB_ID, sx, sy, ITEMS[Lab.item_id].color_key, 1, 0, 0, 3, 3)
    pal()
  else
    sspr(LAB_ID, sx, sy, ITEMS[Lab.item_id].color_key, 1, 0, 0, 3, 3)
  end
end

function Lab:draw_hover_widget(x, y)
  local x, y = clamp(cursor.x + 5, 1, 240 - 85), clamp(cursor.y + 5, 1, 136 - 46)
  local w, h = 83, 46
  local txt = ITEMS[self.item_id].fancy_name
  local txt2 = current_research and TECH[AVAILABLE_TECH[current_research]].name or 'No Active Research'
  ui.draw_panel(x, y, w, h, UI_BG, UI_FG, 'Research Lab', UI_SH)
  prints(txt, x + w/2 - print(txt, 0, -10, 0, false, 1, true)/2, y + 2, 0, 4)
  prints(txt2, x + w/2 - print(txt2, 0, -10, 0, false, 1, true)/2, y + 12, 0, 4)
  for i = 1, 4 do
    box(x + 14 + (i - 1)*13, y + 30, 10, 10, 0, 9)
    if self.input[i].count > 0 then
      draw_item_stack(x + 15 + (i - 1)*13, y + 31, self.input[i])
    end
  end
  local time = current_research and TECH[AVAILABLE_TECH[current_research]].time or 0
  ui.progress_bar(self.progress/(time * 60), x + 10, y + 20, w - 20, 6, UI_BG, UI_FG, 6, 2)
end

function Lab:update()
  if not current_research then
    self.progress = 0
    return
  end
  if current_research and self.progress < TECH[AVAILABLE_TECH[current_research]].time * 60 and not TECH[AVAILABLE_TECH[current_research]].completed then
    for i = 1, #TECH[AVAILABLE_TECH[current_research]].science_packs do
      if self.input[i].count < 1 then return end
    end
    self.progress = self.progress + LAB_TICKRATE
    if self.progress >= TECH[AVAILABLE_TECH[current_research]].time * 60 then
      self.progress = 0
      local science_packs = TECH[AVAILABLE_TECH[current_research]].science_packs
      if update_research_progress() then
        --trace('updating science packs')
        for i = 1, #science_packs do
          local k = self.slot_keys[tostring(science_packs[i].id)]
          --trace('k = ' .. k)
          if self.input[k].count < 1 then return end
          self.input[k].count = self.input[k].count - 1
        end
        current_research = false
        selected_research = false
      end
    end
  end
end

function Lab:request(keep)
  
end

function Lab:deposit_stack(stack)
  for i = 1, 4 do
    local stack_size = ITEMS[self.input[i].id].stack_size
    if stack.id == self.input[i].id then
      if self.input[i].count + stack.count <= stack_size then
        self.input[i].count = self.input[i].count + stack.count
        return true, {id = 0, count = 0}
      elseif self.input[i].count + stack.count > stack_size then
        local old_count = self.input[i].count
        self.input[i].count = stack_size
        stack.count = stack.count - (stack_size - old_count)
        return true, stack
      end
    end
  end
  return false, stack
end

function new_lab(x, y, dummy_keys)
  -- local slotmap = {
  --   [1] = ,
  --   [2] = ,
  --   [3] = ,
  --   [4] = ,
  --   [5] = ,
  --   [6] = ,
  -- }
  local newlab = {
    x = x,
    y = y,
    type = 'research_lab',
    id = 22,
    input = {},
    progress = 10,
    dummy_keys = dummy_keys,
    slot_keys = {}
  }
  for i = 1, 4 do
    newlab.input[i] = {id = 22 + i, count = 0}
    newlab.slot_keys[tostring(22+i)] = i
    --trace('created new_lab with slot_key[' .. tostring(22+i) .. '] = ' .. i)
  end
  setmetatable(newlab, {__index = Lab})
  return newlab
end