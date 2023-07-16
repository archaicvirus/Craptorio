CRAFT_ANCHOR_ID = 435
CLOSE_ID = 437
CRAFT_ROWS = 6
CRAFT_COLS = 8
UI_CORNER = 352
LOGISTICS_ID = 387
UI_BG = 8
UI_FG = 9
UI_TEXT_BG = 0
UI_TEXT_FG = 4
UI_SHADOW = 0
UI_ARROW = 353
UI_BUTTON = 356
UI_PAUSE = 354
UI_CLOSE = 355
UI_BUTTON2 = 113
BTN_MAIN = 12
BTN_SHADOW = 2
BTN_HOVER = 11
BTN_PRESS = 4
--TODO: move all main ui windows here
ui = {
  windows = {},
  active_window = false,
  alerts = {}
}

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
    ui.draw_panel(self.x, self.y, self.w, self.h, 8, 9, 'Crafting', UI_BG)
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
    sspr(482, x + self.tab[3].x + 3, y + self.tab[3].y + 2, 1)-- TAb 3
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
        if UNLOCKED_ITEMS[recipes[self.active_tab][i][j]] then
          spr(item.sprite_id, self.x + self.grid_x + (j*9) - 9 + 1, self.y + self.grid_y + 1 + (i * 9) - 9, item.color_key)
        end
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
        ui.highlight(sl_x - 2, sl_y - 1, 8, 8, false, 3, 4)
        --spr(CURSOR_HIGHLIGHT, sl_x - 1, sl_y - 1, 0, 1, 0, 0, 2, 2)
        local id = recipes[self.active_tab][row][col]
        --if row <= #recipes[self.active_tab] and col <= #recipes[self.active_tab][row] and ITEMS[].craftable and  then
        if UNLOCKED_ITEMS[id] then
          draw_recipe_widget(mouse_x + 8, mouse_y, recipes[self.active_tab][row][col])
        end
        --print(slot_index, mouse_x + 8, mouse_y - 3, 12, false, 1, true)
      end
    end

  end
end

function CraftPanel:click(x, y, side)
  if side == 'left' and not cursor.ll then
    local result, sx, sy, index = self:get_hovered_slot(x, y)
    if result and self.current_output ~= 'player' then
      local row = math.ceil(index / 10)
      local col = ((index - 1) % 10) + 1
      --spr(CURSOR_HIGHLIGHT, sl_x - 1, sl_y - 1, 0, 1, 0, 0, 2, 2)
      if row <= #recipes[self.active_tab] and col <= #recipes[self.active_tab][row] then
        if self.current_output ~= 'player' then
          --assembly machine crafting
          if ENTS[self.current_output] then
            if not ITEMS[recipes[self.active_tab][row][col]].craftable then sound('deny') return end
            ENTS[self.current_output]:set_recipe(ITEMS[recipes[self.active_tab][row][col]])
            toggle_crafting()
            ui.active_window = ENTS[self.current_output]:open()
            self.current_output = 'player'
            return true
          end
        else

        end
      end
      --print(slot_index, mouse_x + 8, mouse_y - 3, 12, false, 1, true)
    elseif result and self.current_output == 'player' then
      local row = math.ceil(index / 10)
      local col = ((index - 1) % 10) + 1
      if row <= #recipes[self.active_tab] and col <= #recipes[self.active_tab][row] then
        --player crafting
        local item = ITEMS[recipes[self.active_tab][row][col]]
        trace('found item: ' .. item.fancy_name)
        if item and item.craftable then
          local can_craft = true
          for k, v in ipairs(item.recipe.ingredients) do
            if not inv:has_stack(v) then can_craft = false end
          end
          if can_craft then
            for k, v in ipairs(item.recipe.ingredients) do
              inv:remove_stack(v)
            end
            inv:add_item({id = item.id, count = item.recipe.count})
          end
        end
      end
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

