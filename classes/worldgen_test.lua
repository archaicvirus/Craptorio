-- title:   game title
-- author:  ArchaicVirus
-- desc:    perlin noise terraingenerator
-- site:    website link
-- license: MIT License (change this to your license of choice)
-- version: 0.1
-- script:  lua

WATER = 257
LAND = 256
local perlin = require('\\libs\\perlin_noise')
local simplex = require('\\libs\\open_simplex_noise')
local mapWidth, mapHeight = 50, 50
local miniMapWidth, miniMapHeight = 50, 50
local cell_size = 8
local x, y = 0, 0
local terrain = {}
local ores = {}
local mpos = {x = (240 - miniMapWidth) - 5, y = 5}
math.randomseed(tstamp())
seed = tstamp()
--coastal settings
local offset_x = math.floor(math.random(-1000, 1000))
local offset_y = math.floor(math.random(-1000, 1000))
local offsetX = math.random()
local offsetY = math.random()
local freq = 2.0
local radius = 0.5
local thresh = 0.65

simplex.seed(tstamp())

local function generateIsland(width, height)
  local islandMap = {}
  local cx, cy = width / 2, height / 2
  local maxDistance = math.min(width, height) / 2

  local function circularMask(xx, yy, cx, cy, rad, variation)
      local distance = math.sqrt((cx - xx) ^ 2 + (cy - yy) ^ 2)
      local noise = simplex.FractalSum(simplex.Noise2D, 8, (xx + offsetX * seed) / width, (yy + offsetY * seed) / height)
      local threshold = rad * (1 - variation / 2 + noise * variation)
      return distance < threshold
  end

  for i = 1, height do
      islandMap[i] = {}
      for j = 1, width do
        local isLand = circularMask(j, i, cx, cy, maxDistance, 0.4)
        local tile = isLand and "land" or "water"
        islandMap[i][j] = tile
      end
  end

  return islandMap
end

function generateOreField(width, height, oreFrequency, oreRadius, oreThreshold)
  math.randomseed(tstamp())
  simplex.seed(tstamp())
  offsetX = math.random()
  offsetY = math.random()
  local oreField = {}

  local function oreMask(xx, yy, radi, thr)
    --local seed = tstamp()
      local noise = simplex.FractalSum(simplex.Noise2D, 8, (xx + offsetX * seed) / width * oreFrequency, (yy + offsetY * seed) / height * oreFrequency)
      return noise > thr and noise < thr + radi
  end

  for i = 1, height do
      oreField[i] = {}
      for j = 1, width do
        local isOre = oreMask(j, i, oreRadius, oreThreshold)
        local tile = isOre and "ore" or "none"
        oreField[i][j] = tile
      end
  end

  return oreField
end

function generate_map()
  terrain = generateIsland(mapWidth, mapHeight)
  local copper = generateOreField(mapWidth, mapHeight, freq, radius, thresh)
  local iron = generateOreField(mapWidth, mapHeight, freq - 0.2, radius + 2, thresh - 0.1)
  for i = 1, mapHeight do
    for j = 1, mapWidth do
      if copper[i][j] == "ore" and terrain[i][j] == "land" then
        terrain[i][j] = 'copper'
      end
      if iron[i][j] == "ore" and terrain[i][j] == "land" then
        terrain[i][j] = 'iron'
      end
    end
  end
end

generate_map()

