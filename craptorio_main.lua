-- title:   craptorio
-- author:  @ArchaicVirus
-- desc:    De-make of Factorio
-- site:    website link
-- license: MIT License
-- version: 0.3
-- script: --testne--test
new_underground_belt = require('\\classes\\underground_belt')
new_belt             = require('\\classes\\transport_belt')
new_splitter         = require('\\classes\\splitter')
new_inserter         = require('\\classes\\inserter')
ITEMS                = require('\\classes\\item_definitions')
DEFS                 = require('\\classes\\defs')
draw_cable           = require('\\classes\\cable')
new_pole             = require('\\classes\\power_pole')
make_inventory       = require('\\classes\\inventory')
new_drill            = require('\\classes\\mining_drill')
new_furnace          = require('\\classes\\furnace')
ui                   = require('\\classes\\ui')
recipies             = require('\\classes\\crafting_definitions')
simplex              = require('\\classes\\open_simplex_noise')
TileManager          = require('\\classes\\TileManager')

math.randomseed(tstamp())
--local seed = math.random(-1000000000, 1000000000)
local seed = 902404786
--math.randomseed(53264)
math.randomseed(seed)
offset = math.random(100000, 500000)
simplex.seed()
TileMan = TileManager:new()
floor = math.floor
sspr = spr
--image = require('\\assets\\fullscreen_images')
--------------------COUNTERS--------------------------
TICK = 0

-------------GAME-OBJECTS-AND-CONTAINERS---------------
ENTS = {}
ORES = {}
window = nil
window = nil
STATE = 'main'
CURSOR_POINTER = 341
CURSOR_HIGHLIGHT = 312
CURSOR_HIGHLIGHT_CORNER = 309
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
  left = false,
  last_left = false,
  middle = false,
  last_mid = false,
  right = false,
  last_right = false,
  rot = 0,
  last_rotation = 0,
  type = 'pointer',
  item = 'transport_belt',
  drag = false,
  panel_drag = false,
  drag_dir = 0,
  drag_loc = {x = 0, y = 0},
  hand_item = {id = 0, count = 0},
  drag_offset = {x = 0, y = 0},
  item_stack = {id = 5, count = 100}
}
player = {
  x = 37, y = 288,
  spr = 362,
  lx = 0, ly = 0,
  shadow = 382,
  anim_frame = 0, anim_speed = 8, anim_dir = 0, anim_max = 4,
  last_dir = '0,0', move_speed = 3,
  directions = {
    ['0,0'] = {id = 362, flip = 0, rot = 0},  --straight
    ['0,-1'] = {id = 365, flip = 0, rot = 0},  --up
    ['0,1'] = {id = 365, flip = 2, rot = 0},  --down
    ['-1,0'] = {id = 363, flip = 1, rot = 0},  --left
    ['1,0'] = {id = 363, flip = 0, rot = 0},  --right
    ['1,-1'] = {id = 364, flip = 0, rot = 0},  --up-right
    ['-1,-1'] = {id = 364, flip = 1, rot = 0},  --up-left
    ['-1,1'] = {id = 364, flip = 3, rot = 0},  --down-left
    ['1,1'] = {id = 364, flip = 2, rot = 0}   --down-right
  },
}

inv = make_inventory()
inv.slots[91].item_id = 9
inv.slots[92].item_id = 10
inv.slots[93].item_id = 11
inv.slots[94].item_id = 12
inv.slots[95].item_id = 13
inv.slots[96].item_id = 14
inv.slots[97].item_id = 18
craft_menu = ui.NewCraftPanel(135, 1)
vis_ents = {}
show_mini_map = false
debug = false
last_num_ents = 0
local TILE_SIZE = 8
local VIEWPORT_WIDTH = 240
local VIEWPORT_HEIGHT = 136
local MAP_WIDTH = 240 * TILE_SIZE
local MAP_HEIGHT = 136 * TILE_SIZE
local GRID_CELL_SIZE = math.ceil(VIEWPORT_WIDTH / TILE_SIZE)
--------------------FUNCTIONS-------------------------
local dust = {}
function move(o)
  o.x =o.x+o.vx
  o.y =o.y+o.vy
 end

