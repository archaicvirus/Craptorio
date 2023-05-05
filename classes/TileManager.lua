-- local TileMgr = {}
-- TileMgr.__index = TileMgr

-- function TileMgr.new()
--   local self = setmetatable({}, TileMgr)
--   local tile_mt = {
--     __index = function(row, x)
--       local tile = TileMgr.create_tile(x, row.y)
--       row[x] = tile
--       return tile
--     end
--   }
--   local tiles_mt = {
--     __index = function(tiles, y)
--       local row = setmetatable({y = y}, tile_mt)
--       tiles[y] = row
--       return row
--     end
--   }
--   self.tiles = setmetatable({}, tiles_mt)
--   return self
-- end

-- function ore_sample(x, y, ore)
--   local scale = ore.scale
--   local noise = (simplex.Noise2D(x * scale + (ore.offset * scale) + offset * scale, (y * scale) + (ore.offset * scale) + (offset * scale)) / 2 + 0.5) * 16
--   return noise > ore.min and true or false
-- end

-- function TileMgr.create_tile(x, y)
--   for i = 1, #ores do
--     if ore_sample(x, y, ores[i]) then
--       return {tile = ores[i].id, rot = math.random(4) % 4, index = i, is_ore = true, color = ores[i].map_cols[floor(math.random(#ores[i].map_cols))]}
--     end
--   end
--   local id, r = 0, math.random(4) % 4
--   if math.random(100) > 95 then
--     id = floor(math.random(8) % 8)
--     r = 0
--   end
--   return {tile = id, rot = r, index = 1, is_ore = false, color = 4}
-- end

-- function TileMgr:get_tile_screen(screen_x, screen_y)
--   local cam_x = player.x - 116
--   local cam_y = player.y - 64
--   local sub_tile_x = cam_x % 8
--   local sub_tile_y = cam_y % 8
--   local sx = floor((mouse_x + sub_tile_x) / 8)
--   local sy = floor((mouse_y + sub_tile_y) / 8)
--   local wx = floor(cam_x / 8) + sx + 1
--   local wy = floor(cam_y / 8) + sy + 1
--   return self.tiles[wy][wx]
-- end

-- function TileMgr:get_tile_world(world_x, world_y)
--   return self.tiles[world_y][world_x]
-- end

-- function TileMgr:set_tile(tile, world_x, world_y)
--   local id, r = 0, math.random(4) % 4
--   if math.random(100) > 95 then
--     id = floor(math.random(8) % 8)
--     r = 0
--   end
--   self.tiles[world_y][world_x] = {tile = id, rot = r, index = 1, is_ore = false}
-- end

-- function TileMgr:draw(player, screenWidth, screenHeight)
--   local cameraTopLeftX = player.x - 116
--   local cameraTopLeftY = player.y - 64

--   local subTileX = cameraTopLeftX % 8
--   local subTileY = cameraTopLeftY % 8

--   local startX = math.floor(cameraTopLeftX / 8)
--   local startY = math.floor(cameraTopLeftY / 8)

--   for screenY = 1, screenHeight do
--     for screenX = 1, screenWidth do
--       local worldX = startX + screenX
--       local worldY = startY + screenY
--       local tile = self.tiles[worldY][worldX]
--       local sx = (screenX - 1) * 8 - subTileX
--       local sy = (screenY - 1) * 8 - subTileY
--       if tile.is_ore then
--         sspr(ores[tile.index].tile_id, sx, sy, -1, 1, 0, tile.rot)
--       else
--         sspr(tile.tile, sx, sy, -1, 1, 0, tile.rot)
--       end
--     end
--   end
-- end

-- function TileMgr:draw_p(player)
--   local startX = player.x - 116
--   local startY = player.y - 64

--   for y = 0, 135 do
--     for x = 0, 239 do
--       local tile = self.tiles[startY + y - 1][startX + x - 1]
--       --trace(tile.index)
--       --local color = 4
--       -- if tile == 48 then tile = 5 end
--       -- if tile == 49 then tile = 0 end
--       -- if tile == 52 then tile = 14 end
--       -- if tile == 65 then tile = 3 end
--       -- if tile.is_ore then
--       --   color = ores[tile.index].map_cols[floor(math.random(#ores[tile.index].map_cols))]
--       -- end

--       pix(x, y, tile.color)
--     end
--   end
-- end

-- return TileMgr
local TileMgr = {}
TileMgr.__index = TileMgr

function ore_sample(x, y, tile)
  local biome = tile.biome
  for i = 1, #ores do
    local scale = ores[i].scale -- ((4 - biome)/100)
    local noise = (simplex.Noise2D(x * scale + ((ores[i].offset * biome) * scale) + offset * scale, (y * scale) + ((ores[i].offset * biome) * scale) + (offset * scale)) / 2 + 0.5) * 16
    --if noise >= ores[i].min and noise <= ores[i].max and ores[i].biome_id == biome then return i end
    if noise >= ores[i].min and noise <= ores[i].max then return i end
  end
  return false
end

function AutoMap(x, y)
  local tile = TileMan.tiles[y][x]
  TileMan.tiles[y][x].visited = true
  --Here, 'adj' is the north, east, south, and west 'neighboring' tiles (in local space)
  local adj = {
    [1] = {x = 0, y = -1},
    [2] = {x = 1, y = 0},
    [3] = {x = 0, y = 1},
    [4] = {x = -1, y = 0},
  }
  local key = ''
  for i = 1, 4 do
    --Grab the neighbor tile
    local near = TileMan.tiles[y + adj[i].y][x + adj[i].x]

    --Determine if neighbor is a '0' or '1', meaning 0 is land, 1 is water or a different biome
    if not near.is_land or near.biome < tile.biome then
      key = key .. '1'
      TileMan.tiles[y][x].border_col = biomes[near.biome].map_col
    else
      key = key .. '0'
    end
  end

  --Try to index the key we just created
  local new_tile = auto_map[key]

  --If key exists, then valid config detected, so set tile to the returned value, otherwise return
  if not new_tile then return end

  TileMan.tiles[y][x].sprite_id = new_tile.sprite_id + 11 + biomes[tile.biome].tile_id_offset
  TileMan.tiles[y][x].is_border = true
  TileMan.tiles[y][x].ore = false
  TileMan.tiles[y][x].rot = new_tile.rot
end

function TileMgr.new()
  --Creates a TileManager instance - cache's all the generated terrain in memory

  --Here, using __index metemethod, we can automatically trigger the create_tile
  --method whenever a non-existent value is indexed


  local self = setmetatable({}, TileMgr)
  local tile_mt = {
    __index = function(row, x)
      --Here's where the magic happens, in create_tile
      local tile = TileMgr.create_tile(x, row.y)
      row[x] = tile
      return tile
    end
  }
  local tiles_mt = {
    __index = function(tiles, y)
      local row = setmetatable({y = y}, tile_mt)
      tiles[y] = row
      return row
    end
  }
  self.tiles = setmetatable({}, tiles_mt)
  return self
end

function TileMgr.create_tile(x, y)
  --Replace with your own function, this gets called once whenever a 'new' tile is indexed

  local scale  = 0.003
  local scale2 = 0.07
  --Here we sample 2 noise values and blend them together
  local base_noise = (simplex.Noise2D(x * scale + offset * scale, (y * scale) + (offset * scale)) / 2 + 0.5) * 100
  local addl_noise = (simplex.Noise2D(x * scale2 + offset * scale2, (y * scale2) + (offset * scale2))) * 50

  --Now base_noise is used to determine biome and land/water
  base_noise = ((base_noise * 3) + addl_noise) / 4

  local tile = {
    noise = base_noise,
    is_land = base_noise > 20 and true or false,
    biome = base_noise < 30 and 1 or base_noise < 45 and 2 or 3,
    is_border = false,
    visited = false,
    b_visited = false,
    rot = math.random(4) % 4,
    flip = math.random() > 0.5 and 1 or 0,
    offset = {x = math.random(-2, 2), y = math.random(-2, 2)},
  }

  --If base_noise value is high enough, then try to generate an ore type
  tile.ore = tile.is_land and base_noise > 40 and ore_sample(x, y, tile) or false
  
  --Water tile by default
  tile.color = floor(math.random(2)) + 8
  tile.sprite_id = 79

  --If ore-generation was successful, then set sprite_id and color
  if tile.ore then
    tile.color = ores[tile.ore].map_cols[floor(math.random(#ores[tile.ore].map_cols))]
    tile.sprite_id = ores[tile.ore].tile_idd
  elseif tile.is_land then
    tile.color = biomes[tile.biome].map_col
    tile.sprite_id = biomes[tile.biome].tile_id_offset

    --Generate clutter based on biome clutter scale, ex grass, rocks, trees, etc
    if math.random(100) < biomes[tile.biome].clutter * 100 then
      tile.sprite_id = biomes[tile.biome].tile_id_offset + floor(math.random(10))
      tile.rot = 0
    end

  end
  return tile
end

function TileMgr:set_tile(x, y, tile_id)
  local tile = self.tiles[y][x]
  tile_id = tile_id or biomes[tile.biome].tile_id_offset
  if tile.is_land and not tile.ore and not tile.is_border then
    tile.sprite_id = tile_id
  end
end

function TileMgr:draw_terrain(player, screenWidth, screenHeight)
  local cameraTopLeftX = player.x - 116
  local cameraTopLeftY = player.y - 64
  local subTileX = cameraTopLeftX % 8
  local subTileY = cameraTopLeftY % 8
  local startX = math.floor(cameraTopLeftX / 8)
  local startY = math.floor(cameraTopLeftY / 8)
  for screenY = 1, screenHeight do
    for screenX = 1, screenWidth do
      local worldX = startX + screenX
      local worldY = startY + screenY
      local tile = self.tiles[worldY][worldX]
      local sx = (screenX - 1) * 8 - subTileX
      local sy = (screenY - 1) * 8 - subTileY

      --Here, AutoMap is called once per tile during draw
      --AutoMap is what sets the 'border' or edge tiles
      if not tile.visited and tile.is_land then AutoMap(worldX, worldY) end

      --If I'm a border tile, recolor to match neighboring biome
      if tile.is_border and tile.biome > 1 then
        sspr(biomes[tile.biome - 1].tile_id_offset, sx, sy, -1, 1, 0, tile.rot)
        sspr(tile.sprite_id, sx, sy, 9, 1, 0, tile.rot)

      --Normal terrain, not a border, water or ore
      elseif not tile.ore then
        local x, y, color_key, flip = sx, sy, -1, not tile.is_border and tile.flip or 0
        if tile.is_land and not tile.is_border then
          x, y, color_key, flip = sx + tile.offset.x, sy + tile.offset.y, biomes[tile.biome].map_col, tile.flip
          --Optionally draw grass everywhere else
          --sspr(biomes[tile.biome].tile_id_offset, sx, sy)
          rect(sx, sy, 8, 8, biomes[tile.biome].map_col)
        end
        --Draw tile's set sprite_id
        sspr(tile.sprite_id, x, y, color_key, 1, flip, tile.rot)
      end

      --If tile is an ore, we need to set the color_key to 'erase' the ore background, to overlay on terrain
      if tile.ore then
        if not tile.is_border then
          rect(sx, sy, 8, 8, biomes[tile.biome].map_col)
        end
        sspr(ores[tile.ore].tile_id, sx, sy, 4, 1, 0, tile.rot)
      end

    end
  end
end

function TileMgr:draw_clutter(player, screenWidth, screenHeight)
  local cameraTopLeftX = player.x - 116
  local cameraTopLeftY = player.y - 64
  local subTileX = cameraTopLeftX % 8
  local subTileY = cameraTopLeftY % 8
  local startX = math.floor(cameraTopLeftX / 8)
  local startY = math.floor(cameraTopLeftY / 8)
  
  for screenY = 1, screenHeight + 2 do
    for screenX = 1, screenWidth + 2 do
      local worldX = startX + screenX
      local worldY = startY + screenY
      local tile = self.tiles[worldY][worldX]
      local sx = (screenX - 1) * 8 - subTileX
      local sy = (screenY - 1) * 8 - subTileY

      --Here, the 19, 25, and 41 are just randomly chosen biome tiles
      --picked to spawn trees on, but you can use any tiles to limit trees to certain biomes

      if tile.sprite_id == 19 then
        sspr(201, sx - 9 + tile.offset.x, sy - 28 + tile.offset.y, 0, 1, tile.flip, 0, 3, 4)
      elseif tile.sprite_id == 25 then
        sspr(198, sx - 6 + tile.offset.x, sy - 28 + tile.offset.y, 0, 1, tile.flip, 0, 3, 4)
      elseif tile.sprite_id == 41 then
        sspr(204, sx - 8 + tile.offset.x, sy - 28 + tile.offset.y, 0, 1, tile.flip, 0, 3, 4)
      end
    end
  end
end

function TileMgr:draw_worldmap(player, width, height)
  --Simple pixel map, using the tile's assigned biome in - biome[i].map_col
  local startX, startY = math.floor(player.x/8 - 96), math.floor(player.y/8 - 46)
  width, height = width or 200, height or 100
  rectb(19, 17, width + 2, height + 2, 11)
  for y = 0, height - 1 do
    for x = 0, width - 1 do
      local tile = self.tiles[startY + y - 1][startX + x - 1]
      pix(x + 20, y + 18, tile.color)
    end
  end
end

return TileMgr