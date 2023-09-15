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
UI_BUTTON = 438
UI_PAUSE = 354
UI_CLOSE = 355
UI_BUTTON2 = 113
UI_PROG_ID = 128
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

function ui.draw_text_window(data, x, y, label, bg, fg, text_bg, text_fg, wrap)
  x, y, label, fg, bg, text_fg, text_bg = x or 2, y or 2, label or false, fg or UI_FG, bg or UI_BG, text_fg or UI_TEXT_FG, text_bg or UI_TEXT_BG
  local w = wrap or 6
  local h = #data * 7 + 4 + (label and 9 or 0)
  local final_data = {}
  --if label then h = h + 9 end
  for i = 1, #data do
    local string = type(data[i]) == 'table' and data[i].text or data[i]
    local string_width = print(string, 0, -10, 0, false, 1, true)
    if not wrap and string_width + 6 > w then
      w = string_width + 6
      table.insert(final_data, data[i])
    elseif wrap and string_width + 6 > wrap then
      local lines = text_wrap(string, wrap - 6)
      for k, v in ipairs(lines) do
        if type(data[i]) == 'table' then
          table.insert(final_data, {text = tostring(v), bg = data[i].bg, fg = data[i].fg})
        else
          table.insert(final_data, tostring(v))
        end
      end
      h = h + ((#lines - 1)*7)
    else
      if type(data[i]) == 'table' then
        table.insert(final_data, {text = string, bg = data[i].bg, fg = data[i].fg})
      else
        table.insert(final_data, string)
      end
    end
  end
  x = clamp(x, 0, 240 - w - 1)
  y = clamp(y, 0, 136 - h - 1)
  ui.draw_panel(x, y, w, h, bg, fg, label, UI_SHADOW)
  -- rectb(x, y, width, height, border)
  -- rect(x + 1, y + 1, width - 2, height - 2, background)
  for i = 1, #final_data do
    local bg, fg, text = text_bg, text_fg, final_data[i]
    if type(text) == 'table' then
      bg, fg = final_data[i].bg, final_data[i].fg
      text = final_data[i].text
    end
    prints(text, x + 4, y + ((i-1) * 7) + (label and 10 or 3), bg, fg)
  end
end

-- function ui.item_slot(x, y, w, h, bg, fg, stack, id_lock, deposit_lock)
--   local slot = {
--     x = x,
--     y = y,
--     w = w or 10,
--     h = h or 10,
--     bg = bg or 8,
--     fg = fg or 9,
--     stack = stack or {id = 0, count = 0},
--     id_lock = id_lock or false,
--     deposit_lock = deposit_lock or false,
--   }
--   function slot:click()
--     local x, y = cursor.x, cursor.y
--     local left, right = cursor.l, cursor.r
--     local shift = key(64)
--     if x >= self.x and x < self.x + self.w and y >= self.y and y < self.y + self.h then
--       local stack_size = ITEMS[self.id].stack_size
--       --item interaction
--       if cursor.type == 'pointer' then
--         if key(64) then
--           local old_count = v.count
--           local result, stack = inv:add_item({id = v.id, count = v.count})
--           if result then
--             v.count = stack.count
--             sound('deposit')
--             ui.new_alert(cursor.x, cursor.y, '+ ' .. (stack.count == 0 and old_count or old_count - stack.count) .. ' ' .. ITEMS[v.id].fancy_name, 1000, 0, 6)
--             return true
--           end
--         elseif v.count > 0 then
--           if cursor.r and v.count > 1 then
--             set_cursor_item({id = v.id, count = math.ceil(v.count/2)}, false)
--             v.count = floor(v.count/2)
--             return true
--           else
--             set_cursor_item({id = v.id, count = v.count}, false)
--             v.count = 0
--             return true
--           end
--         end
--       elseif cursor.type == 'item' and cursor.item_stack.id == v.id then
--         --try to combine stacks, leaving extra on cursor
--         if key(64) then
--           if v.count > 0 then
--             local result, stack = inv:add_item({id = v.id, count = v.count})
--             if result then
--               v.count = stack.count
--               sound('deposit')
--               ui.new_alert(cursor.x, cursor.y, '+ ' .. (stack.count == 0 and old_count or old_count - stack.count) .. ' ' .. ITEMS[v.id].fancy_name, 1000, 0, 6)
--               return true
--             end
--           end
--           return true
--         end
--         if cursor.r then
--           if v.count + 1 < stack_size then
--             v.count = v.count + 1
--             cursor.item_stack.count = cursor.item_stack.count - 1
--             if cursor.item_stack.count < 1 then
--               set_cursor_item()
--             end
--             return true
--           end
--         else
--           if cursor.item_stack.count + v.count > stack_size then
--             local old_count = v.count
--             v.count = stack_size
--             cursor.item_stack.count = cursor.item_stack.count - (stack_size - old_count)
--             return true
--           else
--             v.count = v.count + cursor.item_stack.count
--             set_cursor_item()
--             return true
--           end
--         end
--       end
--       return true
--     end
--     return false
--   end
-- end

function ui.item_box(x, y, w, h, bg, fg)
  local new_box = {
    x = x,
    y = y,
    w = w,
    h = h,
    bg = bg or UI_BG,
    fg = fg or UI_FG,
    update = function (self, parent)
      --self.
    end,
    draw = function (self, x, y, stack)
      box(self.x + x, self.y + y, self.w, self.h, self.bg, self.fg)
      if stack.count ~= 0 and stack.id ~= 0 then
        draw_item_stack(self.x + x + 1, self.y + y + 1, stack, true)
      end
    end,
    click = function (self, x, y, parent, stack)
      local sx, sy = self.x + parent.x, self.y + parent.y
      --have we clicked box?
      if x >= sx and x < sx + self.w and y >= sy and y < sy + self.h then
        if key(64) and stack.id ~= 0 then
          local result, stack2 = inv:add_item(stack)
          if result then
            sound('deposit')
            return {id = 0, count = 0}
          end
          if stack2 then
            sound('deposit')
            return stack2
          end
        end
        --is player holding an item stack?
        if cursor.type == 'item' then
          if cursor.item_stack.id == stack.id then

          end
        elseif cursor.type == 'pointer' then
          if stack.count > 0 then
            if cursor.r then
              set_cursor_item({id = stack.id, count = math.ceil(stack.count/2)})
              return {id = stack.id, count = floor(stack.count/2)}
            else
              set_cursor_item(stack)
              return {id = 0, count = 0}
            end
          end
          
        end
      end
      return false
    end,
  }
  return new_box
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
  active_tab = 1,
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
    }
  }
}

