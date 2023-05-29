CRAFT_ANCHOR_ID = 435
CLOSE_ID = 437

ui = {windows = {}}

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

function ui.draw_text_window(data, x, y, border, background, text)
  border, background, text = border or 10, background or 8, text or 11
  local width = 4
  local height = #data * 7 + 3
  for i = 1, #data do
    local string_width = print(data[i], 0, -10, 0, true, 1, true)
    if string_width > width then width = string_width end
  end
  width = width + 4
  rectb(x, y, width, height, border)
  rect(x + 1, y + 1, width - 2, height - 2, background)
  for i = 1, #data do
    print(data[i], x + 2, y - 5 + i*7, text, true, 1, true)
  end
end

local CraftPanel = {
  x = 70,
  y = 23,
  grid_x = 4,
  grid_y = 26,
  w = 100,
  h = 84,
  fg = 9,
  bg = 8,
  grid_bg = 8,
  grid_fg = 9,
  border = 12,
  vis = false,
  docked = true,
  active_tab = 0,
  current_output = 'player',
  tab = {
    [0] = {
      x = 2,
      y = 2,
      w = 22,
      h = 22,
      spr_id = 387,
      slots = {},
    },
    [1] = {
      x = 25,
      y = 2,
      w = 20,
      h = 22,
      spr_id = 390,
      slots = {},
    },
    [2] = {
      x = 45,
      y = 2,
      w = 23,
      h = 22,
      spr_id = 393,
      slots = {},
    },
    [3] = {
      x = 69,
      y = 2,
      w = 22,
      h = 22,
      spr_id = 497,
      slots = {},
    }
  }
}

CraftPanel.tab['logistics'] = CraftPanel.tab[0]
CraftPanel.tab['production'] = CraftPanel.tab[1]
CraftPanel.tab['intermediate'] = CraftPanel.tab[2]
CraftPanel.tab['combat'] = CraftPanel.tab[3]

function CraftPanel:draw()
  if self.vis == true then
    local mouse_x, mouse_y = mouse()
    local x, y, w, h, active_tab, ax, ay, aw, ah = self.x, self.y, self.w, self.h, self.active_tab, self.tab[self.active_tab].x, self.tab[self.active_tab].y, self.tab[self.active_tab].w, self.tab[self.active_tab].h
    --outer border
    rectb(x, y, w, h, self.border)

    --fill
    rect(x + 1, y + 1, w - 2, h - 2, self.fg)

    --tab background area
    rect(x + 1, y + 1, w - 2, 23, self.bg)

    --bottom tab divider
    line(x, y + 23, x + w - 1, y + 23, self.border)

    --selected tab background fill
    rect(ax + x - 1, ay + y - 1, aw + 1, ah + 2, self.fg)

    --right divider for selected tab
    line(x + ax + aw, y + ay - 1, x + ax + aw, y + ay + ah - 1, self.border)
    --left divider
    if active_tab > 0 then
      line(x + ax - 1, y + ay - 1, x + ax - 1, y + ay + ah - 1, self.border)
    end

    --close button
    sspr(CLOSE_ID, x + w - 7, y + 2, 0)
    -- rect(self.x + self.w - 6, self.y + 1, 5, 6, 2)
    -- print('x', self.x + self.w - 5, self.y + 1, 0, false, 1, true)

    --anchor button
    sspr(self.docked == true and CRAFT_ANCHOR_ID or CRAFT_ANCHOR_ID + 1, self.x + self.w - 7, self.y + 8, 15)

    --Sprites for tab images
    for i = 0, 3 do
      if i < 3 then
        sspr(self.tab[i].spr_id, self.tab[i].x + x, self.tab[i].y + y, 1, 1, 0, 0, 3, 3)
      else
        sspr(self.tab[i].spr_id, self.tab[i].x + x + 3, self.tab[i].y + y + 2, 0, 2.5, 0, 0, 1, 1)
      end
    end
    --spr(self.tab[3].spr_id, self.tab[3].x + x + 1, self.tab[3].y + y, 6, 1, 0, 0, 3, 3)

    --Crafting grid-------------------------------

    --Grid background (grid lines)
    --rect(self.x + 4, self.y + 26, self.w - 8, self.h - 28, 14)

    --grid tiles
    for i = 1, 10 do
      for j = 1, 6 do
        rect(self.x + 5 + (i*9) - 9, self.y + 27 + (j*9) - 9, 8, 8, 8)
      end
    end
    
    --item sprites

    for i = 1, #recipes[self.active_tab] do
      for j = 1, #recipes[self.active_tab][i] do
        spr(ITEMS[recipes[self.active_tab][i][j]].sprite_id, self.x + self.grid_x + (j*9) - 9 + 1, self.y + self.grid_y + 1 + (i * 9) - 9, 0)
      end
    end


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
            window = ENTS[self.current_output]:open()
            self.current_output = 'player'
            return true
          end
        end
      end
      --print(slot_index, mouse_x + 8, mouse_y - 3, 12, false, 1, true)
    end
    --close button
    local cx, cy, w, h = self.x + self.w - 6, self.y + 1, 5, 6
    if x >= cx and x < cx + w and y >= cy and y < cy + h then
      self.vis = false
      return true
    end
    --dock button
    local cx, cy, w, h = self.x + self.w - 6, self.y + 8, 5, 8
    if x >= cx and x < cx + w and y >= cy and y < cy + h then
      self.docked = not self.docked
      return true
    end
    --category tabs
    for i = 0, 3 do
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
  if slot_x >= 0 and slot_x < 10 and slot_y >= 0 and slot_y < 10 then
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

function ui.NewCraftPanel(x, y)
  local new_panel = {x = x, y = y}
  setmetatable(new_panel, {__index = CraftPanel})
  return new_panel
end

function draw_recipe_widget(x, y, id)
  local item = ITEMS[id]
  local w, h = 10, 12
  for k, v in ipairs(item.recipe.ingredients) do
    local str_w = print(ITEMS[v.id].name .. ' - ' .. v.count, 0, -6, 0, false, 1, true)
    if str_w > w then w = str_w + 4 end
    h = h + 6
  end
  h = h + 8
  local str_w2 = print(item.name, 0, -6, 0, false, 1, true)
  if str_w2 > w then w = str_w2 + 2 end
  --local sx, sy = x - w/2, y + 8
  local sx, sy = math.max(1, math.min(x - w/2, 240 - w - 2)), y + 8
  box(sx, sy, w, h, 8, 9)
  rect(sx + 1, sy + 1, w - 2, 8, 9)
  prints(item.fancy_name, sx + 3, sy + 2, 0, 4)
  line(sx + 1, sy + 8, sx + w - 2, sy + 8, 9)
  local i = 0
  for k, v in ipairs(item.recipe.ingredients) do
    prints(ITEMS[v.id].fancy_name .. ' - ' .. v.count, sx + 3, sy + 10 + (i * 6), 0, 11)
    i = i + 1
  end
  sspr(CRAFTER_TIME_ID, sx + 2, sy + h - 8, 1)
  prints(item.recipe.crafting_time/60 .. 's', sx + 12, sy + h - 8, 0, 5)
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

return ui