-- title:   craptorio
-- author:  @ArchaicVirus
-- desc:    De-make of Factorio
-- site:    website link
-- license: MIT License
-- version: 0.3
-- script:  lua

new_belt        = require('\\classes\\transport_belt')
new_splitter    = require('\\classes\\splitter')
new_inserter    = require('\\classes\\inserter')
ITEMS           = require('\\classes\\item_definitions')
draw_cable      = require('\\classes\\cable')
new_pole        = require('\\classes\\power_pole')
make_inventory  = require('\\classes\\inventory')
new_drill       = require('\\classes\\mining_drill')
ui              = require('\\classes\\ui')
recipies        = require('\\classes\\crafting_definitions')
simplex         = require('\\classes\\open_simplex_noise')
TileManager     = require('\\classes\\TileManager')

math.randomseed(tstamp())
offset = math.random(100000, 500000)
simplex.seed()
TileMan = TileManager:new()
floor = math.floor
sspr = spr
--image           = require('\\assets\\fullscreen_images')
--------------------COUNTERS--------------------------
TICK = 0

-------------GAME-OBJECTS-AND-CONTAINERS---------------
ENTS = {}
ORES = {}
STATE = 'main'
CURSOR_POINTER_ID = 341
CURSOR_HIGHLIGHT_ID = 312
CURSOR_HAND_ID = 356
CURSOR_GRAB_ID = 357
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
  panel_drag = false,
  drag_dir = 0,
  drag_loc = {x = 0, y = 0},
  hand_item = {id = 0, count = 0},
  drag_offset = {x = 0, y = 0}
}
player = {x = 0, y = 0, spr = 362, lx = 0, ly = 0, shadow = 382, anim_frame = 0, anim_speed = 8, anim_dir = 0, anim_max = 4, last_dir = '0,0'}
player.directions = {
  ['0,0'] = {id = 362, flip = 0, rot = 0},  --straight
  ['0,-1'] = {id = 365, flip = 0, rot = 0},  --up
  ['0,1'] = {id = 365, flip = 2, rot = 0},  --down
  ['-1,0'] = {id = 363, flip = 1, rot = 0},  --left
  ['1,0'] = {id = 363, flip = 0, rot = 0},  --right
  ['1,-1'] = {id = 364, flip = 0, rot = 0},  --up-right
  ['-1,-1'] = {id = 364, flip = 1, rot = 0},  --up-left
  ['-1,1'] = {id = 364, flip = 3, rot = 0},  --down-left
  ['1,1'] = {id = 364, flip = 2, rot = 0}   --down-right
}
cam = {x = 120, y = 64, ccx = 0, ccy = 0}
mcx, mcy, mw, mh, msx, msy = 15 - cam.ccx, 8 - cam.ccy, 31, 18, (cam.x % 8) - 8, (cam.y % 8) - 8
inv = make_inventory()
craft_menu = ui.NewCraftPanel(135, 1)
vis_ents = {}
debug = true
last_num_ents = 0
local TILE_SIZE = 8
local VIEWPORT_WIDTH = 240
local VIEWPORT_HEIGHT = 136
local MAP_WIDTH = 240 * TILE_SIZE
local MAP_HEIGHT = 136 * TILE_SIZE
local GRID_CELL_SIZE = math.ceil(VIEWPORT_WIDTH / TILE_SIZE)
local render_order = {'transport_belt', 'inserter', 'power_pole'}
--------------------FUNCTIONS-------------------------
function get_visible_ents()
  vis_ents = {['transport_belt'] = {}, ['inserter'] = {}, ['power_pole'] = {}, ['splitter'] = {}, ['dummy'] = {}}
  for x = 1, 31 do
    for y = 1, 18 do
      local worldX = (x*8) + (player.x - 116)
      local worldY = (y*8) + (player.y - 64)
      local cellX = floor(worldX / 8)
      local cellY = floor(worldY / 8)
      local key = cellX .. '-' .. cellY
      if ENTS[key] and ENTS[key].type ~= 'dummy' then
        local type = ENTS[key].type
        local index = #vis_ents[type] + 1
        --vis_ents[type][key] = ENTS[key]
        vis_ents[type][index] = key
      end
    end
  end
end

function get_key(x, y)
  local tile, wx, wy = get_world_cell(x, y)
  return wx .. '-' .. wy
end

function get_world_key(x, y)
  return x .. '-' .. y
end

function world_to_screen(world_x, world_y)
  local screen_x = world_x * 8 - (player.x - 116)
  local screen_y = world_y * 8 - (player.y - 64)
  return screen_x - 8, screen_y - 8
end

function get_cell(x, y)
  return x - (x % 8), y - (y % 8)
end

function get_screen_cell(mouse_x, mouse_y)
  local cam_x, cam_y = 116 - player.x, 64 - player.y
  local mx = floor(cam_x) % 8
  local my = floor(cam_y) % 8
  return mouse_x - ((mouse_x - mx) % 8), mouse_y - ((mouse_y - my) % 8)
end

function get_world_cell(mouse_x, mouse_y)
  local cam_x = player.x - 116
  local cam_y = player.y - 64
  local sub_tile_x = cam_x % 8
  local sub_tile_y = cam_y % 8
  local sx = floor((mouse_x + sub_tile_x) / 8)
  local sy = floor((mouse_y + sub_tile_y) / 8)
  local wx = floor(cam_x / 8) + sx + 1
  local wy = floor(cam_y / 8) + sy + 1
  return TileMan.tiles[wy][wx], wx, wy
end

function is_facing(self, other, side)
  local rotations = {
    [0] = {['left'] = 1, ['right'] = 3},
    [1] = {['left'] = 2, ['right'] = 0},
    [2] = {['left'] = 3, ['right'] = 1},
    [3] = {['left'] = 0, ['right'] = 2},
  }
  if rotations[self.rot][side] == other.rot then return true else return false end
end

function add_belt(x, y, rotation)
  local tile, cell_x, cell_y = get_world_cell(x, y)
  local key = cell_x .. '-' .. cell_y
  local belt = {}
  if ENTS[key] and ENTS[key].type ~= 'transport_belt' then return end
  if not ENTS[key] or ENTS[key].type == 'ground-items' then
    belt = new_belt({x = cell_x, y = cell_y}, cursor.rotation)
    if ENTS[key] and ENTS[key].type == 'ground-items' then
      belt.lanes = ENTS[key].items
      ENTS[key] = belt
      ENTS[key]:rotate(rotation)
    else
      ENTS[key] = belt
      ENTS[key]:rotate(rotation)
      ENTS[key]:update_neighbors()
    end
  elseif ENTS[key] and ENTS[key].type == 'transport_belt' then
    ENTS[key]:rotate(rotation)
  end
  -- local tiles = {
  --   [1] = {x = cell_x, y = cell_y - 1},
  --   [2] = {x = cell_x + 1, y = cell_y},
  --   [3] = {x = cell_x, y = cell_y + 1},
  --   [4] = {x = cell_x - 1, y = cell_y}}
  -- for i = 1, 4 do
  --   local k = tiles[i].x .. '-' .. tiles[i].y
  --   if ENTS[k] and ENTS[k].type == 'transport_belt' then ENTS[k]:set_curved() end
  -- end
  if ENTS[key] and ENTS[key].type == 'transport_belt' then ENTS[key]:set_curved() end
end

function remove_belt(x, y)
  local key = get_key(x, y)
  local tile, cell_x, cell_y = get_world_cell(x, y)
  if not ENTS[key] then return end
  if ENTS[key] and ENTS[key].type == 'transport_belt' then
    ENTS[key] = nil
  end
  local tiles = {
    [1] = {x = cell_x, y = cell_y - 1},
    [2] = {x = cell_x + 1, y = cell_y},
    [3] = {x = cell_x, y = cell_y + 1},
    [4] = {x = cell_x - 1, y = cell_y}}
  for i = 1, 4 do
    local k = tiles[i].x .. '-' .. tiles[i].y
    if ENTS[k] and ENTS[k].type == 'transport_belt' then ENTS[k]:set_curved() end
  end
end

function add_splitter(x, y)
  local child = SPLITTER_ROTATION_MAP[cursor.rotation]
  local tile, wx, wy = get_world_cell(x, y)
  wx, wy = wx + child.x, wy + child.y
  local tile2, cell_x, cell_y = get_world_cell(x, y)
  local key = get_key(x, y)
  local key2 = wx .. '-' .. wy
  if not ENTS[key] and not ENTS[key2] then
    local splitr = new_splitter(cell_x, cell_y, cursor.rotation)
    splitr.other_key = key2
    ENTS[key] = splitr
    ENTS[key2] = {type = 'dummy', other_key = key, rot = cursor.rotation}
    ENTS[key]:set_output()
  end
end

function remove_splitter(x, y)
  local key = get_key(x, y)
  if not ENTS[key] then return end
  if ENTS[key] and (ENTS[key].type == 'splitter' or ENTS[key].type == 'dummy') then
    if ENTS[key].type == 'dummy' then key = ENTS[key].other_key end
    local key_l, key_r = ENTS[key].output_key_l, ENTS[key].output_key_r
    --trace('removing splitters: ')
    local key2 = ENTS[key].other_key
    --trace(key)
    --trace(key2)
    ENTS[key] = nil
    ENTS[key2] = nil
    if ENTS[key_l] and ENTS[key_l].type == 'transport_belt' then ENTS[key_l]:update_neighbors(key) end
    if ENTS[key_r] and ENTS[key_r].type == 'transport_belt' then ENTS[key_r]:update_neighbors(key) end
  end
end

function add_inserter(x, y, rotation)
  local key = get_key(x, y)
  local tile, cell_x, cell_y = get_world_cell(x, y)
  if ENTS[key] and ENTS[key].type == 'inserter' then
    if ENTS[key].rot ~= rotation then
      ENTS[key]:rotate(rotation)
    end
  elseif not ENTS[key] then
    ENTS[key] = new_inserter({x = cell_x, y = cell_y}, rotation)
  end
end

function remove_inserter(x, y)
  local key = get_key(x, y)
  if not ENTS[key] then return end
  if ENTS[key] and ENTS[key].type == 'inserter' then
    ENTS[key] = nil
  end
end

function add_pole(x, y)
  local key = get_key(x,y)
  local tile, cell_x, cell_y = get_world_cell(x, y)
  if not ENTS[key] then
    ENTS[key] = new_pole({x = cell_x, y = cell_y})
  end
end

function remove_pole(x, y)
  local key = get_key(x, y)
  if not ENTS[key] then return end
  if ENTS[key] and ENTS[key].type == 'power_pole' then
    ENTS[key] = nil
  end
end