function text_width(txt)
  return print(txt, 0, -10, 0, false, 1, true)
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
  local craft_time = (item.recipe and (item.recipe.crafting_time or item.smelting_time)/60 .. 's') or 'Uncraftable'
  local cw = print(craft_time, 0, -10, 0, false, 1, true)
  if item.recipe then
    if item.recipe.ingredients then
      for k, v in ipairs(item.recipe.ingredients) do
        local str_w = print(ITEMS[v.id].fancy_name .. ' - ' .. v.count, 0, -6, 0, false, 1, true)
        if str_w > w then w = str_w + 5 end
        h = h + 9
      end
    end
    h = h + 16
    local str_w2 = print(item.name, 0, -6, 0, false, 1, true)
    if str_w2 > w then w = str_w2 + 8 end
    if cw > w then w = cw + 8 end
    --local sx, sy = x - w/2, y + 8
    local sx, sy = clamp(x, 1, 240 - (w + 2)), clamp(y, 1, 136 - (h+2))
    ui.draw_panel(sx, sy, w, h + 1, 8, 9, item.fancy_name, 0)
    --box(sx, sy, w, h, 8, 9)
    --rect(sx + 1, sy + 1, w - 2, 8, 9)
    --prints(item.fancy_name, sx + 3, sy + 2, 0, 4)
    --line(sx + 1, sy + 8, sx + w - 2, sy + 8, 9)
    local i = 0
    if item.recipe.ingredients then
      for k, v in ipairs(item.recipe.ingredients) do
        prints(ITEMS[v.id].fancy_name, sx + 3, sy + 10 + (i * 11), 0, 4)
        draw_item_stack(sx + w-13, sy + 10 + ((k-1) * 11), v, show_cnt)
        i = i + 1
      end
      sspr(CRAFTER_TIME_ID, sx + 2, sy + h - 8, 1)
      prints(craft_time, sx + 12, sy + h - 8, 0, 5)
    end
  else
    w = print(item.fancy_name, 0, -10, 1, false, 1, true) + 6
    local w2 = print('Uncraftable', 0, -10, 1, false, 1, true)
    if w2 + 6 > w then w = w2 + 6 end
    local sx, sy = math.max(1, math.min(x - w/2, 240 - w - 2)), y + 8
    ui.draw_panel(sx, sy, w, 23, 8, 9, item.fancy_name, 0)
    prints('Uncraftable', sx + 4, sy + 12, 0, 2)
  end
end

function draw_tech_widget(x, y, id)
  local t = TECH[id]
  local w, h = print(t.name, 0, -6, 0, false, 1, true) + 8, 55
  local min_width = (#t.science_packs * 9) + 8
  if w < min_width + 8 then w = min_width + 8 end
  local progress = (t.completed and 'Finished') or ('Progress: ' .. floor(100* t.progress/t.science_packs[1].count) .. '%')
  local prog = print(progress, 0, -10, 0, false, 1, true)
  if w < prog + 8 then w = prog + 8 end
  local sx, sy = clamp(x, 1, 240 - w - 2), clamp(y, 1, 136 - h - 2)
  ui.draw_panel(sx, sy, w, h, UI_BG, UI_FG, t.name, 0)
  prints('Cost: ' .. t.science_packs[1].count .. 'x', sx + 4, sy + 10)
  for k, v in ipairs(t.science_packs) do
    sspr(ITEMS[v.id].sprite_id, sx + 4 + ((k-1)*9), sy + 17, ITEMS[v.id].ck)
  end
  prints('Unlocks:', sx + 4, sy + 27)
  for k, v in ipairs(t.item_unlocks) do
    sspr(ITEMS[v].sprite_id, sx + 4 + ((k-1)*9), sy + 34, ITEMS[v].color_key)
  end
  prints(progress, sx + 4, sy + 44)
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

function rotatePoint(cx, cy, angle, px, py)
  local s = math.sin(angle)
  local c = math.cos(angle)

  -- translate point back to origin:
  px = px - cx
  py = py - cy

  -- rotate point
  local xnew = px * c - py * s
  local ynew = px * s + py * c

  -- translate point back
  px = xnew + cx
  py = ynew + cy

  return px, py
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
    ck
  )
  
  ttri(
    sx + width, sy, 
    sx, sy + height, 
    sx + width, sy + height, 
    spriteX + spw, spriteY, 
    spriteX, spriteY + sph, 
    spriteX + spw, spriteY + sph,
    ck
  )
