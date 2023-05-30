UI_ANCHOR = 435
UI_CLOSE = 437
UI_BG = 8
UI_FG = 9
CRAFT_ROWS = 6
CRAFT_COLS = 8

gui = {}

function gui.box(x, y, w, h, bg, fg)
  rectb(x, y, w, h, fg)
  rect(x + 1, y + 1, w - 2, h - 2)
end

function gui.draw_item_stack(x, y, stack)
  sspr(ITEMS[stack.id].sprite_id, x, y, ITEMS[stack.id].color_key)
  local sx, sy = stack.count < 10 and x + 5 or x + 3, y + 5
  prints(stack.count, sx, sy)
end

function prints(text, x, y, bg, fg)
  bg, fg = bg or 0, fg or 4
  print(text, x - 1, y, bg, false, 1, true)
  print(text, x    , y, fg, false, 1, true)
end

function gui.draw_panel(x, y, w, h, bg, fg, label)
  local text_width = print(label, 0, -10, 0, false, 1, true)
  if text_width > w + 7 then w = text_width + 7 end
  pal(1, fg)
  pal(8, fg)
  sspr(UI_CORNER, x, y, 0)
  sspr(UI_CORNER, x + w - 8, y, 0, 1, 1)
  pal(8, 8)
  sspr(UI_CORNER, x + w - 8, y + h - 8, {0, 8}, 1, 3)
  sspr(UI_CORNER, x, y + h - 8, {0, 8}, 1, 2)
  pal()
  rect(x + 6, y, w - 12, 6, fg) -- top header
  rect(x, y + 6, w, 3, fg) -- header lower-fill
  rect(x + 2, y + 9, w - 4, h - 12, bg) -- background fill
  rect(x, y + 7, 2, h - 13, fg) -- left border
  rect(x + w - 2, y + 7, 2, h - 13, fg) -- right border
  rect(x + 6, y + h - 2, w - 12, 2, fg) -- bottom border
  rect(x + 2, y + h - 3, w - 4, 1, fg) -- bottom footer fill
  prints(label, x + w/2 - text_width/2, y + 2, 0, 4) -- header text
  --sspr(CLOSE_ID, x + w - 9, y + 2, 0) -- close button
end