-- title:   craptorio
-- author:  @ArchaicVirus
-- desc:    De-make of Factorio
-- site:    website link
-- license: MIT License
-- version: 0.3
-- script:  lua

new_belt        = require('\\libs\\belt')
new_inserter    = require('\\libs\\inserter')
aspr            = require('\\libs\\affine_sprite')
ITEMS           = require('\\libs\\item_definitions')
draw_cable      = require('\\libs\\cable')
new_pole        = require('\\libs\\power_pole')
make_inventory  = require('\\libs\\inventory')
new_drill       = require('\\libs\\mining_drill')
--image           = require('\\assets\\fullscreen_images')
--------------------COUNTERS--------------------------
TICK = 0

-------------GAME-OBJECTS-AND-CONTAINERS---------------
BELTS, INSERTERS, POLES = {}, {}, {}
GROUND_ITEMS = {}
STATE = 'main'
CURSOR_POINTER_ID = 352
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
  item = 'pointer',
  drag = false,
  drag_dir = 0,
  drag_loc = 0,
}
player = {x = 120, y = 64, spr = 286}
cam = {x = 120, y = 64, ccx = 0, ccy = 0}
inv = make_inventory()
local ndrill = new_drill({x = 32, y = 32})
ndrill.rot = 0
local TILE_SIZE = 8
local VIEWPORT_WIDTH = 240
local VIEWPORT_HEIGHT = 136
local MAP_WIDTH = 240 * TILE_SIZE
local MAP_HEIGHT = 136 * TILE_SIZE
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

function get_screen_cell(x, y)
  local tile_size = 8  -- size of each tile in pixels
  local cx, cy = cam.x, cam.y
  local map_offset_x = math.floor(cx) % tile_size
  local map_offset_y = math.floor(cy) % tile_size
  return x - ((x - map_offset_x) % tile_size), y - ((y - map_offset_y) % tile_size)
end

function get_world_cell(x, y)
  local worldX = x - cam.x
  local worldY = y - cam.y
  local cellX = math.floor(worldX / TILE_SIZE)
  local cellY = math.floor(worldY / TILE_SIZE)
  return cellX + 15, cellY + 8
end

function update_camera()
  cam.x = math.min(120, 120 - player.x)
  cam.y = math.min(64, 64 - player.y)
  cam.ccx = cam.x / 8 + (cam.x % 8 == 0 and 1 or 0)
  cam.ccy = cam.y / 8 + (cam.y % 8 == 0 and 1 or 0)
end

function move_player(x, y)
  local to = {x = x, y = y}
  local tile_nw = fget(mget(get_world_cell(cam.x + to.x,     cam.y + to.y    )), 0)
  local tile_ne = fget(mget(get_world_cell(cam.x + to.x + 7, cam.y + to.y    )), 0)
  local tile_se = fget(mget(get_world_cell(cam.x + to.x + 7, cam.y + to.y + 7)), 0)
  local tile_sw = fget(mget(get_world_cell(cam.x + to.x,     cam.y + to.y + 7)), 0)
  local info = {
    [1] = 'tile_nw:' .. tostring(tile_nw),
    [2] = 'tile_ne:' .. tostring(tile_ne),
    [3] = 'tile_se:' .. tostring(tile_se),
    [4] = 'tile_sw:' .. tostring(tile_sw),
  }
  draw_debug2(info, 10)
  if tile_nw and tile_ne and tile_se and tile_sw then
    player.x, player.y = to.x, to.y
  end
end

function update_player()
  if btn(0) then move_player(player.x, player.y - 1) end
  if btn(1) then move_player(player.x, player.y + 1) end
  if btn(2) then move_player(player.x - 1, player.y) end
  if btn(3) then move_player(player.x + 1, player.y) end
  player.x = math.min(math.max(-120, player.x), MAP_WIDTH - 8 - 120)
  player.y = math.min(math.max(-64, player.y), MAP_HEIGHT - 8 - 64)
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
    if get_flags(cursor.tile_x, cursor.tile_y - 8, 0) then cursor.tile_y = cursor.tile_y - 8 sfx(0, 'C-4', 4, 0, 15, 5) end
  elseif dir == 'down' then
    if get_flags(cursor.tile_x, cursor.tile_y + 8, 0) then cursor.tile_y = cursor.tile_y + 8 sfx(0, 'C-4', 4, 0, 15, 5) end
  elseif dir == 'left' then
    if get_flags(cursor.tile_x - 8, cursor.tile_y, 0) then cursor.tile_x = cursor.tile_x - 8 sfx(0, 'C-4', 4, 0, 15, 5) end
  elseif dir == 'right' then
    if get_flags(cursor.tile_x + 8, cursor.tile_y, 0) then cursor.tile_x = cursor.tile_x + 8 sfx(0, 'C-4', 4, 0, 15, 5) end
  end
  if dir == 'mouse' then
    -- if not (cursor.x == x and cursor.y == y) then
    --   local cell_x, cell_y = get_cell(x, y)
    --   if not (cell_x == cursor.tile_x and cell_y == cursor.tile_y) then
          -- cursor.tile_x, cursor.tile_y = cell_x, cell_y
          -- assuming cursor.x and cursor.y contain the current mouse position
          cursor.tile_x, cursor.tile_y = get_screen_cell(cursor.x, cursor.y)
          -- now (cell_x, cell_y) contains the top-left corner of the cell the cursor is hovering over
    --   end
    -- end
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
  local key = tostring(cursor.tile_x) .. '-' .. tostring(cursor.tile_y)
  if BELTS[key] then
    BELTS[key].lanes[1][8] = id
    BELTS[key].lanes[2][8] = id
    --BELTS[key].lanes[2][8] = id
  end
end