end

function rspr(id, x, y, rot, tw, th, w, h, ck, page)
  -- Convert rotation angle from degrees to radians
  local rotationRadians = -math.rad(rot) -- negating the angle to make the rotation clockwise

  -- Center of the sprite
  local cx, cy = x + w / 2, y + h / 2

  -- Size of the sprite in the sprite data
  local sw, sh = tw * 8, th * 8

  -- Iterate through the screen positions where we want to draw the sprite
  for sy = y, y + h - 1 do
      for sx = x, x + w - 1 do
          -- Translate screen coordinates to origin
          local ox, oy = sx - cx, sy - cy

          -- Rotate the screen coordinate
          local rx = ox * math.cos(rotationRadians) - oy * math.sin(rotationRadians)
          local ry = ox * math.sin(rotationRadians) + oy * math.cos(rotationRadians)

          -- Translate back
          local finalX, finalY = rx + cx, ry + cy

          -- Map to sprite UV
          local su = math.floor((finalX - x) / w * sw)
          local sv = math.floor((finalY - y) / h * sh)

          -- Check if the UV is within sprite range
          if su >= 0 and su < sw and sv >= 0 and sv < sh then
              -- Get the pixel from the sprite data
              local pixelIndex = sv * sw + su + 1
              local pixel = sprites[page][id][pixelIndex]

              -- Skip if it's a color key
              if pixel and (type(ck) == "table" and not ck[pixel] or pixel ~= ck) then
                  -- Calculate VRAM address
                  local addr = 0x0000 + math.floor(sy * 240 + sx) // 2

                  -- Write pixel to VRAM
                  local cur = peek(addr) or 0
                  if sx % 2 == 0 then
                      cur = (cur & 0x0F) | (pixel << 4)
                  else
                      cur = (cur & 0xF0) | pixel
                  end
                  poke(addr, cur)
              end
          end
      end
  end
end

function get_hovered_slot(x, y, grid_x, grid_y, grid_size, rows, cols)
  local start_x = grid_x
  local start_y = grid_y  
  local rel_x = x - start_x
  local rel_y = y - start_y  
  local slot_x = math.floor(rel_x / grid_size)
  local slot_y = math.floor(rel_y / grid_size)  
  local slot_pos_x = start_x + slot_x * grid_size
  local slot_pos_y = start_y + slot_y * grid_size
  local slot_index = slot_y * cols + slot_x + 1
  if slot_x >= 0 and slot_x < cols and slot_y >= 0 and slot_y < rows then
    return {x = slot_pos_x, y = slot_pos_y, index = slot_index}
  else
    return nil
  end
end

function ui.highlight(x, y, w, h, animate, color1, color2)
  pal({1,color1,2,color2})
  local offset = (animate and floor(player.anim_frame/4)) or 0
    sspr(CURSOR_HIGHLIGHT_CORNER_S, x + offset, y - 1 + offset, 0)
    sspr(CURSOR_HIGHLIGHT_CORNER_S, x + (w - 4) - offset, y - 1 + offset, 0, 1, 1, 0)
    sspr(CURSOR_HIGHLIGHT_CORNER_S, x + (w - 4) - offset, y + (h - 5) - offset, 0, 1, 3, 0)
    sspr(CURSOR_HIGHLIGHT_CORNER_S, x + offset, y + (h - 5) - offset, 0, 1, 2, 0)
  pal()
end

function ui.draw_button(x, y, flip, id, color, shadow_color, hover_color)
  color, shadow_color, hover_color = color or 12, shadow_color or 0, hover_color or 11
  local _mouse, _box, ck, p = {x = cursor.x, y = cursor.y}, {x = x, y = y, w = 8, h = 8}, 1, {4, color, 2, shadow_color, 12, color}
  local hov = hovered(_mouse, _box)
  if hov and not cursor.l then
    p = {2, shadow_color, 12, hover_color, 4, hover_color}
  elseif hov and cursor.l then
    p = {2, hover_color, 12, hover_color, 4, hover_color}
    ck = {1, 4}
  end
  pal(p)
  spr(id, x, y, ck, 1, flip)
  pal()
  if hov and cursor.l and not cursor.ll then return true end
  return false
