LAB_ID = 396
LAB_TICKRATE = 5
LAB_ANIM_TICKRATE = 0
LAB_ANIM_TICK = 0

local Lab = {
  x = 0,
  y = 0,
  id = 22,
  type = 'research_lab',
  input = {},
  dummy_keys = {},
  progress = 10,
  current_research = {name = 'Automation 1', id = 1},
}

function Lab:open()
  return {
    x = 240 - 83 - 1,
    y = 1,
    w = 83,
    h = 66,
    ent_key = self.x .. '-' .. self.y,
    close = function(self, sx, sy)
      local btn = {x = self.x + self.w - 7, y = self.y + 1, w = 5, h = 5}
      if sx >= btn.x and sy < btn.x + btn.w and sy >= btn.y and sy <= btn.y + btn.h then
        return true
      end
      return false
    end,
    draw = function(self)
      local txt = ITEMS[ENTS[self.ent_key].id].fancy_name
      local ent = ENTS[self.ent_key]
      box(self.x, self.y, self.w, self.h, 8, 9)
      rect(self.x + 1, self.y + 1, self.w - 2, 9, 9)
      --close button
      sspr(CLOSE_ID, self.x + self.w - 7, self.y + 2, 0)
      prints(txt, self.x + self.w/2 - print(txt, 0, -10, 0, false, 1, true)/2, self.y + 2, 0, 4)
      prints(ent.current_research.name, self.x + self.w/2 - print(ent.current_research.name, 0, -10, 0, false, 1, true)/2, self.y + 12, 0, 4)
      for i = 1, 6 do
        box(self.x + 4 + (i - 1)*13, self.y + 50, 10, 10, 0, 9)
        if ent.input[i].count > 0 then
          draw_item_stack(self.x + 5 + (i - 1)*13, self.y + 51, ent.input[i])
        end
      end
      --progress bar
      box(self.x + 10, self.y + 20, self.w - 20, 6, 0, 9)
      if ent.progress > 0 then

      end
    end,
    click = function(self, sx, sy)
      if self:close(sx, sy) then
        window = nil
        return true
      end
      return false
    end,
    is_hovered = function(self, x, y)
      return x >= self.x and x < self.x + self.w and y >= self.y and y < self.y + self.h and true or false
    end,
  }
end

function Lab:draw()
  local sx, sy = world_to_screen(self.x, self.y)
  if self.progress > 0 and TICK%60 > math.random(60) then
    local r =  math.random()
    if r > 0.75 then
      pal(9, 4)
    elseif r > 0.5 then
      pal(10, 4)
    else
      pal(10, 11)
    end
    sspr(LAB_ID, sx, sy, 6, 1, 0, 0, 3, 3)
    pal()
  else
    sspr(LAB_ID, sx, sy, 6, 1, 0, 0, 3, 3)
  end
end

function Lab:draw_hover_widget(x, y)
  local width = print(ITEMS[self.id].fancy_name, 0, -10, 0, false, 1, true)
  local w, h = 75, 50
  local sx, sy = clamp(x or cursor.x + 5, 0, 240 - width), clamp(y or cursor.y + 5, 0, 136 - h)
  box(sx, sy, w, h, 8, 9)
  rect(sx + 1, sy + 1, w - 2, 9, 9)
  prints(ITEMS[self.id].fancy_name, sx + w/2 - width/2, sy + 2)
end

function Lab:update()
  return
end

function Lab:request(keep)
  
end

function new_lab(x, y, dummy_keys)
  -- local slotmap = {
  --   [1] = ,
  --   [2] = ,
  --   [3] = ,
  --   [4] = ,
  --   [5] = ,
  --   [6] = ,
  -- }
  local newlab = {
    x = x,
    y = y,
    type = 'research_lab',
    id = 22,
    input = {},
    progress = 10,
    dummy_keys = dummy_keys,
  }
  for i = 1, 6 do
    newlab.input[i] = {id = 22 + i, count = 1}
  end
  setmetatable(newlab, {__index = Lab})
  return newlab
end