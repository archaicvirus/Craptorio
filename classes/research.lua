AVAILABLE_TECH = {1,2,3}
UNLOCKED_TECH = {}
TECH = {
  [1] = {
    name = 'Logistics 1',
    progress = 0,
    completed = false,
    time = 15,
    requirements = {
      {id = 23, count = 15},
      {id = 24, count = 15},
      {id = 25, count = 15},
      {id = 26, count = 15},
      {id = 27, count = 15},
      {id = 28, count = 15}
    },
    unlocks = {18, 10, 11},
    sprite = {id = 12, w = 3, h = 3, color_key = 1, scale = 1, page = 1},
  },
  [2] = {
    name = 'Automation 1',
    progress = 0,
    completed = false,
    time = 15,
    requirements = {
      {id = 23, count = 20}
    },
    unlocks = {19, 22},
    sprite = {id = 392, w = 3, h = 3, color_key = 0, scale = 1, page = 0},
  },
  [3] = {
    name = 'Logistics Pack',
    progress = 0,
    completed = false,
    time = 15,
    requirements = {
      {id = 23, count = 30}
    },
    unlocks = {24},
    sprite = {id = 269, w = 2, h = 2, color_key = 1, scale = 1, page = 1},
  },
}
--copy  defs, so runtime changes are independant
RESEARCH = TECH
current_page = 1
function draw_research_screen()
  cls(UI_BG)
  local sw = print('Technology Tree',0,-10,0,false,1,true)
  local rw = print(current_research and TECH[current_research].name or 'No Active Research',0,-10,0,false,1,true)
  local rsw = print('Research', 0, -10, 0, false, 1, false)/2
  local lpw = 101
  local lph = 57
  --main panel
  ui.draw_panel(0, 0, 240, 136, UI_FG, UI_FG)
  --left panel header
  prints(current_research and TECH[current_research].name or 'No Active Research', lpw/2 - rw/2, 1)
  rectr(2, 8, lpw - 3, lph - 14, UI_BG, UI_FG, false)
  prints('Research', (lpw/2) - (rsw/2), lph - 5)
  --page  < > arrow buttons
  spr(353, (lpw/2) - (rsw/2) + 29, lph - 5, 0, 1, 1)
  prints(current_page .. '/' .. math.ceil(#TECH/12), (lpw/2) - (rsw/2) + 41, lph - 5, 0)
  spr(353, (lpw/2) - (rsw/2) + 56, lph - 5, 0)
  --top right header
  prints('Research Queue', (240 - lpw)/2 + lpw - sw/2, 1)
  --research queue grid
  ui.draw_grid(lpw + 6, 8, 1, 7, UI_BG, UI_FG, 17, false)
  for i = 1, 7 do
    tspr(392, 3, 3, lpw + 7 + ((i-1)*17), 8, 0, 16, 16)
  end
  rectr(lpw + 2, 36, 135, 98, UI_BG, UI_FG, false)
  prints('Technology Tree', (240 - lpw)/2 + lpw - sw/2, 29)
  --top left current research widget
  if current_research then
    --research progress bar
    --ui.progress_bar(progress, x, y, w, h, bg, fg, fill, option)
    local progress = current_research and TECH[current_research].progress / TECH[current_research].requirements[1].count or 0
    ui.progress_bar(progress, 30, 12, 68, 5, 0, UI_FG, 6, 2)
    prints('Cost:', 28, 21)
    prints('Unlocks:', 4, 42)
    --available research icons
    --timer sprite & text
    sspr(CRAFTER_TIME_ID, 30, 28, 1)
    for k, v in ipairs(TECH[current_research].unlocks) do
      sspr(ITEMS[v].sprite_id, 35 + ((k-1)*9), 40, ITEMS[v].color_key)
    end
    prints(TECH[current_research].time .. 's', 37, 30, 0, 6)
    --current research icon
    pokey(1,12,3,3,3,12,1)
    --current research recipe icons
    for k, v in ipairs(TECH[current_research].requirements) do
      sspr(ITEMS[v.id].sprite_id, 48 + (k-1)*8, 19, ITEMS[v.id].color_key)
      --draw_item_stack(48 + (k-1)*8, 19, {id = v.id, count = 1})
    end
  end
  --draw panel for available research
  ui.draw_grid(1, lph + 2, 3, 4, UI_BG, UI_FG, 25, false)
  local i = 1
  for y = 0, 2 do
    for x = 0, 3 do
      --rect(2 + x*25, lph + 3 + y*25, 24, 24, 2)
      if TECH[i] then
        local s = TECH[i].sprite
        if s.page > 0 then
          pokey(s.page, s.id, s.w, s.h, 3 + x*25, lph + 4 + y*25, s.color_key)
        else
          sspr(s.id, 2 + x*25, lph + 3 + y*25, s.color_key, s.scale, 0, 0, s.w, s.h)
        end
      end
      i = i + 1
    end
  end
  --x, y, grid_x, grid_y, grid_size, rows, cols)
  --check available research hover
  local slot = get_hovered_slot(cursor.x, cursor.y, 1, 59, 25, 3, 4)
  if slot then
    rectb(slot.x, slot.y, 26, 26, 4)
    if TECH[slot.index] then
      draw_tech_widget(cursor.x + 5, cursor.y + 5, slot.index)
    end
    if cursor.l and not cursor.ll then
      current_research = slot.index
      if not current_research then
      elseif current_research ~= slot.index then
        --todo: add to queue
      end
    end
    --todo: draw hover widget
  end
  --ui.draw_grid(lpw + 6, 8, 1, 7, UI_BG, UI_FG, 17, false)
  slot = get_hovered_slot(cursor.x, cursor.y, 107, 8, 17, 1, 7)
  if slot then
    rectb(slot.x, slot.y, 18, 18, 4)
  end
  if current_research then
    slot = get_hovered_slot(cursor.x, cursor.y, 34, 39, 9, 1, #TECH[current_research].unlocks)
    if slot then
      rectb(slot.x, slot.y, 10, 10, 4)
      draw_recipe_widget(cursor.x + 5, cursor.y + 5, TECH[current_research].unlocks[slot.index])
    end
    --draw_item_stack(48 + (k-1)*8, 19, {id = v.id, count = 1})
    slot = get_hovered_slot(cursor.x, cursor.y, 47, 19, 8, 1, #TECH[current_research].requirements)
    if slot then
      rectb(slot.x, slot.y-1, 10, 10, 4)
      draw_recipe_widget(cursor.x + 5, cursor.y + 5, TECH[current_research].requirements[slot.index].id)
    end
  end
end

function create_research_screen()
  return{
    sw = print('Technology Tree',0,-10,0,false,1,true),
    rw = print(TECH[current_research].name,0,-10,0,false,1,true),
    lpw = 101, --left panel width
    lph = 57, --left panel height
    grid_x = 1,
    grid_y = 59,
    get_hovered_slot = function(x, y)
      local start_x = self.grid_x
      local start_y = self.grid_y
      
      local rel_x = x - start_x
      local rel_y = y - start_y
      
      local slot_x = math.floor(rel_x / 25)
      local slot_y = math.floor(rel_y / 25)
      
      local slot_pos_x = start_x + slot_x * 25
      local slot_pos_y = start_y + slot_y * 25
      local slot_index = slot_y * INVENTORY_ROWS + slot_x + 1
      if slot_x >= 0 and slot_x < INVENTORY_COLS and slot_y >= 0 and slot_y < INVENTORY_ROWS then
        return {x = slot_pos_x, y = slot_pos_y, index = slot_index}
      else
        return nil
      end
    end,
    draw = function ()
      --main panel
      ui.draw_panel(0, 0, 240, 136, UI_FG, UI_FG)  
      --left panel header
      prints(TECH[current_research].name or "Select-a-tech", self.lpw/2 - self.rw/2, 1)
      rectr(2, 8, self.lpw - 3, self.lph - 14, UI_BG, UI_FG, false)
      --research progress bar
      -- args: (progress, x, y, width, height, bg, fg, fill, option)
      ui.progress_bar(0.35, 30, 12, 68, 5, 0, UI_FG, 6, 2)
      prints('Available Research', 21, self.lph - 5)
      --top right header
      prints('Research Queue', (240 - self.lpw)/2 + self.lpw - self.sw/2, 1)
      --research queue grid
      ui.draw_grid(self.lpw + 6, 8, 1, 7, UI_BG, UI_FG, 17, false)
      for i = 1, 7 do
        tspr(392, 3, 3, self.lpw + 7 + ((i-1)*17), 8, 0, 16, 16)
      end
      rectr(self.lpw + 2, 36, 135, 98, UI_BG, UI_FG, false)
      prints('Technology Tree', (240 - self.lpw)/2 + self.lpw - self.sw/2, 29)
      prints('Cost:', 28, 21)
      prints('Unlocks:', 4, 42)
      --available research icons
      for k, v in ipairs(TECH[current_research].unlocks) do
        sspr(ITEMS[v].sprite_id, 35 + ((k-1)*10), 40, ITEMS[v].color_key)
      end
      --timer sprite & text
      sspr(CRAFTER_TIME_ID, 30, 28, 1)
      prints(TECH[current_research].time .. 's', 37, 30, 0, 6)
      --current research icon
      --sspr(317, 3, 12, 1, 1, 0, 0, 3, 3)
      pokey(1,12,3,3,3,12,1) 
      --current research recipe icons
      for k, v in ipairs(TECH[current_research].requirements) do
        draw_item_stack(48 + (k-1)*8, 19, {id = v.id, count = 1})
      end
      --3x3 icons
      --draw panel for available research
      ui.draw_grid(1, self.lph + 2, 3, 4, UI_BG, UI_FG, 25, false)
      local i = 1
      for y = 0, 2 do
        for x = 0, 3 do
          --rect(2 + x*25, self.lph + 3 + y*25, 24, 24, 2)
          if TECH[i] then
            local s = TECH[i].sprite
            if s.page > 0 then

              --sync(3, s.page, false)
              --sync(2, s.page, false)
              --sync(1, s.page, false)
              --pokey(s.page, s.id, s.w, s.h, 3 + x*25, self.lph + 4 + y*25, s.color_key)
              --sspr(s.id, 2 + x*25, self.lph + 3 + y*25, s.color_key, s.scale, 0, 0, s.w, s.h)
            else
              sspr(s.id, 2 + x*25, self.lph + 3 + y*25, s.color_key, s.scale, 0, 0, s.w, s.h)
            end
          end
          i = i + 1
        end
      end
      local slot = self:get_hovered_slot(cursor.x, cursor.y)
      if slot then
        rect(slot.x, slot.y, 25, 25, 2)
      end
    end,
    click = function(x, y)

    end,
  }
end

function update_research_progress()
  if not current_research then return false end
  if TECH[current_research].progress < TECH[current_research].requirements[1].count then
    TECH[current_research].progress = TECH[current_research].progress + 1
    if TECH[current_research].progress >= TECH[current_research].requirements[1].count then
      TECH[current_research].completed = true
      current_research = false
    end
    return true
  end
  return false
end