end

function ui.draw_text_button(x, y, id, width, height, main_color, shadow_color, hover_color, label)
  width, height = width or 8, height or 8
  main_color, shadow_color, hover_color = main_color or BTN_MAIN, shadow_color or UI_SHADOW, hover_color or BTN_HOVER
  if label then
    local w = text_width(label.text)
    if w  + 2 > width then
      width = w + 2
    end
  end
  local _mouse, _box, ck, p = {x = cursor.x, y = cursor.y}, {x = x, y = y, w = width, h = height}, 1, {BTN_PRESS, main_color, BTN_SHADOW, shadow_color, BTN_MAIN, main_color}
  local hov = hovered(_mouse, _box)
  if hov and not cursor.l then
    p = {BTN_SHADOW, shadow_color, BTN_MAIN, hover_color, BTN_PRESS, hover_color}
  elseif hov and cursor.l then
    p = {BTN_SHADOW, hover_color, BTN_MAIN, hover_color, BTN_PRESS, hover_color}
    ck = {1, BTN_PRESS}
  end

  if not main_color == BTN_MAIN and not shadow == BTN_SHADOW and not hover_color == BTN_HOVER then
  else
  end


  local lines = {
    [1] = {x1 =  x, y1 = y + height, x2 =  x + width, y2 = y + height},
    [2] = {x1 =  x, y1 = y, x2 =  x + width, y2 = y}
  }
  --trace('filling mesh')
  --mesh_fill(lines, id, ck)
  if label and width > 8 then
    if hov and not cursor.l then
      rect(x + 4, y, width - 8, height - 1, hover_color)
      line(x + 4, y + height - 1, x + width - 4, y + height - 1, shadow_color)
    elseif hov and cursor.l then
      rect(x + 4, y + 1, width - 8, height - 1, hover_color)
      label.y = label.y + 1
    else
      rect(x + 4, y, width - 8, height - 1, main_color)
      line(x + 4, y + height - 1, x + width - 4, y + height - 1, shadow_color)
    end
  end
  pal(p)
  spr(id, x, y, ck, 1, 0)
  spr(id, x + width - 8, y, ck, 1, 1)
  pal()

  if label then
    prints(label.text, x + label.x, y + label.y, label.bg, label.fg, label.shadow)
  end

  if hov and cursor.l and not cursor.ll then return true end
  return false
end

function ui.new_slider(x, y, value, min, max, step, width, height, ditch_color, handle_color, shadow_color)
  local slider = {
    x = x,
    y = y,
    value = value,
    min = min,
    max = max,
    step = step,
    width = width,
    height = height,
    ditch_color = ditch_color or 13,
    handle_color = handle_color or 12,
    shadow_color = shadow_color or 15,
  }
  slider.draw = function(self)
    line(self.x, self.y + 1, self.x + self.width - 1, self.y + 1, self.ditch_color)
    line(self.x + 1, self.y + 2, self.x + self.width - 1, self.y + 2, self.shadow_color)
    local x, y = remap(self.value, self.min, self.max, self.x, self.x + self.width - 1), self.y
    -- line(x, y, x, y + 2, 14)
    -- line(x + 1, y, x + 1, y + 2, 12)
    -- line(x + 2, y, x + 2, y + 2, 15)
    circ(x+1, y+2, 2, self.shadow_color)
    circ(x, y+1, 2, 12)
    local text = self.step >= 1 and floor(self.value) or round(self.value, 2)
    prints(text, self.x + self.width + 15 - (text_width(text)/2), self.y - 1)
  end
  setmetatable(slider, {__index = slider})
  return slider
end

function ui.draw_toggle(x, y, value, size)
  local mx, my = cursor.x, cursor.y
  local hov = hovered({x = mx, y = my}, {x = x, y = y - 1, w = (text_width(value)) + 12, h = 7})
  if value then
    circ(x + 4, y + 2, size, 2)
  end
  circb(x + 4, y + 2, size, 0)  
  return value
end

