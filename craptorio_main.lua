-- title:   craptorio
-- author:  @ArchaicVirus
-- desc:    De-make of Factorio
-- site:    website link
-- license: MIT License
-- version: 0.3
-- script:  lua

local new_belt      = require('\\libs\\belt')
local new_inserter  = require('\\libs\\inserter')
local aspr          = require('\\libs\\affine_sprite')
local ITEMS         = require('\\libs\\item_definitions')
local draw_cable    = require('\\libs\\cable')
local new_pole      = require('\\libs\\power_pole')

--------------------COUNTERS--------------------------
TICK              = 0
BELT_TICKRATE     = 5
BELT_MAXTICK      = 3
BELT_TICK         = 0
INSERTER_TICKRATE = 4

-------------GAME-OBJECTS-AND-CONTAINERS---------------
BELTS, INSERTERS, POLES = {}, {}, {}
GROUND_ITEMS = {}
cursor = {
  x = 8,
  y = 8,
  id = 352,
  last_x = 8,
  last_y = 8,
  last_tile_x = 8,
  last_tile_y = 8,
  last_left = false,
  last_mid = false,
  last_right = false,
  rotation = 0,
  last_rotation = 0,
  item = 'belt',
}
--------------------FUNCTIONS-------------------------
function get_key(x, y)
  return tostring(x) .. '-' .. tostring(y)
end

function draw_pixel_sprite(item_id, x, y)
  for i = 1, 3 do
    for j = 1, 3 do
      local index = ((i - 1) * 3) + j
      if ITEMS[item_id].pixels[index] ~= 0 then
        pix(x + j - 1, y + i - 1, ITEMS[item_id].pixels[index])
      end
    end
  end
end

function add_belt(x, y, rotation)
  local key = tostring(x) .. '-' .. tostring(y)
  if not BELTS[key] then
    local belt = new_belt({x = x, y = y}, rotation)
    table.insert(BELTS, belt)
    local index = #BELTS
    BELTS[key] = BELTS[index]
    BELTS[key].index = index
  elseif BELTS[key] then
    BELTS[key]:rotate(rotation)
    --return
    --BELTS[key]:set_curved()
  end
  --BELTS[key]:set_output()
  --check surrounding area for belts to update n,s,e,w
  local tiles = {[1]={x=x,y=y-8},[2]={x=x+8,y=y},[3]={x=x,y=y+8},[4]={x=x-8,y=y}}
  for i = 1, 4 do
    local k = tostring(tiles[i].x) .. '-' .. tostring(tiles[i].y)
    if BELTS[k] then BELTS[k]:set_curved() end
    --if INSERTERS[k] then INSERTERS[k]:set_input() end
  end
  --check if should be curved
  BELTS[key]:set_curved()
  --sort_belt_render_order()
  if GROUND_ITEMS[key] and GROUND_ITEMS[key][1] > 0 then
    BELTS[key].lanes[2][4] = GROUND_ITEMS[key][1]
    GROUND_ITEMS[key][1] = 0
  end
end

function remove_belt(x, y)
  local key = tostring(x) .. '-' .. tostring(y)
  if BELTS[key] then
    for i = 1, #BELTS do
      if BELTS[i] == BELTS[key] then
        BELTS[key] = nil
        table.remove(BELTS, i)
        --BELTS[i] = nil
        break
      end
    end
  end
  --check surrounding area for belts to update n,s,e,w
  local tiles = {[1]={x=x,y=y-8,z=3},[2]={x=x+8,y=y,z=0},[3]={x=x,y=y+8,z=1},[4]={x=x-8,y=y,z=2}}
  for i = 1, 4 do
    local k = tostring(tiles[i].x) .. '-' .. tostring(tiles[i].y)
    if BELTS[k] then BELTS[k]:set_curved() end
  end
  --sort_belt_render_order()
end

function update_belts()
  for key, belt in pairs(BELTS) do
    --BELT table is double indexed with position, eg. BELTS[1] = BELTS['x-y']
    if key == (tostring(belt.pos.x .. '-' ..belt.pos.y)) then
      belt:update()
    end
  end
