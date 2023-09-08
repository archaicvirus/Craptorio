-- title:   Craptorio
-- author:  @ArchaicVirus
-- desc:    De-make of Factorio
-- site:    website link
-- license: MIT License
-- version: 0.3
-- script: lua

require('classes/vec2D')
require('classes/item_definitions')
require('classes/images')
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
require('classes/research_definitions')
require('classes/solar_panel')
require('classes/storage_chest')
require('classes/refinery')

local seed = tstamp() * time()
--seed = math.random(-1000000000, 1000000000)
--local seed = 902404786
--local seed = 747070313
--math.randomseed(53264)
math.randomseed(seed)
offset = math.random(100000, 500000)
simplex.seed()
TileMan = TileManager:new()
floor = math.floor
sspr = spr
biome = 1
db_time = 0.0
last_frame_time = time()
STATE = 'start'
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
WATER_SPRITE = 224
CURSOR_MINING_SPEED = 50
technology = {}

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
  prog = false,
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
  x = 0, y = 0,
  spr = 362,
  lx = 0, ly = 0,
  shadow = 382,
  anim_frame = 0, anim_speed = 8, anim_dir = 0, anim_max = 4,
  last_dir = '0,0', move_speed = 0.15,
  directions = {
    ['0,0'] =   {id = 362, flip = 0, rot = 0, dust = vec2(4, 11)},  --straight
    ['0,-1'] =  {id = 365, flip = 0, rot = 0, dust = vec2(4, 11)},  --up
    ['0,1'] =   {id = 365, flip = 2, rot = 0, dust = vec2(4, -2)},  --down
    ['-1,0'] =  {id = 363, flip = 1, rot = 0, dust = vec2(11, 5)},  --left
    ['1,0'] =   {id = 363, flip = 0, rot = 0, dust = vec2(-2, 5)},  --right
    ['1,-1'] =  {id = 364, flip = 0, rot = 0, dust = vec2(-2, 10)},  --up-right
    ['-1,-1'] = {id = 364, flip = 1, rot = 0, dust = vec2(10, 10)},  --up-left
    ['-1,1'] =  {id = 364, flip = 3, rot = 0, dust = vec2(10, -2)},  --down-left
    ['1,1'] =   {id = 364, flip = 2, rot = 0, dust = vec2(-2, -2)}   --down-right
  },
}

dummies = {
  ['dummy_furnace'] = true,
  ['dummy_assembler'] = true,
  ['dummy_drill'] = true,
  ['dummy_lab'] = true,
  ['dummy_splitter'] = true,
  ['dummy_refinery'] = true,
}

opensies = {
  ['stone_furnace'] = true,
  ['assembly_machine'] = true,
  ['research_lab'] = true,
  ['chest'] = true,
  ['mining_drill'] = true,
  ['bio_refinery'] = true,
}

inv = make_inventory()
inv.slots[1].id  = 33 inv.slots[1].count  = ITEMS[33].stack_size
inv.slots[2].id  = 18 inv.slots[2].count  = ITEMS[18].stack_size
inv.slots[3].id  = 23 inv.slots[3].count  = ITEMS[23].stack_size
inv.slots[4].id  = 24 inv.slots[4].count  = ITEMS[24].stack_size
inv.slots[5].id  = 25 inv.slots[5].count  = ITEMS[25].stack_size
inv.slots[6].id  = 26 inv.slots[6].count  = ITEMS[26].stack_size
inv.slots[7].id  =  6 inv.slots[7].count  = ITEMS[6].stack_size
inv.slots[8].id  =  8 inv.slots[8].count  = ITEMS[8].stack_size
inv.slots[9].id  = 32 inv.slots[9].count  = ITEMS[32].stack_size
inv.slots[57].id = 9  inv.slots[57].count = ITEMS[9].stack_size
inv.slots[58].id = 10 inv.slots[58].count = ITEMS[10].stack_size
inv.slots[59].id = 11 inv.slots[59].count = ITEMS[11].stack_size
inv.slots[60].id = 13 inv.slots[60].count = ITEMS[12].stack_size
inv.slots[61].id = 14 inv.slots[61].count = ITEMS[13].stack_size
inv.slots[62].id = 22 inv.slots[62].count = ITEMS[22].stack_size
inv.slots[63].id = 19 inv.slots[63].count = ITEMS[19].stack_size
inv.slots[64].id = 30 inv.slots[64].count = ITEMS[30].stack_size
craft_menu = ui.NewCraftPanel(135, 1)
vis_ents = {}
show_mini_map = false
show_tile_widget = false
debug = false
alt_mode = false
show_tech = false
show_count = false
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
  ['deny']        = {id =  5, note = 'C-3', duration = 22, channel = 0, volume = 10, speed = 0},
  ['place_belt']  = {id =  4, note = 'B-3', duration = 10, channel = 1, volume =  8, speed = 4},
  ['delete']      = {id =  2, note = 'C-3', duration =  4, channel = 1, volume =  9, speed = 5},
  ['rotate_r']    = {id =  3, note = 'E-5', duration = 10, channel = 1, volume =  8, speed = 3},
  ['rotate_l']    = {id =  7, note = 'E-5', duration =  5, channel = 2, volume =  8, speed = 4},
  ['move_cursor'] = {id =  0, note = 'C-4', duration =  4, channel = 0, volume =  8, speed = 5},
  ['axe']         = {id =  9, note = 'D-3', duration = 20, channel = 0, volume =  6, speed = 4},
  ['laser']       = {id =  0, note = 'D-3', duration =  5, channel = 0, volume =  4, speed = 7},
  ['move']        = {id = 10, note = 'D-3', duration =  5, channel = 3, volume =  2, speed = 5},
  ['deposit']     = {id = 11, note = 'D-6', duration =  3, channel = 1, volume =  5, speed = 7},
  ['tech_done']   = {id = 12, note = 'D-8', duration = 50, channel = 2, volume = 10, speed = 6},
  ['tech_add']    = {id = 13, note = 'G-5', duration = 50, channel = 1, volume = 10, speed = 6},
}

resources = {
  ['2']  = {name = 'Petrified Fossil', id = 5, min =  5, max = 20}, --rocks
  ['7']  = {name = 'Medium Rock', id = 5, min =  5, max = 10},
  ['8']  = {name = 'Pebble', id = 5, min =  1, max =  3},
  ['9']  = {name = 'Bone', id = 5, min =  1, max =  3},
  ['10'] = {name = 'Skull', id = 5, min =  5, max =  10},
  ['24'] = {name = 'Small Rock', id = 5, min =  1, max =  3},
  ['26'] = {name = 'Medium Rock', id = 5, min =  4, max = 15},
  ['40'] = {name = 'Medium Rock', id = 5, min =  4, max = 15},
  ['42'] = {name = 'Large Rock', id = 5, min =  4, max = 15},

  ['3']  = {name = 'Cactus Sprouts', id = 32, min = 5, max = 12}, --fiber
  ['4']  = {name = 'Wildflower Patch', id = 32, min = 10, max = 20},
  ['5']  = {name = 'Flowering Cactus', id = 32, min = 19, max = 45},
  ['6']  = {name = 'Large Wildflower', id = 32, min = 5, max = 17},
  ['1']  = {name = 'Palm Sprout', id = 32, min = 5, max = 12},
  ['17'] = {name = 'Grass', id = 32, min = 5, max = 12},
  ['18'] = {name = 'Small Wildflowers', id = 32, min = 5, max = 12},
  ['19'] = {name = 'Grass', id = 32, min = 5, max = 12},
  ['20'] = {name = 'Bean Sprouts', id = 32, min = 5, max = 12},
  ['21'] = {name = 'Wildflower', id = 32, min = 5, max = 12},
  ['22'] = {name = 'Wildflower', id = 32, min = 5, max = 12},
  ['23'] = {name = 'Fungal Sprout', id = 32, min = 5, max = 15},
  ['33'] = {name = 'Grass', id = 32, min = 5, max = 12},
  ['34'] = {name = 'Grass', id = 32, min = 5, max = 12},
  ['35'] = {name = 'Large Grass Patch', id = 32, min = 5, max = 12},
  ['36'] = {name = 'Wildflower Stem', id = 32, min = 5, max = 12},
  ['37'] = {name = 'Small Wildflowers', id = 32, min = 5, max = 12},
  ['39'] = {name = 'Grass', id = 32, min = 5, max = 12},

}

dust = {}

_t = 0
sprites = {}
loaded = false

function BOOT()
  spawn_player()
  -- local tile, _, _ = get_world_cell(player.x, player.y)
  -- biome = tile.biome
  cls(0)
  poke(0x3FF8, 0)
  draw_image(0,0,240,136,cover,-1)
  vbank(1)
  --poke(0x3FF8, 1)
  --cls(0)
   --poke(0x03FF8, 0)
   
end

function hovered(_mouse, _box)
  local mx, my, bx, by, bw, bh = _mouse.x, _mouse.y, _box.x, _box.y, _box.w, _box.h
  return mx >= bx and mx < bx + bw and my >= by and my < by + bh
end

function pokey(bnk,sid,tw,th,x,y,ck,rot)
  rot = rot or 0
  if bnk == 0 then sspr(sid, x, y, ck, 1, 0, rot, tw, th) return end
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

function draw_dust()
  if not show_mini_map and not craft_menu.vis and not inv.vis and not show_tech then
    for i,d in pairs(dust) do
      if d.ty>=0 then	circ(d.x,d.y,d.r,d.c)
      else circb(d.x,d.y,d.r,d.c+1) end
    end
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
    ['chest'] = {},
    ['bio_refinery'] = {},
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
  if not ENTS[k] then
    return false
  end

  if ENTS[k].type == 'splitter' then return k end
  if ENTS[k].type == 'underground_belt_exit' then return ENTS[k].other_key, true end
  if ENTS[k].type == 'underground_belt' then return k end
  if ENTS[k].other_key then return ENTS[k].other_key else return k end
  return false
end

function get_key(x, y)
  local _, wx, wy = get_world_cell(x, y)
  return wx .. '-' .. wy
end

function get_world_key(x, y)
  return x .. '-' .. y
end

function world_to_screen(world_x, world_y)
  local screen_x = (world_x * 8) - (player.x - 116)
  local screen_y = (world_y * 8) - (player.y - 64)
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
  local cam_x = player.x - 116 + 1
  local cam_y = player.y - 64 + 1
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

function clamp(val, min, max)
  return math.max(min, math.min(val, max))
end

function prints(text, x, y, bg, fg, shadow_offset, size)
  shadow_offset = shadow_offset or {x = 1, y = 0}
  size = not size
  bg, fg = bg or 0, fg or 4
  print(text, x + shadow_offset.x, y + shadow_offset.y, bg, false, 1, size)
  print(text, x, y, fg, false, 1, size)
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
  local dt = time() - last_frame_time
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
  if not cursor.prog then
    local dust_dir = player.directions[x_dir .. ',' .. y_dir].dust
    local dx, dy = 240/2 - 4 + dust_dir.x, 136/2 - 4 + player.anim_frame + dust_dir.y
    if dust_dir and (x_dir ~= 0 or y_dir ~= 0) then
      new_dust(dx, dy, 2, math.random(-1,1) + (3*-x_dir), math.random() + (3*-y_dir))
    elseif TICK%24 == 0 then
      new_dust(dx, dy, 2, math.random(-1,1) + (3*-x_dir), math.random() + (3*-y_dir))
    end
    if x_dir ~= 0 or y_dir ~= 0 then
      sound('move')
      move_player(x_dir * (not show_mini_map and player.move_speed*dt or player.move_speed*dt * 24), y_dir * (not show_mini_map and player.move_speed*dt or player.move_speed*dt * 24))
    end
  end
    player.last_dir = x_dir .. ',' .. y_dir
end

function draw_player()
  local sx, sy = get_screen_cell(120, 76)
  local tile, wx, wy = get_world_cell(sx, sy)
  -- if biome ~= tile.biome and not show_tech then
  --   biome = tile.biome
  --   poke(0x03FF8, biomes[tile.biome].map_col)
  -- end
  if alt_mode then ui.highlight(sx-1, sy-1, 8, 8, false, 5, 6) end
  local sprite = player.directions[player.last_dir] or player.directions['0,0']
  sspr(player.shadow - player.anim_frame, 240/2 - 4, 136/2 + 8, 0)
  draw_dust()
  sspr(sprite.id, 240/2 - 4, 136/2 - 4 + player.anim_frame, 0, 1, sprite.flip)
end

function cycle_hotbar(dir)
  if cursor.type == 'item' and cursor.item_stack then
    if cursor.item_stack.slot then
      inv.slots[cursor.item_stack.slot].id = cursor.item_stack.id
      inv.slots[cursor.item_stack.slot].count = cursor.item_stack.count
    else
      inv:add_item({id = cursor.item_stack.id, count = cursor.item_stack.count})
      set_cursor_item()
    end
    --set_cursor_item()
  end
  inv.active_slot = inv.active_slot + dir
  if inv.active_slot < 1 then inv.active_slot = INVENTORY_COLS end
  if inv.active_slot > INVENTORY_COLS then inv.active_slot = 1 end
  set_active_slot(inv.active_slot)
end