function move_player(x, y)
  -- local tile_nw = fget(mget(get_world_cell(cam.x + x,     cam.y + y    )), 0)
  -- local tile_ne = fget(mget(get_world_cell(cam.x + x + 7, cam.y + y    )), 0)
  -- local tile_se = fget(mget(get_world_cell(cam.x + x + 7, cam.y + y + 7)), 0)
  -- local tile_sw = fget(mget(get_world_cell(cam.x + x,     cam.y + y + 7)), 0)
  -- local info = {
  --   [1] = 'tile_nw:' .. tostring(tile_nw),
  --   [2] = 'tile_ne:' .. tostring(tile_ne),
  --   [3] = 'tile_se:' .. tostring(tile_se),
  --   [4] = 'tile_sw:' .. tostring(tile_sw),
  -- }
  --draw_debug2(info, 10)
  --if tile_nw and tile_ne and tile_se and tile_sw then
    player.lx, player.ly = player.x, player.y
    player.x, player.y = x, y
  --end
end

function update_player()
  if TICK % player.anim_speed == 0 then
    if player.anim_dir == 0 then
      player.anim_frame = player.anim_frame + 1
      if player.anim_frame > player.anim_max then
        player.anim_dir = 1
        player.anim_frame = player.anim_max
      end
    else
      player.anim_frame = player.anim_frame - 1
      if player.anim_frame < 0 then
        player.anim_dir = 0
        player.anim_frame = 0
      end
    end
  end
  player.lx, player.ly = player.x, player.y
  local x_dir, y_dir = 0, 0
  if key(23) then --w
    y_dir = -1
  end
  if key(19) then --s
    y_dir = 1
  end
  if key(1)  then --a
    x_dir = -1
  end
  if key(4)  then --d
    x_dir = 1
  end
  move_player(player.x + x_dir, player.y + y_dir)
  player.last_dir = x_dir .. ',' .. y_dir
end

function draw_player()
  local sprite = player.directions[player.last_dir] or player.directions['0,0']
  sspr(player.shadow - player.anim_frame, 116, 76, 0)
  sspr(sprite.id, 116, 64 + player.anim_frame, 0, 1, sprite.flip)
end

--temp
local cursor_items = {[0] = 'transport_belt', [1] = 'inserter', [2] = 'power_pole', [3] = 'pointer', [4] = 'splitter'}
local cursor_item = 4

function cycle_hotbar(dir)
  cursor_item = cursor_item + dir
  inv.active_slot = inv.active_slot + dir
  if inv.active_slot < 1 then inv.active_slot = 10 end
  if inv.active_slot > 10 then inv.active_slot = 1 end
  if cursor_item < 0 then cursor_item = 4 end
  if cursor_item > 4 then cursor_item = 0 end
  cursor.item = cursor_items[cursor_item]
end

function add_item(x, y, id)
  local key = get_key(x, y)
  if ENTS[key] and ENTS[key].type == 'transport_belt' then
    ENTS[key].idle = false
    ENTS[key].lanes[1][8] = id
    ENTS[key].lanes[2][8] = id
  end
end

