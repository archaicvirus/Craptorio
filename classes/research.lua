  -- [1] = {
  --   name = '',
  --   progress = 0,
  --   requirements = {{id = 0, count = 0}},
  --   unlocks = {},
  --   sprite_id = 0,
  -- },

--table to store researched technology
TECH = {23, }

RESEARCH = {
  [1] = {
    name = 'Logistics 1',
    progress = 0,
    time = 15,
    requirements = {{id = 23, count = 10}, {id = 24, count = 15},{id = 25, count = 15},{id = 26, count = 15},{id = 27, count = 15},{id = 28, count = 15}},
    unlocks = {10, 18},
    sprite_id = 0,
    sprite_scale = 3
  },
  [2] = {
    name = 'Automation 1',
    progress = 0,
    time = 15,
    requirements = {{id = 23, count = 20}},
    unlocks = {11, 19},
    sprite_id = 0,
    sprite_scale = 3
  },
  [2] = {
    name = 'Logistics Pack',
    progress = 0,
    time = 15,
    requirements = {{id = 23, count = 30}},
    unlocks = {24},
    sprite_id = 0,
    sprite_scale = 3
  },
}

function draw_research_screen()
  cls(0)
  local sw = print('Technology Tree',0,-10,0,false,1,true)
  local rw = print(RESEARCH[current_research].name,0,-10,0,false,1,true)
  local left_panel_width = 101
  local left_panel_height = 57
  --main panel
  ui.draw_panel(0, 0, 240, 136, UI_BG, UI_FG)
  --left panel vertical divider
  rect(left_panel_width, 2, 2, 132, UI_FG)
  rect(2, 2, 238, 6, UI_FG)
  --left panel header
  prints(RESEARCH[current_research].name, left_panel_width/2 - rw/2, 1)
  --research progress bar
  --ui.progress_bar(progress, x, y, w, h, bg, fg, fill, option)
  ui.progress_bar(0.35, 30, 12, 68, 5, 0, UI_FG, 6, 2)
  --left panel header underline
  --line(2, left_panel_height - 12, left_panel_width-1, left_panel_height - 12, UI_FG)
  
  --left panel horizontal divider 1
  rect(2, left_panel_height - 6, left_panel_width - 2, 8, UI_FG)
  prints('Available Research', 21, left_panel_height - 5)
  prints('Research Queue', (240 - left_panel_width)/2 + left_panel_width - sw/2, 1)
  --draw_grid(x, y, rows, cols, bg, fg, size, draw_top)
  rect(240 - 13, 8, 11, 26, UI_FG)
  rect(left_panel_width, 8, 6, 26, UI_FG)
  ui.draw_grid(left_panel_width + 6, 7, 1, 5, UI_BG, UI_FG, 25, false)
  rect(left_panel_width + 2, 33, 240 - 4 - left_panel_width, 8, UI_FG)
  prints('Technology Tree', (240 - left_panel_width)/2 + left_panel_width - sw/2, 34)
  prints('Cost:', 28, 21)
  sspr(CRAFTER_TIME_ID, 30, 28, 1)
  prints(RESEARCH[current_research].time .. 's', 37, 30, 0, 6)
  --current research icon
  sspr(317, 3, 12, 1, 1, 0, 0, 3, 3)
  --current research recipe icons
  for k, v in ipairs(RESEARCH[current_research].requirements) do
    --draw_item_stack(left_panel_width/2 - 4 - ((#RESEARCH[current_research].requirements*13-13)/2) + (k-1)*13, left_panel_height - 12, v)
    --sspr(ITEMS[v.id].sprite_id, 48 + (k-1)*8, 19, ITEMS[v.id].color_key)
    draw_item_stack(48 + (k-1)*8, 19, {id = v.id, count = 1})
  end
  --draw scroll panel for available research
  ui.draw_grid(1, left_panel_height + 2, 3, 4, UI_BG, UI_FG, 25, false)
  for y = 0, 2 do
    for x = 0, 3 do
      --rect(2 + x*25, left_panel_height + 3 + y*25, 24, 24, 2)
      sspr(317, 2 + x*25, left_panel_height + 3 + y*25, 1, 1, 0, 0, 3, 3)
    end
  end
end