function draw_debug2(data, screen_y)
  screen_y = screen_y or 0
  local width = 80
  local height = (#data * 6) + 3
  rectb(0, screen_y, width, height, 12)
  rect(1, screen_y + 1, width - 2, height - 2, 15)
  for i = 1, #data do
    print(data[i], 2, i*6 - 4 + screen_y, 2, true, 1, true)
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
  local key = get_key(cursor.tile_x, cursor.tile_y)
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
  local key = get_key(cursor.tile_x, cursor.tile_y)
  if not fget(mget(get_world_cell(cursor.x, cursor.y)), 0) then
    spr(271, cursor.tile_x, cursor.tile_y, 00, 1, 0, 0, 1, 1) 
    return
  end
  if cursor.item == 'belt' and STATE == 'main' then
    if cursor.drag then
      if cursor.drag_dir == 0 or cursor.drag_dir == 2 then
        spr(288, cursor.tile_x, cursor.drag_loc, 00, 1, 0, 0, 1, 1)
      else
        spr(288, cursor.drag_loc, cursor.tile_y, 00, 1, 0, 0, 1, 1)
      end
      --arrow to indicate drag direction
      --spr(270, cursor.tile_x, cursor.tile_y, 0, 1, 0, cursor.drag_dir, 1, 1)
    elseif not BELTS[key] or (BELTS[key] and BELTS[key].rot ~= cursor.rotation) then
      spr(BELT_ID_STRAIGHT + BELT_TICK, cursor.tile_x, cursor.tile_y, 00, 1, 0, cursor.rotation, 1, 1)
      spr(288, cursor.tile_x, cursor.tile_y, 00, 1, 0, cursor.rotation, 1, 1)
    else
      spr(288, cursor.tile_x, cursor.tile_y, 00, 1, 0, cursor.rotation, 1, 1)
    end
  elseif cursor.item == 'inserter' then
    if not INSERTERS[key] or (INSERTERS[key] and INSERTERS[key].rot ~= cursor.rotation) then
      local temp_inserter = new_inserter({x = cursor.tile_x, y = cursor.tile_y}, cursor.rotation)
      temp_inserter:draw()
    end
  elseif cursor.item == 'pole' then
    local temp_pole = new_pole({x = cursor.tile_x, y = cursor.tile_y})
    temp_pole:draw(true)
    --check around cursor to attach temp cables to other poles
  elseif cursor.item == 'pointer' then
    if STATE == 'inventory' then
      spr(CURSOR_POINTER_ID, cursor.x, cursor.y, 00, 1, 0, 0, 1, 1)
      pix(cursor.x, cursor.y, 5)
      --if hovered over item slot
      local slot, sx, sy, slot_index = inv:get_hovered_slot(cursor.x, cursor.y)
      if slot then
        spr(288, sx, sy, 00, 1, 0, 0, 1, 1)
        local slot_data = {[1] = 'Slot:' .. tostring(slot_index), [2] = 'Item ID:' .. inv.slots[slot_index].item_id, [3] = 'Count:' .. inv.slots[slot_index].count}
        draw_debug2(slot_data)
      end
    else
      spr(CURSOR_POINTER_ID, cursor.x, cursor.y, 00, 1, 0, 0, 1, 1)
      spr(288, cursor.tile_x, cursor.tile_y, 00, 1, 0, 0, 1, 1)
      pix(cursor.x, cursor.y, 5)
    end
  end
end

function rotate_cursor()
  if not cursor.drag then
    local key = get_key(cursor.tile_x, cursor.tile_y)
    local x, y = cursor.tile_x, cursor.tile_y
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
    local key = get_key(cursor.tile_x, cursor.tile_y)
    if BELTS[key] then cursor.item = 'belt' cursor.rotation = BELTS[key].rot return
    elseif INSERTERS[key] then cursor.item = 'inserter' cursor.rotation = INSERTERS[key].rot return
    elseif POLES[key] then cursor.item = 'pole' end
  else
    cursor.item = 'pointer'
  end
end

function handle_input()
  local x, y, left, middle, right, scroll_x, scroll_y = mouse()
  local info = {
    [1] = 'SX: ' .. scroll_x,
    [2] = 'SY: ' .. scroll_y
  }
  if not left and cursor.last_left and cursor.drag then
    cursor.drag = false
    if cursor.drag_dir == 0 or cursor.drag_dir == 2 then
      cursor.tile_y = cursor.drag_loc
      cursor.y = cursor.drag_loc
    else
      cursor.tile_x = cursor.drag_loc
      cursor.x = cursor.drag_loc
    end
  end
  move_cursor('mouse', x, y)
  local tile_x, tile_y = get_cell(x, y)
  if cursor.item == 'belt' and not cursor.drag and left and cursor.last_left then
    --drag locking/placing belts
    cursor.drag = true
    if cursor.rotation == 0 or cursor.rotation == 2 then
      cursor.drag_loc = cursor.tile_y
    else
      cursor.drag_loc = cursor.tile_x
    end
    cursor.drag_dir = cursor.rotation
  end    
  if cursor.item == 'belt' and cursor.drag then
    if cursor.drag_dir == 0 or cursor.drag_dir == 2 and tile_x ~= cursor.last_tile_x then
      place_tile(cursor.tile_x, cursor.drag_loc, cursor.drag_dir)
    elseif cursor.drag_dir == 1 or cursor.drag_dir == 3 and tile_y ~= cursor.last_tile_y then
      place_tile(cursor.drag_loc, cursor.tile_y, cursor.drag_dir)
    end
  end

  if left and not cursor.last_left then place_tile(tile_x, tile_y, cursor.rotation) end
  if right then remove_tile(tile_x, tile_y) end
  local cell_x, cell_y = get_cell(x, y)
  local k = get_key(cell_x, cell_y)
  if POLES[k] then POLES[k].is_hovered = true end

  if keyp(18) and not keyp(63) then rotate_cursor()end --r
  if keyp(17) then pipette()            end --q
  if key(6)   then add_item(1)          end --f
  if key(7)   then add_item(2)          end --g
  if btnp(7)  then cycle_placeable()    end --s
  if keyp(9)  then toggle_inventory()   end --i

  cursor.last_tile_x, cursor.last_tile_y = tile_x, tile_y
  cursor.last_rotation = cursor.rotation
  cursor.last_x, cursor.last_y, cursor.last_left, cursor.last_mid, cursor.last_right = cursor.x, cursor.y, left, middle, right
  cursor.x, cursor.y = x, y
end

function toggle_inventory()
  if STATE == 'main' then
    STATE = 'inventory'
    cursor.item = 'pointer'
  else
    STATE = 'main'
  end
end

function draw_inventory()
  inv:draw()
end

local img_count = 1
function draw_image()
  if TICK % 4 == 0 then
    img_count = img_count + 1
    if img_count > #image then img_count = 1 end
  end
  for i = 1, 240 do
    for j = 1, 136 do
      local index = (j - 1) * 240 + i
      pix(i-1, j-1, image[img_count][index])
    end
  end

  local pos = {x = 2, y = 75}
  -- for i = 1, 235 do
  --   for j = 1, 31 do
  --     local index = (j - 1) * 235 + i
  --     if image.logo[index] ~= 12 then
  --       pix(i + pos.x, j + pos.y, image.logo[index])
  --     end
  --   end
  -- end
end

function TIC()
  cls(0)
  update_camera()
  map(15 - cam.ccx, 8 - cam.ccy, 31, 18, (cam.x % 8) - 8,(cam.y % 8) - 8)
  update_player()
  -- trace('player y:' .. player.y)
  -- trace('cam y:' .. cam.y)
  spr(player.spr, cam.x + player.x, cam.y + player.y, 0)
  local cell_x, cell_y = get_world_cell(cursor.x, cursor.y)
  local tile_id = mget(cell_x, cell_y)
  local info = {
    [1] = 'player: ' ..player.x .. ',' .. player.y,
    [2] = 'camera: ' .. cam.x .. ',' .. cam.y,
    [3] = 'ccx/ccy: ' .. (cam.x%8)-8 .. ',' .. (cam.y%8)-8,
    [4] = 'tile: ' ..cell_x .. ',' .. cell_y,
    [5] = 'tileID: ' .. tile_id
  }
  draw_debug2(info, 8)
  --map(cam.ccx - 15, cam.ccy - 8, 32, 17, (cam.x % 8) - 8, (cam.y % 8) - 8)
  
  TICK = TICK + 1
  --remove mouse cursor
  poke(0x3FFB, 0x000000, 8)
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
  ----------------UPDATE-INSERTERS-------------
  if TICK % INSERTER_TICKRATE == 0 then
    update_inserters()
  end
  for k, v in ipairs(INSERTERS) do
    v:draw()
  end
  ----------------UPDATE-POLES-----------------
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
  end
  -----------UPDATE-MINING-DRILLS--------------
  -- if TICK % DRILL_TICK_RATE == 0 then
  --   DRILL_ANIM_TICK = DRILL_ANIM_TICK + 1
  --   if DRILL_ANIM_TICK > 3 then DRILL_ANIM_TICK = 0 end
  --   if DRILL_BIT_DIR == 0 then
  --     DRILL_BIT_TICK = DRILL_BIT_TICK + 1
  --     if DRILL_BIT_TICK > 5 then
  --       DRILL_BIT_TICK = 5
  --       DRILL_BIT_DIR = 1
  --     end
  --   elseif DRILL_BIT_DIR == 1 then
  --     DRILL_BIT_TICK = DRILL_BIT_TICK - 1
  --     if DRILL_BIT_TICK < 0 then
  --       DRILL_BIT_TICK = 0
  --       DRILL_BIT_DIR = 0
  --     end
  --   end
  --   ndrill:update()
  -- end
  -- ndrill:draw()
  ------------------INPUT----------------------
  handle_input()
  draw_ground_items()
  if STATE == 'inventory' then
    draw_inventory()
  else
    inv:draw_hotbar()
  end
  draw_cursor()
end

-- <TILES>
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
-- 036:ddddeddddeedddeddddddddddddedddeddedddddeddddedddeddddeddddddddd
-- 037:2433324333333333433232332323333433334233324333323333333343423343
-- 038:44444cd44d84488448444444444d4444484444d44d4448c4dc844484e8444d44
-- 039:f000f00f000000f0000f0000f000000f00000f00f0f0000f0000f0f00f0f000f
-- 040:6676666665566756657676566666666766675666666666667566567566676665
-- 041:1111011111011110111111110111011111011111111111011110111101111011
-- 042:4444444443443444444444444444443434444444444344444444444443444434
-- 043:4444444444444444444444444444444444444444444444444444444444444444
-- 044:4444444444444444444444444444444444444444444444444444444444444444
-- </TILES>

-- <TILES1>
-- 000:0000000000000000000000000020000000000000000000000000000000000000
-- </TILES1>

-- <SPRITES>
-- 000:ffffffffeeeeeeee4fcd4fcdfcd4fcd4fcd4fcd44fcd4fcdeeeeeeeeffffffff
-- 001:ffffffffeeeeeeeefcd4fcd4cd4fcd4fcd4fcd4ffcd4fcd4eeeeeeeeffffffff
-- 002:ffffffffeeeeeeeecd4fcd4fd4fcd4fcd4fcd4fccd4fcd4feeeeeeeeffffffff
-- 003:ffffffffeeeeeeeed4fcd4fc4fcd4fcd4fcd4fcdd4fcd4fceeeeeeeeffffffff
-- 004:00ffffff0feeeeeefeed4fcdfed4fcd4fed4fcd4fecd4fcdfefccfdefe4ff4ef
-- 005:00ffffff0feeeeeefecddcd4fefccf40fe4ff440fed44dd4fecddcdefefccfef
-- 006:00ffffff0feeeeeefeeddd4ffecdd4fcfefcc4fcfe4ff44ffed44ddefeddddef
-- 007:00ffffff0feeeeeefeedd4fcfedd4fcdfecd4fcdfefcf4fcfe4ff4defed44def
-- 008:00000033000003e30000333f333333f033333300000033300000f3e300000f33
-- 009:0000000044000000004000000004444300f44434ff4000004400000000000000
-- 010:0004000000004000f00040004fff400004444400000044400000043400000043
-- 011:0000000099000000009000000009999300f99939ff9000009900000000000000
-- 012:0009000000009000f00090009fff900009999900000099900000093900000093
-- 013:0000008a000008980000888fc88888f0c8888800000088800000f89800000f8a
-- 014:00000000000f000000fc00000fcffff00cccccc000cf0000000c000000000000
-- 015:00dddd00020000d0d020000dd002000dd000200dd000020d0d00002000dddd00
-- 017:cdeeeeeedd000000ee000000e00000000000000000000000000000000000efef
-- 018:eeeeeedc000000dd000000ee0000000e000000de000000dd00000edeefefefde
-- 019:00d000000fed0000effed00000d0000000d00000000000000000000000000000
-- 021:ffffffff4fcd4fcefcd4fcd44fcd4fceffffffff000000000000000000000000
-- 022:fffffffffcd4fce4cd4fcd4ffcd4fce4ffffffff000000000000000000000000
-- 023:ffffffffcd4fce4fd4fcd4fccd4fce4fffffffff000000000000000000000000
-- 024:ffffffffd4fce4fc4fcd4fcdd4fce4fcffffffff000000000000000000000000
-- 025:6560022134500342654001240000000000000000998000003490000089400000
-- 026:003000d003030d0d003000d0000000000000000003340edd03330ddd04330dde
-- 027:0ff0000008ff000000f800000000000000000000000000000000000000000000
-- 028:0000000004300980032408fd003300e800000000003300ed03240efe04300dd0
-- 029:000000000e0d00000eff00000de0000000000000000000000000000000000000
-- 030:d00ccc00e0c9e9c0e0ceeec0f3ecccd3ff3dde30ffeccec00eceecc00033cc33
-- 032:3030303000000003300000000000000330000000000000033000000003030303
-- 033:000000000000000000000000e0000000e0000000ee000000dd000000cdeeeeee
-- 034:00000ede000000dd000000de0000000e0000000e000000ee000000ddeeeeeedc
-- 036:00000000d00cd00decccccce000dd000000ee000000110000001100000011000
-- 037:ffffffff4fcd4fceffffffff0000000000000000000000000000000000000000
-- 038:fffffffffcd4fce4ffffffff0000000000000000000000000000000000000000
-- 039:ffffffffcd4fce4fffffffff0000000000000000000000000000000000000000
-- 040:ffffffffd4fce4fcffffffff0000000000000000000000000000000000000000
-- 041:00000014000001710000111fc11111f0c1111100000011100000f17100000f14
-- 042:4100001417100171f11111100f1001000f100100f11111101710f17141000f14
-- 046:0000000000000000000009000000090000000090000000090000000900000009
-- 047:0000000000000000009000000090000009000000900000009000000090000000
-- 048:0000e0000000de00dddddde04eff4edeeff4effe4eff4ededddddde00000de00
-- 049:0000e0000000de00dddddde0eff4efdeff4eff4eeff4efdedddddde00000de00
-- 050:0000e0000000de00dddddde0ff4effdef4eff4eeff4effdedddddde00000de00
-- 051:0000e0000000de00dddddde0f4eff4de4eff4efef4eff4dedddddde00000de00
-- 052:0001100000011000000110000001100000011000000110000001100000011000
-- 056:000000000000000000000000000000000000000002f0002002f00020002f0200
-- 062:000000030000008900000888000089800000a800000000000000000000000000
-- 063:90000000380000008880000008980000008a0000000000000000000000000000
-- 064:3300003330000003000000000000000000000000000000003000000333000033
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
-- 102:0000000000000000000000000000000000000000000000000000000020000000
-- 117:0000000200000000000000000000000000000000000000000000000000000000
-- 118:2200001422200171f22211100f2221000f122100f11111101710f17141000f14
-- 122:0000c0ef004cdcef04cdcddf4cdcecdf4dcececf04dcecdf004dcdef0000d0ef
-- 123:00eeddcc004ccdee04ceeccc4cedcece4decdecc04deecee004dcdee0000cdee
-- 124:00feffc000d4dec00d4decd0d4dedcd04deeecd0d4dedcd00d4decd000d4fec0
-- 125:0000c0ef009cdcef09cdcddf9cdcecdf9dcececf09dcecdf009dcdef0000d0ef
-- 126:0000c0ef002cdcef02cdcddf2cdcecdf2dcececf02dcecdf002dcdef0000d0ef
-- 127:000fffc0000cdfc0000cccd000c4ecd00c4edcd004eeecd00c4edcd000e4cec0
-- 134:000dddff00deedee0de4fdcdde4fedd4de4fedd4dee4fdcddeeddeeedddeffff
-- 135:000dddff00deedee0de4fdd4de4fed4fde4fed4fdee4fdd4deeddeeedddeffff
-- 136:000dddff00deedee0de4fd4fde4fedfcde4fedfcdee4fd4fdeeddeeedddeffff
-- 137:000dddff00deedee0de4fdfcde4fedcdde4fedcddee4fdfcdeeddeeedddeffff
-- 138:004dcdef04dcecdf4dcececf4cdcecdf04cdcddf004cdcdf00f0c0df00ecddef
-- 139:004dcdee04dcedee4dcecdcc4cdcedee04cdcddd004cddee0004cdee000eedee
-- 140:00d4fec00d4decd0d4dedcd04deeecd0d4dedcd00d4ddee000fefcc000fffcc0
-- 141:009dcdef09dcecdf9dcececf9cdcecdf09cdcddf009cdcdf00f0c0df00ecddef
-- 142:002dcdef02dcecdf2dcececf2cdcecdf02cdcddf002cdcdf00f0c0df00ecddef
-- 143:00e4cec00c4edcd004eeecd00c4edcd000c4ecd0000cccd0000cdfc0000fffc0
-- 145:ddeeeeeedce00000ee000000e0000000e0000000e0000000e0000000e0000000
-- 146:eeceecee000dd000000ee000000cc000000ee000000cc000000ee000000cc000
-- 147:eeeeeedd00000ecd000000ee0000000e0000000e0000000e0000000e0000000e
-- 161:e0000000e0000000e00000d0e0000de0e000defde0000ff0e00000e0e0000000
-- 162:000ee000000cc000000ee000000cc000dddeeddd000cc000000ee000000cc000
-- 163:0000000e0000000e0e00000e0ff0000edfed000e0ed0000e0d00000e0000000e
-- 166:0000de00dddddde04fec4fdefec4fedefec4fede4fec4fdedddddde00000de00
-- 177:e0000000e0000000e0000000e0000000e0000000ee000000dce00000ddeeeeee
-- 178:00eeee000edddde0edfeefdedd4ff4dd0dc44cd00decced00dfeefd0ed4ff4de
-- 179:0000000e0000000e0000000e0000000e0000000e000000ee00000ecdeeeeeedd
-- </SPRITES>

-- <SPRITES1>
-- 000:cccccccccccccccccccccccccccc2222ccc22322c0123333c0233333c0233333
-- 001:cccccccccccccccccccccccc2222222222222222222222223322222232223222
-- 002:cccccccccccccccccccccccc200ccccc3200cccc3200cccc3200ccc02200ccc0
-- 003:cccccccccccccccccccccccccc221121c2222222122222220222222221222222
-- 004:cccccccccccccccccccccccc1122110022222222222222222222222222222222
-- 005:cccccccccccccccccccccccc2ccccccc22ccccc1210cccc0220cccc1220cccc2
-- 006:cccccccccccccccccccccccc2222222222222222222222222222222222233333
-- 007:cccccccccccccccccccccccc2222222222222222222222222222222233332222
-- 008:cccccccccccccccccccccccc222ccccc23221ccc333221cc3333220c2223320c
-- 009:cccccccccccccccccccccccccccccc22cccc2222ccc02333ccc02333ccc12333
-- 010:cccccccccccccccccccccccc2222222222222222322222223332222233333222
-- 011:cccccccccccccccccccccccc2222222222222333222222332222222222322222
-- 012:ccccccccccccccccccccccccccccc120220cc222230cc2332300c2332310c233
-- 013:cccccccccccccccccccccccc2221122222222222332222223322222233333333
-- 014:cccccccccccccccccccccccc2222222222222222222222222222222233333322
-- 015:cccccccccccccccccccccccc110ccccc2200cc002200cc002200cc002200cc00
-- 016:c0233333c0233333c0233333c0233333c0233333c0233333c0233333c0233333
-- 017:31000000320000003200000032cccccc32cccccc32cccccc32cccccc32cccccc
-- 018:0000ccc00000ccc00000ccc0ccccccc0ccccccc0ccccccc0ccccccc0ccccccc0
-- 019:1222222212222222123322231233323312333333133333331333333323333333
-- 020:21112111100000000000000000000000000000000ccccccc0ccccccc0ccccccc
-- 021:100cccc2000cccc0000cccc0000cccc000ccccccccccccc2ccccccc2ccccccc1
-- 022:22222222000000000000000000000000cccccccc222222223333333333333333
-- 023:22222222000002220000002200000023cccccc23222222233333333333333333
-- 024:2222320c2222320c2222320c3223320c3333320c3333320c3333320c3333320c
-- 025:ccc22333ccc22333ccc22333ccc22333ccc22333ccc23333ccc23433ccc23433
-- 026:33333222333332003333310033333200333332cc333333223333333333333333
-- 027:22222222000022220000022200000233ccccc233222222333333333333333333
-- 028:2320c0222320c0002320c0003320c0003320c0003320cccc3320cccc3200cccc
-- 029:1222222200000000000000000000000000000000f2232233f3333333f2333333
-- 030:222222220000000000000000000000000001000033331ccc33331ccc33330ccc
-- 031:2200cc000000cc000000cc000000cc00000ccccccccccccccccccccccccccccc
-- 032:c0333333c0233333c0233333c0233333c0012333c0000222c0000000c0000000
-- 033:32cccccc33333333333333333333333333333333222222220000000000000000
-- 034:ccccccc0322cccc03221ccc03220ccc03210ccc02100ccc00000ccc00000ccc0
-- 035:2333333312333333123333331233333302223323001222230002221200000000
-- 036:0ccccccc0ccccccc0ccccccc0ccccccc0ccccccc0ccccccc0ccccccc0ccccccc
-- 037:ccccccc1ccccccc2ccccccc2ccccccc1ccccccc0ccccccc0ccccccc0ccccccc0
-- 038:3333333333333332333333302333333022333331123333300222222000000000
-- 039:222222330000003300000033000000330000003300000023ccccc022ccccc000
-- 040:3333320c3333320c3333320c3333320c3333320c3322200c2221000c0000000c
-- 041:ccc23433ccc22433ccc12333ccc12333ccc12333ccc01222ccc00000ccc00000
-- 042:333333333333301133333000333330003333200022220000000000cc000000cc
-- 043:333333331111211100000000000000000000000000000000cccccccccccccccc
-- 044:3000cccc0000cccc0000cccc000ccccc00cccccccccccccccccccccccccccccc
-- 045:0233333302333333013333330133333301333333012222330000112200000000
-- 046:33330ccc33332ccc33332ccc33331ccc33331ccc33330ccc22220ccc00000ccc
-- 047:ccccccc1cccccc12cccccc12cccccc11cccccc00cccccc10cccccc21cccccc00
-- 048:c0000000c0000000c0000000cc000000cccccccccccccccccccccccc00000000
-- 049:00000000000000000000000000000000cccccccccccccccccccccccc00000000
-- 050:0000ccc00000ccc00000ccc0000ccccccccccccccccccccccccccccc00000000
-- 051:00000000000000000000000000000000cc000000ccc00000cccccccc00000000
-- 052:0ccccccc0ccccccc0ccccccc0ccccccc0ccccccc0ccccccccccccccc00000000
-- 053:ccccccc0ccccccc0ccccccc0ccccccc0ccccccc0cccccccccccccccc00000000
-- 054:00000000000000000000000000000000000000000000000ccccccccc00000000
-- 055:ccccc000ccccc000ccccc000ccccc000cccccc00ccccccc0cccccccc00000000
-- 056:0000000c0000000c000000cc000000cc000000cc00000ccccccccccc00000000
-- 057:ccc00000ccc00000ccc00000ccc00000cccc0000ccccc000cccccccc00000000
-- 058:000000cc000000cc000000cc000000cc00000ccc0000cccccccccccc00000000
-- 059:cccccccccccccccccccccccccccccccccccccccccccccccccccccccc00000000
-- 060:cccccccccccccccccccccccccccccccccccccccccccccccccccccccc00000000
-- 061:0000000000000000000000000000000000000000c0000000cccccccc00000000
-- 062:00000ccc00000ccc00000ccc00000ccc0000cccc000ccccccccccccc00000000
-- 063:cccccc00cccccc00cccccc00cccccc00cccccccccccccccccccccccc00000000
-- 064:0000000000000000000000000000000000000000c0000000cccccccc00000000
-- 065:000000000000000000000000000000000000000000000000cccccccc00000000
-- 066:000000000000000000000000000000000000000c000000cccccccccc00000000
-- 067:cc000000cc000000cc000000cc000000cccc0000ccccc000cccccccc00000000
-- 068:0000cccc0000cccc0000cccc0000cccc0000cccc0000cccccccccccc00000000
-- 069:cccccccccccccccccccccccccccccccccccccccccccccccccccccccc00000000
-- 070:c1000000c1000000c1000000c1000000cc100000ccc00000cccccccc00000000
-- 071:000000cc000000cc000000cc000000cc00000ccc000ccccccccccccc00000000
-- 072:cccccc00cccccccccccccccccccccccccccccccccccccccccccccccc00000000
-- 073:0000cc00cccccccccccccccccccccccccccccccccccccccccccccccc00000000
-- 074:00122200000222000000000000000000c0000000cc00000ccccccccc00000000
-- 075:000000000000000000ccc0000ccccccccccccccccccccccccccccccc00000000
-- 076:0000cccc000ccccc00cccccccccccccccccccccccccccccccccccccc00000000
-- 077:ccc00000ccc00000ccc00000ccc00000ccc00000ccc00000ccc0000000000000
-- </SPRITES1>

-- <MAP>
-- 000:a2a2a2a2a2a2a2a2a2a2a2a2a262a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a242424242424242424242424242424242424242424242424242424242424242a2a2a2a2a2a2a2a26262a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 001:a2a2a2a2a2a2a2a2a2a2a26262626262a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a242424242424242424242424242424242424242424242424242424242424242a2a2a2a2a2a2a262626262a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 002:a2a2a2a2a2a2a2a2a2a26262626262626262a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a242424242424242424242424242626262626242424242424242424242424242a2a2a2a2a2a2a2626262626262a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 003:a2a2a2a2a2a2a2a2a2a26262626262626262626262a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a24242424242424242424242626262626262626262424242424242424242a2a2a2a2a2a2a2a2a2626262626262a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 004:a2a2a2a2a2a2a2a2a26262626262626262626262626262a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a24242424242424242424262626262626262626262626242424242424242a2a2a2a2a2a2a2a2a26262626262626262a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 005:a2a2a2a2a2a2a2a2a262626262626262626262626262626262a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2424242424242424242626262626262626262626262626242424242a2a2a2a2a2a2a2a2a2a2a26262626262626262a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 006:a2a2a2a2a2a2a2a2a2a26262626262626262626262626262626262a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a24242424242424242626262626262626262626262626262626242a2a2a2a2a2a2a2a2a2a2a2a2626262626262626262a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 007:a2a2a2a2a2a2a2a2a2a262626262626262626262626262626262626262a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a24242424242424262626262626262626262626262626262626262a2a2a2a2a2a2a2a2a2a2a262626262626262626262a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 008:a2a2a2a2a2a2a2a2a2a2a262626262626262626262626262626262626262a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a242424242424242626262626262626262626262626262626262626262a2a2a2a2a2a2a2a2a26262626262626262626262a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 009:a2a2a2a2a2a2a2a2a2a2a2a26262626262626262626262626262626262626262a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2424242424262626262626262626262626262626262626262626262626262a2a2a2a2a2a26262626262626262626262a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 010:a2a2a2a2a2a2a2a2a2a2a2a2a2a26262626262626262626262626262626262626262a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a242424262626262626262626262626262626262626262626262626262626262626262626262626262626262626262a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 011:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2626262626262626262626262626262626262626262a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0727272727272a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a262626262626262626262626262626262626262626262626262626262626262626262626262626262626262a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 012:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a26262626262626262626262626262626262626262a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a07272727272727272727272a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2626262626262626262626262626262626262626262626262626262626262629292a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 013:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a262626262626262626262626262626262a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a072727272727272727272727272727272a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2626262626262626262626262626262626262626262626262626262626262929292a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 014:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a26262626262a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0727272727272727272727272727272727272727272a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a262626262626262626262626262626262626262626262626262626262a2a292a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 015:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a072727272727272727272727272727272727272727272a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2626262626262626262626262626262626262626262626262626262a2a2a2a2a2a2a2a2a2a2a2a2a2a2a282a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 016:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0727272727272727272727272727272727272724242424242424242424242a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a262626262626262626262626262626262626262626262626262a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 017:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a07272727272727272727272727272727272724242424242424242424242424242424242a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a26262626262626262626262626262626262626262626262a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 018:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a072727272727272727272727272727272724242424242424242424242424242424242424242424242a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a26262626262626262626262626262626262626262a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 019:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0727272727272727272727272727272724242424242424242424242424242424242424242424242424242424242a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a262626262626262626262626262626262a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 020:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a072727272727272727272727272727272424242424242424242424242424242424242424242424242424242424242424242a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a26262626262626262626262a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 021:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a2a27272727272727272727272a2a2424242424242424242424242424242424242424242424242424242424242424242424242a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 022:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2a2a24242424242424242424242424242424242424242424242424242424242424242424242424242a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 023:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2a242424242424242424242424242424242424242424242424242424242424242424242424242424242a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a282a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 024:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2a242424242424242424242424242424242424242424242424242424242424242424242424242424242a2a2a2a2a2a2a2a2a2a2a2a2a2a2828282a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 025:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2a24242424242424242424242424242424242424242424242424242424242424242424242424242424242a2a2a2a2a2a2a2a2a2a2a2a2a28282a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 026:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2424242424242424242424242424242424242424242424242424242424242424242424242424242424242a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 027:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a24242424242424242424242424242424242424242424242424242424242424242424242424242424242a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 028:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a24242424242424242424242424242424242424242424242424242424242424242424242424242424242a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 029:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a24242424242424242424242424242424242424242424242424242424242424242424242424242424242a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 030:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a242424242424242424242424242424242424242424242424242424242424242424242424242424242a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 031:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a2a2a2a2a2a2a2a2a2a2a2a242525252424242424242424242424242424242424242424242424242424242424242424242424242a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 032:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a2a2a2a2a2a2a2a2a252525252525252525252424242424242424242424242424242424242424242424242424242424242424242a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 033:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a2a2a2a2a2a2a25252525252525252525252524242424242424242424242424242424242424242424242424242424242424242a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 034:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a272a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a2a2a2a2a2525252525252525252525252525242424242424242424242424242424242424242424242424242424242424242a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 035:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a272727272727272727272a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a2a2a252525252525252525252525252525242424242424242424242424242424242424242424242424242424242424242a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 036:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a272727272727272727272727272a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a2a2525252525252525252525252525252424242424242424242424242424242424242424242424242424242424242a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 037:a29292929292a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a272727272727272727272727272727272a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a2a25252525252525252525252525252524242424242424242424242424242424242424242424242424242424242a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0
-- 038:a2929292929292a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2727272727272727272727272727272727272a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a252525252525252525252525252524242424242424242424242424242424242424242424242424242424242a2929292a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0
-- 039:a2a2a29292929292a2a2a2a2a2a2a2a2a2a2a2a2a2a2a27272727272727272727272727272727272727272a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a2a25252525252525252525252525242424242424242424242424242424242424242424242424242424242a2a2929292929292a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a29292a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0
-- 040:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a272727272727272727272727272727272727272727272a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a2a2a2a252525252525252525252a2a24242424242424242424242424242424242424242424242424242a2a2a2a2a29292929292a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a29292929292a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0
-- 041:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a272727272727272727272727272727272727272727272a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a2a2a2a2a2a2525252525252a2a2a2a2a24242424242424242424242424242424242424242424242a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a292929292a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0
-- 042:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a272727272727272727272727272727272727272727272a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2424242424242424242424242424242424242a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a29292a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0
-- 043:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a272727272727272727272727272727272727272727272a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2424242424242424242a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0
-- 044:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a27272727272727272727272727272727272727272a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0
-- 045:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2727272727272727272727272727272727272a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2828282a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0
-- 046:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2727272727272727272727272727272a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2828282a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0
-- 047:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a272727272727272727272a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0
-- 048:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a292929292a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2525252525252525252a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0
-- 049:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a29292929292a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2525252525252525252525252525252a2a2a2a2a0a0a0a0a0a0a0a0a0a0
-- 050:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a292929292a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2525252525252525252525252525252525252a2a2a2a0a0a0a0a0a0a0a0a0a0
-- 051:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a25252525252525252525252525252525252525252a2a2a2a0a0a0a0a0a0a0a0a0a0
-- 052:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a252525252525252525252525252525252525252525252a2a2a0a0a0a0a0a0a0a0a0a0
-- 053:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a292929292a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a24242a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a25252525252525252525252525252525252525252525252a2a2a0a0a0a0a0a0a0a0a0a0
-- 054:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a29292929292a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a24242424242a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a252525252525252525252525252525252525252525252525252a2a0a0a0a0a0a0a0a0a0a0
-- 055:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a292929292a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2424242424242a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a25252525252525252525252525252525252525252525252525252a2a0a0a0a0a0a0a0a0a0a0
-- 056:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a24242424242a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a292929292a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a252525252525252525252525252525252525252525252525252a2a2a0a0a0a0a0a0a0a0a0a0
-- 057:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a242424242a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2929292929292a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a252525252525252525252525252525252525252525252525252a2a2a0a0a0a0a0a0a0a0a0a0
-- 058:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a292929292a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a292929292929292a2a2a2a2a2a2a2a2a2a2a2a2a2a2525252525252525252a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2525252525252525252525252525252525252525252525252a2a2a2a0a0a0a0a0a0a0a0a0a0
-- 059:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2929292929292a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2929292929292a2a2a2a2a2a2a2a2a2a2a252525252525252525252525252a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2525252525252525252525252525252525252525252a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0
-- 060:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2929292929292a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a29292929292a2a2a2a2a2a2a2a2a25252525252525252525252525252525252a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a25252525252525252525252525252a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0
-- 061:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2929292a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a29292a2a2a2a2a2a2a2a2a2a25252525252525252525252525252525252525272727272a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0
-- 062:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a252525252525252525252525252525252525252525252727272727272a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0
-- 063:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2525252525252525252525252525252525252525252525272727272727272a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0
-- 064:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2525252525252525252525252525252525252525252525252727272727272a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0
-- 065:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a252525252525252525252525252525252525252525252525252727272727272a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0
-- 066:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a252525252525252525252525252525252525252525252525252727272727272a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 067:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2525252525252a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2525252525252525252525252525252525252525252525272727272727272a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 068:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2525252525252525252525252a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a252525252525252525252525252525252525252525272727272727272a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 069:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2525252525252525252525252525252a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a252525252525252525252525252525252727272727272727272a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a29292929292a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 070:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a25252525252525252525252525252525252a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a27272727272727272727272727272727272727272a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a292929292929292a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 071:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2525252525252525252525252525252525252a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a27272727272727272727272727272727272a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a29292929292929292a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 072:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a252525252525252525252525252525252525252a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a27272727272727272727272727272a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a292929292929292a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 073:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a252525252525252525252525252525252525252a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2727272727272727272a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2929292a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 074:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2525252525252525252525252525252525252a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 075:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a252525252525252525252525252525252a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a292929292929292a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 076:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a252525252525252525252525252a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2929292929292929292a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 077:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2525252525252a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a292929292929292a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 078:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2929292a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 079:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 080:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a282828282828282a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 081:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a282828282828282828282a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 082:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a282828282828282828282a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 083:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a28282828282828282a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 084:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 085:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 086:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a262626262626262a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 087:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2626262626262626262626262a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 088:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a262626262626262626262626262626262a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 089:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a26262626262626262626262626262626262a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 090:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a29292929292a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a262626262626262626262626262626262626262a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 091:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a29292929292a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a262626262626262626262626262626262626262a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 092:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2929292a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a26262626262626262626262626262626262626262a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 093:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a26262626262626262626262626262626262626262a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 094:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2525252525252525252a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a262626262626262626262626262626262626262a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 095:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2525252525252525252525252a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a262626262626262626262626262626262626262a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 096:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a25252525252525252525252525252a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2626262626262626262626262626262626262a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 097:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a252525252525252525252525252525252a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a26262626262626262626262626262626262a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 098:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a252525252525252525252525252525252a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a262626262626262626262626262626262a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 099:a0a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a25252525252525252525252525252525252a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a262626262626262626262626262a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 100:a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a262626262a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2525252525252525252525252525252a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a262626262626262626262a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 101:a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a262626262626262626262626262a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2525252525252525252525252525252a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a26262626262626262a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 102:a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a262626262626262626262626262626262a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2525252525252525252525252a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 103:a0a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2626262626262626262626262626262626262a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2525252525252a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a252525252525252525252a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 104:a0a0a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a262626262626262626262626262626262626262a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a252525252525252525252a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a25252a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 105:a0a0a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a262626262626262626262626262626262626262a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2525252525252525252525252a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 106:a0a0a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2626262626262626262626262626262626262a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a25252525252525252525252525252a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 107:a0a0a0a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a26262626262626262626262626262626262a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2525252525252525252525252525252a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a262626262626262a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 108:a0a0a0a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a262626262626262626262626262626262a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2525252525252525252525252525252a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2727272727272727272727272a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a26262626262626262626262a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 109:a0a0a0a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a26262626262626262626262626262a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a25252525252525252525252525252a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a272727272727272727272727272727272727272a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a262626262626262626262626262a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 110:a0a0a0a0a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a262626262626262626262a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a25252525252525252525252525252a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a272727272727272727272727272727272727272727272727272a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2626262626262626262626262626262a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 111:a0a0a0a0a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a262626262a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2525252525252525252525252a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2727272727272727272727272727272727272727272727272727272727272a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a262626262626262626262626262626262a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 112:a0a0a0a0a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2525252525252525252a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a27272727272727272727272727272727272727272424242424242424272727272a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a262626262626262626262626262626262a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 113:a0a0a0a0a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2727272727272727272727272727272727242424242424242424242424242727272a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a262626262626262626262626262626262a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 114:a0a0a0a0a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a27272727272727272727272727272424242424242424242424242424242427272a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2626262626262626262626262626262a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 115:a0a0a0a0a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a27272727272727272727272424242424242424242424242424242424272a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a26262626262626262626262626262a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 116:a0a0a0a0a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a27272727272727272724242424242424242424242424242424242a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2626262626262626262626262a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 117:a0a0a0a0a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a27272727272724242424242424242424242424242424242a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a262626262626262626262a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 118:a0a0a0a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a272724242424242424242424242424242424242a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a262626262626292a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 119:a0a0a0a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a24242424242424242424242424242424242a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a292929292929292a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 120:a0a0a0a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a242424242424242424242424242424242a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2929292929292929292a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 121:a0a0a0a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a242424242424242424242424242424242a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a292929292929292a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 122:a0a0a0a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a242424242424242424242424242424242a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 123:a0a0a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a242424242424242424242424242424242a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2929292929292a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 124:a0a0a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2424242424242424242424242424242a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a292929292929292a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 125:a0a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2424242424242424242424242424242a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a292929292929292a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 126:a0a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2828282828282a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2424242424242424242424242424242a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a292929292929292a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 127:a0a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2828282828282a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2424242424242424242424242424242a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 128:a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2828282a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a242424242424242424242424242424242a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 129:a0a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a24242424242424242424242424242424242a2a2a2a252525252525252a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 130:a0a0a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2424242424242424242424242424242a2a2a252525252525252525252525252a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 131:a0a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2424242424242424242424242424242a2525252525252525252525252525252525252a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 132:a0a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2424242424242424242424242424242a2525252525252525252525252525252525252525252a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 133:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a242424242424242424242424242a252525252525252525252525252525252525252525252525252a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 134:a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a242424242424242424242a2a2525252525252525252525252525252525252525252525252525252a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- 135:a2a2a2a2a2a2a2a2a2a2a2a2a2a2929292929292a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2525252525252525252525252525252525252525252525252525252525252a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a2a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0a0
-- </MAP>

-- <WAVES>
-- 000:eeeeeeedcb9687777777778888888888
-- 001:0123456789abcdeffedcba9876543210
-- 002:06655554443333344556789989abcdef
-- 004:777662679abccd611443377883654230
-- 005:eeedddccbbaaaaaaabbbbcccb9210000
-- </WAVES>

-- <SFX>
-- 000:020802080201020802010208020802080201020802010208020802080201020802010208020802080201020802010208020802080201020802010208b0b000000004
-- 001:8000d000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000329000000000
-- 002:040004000400040004000400040004000400040004000400040004000400040004000400040004000400040004000400040004000400040004000400b04000000000
-- </SFX>

-- <PATTERNS>
-- 000:800024000020100000000000800024000000100000000000800024000000100000000000800024000000100000000000900024000000100000000000900024000000100000000000900024000000100000000000900024000000100000000000400024000000100000000000400024000000100000000000400024000000100000000000400024000000100000000000400024000000100000000000400024000000100000000000400024000000100000000000400024000000100000000000
-- 001:500026000000800028000020c00028000000500026000020800028000020c00028000000800028000000500026000000700026000000800028000000c00028000000700026000000800028000000c00028000000800028000000700028000000800026000000c00028000000d00028000000800026000000c00028000000d00028000000c00028000000800028000000700026000000800028000000a00028000000800028000000c00028000000a00028000000800028000000700028000000
-- 002:500024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 003:50002a80002aa0002ac0002a50002a80002aa0002ac0002a83a62a00000000000000000000062000000000000000000050002a80002aa0002ac0002a50002a80002aa0002ac0002aa7d62a00000000000000000000062000000000000000000050002a80002aa0002ac0002ad0002ac0002aa0002a80002ac0002aa0002a80002aa0002ac0002ad0002ac0002a80002aa0002a80002aa0002a80002aa0002ac0002aa0002a80002ac0002aa0002a80002a70002aa0002a80002a70002af00028
-- </PATTERNS>

-- <TRACKS>
-- 000:2000002c0000480300000000000000000000000000000000000000000000000000000000000000000000000000000000000020
-- </TRACKS>

-- <FLAGS>
-- 000:10101010101010101010000000000000101010101010100010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </FLAGS>

-- <PALETTE>
-- 000:1a1c2c5d245db13e53ef7d57ffcd75a7f07038b76404650029366f3b5dc941a6f673eff7919191aeaaae656c79333434
-- </PALETTE>

-- <PALETTE1>
-- 000:1a1c2c5d245db13e53ef7d57ffcd75a7f07038b76404650029366f3b5dc941a6f673eff7919191aeaaae656c79333434
-- </PALETTE1>