end

function add_inserter(x, y, rotation)
  local key = x .. '-' .. y
  if INSERTERS[key] then
    if INSERTERS[key].rot ~= rotation then
      INSERTERS[key]:rotate(rotation)
    end
  else
    local new_ins = new_inserter({x = x, y = y}, rotation)
    table.insert(INSERTERS, new_ins)
    local index = #INSERTERS
    INSERTERS[key] = INSERTERS[index]
    INSERTERS[key].index = index
    trace('created new ins ->' .. #INSERTERS)
  end
end

function remove_inserter(x, y)
  local key = tostring(x) .. '-' .. tostring(y)
  if INSERTERS[key] then
    for i = 1, #INSERTERS do
      if INSERTERS[i] == INSERTERS[key] then
        table.remove(INSERTERS, i)
        INSERTERS[key] = nil
        break
      end
    end
  end
end

function update_inserters()
  for key, inserter in ipairs(INSERTERS) do
    inserter:update()
  end
end

function add_pole(x, y)
  local key = get_key(x,y)
  if not POLES[key] then
    local pole = new_pole({x = x, y = y})
    table.insert(POLES, pole)
    local index = #POLES
    POLES[key] = POLES[index]
    POLES[key].index = #POLES
  end
end

function get_cell(x, y)
  return x - (x % 8), y - (y % 8)
end

function get_flags(x, y, flags)
  local cell_x, cell_y = get_cell(x, y)
  if type(flags) == 'table' then
    local flag = ''
    for i = flags[1], flags[2] do
      flag = flag .. (fget(mget(cell_x//8, cell_y//8), i) == true) and '1' or '0'
    end
    return flag
  end
  return fget(mget(cell_x//8, cell_y//8), flags)
end

function move_cursor(dir, x, y)
  if dir == 'up' then
    if get_flags(cursor.x, cursor.y - 8, 0) then cursor.y = cursor.y - 8 sfx(0, 'C-4', 4, 0, 15, 5) end
  elseif dir == 'down' then
    if get_flags(cursor.x, cursor.y + 8, 0) then cursor.y = cursor.y + 8 sfx(0, 'C-4', 4, 0, 15, 5) end
  elseif dir == 'left' then
    if get_flags(cursor.x - 8, cursor.y, 0) then cursor.x = cursor.x - 8 sfx(0, 'C-4', 4, 0, 15, 5) end
  elseif dir == 'right' then
    if get_flags(cursor.x + 8, cursor.y, 0) then cursor.x = cursor.x + 8 sfx(0, 'C-4', 4, 0, 15, 5) end
  end
  if dir == 'mouse' then
    if not (cursor.last_x == x and cursor.last_y == y) then
      local cell_x, cell_y = get_cell(x, y)
      if not (cell_x == cursor.x and cell_y == cursor.y) then
        cursor.x, cursor.y = cell_x, cell_y
      end
    end
  end
end

function cycle_placeable()
  if cursor.item == 'belt' then
    cursor.item = 'inserter'
  elseif cursor.item == 'inserter' then
    cursor.item = 'pole'
  elseif cursor.item == 'pole' then
    cursor.item = 'pointer'
  elseif cursor.item == 'pointer' then
    cursor.item = 'belt'
  end
end

function add_item(id)
  local key = tostring(cursor.x) .. '-' .. tostring(cursor.y)
  if BELTS[key] then
    BELTS[key].lanes[1][8] = id
    BELTS[key].lanes[2][8] = id
    --BELTS[key].lanes[2][8] = id
  end
end

function draw_debug()
  --count belt items
  local n = 0
  for k, v in ipairs(BELTS) do
    for i = 1, 2 do
      for j = 1, 8 do
        if v.lanes[i][j] ~=0 then n = n + 1 end
      end
    end
  end

  local info = false
  local key = get_key(cursor.x, cursor.y)
  local width, height = 60, 100
  if BELTS[key] then info = BELTS[key]:get_info() end
  --if INSERTERS[key] then info = INSERTERS[key]:get_info() end
  --if POLES[key] then info = POLES[key]:get_info() end
  --get TPS
  if info ~= false then
    height = (#info * 6) + 3
    rectb(0, 0, width, height, 12)
    rect(1, 1, width - 2, height - 2, 15)
    for i = 1, #info do
      print(info[i], 2, i*6 - 4, 2, true, 1, true)
    end
  end


  -- local time = math.floor(TICK/(time()/1000))
  -- rectb(0, 115, 45, 21, 5)
  -- rect( 1, 116, 43, 19, 15)
  -- print('BELT:' .. info, 3, 123, 2, true, 1, true)
  -- print('ITEMS:' .. n,      3, 117, 2, true, 1, true)
  -- print('TPS:'    .. time,   3, 129, 2, true, 1, true)
end

function draw_ground_items()
  -- for k, v in ipairs(GROUND_ITEMS) do
  --   trace('GI: ' .. #GROUND_ITEMS)
  --   if v[1] > 0 then
  --     trace('drawing_item ' .. v[1])
  --     trace('x:' .. v[2])
  --     trace('y:' .. v[3])
  --     draw_pixel_sprite(ITEMS[tonumber(v[1])], v[2], v[3])
  --   end
  -- end
  for i = 1, #GROUND_ITEMS do
    if GROUND_ITEMS[i][1] > 0 then
      draw_pixel_sprite(GROUND_ITEMS[i][1], GROUND_ITEMS[i][2], GROUND_ITEMS[i][3])
    end
  end
end

function draw_cursor()
  local key = cursor.x .. '-' .. cursor.y
  if not get_flags(cursor.x, cursor.y, 0) then spr(271, cursor.x, cursor.y, 00, 1, 0, 0, 1, 1) return end
  if cursor.item == 'belt' then
    if not BELTS[key] or (BELTS[key] and BELTS[key].rot ~= cursor.rotation) then
      spr(BELT_ID_STRAIGHT + BELT_TICK, cursor.x, cursor.y, 00, 1, 0, cursor.rotation, 1, 1)
      spr(288, cursor.x, cursor.y, 00, 1, 0, cursor.rotation, 1, 1)
    end
    spr(288, cursor.x, cursor.y, 00, 1, 0, 0, 1, 1)
    --pix(cursor.last_x, cursor.last_y, 5)
  elseif cursor.item == 'inserter' then
    if not INSERTERS[key] or (INSERTERS[key] and INSERTERS[key].rot ~= cursor.rotation) then
      local temp_inserter = new_inserter({x = cursor.x, y = cursor.y}, cursor.rotation)
      temp_inserter:draw()
    end
  elseif cursor.item == 'pole' then
    local temp_pole = new_pole({x = cursor.x, y = cursor.y})
    temp_pole:draw(true)
    --check around cursor to attach temp cables to other poles
  else
    spr(cursor.id, cursor.last_x, cursor.last_y, 00, 1, 0, 0, 1, 1)
    spr(288, cursor.x, cursor.y, 00, 1, 0, 0, 1, 1)
    --pix(cursor.last_x, cursor.last_y, 5)
  end
end

function rotate_cursor()
  cursor.rotation = cursor.rotation + 1
  if cursor.rotation > 3 then cursor.rotation = 0 end
end

function place_tile(x, y, rotation)
  local key = tostring(x) .. '-' .. tostring(y)
  if cursor.item == 'belt' and not INSERTERS[key] then
    add_belt(x, y, rotation)
  elseif cursor.item == 'inserter' and not BELTS[key] then
    add_inserter(x, y, rotation)
  elseif cursor.item == 'pole' then
    add_pole(x, y)
  end
end

function remove_tile(x, y)
  remove_belt(x,y)
  remove_inserter(x,y)
end

function TIC()
  TICK = TICK + 1
  --remove mouse cursor
  poke(0x3FFB, 0x000000, 8)

  cls(0)
  
  --map(0, 0, 30, 17, 0, 0, 00, 1)

  local x, y, left, middle, right = mouse()
  ----------------UPDATE BELTS-----------------
  if TICK % BELT_TICKRATE == 0 then
    BELT_TICK = BELT_TICK + 1
    if BELT_TICK > BELT_MAXTICK then
      BELT_TICK = 0
    end
    update_belts()
  end

  for i = 1, #BELTS do
    BELTS[i].updated = false
    BELTS[i].drawn = false
    BELTS[i]:draw()
  end

  for i = 1, #BELTS do
    if not BELTS[i].drawn then
      BELTS[i]:draw_items()
    end
  end

  if TICK % INSERTER_TICKRATE == 0 then
    update_inserters()
  end

  for k, v in ipairs(INSERTERS) do
    v:draw()
  end

  for k, v in ipairs(POLES) do
    v:draw()
    v.is_hovered = false
  end
  if POLES[1] and POLES[2] then
    local offset  = POWER_POLE_ANCHOR_POINTS['power'][1]
    local offset2 = POWER_POLE_ANCHOR_POINTS['red'][1]
    local offset3 = POWER_POLE_ANCHOR_POINTS['green'][1]
    local p1 = {x = POLES[1].pos.x + offset.x,  y = POLES[1].pos.y + offset.y  - 16}
    local p2 = {x = POLES[2].pos.x + offset.x,  y = POLES[2].pos.y + offset.y  - 16}
    local r1 = {x = POLES[1].pos.x + offset2.x, y = POLES[1].pos.y + offset2.y - 16}
    local r2 = {x = POLES[2].pos.x + offset2.x, y = POLES[2].pos.y + offset2.y - 16}
    local g1 = {x = POLES[1].pos.x + offset3.x, y = POLES[1].pos.y + offset3.y - 16}
    local g2 = {x = POLES[2].pos.x + offset3.x, y = POLES[2].pos.y + offset3.y - 16}
    draw_cable(p1, p2, 4)
    --draw_cable(r1, r2, 2)
    --draw_cable(g1, g2, 6)
  end
  draw_debug()

  ------------------INPUT----------------------
  if btnp(0) then move_cursor('up')    end
  if btnp(1) then move_cursor('down')  end
  if btnp(2) then move_cursor('left')  end
  if btnp(3) then move_cursor('right') end
  if btnp(4) then rotate_cursor()      end --z
  if btn(5)  then add_item(1)          end --x
  if btn(6)  then add_item(2)          end --a
  if btnp(7) then cycle_placeable()    end --s
  ----------------DRAW-CURSOR------------------
  move_cursor('mouse', x, y)
  draw_cursor()

  if (left and not cursor.last_left) or left and (cursor.x ~= cursor.last_tile_x or cursor.y ~= cursor.last_tile_y) then
    place_tile(cursor.x, cursor.y, cursor.rotation)
  end

  if (right and not cursor.last_right) or right and (cursor.x ~= cursor.last_tile_x or cursor.y ~= cursor.last_tile_y) then
    remove_tile(cursor.x, cursor.y)
  end

  local cell_x, cell_y = get_cell(x, y)
  local key = get_key(cell_x, cell_y)
  if POLES[key] then POLES[key].is_hovered = true end
  --if INSERTERS[key] then INSERTERS[key].is_hovered = true end
  --if BELTS[key] then BELTS[key].is_hovered = true end
  draw_ground_items()
  cursor.last_tile_x, cursor.last_tile_y = get_cell(x, y)
  cursor.last_rotation = cursor.rotation
  cursor.last_x, cursor.last_y, cursor.last_left, cursor.last_mid, cursor.last_right = x, y, left, middle, right
  --spr(371, x, y)
  --spr(370, 16, 70)
  --draw_cable({x = 23, y = 70}, {x = x, y = y}, 14)
end

-- <TILES>
-- 001:0e0ecdcde0e0dcdc0e0ecdcde0e0dcdccdcd0e0edcdce0e0cdcd0e0edcdce0e0
-- 002:ffffeeeefdefefdefedfedfeffffeeeeeeeeffffefdefdefedfefedfeeeeffff
-- 003:2ddddddcddddddddddddddddddddddddddddddddddddddddddddddddaddddddb
-- 017:fefefefeefefefeffefefefeefefefeffefefefeefefefeffefefefeefefefef
-- 019:0e0e8d8de0e0d8d80e0e8d8de0e0d8d88d8d0e0ed8d8e0e08d8d0e0ed8d8e0e0
-- 034:0222222034444422222224433444222222244443342222222444444300022222
-- </TILES>

-- <SPRITES>
-- 000:ffffffffddfeeefdddfeeefdddfeeefdeefdddfeeefdddfeeefdddfeffffffff
-- 001:ffffffffdfeeefdddfeeefdddfeeefddefdddfeeefdddfeeefdddfeeffffffff
-- 002:fffffffffeeefdddfeeefdddfeeefdddfdddfeeefdddfeeefdddfeeeffffffff
-- 003:ffffffffeeefdddfeeefdddfeeefdddfdddfeeefdddfeeefdddfeeefffffffff
-- 004:ffffffffeefdddfeeefdddfeeefdddfeddfeeefdddfeeefdddfeeefdffffffff
-- 005:ffffffffefdddfeeefdddfeeefdddfeedfeeefdddfeeefdddfeeefddffffffff
-- 006:fffffffffdddfeeefdddfeeefdddfeeefeeefdddfeeefdddfeeefdddffffffff
-- 007:ffffffffdddfeeefdddfeeefdddfeeefeeefdddfeeefdddfeeefdddfffffffff
-- 008:6560022134500342654001240000000000000000998000003490000089400000
-- 009:003000d003030d0d003000d0000000000000000003340edd03330ddd04330dde
-- 010:0ff0000008ff000000f800000000000000000000000000000000000000000000
-- 011:000000000000000000000000000000000000cdee0000dd000000ee000000e000
-- 012:00000000000000000000000000000000eeeeeeee00000000000000000dddddd0
-- 013:00000000000000000000000000000000eedc000000dd000000ee0000000e0000
-- 015:00dddd00020000d0d020000dd002000dd000200dd000020d0d00002000dddd00
-- 016:00ffffff0fddeeedfdddeeedfdddeeedfeeedddefeeedddefeeedddefdddeeef
-- 017:ffffffffddfeeefdddfeeefdddfeeefdeefdddfeeefdddfeeefdddfeffffffff
-- 018:00000014000001710000111fc11111f0c1111100000011100000f17100000f14
-- 019:0000000044000000004000000004444300f44434ff4000004400000000000000
-- 020:0004000000004000f00040004fff400004444400000044400000043400000043
-- 021:00ffffff0feeeeeefeed4fcdfed4fcd4fed4fcd4fecd4fcdfefccfdefe4ff4ef
-- 022:00ffffff0feeeeeefecddcd4fefccf40fe4ff440fed44dd4fecddcdefefccfef
-- 023:00ffffff0feeeeeefeeddd4ffecdd4fcfefcc4fcfe4ff44ffed44ddefeddddef
-- 024:00ffffff0feeeeeefeedd4fcfedd4fcdfecd4fcdfefcf4fcfe4ff4defed44def
-- 025:0000000004300de003240efd003300ed00000000003300ed03240efe04300dd0
-- 026:000000000e0d00000eff00000de0000000000000000000000000000000000000
-- 027:0000e00d0000e0de0000ede00000de000000e00d0000e0de0000ede00000de00
-- 028:deeeeeede000000e000000000dddddd0deeeeeede000000e0000000000000000
-- 029:d00e0000ed0e00000ede000000ed0000d00e0000ed0e00000ede000000ed0000
-- 032:2000000200000000000000000000000000000000000000000000000020000002
-- 033:000000000000000000000000000000000000cdee0000dd000000ee000000e000
-- 034:00000000000000000000000000000000eeeeeeee0000000000000000000d0000
-- 035:00000000000000000000000000000000eedc000000dd000000ee0000000e0000
-- 036:00000000d00cd00decccccce000dd000000ee000000110000001100000011000
-- 037:ffffffffeeeeeeee4eee4eeefee4fee44eef4eeffeeefeeeeeeeeeeeffffffff
-- 038:ffffffffeeeeeeeeeee4eee4ee4fee4feef4eef4eeefeeefeeeeeeeeffffffff
-- 039:ffffffffeeeeeeeeee4eee4ee4fee4feef4eef4eeefeeefeeeeeeeeeffffffff
-- 040:ffffffffeeeeeeeee4eee4ee4fee4feef4eef4eeefeeefeeeeeeeeeeffffffff
-- 042:00dddddd0deeeeeedeee4feedee4fee4deee4feedeeeeeeedefefeeede4f4eed
-- 043:0000e0000000ee000000dd000000cdee00000000000000000000000000000000
-- 044:000000000000000000000000eeeeeeee00000000000000000000000000000000
-- 045:000e000000ee000000dd0000eedc000000000000000000000000000000000000
-- 048:0000000006000060000000000000000000000000000000000600006000000000
-- 049:0000e0000000ed000000dd000000ede00000edfe0000ede00000dd000000ed00
-- 050:00fed0000effed00000d0000000d0000fefefefe000d0000000d00000fdefe00
-- 051:000e000000ed000000ddd000edfff000fffff000edfff00000ddd00000ed0000
-- 052:0001100000011000000110000001100000011000000110000001100000011000
-- 054:ffffffffffeeffeeff4eff4ef4eff4eff4eff4efff4eff4effeeffeeffffffff
-- 055:fffffffffeeffeeff4eff4ef4eff4eff4eff4efff4eff4effeeffeefffffffff
-- 056:ffffffffeeffeeff4eff4effeff4eff4eff4eff44eff4effeeffeeffffffffff
-- 057:ffffffffeffeeffeeff4eff4ff4eff4eff4eff4eeff4eff4effeeffeffffffff
-- 058:00dddddd0deeeeeedeeeeee4defefe4fde4f4ee4dee4eeeedeeeeeeedefefeed
-- 060:deffd000fdeff000ffdef000effde000deffd000fdeff0000fde000000f00000
-- 064:3300003330000003000000000000000000000000000000003000000333000033
-- 065:0000e0000000ee000000dd000000cdee00000000000000000000000000000000
-- 066:00fde000000f000000000000eeeeeeee00000000000000000000000000000000
-- 067:000e000000ee000000dd0000eedc000000000000000000000000000000000000
-- 068:0001100000011000000cd000000dc000000ce000000cd0000000000000000000
-- 069:7270065627200565727006562720000072720000272727270272727200272727
-- 070:ffffffffeeeeeeee4fdd4fddfdd4fdd4fdd4fdd44fdd4fddeeeeeeeeffffffff
-- 071:ffffffffeeeeeeeefdd4fdd4dd4fdd4fdd4fdd4ffdd4fdd4eeeeeeeeffffffff
-- 072:ffffffffeeeeeeeedd4fdd4fd4fdd4fdd4fdd4fddd4fdd4feeeeeeeeffffffff
-- 073:ffffffffeeeeeeeed4fdd4fd4fdd4fdd4fdd4fddd4fdd4fdeeeeeeeeffffffff
-- 074:00dddddd0deeeeeedeeeee4fdeeee4fedefefe4fde4f4eeedee4eeeedeeeeeed
-- 080:6500000050000000000000000000000000000000000000000000000000000000
-- 083:7270656027205656727065652720565672726565272727270272727200272727
-- 086:ffffffffeeeeeeee4fcd4fcdfcd4fcd4fcd4fcd44fcd4fcdeeeeeeeeffffffff
-- 087:ffffffffeeeeeeeefcd4fcd4cd4fcd4fcd4fcd4ffcd4fcd4eeeeeeeeffffffff
-- 088:ffffffffeeeeeeeecd4fcd4fd4fcd4fcd4fcd4fccd4fcd4feeeeeeeeffffffff
-- 089:ffffffffeeeeeeeed4fcd4fc4fcd4fcd4fcd4fcdd4fcd4fceeeeeeeeffffffff
-- 090:00dddddd0deeeeeedeeee4fedeee4feedeeee4fedefefeeede4f4eeedee4eeed
-- 096:ddd00000de000000d0d00000000d000000000000000000000000000000000000
-- 102:ffffffff4fcd4fcefcd4fcd44fcd4fceffffffff000000000000000000000000
-- 103:fffffffffcd4fce4cd4fcd4ffcd4fce4ffffffff000000000000000000000000
-- 104:ffffffffcd4fce4fd4fcd4fccd4fce4fffffffff000000000000000000000000
-- 105:ffffffffd4fce4fc4fcd4fcdd4fce4fcffffffff000000000000000000000000
-- 112:0222222034444422222224433444222222244443342222222444444300022222
-- 118:ffffffff4fcd4fceffffffff0000000000000000000000000000000000000000
-- 119:fffffffffcd4fce4ffffffff0000000000000000000000000000000000000000
-- 120:ffffffffcd4fce4fffffffff0000000000000000000000000000000000000000
-- 121:ffffffffd4fce4fcffffffff0000000000000000000000000000000000000000
-- 149:000fffc0000cdfc0000cccd000c4ecd00c4edcd004eeecd00c4edcd000e4cec0
-- 153:00ffffc000fddfc00d4decd0d4dedcd04deeecd0d4dedcd00d4decd000d4fec0
-- 165:00e4cec00c4edcd004eeecd00c4edcd000c4ecd0000cccd0000cdfc0000fffc0
-- 169:00d4fec00d4decd0d4dedcd04deeecd0d4dedcd00d4decd000fddfc000ffffc0
-- 179:0000c0ef009cdcef09cdcddf9cdcecdf9dcececf09dcecdf009dcdef0000d0ef
-- 180:0000c0ef002cdcef02cdcddf2cdcecdf2dcececf02dcecdf002dcdef0000d0ef
-- 181:0000c0ef004cdcef04cdcddf4cdcecdf4dcececf04dcecdf004dcdef0000d0ef
-- 183:00ecddcc004cddee04cdcdcc4cdcedee4dcecdcc04dcedee004dcdee0000cdee
-- 195:009dcdef09dcecdf9dcececf9cdcecdf09cdcddf009cdcdf00f0c0df00ecddef
-- 196:002dcdef02dcecdf2dcececf2cdcecdf02cdcddf002cdcdf00f0c0df00ecddef
-- 197:004dcdef04dcecdf4dcececf4cdcecdf04cdcddf004cdcdf00f0c0df00ecddef
-- 199:004dcdee04dcedee4dcecdcc4cdcedee04cdcddd004cddee00f0cdee00ecddee
-- </SPRITES>

-- <MAP>
-- 000:101010101010101010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 001:101010101010101010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 002:101010101010101010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 003:101010101010101010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 004:101010101010101010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 005:101010101010101010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 006:101010101010101010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 007:101010101010101010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 008:101010101010101010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 009:101010101010101010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 010:101010101010101010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 011:101010101010101010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 012:101010101010101010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 013:101010101010101010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 014:101010101010101010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 015:101010101010101010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 016:101010101010101010101010101010101010101010101010101010101010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </MAP>

-- <WAVES>
-- 000:eeeeeeedcb9687777777778888888888
-- 001:0123456789abcdeffedcba9876543210
-- 002:06655554443333344556789989abcdef
-- </WAVES>

-- <SFX>
-- 000:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000304000000000
-- 001:8000d000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000723000000000
-- </SFX>

-- <TRACKS>
-- 000:100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </TRACKS>

-- <FLAGS>
-- 000:00100010000000000000000000000000001000100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </FLAGS>

-- <PALETTE>
-- 000:1a1c2c5d2424b13e53ef7d57ffcd75a7f07038b764c25d0029366f3b5dc941a6f673eff7919191aeaaae656c79333434
-- </PALETTE>

