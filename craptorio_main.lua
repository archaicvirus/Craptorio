-- title:   craptorio
-- author:  @ArchaicVirus
-- desc:    De-make of Factorio
-- site:    website link
-- license: MIT License
-- version: 0.3
-- script:  lua

new_belt      = require('\\libs\\belt')
new_inserter  = require('\\libs\\inserter')
aspr          = require('\\libs\\affine_sprite')
ITEMS         = require('\\libs\\item_definitions')
draw_cable    = require('\\libs\\cable')
new_pole      = require('\\libs\\power_pole')
make_inventory = require('\\libs\\inventory')

--------------------COUNTERS--------------------------
TICK = 0

-------------GAME-OBJECTS-AND-CONTAINERS---------------
BELTS, INSERTERS, POLES = {}, {}, {}
GROUND_ITEMS = {}
STATE = 'main'
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
  drag = false,
  drag_dir = 0,
  drag_loc = 0,
}
inv = make_inventory()
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

function remove_pole(x, y)
  local key = get_key(x, y)
  if POLES[key] then
    for i = 1, #POLES do
      if POLES[i] == POLES[key] then
        POLES[key] = nil
        table.remove(POLES, i)
        --BELTS[i] = nil
        break
      end
    end
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

function draw_debug2(data)
  local width = 60
  local height = (#data * 6) + 3
  rectb(0, 0, width, height, 12)
  rect(1, 1, width - 2, height - 2, 15)
  for i = 1, #data do
    print(data[i], 2, i*6 - 4, 2, true, 1, true)
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
  local key = get_key(cursor.x, cursor.y)
  if not get_flags(cursor.x, cursor.y, 0) then spr(271, cursor.x, cursor.y, 00, 1, 0, 0, 1, 1) return end
  if cursor.item == 'belt' then
    if cursor.drag then
      if cursor.drag_dir == 0 or cursor.drag_dir == 2 then
        spr(288, cursor.x, cursor.drag_loc, 00, 1, 0, 0, 1, 1)
      else
        spr(288, cursor.drag_loc, cursor.y, 00, 1, 0, 0, 1, 1)
      end
      spr(270, cursor.x, cursor.y, 0, 1, 0, cursor.drag_dir, 1, 1)
    elseif not BELTS[key] or (BELTS[key] and BELTS[key].rot ~= cursor.rotation) then
      spr(BELT_ID_STRAIGHT + BELT_TICK, cursor.x, cursor.y, 00, 1, 0, cursor.rotation, 1, 1)
      spr(288, cursor.x, cursor.y, 00, 1, 0, cursor.rotation, 1, 1)
    else
      spr(288, cursor.x, cursor.y, 00, 1, 0, cursor.rotation, 1, 1)
    end
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
  elseif cursor.item == 'splitter' then

  else
    spr(cursor.id, cursor.last_x, cursor.last_y, 00, 1, 0, 0, 1, 1)
    spr(288, cursor.x, cursor.y, 00, 1, 0, 0, 1, 1)
    pix(cursor.last_x, cursor.last_y, 5)
  end
end

function rotate_cursor()
  if not cursor.drag then
    local key = get_key(cursor.x, cursor.y)
    local x, y = cursor.x, cursor.y
    if BELTS[key] and cursor.item == 'pointer' then
      BELTS[key]:rotate(BELTS[key].rot + 1)
      local tiles = {[1]={x=x,y=y-8},[2]={x=x+8,y=y},[3]={x=x,y=y+8},[4]={x=x-8,y=y}}
      for i = 1, 4 do
        local k = tostring(tiles[i].x) .. '-' .. tostring(tiles[i].y)
        if BELTS[k] then BELTS[k]:set_curved() end
      end
    end
    if INSERTERS[key] and cursor.item == 'pointer' then
      INSERTERS[key]:rotate(INSERTERS[key].rot + 1)
    end
    cursor.rotation = cursor.rotation + 1
    if cursor.rotation > 3 then cursor.rotation = 0 end
  end
end

function place_tile(x, y, rotation)
  local key = tostring(x) .. '-' .. tostring(y)
  if cursor.item == 'belt' and not INSERTERS[key] and not POLES[key] then
    add_belt(x, y, rotation)
  elseif cursor.item == 'inserter' and not BELTS[key] and not POLES[key] then
    add_inserter(x, y, rotation)
  elseif cursor.item == 'pole' and not INSERTERS[key] and not BELTS[key] then
    add_pole(x, y)
  end
end

function remove_tile(x, y)
  remove_belt(x, y)
  remove_inserter(x, y)
  remove_pole(x, y)
end

function pipette()
  if cursor.item == 'pointer' then
    local key = get_key(cursor.x, cursor.y)
    if BELTS[key] then cursor.item = 'belt' cursor.rotation = BELTS[key].rot return
    elseif INSERTERS[key] then cursor.item = 'inserter' cursor.rotation = INSERTERS[key].rot return
    elseif POLES[key] then cursor.item = 'pole' end
  else
    cursor.item = 'pointer'
  end
end

function mouse_input()
  local x, y, left, middle, right = mouse()
  if not left and cursor.last_left and cursor.drag then
    cursor.drag = false
    if cursor.drag_dir == 0 or cursor.drag_dir == 2 then
      cursor.y = cursor.drag_loc
      cursor.last_y = cursor.drag_loc
    else
      cursor.x = cursor.drag_loc
      cursor.last_x = cursor.drag_loc
    end
  end
  move_cursor('mouse', x, y)
  local tile_x, tile_y = get_cell(x, y)
  if cursor.item == 'belt' and not cursor.drag and left and cursor.last_left then
    --drag locking/placing belts
    cursor.drag = true
    if cursor.rotation == 0 or cursor.rotation == 2 then
      cursor.drag_loc = cursor.y
    else
      cursor.drag_loc = cursor.x
    end
    cursor.drag_dir = cursor.rotation
  end    
  if cursor.item == 'belt' and cursor.drag then
    if cursor.drag_dir == 0 or cursor.drag_dir == 2 and tile_x ~= cursor.last_tile_x then
      place_tile(cursor.x, cursor.drag_loc, cursor.drag_dir)
    elseif cursor.drag_dir == 1 or cursor.drag_dir == 3 and tile_y ~= cursor.last_tile_y then
      place_tile(cursor.drag_loc, cursor.y, cursor.drag_dir)
    end
  end

  local info = {
    [1] = 'Drag: ' .. tostring(cursor.drag),
    [2] = 'DDir: ' .. cursor.drag_dir,
    [3] = 'DLoc: ' .. cursor.drag_loc,
    [4] = 'CRot: ' .. cursor.rotation
  }

  draw_debug2(info)

  if left and not cursor.last_left then place_tile(tile_x, tile_y, cursor.rotation) end
  if right then remove_tile(tile_x, tile_y) end
  local cell_x, cell_y = get_cell(x, y)
  local key = get_key(cell_x, cell_y)
  if POLES[key] then POLES[key].is_hovered = true end
  cursor.last_tile_x, cursor.last_tile_y = tile_x, tile_y
  cursor.last_rotation = cursor.rotation
  cursor.last_x, cursor.last_y, cursor.last_left, cursor.last_mid, cursor.last_right = x, y, left, middle, right
end

function toggle_inventory()
  if STATE == 'main' then STATE = 'inventory' else STATE = 'main' end
end

function draw_inventory()
  inv:draw()
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
  --draw_debug()
  

  ------------------INPUT----------------------
  if btnp(0)  then move_cursor('up')    end
  if btnp(1)  then move_cursor('down')  end
  if btnp(2)  then move_cursor('left')  end
  if btnp(3)  then move_cursor('right') end
  if keyp(18) then rotate_cursor()      end --r
  if keyp(17) then pipette()            end --q
  if key(6)   then add_item(1)          end --f
  if key(7)   then add_item(2)          end --g
  if btnp(7)  then cycle_placeable()    end --s
  if keyp(9)  then toggle_inventory()   end --i
  ----------------DRAW-CURSOR------------------
  --move_cursor('mouse', x, y)
  mouse_input()
  

  -- if (left and not cursor.last_left) or left and (cursor.x ~= cursor.last_tile_x or cursor.y ~= cursor.last_tile_y) then
  --   place_tile(cursor.x, cursor.y, cursor.rotation)
  -- end

  if (right and not cursor.last_right) or right and (cursor.x ~= cursor.last_tile_x or cursor.y ~= cursor.last_tile_y) then
    remove_tile(cursor.x, cursor.y)
  end

  draw_ground_items()
  if STATE == 'inventory' then
    draw_inventory()
  else
    inv:draw_hotbar()
  end
  draw_cursor()
end

-- <TILES>
-- 001:0e0ecdcde0e0dcdc0e0ecdcde0e0dcdccdcd0e0edcdce0e0cdcd0e0edcdce0e0
-- 002:ffffeeeefdefefdefedfedfeffffeeeeeeeeffffefdefdefedfefedfeeeeffff
-- 003:2ddddddcddddddddddddddddddddddddddddddddddddddddddddddddaddddddb
-- 017:fefefefeefefefeffefefefeefefefeffefefefeefefefeffefefefeefefefef
-- 019:0e0e8d8de0e0d8d80e0e8d8de0e0d8d88d8d0e0ed8d8e0e08d8d0e0ed8d8e0e0
-- </TILES>

-- <SPRITES>
-- 000:ffffffffeeeeeeee4fcd4fcdfcd4fcd4fcd4fcd44fcd4fcdeeeeeeeeffffffff
-- 001:ffffffffeeeeeeeefcd4fcd4cd4fcd4fcd4fcd4ffcd4fcd4eeeeeeeeffffffff
-- 002:ffffffffeeeeeeeecd4fcd4fd4fcd4fcd4fcd4fccd4fcd4feeeeeeeeffffffff
-- 003:ffffffffeeeeeeeed4fcd4fc4fcd4fcd4fcd4fcdd4fcd4fceeeeeeeeffffffff
-- 004:00ffffff0feeeeeefeed4fcdfed4fcd4fed4fcd4fecd4fcdfefccfdefe4ff4ef
-- 005:00ffffff0feeeeeefecddcd4fefccf40fe4ff440fed44dd4fecddcdefefccfef
-- 006:00ffffff0feeeeeefeeddd4ffecdd4fcfefcc4fcfe4ff44ffed44ddefeddddef
-- 007:00ffffff0feeeeeefeedd4fcfedd4fcdfecd4fcdfefcf4fcfe4ff4defed44def
-- 008:00000044000004e40000444f344444f034444400000044400000f4e400000f44
-- 009:0000000044000000004000000004444300f44434ff4000004400000000000000
-- 010:0004000000004000f00040004fff400004444400000044400000043400000043
-- 011:0000000099000000009000000009999300f99939ff9000009900000000000000
-- 012:0009000000009000f00090009fff900009999900000099900000093900000093
-- 013:0000008a000008980000888fc88888f0c8888800000088800000f89800000f8a
-- 014:00000000000f000000fc00000fcffff00cccccc000cf0000000c000000000000
-- 015:00dddd00020000d0d020000dd002000dd000200dd000020d0d00002000dddd00
-- 021:ffffffff4fcd4fcefcd4fcd44fcd4fceffffffff000000000000000000000000
-- 022:fffffffffcd4fce4cd4fcd4ffcd4fce4ffffffff000000000000000000000000
-- 023:ffffffffcd4fce4fd4fcd4fccd4fce4fffffffff000000000000000000000000
-- 024:ffffffffd4fce4fc4fcd4fcdd4fce4fcffffffff000000000000000000000000
-- 025:6560022134500342654001240000000000000000998000003490000089400000
-- 026:003000d003030d0d003000d0000000000000000003340edd03330ddd04330dde
-- 027:0ff0000008ff000000f800000000000000000000000000000000000000000000
-- 028:0000000004300de003240efd003300ed00000000003300ed03240efe04300dd0
-- 029:000000000e0d00000eff00000de0000000000000000000000000000000000000
-- 032:3000000300000000000000000000000000000000000000000000000030000003
-- 033:000000000000000000000000000000000000cdee0000dd000000ee000000e000
-- 034:00000000000000000000000000000000eeeeeeee0000000000000000000d0000
-- 035:00000000000000000000000000000000eedc000000dd000000ee0000000e0000
-- 036:00000000d00cd00decccccce000dd000000ee000000110000001100000011000
-- 037:ffffffff4fcd4fceffffffff0000000000000000000000000000000000000000
-- 038:fffffffffcd4fce4ffffffff0000000000000000000000000000000000000000
-- 039:ffffffffcd4fce4fffffffff0000000000000000000000000000000000000000
-- 040:ffffffffd4fce4fcffffffff0000000000000000000000000000000000000000
-- 041:00000014000001710000111fc11111f0c1111100000011100000f17100000f14
-- 042:4100001417100171f11111100f1001000f100100f11111101710f17141000f14
-- 046:0000000000000000000009000000090000000090000000090000000900000009
-- 047:0000000000000000009000000090000009000000900000009000000090000000
-- 048:0000000006000060000000000000000000000000000000000600006000000000
-- 049:0000e0000000ed000000dd000000ede00000edfe0000ede00000dd000000ed00
-- 050:00fed0000effed00000d0000000d0000fefefefe000d0000000d00000fdefe00
-- 051:000e000000ed00000eddddddedfffe4fefffffe4edfffe4f0edddddd00ed0000
-- 052:0001100000011000000110000001100000011000000110000001100000011000
-- 056:000000000000000000000000000000000000000002f0002002f00020002f0200
-- 062:000000030000008900000888000089800000a800000000000000000000000000
-- 063:90000000380000008880000008980000008a0000000000000000000000000000
-- 064:3300003330000003000000000000000000000000000000003000000333000033
-- 065:0000e0000000ee000000dd000000cdee00000000000000000000000000000000
-- 066:00fde000000f000000000000eeeeeeee00000000000000000000000000000000
-- 067:000e000000ee000000dd0000eedc000000000000000000000000000000000000
-- 068:0001100000011000000cd000000dc000000ce000000cd0000000000000000000
-- 070:0002000000002000f00020002fff200002222200000022200000022200000022
-- 071:0000000000000000000000000000000000000000000000000000000020000000
-- 072:0002200000033000000220000002200000022000000220000002200000022000
-- 074:000000000000022000000002000000000000000f00000ff20000022000000000
-- 075:0000000000000000000000002222222222222222000000000000000000000000
-- 076:00000014000001710000111f222231f022232100000011100000f17100000f14
-- 080:6500000050000000000000000000000000000000000000000000000000000000
-- 081:deffd000fdeff000ffdef000effde000deffd000fdeff0000fde000000f00000
-- 082:0027272702727272272727277272000027200000727006562720056572700656
-- 083:7270656027205656727065652720565672720000272727270272727200272727
-- 086:0000000200000000000000000000000000000000000000000000000000000000
-- 087:2200000022200000022200000023200000023000000000000000000000000000
-- 088:00022011000221e100022110e1122100e1122100000111100000f1e100000f11
-- 096:ddd00000de000000d0d00000000d000000000000000000000000000000000000
-- 101:0002000000002000f00020002fff200002222200000022200000022200000022
-- 118:2200001422200171f22211100f2221000f122100f11111101710f17141000f14
-- 134:000dddff00deedee0de4fdcdde4fedd4de4fedd4dee4fdcddeeddeeedddeffff
-- 135:000dddff00deedee0de4fdd4de4fed4fde4fed4fdee4fdd4deeddeeedddeffff
-- 136:000dddff00deedee0de4fd4fde4fedfcde4fedfcdee4fd4fdeeddeeedddeffff
-- 137:000dddff00deedee0de4fdfcde4fedcdde4fedcddee4fdfcdeeddeeedddeffff
-- 149:000fffc0000cdfc0000cccd000c4ecd00c4edcd004eeecd00c4edcd000e4cec0
-- 153:00feffc000d4dec00d4decd0d4dedcd04deeecd0d4dedcd00d4decd000d4fec0
-- 165:00e4cec00c4edcd004eeecd00c4edcd000c4ecd0000cccd0000cdfc0000fffc0
-- 169:00d4fec00d4decd0d4dedcd04deeecd0d4dedcd00d4ddee000fefcc000fffcc0
-- 179:0000c0ef009cdcef09cdcddf9cdcecdf9dcececf09dcecdf009dcdef0000d0ef
-- 180:0000c0ef002cdcef02cdcddf2cdcecdf2dcececf02dcecdf002dcdef0000d0ef
-- 181:0000c0ef004cdcef04cdcddf4cdcecdf4dcececf04dcecdf004dcdef0000d0ef
-- 183:00eeddcc004ccdee04ceeccc4cedcece4decdecc04deecee004dcdee0000cdee
-- 195:009dcdef09dcecdf9dcececf9cdcecdf09cdcddf009cdcdf00f0c0df00ecddef
-- 196:002dcdef02dcecdf2dcececf2cdcecdf02cdcddf002cdcdf00f0c0df00ecddef
-- 197:004dcdef04dcecdf4dcececf4cdcecdf04cdcddf004cdcdf00f0c0df00ecddef
-- 199:004dcdee04dcedee4dcecdcc4cdcedee04cdcddd004cddee0004cdee000eedee
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

