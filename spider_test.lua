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
-- joint1: position of the first leg joint (positioned on the spiders body)
-- joint2: position of the second leg joint (dist = bone1Length)
-- foot: position of the legs foot (based on the target position)
-- bone1Length: length of the bone between joint1 and joint2
-- bone2Length: length of the bone between joint2 and foot
-- angle1: angle between joint1 and joint2
-- angle2: angle between joint2 and foot
-- offset: the offsetted position the legs first joint is placed based on the spiders position
-- targetPos: new target position for the leg which is calculated after a certain
-- distance to the previous position has been reached
-- currentTargetPos: for animating the leg movement
--function new_leg(offset, bone1Length, bone2Length, updateDist, flipped)
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
    new_leg(vec2(-15, 0), 20, 45, 25, true),
    new_leg(vec2(-10, 5), 20, 45, 30, true),
    -- new_leg(vec2(-13, 0), 20, 45, 24, true),
    -- new_leg(vec2( -8, 0), 20, 45, 24, true),

    -- new_leg(vec2(  8, 0), 20, 22, 24),
    -- new_leg(vec2( 13, 0), 30, 30, 24),
    new_leg(vec2( 10, 5), 30, 40, 30),
    new_leg(vec2( 15, 0), 30, 40, 25)

  },
  draw = function (self)
    elli(self.x, self.y, self.radius.x, self.radius.y, self.color)
    circ(self.x + self.eyes.left.x, self.y + self.eyes.left.y, self.eyes.radius, self.eyes.color)
    circ(self.x + self.eyes.right.x, self.y + self.eyes.right.y, self.eyes.radius, self.eyes.color)
    circ(self.x + self.eyes.left.x, self.y + self.eyes.left.y, self.eyes.radius - 2, 11)
    circ(self.x + self.eyes.right.x, self.y + self.eyes.right.y, self.eyes.radius - 2, 11)
    for k, v in pairs(self.legs) do
      
      v:draw()
    end
    pix(self.x, self.y, 9)
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

-- joint1: position of the first leg joint (positioned on the spiders body)
-- joint2: position of the second leg joint (dist = bone1Length)
-- foot: position of the legs foot (based on the target position)
-- bone1Length: length of the bone between joint1 and joint2
-- bone2Length: length of the bone between joint2 and foot
-- angle1: angle between joint1 and joint2
-- angle2: angle between joint2 and foot
-- offset: the offsetted position the legs first joint is placed based on the spiders position
-- targetPos: new target position for the leg which is calculated after a certain
-- distance to the previous position has been reached
-- currentTargetPos: for animating the leg movement
function TIC()

	if key(23) then spider.y = spider.y - 1 end
	if key(1)  then spider.x = spider.x - 1 end
	if key(19) then spider.y = spider.y + 1 end
	if key(4)  then spider.x = spider.x + 1 end

	cls(0)
	print("CR4P-SPYD3RT40N",84,68, 8)
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
  --data, x, y, label, bg, fg, text_bg, text_fg)
  --ui.draw_text_window(info, 0, 0, 'Left-leg', 0, 2, 0, 4)
	t=t+1
end

-- <TILES>
-- 000:0011110001111100111888001188880011888800118888000000000000000000
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
