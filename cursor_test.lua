-- title:   game title
-- author:  game developer, email, etc.
-- desc:    short description
-- site:    website link
-- license: MIT License (change this to your license of choice)
-- version: 0.1
-- script:  lua

t = 0
line = 0
m = {
  x = 0,
  y = 0,
  lx = 0,
  ly = 0,
  l = false,
  ll = false,
  mid = false,
  lm = false,
  r = false,
  lr = false,
  sx = 0,
  sy = 0,
  held_l = false,
  held_r = false,
  drag = false,
  hold_time = 0,
  dragloc = false,
  droploc = false,
}

local tr = trace

function trace(message)
  line = line + 1
  tr(' ' .. line .. ': ' .. message)
end

function update_mouse_state()
  local x, y, l, mid, r, sx, sy = mouse()

  if l and m.l and not m.held_l then
    m.held_l = true
    m.dragloc = {x = x, y = y}
    m.droploc = false
    drag_start(x, y, 'left')
  end

  if not l and m.l then
    if m.held_l then
      drag_end(x, y, 'left')
    else
      mouse_up(x, y, 'left')
    end
    m.held_l = false
  end

  if not r and m.r then
    if m.held_r then
      drag_end(x, y, 'right')
    else
      mouse_up(x, y, 'right')
    end
    m.held_r = false
  end

  if r and m.r and not m.held_r then
    m.held_r = true
    m.dragloc = {x = x, y = y}
    m.droploc = false
    drag_start(x, y, 'right')
  end

  if m.held_l or m.held_r then
    m.hold_time = m.hold_time + 1
  end

  m.lx = m.x
  m.ly = m.y
  m.ll = m.l
  m.lm = m.mid
  m.lr = m.r 

  m.x = x
  m.y = y
  m.l = l
  m.mid = mid
  m.r = r
  m.sx = sx
  m.sy = sy
end

function mouse_down(x, y, side)
  trace('mouse-' .. side .. ' pressed @ ' .. x .. ',' .. y)
end

function mouse_up(x, y, side)
  m.droploc = {x = x, y = y}
  trace('mouse-' .. side .. ' released @ ' .. x .. ',' .. y)
end

function drag_start(x, y, side)
  trace('drag-' .. side .. ' started @ ' .. x .. ',' .. y)
end

function drag_end(x, y, side)
  trace('drag-' .. side .. ' ended @ ' .. x .. ',' .. y)
end

function print_mouse_state()
  print('Left: ' .. tostring(m.l), 1, 1*7 - 6, 12, true, 1, true)
  print('Left Hold: ' .. tostring(m.held_l), 1, 2*7 - 6, 12, true, 1, true)
  print('Middle: ' .. tostring(m.mid), 1, 3*7 - 6, 12, true, 1, true)
  print('Right: ' .. tostring(m.r), 1, 4*7 - 6, 12, true, 1, true)
  print('Right Hold: ' .. tostring(m.held_r), 1, 5*7 - 6, 12, true, 1, true)
  print('Coords: ' .. m.x .. ',' .. m.y, 1, 6*7 - 6, 12, true, 1, true)
  print('Hold Time: ' .. m.hold_time, 1, 7*7 - 6, 12, true, 1, true)
end

function TIC()
	poke(0x3FFB, 258)
  cls(10)
  update_mouse_state()
  print_mouse_state()

  if m.dragloc then
    if not m.droploc then
      rectb(math.min(m.dragloc.x, m.x), math.min(m.dragloc.y, m.y), math.abs(m.dragloc.x - m.x) + 1, math.abs(m.dragloc.y - m.y) + 1, 2)
    else
      rectb(math.min(m.dragloc.x, m.droploc.x), math.min(m.dragloc.y, m.droploc.y), math.abs(m.dragloc.x - m.droploc.x) + 1, math.abs(m.dragloc.y - m.droploc.y) + 1, 2)
    end
  end

	t = t + 1
end

-- <SPRITES>
-- 001:cd000000ccd00000cde0000000d0000000000000000000000000000000000000
-- 002:c0000000cc000000ccd00000cde0000000000000000000000000000000000000
-- 003:e0000000ce000000cce00000cdf0000000df0000000000000000000000000000
-- 004:ccf00000cf000000000000000000000000000000000000000000000000000000
-- 005:00c0000000c0000000ccc000c0ccc0000cccc00000dd00000000000000000000
-- 006:000000000cc000000ccc0000cccc0000cccc00000dd000000000000000000000
-- </SPRITES>

-- <WAVES>
-- 000:00000000ffffffff00000000ffffffff
-- 001:0123456789abcdeffedcba9876543210
-- 002:0123456789abcdef0123456789abcdef
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- </SFX>

-- <TRACKS>
-- 000:100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </TRACKS>

-- <PALETTE>
-- 000:1a1c2c5d275db13e53ef7d57ffcd75a7f07038b76425717929366f3b5dc941a6f673eff7f4f4f494b0c2566c86333c57
-- </PALETTE>