CraftPanel.tab['logistics'] = CraftPanel.tab[0]
CraftPanel.tab['production'] = CraftPanel.tab[1]
CraftPanel.tab['intermediate'] = CraftPanel.tab[2]
--CraftPanel.tab['combat'] = CraftPanel.tab[3]

function ui.draw_panel(x, y, w, h, bg, fg, label, shadow)
  x, y = clamp(x, 0, (240 - w)), clamp(y, 0, (136 - h))
  bg, fg = bg or UI_BG, fg or UI_FG
  local width = text_width(type(label) == 'table' and label.text or label)
  if width > w + 7 then w = width + 7 end
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
    if type(label) == 'table' then
      prints(label.text, x + w/2 - width/2, y + 2, label.bg, label.fg) -- header text
    else
      prints(label, x + w/2 - width/2, y + 2, 0, 4) -- header text
    end
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
    sspr(482, x + self.tab[3].x + 3, y + self.tab[3].y + 2, 6)-- TAb 3
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
          -- if ENTS[self.current_output].type == 'bio_refinery' then
          --   if item.type == 'oil' then
          --   end
          -- else
          --   spr(item.sprite_id, self.x + self.grid_x + (j*9) - 9 + 1, self.y + self.grid_y + 1 + (i * 9) - 9, item.color_key)
          -- end
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
        ui.highlight(sl_x - 1, sl_y - 1, 8, 8, false, 3, 4)
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
      if row <= #recipes[self.active_tab] and col <= #recipes[self.active_tab][row] then
        --assembly machine crafting
        if ENTS[self.current_output] then
          trace('clicked ' .. ENTS[self.current_output].type)
          local item = ITEMS[recipes[self.active_tab][row][col]]
          if item.craftable == false and item.type ~= 'oil' then sound('deny') return end
          if item.type == 'oil' and ENTS[self.current_output].type == 'bio_refinery' then
            ENTS[self.current_output]:set_recipe(ITEMS[recipes[self.active_tab][row][col]])
            toggle_crafting()
            ui.active_window = ENTS[self.current_output]:open()
            self.current_output = 'player'
            return true
          elseif item.type ~= 'oil' and ENTS[self.current_output].type ~= 'bio_refinery' then
            ENTS[self.current_output]:set_recipe(ITEMS[recipes[self.active_tab][row][col]])
            toggle_crafting()
            ui.active_window = ENTS[self.current_output]:open()
            self.current_output = 'player'
            return true
          end
          sound('deny')
          return false
        end
      end
    elseif result and self.current_output == 'player' then
      local row = math.ceil(index / 10)
      local col = ((index - 1) % 10) + 1
      if row <= #recipes[self.active_tab] and col <= #recipes[self.active_tab][row] then
        --player crafting
        local item = ITEMS[recipes[self.active_tab][row][col]]
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