function draw_debug2(data, x, y)
  if debug then
    screen_y = screen_y or 0
    local width = 90
    local height = (#data * 6) + 3
    rectb(0, screen_y, width, height, 12)
    rect(1, screen_y + 1, width - 2, height - 2, 15)
    for i = 1, #data do
      print(data[i], 2, i*6 - 4 + screen_y, 2, true, 1, true)
    end
  end
end

function draw_ground_items()
  -- for i = 1, #GROUND_ITEMS do
  --   if GROUND_ITEMS[i][1] > 0 then
  --     draw_pixel_ssprite(GROUND_ITEMS[i][1], GROUND_ITEMS[i][2], GROUND_ITEMS[i][3])
  --   end
  -- end
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
    cursor.tile_x, cursor.tile_y = get_screen_cell(x, y)
  end 
end

function draw_cursor()
  local x, y = cursor.x, cursor.y
  local key = get_key(x, y)

  if inv:is_hovered(x, y) or craft_menu:is_hovered(x, y) then
    if cursor.panel_drag then
      sspr(CURSOR_GRAB_ID, cursor.x - 1, cursor.y - 1, 0, 1, 0, 0, 1, 1)
    else
      sspr(CURSOR_HAND_ID, cursor.x - 2, cursor.y, 0, 1, 0, 0, 1, 1)
    end
    return
  end

  if cursor.item == 'transport_belt' then
    if cursor.drag then
      local sx, sy = world_to_screen(cursor.drag_loc.x, cursor.drag_loc.y)
      if cursor.drag_dir == 0 or cursor.drag_dir == 2 then
        sspr(CURSOR_HIGHLIGHT_ID, cursor.tile_x - 1, sy - 1, 0, 1, 0, 0, 2, 2)
      else
        sspr(CURSOR_HIGHLIGHT_ID, sx - 1, cursor.tile_y - 1, 0, 1, 0, 0, 2, 2)
      end
      --arrow to indicate drag direction
      sspr(287, cursor.tile_x, cursor.tile_y, 0, 1, 0, cursor.drag_dir, 1, 1)
    elseif not ENTS[key] or (ENTS[key] and ENTS[key].type == 'transport_belt' and ENTS[key].rot ~= cursor.rotation) then
      sspr(BELT_ID_STRAIGHT + BELT_TICK, cursor.tile_x, cursor.tile_y, 00, 1, 0, cursor.rotation, 1, 1)
      sspr(CURSOR_HIGHLIGHT_ID, cursor.tile_x - 1, cursor.tile_y - 1, 0, 1, 0, 0, 2, 2)
    else
      sspr(CURSOR_HIGHLIGHT_ID, cursor.tile_x - 1, cursor.tile_y - 1, 0, 1, 0, 0, 2, 2)
    end
  elseif cursor.item == 'inserter' then
    if not ENTS[key] or (ENTS[key] and ENTS[key].type == 'inserter' and ENTS[key].rot ~= cursor.rotation) then
      local tile, world_x, world_y = get_world_cell(cursor.tile_x, cursor.tile_y)
      local temp_inserter = new_inserter({x = world_x, y = world_y}, cursor.rotation)
      spr(CURSOR_HIGHLIGHT_ID, cursor.tile_x - 1, cursor.tile_y - 1, 0, 1, 0, 0, 2, 2)
      temp_inserter:draw()
    end
    spr(CURSOR_HIGHLIGHT_ID, cursor.tile_x - 1, cursor.tile_y - 1, 0, 1, 0, 0, 2, 2)
  elseif cursor.item == 'power_pole' then
    local tile, world_x, world_y = get_world_cell(cursor.tile_x, cursor.tile_y)
    local temp_pole = new_pole({x = world_x, y = world_y})
    temp_pole:draw(true)
    --check around cursor to attach temp cables to other poles
  elseif cursor.item == 'pointer' then
    sspr(CURSOR_POINTER_ID, cursor.x, cursor.y, 0, 1, 0, 0, 1, 1)
    sspr(CURSOR_HIGHLIGHT_ID, cursor.tile_x - 1, cursor.tile_y - 1, 0, 1, 0, 0, 2, 2)
    pix(cursor.x, cursor.y, 2)
  elseif cursor.item == 'splitter' then
    local loc = SPLITTER_ROTATION_MAP[cursor.rotation]
    sspr(CURSOR_HIGHLIGHT_ID, cursor.tile_x - 1, cursor.tile_y - 1, 0, 1, 0, 0, 2, 2)
    sspr(CURSOR_HIGHLIGHT_ID, cursor.tile_x - 1 + (loc.x * 8), cursor.tile_y - 1 + (loc.y * 8), 0, 1, 0, 0, 2, 2)
    sspr(SPLITTER_ID, cursor.tile_x, cursor.tile_y, 0, 1, 0, cursor.rotation, 1, 2)
  end
end

function rotate_cursor()
  if not cursor.drag then
    cursor.rotation = cursor.rotation + 1
    if cursor.rotation > 3 then cursor.rotation = 0 end
    local key = get_key(cursor.x, cursor.y)
    local tile, cell_x, cell_y = get_world_cell(cursor.x, cursor.y)
    if ENTS[key] then
      if ENTS[key].type == 'transport_belt' and cursor.item == 'pointer' then
        ENTS[key]:rotate(ENTS[key].rot + 1)
        local tiles = {
          [1] = {x = cell_x, y = cell_y - 1},
          [2] = {x = cell_x + 1, y = cell_y},
          [3] = {x = cell_x, y = cell_y + 1},
          [4] = {x = cell_x - 1, y = cell_y}}
        for i = 1, 4 do
          local k = get_world_key(tiles[i].x, tiles[i].y)
          if ENTS[k] and ENTS[k].type == 'transport_belt' then ENTS[k]:set_curved() end
        end
      end
      if ENTS[key].type == 'inserter' and cursor.item == 'pointer' then
        ENTS[key]:rotate(ENTS[key].rot + 1)
      end
    end
  end
end

function place_tile(x, y, rotation)
  if cursor.item == 'transport_belt' then
    add_belt(x, y, cursor.rotation)
  elseif cursor.item == 'inserter' then
    add_inserter(x, y, cursor.rotation)
  elseif cursor.item == 'power_pole' then
    add_pole(x, y)
  elseif cursor.item == 'splitter' then
    add_splitter(x, y)
  end
end

function remove_tile(x, y)
  local tile, wx, wy = get_world_cell(x, y)
  local key = wx .. '-'.. wy
  if ENTS[key] then
    if ENTS[key].type == 'transport_belt' then
      remove_belt(x, y)
    elseif ENTS[key].type == 'inserter' then
      remove_inserter(x, y)
    elseif ENTS[key].type == 'power_pole' then
      remove_pole(x, y)
    elseif ENTS[key].type == 'splitter' or ENTS[key].type == 'dummy' then
      remove_splitter(x, y)
    end
  end

end

function pipette()
  if cursor.item == 'pointer' then
    local key = get_key(cursor.x, cursor.y)
    if ENTS[key] then
      if ENTS[key].type == 'dummy' then
        key = ENTS[key].other_key
      end
      cursor.item = ENTS[key].type
      if ENTS[key].rot then
        cursor.rotation = ENTS[key].rot
      end
      return
    end
  else
    cursor.item = 'pointer'
  end
end

function handle_input()
  local x, y, left, middle, right, scroll_x, scroll_y = mouse()
  if scroll_y ~= 0 then cycle_hotbar(scroll_y*-1) end
  move_cursor('mouse', x, y)

  if not left and cursor.last_left and cursor.drag then
    local sx, sy = world_to_screen(cursor.drag_loc.x, cursor.drag_loc.y)
    cursor.drag = false
    if cursor.drag_dir == 0 or cursor.drag_dir == 2 then
      cursor.tile_y = sy
    else      
      cursor.tile_x = sx
    end
  end

  local tile, tile_x, tile_y = get_world_cell(x, y)
  local screen_tile_x, screen_tile_y = get_screen_cell(x, y)
  local k = get_key(x, y)

  if cursor.item == 'transport_belt' and not cursor.drag and left and cursor.last_left then
    --drag locking/placing belts
    cursor.drag = true
    local screen_x, screen_y = get_screen_cell(x, y)
    local tile, wx, wy = get_world_cell(x, y)
    cursor.drag_loc = {x = wx, y = wy}
    cursor.drag_dir = cursor.rotation
  end

  if cursor.item == 'transport_belt' and cursor.drag then
    local dx, dy = world_to_screen(cursor.drag_loc.x, cursor.drag_loc.y)
    if cursor.drag_dir == 0 or cursor.drag_dir == 2 and screen_tile_x ~= cursor.last_tile_x then
      place_tile(x, dy, cursor.drag_dir)
    elseif cursor.drag_dir == 1 or cursor.drag_dir == 3 and screen_tile_y ~= cursor.last_tile_y then
      place_tile(dx, y, cursor.drag_dir)
    end
  end

  if left and not cursor.last_left then place_tile(x, y, cursor.rotation) end
  if right then remove_tile(x, y) end
  if ENTS[k] then ENTS[k].is_hovered = true end

  if keyp(18) and not keyp(63) then rotate_cursor()end --r
  if keyp(17) then pipette()            end --q
  if key(6)   then add_item(x, y, 1)          end --f
  if key(7)   then add_item(x, y, 2)          end --g
  if keyp(9) or keyp(49) then toggle_inventory() end --i or tab
  if keyp(8) then toggle_hotbar() end
  if keyp(3) then toggle_crafting() end
  if keyp(25) then debug = debug == false and true or false end

  if craft_menu.vis and not cursor.panel_drag and left and not cursor.last_left and craft_menu:is_hovered(x, y) == true then
    if craft_menu:click(x, y) then
    elseif not craft_menu.docked then
      cursor.panel_drag = true
      cursor.drag_offset.x = craft_menu.x - x
      cursor.drag_offset.y = craft_menu.y - y
    end
  end
  if not left then cursor.panel_drag = false end
  if craft_menu.vis and cursor.panel_drag then
    craft_menu.x = math.max(1, math.min(x + cursor.drag_offset.x, 239 - craft_menu.w))
    craft_menu.y = math.max(1, math.min(y + cursor.drag_offset.y, 135 - craft_menu.h))
  end

  if left and not cursor.last_left and not craft_menu:is_hovered(x, y) and inv:is_hovered(x, y) then
    local slot = inv:get_hovered_slot(x, y)
    inv.slots[slot.index]:callback()
  end

  cursor.last_tile_x, cursor.last_tile_y = cursor.tile_x, cursor.tile_y
  cursor.tile_x, cursor.tile_y = screen_tile_x, screen_tile_y
  cursor.last_rotation = cursor.rotation
  cursor.last_x, cursor.last_y, cursor.last_left, cursor.last_mid, cursor.last_right = cursor.x, cursor.y, left, middle, right
  cursor.x, cursor.y = x, y
end

function toggle_hotbar()
  if not inv.hotbar_vis then
    inv.hotbar_vis = true
  else
    inv.hotbar_vis = false
    inv.hovered_slot = -1
  end
end

function toggle_inventory()
  if not inv.vis then
    inv.vis = true
  else
    inv.hovered_slot = -1
    inv.vis = false
  end
end

function toggle_crafting()
  craft_menu.vis = craft_menu.vis == false and true or false
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

function update_ents()
  if TICK % 5 == 0 then
    for k, v in pairs(ENTS) do
      if v.type ~= 'dummy' then
        v:update()
      end
    end
  end
end

function draw_ents()
  for index, key in pairs(vis_ents['transport_belt']) do
    if ENTS[key] then ENTS[key]:draw() end
  end
  for index, key in pairs(vis_ents['transport_belt']) do
    --trace('drawing belt items')
    if ENTS[key] then ENTS[key]:draw_items() end
  end
  for index, key in pairs(vis_ents['inserter']) do
    if ENTS[key] then ENTS[key]:draw() end
  end
  for index, key in pairs(vis_ents['power_pole']) do
    if ENTS[key] then ENTS[key]:draw() end
  end
  for index, key in pairs(vis_ents['splitter']) do
    --trace('DRAWING ENT - KEY: ' .. tostring(key) .. ', VALUE: ' .. tostring(ent.type))
    if ENTS[key] then ENTS[key]:draw() end
  end
end

function draw_ents2()
  for k, v in pairs(vis_ents) do
    if k == 'transport_belt' then
      for index, key in pairs(vis_ents[k]) do
        if ENTS[key] then ENTS[key]:draw() end
      end
      for index, key in pairs(vis_ents[k]) do
        if ENTS[key] then ENTS[key]:draw_items() end
      end
    elseif k == 'splitter' then
      for index, key in ipairs(vis_ents[k]) do
        if ENTS[key] then ENTS[key]:draw() end
      end
      -- for index, key in ipairs(vis_ents[k]) do
      --   if ENTS[key] then ENTS[key]:draw_items() end
      -- end
    else
      for index, key in pairs(vis_ents[k]) do
        --trace('drawing ent' .. k)
        if ENTS[key] then ENTS[key]:draw() end
      end
    end
  end
end

function draw_belt_items()
  for k, ent in pairs(vis_ents) do
    if ent.type == 'transport_belt' and not ent.drawn then
      ent:draw_items()
    end
  end
end

function draw_map()
  TileMan:draw(player, 31, 18)
end

local function lapse(fn, ...)
	local t = time()
	fn(...)
	return floor((time() - t))
end

function TIC()
  TICK = TICK + 1
  local start = time()
  --remove mouse cursor
  poke(0x3FFB, 0x000000, 8)
  cls(0)
  local gv_time = lapse(get_visible_ents)
  --update_camera()
  --local uc_time = lapse(update_camera)
  --map(15 - cam.ccx, 8 - cam.ccy, 31, 18, (cam.x % 8) - 8,(cam.y % 8) - 8)
  --local m_time = lapse(draw_map)
  local m_time = lapse(draw_map)
  --update_player()
  local up_time = lapse(update_player)
  --handle_input()
  local hi_time = lapse(handle_input)

  if TICK % BELT_TICKRATE == 0 then
    BELT_TICK = BELT_TICK + 1
    if BELT_TICK > BELT_MAXTICK then BELT_TICK = 0 end
  end

  local ue_time = lapse(update_ents)
  --draw_ents()
  local de_time = lapse(draw_ents)
  
  -- local key = get_key(cursor.x, cursor.y)
  -- local cell_x, cell_y = get_world_cell(cursor.x, cursor.y)
  -- local tile_id = mget(cell_x, cell_y)
  -- local info = {
  --   [1] = 'player: ' ..player.x .. ',' .. player.y,
  --   [2] = 'camera: ' .. cam.x .. ',' .. cam.y,
  --   [3] = 'ccx/ccy: ' .. (cam.x%8)-8 .. ',' .. (cam.y%8)-8,
  --   [4] = 'tile: ' .. cell_x .. ',' .. cell_y,
  --   [5] = 'tileID: ' .. tile_id,
  --   [6] = '#ENTS: ' .. #ENTS,
  --   [7] = 'VIS ENTS: ' .. #ents,
  -- }

  -- if ENTS[key] and ENTS[key].type == 'transport_belt' then
  --   local item_info = ENTS[key]:get_info()
  --   for i = 1, #item_info do
  --     info[7 + i] = item_info[i]
  --   end
  -- end
    --local db_time = lapse(draw_belt_items)

  --draw_debug2(info)
  draw_player()
  --sspr(player.spr, 116, 64, 1, 1, 0, 0, 1, 2)
  
  for k, v in pairs(ENTS) do
    v.updated = false
    v.drawn = false
    v.is_hovered = false
    if v.type == 'transport_belt' then v.belt_drawn = false; v.curve_checked = false; end
  end
  
  
  
  inv:draw()
  --inv:draw_hotbar()
  craft_menu:draw()
  local dc_time = lapse(draw_cursor)

  --draw_cursor()

  --   local info = {
  --   --[1] = 'update_camnera: ' .. uc_time,
  --   [1] = 'nil',
  --   [2] = 'draw_map: ' .. m_time,
  --   [3] = 'update_player: ' .. up_time,
  --   [4] = 'handle_input: ' .. hi_time,
  --   [5] = 'draw_ents: ' .. de_time,
  --   [6] = 'update_ents:' .. ue_time,
  --   [7] = 'draw_cursor: ' .. dc_time,
  --   [8] = 'draw_belt_items: ' ..db_time,
  --   [9] = 'get_vis_ents: ' .. gv_time,
  -- }
  local ents = 0
  for k, v in pairs(vis_ents) do
    for _, ent in ipairs(v) do
      ents = ents + 1
    end
  end
  local tile, wx, wy = get_world_cell(cursor.x, cursor.y)
  local sx, sy = get_screen_cell(cursor.x, cursor.y)
  local key = get_key(cursor.x, cursor.y)
  local info = {
    [1] = 'Wx,Wy: ' .. wx ..',' .. wy,
    [2] = 'Tile: ' .. tile,
    [3] = 'Sx,Sy: ' .. sx .. ',' .. sy,
    [4] = 'Key: ' .. key,
    [5] = '#Ents: ' .. ents,
    [6] = 'Frame Time: ' .. floor(time() - start) .. 'ms'
  }
  -- local info
  -- local ent = ENTS[key]
  -- if ent then
  --   if ent.type == 'transport_belt' or ent.type == 'splitter' then
  --     info = ent:get_info()
  --   else
  --     info = {
  --       [1] = 'ENT: ' .. ent.type,
  --       [2] = 'ROT: ' .. ent.type ~= 'power_pole' and ent.rot or 'nil',
  --       [3] = 'MAP: ' .. key
  --     }
  --   end
  --   --if ent.other_key then info[4] = 'OTK: ' .. ent.other_key end
  --   info[#info + 1] = 'MAP: ' .. key
  -- else
  --   info = {
  --     [1] = 'nil',
  --     [2] = 'KEY: ' .. key
  --   }
  -- end
  draw_debug2(info)
end

-- <TILES>
-- 000:6666666666666676666667666666676667666666667666666676666666666666
-- 001:6666666666666666666666666666666666666666666666666666666666666666
-- 002:6666666666666666666666666666666666666666666666666666666666666666
-- 003:6666666666666666666666666666666666666666666666666666666666666666
-- 004:6d66e6666ee666e6dd66d666666e666e6de666d6e6666e666ed666e6666d666d
-- 005:6f6666c666f66666666666666666d6666c66666666666d666e666df66d666666
-- 006:666d66666ce66de66df6666fd6e666666666de666d666d666d6f666d6666d666
-- 007:6666666666666666666666666666666666666666666666666666666666666666
-- 008:4444444443443444444444444444443434444444444344444444444443444434
-- 009:4444444443443444444444444444443434444444444344444444444443444434
-- 010:9999999999999999999999999999999999999999999999999999999999999999
-- 011:9999999999999999999999999999999999999999999999999999999999999999
-- 012:9899a99999b999999a99898999999999989a99b9999899a99a9999999989b899
-- 013:9999999999899989999989999999998998999999999899999899989999999999
-- 014:9999999999899989999989999999998998999999999899999899989999999999
-- 015:9999999999899989999989999999998998999999999899999899989999999999
-- 016:6666666666666666666666666666666666666666666666666666666666666666
-- 017:6666466663266346634666666646666446663466646662666362663636664666
-- 018:6366626666646666636642632666366466666666624466666336643666664666
-- 019:6664666626666636662666466643666664666463666664366436623666646666
-- 020:6666666666666666666666666666666666666666666666666666666666666666
-- 021:6666666666666666666666666666666666666666666666666666666666666666
-- 022:6666666666666666666666666666666666666666666666666666666666666666
-- 023:9899a99999b999999a99898999999999989a99b9999899a99a9999999989b899
-- 024:6666666666666666666666666666666666666666666666666666666666666666
-- 025:6666666666666666666666666666666666666666666666666666666666666666
-- 026:6666666666666666666666666666666666666666666666666666666666666666
-- 027:6666666666666666666666666666666666666666666666666666666666666666
-- 028:6d66e6666ee666e6dd66d666666e666e6de666d6e6666e666ed666e6666d666d
-- 029:666d66666ce66de66df6666fd6e666666666de666d666d666d6f666d6666d666
-- 030:6f6666c666f6666666666666666666666c66666666666d666e666df66d666666
-- 031:6666666666666666666666666666666666666666666666666666666666666666
-- 032:6666666676666666666666667666666666666666766666666566666606767676
-- 033:6666666666666666666666666666666666666666666666666666666676767676
-- 034:0676767665666666766666666666666666666666766666666566666606767676
-- 035:6766666666766666667666676666667666666676666666666666666666666666
-- 036:6ce6ce66ccd6ecc6cee66ce666666666edcc6ee6ecc66ece6ee6eeec666666e6
-- 037:6346346642362436334663466666666633436436423362346346343366666326
-- 038:6ce6cf668bd6fdb68ee668f666666666edcb6ff6fc8e68cf6ff6ffbc66666ef6
-- 039:660f66f060f06f0f6f0660066666666666f060666f066f0f6f0f600660f66666
-- 040:66756766766576f67f75577f57756557676756766676577f5f656676555756f5
-- 041:0ff01100f111111f1f111f10111111f111111111111ff11111f1111ff11111f0
-- 042:6666666666666666666666666666666666666666666666666666666666666666
-- 043:6666666666666666666666666666666666666666666666666666666666666666
-- 044:4444444444444444444444444444444444444444444444444444444444444444
-- 045:6ce6cf668bd6fdb68ee668f666666666edcb6ff6fc8e68cf6ff6ffbc66666ef6
-- 046:66666cd66d86688668666666666d6666686666d66d6668c6dc866686e8666d66
-- 047:f000f00f000000f0000f0000f000000f00000f00f0f0000f0000f0f00f0f000f
-- 048:6666666667666666667667666676766666767666666666666666666666666666
-- 049:6666666666667666766776666767766767677676676776766666666666666666
-- 050:6666666666d666666d2d66d666d66d2d667666d6667666766666666666666666
-- 051:6676666667566666765666667664666676666766666665766666656766663667
-- 052:6676666666666666766667666666666666666666666676666766666666666667
-- </TILES>

-- <TILES1>
-- 000:11efef111efefef11eeeeee11efefee11f6f6ff11efdfed111dddd11110dd011
-- 001:11fefe111fefefe11eeeeee11eefefe11ff6f6f11defdfe111dddd11110dd011
-- 007:000fffff00fddddd0fdcfffefdcef4fefdeeedeefdeef4fefdeefffefdeeecee
-- 008:ffffffffdcfcddddcfdfceecfcfcfeeeeeeeeeeeff4d4ffffeeeeddeceeedefd
-- 009:00000000f0000000df000000cdf00000edf00000fdf00000edf00000edf00000
-- 010:000fffff00fddddd0fdcfff9fdc9f4f9fd999d99fd99f4f9fd99fff9fd999899
-- 011:ffffffffdcfcddddcfdfc99cfcfcf99999999999ff4d4ffff9999dd98999defd
-- 012:00000000f0000000df000000cdf000009df00000fdf000009df000009df00000
-- 013:000fffff00fddddd0fdcfff4fdc4f4f4fd444d44fd44f4f4fd44fff4fd444844
-- 014:ffffffffdcfcddddcfdfc44cfcfcf44444444444ff4d4ffff4444dd48444defd
-- 015:00000000f0000000df000000cdf000004df00000fdf000004df000004df00000
-- 016:10effe0110feef1010effe101deeee1d118ff81111411f111111141111111111
-- 017:10effe0101feef0101effe01d1eeeed1118ff81111f114111141111111111111
-- 023:fdeeecccfdeeeeeefdeedddefdedfffdfdedeeedfdedfffdfdedeeedfdedfffd
-- 024:cceedfedeceeeddeeceeeeeeeceeeeefeccccccfeeeceeefeeeceeeee4fff4ee
-- 025:edf00000edf00000edf00000fdf000004df00000fdf00000edf00000edf00000
-- 026:fd999888fd999999fd99ddd9fd9dcccdfd9defedfd9dcccdfd9dfefdfd9dcccd
-- 027:8899dfed98999dd9989999999899999f9888888f9998999f9998999994fff499
-- 028:9df000009df000009df00000fdf000004df00000fdf000009df000009df00000
-- 029:fd444888fd444444fd44ddd4fd4dcccdfd4defedfd4dcccdfd4dfefdfd4dcccd
-- 030:8844dfed48444dd4484444444844444f4888888f4448444f4448444444fff444
-- 031:4df000004df000004df00000fdf000004df00000fdf000004df000004df00000
-- 032:11efef111efefef11eeeeee11efefee11f6f6ff11efdfed111dddd11110dd011
-- 033:11fefe111fefefe11eeeeee11eefefe11ff6f6f11defdfe111dddd11110dd011
-- 034:1fffff11ffefeff1fcccccf1cffcffc1f5ff5ff1cffcffc11ccccc1110eee011
-- 035:1fffff11ffefeff1fcccccf1cffcffc1f55f55f1cffcffc11ccccc1110eee011
-- 036:1fffff11ffefeff1fcccccf1cffcffc1ff5ff5f1cffcffc11ccccc1110eee011
-- 037:1fffff11ffeeeff1fecccef1eccfcfe1fff5f5f1eccfcfe11eccce1110efe011
-- 038:1ffeff11efefefe1fecccef1cecccec1fffffff1cecccec11eccce1110ddd011
-- 039:fdceddde0fdceeee00fddddd000fffff00000000000000000000000000000000
-- 040:edeeedeeeceeececddddddddffffffff00000000000000000000000000000000
-- 041:cdf00000df000000f00000000000000000000000000000000000000000000000
-- 042:fdceddd90fdc999900fddddd000fffff00000000000000000000000000000000
-- 043:9d999d999899989cddddddddffffffff00000000000000000000000000000000
-- 044:cdf00000df000000f00000000000000000000000000000000000000000000000
-- 045:fdceddd40fdc444400fddddd000fffff00000000000000000000000000000000
-- 046:4d444d444844484cddddddddffffffff00000000000000000000000000000000
-- 047:cdf00000df000000f00000000000000000000000000000000000000000000000
-- 048:10effe0110feef0110effe011deeeed1118ff81111f11f111141141111111111
-- 049:10effe0110feef0110effe011deeeed1118ff81111f11f111141141111111111
-- 050:0dfffd010fffff010efffe010eeeee01cedddec11ed1de111ff1ff1114414411
-- 051:0dfffd010fffff010efffe010eeeee01cedddec11ed1de111ff1ff1114414411
-- 052:0dfffd010fffff010efffe010eeeee01cedddec11ed1de111ff1ff1114414411
-- 053:0dfffd010fffff010efffe010eeeee01cedddec11ed1de111ff1ff1114414411
-- 054:ecfffce10fffff010efffe010eeeee01deccced11ec1ce111ff1ff1114414411
-- 064:000000fc00000fee00000d5500000d7700000dcc000000de0000000d000fffce
-- 065:cf000000eef0000055d0000077d00000ccd00000ed000000d0000000ecfff000
-- 066:00fccf000feeeef00d6655d00d7777d00dccccd002deed20200dd00200300300
-- 067:00fccf000feeeef00dccc6500dccc7700dccccd00ede2de0e00d200e00030000
-- 068:200fff0002fe65f000dce65f0dccde6f0dceccefcedccdf00cedd02000c00002
-- 069:00feef000feccef00dceecd0ecdccdce0d2dd2d002deed202003300200300300
-- 071:00000000000fffff00fddddd0fdffccf0fdf47740fdffccf0fdccccc0fdccccc
-- 072:00000000ffffffffddddddddfcccccccf888ccccfcc8cc88ccc8cc8cffffffff
-- 073:00000000fffff000dddddf00ceeecdf0efefedf08efeedf0efefedf0ce8ecdf0
-- 075:0ffffff0feeeeeeffeeeeeeffeeeeeeffeeeeeeffeeeeeeffeeeeeef0ffffff0
-- 080:00fefcec0feefecc0feefecc0fcedfec0fccffcc00000fcc00000fec0000fecc
-- 081:cecfef00ccefeef0ccefeef0cefdecf0ccffccf0ccf00000cef00000ccef0000
-- 082:00000000000000000000000000f0f0f00f0f0f0000f0f0f00f0f0f0000000000
-- 083:00000000000000000000000000f0f0f00f0f0f0000f0f0f00f0f0f0000000000
-- 084:00000000000000000000000000f0f0f00f0f0f0000f0f0f00f0f0f0000000000
-- 085:00000000000000000000000000f0f0f00f0f0f0000f0f0f00f0f0f0000000000
-- 087:0fdccccf0f488ccf0fdc8ccf0fdc8ccf0fdc888f0fdccccf0fdccccf0fdccccf
-- 088:efcefcefcedcedcecedcedcecedcedcecedcedcecedcedcecedcedceefcefcef
-- 089:fc8ccdf0fc8c88f0fc8874f0fccc88f0fccccdf0f88ccdf0fc8ccdf0fc8ccdf0
-- 096:0000fccc0000fddf0000effe0000fccf0000fddf00000ff000000d400000dff0
-- 097:cccf0000fddf0000effe0000fccf0000fddf00000ff0000004d000000ffd0000
-- 098:00fccf000feeeef00d7657d00dc77cd00decced002dccd20200dd00200300300
-- 099:00fccf000feeeef00dccc6500deecc700dcceed00e3ed2e0e300200e00020000
-- 100:000fff0002fe75f020dc765f0dccd77f0dceccefcedccdf00cedd02000c00200
-- 101:00feef000feccef00dceecd0ecdccdce0d2dd2d002deed202003300200300300
-- 103:0fdccccc0fdccccc0fdedddd0fedfefe0fdecece00fefefe000fffff00000000
-- 104:ffffffffccccc8ccdeccc8ccfdecc888cedcccccfeddddddffffffff00000000
-- 105:cc8c88f0cc8847f0cccc88f088cccdf0c8cccdf0d4dddf00fffff00000000000
-- 114:00000000000000000000000000ffff000ffffff00ffffff000ffff0000000000
-- 115:00000000000000000000000000ffff000ffffff00ffffff000ffff0000000000
-- 116:000000000000000000000000000ff00000ffff0000ffff00000ff00000000000
-- 117:00000000000000000000000000000000000ff00000ffff00000ff00000000000
-- 118:0000000000000000000000000000000000000000000ff0000000000000000000
-- 135:000fffff00fdcfcd0fdcfffefdcef4fefdeeedeefdeef4fefccefffeffceefee
-- 136:ffffffffddddddddfcf4fcfeffcfcffdeeefeefeff4d4ffffeeeeeeffeeecc3f
-- 137:fffff000dc4cdf00eefecdf0eeffecdfdeefeedfededecdfede4eedfededecdf
-- 138:044e04440e4e0ee40e4e04440e4e04ee0e4e04440fff0fff0fff0fff0fff0fff
-- 140:444004444ee004ee44400444ee4004e444400444fff00ffffff00ffffff00fff
-- 142:444004444e4004e4444004e4ee4004e4ee400444fff00ffffff00ffffff00fff
-- 144:00000000000ddddd00dfcfff0dccfddd0dcfdcef0dcfdef80dcfdcef0dcfdeee
-- 145:00000000ddddddddffffffffddddddddeeefeeeffef8fef5eeefeeefeeeeeeee
-- 146:00000000ddddd000fffccd00dddfccd0ecedfcd0fecdfcd0eeedfcd0eecdfcd0
-- 147:00000000000ddddd00dfefff0deefddd0defdcef0defdef80defdcef0defdeee
-- 148:00000000ddddddddffffffffddddddddeeefeeeffef8fef8eeefeeefeeeeeeee
-- 149:00000000ddddd000fffeed00dddfeed0ecedfed0fecdfed0eeedfed0eecdfed0
-- 151:fcffffccffceeeeefccedddefdedfffdfdedeeedfdedfffdfdedeeedfdeeddde
-- 152:ceeceeefececeeefececeeffececef77eec4cf67eeecef77eeecef77eeecef77
-- 153:d4dfeedfedefecdffefffedf7f776fdf7f777fdf7f677fdf6f777fdf7f767fdf
-- 154:044404e40ee404e40e4404440ee40ee404440ee40fff0fff0fff0fff0fff0fff
-- 156:44400444ee4004e4ee400444ee4004e4ee400444fff00ffffff00ffffff00fff
-- 160:0dcfdfff0dcfdf570dcfdfff0defdddd0defcddc0defcddc0defcccc0defceec
-- 161:ffffffff77777777ffffffffccccccccdeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 162:fffdfcd077fdfcd0fffdfcd0ddddfed0cddcfed0cddcfed0ccccfed0ceecfed0
-- 163:0defdfff0defdf770defdfff0defdddd0defcddc0defcccc0defcccd0defcedf
-- 164:ffffffff77777777ffffffffddddddddcceddeccccccccccddcccccdffdeccee
-- 165:fffdfed077fdfed0fffdfed0ddddfed0cddcfed0ccccfed0ccccfed0ececfed0
-- 167:fdceeeeefdffeffefdf4d4f3fdffeffefdceeeee0fdcecec00fddddd000fffff
-- 168:eeecceffeeeeceefffffcfffeeeeeeeeeeeeffffeceefeecddcf4fcdffffffff
-- 169:fefffedfeeefeedfeeefecdfeeefeedfffffecdfeceecdf0dddddf00fffff000
-- 176:0defcddc0defceec0defceec0deefccc0defefff00deecee000ddddd00000000
-- 177:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeccccccccffffffffdddddddd00000000
-- 178:cddcfed0ceecfed0ceecfcd0cccfeed0fffeecd0eececd00ddddd00000000000
-- 179:0defcddf0defcedf0defcccd0deefccc0defefff00deecee000ddddd00000000
-- 180:ffddcdedffdecceeddcccccdcccccccccceeeeccffffffffdddddddd00000000
-- 181:eddcfed0ececfed0ccccfcd0cccfeed0fffeecd0eececd00ddddd00000000000
-- 192:00000000000ddddd00dfcfff0dccfddd0dcfdcef0dcfdef80dcfdcef0dcfdeee
-- 193:00000000ddddddddffffffffddddddddeeefeeeffef8fef5eeefeeefeeeeeeee
-- 194:00000000ddddd000fffccd00dddfccd0ecedfcd0fecdfcd0eeedfcd0eecdfcd0
-- 195:00000000000ddddd00dfefff0deefddd0defdc3f0defd3f80defd33f0defd333
-- 196:00000000ddddddddffffffffdddddddd333f333ff3f8f3f8333f333f33333333
-- 197:00000000ddddd000fffefd00dddfeed033edfed0f33dfed0333dfed0333dfed0
-- 199:000fffff00fdcfcd0fdcfff9fdc9f4f9fd999d99fd99f4f9fcc9fff9ffc99f99
-- 200:ffffffffddddddddfcf4fcf9ffcfcffd999f99f9ff4d4ffff999999ff999cc3f
-- 201:fffff000dc4cdf0099fecdf099ff9cdfd99f99df9d9d9cdf9d9499df9d9d9cdf
-- 203:000fffff00fdcfcd0fdcfff3fdc3f4f3fd333d33fd33f4f3fcc3fff3ffc33f33
-- 204:ffffffffddddddddfcf4fcf3ffcfcffd333f33f3ff4d4ffff333333ff333cc4f
-- 205:fffff000dc4cdf0033fecdf033ff3cdfd33f33df3d3d3cdf3d3433df3d3d3cdf
-- 208:0dcfdfff0dcfdf570dcfdfff0defdddd0defcddc0defcddc0defcccc0defceec
-- 209:ffffffff77777777ffffffffccccccccdeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 210:fffdfcd077fdfcd0fffdfcd0ddddfed0cddcfed0cddcfed0ccccfed0ceecfed0
-- 211:0defdfff0defdf550defdfff0defdddd0d4f34430d4f33330d4f333d0d4f3edf
-- 212:ffffffff55577777ffffffffdddddddd33e44e3333333333dd3333ddffdeedff
-- 213:fffdfed077fdfed0fffdfed0ddddfed03443f4d03333f4d0d333f4d0fde3f4d0
-- 215:fcffffccffc99999fcc9ddd9fd9dfffdfd9deeedfd9dfffdfd9deeedfd99ddd9
-- 216:c99c999f9c9c999f9c9c99ff9c9c9f7799c4cf67999c9f77999c9f77999c9f77
-- 217:d4df99df9d9f9cdffefffedf7f776fdf7f777fdf7f677fdf6f777fdf7f767fdf
-- 219:fcffffccffc33333fcc3ddd3fd3dfffdfd3deeedfd3dfffdfd3deeedfd33ddd3
-- 220:c33c333f3c3c333f3c3c33ff3c3c3f7733c4cf67333c3f77333c3f77333c3f77
-- 221:d4df33df3d3f3cdffefffedf7f776fdf7f777fdf7f677fdf6f777fdf7f767fdf
-- 224:0defcddc0defceec0defceec0deefccc0defefff00deecee000ddddd00000000
-- 225:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeccccccccffffffffdddddddd00000000
-- 226:cddcfed0ceecfed0ceecfcd0cccfeed0fffeecd0eececd00ddddd00000000000
-- 227:0d4feddf0d4f3edf0d4f333d0d44f3330d4f4fff00d44444000ddddd00000000
-- 228:ffddddffffdeedffdd3333dd3333333333444433ffffffffdddddddd00000000
-- 229:fddef4d0fde3f4d0d333f4d0333f44d0fff4f4d044444d00ddddd00000000000
-- 231:fdc99999fdff9ff9fdf4d4f3fdff9ff9fdc999990fdc9c9c00fddddd000fffff
-- 232:999cc9ff9999c99fffffcfff999999999999ffff9c99f99cddcf4fcdffffffff
-- 233:f9fff9df999f99df999f9cdf999f99dfffff9cdf9c99cdf0dddddf00fffff000
-- 235:fdc33333fdff3ff3fdf4d4f3fdff3ff3fdc333330fdc3c3c00fddddd000fffff
-- 236:333cc3ff3333c33fffffcfff333333333333ffff3c33f33cddcf4fcdffffffff
-- 237:f3fff3df333f33df333f3cdf333f33dfffff3cdf3c33cdf0dddddf00fffff000
-- </TILES1>

-- <SPRITES>
-- 000:ffffffffeeeeeeee4fcd4fcdfcd4fcd4fcd4fcd44fcd4fcdeeeeeeeeffffffff
-- 001:ffffffffeeeeeeeefcd4fcd4cd4fcd4fcd4fcd4ffcd4fcd4eeeeeeeeffffffff
-- 002:ffffffffeeeeeeeecd4fcd4fd4fcd4fcd4fcd4fccd4fcd4feeeeeeeeffffffff
-- 003:ffffffffeeeeeeeed4fcd4fc4fcd4fcd4fcd4fcdd4fcd4fceeeeeeeeffffffff
-- 004:00ffffff0feeeeeefeed4fcdfed4fcd4fed4fcd4fecd4fcdfefccfdefe4ff4ef
-- 005:00ffffff0feeeeeefecddcd4fefccf4ffe4ff44ffed44dd4fecddcdefefccfef
-- 006:00ffffff0feeeeeefeeddd4ffecdd4fcfefcc4fcfe4ff44ffed44ddefeddddef
-- 007:00ffffff0feeeeeefeedd4fcfedd4fcdfecd4fcdfefcf4fcfe4ff4defed44def
-- 008:00000011000001d10000111f111111f011111100000011100000f1d100000f11
-- 009:ff00000044f000000040000000f4444300f44434ff4000004400000000000000
-- 010:0004f00000004f00f0004f004fff4f00044444f00000444f0000043400000043
-- 011:0000000099000000009000000009999300f99939ff9000009900000000000000
-- 012:0009000000009000f00090009fff900009999900000099900000093900000093
-- 013:0000008a000008980000888fc88888f0c8888800000088800000f89800000f8a
-- 014:00000000000f000000fc00000fcffff00cccccc000cf0000000c000000000000
-- 015:00dddd00020000d0d020000dd002000dd000200dd000020d0d00002000dddd00
-- 016:3000000300000000000000000000000000000000000000000000000030000003
-- 017:cdeeeeeedd000000ee000000e00000000000000000000000000000000000efef
-- 018:eeeeeedc000000dd000000ee0000000e000000de000000dd00000edeefefefde
-- 019:00d000000fed0000effed00000d0000000d00000000000000000000000000000
-- 021:0002000000002000f00020002fff200002222200000022200000022200000022
-- 022:0000000000000000000000000000000000000000000000000000000020000000
-- 023:02f00f2002f00f20002ff2000002200000033000000220000002200000022000
-- 025:656002213450034265400124000000000000000099800bbd3490034b89400db4
-- 026:003000d003430cec003000d0000000000000000004330bcc03330ccc03340ccd
-- 027:1ff111f010ff10ff11f01f011111111111111111100111f11f0f1f0f10f110f0
-- 028:0000000004300980032408fd003300e800000000003300ed03240efe04300dd0
-- 029:000000000e0d00000eff00000de0000000000000000000000000000000000000
-- 031:0000000000300000034000003433333344444444040000000040000000000000
-- 032:3030303000000003300000000000000330000000000000033000000003030303
-- 033:000000000000000000000000e0000000e0000000ee000000dd000000cdeeeeee
-- 034:00000ede000000dd000000de0000000e0000000e000000ee000000ddeeeeeedc
-- 036:00000000d00cd00decccccce000dd000000ee000000110000001100000011000
-- 037:0000000200000000000000000000000000000000000000000000000000000000
-- 038:2200000022200000022200000023200000023000000000000000000000000000
-- 039:0002200000022000000220000002200000022000000220000002300000032000
-- 041:0b000000b0b000000b0000000000000000000000000000000000000000000000
-- 042:0ed00000c12c0000d22d00000dd0000000000000000000000000000000000000
-- 045:000fffff00fcdfee0fe43fcdfd43dfd4fc43cfd4fdc43fcdfcdcfeee0fffffff
-- 046:000fffff00fcdfee0fe21fcdfd21dfd2fc21cfd2fdc21fcdfcdcfeee0fffffff
-- 047:000fffff00fcdfee0fe9afcdfd9adfd9fc9acfd9fdc9afcdfcdcfeee0fffffff
-- 048:0000e0000000de00dddddde04eff4edeeff4effe4eff4ededddddde00000de00
-- 049:0000e0000000de00dddddde0eff4efdeff4eff4eeff4efdedddddde00000de00
-- 050:0000e0000000de00dddddde0ff4effdef4eff4eeff4effdedddddde00000de00
-- 051:0000e0000000de00dddddde0f4eff4de4eff4efef4eff4dedddddde00000de00
-- 052:0001100000011000000110000001100000011000000110000001100000011000
-- 056:3030303000000000300000000000000030000000000000003000000000000000
-- 057:3000000003000000000000000300000000000000030000000000000003000000
-- 064:3300003330000003000000000000000000000000000000003000000333000033
-- 068:0001100000011000000cd000000dc000000ce000000cd0000000000000000000
-- 072:3000000003030303000000000000000000000000000000000000000000000000
-- 073:0000000003000000000000000000000000000000000000000000000000000000
-- 080:2400000030000000000000000000000000000000000000000000000000000000
-- 082:0000000027272700727272702727272056567270656527205656727005652720
-- 083:0000000065656500565656506565656072725650272765607272565007276560
-- 085:bbb00000bd000000b0b00000000b000000000000000000000000000000000000
-- 087:000efffe000fccdf00f4dde00f4defd00f4dfed000f4dde0000fccf0000fccff
-- 096:5dd00000de000000d0d00000000d000000000000000000000000000000000000
-- 100:00b0000000b0000000bbb000b0bbb0000bbbb00000cc00000000000000000000
-- 101:000000000bb000000bbb0000bbbb0000bbbb00000cc000000000000000000000
-- 103:000fccff000fccf000f4dde00f4dfed00f4defd000f4dde0000fccdf000efffe
-- 106:00fddf0d0fc77cfc0c7657c00ce77ec00decced002ceec20200dd00200300300
-- 107:00fddf000fcee7f00dee76500deee7700cdccec0003ee2d0030d200d00020000
-- 108:000fff0002fecef020dc75ef0dccc7cf0dceccefcedccdf00cedd02000c00200
-- 109:00feef000feccef00dceecd0ecdccdce0d2dd2d002deed202003300200300300
-- 110:00300300200330022cdeedc202cddc20ecdccdc00dc77cd00f7557f000feef00
-- 112:ddeeeeeedce00000ee000000e0000000e0000000e0000000e0000000e0000000
-- 113:eeceecee000dd000000ee000000cc000000ee000000cc000000ee000000cc000
-- 114:eeeeeedd00000ecd000000ee0000000e0000000e0000000e0000000e0000000e
-- 118:000dddff00deedee0de4fdcdde4fedd4de4fedd4dee4fdcddeeddeeedddeffff
-- 119:000dddff00deedee0de4fdd4de4fed4fde4fed4fdee4fdd4deeddeeedddeffff
-- 120:000dddff00deedee0de4fd4fde4fedfcde4fedfcdee4fd4fdeeddeeedddeffff
-- 121:000dddff00deedee0de4fdfcde4fedcdde4fedcddee4fdfcdeeddeeedddeffff
-- 122:00000000000000000000000000ffff000ffffff00ffffff000ffff0000000000
-- 123:00000000000000000000000000ffff000ffffff00ffffff000ffff0000000000
-- 124:000000000000000000000000000ff00000ffff0000ffff00000ff00000000000
-- 125:00000000000000000000000000000000000ff00000ffff00000ff00000000000
-- 126:0000000000000000000000000000000000000000000ff0000000000000000000
-- 128:e0000000e0000000e00000d0e0000de0e000defde0000ff0e00000e0e0000000
-- 129:000ee000000cc000000ee000000cc000dddeeddd000cc000000ee000000cc000
-- 130:0000000e0000000e0e00000e0ff0000edfed000e0ed0000e0d00000e0000000e
-- 131:111111111111f441111143f411114f34111114411ff11441f44f1441f444f44f
-- 132:11111f441111f4414443441144434411111114411ff11144f44f1dff444fdeef
-- 133:4f1111111111111111111111111111111111111141111111df111111fdf11111
-- 134:111fffff11fddddd1fdcfffefdcef4fefdeeedeefdeef4fefdeefffefdeeecee
-- 135:ffffffffdcfcddddcfdfceecfcfcfeeeeeeeeeeeff4d4ffffeeeeddeceeedefd
-- 136:11111111f1111111df111111cdf11111edf11111fdf11111edf11111edf11111
-- 137:111111111111111111111111111111111111111111111111111111111111111d
-- 138:111111df11111dcd1111dccc111dccce11dcccee1dccceeddccceedfccceedf1
-- 139:11111111f1111111df111111edf11111df111111f11111111111111111111111
-- 140:111111111111111111111111111111111111111111111111111111111111111f
-- 141:11111111111111111111111f111111fd11111fdd1111fdddf11fdddddfedddde
-- 142:1fef1111fdfe1111dddf1111dde11111de111111e1111111e111111111111111
-- 144:e0000000e0000000e0000000e0000000e0000000ee000000dce00000ddeeeeee
-- 145:000ee000000dd000000ee00000dddd000dffffd00d4ff4d00df44fd0edffffde
-- 146:0000000e0000000e0000000e0000000e0000000e000000ee00000ecdeeeeeedd
-- 147:1f44433411f4f44f11f4f44f11f44ff4111f444d1111f4df1111f4df1111144d
-- 148:44fdeeee4fdffe444dffffeedeeffffeeeeefffffe4440ffffee40fffffe40ef
-- 149:ffdf111140fdf11140ffdf1140efdf11eeedf111fedf1111fdf11111df111111
-- 150:fdeeecccfdeeeeeefdeedddefdedfffdfdedeeedfdedfffdfdedeeedfdedfffd
-- 151:cceedfedeceeeddeeceeeeeeeceeeeefeccccccfeeeceeefeeeceeeee4fff4ee
-- 152:edf11111edf11111edf11111fdf111114df11111fdf11111edf11111edf11111
-- 153:1111111111111111111ed1e11edfddfd1efdeedf11dedfed1ddefded1efdeedf
-- 154:dceedf111dedf11111df134411116666e1113444d111666611113444e1116666
-- 155:1111111111111111446656116646651146644311646666116644431146666611
-- 156:111111fd1111111f1111111e111111ed11111edd1111fddd111feedd11edeeef
-- 157:fededde1ddedde11ddddedf1dddeddeeddedddddde11edddede11eedddd1111e
-- 158:11111111111111111111111111111111ee111111dde11111de111111e1111111
-- 163:11111fff11111111111111111111111111111111111111111111111111111111
-- 164:dfffeeedfdfffedf1fdffdf111fddf11111ff111111111111111111111111111
-- 165:1111111111111111111111111111111111111111111111111111111111111111
-- 166:fdceddde1fdceeee11fddddd111fffff11111111111111111111111111111111
-- 167:eeeeeeeeeeeeeeecddddddddffffffff11111111111111111111111111111111
-- 168:cdf11111df111111f11111111111111111111111111111111111111111111111
-- 169:11dfddfd111e1de1111111111111111111111111111111111111111111111111
-- 170:e111111611111116111111111111111111111111111111111111111111111111
-- 171:6444431166666511111111111111111111111111111111111111111111111111
-- 172:1edddef1edddddf1eddddf111eddf11111ed1111111111111111111111111111
-- 173:fddd11111fde1111111111111111111111111111111111111111111111111111
-- 174:1111111111111111111111111111111111111111111111111111111111111111
-- 179:eeeee000eecee000ecdce000edede000edede000eddde000eddde000eeeee000
-- 180:eeeee000eedee000edede000ecede000ecede000eddde000eddde000eeeee000
-- 192:000cf00000ddcf000cbdddf0cdddddcf0ddddcf000cddf00000cf00000000000
-- 193:0003f00000333f0003b333f03333333f033333f000333f000003f00000000000
-- 194:00df00000dcdf000dedcdf000dedcdf000dedcdf000dedf00000df0000000000
-- 195:0ffffff003334430034434400ffffff003334430043443400000000000000000
-- 196:0000000000bcdf000becebf00ccbccf00becebf000dcbf000000000000000000
-- 197:0003f00003003f003f303f003f303f003fff3f000333f0000000000000000000
-- 198:000000000c0d00000d0c00000d0d00000c0d00000c0c00000d0d000000000000
-- 199:000000000bd00000bbbd00000bbbd00000bbbd00000bbbd00000bd0000000000
-- 200:0666666734444466666664663444644466646666006444440066666600000000
-- 201:0222222134444422222224223444244422242222002444440022222200000000
-- 202:0999999834444499999994993444944499949999009444440099999900000000
-- 203:0bbbbbbd344444bbbbbbb4bb3444b444bbb4bbbb00b4444400bbbbbb00000000
-- 204:000dd000000ee000000cc00000d32d000d3222d00c2232c00d2222d000d33d00
-- 205:000dd000000ee000000cc00000d56d000d5666d00c6656c00d6666d000d77d00
-- 206:000dd000000ee000000dd00000dbbc000cbbbbc00dbbdbd00dbbbbd000cddc00
-- 207:000dd000000ee000000cc00000da9d000d8998d00c9999c00d99a9d000d89d00
-- 208:0000000033333333344444433444444333333333444444444443344444444444
-- 209:00000000dddddddddeeeeeeddeeeeeedddddddddceeeeeecceeddeeccccccccc
-- 210:dddddddddeeeeeeddeeeeeedddddddddfeeeeeeffeddddeffeeffeeffccccccf
-- 211:00dddd000dccccd0dccddccddcdecdcddcdcedcddccddccd0dccccd000dddd00
-- 212:ffffffffeeeeeeeef4dcf4dccf4dcf4dcf4dcf4df4dcf4dceeeeeeeeffffffff
-- 213:ffffffffeeeeeeeef2dcf2dccf2dcf2dcf2dcf2df2dcf2dceeeeeeeeffffffff
-- 214:ffffffffeeeeeeeef9dcf9dccf9dcf9dcf9dcf9df9dcf9dceeeeeeeeffffffff
-- 215:0ef110ef0ef110ef00effef0000ee0000f1ee100f11ee1101d1ec1d1110cef11
-- 216:04f1104f04f1104f004ff4f0000440000f144100f11441101d1431d111034f11
-- 217:02f1102f02f1102f002ff2f0000220000f122100f11221101d1231d111032f11
-- 218:09f8809f09f8809f009ff9f0000990000f899800f88998808d8938d888039f88
-- 219:010ff010010ff010001ff1000001100000f11f000ff11ff0fdf13fdfff0310ff
-- 220:0607706006077060006776000006600000766700077667707d7637d777036077
-- 221:0d0cc0d00d0cc0d000dccd00000dd00000cddc000ccddcc0cdcd3cdccc03d0cc
-- 222:0e0e0e0000dcd0000001000000010000000100000001000000010000000e0000
-- 223:e00cd00e0eedcee0000cd000000dc000000cd000000dc000000cd000000dc000
-- 224:c00ec00cccdffdcc00deed0000dcfd0000dfcd0000deed0000dcfd0000dfcd00
-- 225:d00dd00deddeedde000dd000000dd00000deed000deeeed00dceecd00deeeed0
-- 226:0007000000777000007570000757770007777700077777000077700000000000
-- 228:fffff000eefccf00dcf34df04dfc34df4dfc34dfdcf34dcfeeefcccffffffff0
-- 229:fffff000eefccf00dcf12df02dfc12df2dfc12dfdcf12dcfeeefcccffffffff0
-- 230:fffff000eefccf00dcfa9df09dfca9df9dfca9dfdcfa9dcfeeefcccffffffff0
-- 244:004ecd0004eeede0004ecde0000dcd00000dcd00004ecde004eeede0004ecd00
-- 245:002ecd0002eeede0002ecde0000dcd00000dcd00002ecde002eeede0002ecd00
-- 246:009ecd0009eeede0009ecde0000dcd00000dcd00009ecde009eeede0009ecd00
-- </SPRITES>

-- <SPRITES1>
-- 000:1118f11111bdde111ebdcce11bbddcce1ccdf1fffee88f1f1118f11111ff811c
-- 001:1111111111111111111ddde111dbdce11ee8881f1effff1111111111deef1111
-- 002:1ce11f118bdefdb18e1ff8f111f18111ed1beff1fc8ef8cf1ffcffbc111ffefe
-- 003:111111111edc1111f4434ef1c433322e2432233fe2f2332ff11f3322e11f2f31
-- 004:112222201333331cf3333423f33334f2d2222ff1e2ff3f1111e111f1111fc111
-- 005:1f11133cd33f23422232cf21f13211f111ff4431f44124311221ff121ff11111
-- 006:111111111100f11110fe00111000001f1f0001ec11111100111111ff1110f111
-- 007:11111111f0f00111ef0000e10d0000f1f00000f1000000f100000fe1fffffe11
-- 008:1f1fff01f00ef00010001f00ff0f1ef00f1f1111e0011f000001f00ef10000f1
-- 009:f0f1110f000110e0f0e1000f1ff1f011111f110ff00010e00e0f100ff0f1f0f1
-- 010:111111fc11111fcc1111fccd111fccdd11fcdddd1fcdddddfcddddddccdddddd
-- 011:cf111111ccf11111dccf1111ddccf111dddccf11ddddccf1dddddccfdddddccc
-- 012:111ff11111fcdf111fcdddf1fcdddddffdddddcf1fcddcf111fcdf11111ff111
-- 013:111111ec111111ce111111c6111111d5111111c6111111d611111d761111d566
-- 014:ce111111ec1111116d1111117c1111116d1111115d11111167d11111667c1111
-- 015:111dd111111ee111111cc11111d56d111d5666d11c6656c11d6666d111d77d11
-- 016:1bd811cbfedde1edfedee1c8f8c1ffe81ff1111f188f11111111111111111111
-- 017:beeece11bdcceee1beca81f1ef18f1f1ff1ee1f11118f11111188f1111111111
-- 019:11ffffff1111e1f11e334f11e23334f111f322ff1fff1f111ff111111f1eef11
-- 020:14443211343332e1244332f1ff4433211f2ff22fe1ff113111f1fff111111111
-- 021:c2111121342f331133f144f112c142f11f22f1111333f42ff321142f1d2f1f11
-- 022:1f00f0111fdff0111fef0f011ff0ff0110fff001100f00011100001111111111
-- 023:111111111111111111fe00f11f00d0011000000f10e0000f11000ff111111111
-- 024:f0f1f0f10e0f100ff00010e0111f110f1ff1f011f0e1000f000110e0f0f1110f
-- 025:f0111f0f0e011000f0001e0f110f1ff1f011f1110e01000ff001f0e01f0f1f0f
-- 026:eccdddddfeccdddd1fecccdd11fecccc111feecc1111feec11111fee111111fe
-- 027:ddddddccdddddddfddddddf1ddddcf11ccccf111cccf1111eef11111ef111111
-- 029:111d5656111d656611d6566511d6666511d66666111c76661111d76611111cdd
-- 030:6765d1116666fc1156666d1156666c1166666d116667d11167dd1111dd111111
-- 032:6666666667666666667667666676766666767666666666666666666666666666
-- 033:6666666666667666766776666767766767677676676776766666666666666666
-- 034:6666666666d666666d2d66d666d66d2d667666d6667666766666666666666666
-- 048:0000000090000000900000009000000009000000009990000000090000000cc0
-- 049:000000200000002000000200000002000000200000020000002000000cc00000
-- 051:0000000090000000900000009000000009000000009990000000090000000cc0
-- 052:000000200000002000000200000002000000200000020000002000000cc00000
-- 064:000cceec000ceeee0ffffffffeeeeeeefddddddd0fc23c4c00ffffff00f77777
-- 065:ceecc000eeeec000fffffff0eeeeeeefeddedddfecceccf0ffffff0077777f00
-- 067:000cceec000ceeee0ffffffffeeeeeeefddddddd0fc23c4c00ffffff00f27777
-- 068:ceecc000eeeec000fffffff0eeeeeeefeddedddfecceccf0ffffff00777c7f00
-- 080:00f7777700f7776700f7777700f7777700f7777700f7777700f7777700f77777
-- 081:77777f0077777f0077777f0077777f0077777f0077777f0077677f0077777f00
-- 083:00f7277700f7276600f7266600f7725600f7766d00f777d600f7766600f76666
-- 084:7777df00677cdf00667cef00567cdf0066ccef00dcc7cf006677ef007667cf00
-- 096:00f7777700f7777700f7776700f7777700f7777700f7777700f7777700f77777
-- 097:77777f0077777f0077777f0077777f0077777f0077777f0077777f0077777f00
-- 099:00f7656d00f7666d00f7767d00f7766600f7766600f77e6600f7e77700f7e777
-- 100:6667ef00666c7f0066e77f00d6777f00d6777f006d757f007d777f0077d77f00
-- 112:00f7777700ffffff0feefffffeefeeeeffffffff0feccccc0fcecece00ffffff
-- 113:77777f00ffffff00ffffeef0eeeefeefffffffffccccecf0cececef0ffffff00
-- 115:00fe777500ffffff0feefffffeefeeeeffffffff0feccccc0fcecece00ffffff
-- 116:777d7f00ffffff00ffffeef0eeeefeefffffffffccccecf0cececef0ffffff00
-- </SPRITES1>

-- <SPRITES2>
-- 000:111111111111441111143f441114f34411114411ff11441144f1441f444f44f4
-- 001:11111444111144ff44344f1144344f11111144fffff1144444f1dffd44fdeeff
-- 002:f111111111111111111111111111111111111111f1111111f1111111df111111
-- 003:11111111111ddddd11dde4ee1ddeedee1ddeedee1ddef4fe1ddefffe1ddee8ee
-- 004:11d11111fcfcfdddcfdfceedecfceeeeeeeffeeeff4d4ffffeeffdde8eeedefd
-- 005:11111111f1111111df111111ddf11111edf11111fdf11111edf11111edf11111
-- 006:1111111111111111111111111111111111111111111111111111111c111111ce
-- 007:11111cf11111cecf111ceeec11ceeedd1ceeeddcceeeddcfeeeddcf1eeddcf11
-- 008:1111111111111111f1111111cf111111f1111111111111111111111111111111
-- 009:11111111111111111111111111111111111111111111111111111f1111111dff
-- 010:111111111111111f111111fe1111ffed11fdeede1fdedeeefdedddefdedddddf
-- 011:fede1111edee1111deef1111eef11111ef111111f1111111fff11111deefff11
-- 012:111111111111111111111111111111111111111111111111111111111111111f
-- 013:11111111111111111111111f111111fd11111fdd1111fdddf11fdddddfedddde
-- 014:1fef1111fdfe1111dddf1111dde11111de111111e1111111e111111111111111
-- 016:f44433441f4f44f41f4f44f41f44ff4d11f444de111f4dff111f4dff111144df
-- 017:4fdeeeeffdffe444dffffee4eeffffe4eeeffffee4440ffffee40fffffe40efd
-- 018:fdf111110fdf11110ffdf1110efdf111eedf1111edf11111df111111f1111111
-- 019:1ddee8881ddeeeee1ddeeeee1dddddee1ddfffde1ddeeede1ddfffde1ddeeede
-- 020:88eedfede8eeeddee8eeeeeee8eeeeefe888888feee8eeefeee8eeeee4dfd4ee
-- 021:edf11111edf11111edf11111fdf111114df11111fdf11111edf11111ddf11111
-- 022:1111111c111111111111111111111111111e1fe111dfddfd1efdeedf1fdedfed
-- 023:eddcf111cdcf11111cf11111111116661111344411116666e111344411116666
-- 024:1111111111111111111111116666711144446711666466114464431164666611
-- 025:1111deef111deefe1111efdd1111feee1111fede111feeed1ffdddeefeddddde
-- 026:edddddfeeedddfddeeede1ffdeeefe11edef1f11edeeef11feeedef1efedeef1
-- 027:eddeeef1eeedddefddeeeeeffedddef11ffeef11111ff1111111111111111111
-- 028:111111fd1111111f1111111e111111ed11111edd1111fddd111feedd11edeeef
-- 029:fededde1ddedde11ddddedf1dddeddeeddedddddde11edddede11eedddd1111e
-- 030:11111111111111111111111111111111ee111111dde11111de111111e1111111
-- 032:1111fffd1111111f111111111111111111111111111111111111111111111111
-- 033:fffeeedfdfffedf1fdffdf111fddf11111ff1111111111111111111111111111
-- 034:1111111111111111111111111111111111111111111111111111111111111111
-- 035:1ddfffde1fdddddd11fddddd111fffff11111111111111111111111111111111
-- 036:eeeeeeedddddddddddddddddffffffff11111111111111111111111111111111
-- 037:ddf11111df111111f11111111111111111111111111111111111111111111111
-- 038:11defded1efdeedf11dfddfd111ef1e111111111111111111111111111111111
-- 039:f1113444e1116664111111641111116611111111111111111111111111111111
-- 040:6444431166666611444443116666661111111111111111111111111111111111
-- 041:edddddddfeeddddd1ffedddd111feddd1111fede11111fef111111f111111111
-- 042:f1feef11f11ff111f1111111f111111111111111111111111111111111111111
-- 043:1111111111111111111111111111111111111111111111111111111111111111
-- 044:1edddef1edddddf1eddddf111eddf11111ed1111111111111111111111111111
-- 045:fddd11111fde1111111111111111111111111111111111111111111111111111
-- 046:1111111111111111111111111111111111111111111111111111111111111111
-- 048:1111111111111111111111111111111d111111de11111dff1111dfff111deeff
-- 049:111111111dd11111dffd1111eeffd111eeeffd11e4440fd1fee40ffdffe40efd
-- 064:11deeeef1dffe4441dfffee411dfffe4111dfffe1111dfff11111dff111111dd
-- 065:fffeeeed0fffeed10ffffd110effd111eeed1111eed11111fd111111d1111111
-- </SPRITES2>

-- <SPRITES3>
-- 000:111111111111f441111143f411114f34111114411ff11441f44f1441f444f44f
-- 001:11111f441111f4414443441144434411111114411ff11144f44f1dff444fdeef
-- 002:4f1111111111111111111111111111111111111141111111df111111fdf11111
-- 003:11111111111ddddd11dde4ee1ddeedee1ddeedee1ddef4fe1ddefffe1ddee8ee
-- 004:11d11111fcfcfdddcfdfceedecfceeeeeeeffeeeff4d4ffffeeffdde8eeedefd
-- 005:11111111f1111111df111111ddf11111edf11111fdf11111edf11111edf11111
-- 006:111111111111111111111111111111111111111111111111111111111111111c
-- 007:111111cf11111cec1111ceee111ceeed11ceeedd1ceeeddcceeeddcfeeeddcf1
-- 008:11111111f1111111cf111111dcf11111cf111111f11111111111111111111111
-- 009:11111111111111111111111111111111111111111111111111111f1111111dff
-- 010:111111111111111f111111fe1111ffed11fdeede1fdedeeefdedddefdedddddf
-- 011:fede1111edee1111deef1111eef11111ef111111f1111111fff11111deefff11
-- 012:111111111111111111111111111111111111111111111111111111111111111f
-- 013:11111111111111111111111f111111fd11111fdd1111fdddf11fdddddfedddde
-- 014:1fef1111fdfe1111dddf1111dde11111de111111e1111111e111111111111111
-- 016:1f44433411f4f44f11f4f44f11f44ff4111f444d1111f4df1111f4df1111144d
-- 017:44fdeeee4fdffe444dffffeedeeffffeeeeefffffe4440ffffee40fffffe40ef
-- 018:ffdf111140fdf11140ffdf1140efdf11eeedf111fedf1111fdf11111df111111
-- 019:1ddee8881ddeeeee1ddeeeee1dddddee1ddfffde1ddeeede1ddfffde1ddeeede
-- 020:88eedfede8eeeddee8eeeeeee8eeeeefe888888feee8eeefeee8eeeee4dfd4ee
-- 021:edf11111edf11111edf11111fdf111114df11111fdf11111edf11111ddf11111
-- 022:1111111111111111111ed1e11edfddfd1efdeedf11dedfed1ddefded1efdeedf
-- 023:ceddcf111cdcf11111cf111111116666e1113444d111666611113444e1116664
-- 024:1111111111111111111111116664661144644311646666116444431166666611
-- 025:1111deef111deefe1111efdd1111feee1111fede111feeed1ffdddeefeddddde
-- 026:edddddfeeedddfddeeede1ffdeeefe11edef1f11edeeef11feeedef1efedeef1
-- 027:eddeeef1eeedddefddeeeeeffedddef11ffeef11111ff1111111111111111111
-- 028:111111fd1111111f1111111e111111ed11111edd1111fddd111feedd11edeeef
-- 029:fededde1ddedde11ddddedf1dddeddeeddedddddde11edddede11eedddd1111e
-- 030:11111111111111111111111111111111ee111111dde11111de111111e1111111
-- 032:11111fff11111111111111111111111111111111111111111111111111111111
-- 033:dfffeeedfdfffedf1fdffdf111fddf11111ff111111111111111111111111111
-- 034:f111111111111111111111111111111111111111111111111111111111111111
-- 035:1ddfffde1fdddddd11fddddd111fffff11111111111111111111111111111111
-- 036:eeeeeeedddddddddddddddddffffffff11111111111111111111111111111111
-- 037:ddf11111df111111f11111111111111111111111111111111111111111111111
-- 038:11dfddfd111e1de1111111111111111111111111111111111111111111111111
-- 039:e111116411111166111111111111111111111111111111111111111111111111
-- 040:4444431166666611111111111111111111111111111111111111111111111111
-- 041:edddddddfeeddddd1ffedddd111feddd1111fede11111fef111111f111111111
-- 042:f1feef11f11ff111f1111111f111111111111111111111111111111111111111
-- 043:1111111111111111111111111111111111111111111111111111111111111111
-- 044:1edddef1edddddf1eddddf111eddf11111ed1111111111111111111111111111
-- 045:fddd11111fde1111111111111111111111111111111111111111111111111111
-- 046:1111111111111111111111111111111111111111111111111111111111111111
-- 048:1111111111111111111111111111111d111111de11111dff1111dfff111deeff
-- 049:111111111dd11111dffd1111eeffd111eeeffd11e4440fd1fee40ffdffe40efd
-- 050:eeeee000eedee000edcde000ecece000ecece000eccce000eccce000eeeee000
-- 051:eeeee000eecee000ecece000edece000edece000eccce000eccce000eeeee000
-- 052:0303030330000000000000033000000000000003300000000000000330303030
-- 064:11deeeef1dffe4441dfffee411dfffe4111dfffe1111dfff11111dff111111dd
-- 065:fffeeeed0fffeed10ffffd110effd111eeed1111eed11111fd111111d1111111
-- 096:1111111111111111111111111111111111111111111111111111111c111111ce
-- 097:11111cf11111cecf111ceeec11ceeedd1ceeeddcceeeddcfeeeddcf1eeddcf11
-- 098:1111111111111111f1111111cf111111f1111111111111111111111111111111
-- 099:11111111111111111111111111111111111111111111111111111f1111111dff
-- 112:1111111c111111111111111111111111111e1fe111dfddfd1efdeedf1fdedfed
-- 113:eddcf111cdcf11111cf11111111116661111344411116666e111344411116666
-- 114:1111111111111111111111116666711144446711666466114464431164666611
-- 115:1111deef111deefe1111efdd1111feee1111fede111feeed1ffdddeefeddddde
-- 128:11defded1efdeedf11dfddfd111ef1e111111111111111111111111111111111
-- 129:f1113444e1116664111111641111116611111111111111111111111111111111
-- 130:6444431166666611444443116666661111111111111111111111111111111111
-- 131:edddddddfeeddddd1ffedddd111feddd1111fede11111fef111111f111111111
-- </SPRITES3>

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
-- 000:00101010101010101010000000000000101010101010100010101010101010101010101010101010101010101000101000000000001010101010101010101010000000001010101010101010101010100000000010101010101010101010101000000000101010101010101010101010101010101010101010101010101010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </FLAGS>

-- <PALETTE>
-- 000:1a1c2c5d245db13e53ef7d57ffcd75a7f07038b76404650029366f3b5dc941a6f6eaeaea919191b2b2b2656c79333434
-- </PALETTE>

-- <PALETTE1>
-- 000:1a1c2c5d245db13e53ef7d57ffcd75a7f07038b76404650029366f3b5dc941a6f673eff7919191aeaaae656c79333434
-- </PALETTE1>

-- <PALETTE2>
-- 000:1a1c2c5d245db13e53ef7d57ffcd75a7f07038b76404650029366f3b5dc941a6f673eff7919191aeaaae656c79333434
-- </PALETTE2>

-- <PALETTE3>
-- 000:1a1c2c5d245db13e53ef7d57ffcd75a7f07038b76404650029366f3b5dc941a6f673eff7919191aeaaae656c79333434
-- </PALETTE3>