function set_active_slot(slot)
  inv.active_slot = slot
  local id = inv.slots[slot + INV_HOTBAR_OFFSET].id
  if id ~= 0 then
    --trace('setting item to: ' .. ITEMS[id].name)
    cursor.item = ITEMS[id].name
    cursor.item_stack = {id = id, count = inv.slots[slot + INV_HOTBAR_OFFSET].count, slot = slot + INV_HOTBAR_OFFSET}
    cursor.type = 'item'
  else
    cursor.item = false
    cursor.type = 'pointer'
    cursor.item_stack = {id = 0, count = 0, slot = false}
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
  local tile, wx, wy = get_world_cell(x, y)
  local sx, sy = world_to_screen(wx, wy)
  local k = get_key(x, y)
  local ent = ENTS[k]

  if inv:is_hovered(x, y) or craft_menu:is_hovered(x, y) or (ui.active_window and ui.active_window:is_hovered(cursor.x, cursor.y)) then
    if cursor.panel_drag then
      sspr(CURSOR_GRAB_ID, cursor.x - 1, cursor.y - 1, 0, 1, 0, 0, 1, 1)
    else
      sspr(CURSOR_HAND_ID, cursor.x - 2, cursor.y, 0, 1, 0, 0, 1, 1)
    end
    if cursor.type == 'item' and cursor.item then
      -- draw_item_stack(cursor.x + 3, cursor.y + 3, cursor.item_stack)
    end
    return
  end
  
  if cursor.type == 'item' and cursor.item then
    if callbacks[cursor.item] then
      callbacks[cursor.item].draw_item(x, y)
    else
      draw_item_stack(cursor.x + 5, cursor.y + 5, cursor.item_stack)
    end
  end

  if cursor.type == 'item' and ITEMS[cursor.item_stack.id].type ~= 'placeable' then
    draw_item_stack(cursor.x + 5, cursor.y + 5, {id = cursor.item_stack.id, count = cursor.item_stack.count})
  end
  if cursor.type == 'pointer' then
    local k = get_key(cursor.x, cursor.y)
    if ui.active_window and ui.active_window:is_hovered(cursor.x, cursor.y) then
      
    end
    sspr(CURSOR_POINTER, cursor.x, cursor.y, 0, 1, 0, 0, 1, 1)
    --if show_tile_widget and not cursor.prog then
    if not cursor.prog then
      --local y_off = TICK%8
      --line(cursor.tx, cursor.ty + y_off, cursor.tx + 8, cursor.ty + y_off, 10 + TICK%5)
      if tile.is_tree and not ent then
        local sx, sy = world_to_screen(wx, wy)
        local c1, c2 = 3, 4
        if tile.biome < 2 then c1, c2 = 2, 3 end
        ui.highlight(sx - 9 + tile.offset.x, sy - 27 + tile.offset.y, 24, 32, false, c1, c2)
      end
      ui.highlight(cursor.tx - 1, cursor.ty - 1, 8, 8, false, 2, 2)
    end
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
  end
  -- elseif cursor.drag and cursor.type == 'item' and cursor.item == 'transport_belt' then
  --   return
  --   --trace('drag-rotating')
  --   sound('rotate_' .. dir)
  --   cursor.rot = cursor.rot + 1
  --   if cursor.rot > 3 then cursor.rot = 0 end
  --   --trace('rotated while dragging')
  --   local tile, wx, wy
  --   local dx, dy = world_to_screen(cursor.drag_loc.x, cursor.drag_loc.y)
  --   if (cursor.drag_dir == 0 or cursor.drag_dir == 2) then
  --     _, wx, wy = get_world_cell(cursor.x, dy)
  --   elseif (cursor.drag_dir == 1 or cursor.drag_dir == 3) then
  --     _, wx, wy = get_world_cell(dy, cursor.y)
  --   end
  --   cursor.drag_dir = cursor.rot
  --   -- cursor.rot = cursor.rot + 1
  --   -- if cursor.rot > 3 then cursor.rot = 0 end
  --   --cursor.drag_offset = 
  --   cursor.drag_loc = {x = wx, y = wy}
  -- end
  if cursor.type == 'item' then sound('rotate_' .. dir) end
end

function remove_tile(x, y)
  local sx, sy = get_screen_cell(x, y)
  local tile, wx, wy = get_world_cell(x, y)
  -- local sx, sy = screen_to_world(x, y)
  -- local tile, wx, wy = get_world_cell(sx, sy)
  local k = get_ent(x, y)
  if k and cursor.tx == cursor.ltx and cursor.ty == cursor.lty then
    --add item back to inventory
    local stack = {id = ENTS[k].item_id, count = 1}
    if ENTS[k].type == 'underground_belt' and ENTS[k].exit_key then
      stack.count = 2
    end
    callbacks[ENTS[k].type].remove_item(x, y)
    --trace('adding item_id: ' .. tostring(stack.id) .. ' to inventory')
    ui.new_alert(cursor.x, cursor.y, '+ ' .. stack.count .. ' ' .. ITEMS[stack.id].fancy_name, 1000, 0, 6)
    inv:add_item(stack)
    return
  end
  if cursor.held_right and cursor.tx == cursor.ltx and cursor.ty == cursor.lty then
    local result = resources[tostring(tile.sprite_id)]
    if result then
      local deposit = {id = result.id, count = floor(math.random(result.min, result.max))}
      ui.new_alert(cursor.x, cursor.y, '+ ' .. deposit.count .. ' ' .. ITEMS[deposit.id].fancy_name, 1000, 0, 6)
      inv:add_item(deposit)
      --trace('adding mined resource to inventory')
      TileMan:set_tile(wx, wy)
      sound('delete')
    end


    if tile.is_tree then
      --deposit wood to inventory
      local count = floor(math.random(3, 10))
      local result, stack = inv:add_item({id = 28, count = count})
      if result then 
        ui.new_alert(cursor.x, cursor.y, '+ ' .. count .. ' ' .. ITEMS[28].fancy_name, 1000, 0, 6)
      end
      TileMan:set_tile(wx, wy)
      sound('delete')
    end

    if tile.ore then
      local k = get_key(x, y)
      if not ORES[k] then
        local max_ore = floor(math.random(250, 5000))
        local ore = {
          type = ores[tile.ore].name,
          tile_id = ores[tile.ore].tile_id,
          sprite_id = ores[tile.ore].sprite_id,
          id = ores[tile.ore].id,
          total_ore = max_ore,
          ore_remaining = max_ore,
          wx = wx,
          wy = wy,
        }
        ORES[k] = ore
      end
      if ORES[k].ore_remaining > 0 then
        ORES[k].ore_remaining = ORES[k].ore_remaining - 1
        ui.new_alert(cursor.x, cursor.y, '+ 1 ' .. ITEMS[ORES[k].id].fancy_name, 1000, 0, 6)
        inv:add_item({id = ORES[k].id, count = 1})
        sound('delete')
      end
      if ORES[k].ore_remaining < 1 then
        TileManager:set_tile(wx, wy)
      end
    end
    -- local result = rocks[tostring(tile.sprite_id)]
    -- if result then
    --   --deposit stone ore to inventory
    --   local _, stack = inv:add_item({id = 5, count = floor(math.random(result[1], result[2]))})
    --   TileMan:set_tile(wx, wy)
    -- end
    -- if stack then
    --   --TODO: deposit remaing stack to ground
    -- end
  end
end

function set_cursor_item(stack, slot)
  if not stack then
    cursor.item = false
    cursor.item_stack.id = 0
    cursor.item_stack.count = 0
    cursor.item_stack.slot = false
    cursor.type = 'pointer'
  else
    cursor.type = 'item'
    cursor.item_stack.id = stack.id
    cursor.item_stack.count = stack.count
    cursor.item_stack.slot = slot
    cursor.item = ITEMS[stack.id].type == 'placeable' and ITEMS[stack.id].name or false
  end
end

function pipette()
  if cursor.type == 'pointer' then
    local k = get_ent(cursor.x, cursor.y)
    local ent = ENTS[k]
    if ent then
      if dummies[ent.type] then
        ent = ENTS[ent.other_key]
      end
      for i = 57, #inv.slots do
        if inv.slots[i].id == ENTS[k].item_id then
          cursor.type = 'item'
          cursor.item = ent.type
          cursor.item_stack = {id = inv.slots[i].id, count = inv.slots[i].count, slot = i}
          -- inv.slots[i].id = 0
          -- inv.slots[i].count = 0
          if ent.rot then
            cursor.rot = ent.rot
          end
          if i > 56 then inv.active_slot = i - 56 end
          return
        end
      end
      for i = 1, #inv.slots - INVENTORY_COLS do
        if inv.slots[i].id == ENTS[k].item_id then
          cursor.type = 'item'
          cursor.item = ent.type
          cursor.item_stack = {id = inv.slots[i].id, count = inv.slots[i].count, slot = i}
          -- inv.slots[i].id = 0
          -- inv.slots[i].count = 0
          if ent.rot then
            cursor.rot = ent.rot
          end
          if i > 56 then inv.active_slot = i - 56 end
          return
        end
      end
      -- cursor.type = 'item'
      -- cursor.item = ent.type
      -- cursor.item_stack = {id = ent.id, count = 5}
      -- if ent.rot then
      --   cursor.rot = ent.rot
      -- end
      -- return
    elseif cursor.item_stack.slot and inv.slots[cursor.item_stack.slot].id ~= 0 then
      set_cursor_item({id = inv.slots[cursor.item_stack.slot].id, count = inv.slots[cursor.item_stack.slot].count}, cursor.item_stack.slot)
      -- inv.slots[cursor.item_stack.slot].id = 0
      -- inv.slots[cursor.item_stack.slot].count = 0
    end
  elseif cursor.type == 'item' then
    if not cursor.item_stack.slot then
      inv:add_item({id = cursor.item_stack.id, count = cursor.item_stack.count})
    else
      inv.slots[cursor.item_stack.slot].id = cursor.item_stack.id
      inv.slots[cursor.item_stack.slot].count = cursor.item_stack.count
    end
    set_cursor_item()
    -- cursor.item = false
    -- cursor.item_stack.id = 0
    -- cursor.item_stack.count = 0
    -- cursor.type = 'pointer'
  end
end

function update_cursor_state()
  local x, y, l, m, r, sx, sy = mouse()
  local _, wx, wy = get_world_cell(x, y)
  local tx, ty = world_to_screen(wx, wy)
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

  if not l and cursor.held_left then
    cursor.held_left = false
    cursor.hold_time = 0
  end

  if not r and cursor.held_right then
    cursor.held_right = false
    cursor.hold_time = 0
  end

  cursor.ltx, cursor.lty = cursor.tx, cursor.ty
  cursor.wx, cursor.wy, cursor.tx, cursor.ty, cursor.sx, cursor.sy = wx, wy, tx, ty, sx, sy
  cursor.lx, cursor.ly, cursor.ll, cursor.lm, cursor.lr, cursor.lsx, cursor.lsy = cursor.x, cursor.y, cursor.l, cursor.m, cursor.r, cursor.sx, cursor.sy
  cursor.x, cursor.y, cursor.l, cursor.m, cursor.r, cursor.sx, cursor.sy = x, y, l, m, r, sx, sy
  if cursor.tx ~= cursor.ltx or cursor.ty ~= cursor.lty then
    cursor.hold_time = 0
  end
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
  if keyp(9) or keyp(49) then inv.vis = not inv.vis end
  --H
  if keyp(8) then toggle_hotbar() end
  --C
  if keyp(3) then toggle_crafting() end
  --Y
  if keyp(25) then debug = not debug end
  --SHIFT
  show_tile_widget = key(64)
  --ALT
  if keyp(65) then alt_mode = not alt_mode end
  --CTRL
  if key(64) and keyp(65) then show_count = not show_count end
  --E
  if keyp(5) then inv:add_item({id = 1, count = 10}) end
  --T
  if keyp(20) then
    show_tech = not show_tech
    if show_tech then
      biome = 10
      --poke(0x03FF8, UI_FG)
    end
  end
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

  local tile, wx, wy = get_world_cell(cursor.x, cursor.y)
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
        --trace('clicked active window')
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
  
  if inv:is_hovered(cursor.x, cursor.y) then
    if cursor.l and not cursor.ll then
      inv:clicked(cursor.x, cursor.y)
    end
    return
  end

  if cursor.type == 'item' and cursor.item_stack.id ~= 0 then
    --check other visible widgets
    local item = ITEMS[cursor.item_stack.id]
    local count = cursor.item_stack.count
    --check for ents to deposit item stack
    if key(63) and ENTS[k] and ENTS[k].type == 'chest' then --TODO
      if cursor.l then
        local result, stack = ENTS[k]:deposit_stack(cursor.item_stack)
        if not result then
          cursor.item_stack.count = stack.count
        else
          cursor.item_stack.count = 0
          cursor.item_stack.id = 0
          cursor.item_stack.slot = false
          cursor.type = 'pointer'
        end
      elseif cursor.r then
        --remove_tile(cursor.x, cursor.y)
        --return
      end
      --if item is placeable, run callback for item type
      --checking transport_belt's first (for drag-placement), then other items
    else
      if cursor.l and cursor.item == 'transport_belt' and (cursor.tx ~= cursor.ltx or cursor.ty ~= cursor.lty)  then
        --trace('placing belt')
        local slot = cursor.item_stack.slot
        local item_consumed = callbacks[cursor.item].place_item(cursor.x, cursor.y)
        if slot and item_consumed then
          inv.slots[slot].count = inv.slots[slot].count - 1
          cursor.item_stack.count = inv.slots[slot].count
        elseif item_consumed ~= false then
          cursor.item_stack.count = cursor.item_stack.count - 1
          if cursor.item_stack.count < 1 then
            set_cursor_item()
          end
        end
        if slot and inv.slots[slot].count < 1 then
          inv.slots[slot].id = 0
          inv.slots[slot].count = 0
          set_cursor_item()
        end
        --return
      elseif cursor.l and not cursor.ll and ITEMS[cursor.item_stack.id].type == 'placeable' then
        if callbacks[cursor.item] then
          local item_consumed = callbacks[cursor.item].place_item(cursor.x, cursor.y)
          if item_consumed ~= false then
            cursor.item_stack.count = cursor.item_stack.count - 1
            if cursor.item_stack.count < 1 then
              set_cursor_item()
            end
            if cursor.item_stack.slot then
              inv.slots[cursor.item_stack.slot].count = inv.slots[cursor.item_stack.slot].count - 1
              if inv.slots[cursor.item_stack.slot].count < 1 then
                inv.slots[cursor.item_stack.slot].id = 0
                inv.slots[cursor.item_stack.slot].count = 0
                set_cursor_item()
              end
            end
          end
        end
        return
      elseif cursor.r then
        --remove_tile(cursor.x, cursor.y)
        --return
      end
    end
  elseif cursor.type == 'pointer' then
    if cursor.l and key(63) and ENTS[k] and ENTS[k].type == 'chest' then
      --try to take all items
      ENTS[k]:return_all()
      return
    end
  end

  if cursor.held_right and cursor.type == 'pointer' then
    local sx, sy = get_screen_cell(cursor.x, cursor.y)
    local tile, wx, wy = get_world_cell(cursor.x, cursor.y)
    local result = resources[tostring(tile.sprite_id)]
    local k = get_ent(cursor.x, cursor.y)
    if not result and not tile.is_tree and not ENTS[k] and not tile.ore then cursor.prog = false return end
    if TICK % 4 == 0 then
      local px, py = sx + 4, sy + 4
      line(120, 67 + player.anim_frame, px, py, floor(math.random(1, 3) + 0.5))
      for i = 1, 3 do
        --local rx = px + floor((math.random() + 0.5) * -3)
        --local ry = py + floor((math.random() + 0.5) * -3)
        local rr = 1 + floor((math.random() + 0.5) * 4)
        local rc = 1 + floor((math.random(6) + 0.5))
        circb(px, py, rr, rc)
      end
    end
    if tile.is_tree then
      --local sx, sy = world_to_screen(wx, wy)
      local c1, c2 = 3, 4
      if tile.biome < 2 then c1, c2 = 2, 3 end
      ui.highlight(cursor.tx - 9 + tile.offset.x, cursor.ty - 27 + tile.offset.y, 24, 32, false, c1, c2)
      ui.highlight(cursor.tx + tile.offset.x - 2, cursor.ty - 1 + tile.offset.y, 8, 8, false, c1, c2)
    end
    if result or tile.ore or ENTS[k] then
      ui.highlight(sx - 1, sy - 1, 8, 8, false, 3, 4)
    end
    if (ENTS[k] or tile.is_tree or tile.ore or result) then
      --if TICK % 20 == 0 then
        --if tile.is_tree then
        --  sound('axe')
        --else
          sound('laser')
        --end
      --end
      cursor.prog = remap(clamp(cursor.hold_time, 0, CURSOR_MINING_SPEED), 0, CURSOR_MINING_SPEED, 0, 9)
      -- line(cursor.x - 4, cursor.y + 7, cursor.x + 5, cursor.y + 7, 0)
      -- line(cursor.x - 4, cursor.y + 7, cursor.x - 4 + prog, cursor.y + 7, 2)
      --and tile.is_tree or ENTS[k]
      if cursor.prog >= 9 then
        remove_tile(cursor.x, cursor.y)
        cursor.prog = false
        cursor.held_right = false
        cursor.hold_time = 0
        return
      end
    end
  else
    cursor.prog = false
  end

    --check for held item placement/deposit to other ents
  if ENTS[k] then ENTS[k].is_hovered = true end
  if cursor.l and not cursor.ll and not craft_menu:is_hovered(cursor.x, cursor.y) and inv:is_hovered(cursor.x, cursor.y) then
    local slot = inv:get_hovered_slot(cursor.x, cursor.y)
    if slot then
      --trace(slot.index)
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
      if key(63) and cursor.type == 'pointer' then
        
      end
      if key(64) and cursor.type == 'item' and ENTS[k].deposit_stack then
        local old_stack = cursor.item_stack
        local result, stack = ENTS[k]:deposit_stack(cursor.item_stack)
        if result then
          if stack then
            if stack.count > 0 then
              cursor.item_stack.count = stack.count
            else
              cursor.item_stack = {id = 0, count = 0, slot = false}
              cursor.type = 'pointer'
            end
            sound('deposit')
            ui.new_alert(cursor.x, cursor.y, stack.count - old_stack.count .. ' ' .. ITEMS[old_stack.id].fancy_name, 1000, 0, 2)
          end
        end
      else
        ui.active_window = ENTS[k]:open()
      end
    end

    return
    --consumed = true
  end
