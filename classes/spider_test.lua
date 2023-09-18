-- title:   game title
-- author:  game developer, email, etc.
-- desc:    short description
-- site:    website link
-- license: MIT License (change this to your license of choice)
-- version: 0.1
-- script:  lua

t=0
x=96
y=24
require('classes/vec2D')
require('classes/ik')
require('classes/ui')

UI_CORNER = 0
sspr = spr
spider = {
  x = 120,
  y = 68,
  eyes = {left = {x = -5, y = 3}, right = { x = 5, y = 3}, radius = 3, color = 0},
  radius = {x = 15, y = 8},
  color = 9,
  legs = {
    -- new_leg(vec2(-55, 0), 75, 200, 45, true),
    -- new_leg(vec2(-50, 0), 75, 150, 50, true),
    -- new_leg(vec2(-35, 0), 75, 150, 60, true),
    -- new_leg(vec2(-20, 0), 50, 110, 60, true),
    -- new_leg(vec2( 20, 0), 50, 110, 65),
    -- new_leg(vec2( 35, 0), 75, 150, 62),
    -- new_leg(vec2( 50, 0), 75, 150, 52),
    -- new_leg(vec2( 55, 0), 75, 200, 46),
    new_leg(vec2(-8, 0), 15, 34, 20, true),
    new_leg(vec2( 8, 0), 15, 34, 20),
    new_leg(vec2(-5, 5), 15, 34, 20, true),
    new_leg(vec2( 5, 5), 15, 34, 20),
    --new_leg(vec2(-11, 2), 20, 38, 24, true),
    --new_leg(vec2( -8, 0), 20, 45, 24, true),

    -- new_leg(vec2(  8, 0), 20, 22, 24),
    -- new_leg(vec2( 13, 0), 30, 30, 24),

  },
  draw = function (self)
    -- elli(self.x, self.y, self.radius.x, self.radius.y, self.color)
    -- circ(self.x + self.eyes.left.x, self.y + self.eyes.left.y, self.eyes.radius, self.eyes.color)
    -- circ(self.x + self.eyes.right.x, self.y + self.eyes.right.y, self.eyes.radius, self.eyes.color)
    -- circ(self.x + self.eyes.left.x, self.y + self.eyes.left.y, self.eyes.radius - 2, 11)
    -- circ(self.x + self.eyes.right.x, self.y + self.eyes.right.y, self.eyes.radius - 2, 11)
    for k, v in pairs(self.legs) do
      
      v:draw()
    end
    sspr(16, self.x - 12, self.y - 8, 1, 1, 0, 0, 3, 2)
    --pix(self.x, self.y, 9)
  end,
  update = function (self)
    for k, v in pairs(self.legs) do
      self.legs[k]:update(vec2(spider.x, spider.y))
    end
  end,
}

function prints(text, x, y, bg, fg)
  bg, fg = bg or 0, fg or 4
  print(text, x - 1, y, bg, false, 1, true)
  print(text, x    , y, fg, false, 1, true)
end

function pal(c0, c1)
  if not c0 and not c1 then
    for i = 0, 15 do
      poke4(0x3FF0 * 2 + i, i)
    end
  elseif type(c0) == 'table' then
    for i = 1, #c0, 2 do
      poke4(0x3FF0*2 + c0[i], c0[i + 1])
    end
  else
    poke4(0x3FF0*2 + c0, c1)
  end
end

function TIC()
  if key(23) then spider.y = spider.y - 1 end
  if key(1)  then spider.x = spider.x - 1 end
  if key(19) then spider.y = spider.y + 1 end
  if key(4)  then spider.x = spider.x + 1 end

  cls(0)
  print("CR4P-SPYD3RTR0N",84,68, 8)
  spider:update()
  spider:draw()
  local info = {
    [ 1] = 'Joint1:          ' .. tostring(spider.legs[4].joint1),
    [ 2] = 'Joint2:          ' .. tostring(spider.legs[4].joint2),
    [ 3] = 'Foot:            ' .. tostring(spider.legs[4].foot),
    [ 4] = 'Bone1Length:     ' .. tostring(spider.legs[4].bone1Length),
    [ 5] = 'Bone2Length:     ' .. tostring(spider.legs[4].bone2Length),
    [ 6] = 'Angle1:          ' .. tostring(spider.legs[4].angle1),
    [ 7] = 'Angle2:          ' .. tostring(spider.legs[4].angle2),
    [ 8] = 'Offset:          ' .. tostring(spider.legs[4].offset),
    [ 9] = 'TargetPos:       ' .. tostring(spider.legs[4].targetPos),
    [10] = 'CurrentTargetPos:' .. tostring(spider.legs[4].currentTargetPos),
  }
  --ui.draw_text_window(info, 0, 0, 'Left-leg', 0, 2, 0, 4)
  t=t+1
end

-- <TILES>
-- 000:0111110011111100111888001188880011888800118888000000000000000000
-- 001:00444400002222000022220000bbbb0000bbbb00002222000022220000444400
-- 002:098c8900098f8900098c8900098f8900098c8900098f890000999000000a0000
-- 003:0a998a000a998a000a998a000a998a000a998a000a998a000a998a000a998a00
-- 004:000000000000000000dbbd0000bceb0000becb0000dbbd000000000000000000
-- 016:11111111111111a91111aa99111a999911a9999a1a99999a1a9999991a999999
-- 017:1111112199dd88d89c77c9c8c7657c99ce77eca9decceda9aceeca999aaaa999
-- 018:1111111111111111881111118881111198881111998881119988811199988111
-- 019:000000000000000000000000000000000000000000000000200dd00200300300
-- 032:1a9999991a99999211a99999111a99291111aa99111111aa1111111a11111111
-- 033:9999999999999929999999992999929299999999999999aaaaaaaa1111111111
-- 034:99988111999881119998111199911111aa111111111111111111111111111111
-- </TILES>

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
-- 000:1010105d245db13e50ef9157ffff6daee65061be3c047f5005344c185dc95999f6e6eaf2b6baba8d8d9d444460282038
-- </PALETTE>