function TIC()
  cls(0)
  if key(28) then offset_x = offset_x - 1  generate_map() end --1
  if key(29) then offset_x = offset_x + 1  generate_map() end --2
  if key(17) then offset_y = offset_y - 1  generate_map() end --q
  if key(23) then offset_y = offset_y + 1  generate_map() end --w
  if key( 1) then freq = freq - 1  generate_map() end --a
  if key(19) then freq = freq + 1  generate_map() end --s
  if key(26) then  radius = radius  - 0.01 generate_map() end --z
  if key(24) then  radius = radius  + 0.01 generate_map() end --x
  if key(37) then thresh = thresh - 0.05 generate_map() end -- (-)
  if key(38) then thresh = thresh + 0.05 generate_map() end -- (+)
  if key(60) then x = x - 1 end --left
  if key(61) then x = x + 1 end --right
  if key(58) then y = y - 1 end --up
  if key(59) then y = y + 1 end --down

  for i = 1, 17 do
    for j = 1, 30 do
      local variance = math.floor(simplex.Noise2D((j + x) * 100, (i + y)*3) * 4) % 4 or 0
      local color
      if i + y > 0 and j + x > 0 and j + x <= mapWidth and i + y <= mapHeight then
        if terrain[i + y][j + x] == 'land' then
          color = 291
        elseif terrain[i + y][j + x] == 'iron' then
        color = 260 + (variance % 3)
        elseif terrain[i + y][j + x] == 'copper'then
          color = 273 + (variance % 3)
        elseif terrain[i + y][j + x] == 'water' then
          color = 279
        end
        spr(color, j * 8 - 8, i * 8 - 8, 0, 1, 0, variance)
      else
        spr(279, j * 8 - 8, i * 8 - 8, 0, 1, 0, variance)
      end
    end
  end

  rectb(mpos.x, mpos.y, miniMapWidth + 2, miniMapHeight + 2, 15)
  for i = 1, miniMapHeight do
    for j = 1, miniMapWidth do
      local variance = math.floor(simplex.Noise2D((j + x) * 100, (i + y)*3) * 4) % 2 or 0
      if i + y > 0 and j + x > 0 and j + x <= mapWidth and i + y <= mapHeight then      
        if terrain[i + y][j + x] == 'land' then
          color = 5 + variance
        elseif terrain[i + y][j + x] == 'copper' then
          color = 2 + variance
        elseif terrain[i + y][j + x] == 'iron' then
          color = 13 + variance
        elseif terrain[i + y][j + x] == 'water' then
          color = 8 + variance
        end
        pix(mpos.x + j, mpos.y + i, color)
      else
        pix(mpos.x + j, mpos.y + i, 8 + variance)
      end
    end
  end

  local loc = 'x: '  .. x  .. ', y: ' .. y
  local off = 'x: '  .. offset_x  .. ', y: ' .. offset_y
  print(  'Offset:'  .. off   , 0,  0, 2, false, 1, true)
  print(    'Freq:'  .. freq  , 0,  6, 2, false, 1, true)
  print(  'Radius:'  .. radius, 0, 12, 2, false, 1, true)
  print('Threshold:' .. thresh, 0, 18, 2, false, 1, true)
  print('Location:'  .. loc   , 0, 24, 2, false, 1, true)
end


-- <TILES>
-- 019:0000000000000000000000000000002000000000000000000000000000000000
-- </TILES>

-- <SPRITES>
-- 000:5555565556555555555555555555655555555556655555555555555555565555
-- 001:5555565556555555555555555555655555555556655555555555555555565555
-- 002:5555565556555555555555555555655555555556655555555555555555565555
-- 003:5555565556555555555555555555655555555556655555555555555555565555
-- 004:5d55e5555ee555e5dd55d555555e555e5de555d5e5555e555ed555e5555d555d
-- 005:5f5555c555f55555555555555555d5555c55555555555d555e555df55d555555
-- 006:555d55555ce55de55df5555fd5e555555555de555d555d555d5f555d5555d555
-- 007:5555565556555555555555555555655555555556655555555555555555565555
-- 008:4444444443443444444444444444443434444444444344444444444443444434
-- 009:4444444443443444444444444444443434444444444344444444444443444434
-- 010:9999999999999999999999999999999999999999999999999999999999999999
-- 011:9999999999999999999999999999999999999999999999999999999999999999
-- 012:9899a99999b999999a99898999999999989a99b9999899a99a9999999989b899
-- 013:9999999999899989999989999999998998999999999899999899989999999999
-- 014:9999999999899989999989999999998998999999999899999899989999999999
-- 015:9999999999899989999989999999998998999999999899999899989999999999
-- 016:5555565556555555555555555555655555555556655555555555555555565555
-- 017:5555455553255345534555555545555445553455545552555352553535554555
-- 018:5355525555545555535542532555355455555555524455555335543555554555
-- 019:5554555525555535552555455543555554555453555554355435523555545555
-- 020:5555565556555555555555555555655555555556655555555555555555565555
-- 021:5565555555555565555555556555555555556555555555565555555555565555
-- 022:5555565556555555555555555555655555555556655555555555555555565555
-- 023:9899a99999b999999a99898999999999989a99b9999899a99a9999999989b899
-- 024:5555565556555555555555555555655555555556655555555555555555565555
-- 025:5555655555555555555555566555555555565555555555555555556555655555
-- 026:5555565556555555555555555555655555555556655555555555555555565555
-- 027:5555565556555555555555555555655555555556655555555555555555565555
-- 028:5d55e5555ee555e5dd55d555555e555e5de555d5e5555e555ed555e5555d555d
-- 029:555d55555ce55de55df5555fd5e555555555de555d555d555d5f555d5555d555
-- 030:5f5555c555f55555555555555555d5555c55555555555d555e555df55d555555
-- 031:5555565556555555555555555555655555555556655555555555555555565555
-- 032:6555555576555555655555557655555565555555765555556565656506767676
-- 033:5555555555555555555555555555555555555555555555556565656576767676
-- 034:0676767665656565765555556555555565555555765555556565656506767676
-- 035:5755565555755655557555575555657565565575565656555655556555555565
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