end

function render_cursor_progress()
  if not cursor.prog or not cursor.r then return end
  cursor.prog = remap(clamp(cursor.hold_time, 0, CURSOR_MINING_SPEED), 0, CURSOR_MINING_SPEED, 0, 9)
  --line(cursor.x - 4, cursor.y + 7, cursor.x + 5, cursor.y + 7, 0)
  --line(cursor.x - 4, cursor.y + 7, cursor.x - 4 + cursor.prog, cursor.y + 7, 2)
  rect(cursor.x - 4, cursor.y + 7, 9, 2, 0)
  rect(cursor.x - 4, cursor.y + 7, cursor.prog, 2, floor(remap(cursor.prog, 0, 9, 2, 7))+0.5)
  prints(cursor.hold_time, cursor.x - 4, cursor.y + 10)
end

function toggle_hotbar()
  if not inv.hotbar_vis then
    inv.hotbar_vis = true
  else
    inv.hotbar_vis = false
    inv.hovered_slot = -1
  end
end

function toggle_crafting(force)
  if force then craft_menu.vis = true else craft_menu.vis = not craft_menu.vis end
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
  local start = time()
  for i, k in pairs(vis_ents['transport_belt']) do
    if ENTS[k] then ENTS[k]:draw_items() end
  end
  db_time = floor((time() - start) * 1000)
  for i, k in pairs(vis_ents['stone_furnace']) do
    if ENTS[k] then ENTS[k]:draw() end
  end
  for i, k in pairs(vis_ents['underground_belt']) do
    if ENTS[k] then ENTS[k]:draw() end
  end
  for i, k in pairs(vis_ents['underground_belt']) do
    if ENTS[k] then ENTS[k]:draw_items() end
  end
  for i, k in pairs(vis_ents['splitter']) do
    if ENTS[k] then ENTS[k]:draw() end
  end
  for i, k in pairs(vis_ents['mining_drill']) do
    if ENTS[k] then ENTS[k]:draw() end
  end
  for i, k in pairs(vis_ents['assembly_machine']) do
    if ENTS[k] then ENTS[k]:draw() end
  end
  for i, k in pairs(vis_ents['research_lab']) do
    if ENTS[k] then ENTS[k]:draw() end
  end
  for i, k in pairs(vis_ents['chest']) do
    if ENTS[k] then ENTS[k]:draw() end
  end
  for i, k in pairs(vis_ents['bio_refinery']) do
    if ENTS[k] then ENTS[k]:draw() end
  end
  for i, k in pairs(vis_ents['inserter']) do
    if ENTS[k] then ENTS[k]:draw() end
  end
  for i, k in pairs(vis_ents['power_pole']) do
    if ENTS[k] then ENTS[k]:draw() end
  end
end

function draw_terrain()
  TileMan:draw_terrain(player, 31, 18)
end

function lapse(fn, ...)
	local t = time()
	fn(...)
	return floor((time() - t))
end

