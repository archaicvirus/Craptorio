LAB_ID = 396
LAB_TICKRATE = 5
LAB_ANIM_TICKRATE = 0
LAB_ANIM_TICK = 0

local Lab = {
  x = 0,
  y = 0,
  id = 22,
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
      local txt2 = current_research and TECH[current_research].name or 'No Active Research'
      local ent = ENTS[self.ent_key]
      ui.draw_panel(self.x, self.y, self.w, self.h, UI_BG, UI_FG, 'Research Lab', UI_SH)
      --box(self.x, self.y, self.w, self.h, 8, 9)
      --rect(self.x + 1, self.y + 1, self.w - 2, 9, 9)
      --close button
      sspr(CLOSE_ID, self.x + self.w - 9, self.y + 2, 15)
      prints(txt, self.x + self.w/2 - print(txt, 0, -10, 0, false, 1, true)/2, self.y + 2, 0, 4)
      prints(txt2, self.x + self.w/2 - print(txt2, 0, -10, 0, false, 1, true)/2, self.y + 12, 0, 4)
      for i = 1, 6 do
        box(self.x + 4 + (i - 1)*13, self.y + 50, 10, 10, 0, 9)
        if ent.input[i].count > 0 then
          draw_item_stack(self.x + 5 + (i - 1)*13, self.y + 51, ent.input[i])
        end
      end
      --progress bar
      --box(self.x + 10, self.y + 20, self.w - 20, 6, 0, 9)
      local time = current_research and TECH[current_research].time or 0
      ui.progress_bar(ent.progress/(time * 60), self.x + 10, self.y + 20, self.w - 20, 6, UI_BG, UI_FG, 6, 2)
    end,
    click = function(self, sx, sy)
      if self:close(sx, sy) then
        ui.active_window = nil
        return true
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
    sspr(LAB_ID, sx, sy, ITEMS[Lab.id].color_key, 1, 0, 0, 3, 3)
    pal()
  else
    sspr(LAB_ID, sx, sy, ITEMS[Lab.id].color_key, 1, 0, 0, 3, 3)
  end
end

function Lab:draw_hover_widget(x, y)
  local width = print(ITEMS[self.id].fancy_name, 0, -10, 0, false, 1, true)
  local w, h = 75, 50
  local sx, sy = clamp(x or cursor.x + 5, 0, 240 - width), clamp(y or cursor.y + 5, 0, 136 - h)
  ui.draw_panel(sx, sy, w, h, 8, 9, ITEMS[self.id].fancy_name, 0)
  -- box(sx, sy, w, h, 8, 9)
  -- rect(sx + 1, sy + 1, w - 2, 9, 9)
  --prints(ITEMS[self.id].fancy_name, sx + w/2 - width/2, sy + 2)
end

function Lab:update()
  if not current_research then
    self.progress = 0
    return
  end
  if current_research and self.progress < TECH[current_research].time * 60 and not TECH[current_research].completed then
    for i = 1, #TECH[current_research].requirements do
      if self.input[i].count < 1 then return end
    end
    self.progress = self.progress + LAB_TICKRATE
    if self.progress >= TECH[current_research].time * 60 then
      self.progress = 0
      if not update_research_progress() then return end
      --trace('current_research: ' .. tostring(current_research))
      if current_research then
        for i = 1, #TECH[current_research].requirements do
          if self.input[i].count < 1 then return end
          self.input[i].count = self.input[i].count - 1
        end
      end
    end
  end
end

function Lab:request(keep)
  
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
  }
  for i = 1, 6 do
    newlab.input[i] = {id = 22 + i, count = 50}
  end
  setmetatable(newlab, {__index = Lab})
  return newlab
end