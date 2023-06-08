  -- [1] = {
  --   name = '',
  --   progress = 0,
  --   requirements = {{id = 0, count = 0}},
  --   unlocks = {},
  --   time = 0,
  --   sprite_id = 0,
  -- },

--table to store researched technology
AVAILABLE_TECH = {1,2,3}
UNLOCKED_TECH = {}
RESEARCH = {
  [1] = {
    name = 'Logistics 1',
    progress = 0,
    completed = false,
    time = 15,
    requirements = {
      {id = 23, count = 10},
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

--make a copy of research defs, so runtime modifications are independant
TECH = RESEARCH

function draw_research_screen()
  --cls(0)
  local sw = print('Technology Tree',0,-10,0,false,1,true)
  local rw = print(current_research and TECH[current_research].name or 'No Active Research',0,-10,0,false,1,true)
  local lpw = 101
  local lph = 57
  --main panel
  ui.draw_panel(0, 0, 240, 136, UI_FG, UI_FG)
  --left panel header
  prints(current_research and TECH[current_research].name or 'No Active Research', lpw/2 - rw/2, 1)
  rectr(2, 8, lpw - 3, lph - 14, UI_BG, UI_FG, false)
  prints('Available Research', 21, lph - 5)
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
      sspr(ITEMS[v].sprite_id, 35 + ((k-1)*10), 40, ITEMS[v].color_key)
    end
    prints(TECH[current_research].time .. 's', 37, 30, 0, 6)
    --current research icon
    pokey(1,12,3,3,3,12,1)
    --current research recipe icons
    for k, v in ipairs(TECH[current_research].requirements) do
      draw_item_stack(48 + (k-1)*8, 19, {id = v.id, count = 1})
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

end

function create_research_screen()
  return{
    sw = print('Technology Tree',0,-10,0,false,1,true),
    rw = print(TECH[current_research].name,0,-10,0,false,1,true),
    lpw = 101, --left panel width
    lph = 57, --left panel height

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
      pokey(1,12,3,3,3,12,1)  --current research recipe icons
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
              pokey(s.page, s.id, s.w, s.h, 3 + x*25, self.lph + 4 + y*25, s.color_key)
              --sspr(s.id, 2 + x*25, self.lph + 3 + y*25, s.color_key, s.scale, 0, 0, s.w, s.h)
            else
              sspr(s.id, 2 + x*25, self.lph + 3 + y*25, s.color_key, s.scale, 0, 0, s.w, s.h)
            end
          end
          i = i + 1
        end
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