function text_width(txt)
  return print(txt, 0, -10, 0, false, 1, true)
end

function text_wrap(text, width, break_word)
  local wrapped_lines = {}
  local function add_line(line)
    table.insert(wrapped_lines, line)
  end
  local function measure(str)
      return text_width(str)
  end
  local function add_word(word, line)
    if measure(line .. " " .. word) > width then
      add_line(line)
      return word
    else
      if line ~= "" then line = line .. " " end
      return line .. word
    end
  end
  local line = ""
  for word in text:gmatch("%S+") do
    if not break_word and measure(word) > width then
      for c in word:gmatch(".") do
        if measure(line .. c) > width then
          add_line(line)
          line = c
        else
          line = line .. c
        end
      end
    else
      line = add_word(word, line)
    end
  end
  if line ~= "" then add_line(line) end
  return wrapped_lines
end

function ui.progress_bar(progress, x, y, w, h, bg, fg, fill, option)
  --Options: 
  --0 - rounded/fancy
  --1 - square with border
  --2 - square no border
  local prog_width = math.min(w-2, math.ceil((w-2)*progress))
  if option == 0 then
    pal({1, fg, 4, bg})
    rect(x + 1, y + 1, w - 2, 4, bg)
    rect(x + 1, y + 1, prog_width, 4, fill)
    sspr(UI_PROG_ID, x, y, 0)
    sspr(UI_PROG_ID, x + w - 8, y, 0, 1, 1)
    line(x + 4, y, x + w - 4, y, fg)
    line(x + 4, y + 5, x + w - 4, y + 5, fg)
    pal()
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

function show_recipe_widget()
  local x, y, id = current_recipe.x, current_recipe.y, current_recipe.id
  local item = ITEMS[id]
  local w, h = math.max(75, text_width(item.fancy_name) + 20), 13
  local start_y = 11
  if item.craftable == false then
    h = h + 8
  end
  if item.recipe then
    h = h + #item.recipe.ingredients*10 + 9
    for k, v in ipairs(item.recipe.ingredients) do
      local width = text_width(ITEMS[v.id].fancy_name) + 18
      if width > w then w = width end
    end
  end
  local lines = false
  if item.info then
    lines = text_wrap(item.info, w - 8, false)
    h = h + #lines*8
  end
  x, y = clamp(x, 1, (240 - w) - 1), clamp(y, 1, (136 - h) - 1)
  ui.draw_panel(x, y, w, h, 8, 9, item.fancy_name, 0)
  if not item.craftable then
    prints('Uncraftable', x + 5, y + start_y, 0, 2)
    start_y = start_y + 8
  end
  if item.recipe then
    for k, v in ipairs(item.recipe.ingredients) do
      prints(ITEMS[v.id].fancy_name, x + 5, y + start_y + 1)
      draw_item_stack(x + w - 11, y + start_y - 1, v, true)
      start_y = start_y + 10
    end
    sspr(CRAFTER_TIME_ID, x + 5, y + start_y, 1)
    prints((item.recipe.crafting_time/60) .. 's', x + 12, y + start_y, 0, 5)
    start_y = start_y + 8
  end
  if item.info then
    for k, v in ipairs(lines) do
      prints(v, x + 5, y + start_y, 0, 11)
      start_y = start_y + 8
    end
    --draw_lines
  end