function draw_research_icon(id, x, y)
  for k, v in ipairs(TECH[id].sprite) do
    local offset = v.offset or {x=0,y=0}
    local sprite = v
    --rspr(v.id,3+offset.x,12+offset.y,v.rot,v.tw,v.th,v.w,v.h,v.ck,v.page)
    pokey(v.page, v.id, v.tw, v.th, x + offset.x, y + offset.y, v.ck, v.rot)
  end
  if TECH[id].tier then
    rect(x + 19, y + 17, 5, 7, 9)
    prints(TECH[id].tier, x + 20, y + 18, 15, 4, {x = 1, y = 0})
  end
end

function draw_research_screen()
  cls(UI_FG)
  local AVAILABLE_TECH = AVAILABLE_TECH
  local F_TECH = {}
  for k, v in ipairs(FINISHED_TECH) do
    if v then table.insert(F_TECH, k) end
  end
  -- for k, v in ipairs(TECH) do
  --   if AVAILABLE_TECH[k] then table.insert(AVAILABLE_TECH, v) end
  -- end
  local sw = print('Technology Tree',0,-10,0,false,1,true)
  local name = (current_tab and TECH[AVAILABLE_TECH[selected_research]] and TECH[AVAILABLE_TECH[selected_research]].name) or (not current_tab and TECH[F_TECH[selected_research]] and TECH[F_TECH[selected_research]].name or 'Select-a-Tech')
  local rw = print(name,0,-10,0,false,1,true)
  local rsw = print('Research', 0, -10, 0, false, 1, false)/2
  local lpw = 101
  local lph = 57
  -----------MAIN PANEL-------------------
  ui.draw_panel(0, 0, 240, 136, UI_FG, UI_FG)
  -------SELECTED TECH HEADER-------------------
  prints(name, 4 + lpw/2 - rw/2, 1)
  rectr(2, 8, lpw - 3, lph - 14, UI_BG, UI_FG, false)
  if ui.draw_button(2, lph - 6, 0, UI_BUTTON, 2, 0, 3) then
    current_tab = not current_tab
  end
  if current_tab then
    prints('Available Tech', 12, lph - 4)
  else
    prints('Known Tech', 12, lph - 4)
  end
  ----------CURRENT PAGE--------------------------------------------
  if ui.draw_button((lpw/2) - (rsw/2) + 29, lph - 5, 1, UI_ARROW, 12, 0, 4) then
    current_page = clamp(current_page - 1, 1, math.ceil(current_tab and #AVAILABLE_TECH/12 or #F_TECH/12))
  end
  if ui.draw_button((lpw/2) - (rsw/2) + 56, lph - 5, 0, UI_ARROW, 12, 0, 4) then
    current_page = clamp(current_page + 1, 1, math.ceil(current_tab and #AVAILABLE_TECH/12 or #F_TECH/12))
  end
  prints(current_page .. '/' .. math.ceil(#TECH/12), (lpw/2) - (rsw/2) + 41, lph - 4, 0)  
  ----------RESEARCH QUEUE------------------------------
  prints('Research Queue', (240 - lpw)/2 + lpw - sw/2, 1)
  --research queue grid
  ui.draw_grid(lpw + 6, 8, 1, 7, UI_BG, UI_FG, 17, false)
  --queue item icons
  -- for i = 1, 7 do
  --   tspr(392, 3, 3, lpw + 7 + ((i-1)*17), 8, 0, 16, 16)
  -- end

  --------------TECH TREE------------------------------
  rectr(lpw + 2, 36, 135, 98, UI_BG, UI_FG, false)
  prints('Technology Tree', (240 - lpw)/2 + lpw - sw/2, 29)
  ----------------SELECTED TECH PANEL--------------------------
  if current_tab and selected_research then
    --research progress bar
    if not TECH[AVAILABLE_TECH[selected_research]].completed then
      local progress = TECH[AVAILABLE_TECH[selected_research]].progress --TECH[AVAILABLE_TECH[selected_research]].science_packs[1].count
      ui.progress_bar(progress, 29, 10, 69, 5, 0, UI_FG, 6, 2)
    else
      prints('Finished', 29, 10)
    end
    
    --start/pause research button
    if current_research == selected_research then
      if ui.draw_button(lpw - 11, lph - 15, 0, UI_PAUSE, 12, 0, 4) then
        current_research = false
      end
    elseif current_research ~= selected_research then
      if ui.draw_button(lpw - 11, lph - 15, 0, UI_ARROW, 12, 0, 4) then
        current_research = selected_research
      end
    end
    local cost_w = print(TECH[AVAILABLE_TECH[selected_research]].science_packs[1].count .. 'x - ', 0, -10, 1, false, 1, true)
    prints(TECH[AVAILABLE_TECH[selected_research]].science_packs[1].count .. 'x -', 30, 19)
    --available research icons
    --timer sprite & text
    sspr(CRAFTER_TIME_ID, 30 + cost_w, 18, 1)
    prints(TECH[AVAILABLE_TECH[selected_research]].time .. 's', 30 + cost_w + 8, 19, 0, 6)
    --item unlocks
    prints('Unlocks:', 4, 42)
    for k, v in ipairs(TECH[AVAILABLE_TECH[selected_research]].item_unlocks) do
      sspr(ITEMS[v].sprite_id, 35 + ((k-1)*9), 40, ITEMS[v].color_key)
    end
    --current research icon
    draw_research_icon(AVAILABLE_TECH[selected_research], 3, 8)
    for k, v in ipairs(TECH[AVAILABLE_TECH[selected_research]].science_packs) do
      sspr(ITEMS[v.id].sprite_id, 30 + (k-1)*8, 28, ITEMS[v.id].ck)
    end
  end
  
  --------------AVAILABLE or FINISHED TECH GRID PANEL----------------------
  ui.draw_grid(1, lph + 2, 3, 4, UI_BG, UI_FG, 25, false)
  local i = 1
  for y = 0, 2 do
    for x = 0, 3 do
      --rect(2 + x*25, lph + 3 + y*25, 24, 24, 2)
      local index = current_tab and AVAILABLE_TECH[i] or not current_tab and F_TECH[i]
      -- if F_TECH[i] then
      --   trace('found FINISHED_TECH - ' .. tostring(F_TECH[i]))
      -- end
      if index then
        draw_research_icon(index, 2+x*25, lph+3+y*25)
        if current_tab and AVAILABLE_TECH[i] and i == current_research then
          ui.highlight(x*25, lph + y*25 + 2, 24, 24, true, 3, 4)
        end
      end
      i = i + 1
    end
  end
  --check available research hover
  local slot = get_hovered_slot(cursor.x, cursor.y, 1, 59, 25, 3, 4)
  if slot then
    local index = current_tab and AVAILABLE_TECH[slot.index] or F_TECH[slot.index]
    ui.highlight(slot.x - 1, slot.y, 24, 24, false, 3, 4)
    if not index then return end
    draw_tech_widget(cursor.x + 5, cursor.y + 5, index)
    if current_tab and cursor.l and not cursor.ll then
      if index then
        selected_research = slot.index
      else
        selected_research = false
      end
      if not current_research then

      elseif current_research ~= slot.index then
        --todo: add to queue
      end
    end
    --todo: draw hover widget
  end

  --------MOUSE HOVER/CLICK EVENTS---------------------------
  slot = get_hovered_slot(cursor.x, cursor.y, 107, 8, 17, 1, 7)
  if slot then
    ui.highlight(slot.x-1, slot.y, 16, 16, false, 3, 4)
  end
  if selected_research then
    slot = get_hovered_slot(cursor.x, cursor.y, 34, 39, 9, 1, #TECH[AVAILABLE_TECH[selected_research]].item_unlocks)
    if slot then
      ui.highlight(slot.x-1, slot.y, 8, 8, false, 3, 4)
      draw_recipe_widget(cursor.x + 5, cursor.y + 5, TECH[AVAILABLE_TECH[selected_research]].item_unlocks[slot.index])
    end
    slot = get_hovered_slot(cursor.x, cursor.y, 29, 28, 8, 1, #TECH[AVAILABLE_TECH[selected_research]].science_packs)
    if slot then
      ui.highlight(slot.x-1, slot.y-1, 8, 8, false, 3, 4)
      draw_recipe_widget(cursor.x + 5, cursor.y + 5, TECH[AVAILABLE_TECH[selected_research]].science_packs[slot.index].id)
    end
  end
end

function update_research_progress()
  if not current_research then return false end
  local tech = TECH[AVAILABLE_TECH[current_research]]
  local frac = 1 / tech.science_packs[1].count
  if tech.progress < 1.0 then
    tech.progress = tech.progress + frac
    if tech.progress >= 1.0 then
      tech.completed = true
      for k, v in ipairs(tech.item_unlocks) do
        UNLOCKED_ITEMS[v] = true
      end
      for k, v in ipairs(tech.tech_unlocks) do
        table.insert(AVAILABLE_TECH, v)
      end
      local tid = AVAILABLE_TECH[current_research]
      FINISHED_TECH[AVAILABLE_TECH[current_research]] = true
      table.remove(AVAILABLE_TECH, current_research)
      trace('tid: ' .. tid)
      for k, v in ipairs(TECH) do
        for j, u in ipairs(v.required_tech) do
          if tid == u then
            local n = 0
            for i, m in ipairs(v.required_tech) do
              if FINISHED_TECH[m] then
                n = n + 1
              end
            end
            if n == #v.required_tech then
              trace('tech requirements met! adding : ' .. TECH[k].name)
              table.insert(AVAILABLE_TECH, k)
              break
            end
          end
        end
      end
      current_research = false
      selected_research = false
    end
    return true
  end
  return false
end

function draw_chest_inventory(chest)
  --ui.drawpanel()
end

function draw_image(x, y, width, height, pixel_data, color_key)
  color_key = color_key or -1
  for i = 0, width - 1 do
    for j = 0, height - 1 do
      local index = j * width + i
      if pixel_data[index] ~= color_key then
        pix(x + i, y + j, pixel_data[index])
      end
    end
  end
end

function draw_logo()
  draw_image(0, 0, 240, 136, cover, 1)
end

function ui.draw_menu()
  cls(0)
  --ui.draw_panel(40, 40, 160, 76, 8, 9)
  if  STATE == 'start' then
    draw_logo()
    if ui.draw_text_button(120 - ((text_width('  Start  ') + 2) /2), 100, UI_BUTTON2, _, 8, 9, 0, 10, {text = '  Start  ', x = 1, y = 1, bg = 0, fg = 4, shadow = {x = 1, y = 0}}) then
      STATE = 'game'
    end

    if ui.draw_text_button(120 - ((text_width('  Settings  ') + 2) /2), 110, UI_BUTTON2, _, 8, 9, 0, 10, {text = '  Settings  ', x = 1, y = 1, bg = 0, fg = 4, shadow = {x = 1, y = 0}}) then
      STATE = 'settings'
    end
  elseif STATE == 'settings' then
    ui.draw_panel(0, 0, 240, 136, 8, 9, 'Settings')
    if ui.draw_text_button(239 - ((text_width('  Back  ') + 2)), 1, UI_BUTTON2, _, 8, 2, 0, 3, {text = ' Back ', x = 1, y = 1, bg = 0, fg = 4, shadow = {x = 1, y = 0}}) then
      STATE = 'start'
    end
  end
end

function ui.new_alert(sx, sy, text, duration, bg, fg)
  local alert = {
    x = sx,
    y = sy,
    text = text,
    duration = duration or 3000,
    bg = bg or UI_TEXT_BG,
    fg = fg or UI_TEXT_FG,
    start = time()
  }
  table.insert(ui.alerts, alert)
end

function ui.update_alerts()
  local trash = {}
  for k, alert in ipairs(ui.alerts) do
    local t = time()
    if t < alert.start + alert.duration then
      local y = alert.y - remap(t, alert.start, alert.start + alert.duration, 0, 20)
      prints(alert.text, alert.x, y, alert.bg, alert.fg)
    else
      table.insert(trash, k)
      alert = nil
    end
  end
  for i = 1, #trash do
    table.remove(ui.alerts, trash[i])
  end
end