function particles()

  for i,d in pairs(dust) do
    move(d)
    d.vx, d.vy = d.vx * 1.015, d.vy * 1.015    
    --if (d.t//1)%5==0 and d.c>3 then d.c=d.c-1 end    
    if d.t < 5 then d.r = d.r/1.1 d.c = d.c - (d.c > 3 and 1 or 0) end
    d.t = d.t - 1 + math.random()
    if d.r < 1 then	table.remove(dust, i) end
  end  
end

function new_dust(x_, y_, r_, vx_, vy_)
for i = 0, 1 do
  table.insert(dust, {
      x = x_,
      y = y_,
      c = 4,
      ty = math.random(-1, 1),
      -- vx = math.cos(math.random(30)) /8,
      -- vy = math.sin(math.rad(math.random(180)))*(math.random()*2)/8,
      vx = vx_,
      vy = vy_,
      r = math.random() * r_,
      t = 5 * r_})
  end
end


function get_visible_ents()
  vis_ents = {['transport_belt'] = {}, ['inserter'] = {}, ['power_pole'] = {}, ['splitter'] = {}, ['mining_drill'] = {}, ['stone_furnace'] = {}, ['underground_belt'] = {}, ['underground_belt_exit'] = {}}
  for x = 1, 31 do
    for y = 1, 18 do
      local worldX = (x*8) + (player.x - 116)
      local worldY = (y*8) + (player.y - 64)
      local cellX = floor(worldX / 8)
      local cellY = floor(worldY / 8)
      local key = cellX .. '-' .. cellY
      if ENTS[key] and ENTS[key].type ~= 'dummy_splitter' and ENTS[key].type ~= 'dummy_drill' and ENTS[key].type ~= 'dummy_furnace' then
        local type = ENTS[key].type
        local index = #vis_ents[type] + 1
        --vis_ents[type][key] = ENTS[key]
        vis_ents[type][index] = key
      end
    end
  end
end

-- function get_ent(x, y, world)
--   local key = x .. '-' .. y
--   if not world then
--     key = get_key(x, y)
--   end
--   return ENTS[key]
-- end

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

function screen_to_world(screen_x, screen_y)
  local cam_x = player.x - 116
  local cam_y = player.y - 64
  local sub_tile_x = cam_x % 8
  local sub_tile_y = cam_y % 8
  local sx = floor((screen_x + sub_tile_x) / 8)
  local sy = floor((screen_y + sub_tile_y) / 8)
  local wx = floor(cam_x / 8) + sx + 1
  local wy = floor(cam_y / 8) + sy + 1
  return wx, wy
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

function lerp(a,b,mu)
  return a*(1-mu)+b*mu
end
--------------------------------------------------------------------------------------

function spawn_player()
  local tile = get_world_cell(116, 76)
  if not tile.is_land then
    while tile.is_land == false do
      player.x = player.x + 1
      tile = get_world_cell(116, 76)
    end
  end
end

function remap(n, a, b, c, d)
  return c + (n - a) * (d - c) / (b - a)
end

function is_water(x, y)
  local tile = get_world_cell(x, y)
  if not tile.is_land then
    sfx(5, 'C-3', 22, 0, 15, 4)
    return true
  end
  return false
end

function new_item_stack(id, count)
  return{
    id = id,
    count = count,
    name = ITEMS[id].name
  }
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

function add_underground_belt(x, y)
  local tile, wx, wy = get_world_cell(x, y)
  local key = wx .. '-' .. wy
  if not ENTS[key] then
    local result, other_key, cells = get_ubelt_connection(x, y, cursor.rot)
    if result then trace('add_underground_belt with ' .. #cells .. ' cells') end
    --if cursor.rot == 0 then 
      --going IN left
      if result then
        --found suitable connection
        --don't create a new ENT, use the found ubelt as the 'host', and update it with US as it's output
        ENTS[key] = {type = 'underground_belt_exit', flip = UBELT_ROT_MAP[cursor.rot].out_flip, rot = cursor.rot, x = wx, y = wy, other_key = other_key}
        ENTS[other_key]:connect(wx, wy, #cells - 1)
      else
        ENTS[key] = new_underground_belt(wx, wy, cursor.rot)
      end

    end
end

function remove_underground_belt(x, y)
  local key = get_key(x, y)
  if ENTS[key] then
    --return underground items if any
    --remove hidden belts, since we removed the head
    ENTS[ENTS[key].other_key] = nil
    ENTS[key] = nil
  end
end

function add_belt(x, y, rotation)
  local tile, cell_x, cell_y = get_world_cell(x, y)
  local key = cell_x .. '-' .. cell_y
  local belt = {}
  if ENTS[key] and ENTS[key].type ~= 'transport_belt' then return end
  if not ENTS[key] or ENTS[key].type == 'ground-items' then
    sfx(4, 'B-3', 10, 0, 15, 4)
    belt = new_belt({x = cell_x, y = cell_y}, cursor.rot)
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
  if ENTS[key] and ENTS[key].type == 'transport_belt' then
    ENTS[key]:set_curved()
  end
end

function remove_belt(x, y)
  local key = get_key(x, y)
  local tile, cell_x, cell_y = get_world_cell(x, y)
  if not ENTS[key] then return end
  if ENTS[key] and ENTS[key].type == 'transport_belt' then
    sfx(2, 'C-3', 4, 0, 15, 5)
    ENTS[key] = nil
  end
  local tiles = {
    [1] = {x = cell_x, y = cell_y - 1},
    [2] = {x = cell_x + 1, y = cell_y},
    [3] = {x = cell_x, y = cell_y + 1},
    [4] = {x = cell_x - 1, y = cell_y}}
  for i = 1, 4 do
    local k = tiles[i].x .. '-' .. tiles[i].y
    if ENTS[k] and ENTS[k].type == 'transport_belt' then
      ENTS[k]:set_curved()
    end
  end
end

function add_splitter(x, y)
  local child = SPLITTER_ROTATION_MAP[cursor.rot]
  local tile, wx, wy = get_world_cell(x, y)
  wx, wy = wx + child.x, wy + child.y
  local tile2, cell_x, cell_y = get_world_cell(x, y)
  local key = get_key(x, y)
  local key2 = wx .. '-' .. wy
  if not ENTS[key] and not ENTS[key2] then
    local splitr = new_splitter(cell_x, cell_y, cursor.rot)
    splitr.other_key = key2
    ENTS[key] = splitr
    ENTS[key2] = {type = 'dummy_splitter', other_key = key, rot = cursor.rot}
    ENTS[key]:set_output()
  end
end

function remove_splitter(x, y)
  local key = get_key(x, y)
  if not ENTS[key] then return end
  if ENTS[key] and (ENTS[key].type == 'splitter' or ENTS[key].type == 'dummy_splitter') then
    if ENTS[key].type == 'dummy_splitter' then key = ENTS[key].other_key end
    local key_l, key_r = ENTS[key].output_key_l, ENTS[key].output_key_r
    local key2 = ENTS[key].other_key
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

function add_drill(x, y)
  local key = get_key(x, y)
  local found_ores = {}
  local field_keys = {}
  --local sx, sy = get_screen_cell(x, y)
  for i = 1, 4 do
    local pos = DRILL_AREA_MAP_BURNER[i]
    local sx, sy = cursor.tile_x + (pos.x * 8), cursor.tile_y + (pos.y * 8)
    local tile, wx, wy = get_world_cell(sx, sy)
    local k = get_key(sx, sy)
    field_keys[i] = k
    if tile.ore then
      table.insert(found_ores, i)

      if not ORES[k] then
        local ore = {
          type = ores[tile.ore].name,
          tile_id = ores[tile.ore].tile_id,
          sprite_id = ores[tile.ore].sprite_id,
          id = ores[tile.ore].id,
          ore_remaining = 100,
          wx = wx,
          wy = wy,
        }
        ORES[k] = ore
      end
    end
    if ENTS[k] or (i == 4 and #found_ores == 0) then
      sfx(5, 'C-3', 22, 0, 15, 4)
      return
    end
  end

  if not ENTS[key] then
    local tile, wx, wy = get_world_cell(x, y)
    sfx(4, 'B-3', 10, 0, 15, 4)
    --trace('creating drill @ ' .. key)
    ENTS[key] = new_drill({x = wx, y = wy}, cursor.rot, field_keys)
    ENTS[wx + 1 .. '-' .. wy] = {type = 'dummy_drill', other_key = key}
    ENTS[wx + 1 .. '-' .. wy + 1] = {type = 'dummy_drill', other_key = key}
    ENTS[wx .. '-' .. wy + 1] = {type = 'dummy_drill', other_key = key}
  elseif ENTS[key] and ENTS[key].type == 'mining_drill' then
    sfx(4, 'B-3', 10, 0, 15, 4)
    sfx(3, 'E-5', 10, 0, 15, 3)
    --ENTS[key].rot = cursor.rot
  end
end

function remove_drill(x, y)
  local key = get_key(x, y)
  local _, wx, wy = get_world_cell(x, y)
  local _, wx, wy = get_world_cell(x, y)
  if ENTS[key].type == 'dummy_drill' then
    key = ENTS[key].other_key
  end
  local wx, wy = ENTS[key].pos.x, ENTS[key].pos.y
  if ENTS[key] then ENTS[key] = nil end
  if ENTS[wx + 1 .. '-' .. wy] then ENTS[wx + 1 .. '-' .. wy] = nil end
  if ENTS[wx + 1 .. '-' .. wy + 1] then ENTS[wx + 1 .. '-' .. wy + 1] = nil end
  if ENTS[wx .. '-' .. wy + 1] then ENTS[wx .. '-' .. wy + 1] = nil end
end

function add_furnace(x, y)
  local key1 = get_key(x, y)
  local key2 = get_key(x + 8, y)
  local key3 = get_key(x + 8, y + 8)
  local key4 = get_key(x, y + 8)
  if not ENTS[key1] and not ENTS[key2] and not ENTS[key3] and not ENTS[key4] then
    local wx, wy = screen_to_world(x, y)
    ENTS[key1] = new_furnace(wx, wy, {key2, key3, key4})
    ENTS[key2] = {type = 'dummy_furnace', other_key = key1}
    ENTS[key3] = {type = 'dummy_furnace', other_key = key1}
    ENTS[key4] = {type = 'dummy_furnace', other_key = key1}
  end
end

function remove_furnace(x, y)
  local key = get_key(x, y)
  if ENTS[key].type == 'dummy_furnace' then
    key = ENTS[key].other_key
  end
  for k, v in ipairs(ENTS[key].dummy_keys) do
    if ENTS[v] then ENTS[v] = nil end
  end
    ENTS[key] = nil
end

function remove_furnace(x, y)
  local key = get_key(x, y)
  if ENTS[key].type == 'dummy_furnace' then
    key = ENTS[key].other_key
  end
  for k, v in ipairs(ENTS[key].dummy_keys) do
    if ENTS[v] then ENTS[v] = nil end
  end
    ENTS[key] = nil
end

function move_player(x, y)
  local tile, wx, wy = get_world_cell(116 + x, 76 + y)
  local sx, sy = world_to_screen(wx, wy)
  --sspr(349, 116 + x, 77 + y, 0)
  --if tile.is_land then player.x, player.y = player.x + x, player.y + y end
  player.x, player.y = player.x + x, player.y + y
  -- local tile_nw = TileMan.tiles[y][x]
  -- local tile_ne = TileMan.tiles[y][x+1]
  -- local tile_se = TileMan.tiles[y+1][x+1]
  -- local tile_sw = TileMan.tiles[y+1][x]
  -- -- local info = {
  -- --   [1] = 'tile_nw:' .. tostring(tile_nw),
  -- --   [2] = 'tile_ne:' .. tostring(tile_ne),
  -- --   [3] = 'tile_se:' .. tostring(tile_se),
  -- --   [4] = 'tile_sw:' .. tostring(tile_sw),
  -- -- }
  -- --draw_debug2(info, 10)
  -- if tile_nw.is_land and tile_ne.is_land and tile_se.is_land and tile_sw.is_land then
  --   player.lx, player.ly = player.x, player.y
  --   player.x, player.y = x, y
  -- end
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
  if x_dir ~= 0 or y_dir ~= 0 then
    new_dust(120 + (-x_dir * 4), 76 + player.anim_frame + (-y_dir*4), 2, (math.random(-1, 1)/2) + (1.75 * -x_dir), (math.random(1, 1)/2) + (1.75 * -y_dir))
  elseif TICK % 24 == 0 then
    new_dust(120, 76 + player.anim_frame, 2, (math.random(-1, 1)/2) + (0.75 * -x_dir), (math.random(1, 1)/2) + (0.75 * -y_dir))
  end
  move_player(x_dir * player.move_speed, y_dir * player.move_speed)
  player.last_dir = x_dir .. ',' .. y_dir
end

function draw_player()
  local sprite = player.directions[player.last_dir] or player.directions['0,0']
  sspr(player.shadow - player.anim_frame, 116, 76, 0)
  sspr(sprite.id, 116, 64 + player.anim_frame, 0, 1, sprite.flip)
end

function cycle_hotbar(dir)
  --cursor_item = cursor_item + dir
  inv.active_slot = inv.active_slot + dir
  if inv.active_slot < 1 then inv.active_slot = 10 end
  if inv.active_slot > 10 then inv.active_slot = 1 end
  set_active_slot(inv.active_slot)
  --local id = inv.slots[90 + inv.active_slot].item_id
  -- if id ~= 0 then
  --   cursor.item_stack = {id = id, count = inv.slots[90 + inv.active_slot].count}
  --   local name = ITEMS[id].name
  --   cursor.item = name
  -- else
  --   cursor.item = 'pointer'
  --   cursor.item_stack = {id = 0, count = 0}
  -- end
  -- if cursor_item < 0 then cursor_item = 4 end
  -- if cursor_item > 4 then cursor_item = 0 end
  -- cursor.item = cursor_items[cursor_item]
end

function set_active_slot(slot)
  --cursor.type = 'item'
  inv.active_slot = slot
  local id = inv.slots[90 + slot].item_id
  if id ~= 0 then
    cursor.item = ITEMS[id].name
    cursor.item_stack = {id = id, count = inv.slots[90 + slot].count}
    cursor.type = 'item'
  else
    cursor.item = 'pointer'
    cursor.type = 'pointer'
    cursor.item_stack = {id = 0, count = 0}
  end
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
    -- elseif cursor.item_stack.id ~= 0 then
    --   local sprite_id = ITEMS[cursor.item_stack.id].sprite_id
    --   sspr(312, cursor.tile_x - 1, cursor.tile_y - 1, 0, 1, 0, 0, 2, 2)
    --   sspr(sprite_id, cursor.tile_x, cursor.tile_y, 0)
    -- elseif cursor.type == 'pointer' then
    --   sspr(CURSOR_POINTER, cursor.x, cursor.y, 0)
    -- elseif cursor.item_stack.id ~= 0 then
    --   local sprite_id = ITEMS[cursor.item_stack.id].sprite_id
    --   sspr(312, cursor.tile_x - 1, cursor.tile_y - 1, 0, 1, 0, 0, 2, 2)
    --   sspr(sprite_id, cursor.tile_x, cursor.tile_y, 0)
    -- elseif cursor.type == 'pointer' then
    --   sspr(CURSOR_POINTER, cursor.x, cursor.y, 0)
  else
    --sspr(CURSOR_HIGHLIGHT, cursor.tile_x - 1, cursor.tile_y - 1, 0, 1, 0, 0, 2, 2)
  end

  if cursor.type == 'item' and cursor.item == 'transport_belt' then
    if cursor.drag then
      local sx, sy = world_to_screen(cursor.drag_loc.x, cursor.drag_loc.y)
      if cursor.drag_dir == 0 or cursor.drag_dir == 2 then
        sspr(CURSOR_HIGHLIGHT, cursor.tile_x - 1, sy - 1, 0, 1, 0, 0, 2, 2)
      else
        sspr(CURSOR_HIGHLIGHT, sx - 1, cursor.tile_y - 1, 0, 1, 0, 0, 2, 2)
      end
      --arrow to indicate drag direction
      sspr(287, cursor.tile_x, cursor.tile_y, 0, 1, 0, cursor.drag_dir, 1, 1)
    elseif not ENTS[key] or (ENTS[key] and ENTS[key].type == 'transport_belt' and ENTS[key].rot ~= cursor.rot) then
      sspr(BELT_ID_STRAIGHT + BELT_TICK, cursor.tile_x, cursor.tile_y, 00, 1, 0, cursor.rot, 1, 1)
      sspr(CURSOR_HIGHLIGHT, cursor.tile_x - 1, cursor.tile_y - 1, 0, 1, 0, 0, 2, 2)
    else
      sspr(CURSOR_HIGHLIGHT, cursor.tile_x - 1, cursor.tile_y - 1, 0, 1, 0, 0, 2, 2)
    end
  elseif cursor.type == 'item' and cursor.item == 'inserter' then
    if not ENTS[key] or (ENTS[key] and ENTS[key].type == 'inserter' and ENTS[key].rot ~= cursor.rot) then
      local tile, world_x, world_y = get_world_cell(cursor.tile_x, cursor.tile_y)
      local temp_inserter = new_inserter({x = world_x, y = world_y}, cursor.rot)
      sspr(CURSOR_HIGHLIGHT, cursor.tile_x - 1, cursor.tile_y - 1, 0, 1, 0, 0, 2, 2)
      temp_inserter:draw()
    end
    sspr(CURSOR_HIGHLIGHT, cursor.tile_x - 1, cursor.tile_y - 1, 0, 1, 0, 0, 2, 2)
  elseif cursor.type == 'item' and cursor.item == 'power_pole' then
    local tile, world_x, world_y = get_world_cell(cursor.tile_x, cursor.tile_y)
    local temp_pole = new_pole({x = world_x, y = world_y})
    temp_pole:draw(true)
    --check around cursor to attach temp cables to other poles
  elseif cursor.type == 'pointer' then
    local key = get_key(cursor.x, cursor.y)
    if window and window:is_hovered(cursor.x, cursor.y) then
      
    end
    if ENTS[key] then
      -- local ent = ENTS[key].type
      -- if ent == 'dummy_splitter' or ent == 'dummy_drill' or ent == 'dummy_furnace' then
      --   key = ENTS[key].other_key
      -- end
      -- ENTS[key]:draw_hover_widget()
    end
    local key = get_key(cursor.x, cursor.y)
    if window and window:is_hovered(cursor.x, cursor.y) then
      
    end
    if ENTS[key] then
      -- local ent = ENTS[key].type
      -- if ent == 'dummy_splitter' or ent == 'dummy_drill' or ent == 'dummy_furnace' then
      --   key = ENTS[key].other_key
      -- end
      -- ENTS[key]:draw_hover_widget()
    end
    sspr(CURSOR_POINTER, cursor.x, cursor.y, 0, 1, 0, 0, 1, 1)
    sspr(CURSOR_HIGHLIGHT, cursor.tile_x - 1, cursor.tile_y - 1, 0, 1, 0, 0, 2, 2)
    pix(cursor.x, cursor.y, 2)
  elseif cursor.type == 'item' and cursor.item == 'splitter' then
    local loc = SPLITTER_ROTATION_MAP[cursor.rot]
    --sspr(CURSOR_HIGHLIGHT, cursor.tile_x - 1, cursor.tile_y - 1, 0, 1, 0, 0, 2, 2)
    sspr(CURSOR_HIGHLIGHT, cursor.tile_x - 1 + (loc.x * 8), cursor.tile_y - 1 + (loc.y * 8), 0, 1, 0, 0, 2, 2)
    sspr(SPLITTER_ID, cursor.tile_x, cursor.tile_y, 0, 1, 0, cursor.rot, 1, 2)
  elseif cursor.type == 'item' and cursor.item == 'mining_drill' then

    local found_ores = {}
    --local _, wx, wy = get_world_cell(cursor.x, cursor.y)
    --local temp_drill = new_drill({x = wx, y = wy}, cursor.rot, {})
    local color_keys = {[1] = {0, 2}, [2] = {0, 2}, [3] = {0, 2}, [4] = {0, 2}}
    for i = 1, 4 do
      local pos = DRILL_AREA_MAP_BURNER[i]
      local key = get_key(cursor.tile_x + (pos.x * 8), cursor.tile_y + (pos.y * 8))
      local sx, sy = cursor.tile_x + (pos.x * 8), cursor.tile_y + (pos.y * 8)
      local tile, wx, wy = get_world_cell(sx, sy)
      --table.insert(found_ores, tile)
      if not tile.ore or ENTS[key] then
        color_keys[i] = {0, 5}
      end
    end
    sspr(CURSOR_HIGHLIGHT_CORNER, cursor.tile_x - 1, cursor.tile_y - 1, color_keys[1], 1, 0, 0, 1, 1)
    sspr(CURSOR_HIGHLIGHT_CORNER, cursor.tile_x + 9, cursor.tile_y - 1, color_keys[2], 1, 0, 1, 1, 1)
    sspr(CURSOR_HIGHLIGHT_CORNER, cursor.tile_x + 9, cursor.tile_y + 9, color_keys[3], 1, 0, 2, 1, 1)
    sspr(CURSOR_HIGHLIGHT_CORNER, cursor.tile_x - 1, cursor.tile_y + 9, color_keys[4], 1, 0, 3, 1, 1)
    --temp_drill:draw()
    local sx, sy = get_screen_cell(x, y)
    local belt_pos = DRILL_MINI_BELT_MAP[cursor.rot]
    --trace(TICK % 2)
    --sspr(DRILL_BURNER_SPRITE_ID + (DRILL_ANIM_TICK * 2), sx, sy, 0, 1, 0, self.rot, 2, 2)
    sspr(DRILL_BIT_ID, sx + 0 + (DRILL_BIT_TICK), sy + 7, 0, 1, 0, 0, 1, 1)
    sspr(DRILL_BURNER_SPRITE_ID, sx, sy, 0, 1, 0, 0, 2, 2)
    sspr(DRILL_MINI_BELT_ID + DRILL_ANIM_TICK, sx + belt_pos.x, sy + belt_pos.y, 0, 1, 0, cursor.rot, 1, 1)
    --sspr(DRILL_BURNER_SPRITE_ID, cursor.tile_x, cursor.tile_y, 0, 1, 0, cursor.rot, 2, 2)
  elseif cursor.type == 'item' and cursor.item == 'stone_furnace' then
    local sx, sy = get_screen_cell(x, y)
    sspr(FURNACE_SPRITE_INACTIVE_ID, sx, sy, 0, 1, 0, 0, 2, 2)
  elseif cursor.type == 'item' and cursor.item == 'underground_belt' then
    local flip = UBELT_ROT_MAP[cursor.rot].in_flip
    local result, other_key, cells = get_ubelt_connection(cursor.x, cursor.y, cursor.rot)
    if result then
      local sx, sy = world_to_screen(ENTS[other_key].x, ENTS[other_key].y)
      sspr(UBELT_OUT + UBELT_TICK, cursor.tile_x, cursor.tile_y, 0, 1, UBELT_ROT_MAP[cursor.rot].out_flip, cursor.rot)
      sspr(CURSOR_HIGHLIGHT, sx - 1, sy - 1, 0, 1, 0, 0, 2, 2)
      for i, cell in ipairs(cells) do
        sspr(CURSOR_HIGHLIGHT, cell.x - 1, cell.y - 1, 0, 1, 0, 0, 2, 2)
      end
    else
      sspr(UBELT_IN + UBELT_TICK, cursor.tile_x, cursor.tile_y, 0, 1, flip, cursor.rot)
    end
    sspr(CURSOR_HIGHLIGHT, cursor.tile_x - 1, cursor.tile_y - 1, 0, 1, 0, 0, 2, 2)
  end
end

function rotate_cursor()
  --sfx(3, 'E-5', 10, 0, 15, 3)
  if not cursor.drag then
    cursor.rot = cursor.rot + 1
    if cursor.rot > 3 then cursor.rot = 0 end
    local key = get_key(cursor.x, cursor.y)
    local tile, cell_x, cell_y = get_world_cell(cursor.x, cursor.y)
    if ENTS[key] then
      if ENTS[key].type == 'transport_belt' and cursor.item == 'pointer' then
        sfx(3, 'E-5', 10, 0, 15, 3)
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
        sfx(3, 'E-5', 10, 0, 15, 3)
        ENTS[key]:rotate(ENTS[key].rot + 1)
      end
    end
  end
  if cursor.drag then
    sfx(3, 'E-5', 10, 0, 15, 3)
    cursor.rot = cursor.rot + 1
    if cursor.rot > 3 then cursor.rot = 0 end
    --trace('rotated while dragging')
    local tile, wx, wy
    local dx, dy = world_to_screen(cursor.drag_loc.x, cursor.drag_loc.y)
    if (cursor.drag_dir == 0 or cursor.drag_dir == 2) then
      tile, wx, wy = get_world_cell(cursor.x, dy)
    elseif (cursor.drag_dir == 1 or cursor.drag_dir == 3) then
      tile, wx, wy = get_world_cell(dx, cursor.y)
    end
    -- cursor.rot = cursor.rot + 1
    -- if cursor.rot > 3 then cursor.rot = 0 end
    --cursor.drag_offset = 
    cursor.drag_loc = {x = wx, y = wy}
    cursor.drag_dir = cursor.rot
  end
  if cursor.type == 'item' then sfx(3, 'E-5', 10, 0, 15, 3) end
end

function place_tile(x, y, rotation)
  local tile = get_world_cell(x, y)
  if not tile.is_land then
    sfx(5, 'C-3', 22, 0, 15, 4)
    return
  end
  
  --trace('placing belt')
  --rotation = rotation or cursor.rot
  if cursor.item == 'transport_belt' then
    add_belt(x, y, cursor.rot)
  elseif cursor.item == 'inserter' then
    add_inserter({x = x, y = y}, rotation)
  elseif cursor.item == 'power_pole' then
    add_pole(x, y)
  elseif cursor.item == 'splitter' then
    add_splitter(x, y)
  -- elseif cursor.item == 'mining_drill' then
  --   add_drill(x, y)
  end
end

function remove_tile(x, y)
  local tile, wx, wy = get_world_cell(x, y)
  local ent = ENTS[wx .. '-'.. wy]
  if ent then
    if ent.type == 'transport_belt' then
      remove_belt(x, y)
    elseif ent.type == 'inserter' then
      remove_inserter(x, y)
    elseif ent.type == 'power_pole' then
      remove_pole(x, y)
    elseif ent.type == 'splitter' or ent.type == 'dummy_splitter' then
      remove_splitter(x, y)
    elseif ent.type == 'mining_drill' or ent.type == 'dummy_drill' then
      remove_drill(x, y)
    elseif ent.type == 'stone_furnace' or ent.type == 'dummy_furnace' then
      remove_furnace(x, y)
    elseif ent.type == 'stone_furnace' or ent.type == 'dummy_furnace' then
      remove_furnace(x, y)
    elseif ent.type == 'underground_belt' then
      remove_underground_belt(x, y)
    end
  elseif not tile.ore then
    TileMan:set_tile(wx, wy)
  end
end

function pipette()
  if cursor.type == 'pointer' then
    local key = get_key(cursor.x, cursor.y)
    if ENTS[key] then
      if ENTS[key].type == 'dummy_splitter' or ENTS[key].type == 'dummy_drill' or ENTS[key].type == 'dummy_furnace' then
        key = ENTS[key].other_key
      end
      cursor.type = 'item'
      cursor.item = ENTS[key].type
      cursor.item_stack = {id = ENTS[key].item_id, count = 0}
      if ENTS[key].rot then
        cursor.rot = ENTS[key].rot
      end
      return
    end
  else
    cursor.item = 'pointer'
    cursor.item_stack = {id = 0, count = 0}
    cursor.type = 'pointer'
  end
end

function update_cursor_state()
  local x, y, l, m, r, sx, sy = mouse()

  --update hold state for left and right click
  if l and cursor.l and not cursor.held_left and not cursor.held_r then
    cursor.held_left = true
  end

  if r and cursor.r and not cursor.held_right and not cursor.held_l then
    cursor.held_right = true
  end

  if cursor.held_left or cursor.held_right then
    cursor.hold_time = cursor.hold_time + 1
  end

  if not l then cursor.held_l = false end
  if not r then cursor.held_r = false end


  --cursor.cl, cursor.cr = l and not cursor.l, r and not cursor.r
  cursor.lx, cursor.ly, cursor.ll, cursor.lm, cursor.lr, cursor.lsx, cursor.lsy = cursor.x, cursor.y, cursor.l, cursor.m, cursor.r, cursor.sx, cursor.sy
  cursor.x, cursor.y, cursor.l, cursor.m, cursor.r, cursor.sx, cursor.sy = mouse()
end

function dispatch_input()
  --update_cursor_state()
  local x, y, left, middle, right, scroll_x, scroll_y = mouse()
  local tile, tile_x, tile_y = get_world_cell(x, y)
  local screen_tile_x, screen_tile_y = get_screen_cell(x, y)
  local k = get_key(x, y)
  if scroll_y ~= 0 then cycle_hotbar(scroll_y*-1) end

  if not left and cursor.left and cursor.drag then
    local sx, sy = world_to_screen(cursor.drag_loc.x, cursor.drag_loc.y)
    cursor.drag = false
    if cursor.drag_dir == 0 or cursor.drag_dir == 2 then
      cursor.tile_y = sy
    else      
      cursor.tile_x = sx
    end
  end

  if left and not cursor.left and ENTS[k] and (ENTS[k].type == 'stone_furnace' or ENTS[k].type == 'dummy_furnace') then
    if ENTS[k].type == 'dummy_furnace' then k = ENTS[k].other_key end
    window = ENTS[k]:open()
  end
  if window and window:is_hovered(x, y) and left and not cursor.left then
    if window:click(x, y) then return end
  end
  --begin mouse-over priority dispatch

  --check crafting menu
  if craft_menu.vis and craft_menu:is_hovered(x, y) then
    if left and not cursor.left then
      craft_menu:click(x, y, 'left')
    elseif right and cursor.right then
      craft_menu:click(x, y, 'right')
    end
    --check inventory
  elseif inv.vis and inv:is_hovered(cursor.x, cursor.y) then
    inv:clicked(x, y)
  end

    --check other visible widgets
  if cursor.type == 'item' and cursor.item_stack.id ~= 0 then
    local item = ITEMS[cursor.item_stack.id]
    local count = cursor.item_stack.count
    --check for ents to deposit item stack
    if ENTS[k] and ENTS[k].type == 'none' then
      if left then
        if ENTS[k]:can_accept(item.id) then
          local result = ENTS[k]:deposit(cursor.item_stack)
        end
      elseif right then
        remove_tile(x, y)
      end
    else
    --if item is placeable, run callback for item type
      if left and not cursor.left then
        DEFS.callbacks[cursor.item](x, y)
      elseif cursor.item == 'transport_belt' and left then 
        DEFS.callbacks[cursor.item](x, y)
      elseif right then
        remove_tile(x, y)
      end
    end
  end
    --check for held item placement/deposit
  

  --F
  if key(6) then add_item(x, y, 1) end
  --G
  if key(7) then add_item(x, y, 2) end
  --M
  if keyp(13) then show_mini_map = not show_mini_map end
  --R
  if keyp(18) and not keyp(63) then rotate_cursor() end
  --Q
  if keyp(17) then pipette() end
  --I or TAB
  if keyp(9) or keyp(49) then toggle_inventory() end
  --H
  if keyp(8) then toggle_hotbar() end
  --C
  if keyp(3) then toggle_crafting() end
  --Y
  if keyp(25) then debug = not debug end
  --0-9
  for i = 1, 10 do
    local key = 27 + i
    if i == 10 then key = 27 end
    if keyp(key) then set_active_slot(i) end
  end

  --if left and not cursor.last_left then place_tile(x, y, cursor.rot) end
  if right then remove_tile(x, y) end
  if ENTS[k] then ENTS[k].is_hovered = true end

  if craft_menu.vis and not cursor.panel_drag and left and not cursor.left and craft_menu:is_hovered(x, y) == true then
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

  if left and not cursor.left and not craft_menu:is_hovered(x, y) and inv:is_hovered(x, y) then
    local slot = inv:get_hovered_slot(x, y)
    --trace('returning: slot_pos_x = ' .. slot.x .. ', slot_pos_y = ' .. slot.y .. ', slot_index = ' .. slot.index)
    if slot then inv.slots[slot.index]:callback() end
  end

  cursor.last_tile_x, cursor.last_tile_y = cursor.tile_x, cursor.tile_y
  cursor.tile_x, cursor.tile_y = screen_tile_x, screen_tile_y
  cursor.last_rotation = cursor.rot
  cursor.left, cursor.middle, cursor.right = left, middle, right
  cursor.last_x, cursor.last_y, cursor.last_left, cursor.last_mid, cursor.last_right = cursor.x, cursor.y, cursor.left, cursor.middle, cursor.right
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
      if v.type ~= 'dummy_splitter' and v.type ~= 'dummy_drill' and v.type ~= 'dummy_furnace' and v.type ~= 'underground_belt_exit' then
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
  for index, key in pairs(vis_ents['stone_furnace']) do
    --trace('DRAWING ENT - KEY: ' .. tostring(key) .. ', VALUE: ' .. tostring(ent.type))
    if ENTS[key] then ENTS[key]:draw() end
  end
  for index, key in pairs(vis_ents['underground_belt']) do
    --trace('DRAWING ENT - KEY: ' .. tostring(key) .. ', VALUE: ' .. tostring(ent.type))
    if ENTS[key] then ENTS[key]:draw() ENTS[key]:draw_items() end
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
  for index, key in pairs(vis_ents['mining_drill']) do
    --trace('DRAWING ENT - KEY: ' .. tostring(key) .. ', VALUE: ' .. tostring(ent.type))
    if ENTS[key] then ENTS[key]:draw() end
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
  TileMan:draw_terrain(player, 31, 18)
end

function lapse(fn, ...)
	local t = time()
	fn(...)
	return floor((time() - t))
end
spawn_player()
function TIC()
  local start = time()
  TICK = TICK + 1
  --change mouse cursor
  poke(0x3FFB, 341)
  cls(0)

  local gv_time = lapse(get_visible_ents)
  --local m_time = lapse(draw_map)
  local m_time = lapse(draw_map)
  --update_player()
  local up_time = lapse(update_player)
  --handle_input()
  --local hi_time = lapse(handle_input)
  local hi_time = lapse(dispatch_input)

  if TICK % BELT_TICKRATE == 0 then
    BELT_TICK = BELT_TICK + 1
    if BELT_TICK > BELT_MAXTICK then BELT_TICK = 0 end
  end

  if TICK % UBELT_TICKRATE == 0 then
    UBELT_TICK = UBELT_TICK + 1
    if UBELT_TICK > UBELT_MAXTICK then UBELT_TICK = 0 end
  end

  if TICK % DRILL_TICK_RATE == 0 then
    DRILL_BIT_TICK = DRILL_BIT_TICK + DRILL_BIT_DIR
    if DRILL_BIT_TICK > 7 or DRILL_BIT_TICK < 0 then DRILL_BIT_DIR = DRILL_BIT_DIR * -1 end
    DRILL_ANIM_TICK = DRILL_ANIM_TICK + 1
    if DRILL_ANIM_TICK > 2 then DRILL_ANIM_TICK = 0 end
  end

  if TICK % FURNACE_ANIM_TICKRATE == 0 then
    FURNACE_ANIM_TICK = FURNACE_ANIM_TICK + 1
    if FURNACE_ANIM_TICK > FURNACE_ANIM_TICKS then
      FURNACE_ANIM_TICK = 0
    end
  end

  local ue_time = lapse(update_ents)
  --draw_ents()
  local de_time = lapse(draw_ents)

  for k, v in pairs(ENTS) do
    v.updated = false
    v.drawn = false
    v.is_hovered = false
    if v.type == 'transport_belt' then v.belt_drawn = false; v.curve_checked = false; end
  end
  --TileMan:draw_clutter(player, 31, 18)
  if not show_mini_map then TileMan:draw_clutter(player, 31, 18) end
  --draw dust
  particles()
  for i,d in pairs(dust) do
    if d.ty>=0 then	circ(d.x,d.y,d.r,d.c)
    else circb(d.x,d.y,d.r,d.c+1) end
  end
  draw_player()

  local dc_time = lapse(draw_cursor)
  local x, y, l, m, r = mouse()
  local col = 5
  if r then col = 2 end
  -- if (l or r) and TICK % 3 == 0 then
  --   sspr(346 + BELT_TICK, x - 4, y - 4, 0, 1)
  --   line(x, y, 119, 66 + player.anim_frame, 4 + BELT_TICK)
  -- end


  inv:draw()
  --inv:draw_hotbar()
  craft_menu:draw()
  if window then
    if ENTS[window.ent_key] then
      window:draw()
    else
      window = nil
    end
  end

  --draw_cursor()

  --   local info = {
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

  if show_mini_map then
    TileMan:draw_worldmap(player)
  end

  local tile, wx, wy = get_world_cell(cursor.x, cursor.y)
  local sx, sy = get_screen_cell(cursor.x, cursor.y)
  local key = get_key(cursor.x, cursor.y)
  local info = {
    [1] = 'World X-Y: ' .. wx ..',' .. wy,
    [2] = 'Player X-Y: ' .. player.x ..',' .. player.y,
    [3] = 'Tile: ' .. tostring(tile.sprite_id),
    [4] = 'Sx,Sy: ' .. sx .. ',' .. sy,
    [5] = 'Key: ' .. key,
    [6] = '#Ents: ' .. ents,
    [7] = 'Frame Time: ' .. floor(time() - start) .. 'ms',
    [8] = 'Seed: ' ..seed,
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
  --draw_debug2(info)
  if debug then ui.draw_text_window(info, 2, 2) end
end

-- <TILES>
-- 000:4444444444444444444444444444444444444444444444444444444444444444
-- 001:4444444444477446446777474477764744777777647677444777774444776744
-- 002:4445744444477444444775444447774444577444447774444447744444477444
-- 003:4647774444767774477737774767776747776777447777744447774644444444
-- 004:44444444444444444444444444444b444444bab444444b444444474444444444
-- 005:4647774444762764477232774767276746776777447777744447764644444444
-- 006:4444444445444444447444444474744444747444444444444444444444444444
-- 007:444444444444444444eddd444eddddd44ccdcdc444fcce444444444444444444
-- 008:44444444444444444444de444444cdc444444cd4444444444444444444444444
-- 009:4444444d44b444444bbd4444444bd4444444bd444d444bb444444b4444444444
-- 010:4444444444bbbb444bbbbbb44b0b0bb44bbebbb444bbbb4444dbcb4444444444
-- 011:9999999999944999994444999444444994444449994444999994499999999999
-- 012:9999999944999494944444444444944444444444444444444444444444444444
-- 013:9999999999999944999994449999449499994444994444449494444494444444
-- 014:9999999999999999999999999999999999999999994444999444444944444444
-- 015:9494444994444449994444944944449999494499944444499944449494444449
-- 016:6666666666666666666666666666666666666666666666666666666666666666
-- 017:6666636666667666766476666767766767677676676776766666666666666666
-- 018:6666666666d666666d2d66d666d66d2d667666d6667666766666666666666666
-- 019:6666666666666666667666666677666666776676667767666666676666666666
-- 020:6676666667566666765666667664666676666766666665766666656766663667
-- 021:66666666666666666666666666666b666666bab666666b666666676666666666
-- 022:6669666666949666666866666667666666676666666766666666666666666666
-- 023:666622666762b226667222266666bd666666bc66676667666666766666666666
-- 024:66666666666cd66666edc66666dc666666666666666666666666666666666666
-- 025:6666666666666666666666666666666666666666666666666666666666666666
-- 026:666666666666666666cddd666eddddd66ccdcdc666ccce666666666666666666
-- 027:4444444444466444446666444666666446666664446666444446644444444444
-- 028:4444444466444646466666666666466666666666666666666666666666666666
-- 029:4444444444444444444446664444666644466666444666664466666644666666
-- 030:4444444444444444444444444444444444444444446666444666666466666666
-- 031:4646666446666664446666466466664444646644466666644466664646666664
-- 032:7777777777777777777777777777777777777777777777777777777777777777
-- 033:777707777f7777777f7f77f7777077f77f777077707f70777777777f7777f770
-- 034:7777a777777a9a777977a7779897657779756777567767777657777776777777
-- 035:7721777772321777772177777776777777567777777677777776577777767777
-- 036:7726777772327777772647777774547777764777775677777776777777777777
-- 037:7777777777777777777777e7770770707e707f7777707f77777f7f7777777777
-- 038:7777777777777777777777e7770770707e707f7777707f77777f7f7777777777
-- 039:7777777777777777777777e7770770707e707f7777707f77777f7f7777777777
-- 040:777777777777777777eddd777eddddd77ccdcdc777fcce777777777777777777
-- 041:7777777777777777777777777777777777777777777777777777777777777777
-- 042:7777777777ddcdd77dcdddccddddcccdcddccdcefecceeef7ffffff777777777
-- 043:6666666666677666667777666777777667777776667777666667766666666666
-- 044:6666666677666767677777777777677777777777777777777777777777777777
-- 045:6666666666666676666667776666776766677777667677776677777767777777
-- 046:6666666666666666666666666666666666666666667777666777777677777777
-- 047:6777767667777776767777666677776766776766677777767677776667777776
-- 079:9999999999899989999999999999999999999999999899999899989999999999
-- 160:4ce4ce44cdd4edc4dec44cf4444444444ecd4de4edf44ece4ee4ecdc444444e4
-- 161:442342244233434344234f33443444444244442332324332f342424443244444
-- 162:4ce4cf448bd4fdb48ee448f444444444edcb4ff4fc8e48cf4ff4ffbc44444ef4
-- 163:4400400440fe40ef400f44f0440444444044440f000e40f00ef040e44f044444
-- 164:45745f44f654f654f77447f44444444475754f74f677475f4ff4ff65444445f4
-- 165:41f40f440114f114410141f4444444440f104104f11f411f410411f0444440f4
-- 176:dc000000ccd000000ee000000000000000000000000000000000000000000000
-- 177:0340000044200000230000000000000000000000000000000000000000000000
-- 178:be000000cd8000000cd000000000000000000000000000000000000000000000
-- 179:ffe00000eff00000fe0000000000000000000000000000000000000000000000
-- 180:0570000077500000f70000000000000000000000000000000000000000000000
-- 181:0ff0000011100000ff0000000000000000000000000000000000000000000000
-- 198:0000000000000000000000000000000000000006000006660000556600005556
-- 199:0000000000000000000000000665500066665566666566666666666566676666
-- 200:0000000000000000000000000000000050000000550000005550000066550000
-- 201:0000000000000000000000000000000600000066000006660000666600007666
-- 202:0000000000000000065555005666655565566656666666666766776666776666
-- 203:0000000000000000000000005000000065000000650000006655000066650000
-- 204:0000000000000000000000000000000b00000022000002b200002bd200022222
-- 205:0000000000000000022d2220222222bd22bb2222222db22222222222b2222222
-- 206:0000000000000000000000002000000022000000b2200000db2200002d22b000
-- 214:0006666500666666077676667776776677777777007772770000772000000002
-- 215:6677666667777666777277667727777772777776722277767233077702337777
-- 216:6665000066550000765555006666655066667600666677006667700037770000
-- 217:0000076600000076000000070000000000006660000765560000766500000772
-- 218:6667777766723373677233037772333300022300600223006702330070023300
-- 219:7665000037670000777000000000000000000000006000000666000066666000
-- 220:002d222200222243000003110000000f00000000000000000000000000000000
-- 221:243443424eceece4f1cdec1f1fcddcf100cddc00000bd000000bb000000db000
-- 222:222222003422220011300000f000000000000000000000000000000000000000
-- 230:0000000200000000000000000000000000000000000000000000000000000000
-- 231:2233777322330037022333000233300002330000023300000233000002330000
-- 232:7770000070000000000000000000000000000000000000000000000000000000
-- 233:0000007700000000000000000000000000000000000000000000000000000000
-- 234:2202330702223300000223330002333000023300000233000002330000023300
-- 235:7376660037777000000000000000000000000000000000000000000000000000
-- 237:000bb000000db000000bb000000bb000000bb000000bd000000bb000000bb000
-- 246:0000000000000000000000000000000000000000000000000000000000000002
-- 247:0223000002330000023300000233000002330000023300002233300022333300
-- 250:0002330000023300000223000002330000023300000233000022333002223333
-- 253:00bbb00000bdbb0000bdbd0000bcedb00bdbeed00bcdbedbbcbdbcecbbd00000
-- 254:000000000000000000000000000000000000000000000000b000000000000000
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
-- 017:cdeeeeeed000dddde00c23eee00d323de00c232cd00d32eee000eccce000c000
-- 018:eeeeeedcdddd000deeeee00ecdcdc00edcdcd00eeeeee00dccce000e000c000e
-- 019:000d0000000d00000defed0000def000000d0000000000000000000000000000
-- 021:0002000000002000f00020002fff200002222200000022200000022200000022
-- 022:0000000000000000000000000000000000000000000000000000000020000000
-- 023:02f00f2002f00f20002ff2000002200000033000000220000002200000022000
-- 024:6560000034500000654000000000000000000000000000000000000000000000
-- 025:656002213450034265400124000000000000000099800bbd3490034b89400db4
-- 026:003000d003430cec003000d0000000000000000004330bcc03330ccc03340ccd
-- 027:44444444444ef04444f000444400f0044f000004400f00f444f00fe444444444
-- 028:0000000004300980032408fd003300e800000000003300ed03240efe04300dd0
-- 029:000000000e0d00000eff00000de0000000000000000000000000000000000000
-- 031:0000000000300000034000003433333344444444040000000040000000000000
-- 032:3030303000000003300000000000000330000000000000033000000003030303
-- 033:fddddddde0000000ddd00000ffec0000fffeceecffec0000ddd00000cdeeeeee
-- 034:ddddddde0000000e0000000d0000000eceecceed0000000e0000000deeeeeedc
-- 036:00000000d00cd00decccccce000dd000000ee000000110000001100000011000
-- 037:0000000200000000000000000000000000000000000000000000000000000000
-- 038:2200000022200000022200000023200000023000000000000000000000000000
-- 039:0002200000022000000220000002200000022000000220000002300000032000
-- 040:2210000034200000124000000000000000000000000000000000000000000000
-- 041:0ed00000efe00000dd0000000000000000000000000000000000000000000000
-- 042:fe000000efd000000ef000000000000000000000000000000000000000000000
-- 043:bcc00000ccc00000ccd000000000000000000000000000000000000000000000
-- 044:4330000033300000334000000000000000000000000000000000000000000000
-- 045:000fffff00fcdfee0fe43fcdfd43dfd4fc43cfd4fdc43fcdfcdcfeee0fffffff
-- 046:000fffff00fcdfee0fe21fcdfd21dfd2fc21cfd2fdc21fcdfcdcfeee0fffffff
-- 047:000fffff00fcdfee0fea9fcdfda9dfd9fca9cfd9fdca9fcdfcdcfeee0fffffff
-- 048:0000e0000000de00dddddde04eff4edeeff4effe4eff4ededddddde00000de00
-- 049:0000e0000000de00dddddde0eff4efdeff4eff4eeff4efdedddddde00000de00
-- 050:0000e0000000de00dddddde0ff4effdef4eff4eeff4effdedddddde00000de00
-- 051:0000e0000000de00dddddde0f4eff4de4eff4efef4eff4dedddddde00000de00
-- 052:0001100000011000000110000001100000011000000110000001100000011000
-- 053:5252525020000000500000002000000050000000200000005000000000000000
-- 054:000000000fcccc000fc0fc000fcccce00fcccce00fcccc00fcccccc000000000
-- 055:0ffffff0feeeeeeffeeeeeeffeeeeeeffeeeeeeffeeeeeeffeeeeeef0ffffff0
-- 056:3030303000000000300000000000000030000000000000003000000000000000
-- 057:3000000003000000000000000300000000000000030000000000000003000000
-- 058:bbbbbbbbbb000000b0b00000b00b0000b000b000b0000b00b00000b0bddddddb
-- 059:bbbbbbbb000000bb00000b0b0000b00b000b000b00b0000b0b00000beddddddb
-- 060:cdeeeeeed000dddde00c23eee00d232de00c322cd00d33eee000eccce000c000
-- 061:eeeeeedcdddd000deeeee00ecdcdc00edcdcd00eeeeee00dccce000e000c000e
-- 062:cdeeeeeed000dddde00c32eee00d232de00c323cd00d23eee000eccce000c000
-- 063:eeeeeedcdddd000deeeee00ecdcdc00edcdcd00eeeeee00dccce000e000c000e
-- 064:3300003330000003000000000000000000000000000000003000000333000033
-- 065:0000000000000000ddd00000f4ec00004ff4c000f4ec0000ddd0000000000000
-- 066:0000000000000000ddd000004fec0000ff4ec0004fec0000ddd0000000000000
-- 067:0000000000000000ddd00000ff4c0000f4fec000ff4c0000ddd0000000000000
-- 068:0001100000011000000cd000000dc000000ce000000cd0000000000000000000
-- 072:3000000003030303000000000000000000000000000000000000000000000000
-- 073:0000000003000000000000000000000000000000000000000000000000000000
-- 074:b000000eb00000b0b0000b00b000b000b00b0000b0b00000bb000000bbbbbbbb
-- 075:b000000b0b00000b00b0000b000b000b0000b00b00000b0b000000bbbbbbbbbb
-- 076:fddddddde0000000ddd000004fec0000ff4eceec4fec0000ddd00000cdeeeeee
-- 077:ddddddde0000000e0000000d0000000eceecceed0000000e0000000deeeeeedc
-- 078:fddddddde0000000ddd00000ff4c0000f4feceecff4c0000ddd00000cdeeeeee
-- 079:ddddddde0000000e0000000d0000000eceecceed0000000e0000000deeeeeedc
-- 080:ffff0000f2220000f2000000f200000000000000000000000000000000000000
-- 081:b0000000bb000000bbd00000bde0000000000000000000000000000000000000
-- 082:0000000027272700727272702727272056567270656527205656727005652720
-- 083:0000000065656500565656506565656072725650272765607272565007276560
-- 085:b0000000bb000000bbd00000bde0000000000000000000000000000000000000
-- 086:e0000000be000000bbe00000bdf0000000df0000000000000000000000000000
-- 087:000efffe000fccdf00f4dde00f4defd00f4dfed000f4dde0000fccf0000fccff
-- 088:f4f000004ec00000f4f000000000000000000000000000000000000000000000
-- 090:0000000000000000000000000002300000022000000000000000000000000000
-- 091:0000000000000000000220000020020000200200000220000000000000000000
-- 092:0000000000022000002002000200002002000020002002000002200000000000
-- 093:0022220002000020200000022000000220000002200000020200002000222200
-- 096:5dd00000de000000d0d00000000d000000000000000000000000000000000000
-- 100:00b0000000b0000000bbb000b0bbb0000bbbb00000cc00000000000000000000
-- 101:000000000bb000000bbb0000bbbb0000bbbb00000cc000000000000000000000
-- 102:bcf00000df000000000000000000000000000000000000000000000000000000
-- 103:000fccff000fccf000f4dde00f4dfed00f4defd000f4dde0000fccdf000efffe
-- 104:ffffffffeeeeeeeecd4fcd00d4fcd400d4fcd400cd4fcd00eeeeeeeeffffffff
-- 106:00fddf0d0fc77cfc0c7657c00ce77ec00decced002ceec20200dd00200300300
-- 107:00fddf000fcee7f00dee76500deee7700cdccec0003ee2d0030d200d00020000
-- 108:000fff0002fecef020dc75ef0dccc7cf0dceccefcedccdf00cedd02000c00200
-- 109:00feef000feccef00dceecd0ecdccdce0d2dd2d002deed202003300200300300
-- 110:00300300200330022cdeedc202cddc20ecdccdc00dc77cd00f7557f000feef00
-- 112:ddeeeeeedce00000ee000000e0000000e0000000e0000000e0000000e0000000
-- 113:eeceecee000d0000000e0000000c0000000e0000000c0000000e0000000c0000
-- 114:eeeeeedd00000ecd000000ee0000000e0000000e0000000e0000000e0000000e
-- 115:ffddd000eedeed00dcde4fd04dd4feed4dd4feeddcde4fedeeeddeedffffeddd
-- 117:000fffff00fcdfee0fe43fcdfd43dfd4fc43cfd4fdc43fcdfcdcfeee0fffffff
-- 118:000fffff00fcdfee0fe43fd4fd43df4ffc43cf4ffdc43fd4fcdcfeee0fffffff
-- 119:000fffff00fcdfee0fe43f4ffd43dffcfc43cffcfdc43f4ffcdcfeee0fffffff
-- 120:000fffff00fcdfee0fe43ffcfd43dfcdfc43cfcdfdc43ffcfcdcfeee0fffffff
-- 122:00000000000000000000000000ffff000ffffff00ffffff000ffff0000000000
-- 123:00000000000000000000000000ffff000ffffff00ffffff000ffff0000000000
-- 124:000000000000000000000000000ff00000ffff0000ffff00000ff00000000000
-- 125:00000000000000000000000000000000000ff00000ffff00000ff00000000000
-- 126:0000000000000000000000000000000000000000000ff0000000000000000000
-- 128:e0000000e0000000e00000d0e0000de0e000defde0000ff0e00000e0e0000000
-- 129:000e0000000c0000000e0000000c0000ddcedddd000c0000000e0000000c0000
-- 130:0000000e0000000ee000000eff00000efed0000eed00000ed000000e0000000e
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
-- 145:000e0000000c0000000e0000000c000000d4d0000dfffd000d4f4d00edf4fdee
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
-- 181:222220002f2f200022f220002f2f200022222000000000000000000000000000
-- 182:fffff000eefdcf004ffe43f0fcf43ddffcf43ccf4ffc43dfeeefcdcffffffff0
-- 183:fffff000eefdcf00fcfe43f0cdf43ddfcdf43ccffcfc43dfeeefcdcffffffff0
-- 184:fffff000eefdcf00cdfe43f0d4f43ddfd4f43ccfcdfc43dfeeefcdcffffffff0
-- 185:fffff000eefdcf00d4fe43f04ff43ddf4ff43ccfd4fc43dfeeefcdcffffffff0
-- 192:00fdf0000fdddf00fdbdddf0dddddddffdddddf00fdddf0000fdf000000f0000
-- 193:00f3f0000f333f00f3b333f03333333ff33333f00f333f0000f3f000000f0000
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
-- 212:ffffffffeeeeeeeecd4fcd4fd4fcd4fcd4fcd4fccd4fcd4feeeeeeeeffffffff
-- 213:ffffffffeeeeeeeecd2fcd2fd2fcd2fcd2fcd2fccd2fcd2feeeeeeeeffffffff
-- 214:ffffffffeeeeeeeecd9fcd9fd9fcd9fcd9fcd9fccd9fcd9feeeeeeeeffffffff
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
-- 228:00ffffff0fedfeeefcd4fecdfd4ffed4fd4ffed4fcc4fecdfdecfeee0fffffff
-- 229:000fffff00fccfee0fd21fcdfd21cfd2fd21cfd2fcd21fcdfcccfeee0fffffff
-- 230:000fffff00fccfee0fda9fcdfda9cfd9fda9cfd9fcda9fcdfcccfeee0fffffff
-- 231:deecceedefdffffeedcdffdeedcdfdceec2cffdee232ccceecdc4f4edeeef4fd
-- 232:0000000000000dff0000ddcf0000ddcc0000ddcc0000ddcc000dddcc000ddddc
-- 233:00000000ffe00000feee0000ceee0000ceee0000ceee0000cceee000cceee000
-- 234:0000000000000dff0000ddcf0000ddcc0000ddcc0000ddcc000dddcc000ddddc
-- 235:00000000ffe00000feee0000ceee0000ceee0000ceee0000cceee000cceee000
-- 236:0000000000000dff0000dddf0000dddd0000dddd0000dddd000ddddd000ddddd
-- 237:00000000ffe00000fcee0000ccee0000ccee0000ccee0000cccee000dccee000
-- 238:0000000000000dff0000dddf0000dddd0000dddd0000dddd000ddddd000ddddd
-- 239:00000000ffe00000fcee0000ccee0000dcee0000dcee0000dccee000ddcee000
-- 244:004ecd0004eeede0004ecde0000dcd00000dcd00004ecde004eeede0004ecd00
-- 245:002ecd0002eeede0002ecde0000dcd00000dcd00002ecde002eeede0002ecd00
-- 246:009ecd0009eeede0009ecde0000dcd00000dcd00009ecde009eeede0009ecd00
-- 247:00dcce0000ddce000dddcee00dddcce00ddffce0ddf23fceddffffcedddddcce
-- 248:000ddddc00ddddff00dddfce00ddfeec0dddfece0dddffff0ddddddd00000000
-- 249:cccee000ffceee00cefcee00eecfcee0ecefcce0ffffcce0dcccccc000000000
-- 250:000ddddc00ddddff00dddf3400ddf4320dddf3430dddffff0ddddddd00000000
-- 251:cccee000ffceee0023fcee00343fcee0432fcce0ffffcce0dcccccc000000000
-- 252:000ddddd00ddddff00dddf3200ddf3430dddf4340dddffff0ddddddd00000000
-- 253:ddcce000ffccee0034fcce00432fcee0234fcce0ffffcce0ddddcce000000000
-- 254:000ddddd00ddddff00dddf4300ddf4340dddf4320dddffff0ddddddd00000000
-- 255:ddcce000ffdcee0043fdce00234fcee0343fdce0ffffdce0dddddce000000000
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
-- 054:000000000000000c000000dd00000ded00000decddd00de0f4eccdc04ff4cddd
-- 055:00000000c0000000dd000000ced00000ded000000ed000000cdc0000ddddc000
-- 057:0000000000000ddc0000dddc0000dddc000ddddc000ddddd000ddddd000ddddd
-- 058:00000000cee00000ceee0000ceee0000ceeee000cceee000cceee000cceee000
-- 059:00000000000000dc00000ddc00000ddc0000dddc0000dddd0000dddd000ddddd
-- 060:00000000ce000000cee00000cee00000ceee0000ccee0000ccee0000cceee000
-- 061:00000000000000dc00000ddc00000ddc0000dddc0000dddd0000dddd000ddddd
-- 062:00000000ce000000cee00000cee00000ceee0000ccee0000ccee0000cceee000
-- 064:000cceec000ceeee0ffffffffeeeeeeefddddddd0fc23c4c00ffffff00f77777
-- 065:ceecc000eeeec000fffffff0eeeeeeefeddedddfecceccf0ffffff0077777f00
-- 067:000cceec000ceeee0ffffffffeeeeeeefddddddd0fc23c4c00ffffff00f27777
-- 068:ceecc000eeeec000fffffff0eeeeeeefeddedddfecceccf0ffffff00777c7f00
-- 070:f4ecec0dddcdec0d00dec00d0cdec00d0dec0fefcdec00fedec0000fdec00000
-- 071:e0cedc00e0cedc00e00ced00e00cedc0cf00ced0f000cedc00000ced00000ced
-- 073:000ddddd000ddddd00ddddff00dddf4200ddf4230dddf4340dddffff0ddddddd
-- 074:dccee000dccee000ffccee0043fcce00433fce00232fcee0ffffcce0ddddcce0
-- 075:000ddddd000ddddd00ddddff00dddf4200ddf4230dddf4340dddffff0ddddddd
-- 076:dccee000dccee000ffccee0043fcce00433fce00232fcee0ffffcce0ddddcce0
-- 077:000ddddd000ddddd00ddddff00dddf4200ddf4230dddf4340dddffff0ddddddd
-- 078:dccee000dccee000ffccee0043fcce00433fce00232fcee0ffffcce0ddddcce0
-- 080:00f7777700f7776700f7777700f7777700f7777700f7777700f7777700f77777
-- 081:77777f0077777f0077777f0077777f0077777f0077777f0077677f0077777f00
-- 083:00f7277700f7276600f7266600f7725600f7766d00f777d600f7766600f76666
-- 084:7777df00677cdf00667cef00567cdf0066ccef00dcc7cf006677ef007667cf00
-- 089:0000000000000dcc0000ddcc0000ddcc0000ddcc0000ddcc000dddcc000ddddc
-- 090:00000000cee00000ceee0000ceee0000ceee0000ceee0000cceee000cceee000
-- 091:0000000000000dcc0000ddcc0000ddcc0000ddcc0000ddcc000dddcc000ddddc
-- 092:00000000cee00000ceee0000ceee0000ceee0000ceee0000cceee000cceee000
-- 093:0000000000000dcc0000ddcc0000ddcc0000ddcc0000ddcc000dddcc000ddddc
-- 094:00000000cee00000ceee0000ceee0000ceee0000ceee0000cceee000cceee000
-- 096:00f7777700f7777700f7776700f7777700f7777700f7777700f7777700f77777
-- 097:77777f0077777f0077777f0077777f0077777f0077777f0077777f0077777f00
-- 099:00f7656d00f7666d00f7767d00f7766600f7766600f77e6600f7e77700f7e777
-- 100:6667ef00666c7f0066e77f00d6777f00d6777f006d757f007d777f0077d77f00
-- 105:000ddddc00ddddff00dddf3400ddf4320dddf3430dddffff0ddddddd00000000
-- 106:cccee000ffceee0023fcee00343fcee0432fcce0ffffcce0dcccccc000000000
-- 107:000ddddc00ddddff00dddf3400ddf4320dddf3430dddffff0ddddddd00000000
-- 108:cccee000ffceee0023fcee00343fcee0432fcce0ffffcce0dcccccc000000000
-- 109:000ddddc00ddddff00dddf3400ddf4320dddf3430dddffff0ddddddd00000000
-- 110:cccee000ffceee0023fcee00343fcee0432fcce0ffffcce0dcccccc000000000
-- 112:00f7777700ffffff0feefffffeefeeeeffffffff0feccccc0fcecece00ffffff
-- 113:77777f00ffffff00ffffeef0eeeefeefffffffffccccecf0cececef0ffffff00
-- 115:00fe777500ffffff0feefffffeefeeeeffffffff0feccccc0fcecece00ffffff
-- 116:777d7f00ffffff00ffffeef0eeeefeefffffffffccccecf0cececef0ffffff00
-- 165:000fffff00fcdfee0fe43fcdfd43dfd4fc43cfd4fdc43fcdfcdcfeee0fffffff
-- 168:000fffff00fcdfee0fe43f4ffd43dffcfc43cffcfdc43f4ffcdcfeee0fffffff
-- 181:000fffff00fcdfee0fe43fd4fd43df4ffc43cf4ffdc43fd4fcdcfeee0fffffff
-- 184:000fffff00fcdfee0fe43ffcfd43dfcdfc43cfcdfdc43ffcfcdcfeee0fffffff
-- 196:000fffff00fcdfee0f34eff4fdd34fcffcc34fcffd34cff4fcdcfeee0fffffff
-- 212:000fffff00fcdfee0f34efcffdd34fdcfcc34fdcfd34cfcffcdcfeee0fffffff
-- 228:000fffff00fcdfee0f34efdcfdd34f4dfcc34f4dfd34cfdcfcdcfeee0fffffff
-- 244:000fffff00fcdfee0f34ef4dfdd34ff4fcc34ff4fd34cf4dfcdcfeee0fffffff
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

-- <SPRITES4>
-- 000:00000000000fffff00ffcccc0fedfcdc0fccdeff0fedcfec0fccdfcf0fedcfef
-- 001:00000000ffffffffccccccccdcdcdcdcffffffffececececfffffffefffffffc
-- 002:00000000ffffffffccccccccdcdcdcdcfffffffffeeeeeeefce55555feeeeeee
-- 003:00000000fffff000cccccf00dcdcfcf0fffedcf0eeefccf077efdcf0eeefccf0
-- 016:0fccdfcf0fedcfef0fccdfcf0fedcfef0fccdfcf0fedcfef0fccdfce0fedcfec
-- 017:fffffffefffffffcfffffffefffffffcfffffffefffffffccecececeecececec
-- 018:fce33377feeeeeeefce4f4e4fee4f4effce444e4feeff4e4fceff4e4feeeeeee
-- 019:77efdcf0eeefdcf044efccf0f4efdcf044efdcf0ffefccf044efdcf0eeefdcf0
-- 032:0fccdcff0fedcfdd0fccdfdf0fedcfdf0fccdfdf0fedcfdf0fccdfdf0fedcfdd
-- 033:ffffffffddddddddeeeeeeeeefffecccefffecccefffeccceeeeeeeedddddddd
-- 034:ffffffffddddddddeeeeeeeeeccceccceccceccceccceccceeeeeeeedddddddd
-- 035:fffdccf0dddfdcf0efdfdcf0efdfdcf0efdfccf0efdfdcf0efdfdcf0dddfdcf0
-- 048:0fccdcff0fedcfdd0fccfddd0fefdccd0fcfcccc00fccdcd000fffff00000000
-- 049:ffffffffddddddddddddddddccdccdcccccccccccdcdcdcdffffffff00000000
-- 050:ffffffffdddddddddddddddddccdccdccccccccccdcdcdcdffffffff00000000
-- 051:fffcdcf0dddfccf0ddddfcf0cdccdff0cccccff0cdcdcf00fffff00000000000
-- </SPRITES4>

-- <WAVES>
-- 000:eeeeeeedcb9687777777778888888888
-- 001:0123456789abcdeffedcba9876543210
-- 002:06655554443333344556789989abcdef
-- 004:777662679abccd611443377883654230
-- 005:eeedddccbbaaaaaaabbbbcccb9210000
-- 006:cdddb953334ddddaa9abddbaa9876665
-- 007:55556777777776655555666778877776
-- 008:f00070c00600b00550dd000009a0cc00
-- 009:44444456789aabb97a654dc831347213
-- </WAVES>

-- <SFX>
-- 000:020802080201020802010208020802080201020802010208020802080201020802010208020802080201020802010208020802080201020802010208b0b000000004
-- 001:8000800080009000a000c000e000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000220000000000
-- 002:04f0f4000400f4000400f4000400f4000400f4000400f4000400f4000400040004000400040004000400040004000400040004000400040004000400c04000000000
-- 003:050005100520153025504560659085b095f0a5f0b5f0c5f0d5f0e5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0404000000000
-- 004:00ec00c170a4f076f037f00ff00df00af008f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000a0b000000000
-- 005:34073407340734073407f400f400f400f400040704070407040704070407040704070407040704070407040704070407040704070407040704070407200000000000
-- 006:09000900090009000900090009000900090009000900090009000900090009000900090009000900090009000900090009000900090009000900090030b000000000
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
-- 000:00000000000000001000000000000000000000000000100010000000000000000000000010101010101000000000000000000000001010101010100010101010000000000000000000000000101010100000000000101000000000001010101000000000101010101010101010101010101010100000101010101010101010100000000000000010101010100000000000000000001010000000000000000000000000000000101010100000000000000000000000001010101000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </FLAGS>

-- <PALETTE>
-- 000:1c1c1c5d245db13e53ef7d57ffcd75a7f07038b76404650029366f3b5dc941a6f6eaeaea919191b2b2b2656c79333434
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

-- <PALETTE4>
-- 000:1c1c1c5d245db13e53ef7d57ffcd75a7f07038b76404650029366f3b5dc941a6f6eaeaea919191b2b2b2656c79333434
-- </PALETTE4>

