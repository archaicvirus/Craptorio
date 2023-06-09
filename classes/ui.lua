CRAFT_ANCHOR_ID = 435
CLOSE_ID = 437
CRAFT_ROWS = 6
CRAFT_COLS = 8
UI_CORNER = 352
UI_CORNER_ = 352
LOGISTICS_ID = 387
UI_BG = 8
UI_FG = 9
UI_TEXT_BG = 0
UI_TEXT_FG = 4
UI_SHADOW = 0
--TODO: move all main ui windows here
ui = {windows = {}, active_window = false}

local Panel = {
  x = 0,
  y = 0,
  w = 10,
  h = 10,
  fg = 13,
  bg = 15,
  border = true,
  children = {},
  name = 'UI Test Name',
  vis = true,
  callback = function(self, ...) end,
  lines = {}
}

function box(x, y, w, h, bg, fg)
  rectb(x, y, w, h, fg)
  rect(x + 1, y + 1, w - 2, h - 2, bg)
end

function Panel:draw(parent)
  if self.vis then
    local screen_x, screen_y = self.x, self.y
    if parent then
      screen_x, screen_y = parent.x + self.x, parent.y + self.y
    end
    if self.border then
      rectb(screen_x, screen_y, self.w, self.h, self.fg)
    end
    rect(screen_x + 1, screen_y + 1, self.w - 2, self.h - 2, self.bg)
    --Draw any lines
    if #self.lines > 0 then
      for key, ln in pairs(self.lines) do
        local x1, x2, y1, y2
        if ln.vert then 
          x1, x2 = self.x + ln.pos, self.x + ln.pos
          y1, y2 = self.y, self.y + self.h - 1
        else
          x1, x2 = self.x + 1, self.x + self.w - 2
          y1, y2 = self.y + ln.pos, self.y + ln.pos
        end
        line(x1, y1, x2, y2, ln.col or self.fg)
      end
    end
    --Center the name text
    if self.w == 5 and self.h == 6 then
      --For small buttons/boxes
      print(self.name, screen_x + 1, screen_y, 15, false, 1, true)
    else
      local width = print(self.name, 0, -6, 15, true, 1, true)
      print(self.name, screen_x + (self.w - width)//2, screen_y + 2, 14, false, 1, true)
    end
    if #self.children > 0 then
      for key, child in ipairs(self.children) do
        child.draw(child, self)
      end
    end
  end
end

function Panel:is_hovered(x, y)
  local sx, sy = self.x, self.y
  if self.parent then
    sx, sy = self.x + self.parent.x, self.y + self.parent.y
  end
  return x >= sx and x < sx + self.w and y >= sy and y < sy + self.h and true or false
end

function ui.NewPanel(x, y, w, h, fg, bg, border, children, on_click)
  local new_panel = {
    x = x or Panel.x,
    y = y or Panel.y,
    w = w or Panel.w,
    h = h or Panel.h,
    fg = fg or Panel.fg,
    bg = bg or Panel.bg,
    border = border or Panel.border,
    children = children or Panel.children,
    callback = on_click or Panel.callback,
  }
  if on_click then
    new_panel.click = function(self, ...) self.callback(self, ...) end
  end
  setmetatable(new_panel, {__index = Panel})
  for key, child in pairs(new_panel.children) do
    child.parent = new_panel
  end
  return new_panel
end

function ui.draw_text_window(data, x, y, label, bg, fg, text_bg, text_fg)
  x, y, label, fg, bg, text_fg, text_bg = x or 2, y or 2, label or false, fg or UI_FG, bg or UI_BG, text_fg or UI_TEXT_FG, text_bg or UI_TEXT_BG
  local w = 6
  local h = #data * 7 + 4 + (label and 9 or 0)
  --if label then h = h + 9 end
  for i = 1, #data do
    local string_width = print(data[i], 0, -10, 0, false, 1, true)
    if string_width + 6 > w then w = string_width + 6 end
  end
  ui.draw_panel(x, y, w, h, bg, fg, label, UI_SHADOW)
  -- rectb(x, y, width, height, border)
  -- rect(x + 1, y + 1, width - 2, height - 2, background)
  for i = 1, #data do
    prints(data[i], x + 4, y + ((i-1) * 7) + (label and 10 or 3), UI_TEXT_BG, UI_TEXT_FG)
  end
end

local CraftPanel = {
  x = 240 - 78,
  y = 2,
  grid_x = 1,
  grid_y = 34,
  w = 75,
  h = 91,
  fg = 9,
  bg = 8,
  grid_bg = 8,
  grid_fg = 9,
  dock_x = 62,
  dock_y = 2,
  close_x = 68,
  close_y = 2,
  border = 9,
  vis = false,
  docked = true,
  active_tab = 3,
  current_output = 'player',
  tab = {
    [1] = {
      x = 2,
      y = 10,
      w = 24,
      h = 24,
      spr_id = LOGISTICS_ID,
      slots = {},
    },
    [2] = {
      x = 26,
      y = 10,
      w = 24,
      h = 24,
      spr_id = 390,
      slots = {},
    },
    [3] = {
      x = 50,
      y = 10,
      w = 23,
      h = 24,
      spr_id = 393,
      slots = {},
    },
    -- [3] = {
    --   x = 74,
    --   y = 2,
    --   w = 24,
    --   h = 24,
    --   spr_id = 497,
    --   slots = {},
    -- }
  }
}

CraftPanel.tab['logistics'] = CraftPanel.tab[0]
CraftPanel.tab['production'] = CraftPanel.tab[1]
CraftPanel.tab['intermediate'] = CraftPanel.tab[2]
CraftPanel.tab['combat'] = CraftPanel.tab[3]

function ui.draw_panel(x, y, w, h, bg, fg, label, shadow)
  bg, fg = bg or UI_BG, fg or UI_FG
  local text_width = print(label, 0, -10, 0, false, 1, true)
  if text_width > w + 7 then w = text_width + 7 end
  rect(x + 2, y + 2, w - 4, h - 4, bg) -- background fill
  if label then
    pal(1, fg)
    pal(8, fg)
    sspr(UI_CORNER, x, y, 0)
    sspr(UI_CORNER, x + w - 8, y, 0, 1, 1)
    pal()
    pal(1, fg)
    pal(8, bg)
    sspr(UI_CORNER, x + w - 8, y + h - 8, 0, 1, 3)
    sspr(UI_CORNER, x, y + h - 8, 0, 1, 2)
    pal()
    rect(x, y + 6, w, 3, fg) -- header lower-fill
    rect(x + 2, y + h - 3, w - 4, 1, fg) -- bottom footer fill
    rect(x + 6, y + 2, w - 12, 4, fg)--header fill
    --rect(x + 2, y + 9, w - 4, h - 12, bg) -- background fill
    prints(label, x + w/2 - text_width/2, y + 2, 0, 4) -- header text
  else
    pal(1, fg)
    sspr(UI_CORNER, x + w - 8, y + h - 8, {0, 8}, 1, 3)
    sspr(UI_CORNER, x, y + h - 8, {0, 8}, 1, 2)
    sspr(UI_CORNER, x, y, {0, 8})
    sspr(UI_CORNER, x + w - 8, y, {0, 8}, 1, 1)
    pal()
  end
  rect(x + 6, y, w - 12, 2, fg) -- top border
  rect(x, y + 6, 2, h - 12, fg) -- left border
  rect(x + w - 2, y + 6, 2, h - 12, fg) -- right border
  rect(x + 6, y + h - 2, w - 12, 2, fg) -- bottom border
  if shadow then
    --line(x + w - 1, y + 1, x + w, y + 3, shadow) -- shadow
    line(x + 4, y + h, x + w - 3, y + h, shadow) -- shadow
    line(x + w - 2, y + h - 1, x + w, y + h - 3, shadow)-- shadow
    line(x + w, y + 4, x + w, y + h - 4, shadow)-- shadow
  end
  --sspr(CLOSE_ID, x + w - 9, y + 2, 0) -- close button
end

function ui.draw_grid(x, y, rows, cols, bg, fg, size, border, rounded)
  rounded = true
  border = true
  size = size or 9
  if border then rectb(x,y,cols*size+1,rows*size+1,fg) end
  rect(x + 1, y + 1, (cols * size) - 1, (rows * size)-1, bg)
  for i = 1, cols - 1 do
    local x1 = x + i*size
    line(x1, y + 1, x1, y + (rows*size), fg)
  end
  for i = 1, rows - 1 do
    local y1 = y + i*size
    line(x + 1, y1, x + (cols*size) - 1, y1, fg)
  end
  if rounded then
    for i = 0, rows - 1 do
      for j = 0, cols  - 1 do
        local xx, yy = x + 1 + j*size, y + 1 + i*size
        --rect(xx,yy,size-1,size-1,3)
        pix(xx, yy, fg)
        pix(xx + size - 2, yy, fg)
        pix(xx + size - 2, yy + size - 2, fg)
        pix(xx, yy + size - 2, fg)
      end
    end
  end
end

function CraftPanel:draw()
  if self.vis == true then
    ui.draw_panel(self.x, self.y, self.w, self.h, 8, 9, 'Crafting', 0)
    local mouse_x, mouse_y = mouse()
    local x, y, w, h, bg, fg = self.x, self.y, self.w, self.h, self.bg, self.fg
    local active_tab, ax, ay, aw, ah = self.active_tab, self.tab[self.active_tab].x, self.tab[self.active_tab].y, 24, 24
    local tw, th = 24, 24
    --rectb(x, y, w, h, self.border)--outer border
    rect(x + 2, y + 32, w - 4, 3, fg)--fill
    rect(x + 2, y + 9, w - 5, 23, bg)--tab background area
    rect(x + ax, y + 9, tw, th, fg)--selected tab background fill
    line(x + 26, y + 9, x + 26, y + 33, fg) --tab dividers
    line(x + 50, y + 9, x + 50, y + 33, fg) --tab dividers
    sspr(UBELT_IN, x + 4, y + self.tab[1].y + 2, 0, 1) --TAB 1
    sspr(SPLITTER_ID_SMALL, x + 15, y + self.tab[1].y + 2, 0, 1) --TAB 1
    sspr(BELT_ID_STRAIGHT, x + 15, y + self.tab[1].y + 12, 0, 1, 0, 1) --TAB 1
    sspr(INSERTER_ARM_ID, x + 4, y + self.tab[1].y + 12, 15, 1, 0, 1) --TAB 1
    sspr(331, x + self.tab[2].x + 14, y + self.tab[2].y + 12, 0)-- TAB 2
    sspr(399, x + self.tab[2].x + 3, y + self.tab[2].y + 12, 0)-- TAB 2
    sspr(316, x + self.tab[2].x + 14, y + self.tab[2].y + 2, 0)-- TAB 2
    sspr(456, x + self.tab[2].x + 3, y + self.tab[2].y + 2, 0)-- TAB 2
    sspr(460, x + self.tab[3].x + 3, y + self.tab[3].y + 12, 0)-- TAb 3
    sspr(482, x + self.tab[3].x + 3, y + self.tab[3].y + 2, 0)-- TAb 3
    sspr(283, x + self.tab[3].x + 14, y + self.tab[3].y + 13, 4)-- TAb 3
    sspr(164, x + self.tab[3].x + 14, y + self.tab[3].y + 2, 4)-- TAb 3
    ui.draw_grid(x + self.grid_x, y + self.grid_y, CRAFT_ROWS, CRAFT_COLS, self.grid_bg, self.grid_fg, 9)
    for i = 1, #self.tab do
      if i ~= self.active_tab then
        local sx, sy, tx, ty, tw, th, fg = self.x, self.y, self.tab[i].x, self.tab[i].y, self.tab[i].w, self.tab[i].h, fg
        if i ~= 1 then
          pix(sx + tx + 1, sy + ty - 1, fg)
          pix(sx + tx + 1, sy + ty + th - 3, fg)
        else
          pix(sx + tx, sy + ty - 1, fg)
          pix(sx + tx, sy + ty + th - 3, fg)
        end
        pix(sx + tx + tw - 1, sy + ty - 1, fg)
        pix(sx + tx + tw - 1, sy + ty + th - 3, fg)
      end
    end
    sspr(CLOSE_ID, x + self.close_x, y + self.close_y, 15)--close button
    sspr(self.docked == true and CRAFT_ANCHOR_ID or CRAFT_ANCHOR_ID + 1, self.x + self.dock_x, self.y + self.dock_y, 15)--anchor button
    --item sprites

    for i = 1, #recipes[self.active_tab] do
      for j = 1, #recipes[self.active_tab][i] do
        local item = ITEMS[recipes[self.active_tab][i][j]]
        spr(item.sprite_id, self.x + self.grid_x + (j*9) - 9 + 1, self.y + self.grid_y + 1 + (i * 9) - 9, item.color_key)
      end
    end
    pix(x + self.grid_x + 1, y + self.grid_y + 1, self.grid_fg)
    pix(x + self.grid_x + 1, y + self.grid_y + CRAFT_ROWS * 9 - 1, self.grid_fg)
    pix(x + self.grid_x + CRAFT_COLS * 9 - 1, y + self.grid_y + CRAFT_ROWS * 9 - 1, self.grid_fg)
    pix(x + self.grid_x + CRAFT_COLS * 9 - 1, y + self.grid_y + 1, self.grid_fg)

    --Hovered-item recipe widget
    if self:is_hovered(x, y) then
      local result, sl_x, sl_y, slot_index = self:get_hovered_slot(mouse_x, mouse_y)
      if result then
        local row = math.ceil(slot_index / 10)
        local col = ((slot_index - 1) % 10) + 1
        spr(CURSOR_HIGHLIGHT, sl_x - 1, sl_y - 1, 0, 1, 0, 0, 2, 2)
        if row <= #recipes[self.active_tab] and col <= #recipes[self.active_tab][row] then
          draw_recipe_widget(mouse_x + 8, mouse_y, recipes[self.active_tab][row][col])
        end
        --print(slot_index, mouse_x + 8, mouse_y - 3, 12, false, 1, true)
      end
    end

  end
end

function CraftPanel:click(x, y, side)
  if side == 'left' then
    local result, _, _, index = self:get_hovered_slot(x, y)
    if result and self.current_output ~= 'player' then
      local row = math.ceil(index / 10)
      local col = ((index - 1) % 10) + 1
      --spr(CURSOR_HIGHLIGHT, sl_x - 1, sl_y - 1, 0, 1, 0, 0, 2, 2)
      if row <= #recipes[self.active_tab] and col <= #recipes[self.active_tab][row] then
        if self.current_output ~= 'player' then
          if ENTS[self.current_output] then
            ENTS[self.current_output]:set_recipe(ITEMS[recipes[self.active_tab][row][col]])
            toggle_crafting()
            ui.active_window = ENTS[self.current_output]:open()
            self.current_output = 'player'
            return true
          end
        end
      end
      --print(slot_index, mouse_x + 8, mouse_y - 3, 12, false, 1, true)
    end
    --close button
    local cx, cy, w, h = self.x + self.close_x, self.y + self.close_y, 5, 5
    if x >= cx and x < cx + w and y >= cy and y < cy + h then
      self.vis = false
      return true
    end
    --dock button
    local cx, cy, w, h = self.x + self.dock_x, self.y + self.dock_y, 5, 5
    if x >= cx and x < cx + w and y >= cy and y < cy + h then
      self.docked = not self.docked
      return true
    end
    --category tabs
    for i = 1, #self.tab do
      if x >= self.x + self.tab[i].x - 1 and x < self.x + self.tab[i].x + self.tab[i].w and y >= self.y + self.tab[i].y - 1 and y < self.y + self.tab[i].y - 1 + self.tab[i].h then
        self.active_tab = i
        return true
      end
    end
  end
  return false
end

function CraftPanel:is_hovered(x, y)
  if self.vis then
    return x >= self.x and x < self.x + self.w and y >= self.y and y < self.y + self.h and true or false
  end
  return false
end

function CraftPanel:get_hovered_slot(x, y)
  local grid_x, grid_y = self.x + self.grid_x, self.y + self.grid_y
  local start_x = grid_x + 1
  local start_y = grid_y + 1
  
  local rel_x = x - start_x + 1
  local rel_y = y - start_y + 1
  
  local slot_x = math.floor(rel_x / 9)
  local slot_y = math.floor(rel_y / 9)
  
  local slot_pos_x = start_x + slot_x * 9
  local slot_pos_y = start_y + slot_y * 9
  local slot_index = slot_y * 10 + slot_x + 1
  if slot_x >= 0 and slot_x <= CRAFT_COLS - 1 and slot_y >= 0 and slot_y <= CRAFT_ROWS - 1 then
    return true, slot_pos_x, slot_pos_y, slot_index
  else
    return nil
  end
end

function CraftPanel:get_hovered_slot_dyn(x, y)
  local grid_x, grid_y = self.x + self.grid_x, self.y + self.grid_y
  local start_x = grid_x + 1
  local start_y = grid_y + 1
  
  local rel_x = x - start_x + 1
  local rel_y = y - start_y + 1
  
  local slot_x = math.floor(rel_x / 9)
  local slot_y = math.floor(rel_y / 9)
  
  local slot_pos_x = start_x + slot_x * 9
  local slot_pos_y = start_y + slot_y * 9
  local slot_index = slot_y * 10 + slot_x + 1
  if slot_x >= 0 and slot_x < 10 and slot_y >= 0 and slot_y < 10 then
    if self.slots[slot_x .. '-' .. slot_y] then
      self.slots[slot_x .. '-' .. slot_y]:click()
    end
    return true, slot_pos_x, slot_pos_y, slot_index
  else
    return nil
  end
end

function ui.assembly_recipe_widget(crafter)
  
end

function ui:furnace_widget(ent)
  
end

function ui.progress_bar(progress, x, y, w, h, bg, fg, fill, option)
  --Options: 
  --0 - rounded/fancy
  --1 - square with border
  --2 - square no border
  if option == 0 then
    ui.draw_panel(x, y, w, h, bg, fg)
    --rect(x + 1, y + 1, progress * (w-2), h - 2, fill)
    -- line(x, y + 2, x, y + h - 3, fg)
    -- line(x + 1, y + 1, x + 1, y + h - 2, fg)
    -- line(x + w - 1, y + 2, x + w - 1, y + h - 3, fg)
    -- line(x + w - 2, y + 1, x + w - 2, y + h - 2, fg)
    -- rectb(x + 2, y, w - 4, h, fg)
    -- rectb(x + 2, y + 1, w - 4, h - 2, fg)
    -- rect(x + 2, y + 2, w - 4, h - 4, bg)
    -- rect(x+2, y+2, w-4, h-4, 2)
  elseif option == 1 then
    rectb(x, y, w, h, fg)
    rect(x + 1, y + 1, progress * (w-2), h - 2, fill)
    pix(x + 1, y + 1, fg)
    pix(x + 1, y + h - 2, fg)
    pix(x + w - 2, y + 1, fg)
    pix(x + w - 2, y + h - 2, fg)
    pix(x, y, bg)
    pix(x, y + h - 1, bg)
    pix(x + w - 1, y, bg)
    pix(x + w - 1, y + h - 1, bg)
  elseif option == 2 then
    rectb(x, y+1, w, h-2, fg)
    rectb(x+1, y, w-2, h, fg)
    rect(x + 1, y + 1, w-2, h - 2, bg)
    rect(x + 1, y + 1, progress * (w-2), h - 2, fill)
    pix(x + 1, y + 1, fg)
    pix(x + 1, y + h - 2, fg)
    pix(x + w - 2, y + 1, fg)
    pix(x + w - 2, y + h - 2, fg)
  end
end

function ui.NewCraftPanel(x, y)
  local new_panel = {}
  setmetatable(new_panel, {__index = CraftPanel})
  return new_panel
end

function draw_recipe_widget(x, y, id)
  local item = ITEMS[id]
  local w, h = 10, 12
  if item.recipe.ingredients then
    for k, v in ipairs(item.recipe.ingredients) do
      local str_w = print(ITEMS[v.id].name .. ' - ' .. v.count, 0, -6, 0, false, 1, true)
      if str_w > w then w = str_w + 4 end
      h = h + 6
    end
  end
  h = h + 8
  local str_w2 = print(item.name, 0, -6, 0, false, 1, true)
  if str_w2 > w then w = str_w2 + 4 end
  --local sx, sy = x - w/2, y + 8
  local sx, sy = math.max(1, math.min(x - w/2, 240 - w - 2)), y + 8
  ui.draw_panel(sx, sy, w, h + 1, 8, 9, item.fancy_name, 0)
  --box(sx, sy, w, h, 8, 9)
  --rect(sx + 1, sy + 1, w - 2, 8, 9)
  --prints(item.fancy_name, sx + 3, sy + 2, 0, 4)
  --line(sx + 1, sy + 8, sx + w - 2, sy + 8, 9)
  local i = 0
  if item.recipe.ingredients then
    for k, v in ipairs(item.recipe.ingredients) do
      prints(ITEMS[v.id].fancy_name .. ' - ' .. v.count, sx + 3, sy + 10 + (i * 6), 0, 11)
      i = i + 1
    end
    sspr(CRAFTER_TIME_ID, sx + 2, sy + h - 8, 1)
    prints(item.recipe.crafting_time/60 .. 's', sx + 12, sy + h - 8, 0, 5)
  end
end

function draw_tech_widget(x, y, id)
  local t = TECH[id]
  local w, h = print(t.name, 0, -6, 0, false, 1, true) + 8, 55
  local min_width = (#t.requirements * 9) + 8
  local strw = print(t.completed and 'Finished' or 'Progress: ' .. t.progress .. '%', 0, -10, 0, false, 1, true)
  if w < strw then w = strw + 8 end
  if w < min_width then w = min_width end
  local sx, sy = clamp(x, 1, 240 - w - 2), clamp(y, 1, 136 - h - 2)
  ui.draw_panel(sx, sy, w, h, UI_BG, UI_FG, t.name, 0)
  prints('Cost: ' .. t.requirements[1].count .. 'x', sx + 4, sy + 10)
  for k, v in ipairs(t.requirements) do
    sspr(ITEMS[v.id].sprite_id, sx + 4 + ((k-1)*9), sy + 17, ITEMS[v.id].color_key)
  end
  prints('Unlocks:', sx + 4, sy + 27)
  for k, v in ipairs(t.unlocks) do
    sspr(ITEMS[v].sprite_id, sx + 4 + ((k-1)*9), sy + 34, ITEMS[v].color_key)
  end
  prints((t.completed and 'Finished') or ('Progress: ' .. floor(100* t.progress/t.requirements[1].count) .. '%'), sx + 4, sy + 44)
end

function ui.check_input(c)
  local x, y, l, m, r, sx, sy, lx, ly, ll, lm, lr, lsx, lsy = c.x, c.y, c.l, c.m, c.r, c.sx, c.sy, c.lx, c.ly, c.ll, c.lm, c.lr, c.lsx, c.lsy
  for k, v in pairs(self.windows) do
    if v.vis and v:is_hovered(x, y) then
      return true
    end
  end
  return false
end

function rectr(x,y,w,h,bg,fg,b)
  --draws a box with 4-interior pixels (rounded look) with or without outer border
  b=false
  local offset = 0
  if b then
    offset=1
    rectb(x,y,w,h,fg)
    rect(x+1,y+1,w-2,h-2,bg)
    pix(x+1,y+1,fg)
    pix(x+w-2,y+1,fg)
    pix(x+w-2,y+h-2,fg)
    pix(x+1,y+h-2,fg)
  else
    rect(x,y,w,h,bg)
    pix(x,y,fg)
    pix(x+w-1,y,fg)
    pix(x+w-1,y+h-1,fg)
    pix(x,y+h-1,fg)
  end
end

function tspr(sprite_id, tile_w, tile_h, sx, sy, ck, width, height)
  if not width then width, height = tile_w*8, tile_h*8 end
  -- Calculate the sprite's UV coordinates
  local spriteX = sprite_id % 16 * 8
  local spriteY = math.floor(sprite_id / 16) * 8
  -- Calculate the width and height in pixels
  local spw = tile_w * 8
  local sph = tile_h * 8
  -- Draw the sprite using two textured triangles
  ttri(
    sx, sy, 
    sx + width, sy, 
    sx, sy + height, 
    spriteX, spriteY, 
    spriteX + spw, spriteY, 
    spriteX, spriteY + sph,
    sprite_id < 256 and 1 or 0, ck  )
  
  ttri(
    sx + width, sy, 
    sx, sy + height, 
    sx + width, sy + height, 
    spriteX + spw, spriteY, 
    spriteX, spriteY + sph, 
    spriteX + spw, spriteY + sph,
    sprite_id < 256 and 1 or 0, ck
  )
end

function get_hovered_slot(x, y, grid_x, grid_y, grid_size, rows, cols)
  local rel_x = x - grid_x
  local rel_y = y - grid_y
  
  local slot_x = math.floor(rel_x / grid_size)
  local slot_y = math.floor(rel_y / grid_size)
  
  local slot_pos_x = grid_x + slot_x * grid_size
  local slot_pos_y = grid_y + slot_y * grid_size
  local slot_index = slot_y * rows + slot_x + 1
  if slot_x >= 0 and slot_x < cols and slot_y >= 0 and slot_y < rows then
    return {x = slot_pos_x, y = slot_pos_y, index = slot_index}
  else
    return nil
  end
end