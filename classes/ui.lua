CRAFT_ANCHOR_ID = 435

local ui = {}

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

function Panel.draw(self, parent)
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

function Panel.is_hovered(self, x, y)
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

local CraftPanel = {
  x = x,
  y = y,
  grid_x = 4,
  grid_y = 26,
  w = 100,
  h = 119,
  fg = 9,
  bg = 8,
  grid_bg = 8,
  grid_fg = 9,
  border = 12,
  vis = false,
  docked = false,
  active_tab = 0,
  tab = {
    [0] = {
      x = 1,
      y = 1,
      w = 22,
      h = 22,
      spr_id = 387,
      slots = {},
    },
    [1] = {
      x = 24,
      y = 1,
      w = 20,
      h = 22,
      spr_id = 390,
      slots = {},
    },
    [2] = {
      x = 44,
      y = 1,
      w = 23,
      h = 22,
      spr_id = 393,
      slots = {},
    },
    [3] = {
      x = 69,
      y = 1,
      w = 22,
      h = 22,
      spr_id = 396,
      slots = {},
    }
  }
}

CraftPanel.tab['logistics'] = CraftPanel.tab[0]
CraftPanel.tab['production'] = CraftPanel.tab[1]
CraftPanel.tab['intermediate'] = CraftPanel.tab[2]
CraftPanel.tab['combat'] = CraftPanel.tab[3]

function CraftPanel.draw(self)
  if self.vis == true then
    local mouse_x, mouse_y = mouse()
    local x, y, w, h, active_tab, ax, ay, aw, ah = self.x, self.y, self.w, self.h, self.active_tab, self.tab[self.active_tab].x, self.tab[self.active_tab].y, self.tab[self.active_tab].w, self.tab[self.active_tab].h
    --outer border
    rectb(x - 1, y - 1, w + 2, h + 2, self.border)

    --fill
    rect(x, y, w, h, self.fg)

    --tab background area
    rect(x, y, w, 23, self.bg)

    --bottom tab divider
    line(x, y + 23, x + w, y + 23, self.border)

    --selected tab background fill
    rect(ax + x - 1, ay + y - 1, aw + 1, ah + 2, self.fg)

    --right divider for selected tab
    line(x + ax + aw, y + ay - 1, x + ax + aw, y + ay + ah, self.border)
    --left divider
    if active_tab > 0 then
      line(x + ax - 1, y + ay - 1, x + ax - 1, y + ay + ah, self.border)
    end

    --close button
    rect(self.x + self.w - 6, self.y + 1, 5, 6, 2)
    print('x', self.x + self.w - 5, self.y + 1, 0, false, 1, true)

    --anchor button
    spr(self.docked == true and CRAFT_ANCHOR_ID or CRAFT_ANCHOR_ID + 1, self.x + self.w - 6, self.y + 8, 0)

    --Sprites for tab images
    spr(self.tab[0].spr_id, self.tab[0].x + x, self.tab[0].y + y, 1, 1, 0, 0, 3, 3)
    spr(self.tab[1].spr_id, self.tab[1].x + x, self.tab[1].y + y, 1, 1, 0, 0, 3, 3)
    spr(self.tab[2].spr_id, self.tab[2].x + x, self.tab[2].y + y, 1, 1, 0, 0, 3, 3)
    spr(self.tab[3].spr_id, self.tab[3].x + x + 1, self.tab[3].y + y, 1, 1, 0, 0, 3, 3)

    --Crafting grid

    --Grid background (grid lines)
    rect(self.x + 4 , self.y + 26, self.w - 9, self.h - 28, 14)

    --grid tiles
    for i = 1, 10 do
      for j = 1, 10 do
        rect(self.x + 5 + (i*9) - 9, self.y + 27 + (j*9) - 9, 8, 8, 8)
      end
    end
    
    --item sprites
    if self.active_tab == 0 then
      for i = 1, #recipies['logistics'] do
        for j = 1, #recipies['logistics'][i] do
          spr(recipies['logistics'][i][j].sprite_id, self.x + self.grid_x + (j*9) - 9 + 1, self.y + self.grid_y + 1 + (i * 9) - 9, 0)
        end
      end
    end

    --Hovered-item recipie widget
    if self:is_hovered(x, y) then
      local result, sl_x, sl_y, slot_index = self:get_hovered_slot(mouse_x, mouse_y)
      if result then
        local row = math.ceil(slot_index / 10)
        local col = ((slot_index - 1) % 10) + 1
        if row <= #recipies['logistics'] and col <= #recipies['logistics'][row] then draw_recipie_widget(mouse_x + 8, mouse_y, recipies['logistics'][row][col]) end
        spr(CURSOR_HIGHLIGHT_ID, sl_x, sl_y, 0)
        --print(slot_index, mouse_x + 8, mouse_y - 3, 12, false, 1, true)
      end
    end
  end
end

function CraftPanel.click(self, x, y)
  local cx, cy, w, h = self.x + self.w - 6, self.y + 1, 5, 6
  if x >= cx and x < cx + w and y >= cy and y < cy + h then
    self.vis = false
  end
  local cx, cy, w, h = self.x + self.w - 6, self.y + 8, 5, 8
  if x >= cx and x < cx + w and y >= cy and y < cy + h then
    self.docked = self.docked == false and true or false
  end
  for i = 0, 3 do
    if x >= self.x + self.tab[i].x - 1 and x < self.x + self.tab[i].x + self.tab[i].w and y >= self.y + self.tab[i].y - 1 and y < self.y + self.tab[i].y - 1 + self.tab[i].h then
      self.active_tab = i
      return true
    end
  end
  return false
end

function CraftPanel.is_hovered(self, x, y)
  return x >= self.x and x < self.x + self.w and y >= self.y and y < self.y + self.h and true or false
end

function CraftPanel.get_hovered_slot(self, x, y)
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

function CraftPanel.get_hovered_slot_dyn(self, x, y)
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

function ui.NewCraftPanel(x, y)
  local new_panel = {x = x, y = y}
  setmetatable(new_panel, {__index = CraftPanel})
  return new_panel
end

function draw_recipie_widget(x, y, cost)
  local w, h = 10, 12
  for k, v in pairs(cost.recipie) do
    local str_w = print(k .. ' - ' .. v, 0, -6, 0, false, 1, true)
    if str_w > w then w = str_w end
    h = h + 6
  end
  local str_w = print(cost.name, 0, -6, 0, false, 1, true)
  if str_w > w then w = str_w end
  local sx, sy = x - w/2, y + 8
  rectb(sx - 1, sy - 1, w + 3, h, 13)
  rect(sx, sy, w + 1, h - 2, 8)
  print(cost.name, sx + 1, sy + 1, 11, false, 1, true)
  line(sx + 1, sy + 8, sx + w - 2, sy + 8, 13)
  local i = 0
  for k, v in pairs(cost.recipie) do
    print(k .. ' - ' .. v, sx + 1, sy + 10 + (i * 6), 5, false, 1, true)
    i = i + 1
  end
end

return ui