function TIC()
  if not loaded then
    load_sprites()
    return
  end
  --change mouse cursor
  poke(0x3FFB, 286)

  --draw main menu
  if STATE ~= "game" then

    update_cursor_state()
    ui.draw_menu()
    TICK = TICK + 1
    return
  end
  
  local start = time()
  update_water_effect(time())
  cls(0)

  local m_time = 0
  local gv_time = lapse(get_visible_ents)
  if not show_mini_map then
    local m_time = lapse(draw_terrain)
  end
  --update_player()
  local up_time = lapse(update_player)
  --handle_input()
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

  if TICK % CRAFTER_ANIM_RATE == 0 then
    CRAFTER_ANIM_FRAME = CRAFTER_ANIM_FRAME + CRAFTER_ANIM_DIR
    if CRAFTER_ANIM_FRAME > 5 then
      CRAFTER_ANIM_DIR = -1
    elseif CRAFTER_ANIM_FRAME < 1 then
      CRAFTER_ANIM_DIR = 1
    end
  end

  local ue_time = lapse(update_ents)
  --draw_ents()
  local de_time = lapse(draw_ents)
  local dcl_time = 0
  if not show_mini_map then
    local st_time = time()
    TileMan:draw_clutter(player, 32, 21)
    dcl_time = floor(time() - st_time)
  end
  --draw dust
  particles()

  draw_player()

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
  if ui.active_window then
    if ENTS[ui.active_window.ent_key] then
      ui.active_window:draw()
    else
      ui.active_window = nil
    end
  end
  local dc_time = lapse(draw_cursor)
  
  
  --draw_cursor()

  local info = {
    [1] = 'draw_clutter: ' .. dcl_time,
    [2] = 'draw_terrain: ' .. m_time,
    [3] = 'update_player: ' .. up_time,
    [4] = 'handle_input: ' .. hi_time,
    [5] = 'draw_ents: ' .. de_time,
    [6] = 'update_ents:' .. ue_time,
    [7] = 'draw_cursor: ' .. dc_time,    
    [8] = 'draw_belt_items: ' .. db_time,
    [9] = 'get_vis_ents: ' .. gv_time,
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
    TileMan:draw_worldmap(player, 0, 0, 192, 109, true)
    pix(121, 69, 2)
    info[9] = 'draw_worldmap: ' .. floor(time() - st_time) .. 'ms'
  end

  local tile, wx, wy = get_world_cell(cursor.x, cursor.y)
  local sx, sy = get_screen_cell(cursor.x, cursor.y)
  local k
  info[10] = 'Frame Time: ' .. floor(time() - start) .. 'ms'
  info[11] = 'Seed: ' .. seed
  info[12] = 'hold time: ' .. cursor.hold_time
  local _, wx, wy  = get_world_cell(cursor.tx, cursor.ty)
  local k = wx .. '-' .. wy
  if key(64) and ENTS[k] then
    if ENTS[k].type == 'underground_belt_exit' then
      ENTS[ENTS[k].other_key]:draw_hover_widget(k)
    else
      k = get_ent(cursor.x, cursor.y)
      if ENTS[k] then ENTS[k]:draw_hover_widget() end
    end
  end
  for k, v in pairs(ENTS) do
    v.updated = false
    v.drawn = false
    v.is_hovered = false
    if v.type == 'transport_belt' then v.belt_drawn = false; v.curve_checked = false; end
  end
  if show_tech then draw_research_screen() end
  -- if debug then ui.draw_text_window(info, 2, 2, _, 0, 2, 0, 4) end
  if show_tile_widget and not ENTS[k] then draw_tile_widget() end
  render_cursor_progress()
  ui.update_alerts()
  last_frame_time = time()
  -- local c = {
  --   'x:  ' .. cursor.x,
  --   'y:  ' .. cursor.y,
  --   'tx: ' .. cursor.tx,
  --   'ty: ' .. cursor.ty,
  --   'sx: ' .. sx,
  --   'sy: ' .. sy,
  --   'wx: ' .. wx,
  --   'wy: ' .. wy
  -- }
  -- if show_tile_widget then
  --   ui.draw_text_window(c, 2, 2, _, 0, 2, 0, 4)
  -- end
  -- local tx, ty = get_screen_cell(cursor.x, cursor.y)
  -- rectb(tx, ty, 8, 8, 9)

  TICK = TICK + 1
end

-- <TILES>
-- 000:5555555554555555555555555555555555555545555555555554555555555555
-- 001:7555557677555765677575775777677555767755555235555553355555523555
-- 002:5555555555cdcc555dcdcdc5dcdcdcdccddbbdce5cdddde555eeee5555555555
-- 003:5775555575575555575765755557575755576757556757555557576555575755
-- 004:5b555c55b2c5c3c55b555c5b57555bca55b5babc5b1c5c5755b5575555755555
-- 005:55576755555626555662326756562657567757775567777f555667f555555555
-- 006:55b555555b2b5775b252b5575b3b755555757555557557555575575557555755
-- 007:555555555555555555cbcd555cbcdcd55bcdcdd55cdcdde555eeee5555555555
-- 008:55555555555555555555de555555cdc555555cd5555555555555555555555555
-- 009:5555555d55b555555bb55555555b55555555b5555d555bb555555b5555555555
-- 010:5555555555bbbbe55bbbbbbe5b0b0bbe5bbebbbe55bbbbe555bebe5555555555
-- 011:0000000000055000005555000555555005555550005555000005500000000000
-- 012:0000000055000505055555555555055555555555555555555555555555555555
-- 013:0000000000000055000005550000550500005555005555550505555505555555
-- 014:0000000000000000000000000000000000000000005555000555555055555555
-- 015:0505555005555550005555055055550000505500055555500055550505555550
-- 016:ddddddddddddddcdddcddddddddddddddddddddddddddddddddcdddddddddddd
-- 017:ddddd5dddddd6ddd5dd57dddd6d67dd7d6d67d7dd6d67d7ddddddddddddddddd
-- 018:ddddddddddbddddddb2bddcdddbddc2cdd7dddcddd7ddd7ddddddddddddddddd
-- 019:dddddddddddddddddd5ddddddd67dddddd67dd7ddd67d7ddddddd7dddddddddd
-- 020:dd7dddddd75ddddd7d5ddddd7dd4dddd7dddd7ddddddd57dddddd5d7dddd3dd7
-- 021:dddddddddddddddddddddddddddddbddddddbabddddddbddddddd7dddddddddd
-- 022:ddd9dddddd949dddddd8ddddddd7ddddddd7ddddddd7dddddddddddddddddddd
-- 023:dd2222ddd22b222dd222222ddd2222dddddbcdddddebcedddddeeddddddbcddd
-- 024:ddddddddddddddddddbcdddddbcdcddddeccedddddeedddddddddddddddddddd
-- 025:dddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddddd
-- 026:ddddddddddddddddddbcbddddbcbccdddcbcccdddecccfddddeefddddddddddd
-- 027:55555555555dd55555dddd555dddddd55dddddd555dddd55555dd55555555555
-- 028:55555555dd555d5d5ddddddddddd5ddddddddddddddddddddddddddddddddddd
-- 029:55555555555555d555555ddd5555dd5d555ddddd55d5dddd55dddddd5ddddddd
-- 030:555555555555555555555555555555555555555555dddd555dddddd5dddddddd
-- 031:5d5dddd55dddddd555dddd5dd5dddd5555d5dd555dddddd555dddd5d5dddddd5
-- 032:eeeeeeeeee8eeeeeeeeeeeeeeeeeeeeeeeeee8eeeeeeeeeee8eeeeeeeeeeeeee
-- 033:eeeeeeeeeeeeeeeee6eeeeeeee6eee6ee66ee66ee66ee66eee6ee6eeeeeeeeee
-- 034:eeeeeeeeeee6eeeee6ee6eeeee6e6ee6ee6e6e6eee6e6e6eee6e6e6eeeeeeeee
-- 035:eeeeeeeee6eeeeeeee6eeeeeee56eee66e56ee6ee666e56eee56566eee66566e
-- 036:ee2deeeee232eeeeee264eeeeee454eeeee64eeeee56eeeeeee6eeeeeeeeeeee
-- 037:eeeeeeeeee6eeeeee626eeeeee6eeeeeeeeeeeeeeeeee6eeeeee636eeeeee6ee
-- 038:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 039:eeeeeeeeeeeeeeeeeeeeee6eee6ee6e6e6e6e6eeeee6e6eeeee6e6eeeeeeeeee
-- 040:eeeeeeeeeeeeeeeeeedcdceeedcdcdfeecdcdffeefcdfffeeeffffeeeeeeeeee
-- 041:eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 042:eeeeeeeeeecdcdeeecdcdcdfcdcdcddfdcddddcffddddcffeffffffeeeeeeeee
-- 043:dddddddddddeedddddeeeedddeeeeeeddeeeeeedddeeeedddddeeddddddddddd
-- 044:ddddddddeedddededeeeeeeeeeeedeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 045:ddddddddddddddeddddddeeeddddeededddeeeeeddedeeeeddeeeeeedeeeeeee
-- 046:ddddddddddddddddddddddddddddddddddddddddddeeeedddeeeeeedeeeeeeee
-- 047:deeeededdeeeeeededeeeeddddeeeededdeededddeeeeeededeeeedddeeeeeed
-- 096:0011110001111100111888001188880011888800118888000000000000000000
-- 097:b0000000bb000000bbc00000bde0000000000000000000000000000000000000
-- 112:1111111111141111111c4111111cc411111cc211111c21111112111111111111
-- 113:144411114ccc1111cccc1111cccc1111cccc1111cccc11112ccc111112221111
-- 128:0111000011000000100000001000000011000000011100000000000000000000
-- 135:1111111111111111111111111157575615656565575756566676676767677676
-- 136:1111111511111156111115755611176765611177565611176767111176756561
-- 137:7571111156561111757571116767611177771111775757711565656657575757
-- 138:1111111511111155111115551111156611111677111157671115677511167756
-- 139:6565611156565657656565657676767767676766777777777777777757777777
-- 140:1111111156711111656611115756711175676111767677117767666177756571
-- 147:44444444444b22444442224422c4b4442224b2224b44b22b4b4444b4444444b4
-- 151:6777777716777777116757571115656511575757117676761567777756567777
-- 152:7756565675656565767676766767676757775656767565577565656556565757
-- 153:76767676677777777177777761e7777176e65111577551116566561157577571
-- 154:1116757511165767115676771565677756565676666767676676767666676766
-- 155:7575767767676757777765657777575777767676677767677776767666677777
-- 156:7776776165676771667775615767765676776565677676767667676677777776
-- 160:4ce4ce44cdd4edc4dec44cf4444444444ecd4de4edf44ece4ee4ecdc444444e4
-- 161:42111121342f331133f144f1124142f1111111111431142ff323132f142f1f11
-- 162:4bf4bf4489b4f9f49bf44fb444444444b8b94494f98b49bf4ff44f9b44444bf4
-- 163:4400400440fe40ef400f44f0440444444044440f000e40f00ef040e44f044444
-- 164:45646544f6644664564f4654444444444f544f545664456645664f5644f44444
-- 165:41f40f440114f114410141f4444444440f104104f11f411f410411f0444440f4
-- 167:676767657676767667777777167777b711677b3b111153b21111153311111173
-- 168:656576767676777767676777777777777777777e177773223173333333153322
-- 169:7676565677757575776767672777777715e77771152111115211111151111111
-- 170:1666776311666633111111131111111111111111111111111111111111111111
-- 171:2116777732216666332222111333221111133223111322221113322111133211
-- 172:7667777661366661132211113221111122111111211111111111111111111111
-- 176:dc444444ccd444444ee444444444444444444444444444444444444444444444
-- 177:1341111144211111231111111111111111111111111111111111111111111111
-- 178:be444444cd8444444cd444444444444444444444444444444444444444444444
-- 179:4f0444440e044444f04444444444444444444444444444444444444444444444
-- 180:4574444477544444f74444444444444444444444444444444444444444444444
-- 181:4ff4444411144444ff4444444444444444444444444444444444444444444444
-- 183:1111111111111111111111111111111111111111111111111111111111111111
-- 184:2335332513335552113333321113332211233331113332211133333111333221
-- 185:e111111111111111111111111111111111111111111111111111111111111111
-- 186:1111111111111111111111111111111111111111111111111111111111111111
-- 187:1113321111132211111332111113221111133211111322111113321111132211
-- 188:1111111111111111111111111111111111111111111111111111111111111111
-- 194:0077777707556466746646567665656466677777677000007007777700746565
-- 195:0000000077000000657000076657007476650656776607567076755657576760
-- 196:0777700074746700565765706566666756777776677000070000000077770000
-- 197:1111111111111117111117551111155611117557111755611157575717567675
-- 198:77677777655656565575757557175676577567b765565bab571767b776761565
-- 199:1111111177111111667111115767111176767111676767117676767176176771
-- 200:1111111111111111111111111157575615656561575751566671676767677676
-- 201:1111111511111156111115755611676765617771565117776767717116756567
-- 202:7571111156561111157571116767611177177611775751717565656657575157
-- 204:0000000000000000000050000057770000077700000757000007775000077700
-- 205:0507700000777700077775700577777507777770077757700777777057577770
-- 210:0756665674665777766777007577700076670000676000000770000000700000
-- 211:6677777770733766002332700032230000333300000333300003333000023320
-- 212:6767700076756700776676700777657000077660000077600000067000000760
-- 213:55157756575757617676b676177b3b571177b7651111cc0611111c0511111bc1
-- 214:57576757656575717656567667617b7575776b57565657616165767611116c01
-- 215:6756576175656567565b57577576b67757b77771617777117bc7b111bb1b2b11
-- 216:6771717116777777116757571113211111113757117676761567177156567777
-- 217:7777561673276513113676316532673157365136765375577163656557573757
-- 218:717676766777b776166beb561777b66176325111573211111566561157577571
-- 220:0007777700057777000077750000050000000000000000000000000000000000
-- 221:7777767077777776777677707777777007777770067776700777777707776777
-- 222:0005000000777500007770000075700005777000000770000077000075775000
-- 224:9999999999999999999999999999999999999999999999999999999999999999
-- 227:0003223000033330000033300000333300002332000032230003333300033333
-- 228:0000070000000000000000000000000000000000000000000000000000000000
-- 229:11111c0c111111cb1111111c1111111b1111111b111111111111111111111111
-- 230:1111bb011111bc01b111cb0100110c010b11cbc1b0110c1c1bc1b0cb1b0c0cb1
-- 231:c011b111b0111111cc111111b0111111cc111111b11111111111111111111111
-- 232:67676765767176636777776116177711111711111171111111761111111b1111
-- 233:6515635626117367321733673217532613213321113233111133321111133211
-- 234:1676561675727575173767661567717613216661133211111321111133211111
-- 237:0757767707777776077677706777777507777770067776700777777067776770
-- 238:7770000000000000000000000000000000000000000000000000000000000000
-- 243:0003333000023320000322300003333000033330002333200032223000333300
-- 245:1111111111111111111111111111111111111111111111111111111111111111
-- 246:1cb0bb1111cc0c11111bc0111110bc11111b0b11111cb01111100c111110b011
-- 247:1111111111111111111111111111111111111111111111111111111111111111
-- 248:11b9b111111b1111111111111111111111111111111111111111111111111111
-- 249:1113321311133233111333321113332111133211111332111113321111333221
-- 250:3211111121111111111111111111111111111111111111111111111111111111
-- 253:0776757607777770076777600777777007777776075767706777777007677770
-- </TILES>

-- <TILES1>
-- 000:0000000000000000000000000000000c00000ccb000cc89b0cc8989bc898989b
-- 001:00000cc0000cc89c0cc8989cc898989b9898989b9898989b9898989b9898989b
-- 003:edde1111d00d1111edde11111ee111111dd111111dd1111b1dd111be1dd111b0
-- 004:eddedddedddedddedd111111ee111111dd111111bbb1111100eb1111b00bdbbd
-- 005:dde11111ddd111111dd111111ee111111dd111111dd111111dd111111dd11111
-- 010:cdeeeeeed000dddde00c32eee00d232de00c323cd00d23eee000eccce000c000
-- 011:eeeeeedcdddd000deeeee00ecdcdc00edcdcd00eeeeee00dccce000e000c000e
-- 012:11111111111111111111111111111f441111143f111114f31111114411ff1144
-- 013:1111111111111111111111f411111f4444443441444434411111114411ff1114
-- 014:111111111111111144f111111111111111111111111111111111111144111111
-- 016:c898989bc898989bc898989bc898989bc898989cc8989cc0c89cc0000cc00000
-- 017:9898989b98989bb0989bb0009bb0d000ce00d0000e00d00000e0d000000dd000
-- 019:1dd111b01dd111be1dd1111b1dd111111dd111ce1dd11cbb1dd1cbbb1dd1cbeb
-- 020:000bdbbb00eb11bbbbb111bbdd1111bbddeccebbeebbbbeebbbbbbbbdddddddd
-- 021:1dd111111dd111111ee111111dd11111ebbc1111bbbbc111bbbbbc11ddbebc11
-- 026:fddddddde0000000ddd00000ff4c0000f4feceecff4c0000ddd00000cdeeeeee
-- 027:ddddddde0000000e0000000d0000000eceecceed0000000e0000000deeeeeedc
-- 028:1f44f1441f444f4411f44433111f4f44111f4f44111f44ff1111f44411111f4d
-- 029:1f44f1dff444fdee444fdeeef4fdffe4f4dffffe4deeffffdeeeefffffe4440f
-- 030:fdf11111ffdf1111effdf111440fdf11e40ffdf1e40efdf1feeedf11ffedf111
-- 035:1ee1cbbd1dd1cbbd1ddecbbd1dddcbbd1eddcbeb11111bbb111111bb11111111
-- 036:d000000000b0000000000000d0000000ddddddddbbbbbbbbbbbbbbbb11111111
-- 037:0ddbbc1100dbbc1100dbbc110ddbbc11ddbebc11bbbbb111bbbb111111111111
-- 044:11111f4d11111144111111ff1111111111111111111111111111111111111111
-- 045:fffee40fdfffe40efdfffeee1fdfffed11fdffdf111fddf11111ff1111111111
-- 046:ffdf1111fdf11111d1111111f111111111111111111111111111111111111111
-- 080:00000000000a999900a99fff0a99f9990a9f9fff0a9f9fef0a9f9fff0a9f9999
-- 081:0000000099999999ffffffff9999999999fff99f99fef99f99fff99f99999999
-- 082:0000000099999000fff99900999f9990ff99f990ef99f990ff99f9909999f990
-- 084:00000000000bbbbb00beeccc0bceccee0bccce990bcdce9d0bcccede0bcccedf
-- 085:00000000bbbbbbbbdccdcdcceeeeeeeedddddd99ffffffd9eeeeeeedfffffffd
-- 086:00000000bbbbb000cdcccb00eeeeccb09bb9ecb09cc9ecb09cc9ecb09dd9edb0
-- 088:d000000d0700007000700700000cd000000dc0000070070007000070d000000d
-- 089:0000000000000000000000000040000000b0000000b000000ebe00000fef0000
-- 096:0a9f9fff0aafffee0aafafff0aafaaae0aafaaae0aafaaae0aafaaae0aafaaae
-- 097:ffffffffeeeeeeeeffffffffeeeeeeeeffffffffffffffffffffffffffffffff
-- 098:fff9f990eefffa90fffafa90eaaafa90eaaafa90eaaafa90eaaafa90eaaafa90
-- 099:0aaaaaa0ae9e9e9aa9ffff9aafeeeefaaaffffaaaaaeeaaa9aaeeaa909999990
-- 100:0bccdede0bcdcedf0bcccede0bcdcedf0bccde9d0bcdce990bccde990bcdcebc
-- 101:eeeeeeedfffffffdeeeeeeedfffffffdeeeeeed9dddddd9999999999dcdccdcd
-- 102:9cc9ecb09dd9ecb09cc9edb09dd9ecb09cc9edb09dd9ecb09ff9edb0f45fecb0
-- 103:0aaaaaa0ae9e9e9aa9ffff9aafeeeefaaaffffaaaaaeeaaa9aaeeaa909999990
-- 112:0aafaaae0aafaaae0aafaaae0aaafaae0aaaaffe009aaaaa0009999900000000
-- 113:ffffffffffffffffffffffffffffffffeeeeeeeeaaaaaaaa9999999900000000
-- 114:eaaafa90eaaafa90eaaafa90eaafaa90effaaa90aaaaa9009999900000000000
-- 116:0bccdebc0bcdce990bcedcee0bceeccd0becccdc00bccccc000bbbbb00000000
-- 117:dcdccdcd99999999eeeeeeeecdcdcdcddcdcdcdccccdcccdbbbbbbbb00000000
-- 118:f55fedb09ff9ecb0eeeeceb0cdcdeeb0dcdcdcb0cdcdcb00bbbbb00000000000
-- 128:000000000003444400344fff0344f444034f4fff034f4fef034f4fff034f4444
-- 129:0000000044444444ffffffff4444444444fff44f44fef44f44fff44f44444444
-- 130:0000000044444000fff44400444f4440ff44f440ef44f440ff44f4404444f440
-- 132:11111111111ff1111ccdfcedc23d4e6cc22d5e7c1ccdfced111ff11111111111
-- 134:00fddf0d0fc77cfc0c7657c00ce77ec00decced002ceec20200dd00200300300
-- 135:00fddf000fcee7f00dee76500deee7700cdccec0003ee2d0030d200d00020000
-- 136:00000000000bbbbb00beeccc0bceccee0bccce990bcdce9d0bcccede0bccced0
-- 137:00000000bbbbbbbbdccdcdcceeeeeeeedddddd99000000d97eeee7ed0700704b
-- 138:00000000bbbbb000cdcccb00eeeeccb09bb9ecb09ff9ecb09ef9ecb0bbe9edb0
-- 139:00000000000bbbbb00beeccc0bceccee0bccce990bcdce9d0bcccedf0bcccedf
-- 140:00000000bbbbbbbbdccdcdcceeeeeeeedddddd99ffffffd9fffffffdffffff4b
-- 141:00000000bbbbb000cdcccb00eeeeccb09bb9ecb09ff9ecb09ef9ecb0bbe9edb0
-- 144:034f4fff033fffee033f3fff033f333e033f333e033f333e033f333e033f333e
-- 145:ffffffffeeeeeeeeffffffffeeeeeeeeffffffffffffffffffffffffffffffff
-- 146:fff4f440eefff340fff3f340e333f340e333f340e333f340e333f340e333f340
-- 147:033333303e4e4e4334ffff433feeeef333ffff33333ee333433ee33404444440
-- 150:00000000000000000000000000ffff000ffffff00ffffff000ffff0000000000
-- 151:00000000000000000000000000ffff000ffffff00ffffff000ffff0000000000
-- 152:0bccdede0bcdced00bcccede0bcdced00bccde9d0bcdce990bccde990bcdcebf
-- 153:eecdeeed00dc000de7ee7eed7000070de4eeeed9dbdddd999b999999ebefcdcd
-- 154:9ef9ecb09ff9ecb09cc9edb09dd9ecb09cc9edb09dd9ecb09ff9edb0f45fecb0
-- 155:0bccdedf0bcdcedf0bcccedf0bcdcedf0bccde9d0bcdce990bccde990bcdcebd
-- 156:fffffffdfffffffdfffffffdfffffffdf4ffffd9dbdddd999b999999ebedcdcd
-- 157:9ef9ecb09ff9ecb09cc9edb09dd9ecb09cc9edb09dd9ecb09ff9edb0f45fecb0
-- 160:033f333e033f333e033f333e0333f33e03333ffe004333330004444400000000
-- 161:ffffffffffffffffffffffffffffffffeeeeeeee333333334444444400000000
-- 162:e333f340e333f340e333f340e33f3340eff33340333334004444400000000000
-- 164:000000000000000000000000000cccc000cfefed00cfefbc00eddbff00eeebff
-- 165:000000000000000000ee00000effe0000feef0000ffff000ceffeeb4ceeeebb3
-- 166:000000000000000000000000000000000000000000000000dddd0000dddded00
-- 168:0bccdebf0bcdce990bcedcee0bceeccd0becccdc00bccccc000bbbbb00000000
-- 169:feffcdcd99999999eeeeeeeecdcdcdcddcdcdcdccccdcccdbbbbbbbb00000000
-- 170:f55fedb09ff9ecb0eeeeceb0cdcdeeb0dcdcdcb0cdcdcb00bbbbb00000000000
-- 171:0bccdebd0bcdce990bcedcee0bceeccd0becccdc00bccccc000bbbbb00000000
-- 172:fefdcdcd99999999eeeeeeeecdcdcdcddcdcdcdccccdcccdbbbbbbbb00000000
-- 173:f55fedb09ff9ecb0eeeeceb0cdcdeeb0dcdcdcb0cdcdcb00bbbbb00000000000
-- 176:00000000000bcccc00bccfff0bccfccc0bcfcfff0bcfcfef0bcfcfff0bcfcccc
-- 177:00000000ccccccccffffffffccccccccccfffccfccfefccfccfffccfcccccccc
-- 178:00000000ccccc000fffccc00cccfccc0ffccfcc0efccfcc0ffccfcc0ccccfcc0
-- 180:00feeccc00fffcdd00999cac09889aac09cccc9909ddd99909ceeeee08ceeeee
-- 181:eddeebd2edddeee2aeddeeeeaeeeebbc9eeeebcc9fffffffedddddddeddddddd
-- 182:dedeeed0eeeefee0eeedfee04ddefe003eeeedd0fffdffd0ddddfe00dffdfe00
-- 192:0bcfcfff0bbfffee0bbfbfff0bbfbbbe0bbfbbbe0bbfbbbe0bbfbbbe0bbfbbbe
-- 193:ffffffffeeeeeeeeffffffffeeeeeeeeffffffffffffffffffffffffffffffff
-- 194:fffcfcc0eefffbc0fffbfbc0ebbbfbc0ebbbfbc0ebbbfbc0ebbbfbc0ebbbfbc0
-- 195:0bbbbbb0becececbbcffffcbbfeeeefbbbffffbbbbbeebbbcbbeebbc0cccccc0
-- 208:0bbfbbbe0bbfbbbe0bbfbbbe0bbbfbbe0bbbbffe00cbbbbb000ccccc00000000
-- 209:ffffffffffffffffffffffffffffffffeeeeeeeebbbbbbbbcccccccc00000000
-- 210:ebbbfbc0ebbbfbc0ebbbfbc0ebbfbbc0effbbbc0bbbbbc00ccccc00000000000
-- 226:00fddf0d0fc77cfc0c7657c00ce77ec00decced002ceec20200dd00200300300
-- 227:00fddf000fcee7f00dee76500deee7700cdccec0003ee2d0030d200d00020000
-- 242:00000000000000000000000000ffff000ffffff00ffffff000ffff0000000000
-- 243:00000000000000000000000000ffff000ffffff00ffffff000ffff0000000000
-- </TILES1>

-- <TILES2>
-- 021:000000000000000000000000000000000000000f000000ff0000ffff000fffff
-- 022:000000000000000000eeeeee0eddddddfdccceccfdcce0ecfdccceccfdcccccc
-- 023:0000000000000000eeeeeeeeddddddddcccccccccccccccccccccccccccccccc
-- 024:0000000000000000eeeeeeeeddddddddcccccccccccccccccccccccccccccccc
-- 025:0000000000000000eeeeee00dddddde0ccecccdfce0eccdfccecccdfccccccdf
-- 026:00000000000000000000000000000000f0000000ff000000ffff0000fffff000
-- 036:00000000000000000000000e000000ec00000ecc0000eccc000ecccc000ecccc
-- 037:0fffffffcfffffffceffffffccffffffccefffffcccfffffccceffffccccffff
-- 038:fdccccccfdccccccfdccceccfedce0ecffedceccfffeddddfff88888ff877777
-- 039:ccccccccccccccccccccccccccccccccccccccccdddddddd8888888877777777
-- 040:ccccccccccccccccccccccccccccccccccccccccdddddddd8888888877777777
-- 041:ccccccdfccccccdfccecccdfce0ecdefccecdeffddddefff88888fff777778ff
-- 042:fffffff0fffffffcffffffecffffffccfffffeccfffffcccffffecccffffcccc
-- 043:0000000000000000e0000000ce000000cce00000ccce0000cccce000cccce000
-- 051:00000000000000000000000e000000ef00000ee0000eceef00ecceff0eccceff
-- 052:000ecccc00ecccecffecce0effecccecfeccccccfeccccccfecccccceccccccc
-- 053:ccccefffcccccffeccccceffccccccf8cccccf88ccccff88cccef888cccf8887
-- 054:f8888888f8888888888777778877888887887888788878887888878888888788
-- 055:8888888888777777778888888888888888888888888888888888777787778fff
-- 056:88888888777777888888887788888888888888888888888877778888fff87778
-- 057:8888888f8888888f777778888888778888878878888788878878888788788888
-- 058:fffecccceffcccccffeccccc8fcccccc88fccccc88ffcccc888feccc7888fccc
-- 059:cccce000ceccce00e0ecceffceccceffccccccefccccccefccccccefccccccce
-- 060:0000000000000000e0000000fe0000000ee00000feece000ffecce00ffeccce0
-- 065:000000000000000000000000000000000000000000000000000000000000000e
-- 066:000000000000000e000000ec00000ecc00000ecc000eeecc0eefecccefffeccc
-- 067:eccccefecccceefecccceffeccceeffecccefffeccceffecccceffecccceffec
-- 068:ecccccccecccccccecccccccccccccccccccccceccccccefccccccefcccccef8
-- 069:ccf88878cff88878ef888788f8887888f8878888888788888878888888788888
-- 070:88888878888888778888878f888878ff88887fff8887fff88887f88f887ff88e
-- 071:78fffff8fffff8eefff8eeee88eeefee8eef7666ee866665ee666665e6666655
-- 072:8fffff87ee8fffffeeee8fffeefeee886667fee8566668ee566666ee5566666e
-- 073:8788888877888888f8788888ff878888fff788888fff7888f88f7888e88ff788
-- 074:87888fcc87888ffc887888fe8887888f8888788f888878888888878888888788
-- 075:ccccccceccccccceccccccceccccccccecccccccfeccccccfecccccc8feccccc
-- 076:efecccceefeecccceffecccceffeecccefffecccceffecccceffecccceffeccc
-- 077:00000000e0000000ce000000cce00000cce00000cceee000cccefee0cccefffe
-- 078:00000000000000000000000000000000000000000000000000000000e0000000
-- 081:000000ef00000eff00000eff0000efff0000efff0000efff0000efff0000efff
-- 082:ffffecccffffecccfffeccccfffeccccfffeccccfffeccccfffeccccfffecccc
-- 083:ccceffecccceffecccceffeeccceffecccceffecccceffecccceffecccccefee
-- 084:ccccef87eccce877fece8777ecef8777ceff8777cfff8777effff877fffff877
-- 085:7777777777666666776666667766666677666666776666667766666677766666
-- 086:777efffe667efffe667efffe667efffe667effff666fffff666effff6667ffff
-- 087:7666665576666655766666557666666676666666e7666666f7666666ff766666
-- 088:55666667556666675566666766666667666666676666667e6666667f666667ff
-- 089:efffe777efffe766efffe766efffe766ffffe766fffff666ffffe666ffff7666
-- 090:7777777766666677666666776666667766666677666666776666667766666777
-- 091:78fecccc778eccce7778ecef7778fece7778ffec7778fffc778ffffe778fffff
-- 092:ceffecccceffeccceeffecccceffecccceffecccceffecccceffeccceefecccc
-- 093:ccceffffccceffffccccefffccccefffccccefffccccefffccccefffccccefff
-- 094:fe000000ffe00000ffe00000fffe0000fffe0000fffe0000fffe0000fffe0000
-- 097:0000efee0000eecc0000ecff000eccff00eccfff00eccfff0eccffff0eccffff
-- 098:eeecccccccccccccffecccccffecccccffecccccffecccccffecccccffeccccc
-- 099:ccccefefccccefffccccefffccccefffccccefffccccefffccccefffccccceff
-- 100:fffffff7fffffffeffffffffffffffffffffffffffffffffffffffffffffffff
-- 101:7776666677776666e7777666f7777666fe777766ffe77776fffe7777ffef7777
-- 102:66668fff66666fff666667ff6666667f66666667666666666666666666666666
-- 103:fffe7777ffffeeeeffffe888ffffe888ffffe88867ffeeee6667777766666666
-- 104:7777efffeeeeffff888effff888effff888effffeeeeff767777766666666666
-- 105:fff86666fff66666ff766666f766666676666666666666666666666666666666
-- 106:66666777666677776667777e6667777f667777ef67777eff7777efff7777feff
-- 107:7fffffffefffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 108:fefeccccfffeccccfffeccccfffeccccfffeccccfffeccccfffeccccffeccccc
-- 109:ccccceeeccccccccccccceffccccceffccccceffccccceffccccceffccccceff
-- 110:eefe0000ccee0000ffce0000ffcce000fffcce00fffcce00ffffcce0ffffcce0
-- 113:0eccffff0eccffff0eccffff0eccffff0eccffff0eccffff0eccffff0eccffff
-- 114:ffecccccffecccccffecccccffecccccffecccccffecccccffecccccfffecccc
-- 115:ccccceeeccccceeeccccceeeccccceeeccccceeecccccceecccccceeccccccee
-- 116:ffffffffefffffffeeffffffeeefffffeeeeffffeeeeeeeeeeeeeeeeeeeeeeee
-- 117:fffee777ffffee77fffffee7ffffffeefffffffeffffffffefffffffeeffffff
-- 118:76666666776666667777777677777777777777777777777777777777ffffff77
-- 119:6666666666666666666666667777777777777777777777777777777777777777
-- 120:6666666666666666666666667777777777777777777777777777777777777777
-- 121:6666666766666677677777777777777777777777777777777777777777ffffff
-- 122:777eefff77eeffff7eefffffeeffffffeffffffffffffffffffffffeffffffee
-- 123:fffffffffffffffeffffffeefffffeeeffffeeeeeeeeeeeeeeeeeeeeeeeeeeee
-- 124:eeeccccceeeccccceeeccccceeeccccceeeccccceecccccceecccccceecccccc
-- 125:ccccceffccccceffccccceffccccceffccccceffccccceffccccceffccccefff
-- 126:ffffcce0ffffcce0ffffcce0ffffcce0ffffcce0ffffcce0ffffcce0ffffcce0
-- 129:0eccffff0eccffff0eccffff00ecffff00ecffff000edfff0000eddd00000eee
-- 130:fffecdddfffecdddfffecdddfffecdddfffecdddfffecdddddddcdddeeeeecdd
-- 131:dddddceedddddceedddddceedddddceedddddceeddddddceddddddceddddddce
-- 132:eeeeefffeeeeffffeeefffffeeffffffefffffffffffffffffffffffffffffff
-- 133:eeeffffffeeeffffffeeeffffffeeeffffffeeeffffffeeeffffffeefffffffe
-- 134:ffffff75ffffff75ffffff76ffffff76ffffff76ffffff76efffff75eefffff7
-- 135:5555555555555555555555555555555555555555666655555555555577777777
-- 136:5555555555555555555555555555555555555555555566665555555577777777
-- 137:57ffffff57ffffff67ffffff67ffffff67ffffff67ffffff57fffffe7fffffee
-- 138:fffffeeeffffeeeffffeeeffffeeeffffeeeffffeeefffffeeffffffefffffff
-- 139:fffeeeeeffffeeeefffffeeeffffffeefffffffeffffffffffffffffffffffff
-- 140:eecdddddeecdddddeecdddddeecdddddeecdddddecddddddecddddddecdddddd
-- 141:dddcefffdddcefffdddcefffdddcefffdddcefffdddcefffdddcddddddceeeee
-- 142:ffffcce0ffffcce0ffffcce0ffffce00ffffce00fffde000ddde0000eee00000
-- 145:000fffff0000ffff0000ffff00000fff00000fff00000fff00000fff0000ffff
-- 146:ffffecddffffecddfffffecdfffffecdfffffecdffffffecffffffecfffffffc
-- 147:dddddddcdddddddddddddddddddddddddddddddddddddddddddddddddddddddc
-- 148:efffffffceffffffdcefffffddceffffdddcefffddddceffcccddcee222cddcc
-- 149:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffff
-- 150:eeffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 151:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 152:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 153:ffffffeeffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 154:fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffe
-- 155:fffffffeffffffecfffffecdffffecddfffecdddffecddddeecddcccccddc222
-- 156:cdddddddddddddddddddddddddddddddddddddddddddddddddddddddcddddddd
-- 157:ddceffffddceffffdcefffffdcefffffdcefffffceffffffceffffffcfffffff
-- 158:fffff000ffff0000ffff0000fff00000fff00000fff00000fff00000ffff0000
-- 160:0000000000000000000000000000000000000000000000000000000e000000ee
-- 161:000eddde000eeedd00eeeedd0eeeeeed0eeeeeedeeeedeeeeedddeeeeddddeef
-- 162:eeee111eeee1221edeee2221ddee1222ddee1122eddf2112eedf2211ffff1221
-- 163:cdddddc2cdddddc2eccdddc21eeccddc11feecdd211ffecc221fffee121fffff
-- 164:2332cddd3452cddd3432cddd222cddddcccdddddddddddddccddddddeeccdddd
-- 165:ceffffffdceeffffddccefffddddceffdddddceeddddddccdddddddddddddddd
-- 166:ffffffffffffffffffffffffffffffffffffffffeeffffffcceeffffddcceeff
-- 167:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 168:ffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 169:ffffffffffffffffffffffffffffffffffffffffffffffeeffffeeccffeeccdd
-- 170:ffffffecffffeecdfffeccddffecddddeecdddddccdddddddddddddddddddddd
-- 171:dddc2332dddc2543dddc2343ddddc222dddddcccddddddddddddddccddddccee
-- 172:2cdddddc2cdddddc2cdddccecddccee1ddceef11cceff112eefff122fffff121
-- 173:e111eeeee1221eee1222eeed2221eedd2211eedd2112fdde1122fdee1221ffff
-- 174:eddde000ddeee000ddeeee00deeeeee0deeeeee0eeedeeeeeeedddeefeedddde
-- 175:000000000000000000000000000000000000000000000000e0000000ee000000
-- 176:000000ee0000eeee00eeeeed0eeeeedd0eeeedddeeeeedddeeeddddd01121dde
-- 177:edddeeffdddeefffddeeffffddeeffffdeefffffdeefffffeeefffffeeeeffff
-- 178:fffff111ffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 179:ff1fffffffffffffffffffffffffffffff0fffffff00fffff0000fff0000000f
-- 180:ffeeccddffffeecdffffffecfffffffeffffffffffffffffffffffffffffffff
-- 181:ddddddddddddddddcdddddddecddddddfeccddddffeeccccffffeeeeffffffff
-- 182:ddddcceeddddddccddddddddddddddddddddddddcccccdddeeeeecddffffecdd
-- 183:ffffffffffffffffdcccccccdddddddddddddddddddddddddddddddddddddddd
-- 184:ffffffffffffffffcccccccddddddddddddddddddddddddddddddddddddddddd
-- 185:eeccddddccdddddddddddddddddddddddddddddddddcccccddceeeeeddceffff
-- 186:dddddddddddddddddddddddcddddddceddddccefcccceeffeeeeffffffffffff
-- 187:ddcceeffdceeffffceffffffefffffffffffffffffffffffffffffffffffffff
-- 188:fffff1fffffffffffffffffffffffffffffff0ffffff00fffff0000ff0000000
-- 189:111fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff
-- 190:ffeedddefffeedddffffeeddffffeeddfffffeedfffffeedfffffeeeffffeeee
-- 191:ee000000eeee0000deeeee00ddeeeee0dddeeee0dddeeeeedddddeeeedd12110
-- 192:0122421e0122422e012242530f2233230012233200f12253000f12230000f122
-- 193:eeefffffeeeeffff2eeeffff5eeeffff322fffff222fffff4331ffff2231ffff
-- 194:fffffff0fffffff0ffffff00fffff000ffff0000fff00000ff000000f0000000
-- 195:0000000000000000000000000000000f0000000e000000fe000000ee00000fee
-- 196:ffffffff0fffffffeeefffffeeeeffffeeeeefffeeeeeeefeeeeeeeeeeeeeeee
-- 197:ffffffffffffffffffffffffffffffffffffffffffffffffeeffffffeeeeefff
-- 198:ffffecddfffffecdffffffecfffffffeffffffffffffffffffffffffffffffff
-- 199:ddddddddddddddddddddddddccccddddffffcdddfffffcddffffffcdffffffcd
-- 200:ddddddddddddddddddddddddddddccccdddcffffddcfffffdcffffffdcffffff
-- 201:ddceffffdcefffffceffffffefffffffffffffffffffffffffffffffffffffff
-- 202:ffffffffffffffffffffffffffffffffffffffffffffffffffffffeefffeeeee
-- 203:fffffffffffffff0fffffeeeffffeeeefffeeeeefeeeeeeeeeeeeeeeeeeeeeee
-- 204:000000000000000000000000f0000000e0000000ef000000ee000000eef00000
-- 205:0fffffff0fffffff00ffffff000fffff0000ffff00000fff000000ff0000000f
-- 206:fffffeeeffffeeeeffffeee2ffffeee5fffff223fffff222ffff1334ffff1322
-- 207:e1242210e224221035242210323322f02332210035221f003221f000221f0000
-- 208:00000f11000000f1000000000000000000000000000000000000000000000000
-- 209:1111ffff1111ffff0f1ffff00000000000000000000000000000000000000000
-- 211:00000eee0000feee0000eeed0000eed00000edd00000ed000000ed000000fc00
-- 212:eedddddedddddddd000000dd00ffff0d0ffffff00fffffffffffffffffffffff
-- 213:eeeeeeefdeeeeeeeddeeeeeeddddeeeedddddeeefcddddeeffcdddeeffedddde
-- 214:ffffffffeeffffffee00ffffe0000000e0000000e0000000f000000000000000
-- 215:ffffffcdffffffcdffffffcdffffffcd00000000000000000000000000000000
-- 216:dcffffffdcffffffdcffffffdcffffff00000000000000000000000000000000
-- 217:ffffffffffffffeeffff00ee0000000e0000000e0000000e0000000f00000000
-- 218:feeeeeeeeeeeeeedeeeeeeddeeeeddddeeedddddeeddddcfeedddcffeddddeff
-- 219:edddddeedddddddddd000000d0ffff000ffffff0fffffff0ffffffffffffffff
-- 220:eee00000eeef0000deee00000dee00000dde000000de000000de000000cf0000
-- 222:ffff1111ffff11110ffff1f00000000000000000000000000000000000000000
-- 223:11f000001f000000000000000000000000000000000000000000000000000000
-- 227:00000cd000000ccf000000cf0000000c00000000000000000000000000000000
-- 228:ffffffffffffffffffffffffffffffffcdffffff0ccfffff00cccccc00000000
-- 229:ffecddd0ffecdde0fffcdde0ffedde000edde000ede00000cc00000000000000
-- 234:0dddceff0eddceff0eddcfff00eddeff000edde000000ede000000cc00000000
-- 235:ffffffffffffffffffffffffffffffffffffffdcfffffcc0cccccc0000000000
-- 236:0dc00000fcc00000fc000000c000000000000000000000000000000000000000
-- </TILES2>

-- <TILES3>
-- 000:1111111111111111111111111111111111111111111111111111111111111111
-- 001:1111111111111111111111111111111111111111111111111111111111111111
-- 002:1111111111111111111111111111111111111111111111111111111111111111
-- 003:1111111111111111111111111111111111111111111111111111111111111111
-- 004:1111111111111111111111111111111111111111111111111111111111111111
-- 005:1111111111111111111111111111111111111111111111111111111111111111
-- 006:111111111111111e111111ec11111ecd1111ecdd111ecddd111ecddd11ecdddd
-- 007:eeee1111cddce111dddde111dddce111ddcde111dcde1111ccde1111ccde1111
-- 016:1111111111111111111111111111111111111111111111111111111111111111
-- 017:111111111111111111111111111111111111111111111111111111111111eeee
-- 018:11111111111111111111111111111111111eeeee1eeecccceeecccbceecccbcc
-- 019:11111111111111111eeeeeeeeeeeeeeeeeeeddddceeeedddceeeedddceeedddd
-- 020:1111111111111111eeeeeee1eeeeeeeedddddddedddddddddddddddddddddddd
-- 021:11111111111111111111111eeee111eeeeeeeeecdddddddddddddddddddddddd
-- 022:1ecddddcecdddddccdddddcccddddcccdddddcccdddddcccdddddcccdddddccc
-- 023:ccde1111cce11111cde11111dee11111cdde1111cccde111ccccde11ccccde11
-- 032:111111111111111e11111dde1111dbbe111dbbbe11dbbbbe11dbbbbe11dbbbbe
-- 033:11eedddeeeddddddedddddddedddddddedddddddedddddddedddededeedddddd
-- 034:eeccccccdeeeeeeeddddddddddddddddddddddddddddddddededededdddddddd
-- 035:eeddddddddddddddddddddddddddddddddddddddddddddddededededdddddddd
-- 036:ddddddddddddddddddddddddddddddddddddddddddddddddededededdddddddd
-- 037:ddddddddddddddddddddddddddddddddddddddddddddddddededededdddddddd
-- 038:dddddcccdddddddddddddcccdddddcccdddddcccdddddccceddddcccdcdddccc
-- 039:cccce111ddee1111de111111cde11111ccdee111cccdee11ccdee111ddee1111
-- 048:11dbbbbe111dbbbe1111ddde1111111111111111111111111111111111111111
-- 049:edeccdcceeedeeedeeeeeeee11100111111ff11111ffff1111ffff11111ff111
-- 050:cdcccdcceeedeeedeeeeeeee1111111111111111111111111111111111111111
-- 051:cdcccdcceeedeeedeeeeeeee1111111111111111111111111111111111111111
-- 052:cdcccdcceeedeeedeeeeeeee111100111111ff11111ffff1111ffff11111ff11
-- 053:cdcccdcceeedeeedeeeeeeee11100111111ff11111ffff1111ffff11111ff111
-- 054:ceeeeeeeeeeeeee1eeee11111111111111111111111111111111111111111111
-- 055:ee11111111111111111111111111111111111111111111111111111111111111
-- </TILES3>

-- <SPRITES>
-- 000:ffffffffeeeeeeee4fdd4fddfdd4fdd4fdd4fdd44fdd4fddeeeeeeeeffffffff
-- 001:ffffffffeeeeeeeefdd4fdd4dd4fdd4fdd4fdd4ffdd4fdd4eeeeeeeeffffffff
-- 002:ffffffffeeeeeeeedd4fdd4fd4fdd4fdd4fdd4fddd4fdd4feeeeeeeeffffffff
-- 003:ffffffffeeeeeeeed4fdd4fd4fdd4fdd4fdd4fddd4fdd4fdeeeeeeeeffffffff
-- 004:00ffffff0feeeeeefeed4fddfed4fdd4fed4fdd4fedd4fddfefddfdefe4ff4ef
-- 005:00ffffff0feeeeeefeddddd4fefddf4ffe4ff44ffed44dd4fedddddefefddfef
-- 006:00ffffff0feeeeeefeeddd4ffeddd4fdfefdd4fdfe4ff44ffed44ddefeddddef
-- 007:00ffffff0feeeeeefeedd4fdfedd4fddfedd4fddfefdf4fdfe4ff4defed44def
-- 008:fffff0d1ffff0d110000d110dddd110f1111110f00001110ffff0111fffff01d
-- 009:000fffff4440ffff00440000ff044434ff044434004400004440ffff000fffff
-- 010:ff04fffffff04fff0ff04fff40004ffff44444ffffff444ffffff444ffffff44
-- 011:f40ff04ff40ff04fff4004fffff44fffff1441fff114411f11133111c1f44f1c
-- 012:000000000600500000506060006b65000b6766b00bc77cb00bccccb000bbbb00
-- 013:76700000c7c00000bcb000000000000000000000000000000000000000000000
-- 014:00000000000f000000fc00000fcffff00cccccc000cf0000000c000000000000
-- 015:00dddd00020000d0d020000dd002000dd000200dd000020d0d00002000dddd00
-- 016:3000000300000000000000000000000000000000000000000000000030000003
-- 017:bbbbccddb0000000b0000000c0000000cd000000cdddddddcd000000c0000000
-- 018:ddccbbbb0000000b0000000b0000000c000000dcdddddddc000000dc0000000c
-- 019:000b0000000c00000bcbcb0000bcb000000b0000000000000000000000000000
-- 020:deecceedeffffffeecccccceeffffffeeffffffeeffffffeefff404edeee040d
-- 021:00fff00000fdcf0000fe43f000f43ddf00f43ccf00fc43df00efcdcf00fffff0
-- 022:000fff0000fcdf000fe43f00fd43df00fc43cf00fdc43f00fcdcfe000fffff00
-- 023:e4f000004df00000d4f000000000000000000000000000000000000000000000
-- 024:6560000034500000654000000000000000000000000000000000000000000000
-- 025:0300000034300000030000000000000000000000000000000000000000000000
-- 026:cd111111dcd111111dc111111111111111111111111111111111111111111111
-- 027:44444444444ef04444f000444400f0044f000004400f00f444f00f4444444444
-- 030:b0000000bb000000bbc00000bde0000000000000000000000000000000000000
-- 031:0000000000300000034000003433333344444444040000000040000000000000
-- 032:3030303000000003300000000000000330000000000000033000000003030303
-- 033:d0000000d0000000c0000000c0000000b0000000b0000000b0000000bbbbccdd
-- 034:0000000d0000000d0000000c0000000c0000000b0000000b0000000bddccbbbb
-- 035:000000000fcccc000fc0fc000fcccce00fcccce00fcccc00fcccccc000000000
-- 036:00000000d00cd00decccccce000dd000000ee000000320000003300000023000
-- 039:a9a0000034900000894000000000000000000000000000000000000000000000
-- 040:2210000034200000124000000000000000000000000000000000000000000000
-- 041:0ed00000efe00000dd0000000000000000000000000000000000000000000000
-- 042:fe000000efd000000ef000000000000000000000000000000000000000000000
-- 043:bcc11111ccc11111ccd111111111111111111111111111111111111111111111
-- 044:4331111133311111334111111111111111111111111111111111111111111111
-- 045:000fffff00fcdfee0fe43fcdfd43dfd4fc43cfd4fdc43fcdfcdcfeee0fffffff
-- 046:000fffff00fcdfee0fe21fcdfd21dfd2fc21cfd2fdc21fcdfcdcfeee0fffffff
-- 047:000fffff00fcdfee0fea9fcdfda9dfd9fca9cfd9fdca9fcdfcdcfeee0fffffff
-- 048:0000000000000000ddd00000f4ec00004ff4c000f4ec0000ddd0000000000000
-- 049:0000000000000000ddd000004fec0000ff4ec0004fec0000ddd0000000000000
-- 050:0000000000000000ddd00000ff4c0000f4fec000ff4c0000ddd0000000000000
-- 051:0252500020000000500000002000000050000000000000000000000000000000
-- 052:0003200000023000000330000002300000033000000230000002300000033000
-- 053:111111111111111c1111111011111c0011111000111c000b111000b01c000000
-- 054:11111111011111110011111100011111b00011110000011100b000110b000c11
-- 056:00000000000bbbbb00bccccc0bceceee0bece9dd0bdcedff0bccedee0bccedff
-- 057:00000000bbbbbbbbdccdcdcceeeeeeeedddddd99ffffffd9eeeeeed9ffffffd9
-- 058:00000000bbbbb000cdcccb00eeececb0bb9eceb0cc9eceb0cc9ecdb0dd9eccb0
-- 060:00ed0e00edfddfd0efdeedfe0dedfeddddefded0efdeedfe0dfddfde00e0de00
-- 061:11111111111111111111111111111f441111143f111114f31111114411ff1144
-- 062:1111111111111111111111f411111f4444443441444434411111114411ff1114
-- 063:111111111111111144f111111111111111111111111111111111111144111111
-- 064:00b0000000b0000000bbb000b0bbb0000bbbb00000dd00000000000000000000
-- 065:000000000bb000000bbb0000bbbb0000bbbb00000dd000000000000000000000
-- 066:000efffe000fccdf00f4dde00f4defd00f4dfed000f4dde0000fccf0000fccff
-- 067:004ecd0004eeede0004ecde0000dcd00000dcd00004ecde004eeede0004ecd00
-- 068:0002300000032000000cd000000dc000000ce000000cd0000000000000000000
-- 069:100000001100000b1110000011110000111110001111110c1111111d11111111
-- 070:b0001d11000c1111001d11110c1111111d111111111111111111111111111111
-- 072:0bcdedee0bdcedff0bccedee0bdcedff0bcdedee0bdce9dd0bcde9990bdcebcd
-- 073:eeeeeed9ffffffd9eeeeeed9ffffffd9eeeeeed9dddddd9999999999cdccdcdf
-- 074:cc9ecdb0dd9eccb0cc9ecdb0dd9eccb0cc9ecdb0dd9eccb0ff9ecdb0bcfeccb0
-- 075:0bbbbbd0b8dd989bbdffd98dbdeed89bb9dd898db8989f9bb989f5fd0bbbdbd0
-- 077:1f44f1441f444f4411f44433111f4f44111f4f44111f44ff1111f44411111f4d
-- 078:1f44f1dff444fdee444fdeeef4fdffe4f4dffffe4deeffffdeeeefffffe4440f
-- 079:fdf11111ffdf1111effdf111440fdf11e40ffdf1e40efdf1feeedf11ffedf111
-- 080:0000000000212000020000000100000002000000000000000000000000000000
-- 081:1aaa0111a969a011a967a011a999a0111aaa0111111111111111111111111111
-- 082:000fccff000fccf000f4dde00f4dfed00f4defd000f4dde0000fccdf000efffe
-- 083:4500000056000000000000000000000000000000000000000000000000000000
-- 084:1ddd7771dddd7777dddd7777dddd7777bbbb9999bbbb9999bbbb99991bbb9991
-- 085:11111111141f1f11141f1f11141f1f11111111111111111313111132111d1321
-- 086:111fddf111f2eecf112b2eed1332eeed32dcccdc21fdee31111fdd1311111211
-- 088:0bcdebcd0bdce9990bceceee0becccdc0beccdcd00bccccc000bbbbb00000000
-- 089:cdccdcdf99999999eeeeeeeedcdcdcdccdcdcdcdcccdcccdbbbbbcbb00000000
-- 090:cdfecdb0ff9eccb0eeececb0dcdcceb0cdcdceb0cdcdcb00bcbbb00000000000
-- 091:000000000d0000c0008009000008900000098000009008000c0000d000000000
-- 092:040000000b0000000b000000ebe00000fef00000000000000000000000000000
-- 093:11111f4d11111144111111ff1111111111111111111111111111111111111111
-- 094:fffee40fdfffe40efdfffeee1fdfffed11fdffdf111fddf11111ff1111111111
-- 095:ffdf1111fdf11111df111111f111111111111111111111111111111111111111
-- 096:0011110001111100111888001188880011888800118888000000000000000000
-- 097:1111111111141111111c4111111cc411111cc211111c21111112111111111111
-- 098:111111111111111111141411111c1c11111c1c11111c1c111112121111111111
-- 099:44444111c0c0c111cc0cc111c0c0c111ccccc111222221111111111111111111
-- 100:111111111111111111144111114cc41111cccc11112cc2111112211111111111
-- 101:1131e211e11c1e111dcbcd1111dc1211b11d11111111b12111e1111111111111
-- 102:11111111111f1f11111efe11b32ccccddccfeddc111f1ef11111fef111111ef1
-- 103:111f1f111bdefec1b22565dcb32ddddf1bdfecde1d1f1ef11e11fef111111ef1
-- 104:11111111111ff1111ccdfcedc23d4e6cc22d5e7c1ccdfced111ff11111111111
-- 106:00fbbf0c0fb77bfb0b7657b00be77eb00ceccec002beeb20200cc00200300300
-- 107:00fbbf000fbee7f00bee76500beee7700cdbcec0003ee2b0030b200c00020000
-- 108:000fff0002febef020cb75ef0cbcc7bf0cceccefceccbcf00cecc02000c00200
-- 109:00feef000febbef00cbeebc0ebccccbe0c2cc2c002ceec202003300200300300
-- 110:00300300200330022bceecb202bddb20ebdccdb00cb77bc00f7557f000feef00
-- 112:ccffffffcdf00000ff000000f0000000f0000000f0000000f0000000f0000000
-- 113:fcccccff00cdc000000e0000000c0000000e0000000c0000000e0000000c0000
-- 114:ffffffcc00000fdc000000ff0000000f0000000f0000000f0000000f0000000f
-- 115:111111bb11111bbd1111bbbb1fe1bbcb1dddbc0c1fe1bc0c1fe1bbcb1fe1bbbb
-- 116:bbbbbbb1bdbdbdbbbbbbbbbbbbcbbbcbbc0cbc0cbc0cbc0cbbcbbbcbbbbbbbbb
-- 117:111111111111bb11b11cccc1b1bbccbbbdbe000bb1c0000cbdb0000bb1bbccbb
-- 118:f11111b1f0dedb0bf1bbb1befbc00b1feb000b1eeb000bef11bbb1111deded11
-- 122:00000000000000000000000000ffff000ffffff00ffffff000ffff0000000000
-- 123:00000000000000000000000000ffff000ffffff00ffffff000ffff0000000000
-- 124:000000000000000000000000000ff00000ffff0000ffff00000ff00000000000
-- 125:00000000000000000000000000000000000ff00000ffff00000ff00000000000
-- 126:0000000000000000000000000000000000000000000ff0000000000000000000
-- 128:f0000000f0000000f00000d0f0000de0f000defdf0000ff0f00000e0f0000000
-- 129:000e0000000c0000000e0000000c0000ddcedddd000c0000000e0000000c0000
-- 130:0000000f0000000fe000000fff00000ffed0000fed00000fd000000f0000000f
-- 131:1fe11bbd1fe1bb001fe1b00c1fe1b0001dddb0001fe1b0001feebb001fffbbbd
-- 132:bdbdbdbb0000000b000000000000000000000000000000000000000bbdbdbdbb
-- 133:111cccc1b111bb11b111ef11b111ef11b1eeef11bdefff11b1ef1111bdef1111
-- 134:bcb11111c0c11111bcb111111111111111111111111111111111111111111111
-- 136:000000000000000000000000000cccc000cfefed00cfefbc00eddbff00eeebff
-- 137:000000000000000000ee00000effe0000feef0000ffff000ceffeeb4ceeeebb3
-- 138:000000000000000000000000000000000000000000000000dddd0000dddded00
-- 140:0000000d00000dbb000ecbbb00eccbb900cbbab90cccaabc0cc9acbb0ddcbbbb
-- 141:cbbbbbcdbbbcbbbbbbbbb9cb9abbbccc9bbccaaabb9cc989a98abc8bbbcaacbb
-- 142:d0000000ddd00000b9cdd000bb8ddd00cbcdcd00bbdddcd0b9d8ddd099d88de0
-- 143:00bbbd000bbbbbc0ccbbccdcc9acb9dfd9caccdfdcaad9efe9dc9d8f0e9ee8f0
-- 144:f0000000f0000000f0000000f0000000f0000000ff000000cdf00000ccffffff
-- 145:000e0000000c0000000e000000ccc00000d4d0000dfffd000d4f4d00fdf4fdff
-- 146:0000000f0000000f0000000f0000000f0000000f000000ff00000fdcffffffcc
-- 147:11111bbb111111bb111111bd11eccccc1ecccced11eccccc111eeeee11111111
-- 148:bbbbbbbbbbbbbbb1ddddddb1ccccccccededdeddcccccccceeeeeeee11111111
-- 149:11ee111111dd11111eeee111ccccce11eecccce1ccccce11eeeee11111111111
-- 150:0000000000c423320c43cdcc0ccccdcd0dc432330d4221220c31cccc0c21deee
-- 151:00000d003000d0d03323edf0feedeef02332eff01221eef0eddceffddddceefd
-- 152:00feeccc00fffcdd00999cac09889aac09cccc9909ddd99909ceeeee08ceeeee
-- 153:eddeebd2edddeee2aeddeeeeaeeeebbc9eeeebcc9fffffffedddddddeddddddd
-- 154:dedeeed0eeeefee0eeedfee04ddefe003eeeedd0fffdffd0ddddfe00dffdfe00
-- 156:ddd9cbcadd89ccccdd8cc99cdecca9acedee9a9cdeefccbce8fc89cef88c999e
-- 157:ccbbbbc9aaaacdcdaaabbccd99bbaadacbbaaac9dbaaaadaecaaaacdffccdcdd
-- 158:888d88df989d8deedd8dceef98dddffe99ddffff9cdeeeffcd8e88ffa89e88ff
-- 160:cec00000efe00000cec000000000000000000000000000000000000000000000
-- 161:4310000000400000431000000000000000000000000000000000000000000000
-- 163:000ff00000cffe0000cdde0004deed200433232044222222432ff212432ff212
-- 164:ccc000dec33233dee2cdccdedefdccbceeffeefddefe34eddefdddd00dd00000
-- 165:0ccc00000dddedd099bbeb4c99daec3d89a9edde88eecce0c8ec33ce0cefccfe
-- 166:0ecdefee0deefffc0edeefc30deeffc20deedfcc00dd0ddd0000000000000000
-- 167:eeeeccdfcccfeeff232ceefd342ceefdcccceed0dddddd000000000000000000
-- 168:08d888df00d88dff00de8dff0cee0dff0eccdfff00eedfff0000dfff00000000
-- 169:efffffffffccccccec343343fc344443ec222222ffccccccefffffff00000000
-- 170:effdff00ffffdf00cfffdf00cfffdf00cffffd00fffffd00effffd0000000000
-- 172:0e8d89d90fefedd800ffff980000ffe8000000ff000000000000000000000000
-- 173:faaaa8dd9d8998ed98d88e8a88fee888ffeddeff000000000000000000000000
-- 174:da8e8ff0eeffeff08effff00efff0000ff000000000000000000000000000000
-- 176:0d000000cec000000d0000000000000000000000000000000000000000000000
-- 177:0f4d000000fc00000f4d00000000000000000000000000000000000000000000
-- 178:f4f000004cd00000f4f000000000000000000000000000000000000000000000
-- 179:fdffffffdbdfffffbfbfffffbbbfffffbbbfffffffffffffffffffffffffffff
-- 180:fbffffffbdbfffffdfbfffffbbbfffffbbbfffffffffffffffffffffffffffff
-- 181:22222fff20202fff22022fff20202fff22222fffffffffffffffffffffffffff
-- 182:1111111111141111111241111444c4111222c211111421111112111111111111
-- 188:0200000032200000212000000000000000000000000000000000000000000000
-- 189:0700000057700000767000000000000000000000000000000000000000000000
-- 190:0f0000004ff00000f6e000000000000000000000000000000000000000000000
-- 191:09000000a9900000989000000000000000000000000000000000000000000000
-- 192:111d011111ccd0111cbccd01ccccccd01ccccc0111ccc011111c011111111111
-- 193:111301111133301113b333013333333013333301113330111113011111111111
-- 194:1111111111cc01111ccdc0111cdcdc0111cdcdc0111cdcc01111cc0111111111
-- 195:0000000003332230032232200000000003332230023223200000000000000000
-- 196:00ec0e00ecfccfc0efceecfe0cecfeccccefcec0efceecfe0cfccfce00e0ce00
-- 197:0000000000003f00003003f003f303f003f303f003fff3f000333f0000000000
-- 198:000000000c0d00000d0c00000d0d00000c0d00000c0c00000d0d000000000000
-- 199:000000000bd00000bbbd00000bbbd00000bbbd00000bbbd00000bd0000000000
-- 200:0666666734444466666664663444644466646666006444440066666600000000
-- 201:0222222134444422222224223444244422242222002444440022222200000000
-- 202:0999999834444499999994993444944499949999009444440099999900000000
-- 203:0ccccccd344444ccccccc4cc3444c444ccc4cccc00c4444400cccccc00000000
-- 204:000dd000000ee000000cc00000d32d000d3222d00c2232c00d2222d000dd3d00
-- 205:000dd000000ee000000cc00000d56d000d5666d00c6656c00d6666d000d77d00
-- 206:000dd000000ee000000dd00000dffc000cf4ffc00dffffc00dffffe000cddc00
-- 207:000dd000000ee000000cc00000da9d000d8998d00c9999c00d99a9d000d89d00
-- 208:3334444331222223323333433222334332332223131111211322222111111111
-- 209:cccccccccf88888cc823ccdcc83ccc4cc8ccc34cf0ffff82f08888811fffff11
-- 210:ccccccccc8f8f8fcfa8a8a8fca8a8a8ccccccccc8f0f0f088f0f0f0888888888
-- 211:3230000000000000233000000000000000000000000000000000000000000000
-- 212:1111111111111111bbbbbbbbdcdcdcdccdcdcdcdbbbbbbbb1111111111111111
-- 213:bbb11111dcd11111bbb111111111111111111111111111111111111111111111
-- 214:4430000032200000133000000000000000000000000000000000000000000000
-- 215:bb000000bbb000000bd000000000000000000000000000000000000000000000
-- 219:11111111111111111111bb11111b9b1111b89b111b9a9b1bb8989bc8baaaabca
-- 220:111111111111111111bb11111b9b111bb89b11b89a9b1b9a989bc898aaabcaaa
-- 221:1111111111111111bb1111bb9b111b9b9b11b89b9b1b9a9b9bc8989babcaaaab
-- 222:0e0e0e0000dcd0000001000000010000000100000001000000010000000e0000
-- 223:e00cd00e0eedcee0000cd000000dc000000cd000000dc000000cd000000dc000
-- 225:6066666600066666f0f666666666666666666666666666666666666666666666
-- 226:6660666666000666660f066660e0006660000066600000666600066666666666
-- 227:111111111bb11bb1ddddddddcccccccccedededccedededcceeeeeeccccccccc
-- 228:dbe11111dee11111ccc111111111111111111111111111111111111111111111
-- 232:66666cff66666cf06666fcf06666fcff666cfcee666cfeee664cffff664ce000
-- 233:ff0666660ff666660f006666fff06666ee0fe666eee0e666ffffe266000fe266
-- 235:b8989bc8baaaabcab898bbc8baababcab8b89bc8bbaaabcbb8989bc8baaaabca
-- 236:989bc898aaabcaaa98bbc898ababcaabb89bc8b8aaabcbaa989bc898aaabcaaa
-- 237:9bc8989babcaaaabbbc898bbabcaabab9bc8b89babcbaaab9bc8989babcaaaab
-- 238:bab1111198911111bab111111111111111111111111111111111111111111111
-- 246:6e666666431666664f2666666666666666666666666666666666666666666666
-- 247:666ff66666cffe6666cdde6664deed266433232644222222432ff212432ff212
-- 248:644cedde644eddde444e1122443233ee443233e043222ee043233ec066233ec0
-- 249:eddfe226edddf2262211f222ee3321220e3321220ee221120ce332120ce33266
-- 251:b8989bc8baaaabcab8989bc8baaabfbab89b1eb8babfeebabb1111bb11111111
-- 252:989bc898aaabcaaa989bc898aabfbaaa9b1eb89bbfeebabf1111bb1111111111
-- 253:9bc8989babcaaaab9bc8989bbfbaaabf1eb89b1eeebabfee11bb111111111111
-- 254:1bbbbbb1baaaaaabb898989bbaaaaaabb898989bbaaaaaabb898989b1bbbbbb1
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
-- 013:111111db111111ce111111bd111111c6111111b6111111b611111c661111c666
-- 014:cd111111ec111111dc1111116c1111116c1111115c11111166c11111665c1111
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
-- 029:111b6656111c566611b6666611b6657711c67666111b76561111d77711111cbb
-- 030:6666c1116566c11166666c1177766c1166676c116665c111777c1111bcb11111
-- 032:000000000000000c000000dd00000ded00000decddd00de0f4eccdc04ff4cddd
-- 033:00000000c0000000dd000000ced00000ded000000ed000000cdc0000ddddc000
-- 045:111111db111111ce111111bd111111cf111111bf111111bf11111cff1111cfff
-- 046:cd111111ec111111dc111111fc111111fc1111114c111111ffc11111ff4c1111
-- 047:000dd000000ee000000dd00000dffc000cf4ffc00dffffc00dffffe000cddc00
-- 048:f4ecec0dddcdec0d00dec00d0cdec00d0dec0fefcdec00fedec0000fdec00000
-- 049:e0cedc00e0cedc00e00ced00e00cedc0cf00ced0f000cedc00000ced00000ced
-- 061:111bff4f111c4fff11bfffff11bff4ee11cfefff111bef4f1111deee11111cbb
-- 062:ffffc111f4ffc111fffffc11eeeffc11fffefc11fff4c111eeec1111bcb11111
-- 077:111111db111111ce111111bd111111c9111111b9111111b911111c991111c999
-- 078:cd111111ec111111dc1111119c1111119c111111ac11111199c1111199ac1111
-- 079:000dd000000ee000000cc00000da9d000d8998d00c9999c00d99a9d000d89d00
-- 093:111b99a9111ca99911b9999911b99a8811c98999111b89a91111d88811111cbb
-- 094:9999c1119a99c11199999c1188899c1199989c11999ac111888c1111bcb11111
-- 099:00fbbf0d0fb77bfb0b7657b00be77eb00dedded002beeb20200dd00200300300
-- 100:00fbbf000fbee7f00bee76500beee7700cdbcec0003ee2b0030b200d00020000
-- 101:000fff0002febef020db75ef0dbcc7bf0dceccefcedcbdf00cedd02000c00200
-- 102:00feef000febbef00dbeebd0ebdccdbe0d2dd2d002deed202003300200300300
-- 103:00300300200330022bdeedb202bddb20ebdccdb00db77bd00f7557f000feef00
-- 129:11111111111ff1111ccdfcedc23d4e6cc22d5e7c1ccdfced111ff11111111111
-- 131:00fddf0d0fc77cfc0c7657c00ce77ec00decced002ceec20200dd00200300300
-- 132:00fddf000fcee7f00dee76500deee7700cdccec0003ee2d0030d200d00020000
-- 133:000fff0002fecef020dc75ef0dccc7cf0dceccefcedccdf00cedd02000c00200
-- 134:00feef000feccef00dceecd0ecdccdce0d2dd2d002deed202003300200300300
-- 135:00300300200330022cdeedc202cddc20ecdccdc00dc77cd00f7557f000feef00
-- </SPRITES1>

-- <WAVES>
-- 000:eeeeeeedcb9687777777778888888888
-- 001:0123456789abcdeffedcba9876543210
-- 002:06655554443333344556789989abcdef
-- 004:777662679abccd611443377883654230
-- 005:eeedddccbbaaaaaaabbbbcccb9210000
-- 007:55556777777776655555666778877776
-- 008:f00070c00600b00550dd000009a0cc00
-- 009:44444456789aabb97a654dc831347213
-- 010:0ddcba9888777666778899aabbddeeff
-- 012:67777777777777778888888888888999
-- </WAVES>

-- <SFX>
-- 000:5ac07a808ad0aaf0ba90daf0eaa0fa506a306a305a704a604a605a406a307a307a607a706a605a304a205a206a407a707a706a505a305a206a407a50227000060500
-- 001:8000800080009000a000c000e000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000220000000000
-- 002:090009000900090009000900090009000900090009000900090009000900090009000900090009000900090009000900090009000900090009000900a00000000000
-- 003:050005100520153025504560659085b095f0a5f0b5f0c5f0d5f0e5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0f5f0414000000000
-- 004:00ec00c170a4f076f037f00ff00df00af008f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000a0b000000000
-- 005:34073407340734073407f400f400f400f400040704070407040704070407040704070407040704070407040704070407040704070407040704070407200000000000
-- 006:09000900090009000900090009000900090009000900090009000900090009000900090009000900090009000900090009000900090009000900090030b000000000
-- 007:05f005b0159025604550653075209510a500b500c500d500e500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500f500404000000000
-- 008:00e800c970aaf07cf03ef00ff00ff000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000f000a0b000000000
-- 009:46e09680f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600202000000000
-- 010:b672c672d677c604f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600282000040404
-- 011:46e0c630e610f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600f600502000000000
-- 012:0ae00ac00ab00aa00ab00ac00ab00a900a700a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a00f12000000900
-- 013:09f019f019f039f039f049f0f9f0f9f019f019f029f039f049f059f0f9f0f9f009f029f0f9f0f9f009f029f039f049f069f089f099f099f0b9f0e9f0422000000000
-- 016:0a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a000a00404000000000
-- </SFX>

-- <PATTERNS>
-- 000:800024000020100000000000800005000000100000000000800024000000100000000000800024000000100000000000900024000000100000000000900024000000100000000000900024000000100000000000900024000000100000000000400024000000100000000000400024000000100000000000400024000000100000000000400024000000100000000000400024000000100000000000400024000000100000000000400024000000100000000000400024000000100000000000
-- 001:500026000000800028000020c00028000000500026000020800028000020c00028000000800028000000500026000000700026000000800028000000c00028000000700026000000800028000000c00028000000800028000000700028000000800026000000c00028000000d00028000000800026000000c00028000000d00028000000c00028000000800028000000700026000000800028000000a00028000000800028000000c00028000000a00028000000800028000000700028000000
-- 002:500024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000800024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000700024000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 003:50002a80002aa0002ac0002a50002a80002aa0002ac0002a83a62a00000000000000000000062000000000000000000050002a80002aa0002ac0002a50002a80002aa0002ac0002aa7d62a00000000000000000000062000000000000000000050002a80002aa0002ac0002ad0002ac0002aa0002a80002ac0002aa0002a80002aa0002ac0002ad0002ac0002a80002aa0002a80002aa0002a80002aa0002ac0002aa0002a80002ac0002aa0002a80002a70002aa0002a80002a70002af00028
-- 009:6ff103988103b66103d44103022101011100011100100000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 010:6fc226000020000000000000000020000000000000000000dfc226000000000000000000000000000000000000000000bfc226000000000000000000000000000000000000000000aff226000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bfc226000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 011:6fc2260000200000000000000000200000000000000000006ce226000000000000000000000000000000000000000000bfc226000000000000000000000000000000000000000000aff226000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000bfc226000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 012:6000c60000000000000000006000c60000004000c60000c06000c6000000000000000000e000c40000009000c60000004000c80000004000c8000000e000c6000000e000c6000000d000c6000000d000c60000009000c60000009000c6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </PATTERNS>

-- <TRACKS>
-- 000:2000002c0000480300000000000000000000000000000000000000000000000000000000000000000000000000000000000020
-- 001:d00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000020
-- </TRACKS>

-- <FLAGS>
-- 000:00000000000000001000000000000000000000000000000010000000000000000000000000000000101000000000000000000000000000000000000000000010000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </FLAGS>

-- <SCREEN>
-- 049:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000422000000000000000000000
-- 050:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003222300000000000000000000
-- 051:000000022333333333330000000002333333333333330000000333333333333333333300000000000233333333333333333300003333333333333333333330000000333333333333333333300000000023333333333333300000000333333330000000000000000000000042222220000000000000000000
-- 052:000000223222222222232000000023222222222222223000003222222222222222223230000000022322222222222222333230003222222222222222222223000003202222232322222222233000000232222222222222230000003022222223000000000004400000000422222240000000000000000000
-- 053:0000002333322222222320000000322222222222222200000032222222222222222333230000000233332222222222222332330023333222222222222222230000032222222222222222222203000f0322222222222222200000032222222223000000000022242000222222222224200000000000000000
-- 054:000002333333322222232000000022222222222222222000000222222222222222233332300000023333332222222222222233002333322222222222222220000002222222222222222222222300003222222222222222220000032222222223000000000002222222222222222222220004422000000000
-- 055:000002333333222322222000000202222222222222222000002222333333333222222233200000023333333300002322222233002333333333333333322220000002222222333333222222222200003022222222222222220000022322223320000000000000022222222222222222222222220200000000
-- 056:000002333333000000000000000022222222000200000000002222222222222222222223200000223333333300000222222233000220222222222222222220000002222222222222222222222200000222222220002000000000022222222220000000000000222222200000000222222222000000000000
-- 057:000002333333200000000000000022222220000000000000000000000000000022222223200000223333333300000322222233000000000000000000000000000000000000000000332222222200000222222200000000000000000000000000000000000042222222200000000034322222200000000000
-- 058:000002333333200000000000000023322230000000000000000000000000000002222223200000223333333300000322222233000000000000000000000000000000000000000000032222222200000233222300000000000000000000000000000000000422222220000000000002233222220000000000
-- 059:000002333333200000000000000023332330000000000000000000000000000002332233200000223333333300003322233333000000000000000000000000000000000000000000032233222200000233323300000000000000000000000000000000444232222200000000000000044222222f00000000
-- 060:00000233333320000000000000002333333000000000000000000000000000000233333320000022333333333333223333333300000000000000000000000000000000000000000003222233220000023333330000000000000000000000000000000422223222220000000000000003c223222444000000
-- 061:00000233333320000000000000003333333000000000000000222222222222222233333320000023333333333333333333333200000f323223333330000000000002222222200000033333332200000333333300000000000000000000000000000022222232222200000000000000024223322222400000
-- 062:00000233333320000000000000003333333000000000000000233333333333333333333320000023433333333333333333332000000f333333333330000000000004333332220000033333333200000333333300000000000000033333333322000020222232222200000000000000004223322222240000
-- 063:00000233333320000000000000023333333000000000000000033333333333333333333320000023433333333333333333330000000f333333333330000000000004333333220000033233332200002333333300000000000000033333333320000000000032223220000000000000023333322222200000
-- 064:000003333333200000000000000233333330000000000000000333333332222223333333200000234333333320000002000000000000333333333330000000000004333332200000032223332200002333333300000000000000333333333330000000000023223322000000000000322333220000000000
-- 065:000002333333333333332200000023333330000000000000002333333320000003333333200000224333333300000000000000000000333333333332000000000024333332222222222223332200000233333300000000000000323332233330000000000003332232222000000003223332000000000000
-- 066:000002333333333333332200000023333330000000000000002333333300000003333333200000023333333300000000000000000000333333333332000000000024333333222223222233322200000233333300000000000000323232222330000000000003433222222222223222333322000000000000
-- 067:000002333333333333332200000023333330000000000000000233333300000003333333200000023333333300000000000000000000333333333330000000000004333333322233333333222200000233333300000000000000323222222230000000000042333322222222222233333220400000000000
-- 068:000000023333333333332000000022233230000000000000000223333300000003333333200000023333333200000000000000000000333333333330000000000004333333333333333332222000000222332300000000000000322222222320000000000432234322222233322333332000040000000000
-- 069:000000002222222222220000000000222230000000000000000023333300000002333222000000002222222000000000000000000000322223333330000000000003333333322233333322220000000002222300000000000000032222222200000000000422200440222222222222000022240000000000
-- 070:000000000000000000000000000000222020000000000000000022222200000002222200000000000000000000000000000000000000233002222220000000000200333333222222222220000000000002220200000000000000003222222000000000000000000000002222220000000222200000000000
-- 071:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000422200000000000000000000000
-- 072:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000422200000000000000000000000
-- 073:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000042200000000000000000000000
-- 100:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000099999999999999999999999999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 101:00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000099999944f94f99999999994f999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 102:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000999994f99444f44f94f4f444f99999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 103:0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009999994f994f9944f44f994f999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 104:00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000099999994f94f94f4f4f9994f999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 105:0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000009999944f9994f444f4f99994f99999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 106:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f9999999999999999999999999999f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 107:0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 110:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000099999999999999999999999999999999999999990000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 111:00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000099999944f9999999994f99999999944f9999999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 112:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000999994f9994f944f9444f4f4f94f994f9944f99999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 113:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000999994f994f4f4f4f94f944f94f4f94f944f999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 114:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000999994f994f4f4f4f94f94f994f4f94f9994f99999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 115:00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000099999944f94f94f4f994f4f9994f9444f44f999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 116:000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000f9999999999999999999999999999999999999999f000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- 117:0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000ffffffffffffffffffffffffffffffffffffffff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
-- </SCREEN>

-- <PALETTE>
-- 000:1010105d245db13e50ef9157ffff6daee65061be3c047f5005344c185dc95999f6eaeef2b6baba8d8d8d444455282030
-- </PALETTE>

-- <PALETTE1>
-- 000:1010105d245db13e50ef9157ffff6daee65061be3c047f5005344c185dc95999f6e6eaf2b6baba8d8d9d444460282038
-- </PALETTE1>

-- <PALETTE2>
-- 000:1010105d245db13e50ef9157ffff6daee65061be3c047f5005344c185dc95999f6eaeef2b6baba8d8d8d444455282030
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

