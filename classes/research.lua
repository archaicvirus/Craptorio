AVAILABLE_TECH = {'1','2','3'}
UNLOCKED_TECH = {}
UNLOCKED_ITEMS = {}
current_research = false
selected_research = false
current_page = 1
local starting_items = {2, 9, 20, 17, 21, 23, 15, 16, 3, 4, 5, 6, 7, 8, 12, 14}
for i = 1, #ITEMS do
  UNLOCKED_ITEMS[i] = false
end
for k, v in ipairs(starting_items) do
  UNLOCKED_ITEMS[v] = true
end

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
    time = 20,
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
    time = 30,
    requirements = {
      {id = 23, count = 30}
    },
    unlocks = {24},
    sprite = {id = 269, w = 2, h = 2, color_key = 1, scale = 2, page = 1, offset = {x = 4, y = 4}},
  },
  [4] = {
    name = 'Steel Processing',
    progress = 0,
    completed = false,
    time = 30,
    requirements = {
      {id = 23, count = 50}
    },
    unlocks = {30},
    sprite = {id = 0, w = 2, h = 2, color_key = 1, scale = 2, page = 1, offset = {x = 4, y = 4}},
  },
}
--copy defs so runtime changes are independant
RESEARCH = TECH

function draw_research_screen()
  cls(UI_FG)
  local sw = print('Technology Tree',0,-10,0,false,1,true)
  local rw = print(selected_research and TECH[selected_research].name or 'Select-a-tech',0,-10,0,false,1,true)
  local rsw = print('Research', 0, -10, 0, false, 1, false)/2
  local lpw = 101
  local lph = 57
  -----------MAIN PANEL-------------------
  ui.draw_panel(0, 0, 240, 136, UI_FG, UI_FG)

  -------SELECTED TECH HEADER-------------------
  prints(selected_research and TECH[selected_research].name or 'Select-a-tech', 4 + lpw/2 - rw/2, 1)
  rectr(2, 8, lpw - 3, lph - 14, UI_BG, UI_FG, false)
  prints('Research', 4, lph - 4)

  ----------CURRENT PAGE--------------------------------------------
  if ui.draw_button((lpw/2) - (rsw/2) + 29, lph - 5, 1, UI_ARROW) then
    current_page = clamp(current_page - 1, 1, math.ceil(#TECH/12))
  end
  if ui.draw_button((lpw/2) - (rsw/2) + 56, lph - 5, 0, UI_ARROW) then
    current_page = clamp(current_page + 1, 1, math.ceil(#TECH/12))
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
  if selected_research then
    --research progress bar
    --ui.progress_bar(progress, x, y, w, h, bg, fg, fill, option)
    --start/pause research button
    if current_research == selected_research then
      if ui.draw_button(lpw - 11, lph - 15, 0, UI_PAUSE) then
        current_research = false
      end
    else
      if ui.draw_button(lpw - 11, lph - 15, 0, UI_ARROW) then
        current_research = selected_research
      end
    end

    if selected_research and TECH[selected_research].progress > 0 or (selected_research == current_research) then
      local progress = TECH[selected_research].progress / TECH[selected_research].requirements[1].count
      ui.progress_bar(progress, 30, 12, 68, 5, 0, UI_FG, 6, 2)
    end
    prints('Cost:', 28, 21)
    prints('Unlocks:', 4, 42)
    --available research icons
    --timer sprite & text
    sspr(CRAFTER_TIME_ID, 30, 28, 1)
    for k, v in ipairs(TECH[selected_research].unlocks) do
      sspr(ITEMS[v].sprite_id, 35 + ((k-1)*9), 40, ITEMS[v].color_key)
    end
    prints(TECH[selected_research].time .. 's', 37, 30, 0, 6)
    --current research icon
    local sprite = TECH[selected_research].sprite
    local offset = sprite.offset or {x=0,y=0}
    pokey(sprite.page,sprite.id,sprite.w,sprite.h,3 + offset.x,12 + offset.y,sprite.color_key)
    --current research recipe icons
    for k, v in ipairs(TECH[selected_research].requirements) do
      sspr(ITEMS[v.id].sprite_id, 48 + (k-1)*8, 19, ITEMS[v.id].color_key)
      --draw_item_stack(48 + (k-1)*8, 19, {id = v.id, count = 1})
    end
  end

  --------------AVAILABLE TECH GRID PANEL----------------------
  ui.draw_grid(1, lph + 2, 3, 4, UI_BG, UI_FG, 25, false)
  local i = 1
  for y = 0, 2 do
    for x = 0, 3 do
      --rect(2 + x*25, lph + 3 + y*25, 24, 24, 2)
      if TECH[i] then
        local s = TECH[i].sprite
        local offset = s.offset or {x=0,y=0}
        if s.page > 0 then
          pokey(s.page, s.id, s.w, s.h, offset.x + 2 + x*25, offset.y + lph + 3 + y*25, s.color_key)
        else
          sspr(s.id, offset.x + 2 + x*25, offset.y + lph + 3 + y*25, s.color_key, s.scale, 0, 0, s.w, s.h)
        end
        if TECH[i] and i == current_research then
          ui.highlight(x*25, lph + y*25 + 2, 24, 24, true)
        end
      end
      i = i + 1
    end
  end
  --check available research hover
  local slot = get_hovered_slot(cursor.x, cursor.y, 1, 59, 25, 3, 4)
  if slot then
    --rectb(slot.x, slot.y, 26, 26, 4)
    ui.highlight(slot.x - 1, slot.y, 24, 24, false)
    if TECH[slot.index] then
      draw_tech_widget(cursor.x + 5, cursor.y + 5, slot.index)
    end
    if cursor.l and not cursor.ll then
      if TECH[slot.index] then
        selected_research = slot.index
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
    ui.highlight(slot.x-1, slot.y, 16, 16, false)
    --rectb(slot.x, slot.y, 18, 18, 4)
  end
  if selected_research then
    slot = get_hovered_slot(cursor.x, cursor.y, 34, 39, 9, 1, #TECH[selected_research].unlocks)
    if slot then
      ui.highlight(slot.x-1, slot.y, 8, 8, false)
      --rectb(slot.x, slot.y, 10, 10, 4)
      draw_recipe_widget(cursor.x + 5, cursor.y + 5, TECH[selected_research].unlocks[slot.index])
    end
    --draw_item_stack(48 + (k-1)*8, 19, {id = v.id, count = 1})
    slot = get_hovered_slot(cursor.x, cursor.y, 47, 19, 8, 1, #TECH[selected_research].requirements)
    if slot then
      --rectb(slot.x, slot.y-1, 10, 10, 4)
      ui.highlight(slot.x-1, slot.y-1, 8, 8, false)
      draw_recipe_widget(cursor.x + 5, cursor.y + 5, TECH[selected_research].requirements[slot.index].id)
    end
  end
end

function update_research_progress()
  if not current_research then return false end
  if TECH[current_research].progress < TECH[current_research].requirements[1].count then
    TECH[current_research].progress = TECH[current_research].progress + 1
    if TECH[current_research].progress >= TECH[current_research].requirements[1].count then
      TECH[current_research].completed = true
      for k, v in ipairs(TECH[current_research].unlocks) do
        UNLOCKED_ITEMS[v] = true
      end
      current_research = false
    end
    return true
  end
  return false
end