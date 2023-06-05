  -- [1] = {
  --   name = '',
  --   progress = 0,
  --   requirements = {{id = 0, count = 0}},
  --   unlocks = {},
  --   time = 0,
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
    unlocks = {10, 18, 11},
    sprite_id = 0,
    sprite_scale = 3
  },
  [2] = {
    name = 'Automation 1',
    progress = 0,
    time = 15,
    requirements = {{id = 23, count = 20}},
    unlocks = {19, 22},
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
  ui.draw_panel(0, 0, 240, 136, UI_FG, UI_FG)
  --left panel header
  prints(RESEARCH[current_research].name, left_panel_width/2 - rw/2, 1)
  rectr(2, 8, left_panel_width - 3, left_panel_height - 14, UI_BG, UI_FG, false)
--research progress bar
  --ui.progress_bar(progress, x, y, w, h, bg, fg, fill, option)
  ui.progress_bar(0.35, 30, 12, 68, 5, 0, UI_FG, 6, 2)
  prints('Available Research', 21, left_panel_height - 5)
  --top right header
  prints('Research Queue', (240 - left_panel_width)/2 + left_panel_width - sw/2, 1)
  --research queue grid
  ui.draw_grid(left_panel_width + 6, 8, 1, 7, UI_BG, UI_FG, 17, false)
  for i = 1, 7 do
    tspr(317, 3, 3, left_panel_width + 6 + ((i-1)*17), 8, 1, 18, 18)
  end
  prints('Technology Tree', (240 - left_panel_width)/2 + left_panel_width - sw/2, 34)
  rectr(left_panel_width + 2, 42, 135, 92, UI_BG, UI_FG, false)
  prints('Cost:', 28, 21)
  prints('Unlocks:', 4, 42)
  --available research icons
  for k, v in ipairs(RESEARCH[current_research].unlocks) do
    sspr(ITEMS[v].sprite_id, 35 + ((k-1)*10), 40, ITEMS[v].color_key)
  end
  --timer sprite & text
  sspr(CRAFTER_TIME_ID, 30, 28, 1)
  prints(RESEARCH[current_research].time .. 's', 37, 30, 0, 6)
  --current research icon
  sspr(317, 3, 12, 1, 1, 0, 0, 3, 3)
  --current research recipe icons
  for k, v in ipairs(RESEARCH[current_research].requirements) do
    draw_item_stack(48 + (k-1)*8, 19, {id = v.id, count = 1})
  end
  --3x3 icons
  --draw panel for available research
  ui.draw_grid(1, left_panel_height + 2, 3, 4, UI_BG, UI_FG, 25, false)
  for y = 0, 2 do
    for x = 0, 3 do
      --rect(2 + x*25, left_panel_height + 3 + y*25, 24, 24, 2)
      sspr(317, 3 + x*25, left_panel_height + 3 + y*25, 1, 1, 0, 0, 3, 3)
    end
  end
  --2x2 icons
  -- ui.draw_grid(1, left_panel_height + 2, 4, 6, UI_BG, UI_FG, 17, false)
  -- for y = 0, 2 do
  --   for x = 0, 3 do
  --     --rect(2 + x*25, left_panel_height + 3 + y*25, 24, 24, 2)
  --     sspr(317, 2 + x*17, left_panel_height + 3 + y*17, 1, 1, 0, 0, 2, 2)
  --   end
  -- end
end