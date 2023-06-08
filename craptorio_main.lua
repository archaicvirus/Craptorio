-- title:   craptorio
-- author:  @ArchaicVirus
-- desc:    De-make of Factorio
-- site:    website link
-- license: MIT License
-- version: 0.3
-- script: lua

require('classes/item_definitions')
require('classes/ores')
require('classes/biomes')
require('classes/callbacks')
require('classes/ui')
require('classes/inventory')
require('classes/underground_belt')
require('classes/transport_belt')
require('classes/splitter')
require('classes/inserter')
require('classes/cable')
require('classes/power_pole')
require('classes/mining_drill')
require('classes/furnace')
require('classes/assembly_machine')
require('classes/research_lab')
require('classes/open_simplex_noise')
require('classes/TileManager')
require('classes/crafting_definitions')
require('classes/research')

--math.randomseed(tstamp() * time())
--local seed = math.random(-1000000000, 1000000000)
--local seed = 902404786
local seed = 747070313
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
--window = nil
CURSOR_POINTER = 286
CURSOR_HIGHLIGHT = 309
CURSOR_HIGHLIGHT_CORNER = 307
CURSOR_HIGHLIGHT_CORNER_S = 336
CURSOR_HAND_ID = 320
CURSOR_GRAB_ID = 321
technology = {}
current_research = 1
cursor = {
  x = 8,
  y = 8,
  id = 352,
  lx = 8,
  ly = 8,
  tx = 8,
  ty = 8,
  wx = 0,
  wy = 0,
  sx = 0,
  sy = 0,
  lsx = 0,
  lsy = 0,
  l = false,
  ll = false,
  m = false,
  lm = false,
  r = false,
  lr = false,
  rot = 0,
  last_rotation = 0,
  hold_time = 0,
  type = 'pointer',
  item = 'transport_belt',
  drag = false,
  panel_drag = false,
  drag_dir = 0,
  drag_loc = {x = 0, y = 0},
  hand_item = {id = 0, count = 0},
  drag_offset = {x = 0, y = 0},
  item_stack = {id = 9, count = 100}
}
player = {
  x = 15 * 8, y = 600 * 8,
  spr = 362,
  lx = 0, ly = 0,
  shadow = 382,
  anim_frame = 0, anim_speed = 8, anim_dir = 0, anim_max = 4,
  last_dir = '0,0', move_speed = 2,
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

dummies = {
  ['dummy_furnace'] = true,
  ['dummy_assembler'] = true,
  ['dummy_drill'] = true,
  ['dummy_lab'] = true,
  ['dummy_splitter'] = true
}

opensies = {
  ['stone_furnace'] = true,
  ['assembly_machine'] = true,
  ['research_lab'] = true
}

inv = make_inventory()
inv.slots[1].item_id  = 9  inv.slots[1].count = 10
inv.slots[57].item_id = 9  inv.slots[57].count = 10
inv.slots[58].item_id = 10 inv.slots[58].count = 10
inv.slots[59].item_id = 11 inv.slots[59].count = 10
inv.slots[60].item_id = 13 inv.slots[60].count = 10
inv.slots[61].item_id = 14 inv.slots[61].count = 10
inv.slots[62].item_id = 18 inv.slots[62].count = 10
inv.slots[63].item_id = 19 inv.slots[63].count = 10
inv.slots[64].item_id = 22 inv.slots[64].count = 10
craft_menu = ui.NewCraftPanel(135, 1)
vis_ents = {}
show_mini_map = false
show_tile_widget = false
debug = false
alt_mode = false
show_tech = false
--water effect defs
local num_colors = 3
local start_color = 8
local tileSize = 8
local tileCount = 1
local amplitude = num_colors
local frequency = 0.185
local speed = 0.0022
--------------------
sounds = {
  ['deny']        = {id = 5, note = 'C-3', duration = 22, channel = 0, volume = 15, speed = 0},
  ['place_belt']  = {id = 4, note = 'B-3', duration = 10, channel = 0, volume = 15, speed = 4},
  ['delete']      = {id = 2, note = 'C-3', duration =  4, channel = 0, volume = 15, speed = 5},
  ['rotate_r']    = {id = 3, note = 'E-5', duration = 10, channel = 0, volume = 15, speed = 3},
  ['rotate_l']    = {id = 7, note = 'E-5', duration = 10, channel = 0, volume = 15, speed = 3},
  ['move_cursor'] = {id = 0, note = 'C-4', duration =  4, channel = 0, volume = 15, speed = 5},
}

local dust = {}

_t = 0
sprites = {}
loaded = false

function pokey(bnk,sid,tw,th,x,y,ck)
  for ty=0,th-1 do
    for tx=0,tw-1 do
      for sy=0,7 do
        for sx=0,7 do
          local px = x + tx * 8 + sx
          local py = y + ty * 8 + sy
          local pixel = sprites[bnk][(sid + tx + ty * 16)][sy * 8 + sx]

          -- Check if pixel matches color_key
          local skip_pixel = false
          if type(ck) == 'table' then
            -- If color_key is a table, check if pixel is in the table
            for _, value in ipairs(ck) do
              if pixel == value then
                skip_pixel = true
                break
              end
            end
          else
            -- If color_key is a single value, directly compare with pixel
            if pixel == ck then
              skip_pixel = true
            end
          end

          -- Skip drawing this pixel if it matches the color_key
          if skip_pixel then
            goto continue
          end

          local addr = (py * 240 + px) // 2
          if px % 2 == 0 then
            -- Modify the least significant nibble
            local byte = peek(addr)
            byte = (byte & 0xF0) | pixel
            poke(addr, byte)
          else
            -- Modify the most significant nibble
            local byte = peek(addr)
            byte = (byte & 0x0F) | (pixel << 4)
            poke(addr, byte)
          end

          ::continue::
        end
      end
    end
  end
end


function load_sprites()
  local s = "Loading Bank ".. _t .. (("."):rep((_t+1)%4))
  local _w = print(s,0,-6)
  prints(s,(240//2)-(_w//2),65)
  if _t==8 then sync(0,0,false) loaded = true return end
  sync(0,_t,false)
  sprites[_t] = {}
  for i=0,511 do
    sprites[_t][i] = {}
    for j=0,31 do
      local byte = peek(0x4000 + i * 32 + j)
      sprites[_t][i][j*2] = byte & 0x0F
      sprites[_t][i][j*2 + 1] = (byte >> 4) & 0x0F
    end
  end
  _t=_t+1
end

function move(o)
  o.x = o.x + o.vx
  o.y = o.y + o.vy
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
    table.insert(dust, {x = x_, y = y_, c = 4, ty = math.random(-1, 1), vx = vx_, vy = vy_, r = math.random() * r_, t = 5 * r_})
  end
end

function get_sprite_pixel(sprite_id, x, y)
  -- Arguments: sprite_id (0-511), x (0-7), y (0-7)
  local byte = peek(0x04000 + sprite_id * 32 + y * 4 + math.floor(x / 2))
  return x % 2 == 0 and byte % 16 or byte // 16
end

function set_sprite_pixel(sprite_id, x, y, color)
  -- Arguments: sprite_id (0-511), x (0-7), y (0-7), color (palette index 0-15)
  local addr = 0x04000 + sprite_id * 32 + y * 4 + math.floor(x / 2)
  local byte = peek(addr)
  if x % 2 == 0 then poke(addr, (byte - byte % 16) + color) else poke(addr, (color * 16) + byte % 16) end
end

function sound(name)
  if sounds[name] then
    local s = sounds[name]
    sfx(s.id, s.note, s.duration, s.channel, s.volume, s.speed)
  end
end

function update_water_effect(time)
  for sprite_id = 0, (tileCount * tileCount) - 1 do
    for y = 0, tileSize - 1 do
      for x = 0, tileSize - 1 do
        -- Get the world coordinates for the current pixel
        local worldX = (sprite_id % tileCount) * tileSize + x
        local worldY = math.floor(sprite_id / tileCount) * tileSize + y
        
        -- Apply modulo operation to create a tiling texture
        local tileX = worldX % (tileSize * tileCount)
        local tileY = worldY % (tileSize * tileCount)
        
        -- Calculate the noise value using world coordinates and time
        --time = time + math.sin(time)
        local noiseValue = simplex.Noise2D(((tileX + time * speed) * frequency), (tileY + time * speed) * frequency)
        
        -- Convert the noise value to a pixel color (palette index 0-15)
        local color = math.floor(((noiseValue + 1) / 2) * amplitude) + start_color
        --local color = math.floor(((noiseValue + 1) / 2) * amplitude)
        -- Set the pixel color in the sprite
        set_sprite_pixel(224, x, y, color)
      end
    end
  end
end

function get_visible_ents()
  vis_ents = {
    ['transport_belt'] = {},
    ['inserter'] = {},
    ['power_pole'] = {},
    ['splitter'] = {},
    ['mining_drill'] = {},
    ['stone_furnace'] = {},
    ['underground_belt'] = {},
    --['underground_belt_exit'] = {},
    ['assembly_machine'] = {},
    ['research_lab'] = {},
  }
  for x = 1, 31 do
    for y = 1, 18 do
      local worldX = (x*8) + (player.x - 116)
      local worldY = (y*8) + (player.y - 64)
      local cellX = floor(worldX / 8)
      local cellY = floor(worldY / 8)
      local k = cellX .. '-' .. cellY
      --if ENTS[key] and ENTS[key].type ~= 'dummy_splitter' and ENTS[key].type ~= 'dummy_drill' and ENTS[key].type ~= 'dummy_furnace' and ENTS[key] ~= then
      if ENTS[k] and vis_ents[ENTS[k].type] then
        local type = ENTS[k].type
        local index = #vis_ents[type] + 1
        --vis_ents[type][key] = ENTS[key]
        vis_ents[type][index] = k
      end
    end
  end
end

function get_ent(x, y)
  local k = get_key(x, y)
  if not ENTS[k] then return false end
  if ENTS[k].type == 'splitter' then return k end
  if ENTS[k].type == 'underground_belt_exit' then return ENTS[k].other_key, true end
  if ENTS[k].type == 'underground_belt' then return k end
  if ENTS[k].other_key then return ENTS[k].other_key else return k end
end

function get_key(x, y)
  local _, wx, wy = get_world_cell(x, y)
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

function highlight_ent(k)

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

function draw_item_stack(x, y, stack)
  --trace('stack count: ' .. stack.count .. ' Stack ID: ' .. stack.id)
  sspr(ITEMS[stack.id].sprite_id, x, y, ITEMS[stack.id].color_key)
  local sx, sy = stack.count < 10 and x + 5 or x + 3, y + 5
  prints(stack.count, sx, sy)
end

function clamp(val, min, max)
  return math.max(0, math.min(val, max))
end

function prints(text, x, y, bg, fg)
  bg, fg = bg or 0, fg or 4
  print(text, x - 1, y, bg, false, 1, true)
  print(text, x    , y, fg, false, 1, true)
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
    sound('deny')
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
--------ADD-+-REMOVE-ENTS-------------------------------------------------
function remove_research_lab(x, y)
  local tile, wx, wy = get_world_cell(x, y)
  local k = wx .. '-' .. wy
  if not ENTS[k] then return end
  if ENTS[k].type == 'dummy_lab' then
    trace('removing dummy lab')
    k = ENTS[k].other_key
  end

  if ui.active_window and ui.active_window.ent_key == k then ui.active_window = nil end
  local keys = ENTS[k].dummy_keys
  for dk, v in ipairs(keys) do
    trace('removing DUMMY KEYS')
    ENTS[v] = nil
  end
end

function add_assembly_machine(x, y)
  local tile, wx, wy = get_world_cell(x, y)
  local k = wx .. '-' .. wy
  if not ENTS[k] then
    --check 3x3 area for ents
    for i = 0, 2 do
      for j = 0, 2 do
        if ENTS[wx + j .. '-' .. i + wy] then 
          sound('deny')
          return
        end
      end
    end
    --else place dummy ents to reserve 3x3 tile area, and create the crafter
    for i = 0, 2 do
      for j = 0, 2 do
        ENTS[wx + j .. '-' .. i + wy] = {type = 'dummy_assembler', other_key = k}
      end
    end
    sound('place_belt')
    ENTS[k] = new_assembly_machine(wx, wy)
  else
    sound('deny')
  end
end

function remove_assembly_machine(x, y)
  local tile, wx, wy = get_world_cell(x, y)
  local k = wx .. '-' .. wy
  if ENTS[k].other_key then
    k = ENTS[k].other_key
    wx, wy = ENTS[k].x, ENTS[k].y
  end
  if ENTS[k] and ENTS[k].type == 'assembly_machine' then
    for i = 0, 2 do
      for j = 0, 2 do
        ENTS[wx + j .. '-' .. i + wy] = nil
      end
    end
    ENTS[k] = nil
  -- elseif ENTS[k] and ENTS[k].type == 'dummy_assembler' then
  --   k = ENTS[k].other_key
  --   wx, wy = ENTS[k].x, ENTS[k].y
  --   for i = 0, 2 do
  --     for j = 0, 2 do
  --       ENTS[wx + j .. '-' .. i + wy] = nil
  --     end
  --   end
  --   ENTS[k] = nil
  end
end

function add_underground_belt(x, y)
  local tile, wx, wy = get_world_cell(x, y)
  local k = wx .. '-' .. wy
  if not ENTS[k] then
    local result, other_key, cells = get_ubelt_connection(x, y, cursor.rot)
    --found suitable connection
    --don't create a new ENT, use the found ubelt as the 'host', and update it with US as it's output
    if result then
      ENTS[k] = {type = 'underground_belt_exit', flip = UBELT_ROT_MAP[cursor.rot].out_flip, rot = cursor.rot, x = wx, y = wy, other_key = other_key}
      ENTS[other_key]:connect(wx, wy, #cells - 1)
      sound('place_belt')
    else
      ENTS[k] = new_underground_belt(wx, wy, cursor.rot)
    end
    sound('place_belt')
  else
    sound('deny')
  end
end

function remove_underground_belt(x, y)
  local k = get_key(x, y)
  if ENTS[k] then
    --return underground items if any
    --remove hidden belts, since we removed the head
    ENTS[ENTS[k].other_key] = nil
    ENTS[k] = nil
    sound('delete')
  end
end

function remove_belt(x, y)
  local k = get_key(x, y)
  local tile, cell_x, cell_y = get_world_cell(x, y)
  if not ENTS[k] then return end
  if ENTS[k] and ENTS[k].type == 'transport_belt' then
    sound('delete')
    ENTS[k] = nil
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
  local key1 = get_key(x, y)
  local key2 = wx .. '-' .. wy
  if not ENTS[key1] and not ENTS[key2] then
    local splitr = new_splitter(cell_x, cell_y, cursor.rot)
    splitr.other_key = key2
    ENTS[key1] = splitr
    ENTS[key2] = {type = 'dummy_splitter', other_key = key1, rot = cursor.rot}
    ENTS[key1]:set_output()
    sound('place_belt')
  else
    sound('deny')
  end
end

function remove_splitter(x, y)
  local k = get_key(x, y)
  if not ENTS[k] then return end
  if ENTS[k].type == 'dummy_splitter' then k = ENTS[k].other_key end
  if ENTS[k] and ENTS[k].type == 'splitter' then    
    local key_l, key_r = ENTS[k].output_key_l, ENTS[k].output_key_r
    local key2 = ENTS[k].other_key
    ENTS[k] = nil
    ENTS[key2] = nil
    if ENTS[key_l] and ENTS[key_l].type == 'transport_belt' then ENTS[key_l]:update_neighbors(k) end
    if ENTS[key_r] and ENTS[key_r].type == 'transport_belt' then ENTS[key_r]:update_neighbors(k) end
    sound('delete')
  end
end

function add_inserter(x, y, rotation)
  local k = get_key(x, y)
  local tile, cell_x, cell_y = get_world_cell(x, y)
  if ENTS[k] and ENTS[k].type == 'inserter' then
    if ENTS[k].rot ~= rotation then
      ENTS[k]:rotate(rotation)
      sound('rotate')
    end
  elseif not ENTS[k] then
    ENTS[k] = new_inserter({x = cell_x, y = cell_y}, rotation)
    sound('place_belt')
  else
    sound('deny')
  end
end

function remove_inserter(x, y)
  local k = get_key(x, y)
  if not ENTS[k] then return end
  if ENTS[k] and ENTS[k].type == 'inserter' then
    ENTS[k] = nil
    sound('delete')
  end
end

function add_pole(x, y)
  local k = get_key(x,y)
  local tile, cell_x, cell_y = get_world_cell(x, y)
  if not ENTS[k] then
    ENTS[k] = new_pole({x = cell_x, y = cell_y})
  end
end

function remove_pole(x, y)
  local k = get_key(x, y)
  if not ENTS[k] then return end
  if ENTS[k] and ENTS[k].type == 'power_pole' then
    ENTS[k] = nil
  end
end

function add_drill(x, y)
  local k = get_key(x, y)
  local found_ores = {}
  local field_keys = {}
  --local sx, sy = get_screen_cell(x, y)
  for i = 1, 4 do
    local pos = DRILL_AREA_MAP_BURNER[i]
    local sx, sy = cursor.tx + (pos.x * 8), cursor.ty + (pos.y * 8)
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
      sound('deny')
      return
    end
  end

  if not ENTS[k] then
    local tile, wx, wy = get_world_cell(x, y)
    sound('place_belt')
    --trace('creating drill @ ' .. key)
    ENTS[k] = new_drill({x = wx, y = wy}, cursor.rot, field_keys)
    ENTS[wx + 1 .. '-' .. wy] = {type = 'dummy_drill', other_key = k}
    ENTS[wx + 1 .. '-' .. wy + 1] = {type = 'dummy_drill', other_key = k}
    ENTS[wx .. '-' .. wy + 1] = {type = 'dummy_drill', other_key = k}
  elseif ENTS[k] and ENTS[k].type == 'mining_drill' then
    sound('place_belt')
    sound('rotate')
    --ENTS[k].rot = cursor.rot
  end
end

function remove_drill(x, y)
  local k = get_key(x, y)
  local _, wx, wy = get_world_cell(x, y)
  local _, wx, wy = get_world_cell(x, y)
  if ENTS[k].type == 'dummy_drill' then
    k = ENTS[k].other_key
  end
  if ENTS[k] then
    local wx, wy = ENTS[k].pos.x, ENTS[k].pos.y
    ENTS[k] = nil
    ENTS[wx + 1 .. '-' .. wy] = nil
    ENTS[wx + 1 .. '-' .. wy + 1] = nil
    ENTS[wx .. '-' .. wy + 1] = nil
    sound('delete')
  end
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
    sound('place_belt')
  end
end

function remove_furnace(x, y)
  local k = get_key(x, y)
  if ENTS[k] then
    if ENTS[k].type == 'dummy_furnace' then
      k = ENTS[k].other_key
    end
    for k, v in ipairs(ENTS[k].dummy_keys) do
      ENTS[v] = nil
    end
    ENTS[k] = nil
    sound('delete')
  end
end

----END-OF----ADD-+-REMOVE-ENTS------------------------------------------------

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
  -- --draw_debug_window(info, 10)
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
  move_player(x_dir * (not show_mini_map and player.move_speed or player.move_speed * 8), y_dir * (not show_mini_map and player.move_speed or player.move_speed * 8))
  player.last_dir = x_dir .. ',' .. y_dir
end

function draw_player()
  local sx, sy = world_to_screen(player.x//8 + 1, player.y//8 + 2)
  --sspr(CURSOR_HIGHLIGHT, sx, sy, 0, 1, 0, 0, 2, 2)
  local sprite = player.directions[player.last_dir] or player.directions['0,0']
  sspr(player.shadow - player.anim_frame, 240/2 - 4, 136/2 + 8, 0)
  sspr(sprite.id, 240/2 - 4, 136/2 - 4 + player.anim_frame, 0, 1, sprite.flip)
end

function cycle_hotbar(dir)
  inv.active_slot = inv.active_slot + dir
  if inv.active_slot < 1 then inv.active_slot = INVENTORY_COLS end
  if inv.active_slot > INVENTORY_COLS then inv.active_slot = 1 end
  set_active_slot(inv.active_slot)
end

function set_active_slot(slot)
  inv.active_slot = slot
  local id = inv.slots[slot + INV_HOTBAR_OFFSET].item_id
  if id ~= 0 then
    trace('setting item to: ' .. ITEMS[id].name)
    cursor.item = ITEMS[id].name
    cursor.item_stack = {id = id, count = inv.slots[slot + INV_HOTBAR_OFFSET].count}
    cursor.type = 'item'
  else
    cursor.item = false
    cursor.type = 'pointer'
    cursor.item_stack = {id = 0, count = 0}
  end
end

function add_item(x, y, id)
  local k = get_key(x, y)
  if ENTS[k] and ENTS[k].type == 'transport_belt' then
    ENTS[k].idle = false
    ENTS[k].lanes[1][8] = id
    ENTS[k].lanes[2][8] = id
  end
end

function draw_debug_window(data, x, y)
  if debug then
    x, y = x or 2, y or 2
    local width = 74
    local height = (#data * 6) + 5
    ui.draw_panel(x, y, width, height, 0, 2, _, 0)
    for i = 1, #data do
      prints(data[i], x + 4, i*6 + y - 3, 0, 11)
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
    if get_flags(cursor.tx, cursor.ty - 8, 0) then cursor.ty = cursor.ty - 8 sound('move_cursor') end
  elseif dir == 'down' then
    if get_flags(cursor.tx, cursor.ty + 8, 0) then cursor.ty = cursor.ty + 8 sound('move_cursor') end
  elseif dir == 'left' then
    if get_flags(cursor.tx - 8, cursor.ty, 0) then cursor.tx = cursor.tx - 8 sound('move_cursor') end
  elseif dir == 'right' then
    if get_flags(cursor.tx + 8, cursor.ty, 0) then cursor.tx = cursor.tx + 8 sound('move_cursor') end
  end
  if dir == 'mouse' then
    cursor.tx, cursor.ty = get_screen_cell(x, y)
  end 
end

function draw_cursor()
  local x, y = cursor.x, cursor.y
  local k = get_key(x, y)

  if inv:is_hovered(x, y) or craft_menu:is_hovered(x, y) then
    if cursor.panel_drag then
      sspr(CURSOR_GRAB_ID, cursor.x - 1, cursor.y - 1, 0, 1, 0, 0, 1, 1)
    else
      sspr(CURSOR_HAND_ID, cursor.x - 2, cursor.y, 0, 1, 0, 0, 1, 1)
    end
  return
  end

  if cursor.type == 'item' then
    if cursor.item == 'transport_belt' then
      if cursor.drag then
        local sx, sy = world_to_screen(cursor.drag_loc.x, cursor.drag_loc.y)
        if cursor.drag_dir == 0 or cursor.drag_dir == 2 then
          sspr(CURSOR_HIGHLIGHT, cursor.tx - 1, sy - 1, 0, 1, 0, 0, 2, 2)
        else
          sspr(CURSOR_HIGHLIGHT, sx - 1, cursor.ty - 1, 0, 1, 0, 0, 2, 2)
        end
        --arrow to indicate drag direction
        sspr(BELT_ARROW_ID, cursor.tx, cursor.ty, 0, 1, 0, cursor.drag_dir, 1, 1)
      elseif not ENTS[k] or (ENTS[k] and ENTS[k].type == 'transport_belt' and ENTS[k].rot ~= cursor.rot) then
        sspr(BELT_ID_STRAIGHT + BELT_TICK, cursor.tx, cursor.ty, 00, 1, 0, cursor.rot, 1, 1)
        sspr(CURSOR_HIGHLIGHT, cursor.tx - 1, cursor.ty - 1, 0, 1, 0, 0, 2, 2)
      else
        sspr(CURSOR_HIGHLIGHT, cursor.tx - 1, cursor.ty - 1, 0, 1, 0, 0, 2, 2)
      end
    elseif cursor.item == 'inserter' then
      if not ENTS[k] or (ENTS[k] and ENTS[k].type == 'inserter' and ENTS[k].rot ~= cursor.rot) then
        local tile, world_x, world_y = get_world_cell(cursor.tx, cursor.ty)
        local temp_inserter = new_inserter({x = world_x, y = world_y}, cursor.rot)
        sspr(CURSOR_HIGHLIGHT, cursor.tx - 1, cursor.ty - 1, 0, 1, 0, 0, 2, 2)
        temp_inserter:draw()
      end
      sspr(CURSOR_HIGHLIGHT, cursor.tx - 1, cursor.ty - 1, 0, 1, 0, 0, 2, 2)
    elseif cursor.item == 'power_pole' then
      local tile, world_x, world_y = get_world_cell(cursor.tx, cursor.ty)
      local temp_pole = new_pole({x = world_x, y = world_y})
      temp_pole:draw(true)
      --check around cursor to attach temp cables to other poles
    elseif cursor.item == 'splitter' then
      local loc = SPLITTER_ROTATION_MAP[cursor.rot]
      local tile, wx, wy = get_world_cell(x, y)
      wx, wy = wx + loc.x, wy + loc.y
      local tile2, cell_x, cell_y = get_world_cell(x, y)
      local key1 = get_key(x, y)
      local key2 = wx .. '-' .. wy
      local red, green = {5,6,0}, {1,2,0}
      local color_keys = not ENTS[key1] and not ENTS[key2] and green or red
      local loc1, loc2, loc3, loc4
      if cursor.rot == 0 or cursor.rot == 2 then
        loc1, loc2, loc3, loc4 =
        {x = cursor.tx - 2, y = cursor.ty - 2},
        {x = cursor.tx + 2, y = cursor.ty - 2},
        {x = cursor.tx + 2, y = cursor.ty + 10},
        {x = cursor.tx - 2, y = cursor.ty + 10}
      else
        loc1, loc2, loc3, loc4 =
        {x = cursor.tx -  2, y = cursor.ty - 2},
        {x = cursor.tx + 10, y = cursor.ty - 2},
        {x = cursor.tx + 10, y = cursor.ty + 2},
        {x = cursor.tx -  2, y = cursor.ty + 2}
      end
      sspr(CURSOR_HIGHLIGHT_CORNER_S, loc1.x, loc1.y, color_keys, 1, 0)
      sspr(CURSOR_HIGHLIGHT_CORNER_S, loc2.x, loc2.y, color_keys, 1, 1)
      sspr(CURSOR_HIGHLIGHT_CORNER_S, loc3.x, loc3.y, color_keys, 1, 3)
      sspr(CURSOR_HIGHLIGHT_CORNER_S, loc4.x, loc4.y, color_keys, 1, 2)
      sspr(SPLITTER_ID, cursor.tx, cursor.ty, 0, 1, 0, cursor.rot, 1, 2)
    elseif cursor.item == 'mining_drill' then
      local found_ores = {}
      local color_keys = {[1] = {0, 2}, [2] = {0, 2}, [3] = {0, 2}, [4] = {0, 2}}
      for i = 1, 4 do
        local pos = DRILL_AREA_MAP_BURNER[i]
        local k = get_key(cursor.tx + (pos.x * 8), cursor.ty + (pos.y * 8))
        local sx, sy = cursor.tx + (pos.x * 8), cursor.ty + (pos.y * 8)
        local tile, wx, wy = get_world_cell(sx, sy)
        if not tile.ore or ENTS[k] then
          color_keys[i] = {0, 5}
        end
      end
      sspr(CURSOR_HIGHLIGHT_CORNER, cursor.tx - 1, cursor.ty - 1, color_keys[1], 1, 0, 0, 1, 1)
      sspr(CURSOR_HIGHLIGHT_CORNER, cursor.tx + 9, cursor.ty - 1, color_keys[2], 1, 0, 1, 1, 1)
      sspr(CURSOR_HIGHLIGHT_CORNER, cursor.tx + 9, cursor.ty + 9, color_keys[3], 1, 0, 2, 1, 1)
      sspr(CURSOR_HIGHLIGHT_CORNER, cursor.tx - 1, cursor.ty + 9, color_keys[4], 1, 0, 3, 1, 1)
      local sx, sy = get_screen_cell(x, y)
      local belt_pos = DRILL_MINI_BELT_MAP[cursor.rot]
      sspr(DRILL_BIT_ID, sx + 0 + (DRILL_BIT_TICK), sy + 5, 0, 1, 0, 0, 1, 1)
      sspr(DRILL_BURNER_SPRITE_ID, sx, sy, 0, 1, 0, 0, 2, 2)
      sspr(DRILL_MINI_BELT_ID + DRILL_ANIM_TICK, sx + belt_pos.x, sy + belt_pos.y, 0, 1, 0, cursor.rot, 1, 1)
    elseif cursor.item == 'stone_furnace' then
      local sx, sy = get_screen_cell(x, y)
      Furnace.draw_sprite(sx, sy, false)
    elseif cursor.item == 'underground_belt' then
      local flip = UBELT_ROT_MAP[cursor.rot].in_flip
      local result, other_key, cells = get_ubelt_connection(cursor.x, cursor.y, cursor.rot)
      trace('result: ' .. tostring(result))
      trace('other_key: ' .. tostring(other_key))
      trace('cells: ' .. tostring(cells))
      if result then
        local sx, sy = world_to_screen(ENTS[other_key].x, ENTS[other_key].y)
        sspr(UBELT_OUT + UBELT_TICK, cursor.tx, cursor.ty, ITEMS[18].color_key, 1, UBELT_ROT_MAP[cursor.rot].out_flip, cursor.rot)
        sspr(CURSOR_HIGHLIGHT, sx - 1, sy - 1, 0, 1, 0, 0, 2, 2)
        for i, cell in ipairs(cells) do
          sspr(CURSOR_HIGHLIGHT, cell.x - 1, cell.y - 1, 0, 1, 0, 0, 2, 2)
        end
      else
        sspr(UBELT_IN + UBELT_TICK, cursor.tx, cursor.ty, ITEMS[18].color_key, 1, flip, cursor.rot)
      end
      sspr(CURSOR_HIGHLIGHT, cursor.tx - 1, cursor.ty - 1, 0, 1, 0, 0, 2, 2)
    elseif cursor.item == 'assembly_machine' then
      sspr(CRAFTER_ID, cursor.tx, cursor.ty, ITEMS[19].color_key, 1, 0, 0, 3, 3)
    elseif cursor.item == 'research_lab' then
      sspr(LAB_ID, cursor.tx, cursor.ty, ITEMS[22].color_key, 1, 0, 0, 3, 3)
    end
  end
  if cursor.type == 'pointer' then
    local k = get_key(cursor.x, cursor.y)
    if ui.active_window and ui.active_window:is_hovered(cursor.x, cursor.y) then
      
    end
    sspr(CURSOR_POINTER, cursor.x, cursor.y, 0, 1, 0, 0, 1, 1)
    if show_tile_widget then sspr(CURSOR_HIGHLIGHT, cursor.tx - 1, cursor.ty - 1, 0, 1, 0, 0, 2, 2) end
  end
end

function rotate_cursor(dir)
  dir = dir or 'r'
  --sfx(3, 'E-5', 10, 0, 15, 3)
  if not cursor.drag then
    cursor.rot = (dir == 'r' and cursor.rot + 1) or (cursor.rot - 1)
    if cursor.rot > 3 then cursor.rot = 0 end
    if cursor.rot < 0 then cursor.rot = 3 end
    local k = get_key(cursor.x, cursor.y)
    local tile, cell_x, cell_y = get_world_cell(cursor.x, cursor.y)
    if ENTS[k] then
      if ENTS[k].type == 'transport_belt' and cursor.type == 'pointer' then
        sound('rotate_' .. dir)
        ENTS[k]:rotate(ENTS[k].rot + 1)
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
      if ENTS[k].type == 'inserter' and cursor.type == 'pointer' then
        sound('rotate_' .. dir)
        ENTS[k]:rotate(ENTS[k].rot + 1)
      end
    end
  elseif cursor.drag and cursor.type == 'item' and cursor.item == 'transport_belt' then
    trace('drag-rotating')
    sound('rotate_' .. dir)
    cursor.rot = cursor.rot + 1
    if cursor.rot > 3 then cursor.rot = 0 end
    cursor.drag_dir = cursor.rot
    --trace('rotated while dragging')
    local tile, wx, wy
    local dx, dy = world_to_screen(cursor.drag_loc.x, cursor.drag_loc.y)
    if (cursor.drag_dir == 0 or cursor.drag_dir == 2) then
      _, wx, wy = get_world_cell(cursor.x, dy)
    elseif (cursor.drag_dir == 1 or cursor.drag_dir == 3) then
      _, wx, wy = get_world_cell(dx, cursor.y)
    end
    -- cursor.rot = cursor.rot + 1
    -- if cursor.rot > 3 then cursor.rot = 0 end
    --cursor.drag_offset = 
    cursor.drag_loc = {x = wx, y = wy}
  end
  if cursor.type == 'item' then sound('rotate_' .. dir) end
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
    elseif ent.type == 'underground_belt' or ent.type == 'underground_belt_exit' then
      remove_underground_belt(x, y)
    elseif ent.type == 'assembly_machine' or ent.type == 'dummy_assembler' then
      remove_assembly_machine(x, y)
    elseif ent.type == 'research_lab' or ent.type == 'dummy_lab' then
      remove_research_lab(x, y)
    end
  elseif not tile.ore then
    TileMan:set_tile(wx, wy)
  end
end

function pipette()
  if cursor.type == 'pointer' then
    local k = get_key(cursor.x, cursor.y)
    local ent = ENTS[k]
    if ent then
      if ent.type == 'dummy_splitter' or ent.type == 'dummy_drill' or ent.type == 'dummy_furnace' or ent.type == 'dummy_assembler' then
        ent = ENTS[ent.other_key]
      end
      cursor.type = 'item'
      cursor.item = ent.type
      cursor.item_stack = {id = ent.item_id, count = 5}
      if ent.rot then
        cursor.rot = ent.rot
      end
      return
    end
  else
    cursor.item = false
    cursor.item_stack = {id = 0, count = 0}
    cursor.type = 'pointer'
  end
end

function update_cursor_state()
  local x, y, l, m, r, sx, sy = mouse()
  local _, wx, wy = get_world_cell(x, y)
  local tx, ty = get_screen_cell(x, y)
  --update hold state for left and right click
  if l and cursor.l and not cursor.held_left and not cursor.r then
    cursor.held_left = true
  end

  if r and cursor.r and not cursor.held_right and not cursor.l then
    cursor.held_right = true
  end

  if cursor.held_left or cursor.held_right then
    cursor.hold_time = cursor.hold_time + 1
  end

  if not l then cursor.held_l = false end
  if not r then cursor.held_r = false end


  --cursor.cl, cursor.cr = l and not cursor.l, r and not cursor.r
  cursor.wx, cursor.wy, cursor.tx, cursor.ty, cursor.sx, cursor.sy = wx, wy, tx, ty, sx, sy
  cursor.lx, cursor.ly, cursor.ll, cursor.lm, cursor.lr, cursor.lsx, cursor.lsy = cursor.x, cursor.y, cursor.l, cursor.m, cursor.r, cursor.sx, cursor.sy
  cursor.x, cursor.y, cursor.l, cursor.m, cursor.r, cursor.sx, cursor.sy = x, y, l, m, r, sx, sy
end

function dispatch_keypress()
  --F
  if key(6) then add_item(cursor.x, cursor.y, 1) end
  --G
  if key(7) then add_item(cursor.x, cursor.y, 2) end
  --M
  if keyp(13) then show_mini_map = not show_mini_map end
  --R
  if keyp(18) then
    if not key(64) then
      rotate_cursor('r')
    else
      rotate_cursor('l')
    end
  end
  --Q
  if keyp(17) then pipette() end
  --I or TAB
  if keyp(9) or keyp(49) then toggle_inventory() cursor.type = 'pointer' end
  --H
  if keyp(8) then toggle_hotbar() end
  --C
  if keyp(3) then toggle_crafting() end
  --Y
  if keyp(25) then debug = not debug end
  --SHIFT
  if key(64) and not keyp(18) and alt_mode then show_tile_widget = true else show_tile_widget = false end
  --ALT
  if keyp(65) then alt_mode = not alt_mode end
  --T
  if keyp(20) then show_tech = not show_tech end
  --0-9
  for i = 1, INVENTORY_COLS do
    local key_n = 27 + i
    --if i == 10 then key_n = 27 end
    if keyp(key_n) then set_active_slot(i) end
  end
end

function dispatch_input()
  update_cursor_state()
  dispatch_keypress()
  if show_tech then

    return
  end


  local k = get_ent(cursor.x, cursor.y)
  if cursor.sy ~= 0 then cycle_hotbar(cursor.sy*-1) end
  if not cursor.l then
    cursor.panel_drag = false
    cursor.drag = false
  end
  
  --begin mouse-over priority dispatch
  if ui.active_window and ui.active_window:is_hovered(cursor.x, cursor.y) then
    if cursor.l and not cursor.ll then
      if ui.active_window:click(cursor.x, cursor.y) then
        trace('clicked active window')
      end
    end
    return
  end
  
  if craft_menu.vis and craft_menu:is_hovered(cursor.x, cursor.y) then
    if cursor.l and not cursor.ll then
      if craft_menu:click(cursor.x, cursor.y, 'left') then return end
    elseif cursor.r and cursor.lr then
      if craft_menu:click(cursor.x, cursor.y, 'right') then return end
    end
    if craft_menu.vis and cursor.panel_drag then
      craft_menu.x = math.max(1, math.min(cursor.x + cursor.drag_offset.x, 239 - craft_menu.w))
      craft_menu.y = math.max(1, math.min(cursor.y + cursor.drag_offset.y, 135 - craft_menu.h))
      return
      --consumed = true
    end
    if craft_menu.vis and not cursor.panel_drag and cursor.l and not cursor.ll and craft_menu:is_hovered(cursor.x, cursor.y) then
      if craft_menu:click(cursor.x, cursor.y) then
        return
      elseif not craft_menu.docked then
        cursor.panel_drag = true
        cursor.drag_offset.x = craft_menu.x - cursor.x
        cursor.drag_offset.y = craft_menu.y - cursor.y
        return
      end
    end
    return
  end
  
  if inv.vis and inv:is_hovered(cursor.x, cursor.y) then
    if cursor.l and not cursor.ll then
      inv:clicked(cursor.x, cursor.y)
    end
    return
  end

    --check other visible widgets
  if cursor.type == 'item' and cursor.item_stack.id ~= 0 then
    local item = ITEMS[cursor.item_stack.id]
    local count = cursor.item_stack.count
    --check for ents to deposit item stack
    if ENTS[k] and ENTS[k].type == 'none' then --TODO
      if cursor.l then
        if ENTS[k]:can_accept(item.id) then
          local result = ENTS[k]:deposit(cursor.item_stack)
        end
      elseif cursor.r then
        remove_tile(cursor.x, cursor.y)
        return
      end
    else

    --if item is placeable, run callback for item type
      if cursor.l and cursor.item_stack.id == 9 then
        --trace('placing belt')
        callbacks[cursor.item](cursor.x, cursor.y)
        return
      elseif cursor.l and not cursor.ll then
        callbacks[cursor.item](cursor.x, cursor.y)
        return
      elseif cursor.r then
        remove_tile(cursor.x, cursor.y)
        return
      end
    end
  end
    --check for held item placement/deposit to other ents
  if cursor.r then remove_tile(cursor.x, cursor.y) return end
  if ENTS[k] then ENTS[k].is_hovered = true end
  if cursor.l and not cursor.ll and not craft_menu:is_hovered(cursor.x, cursor.y) and inv:is_hovered(cursor.x, cursor.y) then
    local slot = inv:get_hovered_slot(cursor.x, cursor.y)
    if slot then
      trace(slot.index)
      inv.slots[slot.index]:callback()
      return
    end
    
    --consumed = true
  end

  if cursor.l and not cursor.ll and ENTS[k] then

    if dummies[ENTS[k].type] then
      k = ENTS[k].other_key
    end

    if opensies[ENTS[k].type] then
      ui.active_window = ENTS[k]:open()
    end

    return
    --consumed = true
  end

  -- cursor.last_tile_x, cursor.last_tile_y = cursor.tx, cursor.ty
  -- cursor.tx, cursor.ty = screen_tile_x, screen_tile_y
  -- cursor.last_rotation = cursor.rot
  -- cursor.left, cursor.middle, cursor.right = left, middle, right
  -- cursor.last_x, cursor.last_y, cursor.last_left, cursor.last_mid, cursor.last_right = cursor.x, cursor.y, cursor.left, cursor.middle, cursor.right
  -- cursor.x, cursor.y = x, y
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

function toggle_crafting(force)
  if force then craft_menu.vis = true else craft_menu.vis = not craft_menu.vis end
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
      if vis_ents[v.type] then
        v:update()
      end
    end
  end
end

function draw_ents()
  for i, k in pairs(vis_ents['transport_belt']) do
    if ENTS[k] then ENTS[k]:draw() end
  end
  for i, k in pairs(vis_ents['transport_belt']) do
    --trace('drawing belt items')
    if ENTS[k] then ENTS[k]:draw_items() end
  end
  for i, k in pairs(vis_ents['stone_furnace']) do
    --trace('DRAWING ENT - k: ' .. tostring(k) .. ', VALUE: ' .. tostring(ent.type))
    if ENTS[k] then ENTS[k]:draw() end
  end
  for i, k in pairs(vis_ents['underground_belt']) do
    --trace('DRAWING ENT - k: ' .. tostring(k) .. ', VALUE: ' .. tostring(ent.type))
    if ENTS[k] then ENTS[k]:draw() ENTS[k]:draw_items() end
  end
  for i, k in pairs(vis_ents['splitter']) do
    --trace('DRAWING ENT - k: ' .. tostring(k) .. ', VALUE: ' .. tostring(ent.type))
    if ENTS[k] then ENTS[k]:draw() end
  end
  for i, k in pairs(vis_ents['mining_drill']) do
    --trace('DRAWING ENT - k: ' .. tostring(k) .. ', VALUE: ' .. tostring(ent.type))
    if ENTS[k] then ENTS[k]:draw() end
  end
  for i, k in pairs(vis_ents['assembly_machine']) do
    if ENTS[k] then ENTS[k]:draw() end
  end
  for i, k in pairs(vis_ents['research_lab']) do
    if ENTS[k] then ENTS[k]:draw() end
  end
  for i, k in pairs(vis_ents['inserter']) do
    if ENTS[k] then ENTS[k]:draw() end
  end
  for i, k in pairs(vis_ents['power_pole']) do
    if ENTS[k] then ENTS[k]:draw() end
  end
end

function draw_belt_items()
  for k, ent in pairs(vis_ents) do
    if ent.type == 'transport_belt' and not ent.drawn then
      ent:draw_items()
    end
  end
end

function draw_terrain()
  TileMan:draw_terrain(player, 31, 18)
end

function draw_tile_widget()
  local x, y = cursor.x, cursor.y
  local tile, wx, wy = get_world_cell(x, y)
  local tile_type = tile.ore and ores[tile.ore].name or tile.is_land and 'Land' or 'Water'
  local biome = tile.is_land and biomes[tile.biome].name or 'Ocean'
  local info = {
    [1] = 'Biome: ' .. biome,
    [2] = 'Type: ' .. tile_type,
    [3] = 'X,Y: ' .. wx .. ',' .. wy,
    [4] = 'Noise: '  .. tile.noise
  }
  ui.draw_text_window(info, x + 5, y + 5, 'Scanning...')
end

function lapse(fn, ...)
	local t = time()
	fn(...)
	return floor((time() - t))
end

spawn_player()

function TIC()
  if not loaded then
    load_sprites()
    return
  end
  local start = time()
  TICK = TICK + 1
  update_water_effect(time())
  --change mouse cursor
  poke(0x3FFB, 286)
  cls(0)

  local gv_time = lapse(get_visible_ents)
  --local m_time = lapse(draw_terrain)
  local m_time = lapse(draw_terrain)
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
    for y = 0, 3 do
      set_sprite_pixel(490, 0, y, floor(math.random(2, 4)))
      set_sprite_pixel(490, 1, y, floor(math.random(2, 4)))
    end
    if FURNACE_ANIM_TICK > FURNACE_ANIM_TICKS then
      FURNACE_ANIM_TICK = 0
    end
  end

  local ue_time = lapse(update_ents)
  --draw_ents()
  local de_time = lapse(draw_ents)

  -- for k, v in pairs(ENTS) do
  --   v.updated = false
  --   v.drawn = false
  --   v.is_hovered = false
  --   if v.type == 'transport_belt' then v.belt_drawn = false; v.curve_checked = false; end
  -- end
  --TileMan:draw_clutter(player, 31, 18)
  local dcl_time = 0
  if not show_mini_map then
    local st_time = time()
    TileMan:draw_clutter(player, 31, 18)
    dcl_time = floor(time() - st_time)
  end
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

  if show_tile_widget then draw_tile_widget() end

  inv:draw()
  --inv:draw_hotbar()
  craft_menu:draw()
  if ui.active_window then
    if ENTS[ui.active_window.ent_key] then
      ui.active_window:draw()
    else
      ui.active_window = nil
    end
  end

  --draw_cursor()

  local info = {
    [1] = 'draw_clutter: ' .. dcl_time,
    [2] = 'draw_terrain: ' .. m_time,
    [3] = 'update_player: ' .. up_time,
    [4] = 'handle_input: ' .. hi_time,
    [5] = 'draw_ents: ' .. de_time,
    [6] = 'update_ents:' .. ue_time,
    [7] = 'draw_cursor: ' .. dc_time,    
    --[8] = 'draw_belt_items: ' .. db_time,
    [8] = 'get_vis_ents: ' .. gv_time,
  }
  --draw_debug_window(info)
  local ents = 0
  for k, v in pairs(vis_ents) do
    for _, ent in ipairs(v) do
      ents = ents + 1
    end
  end

  info[9] = 0
  if show_mini_map then
    local st_time = time()
    TileMan:draw_worldmap(player, 70, 18, 75, 75, true)
    pix(121, 69, 2)
    info[9] = 'draw_worldmap: ' .. floor(time() - st_time) .. 'ms'
    --info[10] = 'map_rects: ' .. TileMan:optimize_minimap(player, 0, 0, 238, 134)
    --info[10] = 'map_rects: ' .. TileMan:draw_worldmap(player, 240, 136)
  end

  local tile, wx, wy = get_world_cell(cursor.x, cursor.y)
  local sx, sy = get_screen_cell(cursor.x, cursor.y)
  local k = get_key(cursor.x, cursor.y)
  info[10] = 'Frame Time: ' .. floor(time() - start) .. 'ms'
  info[11] = 'Seed: ' .. seed
  --function ui.draw_text_window(data, x, y, label, fg, bg, text_fg, text_bg)
  local k, u = get_ent(cursor.x, cursor.y)
  if k and alt_mode and ENTS[k] then
    -- if ENTS[k].other_key then
    --   k = ENTS[k].other_key
    -- end
    if u then
      ENTS[k]:draw_hover_widget(ENTS[k].other_key)
    else
      ENTS[k]:draw_hover_widget()
    end
  end
  for k, v in pairs(ENTS) do
    v.updated = false
    v.drawn = false
    v.is_hovered = false
    if v.type == 'transport_belt' then v.belt_drawn = false; v.curve_checked = false; end
  end
  if show_tech then draw_research_screen() end
  if debug then ui.draw_text_window(info, 2, 2, _, 0, 2, 0, 4) end
  --ui.draw_panel(70, 18, 50, 75, 8, 9, 'Crafting')
  --ui.draw_grid(10, 10, 5, 5, 8, 9, 9)
  --draw_item_stack(0, 0, {id = 4, count = TICK%45})
end

-- <TILES>
-- 000:4444444444444444444444444444444444444444444444444444444444444444
-- 001:7544447677544765677475774777677444767744444234444443344444423444
-- 002:4444444444cdcc444dcdcdc4dcdcdcdccddbbdcd4cddddc444cccc4444444444
-- 003:4774444474474444474744444447647444474747444767444467474444474764
-- 004:44444444444444444444444444444b444444bab444444b444444474444444444
-- 005:4647774444762764477232774767276746776777447777744447764644444444
-- 006:4444444445444444447454444474744444747444444444444444444444444444
-- 007:444444444444444444eddd444eddddd44ccdcdc444fcce444444444444444444
-- 008:44444444444444444444de444444cdc444444cd4444444444444444444444444
-- 009:4444444d44b444444bbd4444444bd4444444bd444d444bb444444b4444444444
-- 010:4444444444cccc444cccccc44c0c0cc44cceccc444cccc4444dede4444444444
-- 011:0000000000044000004444000444444004444440004444000004400000000000
-- 012:0000000044000404044444444444044444444444444444444444444444444444
-- 013:0000000000000044000004440000440400004444004444440404444404444444
-- 014:0000000000000000000000000000000000000000004444000444444044444444
-- 015:0404444004444440004444044044440000404400044444400044440404444440
-- 016:6666666666666666666666666666666666666666666666666666666666666666
-- 017:6666636666667666766476666767766767677676676776766666666666666666
-- 018:6666666666d666666d2d66d666d66d2d667666d6667666766666666666666666
-- 019:6666666666666666667666666677666666776676667767666666676666666666
-- 020:6676666667566666765666667664666676666766666665766666656766663667
-- 021:66666666666666666666666666666b666666bab666666b666666676666666666
-- 022:6669666666949666666866666667666666676666666766666666666666666666
-- 023:622666662b226666222266666cd666666cc66666666666666666666666666666
-- 024:66666666666cd66666edc66666dc666666666666666666666666666666666666
-- 025:6666666666666666666666666666666666666666666666666666666666666666
-- 026:666666666666666666cddd666eddddd66ccdcdc666ccce666666666666666666
-- 027:4444444444466444446666444666666446666664446666444446644444444444
-- 028:4444444466444646466666666666466666666666666666666666666666666666
-- 029:4444444444444464444446664444664644466666446466664466666646666666
-- 030:4444444444444444444444444444444444444444446666444666666466666666
-- 031:4646666446666664446666466466664444646644466666644466664646666664
-- 032:7777777777777777777777777777777777777777777777777777777777777777
-- 033:7777777777777777767777777767776776677667766776677767767777777777
-- 034:7777777777767777767767777767677677676767776767677767676777777777
-- 035:7777777776777777776777777756777667567767766675677756566777665667
-- 036:7726777772327777772647777774547777764777775677777776777777777777
-- 037:7777777777677777762677777767777777777777777776777777636777777677
-- 038:7777777777777777777777777777777777777777777777777777777777777777
-- 039:7777777777777777777777677767767676767677777676777776767777777777
-- 040:777777777777777777eddd777eddddd77ccdcdc777fcce777777777777777777
-- 041:7777777777777777777777777777777777777777777777777777777777777777
-- 042:7777777777ddcdd77dcdddccddddcccdcddccdcefecceeef7ffffff777777777
-- 043:6666666666677666667777666777777667777776667777666667766666666666
-- 044:6666666677666767677777777777677777777777777777777777777777777777
-- 045:6666666666666676666667776666776766677777667677776677777767777777
-- 046:6666666666666666666666666666666666666666667777666777777677777777
-- 047:6777767667777776767777666677776766776766677777767677776667777776
-- 160:4ce4ce44cdd4edc4dec44cf4444444444ecd4de4edf44ece4ee4ecdc444444e4
-- 161:c2111121342f331133f144f112c142f1111111111431142ff323132f1d2f1f11
-- 162:4ce4cf448bd4fdb48ee448f444444444edcb4ff4fc8e48cf4ff4ffbc44444ef4
-- 163:4400400440fe40ef400f44f0440444444044440f000e40f00ef040e44f044444
-- 164:45646f44f75457f4f66f45f4444444444f544f546575456ff7764f754ff444f4
-- 165:41f40f440114f114410141f4444444440f104104f11f411f410411f0444440f4
-- 176:dc444444ccd444444ee444444444444444444444444444444444444444444444
-- 177:1341111144211111231111111111111111111111111111111111111111111111
-- 178:be444444cd8444444cd444444444444444444444444444444444444444444444
-- 179:4f0444440e044444f04444444444444444444444444444444444444444444444
-- 180:4574444477544444f74444444444444444444444444444444444444444444444
-- 181:4ff4444411144444ff4444444444444444444444444444444444444444444444
-- 194:0077777707556556756666667666666666677777677000007007777700756555
-- 195:0000000077000000657000076657007576657655776667567076755657576760
-- 196:0777700075755700555755705666666766777767677000760000000077770000
-- 198:0000000000000000000000000000000000000005000005560000556600005556
-- 199:0000000000000000000000005555500056665555666566666666666566676666
-- 200:0000000000000000000000000000000050000000550000005550000066550000
-- 201:0000000000000000000000000000000500000055000005550000555600006567
-- 202:0000000000000000054444445555544455555545567655557667676766765676
-- 203:0000000000000000000000004000000055000000565000007556000067755000
-- 204:0000000000000000000050000057770000077700000757000007775000077700
-- 205:0507700000777700077775700577777507777770077757700777777057577770
-- 210:0766666675666777766777777677770076670000076000000770000000700000
-- 211:6677777770723766002333700002300000023000000232000002330000023300
-- 212:6767770076766700776676700777667000077667000007670000007700000000
-- 214:0005666500566666067676666776776666777767006672770000662600000002
-- 215:6677666667777666676267666626777762677766722277766233667702336776
-- 216:6665000066550000765555006666655066667600666676006667600037760000
-- 217:0000067600000076000000070000000000055560005556560055666500556662
-- 218:6766766776723363676233036662333300022300600223006602330060023300
-- 219:6675600037560000666000000000000000000000006000000556000055666000
-- 220:0007777700057777000077750000050000000000000000000000000000000000
-- 221:7777767077777776777677707777777007777770067776700777777707776777
-- 222:0005000000777500007770000075700005777000000770000077000075775000
-- 224:9999999999899989999999999999999999999999999899999899989999999999
-- 227:0000233000002330000023300000232000002330000023300002333000023300
-- 230:0000000200000000000000000000000000000000000000000000000000000000
-- 231:2233666322330036022333000233300002330000023300000233000002330000
-- 232:7660000060000000000000000000000000000000000000000000000000000000
-- 233:0005566600000556000000000000000000000000000000000000000000000000
-- 234:2202330602223300000223330002333000023300000233000002330000023300
-- 235:5365660035666000055500000000000000000000000000000000000000000000
-- 237:0757767707777776077677706777777507777770067776700777777067776770
-- 238:7770000000000000000000000000000000000000000000000000000000000000
-- 243:0002230000023300000233000002330000023300002333000022330000233200
-- 246:0000000000000000000000000000000000000000000000000000000000000002
-- 247:0223000002330000023300000233000002330000023300002233300022333300
-- 250:0002330000023300000223000002330000023300000233000022333002223333
-- 253:0776757607777770076777600777777007777776075767706777777007677770
-- </TILES>

-- <TILES1>
-- 010:cdeeeeeed000dddde00c32eee00d232de00c323cd00d23eee000eccce000c000
-- 011:eeeeeedcdddd000deeeee00ecdcdc00edcdcd00eeeeee00dccce000e000c000e
-- 012:111111111111f441111143f411114f34111114411ff11441f44f1441f444f44f
-- 013:11111f441111f4414443441144434411111114411ff11144f44f1dff444fdeef
-- 014:4f1111111111111111111111111111111111111141111111df111111fdf11111
-- 026:fddddddde0000000ddd00000ff4c0000f4feceecff4c0000ddd00000cdeeeeee
-- 027:ddddddde0000000e0000000d0000000eceecceed0000000e0000000deeeeeedc
-- 028:1f44433411f4f44f11f4f44f11f44ff4111f444d1111f4df1111f4df1111144d
-- 029:44fdeeee4fdffe444dffffeedeeffffeeeeefffffe4440ffffee40fffffe40ef
-- 030:ffdf111140fdf11140ffdf1140efdf11eeedf111fedf1111fdf11111df111111
-- 044:11111fff11111111111111111111111111111111111111111111111111111111
-- 045:dfffeeedfdfffedf1fdffdf111fddf11111ff111111111111111111111111111
-- 046:1111111111111111111111111111111111111111111111111111111111111111
-- </TILES1>

-- <SPRITES>
-- 000:ffffffffeeeeeeee4fdd4fddfdd4fdd4fdd4fdd44fdd4fddeeeeeeeeffffffff
-- 001:ffffffffeeeeeeeefdd4fdd4dd4fdd4fdd4fdd4ffdd4fdd4eeeeeeeeffffffff
-- 002:ffffffffeeeeeeeedd4fdd4fd4fdd4fdd4fdd4fddd4fdd4feeeeeeeeffffffff
-- 003:ffffffffeeeeeeeed4fdd4fd4fdd4fdd4fdd4fddd4fdd4fdeeeeeeeeffffffff
-- 004:00ffffff0feeeeeefeed4fddfed4fdd4fed4fdd4fedd4fddfefddfdefe4ff4ef
-- 005:00ffffff0feeeeeefeddddd4fefddf4ffe4ff44ffed44dd4fedddddefefddfef
-- 006:00ffffff0feeeeeefeeddd4ffeddd4fdfefdd4fdfe4ff44ffed44ddefeddddef
-- 007:00ffffff0feeeeeefeedd4fdfedd4fddfedd4fddfefdf4fdfe4ff4defed44def
-- 008:ffffffd1fffffd11ffffd11fdddd11ff111111ffffff111ffffff111ffffff1d
-- 009:ffffffff44ffffff004fffffff044434ff044434004fffff44ffffffffffffff
-- 010:ff04fffffff04fff0ff04fff40004ffff44444ffffff444ffffff444ffffff44
-- 011:0000000099000000009000000009999300f99939ff9000009900000000000000
-- 012:0009000000009000f00090009fff900009999900000099900000093900000093
-- 013:0000008a000008980000888fc88888f0c8888800000088800000f89800000f8a
-- 014:00000000000f000000fc00000fcffff00cccccc000cf0000000c000000000000
-- 015:00dddd00020000d0d020000dd002000dd000200dd000020d0d00002000dddd00
-- 016:3000000300000000000000000000000000000000000000000000000030000003
-- 017:ccddccddc0000000d0000000d0000000cf000000cedddddddf000000d0000000
-- 018:ddccddcc0000000c0000000d0000000d000000fcddddddec000000fd0000000d
-- 019:000f0000000d00000defed0000def000000d0000000000000000000000000000
-- 021:0002000000002000f00020002fff200002222200000022200000022200000022
-- 022:0000000000000000000000000000000000000000000000000000000020000000
-- 023:02f00f2002f00f20002ff2000002200000033000000220000002200000022000
-- 024:6560000034500000654000000000000000000000000000000000000000000000
-- 025:0300000034300000030000000000000000000000000000000000000000000000
-- 027:44444444444ef04444f000444400f0044f000004400f00f444f00f4444444444
-- 028:0000000004300980032408fd003300e800000000003300ed03240efe04300dd0
-- 029:000000000e0d00000eff00000de0000000000000000000000000000000000000
-- 030:b0000000bb000000bbc00000bde0000000000000000000000000000000000000
-- 031:0000000000300000034000003433333344444444040000000040000000000000
-- 032:3030303000000003300000000000000330000000000000033000000003030303
-- 033:d0000000d0000000c0000000c0000000d0000000d0000000c0000000ccddccdd
-- 034:0000000d0000000d0000000c0000000c0000000d0000000d0000000cddccddcc
-- 035:000000000fcccc000fc0fc000fcccce00fcccce00fcccc00fcccccc000000000
-- 036:00000000d00cd00decccccce000dd000000ee000000110000001100000011000
-- 037:0000000200000000000000000000000000000000000000000000000000000000
-- 038:2200000022200000022200000023200000023000000000000000000000000000
-- 039:0002200000022000000220000002200000022000000220000002300000032000
-- 040:2210000034200000124000000000000000000000000000000000000000000000
-- 041:0ed00000efe00000dd0000000000000000000000000000000000000000000000
-- 042:fe000000efd000000ef000000000000000000000000000000000000000000000
-- 043:bccfffffcccfffffccdfffffffffffffffffffffffffffffffffffffffffffff
-- 044:433fffff333fffff334fffffffffffffffffffffffffffffffffffffffffffff
-- 045:000fffff00fcdfee0fe43fcdfd43dfd4fc43cfd4fdc43fcdfcdcfeee0fffffff
-- 046:000fffff00fcdfee0fe21fcdfd21dfd2fc21cfd2fdc21fcdfcdcfeee0fffffff
-- 047:000fffff00fcdfee0fea9fcdfda9dfd9fca9cfd9fdca9fcdfcdcfeee0fffffff
-- 048:0000000000000000ddd00000f4ec00004ff4c000f4ec0000ddd0000000000000
-- 049:0000000000000000ddd000004fec0000ff4ec0004fec0000ddd0000000000000
-- 050:0000000000000000ddd00000ff4c0000f4fec000ff4c0000ddd0000000000000
-- 051:5252525020000000500000002000000050000000200000005000000000000000
-- 052:0001100000011000000110000001100000011000000110000001100000011000
-- 053:3030303000000000300000000000000030000000000000003000000000000000
-- 054:3000000003000000000000000300000000000000030000000000000003000000
-- 056:00000000000ccccc00cfcfff0cccfddd0ccfdfff0cdfdfef0cdfdfff0ccfdccc
-- 057:00000000ccccccccffffffffddddddddccfffccfccfefccfccfffccfcccccccc
-- 058:00000000ccccc000fffcfc00dddfccc0ffcdfcc0efcdfdc0ffcdfdc0cccdfcc0
-- 060:00ed0e00edfddfd0efdeedfe0dedfeddddefded0efdeedfe0dfddfde00e0de00
-- 061:111111111111111111111f441111143f111114f31111114411ff11441f44f144
-- 062:11111111111111f411111f4444443441444434411111114411ff11141f44f1df
-- 063:1111111144f111111111111111111111111111111111111144111111fdf11111
-- 064:00c0000000c0000000ccc000c0ccc0000cccc00000dd00000000000000000000
-- 065:000000000cc000000ccc0000cccc0000cccc00000dd000000000000000000000
-- 066:000efffe000fccdf00f4dde00f4defd00f4dfed000f4dde0000fccf0000fccff
-- 068:0001100000011000000cd000000dc000000ce000000cd0000000000000000000
-- 069:3000000003030303000000000000000000000000000000000000000000000000
-- 070:0000000003000000000000000000000000000000000000000000000000000000
-- 072:0ccfdfff0cdfffee0cdfcfff0ccfdddd0ccfdddc0cdfedec0ccfcccc0ccfceec
-- 073:ffffffffeeeeeeeeffffffffccccccccffffffffffffffffffffffffffffffff
-- 074:fffdfcc0eefffdc0fffcfdc0ddddfcc0cdddfcc0cedefdc0ccccfcc0ceecfcc0
-- 075:0cccccc0cececedccdffffdccfeeeefccdffffdccddeedddcddeeddc0cccccc0
-- 077:1f444f4411f44433111f4f44111f4f44111f44ff1111f44411111f4d11111f4d
-- 078:f444fdee444fdeeef4fdffe4f4dffffe4deeffffdeeeefffffe4440ffffee40f
-- 079:ffdf1111effdf111440fdf11e40ffdf1e40efdf1feeedf11ffedf111ffdf1111
-- 080:1212000020560000150000002600000000000000000000000000000000000000
-- 081:10bbb1110beceb110becdb110beeeb1110bbb111111111111111111111111111
-- 082:000fccff000fccf000f4dde00f4dfed00f4defd000f4dde0000fccdf000efffe
-- 083:ff0fff0f888888884888488888848884888488844888488888888888ff0fff0f
-- 084:fff0fff0888888888884888488488848884888488884888488888888fff0fff0
-- 085:0fff0fff8888888888488848848884888488848888488848888888880fff0fff
-- 086:f0fff0ff888888888488848848884888488848888488848888888888f0fff0ff
-- 088:0cdfcddc0cdfceec0cdfceec0cddfccc0cdddffe00cddddd000ccccc00000000
-- 089:ffffffffffffffffffffffffffffffffccccccccdcddddcdcccccccc00000000
-- 090:cddcfdc0ceecfdc0ceecfdc0cccfddc0effdddc0dddddc00ccccc00000000000
-- 093:11111144111111ff111111111111111111111111111111111111111111111111
-- 094:dfffe40efdfffeee1fdfffed11fdffdf111fddf11111ff111111111111111111
-- 095:fdf11111df111111f11111111111111111111111111111111111111111111111
-- 096:0011110001111100111888001188880011888800118888000000000000000000
-- 099:000fff0f0f888888f8884888f884888408848884f8884888f8888888f848848f
-- 100:ff0fff0f888888884888488888848884888488844888488888888888ff0fff0f
-- 101:000fff0f0f888888f8884888f884888408848884f8884888f8888888f848848f
-- 102:00f0fff00f888888f888888408888848f8488448f8844884f888888808888880
-- 103:00ff0fff0f88888808888848f8888488f8888488f848844808844888f888888f
-- 104:00fff0ff00888888f8888488f8884888f888488808888488f8488488f884488f
-- 106:00fddf0d0fc77cfc0c7657c00ce77ec00decced002ceec20200dd00200300300
-- 107:00fddf000fcee7f00dee76500deee7700cdccec0003ee2d0030d200d00020000
-- 108:000fff0002fecef020dc75ef0dccc7cf0dceccefcedccdf00cedd02000c00200
-- 109:00feef000feccef00dceecd0ecdccdce0d2dd2d002deed202003300200300300
-- 110:00300300200330022cdeedc202cddc20ecdccdc00dc77cd00f7557f000feef00
-- 112:ccffffffcdf00000ff000000f0000000f0000000f0000000f0000000f0000000
-- 113:fcccccff00cdc000000e0000000c0000000e0000000c0000000e0000000c0000
-- 114:ffffffcc00000fdc000000ff0000000f0000000f0000000f0000000f0000000f
-- 117:000fffff00fcdfee0fe43fcdfd43dfd4fc43cfd4fdc43fcdfcdcfeee0fffffff
-- 118:000fffff00fcdfee0fe43fd4fd43df4ffc43cf4ffdc43fd4fcdcfeee0fffffff
-- 119:000fffff00fcdfee0fe43f4ffd43dffcfc43cffcfdc43f4ffcdcfeee0fffffff
-- 120:000fffff00fcdfee0fe43ffcfd43dfcdfc43cfcdfdc43ffcfcdcfeee0fffffff
-- 122:00000000000000000000000000ffff000ffffff00ffffff000ffff0000000000
-- 123:00000000000000000000000000ffff000ffffff00ffffff000ffff0000000000
-- 124:000000000000000000000000000ff00000ffff0000ffff00000ff00000000000
-- 125:00000000000000000000000000000000000ff00000ffff00000ff00000000000
-- 126:0000000000000000000000000000000000000000000ff0000000000000000000
-- 128:f0000000f0000000f00000d0f0000de0f000defdf0000ff0f00000e0f0000000
-- 129:000e0000000c0000000e0000000c0000ddcedddd000c0000000e0000000c0000
-- 130:0000000f0000000fe000000fff00000ffed0000fed00000fd000000f0000000f
-- 136:00000000000000000000000000cccc000cfefed00cfefbc00eddbffc0eeebffc
-- 137:00000000000000000ee00000effe0000feef0000ffff0000effeeb4deeeebb3d
-- 138:000000000000000000000000000000000000000000000000ddd00000ddded000
-- 140:0000000d00000dbb000ecbbb00eccbb900cbbab90cccaabc0cc9acbb0ddcbbbb
-- 141:cbbbbbcdbbbcbbbbbbbbb9cb9abbbccc9bbccaaabb9cc989a98abc8bbbcaacbb
-- 142:d0000000ddd00000b9cdd000bb8ddd00cbcdcd00bbdddcd0b9d8ddd099d88de0
-- 143:00bbbd000bbbbbc0ccbbccdcc9acb9dfd9caccdfdcaad9efe9dc9d8f0e9ee8f0
-- 144:f0000000f0000000f0000000f0000000f0000000ff000000cdf00000ccffffff
-- 145:000e0000000c0000000e000000ccc00000d4d0000dfffd000d4f4d00fdf4fdff
-- 146:0000000f0000000f0000000f0000000f0000000f000000ff00000fdcffffffcc
-- 150:0000000000c423320c43cdcc0ccccdcd0dc432330d4221220c31cccc0c21deee
-- 151:00000d003000d0d03323edf0feedeef02332eff01221eef0eddceffddddceefd
-- 152:0feeccce0fffcdde0999caca9889aaca9cccc9999ddd99999ceeeeee8ceeeeee
-- 153:ddeebd2ddddeee2eeddeeeeeeeeebbc4eeeebcc3ffffffffdddddddddddddddd
-- 154:edeeed00eeefee00eedfee00ddefe000eeeedd00ffdffd00dddfe000ffdfe000
-- 156:ddd9cbcadd89ccccdd8cc99cdecca9acedee9a9cdeefccbce8fc89cef88c999e
-- 157:ccbbbbc9aaaacdcdaaabbccd99bbaadacbbaaac9dbaaaadaecaaaacdffccdcdd
-- 158:888d88df989d8deedd8dceef98dddffe99ddffff9cdeeeffcd8e88ffa89e88ff
-- 160:cec00000efe00000cec000000000000000000000000000000000000000000000
-- 161:4310000000400000431000000000000000000000000000000000000000000000
-- 162:e4f000004df00000d4f000000000000000000000000000000000000000000000
-- 163:000ff00000cffe0000cdde0004deed200433232044222222432ff212432ff212
-- 164:ccc000dec33233dee2cdccdedefdccbceeffeefddefe34eddefdddd00dd00000
-- 165:0ccc00000dddedd099bbeb4c99daec3d89a9edde88eecce0c8ec33ce0cefccfe
-- 166:0ecdefee0deefffc0edeefc30deeffc20edeefcc0deefddd0deed00000dd0000
-- 167:eeeeccdfcccfeeff232ceefd342ceefdcccceed0dddddd000000000000000000
-- 168:8d888dfe0d88dfff0de8dffecee0dfffeccdfffe0eedffff000dfffe00000000
-- 169:fffffffefccccccfc343343cc344443cc222222cfccccccffffffffe00000000
-- 170:ffdff000fffdf000fffdf000fffdf000ffffd000ffffd000ffffd00000000000
-- 172:0e8d89d90fefedd800ffff980000ffe8000000ff000000000000000000000000
-- 173:faaaa8dd9d8998ed98d88e8a88fee888ffeddeff000000000000000000000000
-- 174:da8e8ff0eeffeff08effff00efff0000ff000000000000000000000000000000
-- 176:0d000000cec000000d0000000000000000000000000000000000000000000000
-- 177:0f4d000000fc00000f4d00000000000000000000000000000000000000000000
-- 178:f4f000004cd00000f4f000000000000000000000000000000000000000000000
-- 179:fdffffffdbdfffffbfbfffffbbbfffffbbbfffffffffffffffffffffffffffff
-- 180:fbffffffbdbfffffdfbfffffbbbfffffbbbfffffffffffffffffffffffffffff
-- 181:22222fff20202fff22022fff20202fff22222fffffffffffffffffffffffffff
-- 182:fffff000eefdcf004ffe43f0fcf43ddffcf43ccf4ffc43dfeeefcdcffffffff0
-- 183:fffff000eefdcf00fcfe43f0cdf43ddfcdf43ccffcfc43dfeeefcdcffffffff0
-- 184:fffff000eefdcf00cdfe43f0d4f43ddfd4f43ccfcdfc43dfeeefcdcffffffff0
-- 185:fffff000eefdcf00d4fe43f04ff43ddf4ff43ccfd4fc43dfeeefcdcffffffff0
-- 188:0200000032200000212000000000000000000000000000000000000000000000
-- 189:0700000057700000767000000000000000000000000000000000000000000000
-- 190:0f0000004ff00000f6e000000000000000000000000000000000000000000000
-- 191:09000000a9900000989000000000000000000000000000000000000000000000
-- 192:fffc0fffffccc0fffcbccc0fccccccc0fccccc0fffccc0fffffc0fffffffffff
-- 193:fff30fffff3330fff343330f33333330f333330fff3330fffff30fffffffffff
-- 194:ffffffffffcc0ffffccdc0fffcdcdc0fffcdcdc0fffcdcc0ffffcc0fffffffff
-- 195:0ffffff003334430034434400ffffff003334430043443400000000000000000
-- 196:00ed0e00edfddfd0efdeedfe0dedfeddddefded0efdeedfe0dfddfde00e0de00
-- 197:0000000000003f00003003f003f303f003f303f003fff3f000333f0000000000
-- 198:000000000c0d00000d0c00000d0d00000c0d00000c0c00000d0d000000000000
-- 199:000000000cd00000cccd00000cccd00000cccd00000cccd00000cd0000000000
-- 200:0666666734444466666664663444644466646666006444440066666600000000
-- 201:0222222134444422222224223444244422242222002444440022222200000000
-- 202:0999999834444499999994993444944499949999009444440099999900000000
-- 203:0ccccccd344444ccccccc4cc3444c444ccc4cccc00c4444400cccccc00000000
-- 204:000dd000000ee000000cc00000d32d000d3222d00c2232c00d2222d000dd3d00
-- 205:000dd000000ee000000cc00000d56d000d5666d00c6656c00d6666d000d77d00
-- 206:000dd000000ee000000dd00000dffc000cf4ffc00dffffc00dffffe000cddc00
-- 207:000dd000000ee000000cc00000da9d000d8998d00c9999c00d99a9d000d89d00
-- 208:3334444331222223323333433222334332332223101111211022222111111111
-- 209:cccccccccf88888cc823ccdcc83ccc4cc8ccc34cf0ffff82f08888811fffff11
-- 210:ccccccccc8f8f8fcfa8a8a8fca8a8a8ccccccccc8f0f0f088f0f0f0888888888
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
-- 224:0b000000cbb00000bdb000000000000000000000000000000000000000000000
-- 225:0400000054400000464000000000000000000000000000000000000000000000
-- 226:0007000000777000007570000757770007777700077777000077700000000000
-- 227:0cccccc0cececedccdffffdccf7777fccdffffdccddeedddcddeeddc0cccccc0
-- 228:00ffffff0fedfeeefcd4fecdfd4ffed4fd4ffed4fcc4fecdfdecfeee0fffffff
-- 229:000fffff00fccfee0fd21fcdfd21cfd2fd21cfd2fcd21fcdfcccfeee0fffffff
-- 230:000fffff00fccfee0fda9fcdfda9cfd9fda9cfd9fcda9fcdfcccfeee0fffffff
-- 231:deecceedefdffffeedcdffdeedcdfdceec2cffdee232ccceecdc4f4edeeef4fd
-- 232:66666cff66666cf06666fcf06666fcff666cfcee666cfeee664cffff664ce000
-- 233:ff0666660ff666660f006666fff06666ee0fe666eee0e666ffffe266000fe266
-- 240:000dd000000ee000000cc00000dbbd000dcbbbd00cbbcbc00dbbbbd000ddcd00
-- 241:000dd000000ee000000cc00000d54d000d5444d00c4454c00d4444d000d5dd00
-- 244:004ecd0004eeede0004ecde0000dcd00000dcd00004ecde004eeede0004ecd00
-- 245:002ecd0002eeede0002ecde0000dcd00000dcd00002ecde002eeede0002ecd00
-- 246:009ecd0009eeede0009ecde0000dcd00000dcd00009ecde009eeede0009ecd00
-- 247:666ff66666cffe6666cdde6664deed266433232644222222432ff212432ff212
-- 248:644cedde644eddde444e1122443233ee443233e043222ee043233ec066233ec0
-- 249:eddfe226edddf2262211f222ee3321220e3321220ee221120ce332120ce33266
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
-- 013:111111ec111111ce111111c6111111d5111111c6111111d611111d761111d666
-- 014:ce111111ec1111116c1111115d1111116c1111116d11111167d11111665d1111
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
-- 029:111d5665111d666611d6566511d5656611d65656111c75661111d77511111cdd
-- 030:6666d1116666d11166566d1166666d1165666d116667c111777d1111ddc11111
-- 032:000000000000000c000000dd00000ded00000decddd00de0f4eccdc04ff4cddd
-- 033:00000000c0000000dd000000ced00000ded000000ed000000cdc0000ddddc000
-- 048:f4ecec0dddcdec0d00dec00d0cdec00d0dec0fefcdec00fedec0000fdec00000
-- 049:e0cedc00e0cedc00e00ced00e00cedc0cf00ced0f000cedc00000ced00000ced
-- </SPRITES1>

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
-- 000:02000200020002000200020002000200020002000200020002000200020002000200020002000200020002000200020002000200020002000200020030b000000000
-- 001:8000800080009000a000c000e000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000220000000000
-- 002:090009000900090009000900090009000900090009000900090009000900090009000900090009000900090009000900090009000900090009000900a00000000000
-- 003:050005100520153025504560659085b095f0a5f0b5f0c5f0d5f0e5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0414000000000
-- 004:00ec00c170a4f076f037f00ff00df00af008f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000a0b000000000
-- 005:34073407340734073407f400f400f400f400040704070407040704070407040704070407040704070407040704070407040704070407040704070407200000000000
-- 006:09000900090009000900090009000900090009000900090009000900090009000900090009000900090009000900090009000900090009000900090030b000000000
-- 007:05f025b04590656075409530a520b510c500e500e500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500404000000000
-- 008:00e800c970aaf07cf03ef00ff00ff000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000a0b000000000
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
-- 000:00000000000000001000000000000000000000000000000010000000000000000000000000000000101000000000000000000000000000001010100010101010000000000000000000000000000000000000000000000000000000000000000000000000000000001010101000000000000000000000000000000010000000000000000000000000000000100000000000000000001000000000000000000000000000000000000000000000000000000000000000000000101000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000
-- </FLAGS>

-- <PALETTE>
-- 000:1010105d245db13e50ef9157ffff6daee65061be3c047f5005344c185dc95999f6e6eaf2b6baba8d8d9d444460282038
-- </PALETTE>

-- <PALETTE1>
-- 000:1010105d245db13e50ef9157ffff6daee65061be3c047f5005344c185dc95999f6e6eaf2b6baba8d8d9d444460282038
-- </PALETTE1>

-- <PALETTE2>
-- 000:1010105d245db13e50ef9157ffff6daee65061be3c047f5005344c185dc95999f6e6eaf2b6baba8d8d9d444460282038
-- </PALETTE2>

-- <PALETTE3>
-- 000:1010105d245db13e50ef9157ffff6daee65061be3c047f5005344c185dc95999f6e6eaf2b6baba8d8d9d444460282038
-- </PALETTE3>

-- <PALETTE4>
-- 000:1010105d245db13e50ef9157ffff6daee65061be3c047f5005344c185dc95999f6e6eaf2b6baba8d8d9d444460282038
-- </PALETTE4>

-- <PALETTE5>
-- 000:1010105d245db13e50ef9157ffff6daee65061be3c047f5005344c185dc95999f6e6eaf2b6baba8d8d9d444460282038
-- </PALETTE5>

-- <PALETTE6>
-- 000:1010105d245db13e50ef9157ffff6daee65061be3c047f5005344c185dc95999f6e6eaf2b6baba8d8d9d444460282038
-- </PALETTE6>

-- <PALETTE7>
-- 000:1010105d245db13e50ef9157ffff6daee65061be3c047f5005344c185dc95999f6e6eaf2b6baba8d8d9d444460282038
-- </PALETTE7>