end

function draw_recipe_widget(x, y, id)
  current_recipe = {x = x, y = y, id = id}
end

-- function draw_recipe_widget(x, y, id)
--   local w, h
--   local item = ITEMS[id]
--   local recipe = item.recipe
--   local name = item.fancy_name
--   w = math.max(text_width(name) + 6, 75)
--   h = 13
  
--   if recipe then
--     h = h + (#recipe.ingredients * 11) + 5
--     for k, v in ipairs(recipe.ingredients) do
--       local width = text_width(ITEMS[v.id].fancy_name) + 17
--       if width > w then w = width end
--     end
--   else
--     h = h + 11
--   end
  
--   local info = item.info and text_wrap(item.info, w - 6) or false
--   if info then
--     h = h + (#info * 7)
--   end

--   local x, y = clamp(x, 1, 240 - w - 2), clamp(y, 1, 136 - h - 2)
--   ui.draw_panel(x, y, w, h, UI_BG, UI_FG, name, UI_SHADOW)

--   if recipe then
--     for k, v in ipairs(recipe.ingredients) do
--       prints(ITEMS[v.id].fancy_name, x + 3, y + 10 + ((k-1)*11), 0, 4)
--       draw_item_stack(x + w - 13, y + 10 + ((k-1)*9), v, true)
--     end
--     local craft_time = item.recipe.crafting_time/60 .. 's'
--     local sw = text_width('x ' .. item.recipe.count .. ' -')
--     local cw = text_width(craft_time)
--     prints('x ' .. item.recipe.count .. ' -', x + 3, y + 7 + (#recipe.ingredients*11) + 2, 0, 4)
--     sspr(CRAFTER_TIME_ID, x + w - 2 - cw - 10, y + 7 + (#recipe.ingredients*11) + 2, 1)
--     prints(craft_time, x + w - 3 - cw, y + 7 + (#recipe.ingredients*11) + 2, 0, 5)
--   else
--     prints('Uncraftable', x + 3, y + 10, 0, 2)
--   end

--   if info then
--     if recipe then
--       y = y + 15 + (#recipe.ingredients * 10) + 1
--     else
--       y = y + 18
--     end
--     for k, v in ipairs(info) do
--       prints(v, x + 3, y + ((k-1)*7), 0, 11)
--     end
--   end

-- end

function draw_item_stack(x, y, stack, show_cnt)
  show_cnt = show_cnt or show_count
  --x, y = clamp(x, 1, 232), clamp(y, 1, 127)
  sspr(ITEMS[stack.id].sprite_id, x, y, ITEMS[stack.id].color_key)
  if show_cnt then
    local count = stack.count < 100 and stack.count or floor(stack.count/100) .. 'H'
    local sx, sy = x + 9 - text_width(count), y + 4
    prints(count, sx, sy)
  end
end

function draw_recipe_widgetOLD(x, y, id)
  local item = ITEMS[id]
  local w, h = text_width(item.fancy_name) + 4, 19
  local craft_time = (item.recipe and (item.recipe.crafting_time or item.smelting_time)/60 .. 's') or 'Uncraftable'
  local cw = text_width(craft_time)
  if item.info then
    w = math.max(w, 75) + 10
    local text = text_wrap(item.info, math.min(w, w - 6), true)
    h = h + (#text * 7)
  end
  if item.recipe then
    if item.recipe.ingredients then
      for k, v in ipairs(item.recipe.ingredients) do
        local str_w = text_width(ITEMS[v.id].fancy_name .. ' - ' .. v.count)
        if str_w + 12 > w then w = str_w + 12 end
        h = h + 7
      end
    end
    h = h + 7
    local str_w2 = text_width(item.name)
    if str_w2 > w then w = str_w2 + 8 end
    if cw > w then w = cw + 8 end
    local sx, sy = clamp(x, 1, 240 - (w + 2)), clamp(y, 1, 136 - (h+2))
    ui.draw_panel(sx, sy, w, h + 1, 8, 9, item.fancy_name, 0)
    local i = 0
    if item.recipe.ingredients then
      for k, v in ipairs(item.recipe.ingredients) do
        prints(ITEMS[v.id].fancy_name, sx + 3, sy + 10 + (i * 11), 0, 4)
        draw_item_stack(sx + w-13, sy + 10 + ((k-1) * 10), v, true)
        i = i + 1
      end
      local sw = text_width('x ' .. item.recipe.count .. ' -')
      local cw = text_width(craft_time)
      prints('x ' .. item.recipe.count .. ' -', sx + 3, sy + h - 8, 0, 4)
      sspr(CRAFTER_TIME_ID, sx + w - 2 - cw - 10, sy + h - 8, 1)
      prints(craft_time, sx + w - 3 - cw, sy + h - 8, 0, 5)
    end
    if item.info then
      local text = text_wrap(item.info, math.min(w, w - 6), true)
      for k, v in ipairs(text) do
        prints(v, sx + 3, sy + 17 + ((k-1) * 7), 0, 11)
      end
    end
  else
    --w = print(item.fancy_name, 0, -10, 1, false, 1, true) + 6
    --h = h + 8
    local w2 = text_width('Uncraftable')
    if w2 + 6 > w then w = w2 + 6 end
    local sx, sy = clamp(x, 1, 240 - w - 2), clamp(y, 1, 136 - h - 2)
    local panel_width = text_width(item.fancy_name)
    ui.draw_panel(sx, sy, w, h, 8, 9, item.fancy_name, 0)
    prints('Uncraftable', sx + 3, sy + 10, 0, 2)
    if item.info then
      local text = text_wrap(item.info, math.min(w, w - 6), true)
      for k, v in ipairs(text) do
        prints(v, sx + 3, sy + 17 + ((k-1) * 7))
      end
      --trace('found item info')
      -- for i = 1, #item.info do
      --   --local str_w = text_width(item.info[i])
        
      --   prints(item.info[i], sx + 3, sy + 10 + ((i-1) * 7))
      -- end
    end
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

function rspr(id, x, y, colorkey, sx, sy, flip, rotate, w, h, pivot)
  colorkey = colorkey or -1
  sx = sx or 1
  sy = sy or 1
  flip = flip or 0
  rotate = rotate or 0
  w = w or 1
  h = h or 1
  pivot = pivot or vec2(4, 4)

  -- Draw a sprite using two textured triangles.
  -- Apply affine transformations: scale, shear, rotate, flip

  -- scale / flip
  if flip % 2 == 1 then
    sx = -sx
  end
  if flip >= 2 then
    sy = -sy
  end
  ox = w * 8 // 2
  oy = h * 8 // 2
  ox = ox * -sx
  oy = oy * -sy

  -- shear / rotate
  shx1 = 0
  shy1 = 0
  shx2 = 0
  shy2 = 0
  shx1 = shx1 * -sx
  shy1 = shy1 * -sy
  shx2 = shx2 * -sx
  shy2 = shy2 * -sy
  rr = math.rad(rotate)
  sa = math.sin(rr)
  ca = math.cos(rr)

  function rot(x, y)
    return x * ca - y * sa, x * sa + y * ca
  end

  rx1, ry1 = rot(ox + shx1, oy + shy1)
  rx2, ry2 = rot(((w * 8) * sx) + ox + shx1, oy + shy2)
  rx3, ry3 = rot(ox + shx2, ((h * 8) * sy) + oy + shy1)
  rx4, ry4 = rot(((w * 8) * sx) + ox + shx2, ((h * 8) * sy) + oy + shy2)
  x1 = x + rx1 - pivot.x
  y1 = y + ry1 - pivot.y
  x2 = x + rx2 - pivot.x
  y2 = y + ry2 - pivot.y
  x3 = x + rx3 - pivot.x
  y3 = y + ry3 - pivot.y
  x4 = x + rx4 - pivot.x
  y4 = y + ry4 - pivot.y

  -- UV coords
  u1 = (id % 16) * 8
  v1 = math.floor(id / 16) * 8
  u2 = u1 + w * 8
  v2 = v1 + h * 8

  ttri(x1, y1, x2, y2, x3, y3, u1, v1, u2, v1, u1, v2, 0, colorkey)
  ttri(x3, y3, x4, y4, x2, y2, u1, v2, u2, v2, u2, v1, 0, colorkey)
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
  sspr(CURSOR_HIGHLIGHT_CORNER_S, x + offset - 1, y - 1 + offset, 0)
  sspr(CURSOR_HIGHLIGHT_CORNER_S, x + (w - 5) - offset, y - 1 + offset, 0, 1, 1, 0)
  sspr(CURSOR_HIGHLIGHT_CORNER_S, x + (w - 5) - offset, y + (h - 5) - offset, 0, 1, 3, 0)
  sspr(CURSOR_HIGHLIGHT_CORNER_S, x + offset - 1, y + (h - 5) - offset, 0, 1, 2, 0)
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
  local lines = {
    [1] = {x1 =  x, y1 = y + height, x2 =  x + width, y2 = y + height},
    [2] = {x1 =  x, y1 = y, x2 =  x + width, y2 = y}
  }
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

function draw_tile_widget()
  local x, y = cursor.x, cursor.y
  if show_tech or inv:is_hovered(x, y) or craft_menu:is_hovered(x, y) or (ui.active_window and ui.active_window:is_hovered(x,y)) then
    return
  end
  local sx, sy = get_screen_cell(x, y)
  local tile, wx, wy = get_world_cell(x, y)
  local k = get_key(x, y)
  local tile_type = tile.ore and ores[tile.ore].name .. ' Ore' or tile.is_land and 'Land' or 'Water'
  local biome = tile.is_land and biomes[tile.biome].name or 'Ocean'
  local info = {
    -- [1] = {text = 'Biome: ' .. biome, bg = 0, fg = biomes[tile.biome].map_col},
    [1] = {text = 'Biome: ' .. biome, bg = 0, fg = 10},
    [2] = {text = 'Type: ' .. tile_type, bg = 0, fg = 3},
    [3] = {text = 'Coords: ' .. wx .. ',' .. wy, bg = 0, fg = 11},
    -- [4] = 'Noise: '  .. tile.noise,
    -- [5] = 'Border: ' .. tostring(tile.is_border),
  }
  local resource = resources[tostring(tile.sprite_id)]
  if resource then
    --{id = 5, min =  5, max = 20},
    info[4] = {text = resource.name, bg = 0, fg = 4}
    info[5] = {text = 'Gives ' .. resource.min ..'-' .. resource.max .. ' ' .. ITEMS[resource.id].fancy_name .. ' when harvested', bg = 0, fg = 5}
  end
  if tile.is_tree then
    info[4] = {text = 'Tree', bg = 0, fg = 2}
    info[5] = {text = 'Gives 5-10 Wood Planks when harvested', bg = 0, fg = 5}
    local sx, sy = world_to_screen(wx, wy)
    local c1, c2 = 3, 4
    if tile.biome < 2 then c1, c2 = 2, 3 end
    ui.highlight(sx - 9 + tile.offset.x, sy - 27 + tile.offset.y, 24, 32, false, c1, c2)
  end
  if tile.ore then
    if ORES[k] then
      info[4] = {text = 'Remainig Ore:', bg = 0, fg = 11}
      info[5] = {text = tostring(ORES[k].ore_remaining) .. '/' .. tostring(ORES[k].total_ore), bg = 0, fg = 2}
    end
  end
  ui.draw_text_window(info, x + 8, y + 5, 'Scanning...', 8, 9, 0, 4, 75)
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
  if ui.draw_button(2, lph - 6, current_tab and 0 or 1, UI_BUTTON, 2, 0, 3) then
    current_tab = not current_tab
  end
  if current_tab then
    prints('Available Tech', 12, lph - 4)
  else
    prints('Known Tech', 12, lph - 4)
  end
  ----------CURRENT PAGE--------------------------------------------
  local total_current_pages = clamp(math.ceil((current_tab and #AVAILABLE_TECH/12) or #F_TECH/12), 1, 100)
  if ui.draw_button((lpw/2) - (rsw/2) + 29, lph - 5, 1, UI_ARROW, 12, 0, 4) then
    current_page = clamp(current_page - 1, 1, total_current_pages)
  end
  if ui.draw_button((lpw/2) - (rsw/2) + 56, lph - 5, 0, UI_ARROW, 12, 0, 4) then
    current_page = clamp(current_page + 1, 1, total_current_pages)
  end
  prints(current_page .. '/' .. total_current_pages, (lpw/2) - (rsw/2) + 41, lph - 4, 0)  
  ----------RESEARCH QUEUE------------------------------
  prints('Research Queue', (240 - lpw)/2 + lpw - sw/2, 1)
  --research queue grid
  ui.draw_grid(lpw + 6, 8, 1, 7, UI_BG, UI_FG, 17, false)
  --queue item icons

  --------------TECH TREE------------------------------
  rectr(lpw + 2, 36, 135, 98, UI_BG, UI_FG, false)
  prints('Technology Tree', (240 - lpw)/2 + lpw - sw/2, 29)
  ----------------SELECTED TECH PANEL--------------------------
  if current_tab and selected_research then
    --research progress bar
    if not TECH[AVAILABLE_TECH[selected_research]].completed then
      local progress = TECH[AVAILABLE_TECH[selected_research]].progress
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
      local index = i + ((current_page - 1) * 12)
      local final_index = current_tab and AVAILABLE_TECH[index] or not current_tab and F_TECH[index]
      if final_index then
        draw_research_icon(final_index, 2+x*25, lph+3+y*25)
        if current_tab and AVAILABLE_TECH[final_index] and final_index == current_research then
          ui.highlight(x*25, lph + y*25 + 2, 24, 24, true, 3, 4)
        end
      end
      i = i + 1
    end
  end
  --check available research hover
  local slot = get_hovered_slot(cursor.x, cursor.y, 1, 59, 25, 3, 4)
  if slot then
    local index = false
    if current_tab then
      index = AVAILABLE_TECH[slot.index + ((current_page-1)*12)] or false
    else
      index = F_TECH[slot.index + ((current_page-1)*12)] or false
    end
    ui.highlight(slot.x, slot.y, 24, 24, false, 3, 4)
    if not index then return end
    draw_tech_widget(cursor.x + 5, cursor.y + 5, index)
    if current_tab and cursor.l and not cursor.ll then
      if index then
        selected_research = slot.index + ((current_page-1)*12)
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
    ui.highlight(slot.x, slot.y, 16, 16, false, 3, 4)
  end
  if selected_research then
    slot = get_hovered_slot(cursor.x, cursor.y, 34, 39, 9, 1, #TECH[AVAILABLE_TECH[selected_research]].item_unlocks)
    if slot then
      ui.highlight(slot.x, slot.y, 8, 8, false, 3, 4)
      draw_recipe_widget(cursor.x + 5, cursor.y + 5, TECH[AVAILABLE_TECH[selected_research]].item_unlocks[slot.index])
    end
    for k, v in ipairs(TECH[AVAILABLE_TECH[selected_research]].science_packs) do
      if hovered(cursor, {x = 30 + (k-1)*8, y = 28, w = 8, h = 8}) then
        ui.highlight(29 + (k-1)*8, 27, 8, 8, false, 3, 4)
        draw_recipe_widget(cursor.x + 5, cursor.y + 5, v.id)
      end
    end
    --draw tech tree
    prints('tech tree', 120, 50, 0, 4)
  end
end

function update_research_progress()
  if not current_research then return false end
  local tech = TECH[AVAILABLE_TECH[current_research]]
  local frac = 1 / tech.science_packs[1].count
  if tech.progress < 1.0 then
    tech.progress = tech.progress + frac
    if tech.progress >= 1.0 then
      sound('tech_done')
      local txt = tech.name .. ' research completed!'
      ui.new_alert(120 - text_width(txt)/2, 68, txt, 2500, 0, 4)
      if tech.callback then tech:callback() end
      tech.completed = true
      for k, v in ipairs(tech.item_unlocks) do
        UNLOCKED_ITEMS[v] = true
      end
      for k, v in ipairs(tech.tech_unlocks) do
        if not FINISHED_TECH[v] and not AVAILABLE_TECH[v] then
          table.insert(AVAILABLE_TECH, v)
        end
      end
      local tid = AVAILABLE_TECH[current_research]
      FINISHED_TECH[AVAILABLE_TECH[current_research]] = true
      table.remove(AVAILABLE_TECH, current_research)
      for k, v in ipairs(TECH) do
        for j, u in ipairs(v.required_tech) do
          if tid == u then
            local n = 0
            for i, m in ipairs(v.required_tech) do
              if FINISHED_TECH[m] then
                n = n + 1
              end
            end
            if n == #v.required_tech and not TECH[k].completed then
              sound('tech_add')
              local txt = '+ ' .. TECH[k].name .. ' research unlocked!'
              ui.new_alert(120 - text_width(txt)/2, 76, txt, 2500, 0, 5)
              table.insert(AVAILABLE_TECH, k)
              break
            end
          end
        end
      end
      return true
    end
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
  draw_image(0, 48, 240, 46, logo, 1)
end

function ui.draw_menu()
  --cls(0)
  --vbank(0)
  --vbank(1)
  if STATE == 'start' then
    draw_logo()
    if ui.draw_text_button(120 - ((text_width('  Start  ') + 2) /2), 100, UI_BUTTON2, _, 8, 9, 15, 10, {text = '  Start  ', x = 1, y = 1, bg = 15, fg = 4, shadow = {x = 1, y = 0}}) then
      STATE = 'game'
      cls(0)
      vbank(0)
    end
    
    -- if ui.draw_text_button(120 - ((text_width('  Settings  ') + 2) /2), 110, UI_BUTTON2, _, 8, 9, 15, 10, {text = '  Settings  ', x = 1, y = 1, bg = 15, fg = 4, shadow = {x = 1, y = 0}}) then
    --   STATE = 'settings'
    -- end
    
    if ui.draw_text_button(120 - ((text_width('  Controls  ') + 2) /2), 110, UI_BUTTON2, _, 8, 9, 15, 10, {text = '  Controls  ', x = 1, y = 1, bg = 15, fg = 4, shadow = {x = 1, y = 0}}) then
      STATE = 'help'
    end
  elseif STATE == 'settings' then
    
    ui.draw_panel(0, 0, 240, 136, 8, 9, {text = 'Settings', bg = 15, fg = 4})
    if ui.draw_text_button(239 - ((text_width(' < ') + 4)), 1, UI_BUTTON2, _, 8, 2, 15, 3, {text = ' < ', x = 1, y = 1, bg = 15, fg = 4, shadow = {x = 1, y = 0}}) then
      cls(0)
      STATE = 'start'
    end
  elseif STATE == 'help' then
    --vbank(0)
    --cls(0)
    local info = {
      {'W A S D', 'Move player'},
      {'ESC', 'Exit game'},
      {'CTRL + R', 'Reload game'},
      {'I or TAB', 'Toggle inventory window'},
      {'C', 'Toggle crafting window'},
      {'T', 'Toggle research window'},
      {'R', 'Rotate held item or hovered object'},
      {'Q', 'Pipette tool - copy/swap objects'},
      {'Left-click', 'Place/deposit item/open machine'},
      {'Right-click hold', 'Mine resource or destroy object'},
      {'Scroll +/-', 'Scroll active hotbar slot'},
    }
    ui.draw_panel(0, 0, 240, 136, 8, 9, {text = 'Controls', bg = 15, fg = 4})
    for i = 1, #info do
      prints(info[i][2], 3, 10 + ((i-1) * 7), 15, 4)
      prints(info[i][1], 150, 10 + ((i-1) * 7), 15, 11, _, true)
    end
    --ui.draw_button(x, y, flip, id, color, shadow_color, hover_color)
    if ui.draw_button(240 - 12, 1, 1, UI_BUTTON, 2, 8, 3) then
      cls()
      STATE = 'start'
      return
    end
    -- if ui.draw_text_button(239 - ((text_width(' < ') + 4)), 1, UI_BUTTON2, _, 8, 2, 15, 3, {text = ' < ', x = 1, y = 1, bg = 0, fg = 4, shadow = {x = 1, y = 0}}) then
    --   cls()
    --   STATE = 'start'
    --   return
    -- end
    --ui.draw_panel(0, 0, 240, 136, 8, 9)
    
  end
end

function ui.new_alert(sx, sy, text, duration, bg, fg)
  local length = text_width(text)
  local alert = {
    x = clamp(sx, 0, 240 - length),
    y = clamp(sy + #ui.alerts*6, 1, 131),
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
    if ui.alerts[trash[i]] then table.remove(ui.alerts, trash[i]) end
  end
end