local TileMgr = {}
TileMgr.__index = TileMgr

function ore_sample(x, y, tile)
  local biome = tile.biome
  --if
  for i = 1, #ores do
    local scale = ores[i].scale -- ((4 - biome)/100)
    local noise = (simplex.Noise2D(x * scale + ((ores[i].offset * biome) * scale) + offset * scale, (y * scale) + ((ores[i].offset * biome) * scale) + (offset * scale)) / 2 + 0.5) * 16
    --if noise >= ores[i].min and noise <= ores[i].max and ores[i].biome_id == biome then return i end
    if noise >= ores[i].min and noise <= ores[i].max and tile.noise >= ores[i].bmin and tile.noise <= ores[i].bmax then return i end
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
  TileMan.tiles[y][x].is_tree  = false
  TileMan.tiles[y][x].ore = false
  TileMan.tiles[y][x].flip = 0
  --TileMan.tiles[y][x].is_tree = false
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

  local scale  = 0.0005
  local scale2 = 0.025
  --Here we sample 2 noise values and blend them together
  local base_noise = (simplex.Noise2D(x * scale + offset * scale, (y * scale) + (offset * scale)) / 2 + 0.5) * 100
  local addl_noise = (simplex.Noise2D(x * scale2 + offset * scale2, (y * scale2) + (offset * scale2))) * 100

  --Now base_noise is used to determine biome and land/water
  --base_noise = ((base_noise * 3) + addl_noise) / 4
  base_noise = lerp(base_noise, addl_noise, 0.02)

  local tile = {
    noise = base_noise,
    is_land = base_noise > 20 and true or false,
    biome = 1,
    --biome = base_noise < 30 and 1 or base_noise < 45 and 2 or 3,
    is_border = false,
    is_tree = false,
    visited = false,
    b_visited = false,
    rot = 0,
    flip = math.random() > 0.5 and 1 or 0,
    offset = {x = math.random(-3, 3), y = math.random(-3, 3)},
  }

  for i = 1, #biomes do
    if base_noise > biomes[i].min and base_noise < biomes[i].max then
      tile.biome = i
      break
    end
  end

  --If base_noise value is high enough, then try to generate an ore type
  tile.ore = tile.is_land and base_noise > 21 and ore_sample(x, y, tile) or false
  
  if not tile.is_land then
    --Water tile
    tile.color = floor(math.random(2)) + 8
    tile.sprite_id = 79
  else
    tile.sprite_id = biomes[tile.biome].tile_id_offset
    tile.color = biomes[tile.biome].map_col
  end

  --If ore-generation was successful, then set sprite_id and color
  if tile.ore then
    tile.color = ores[tile.ore].map_cols[floor(math.random(#ores[tile.ore].map_cols))]
    tile.rot = math.random(4) % 4
  end

  if tile.is_land and not tile.ore then
    --Generate clutter based on biome clutter scale, ex grass, rocks, trees, etc
    scale = 0.001
    local tree = (simplex.Noise2D(x * scale + offset * scale, (y * scale) + (offset * scale)) / 2 + 0.5) * 100
    local tmin = biomes[tile.biome].t_min
    local tmax = biomes[tile.biome].t_max
    if tree >= tmin and tree <= tmax and math.random(100) <= (biomes[tile.biome].tree_density * 100) then
      --trace('trying to spawn a tree')
      tile.is_tree = true
      tile.flip = math.random(1) > 0.5 and 1 or 0
    elseif math.random(100) <= (biomes[tile.biome].clutter * 100) then
      tile.sprite_id = biomes[tile.biome].tile_id_offset + floor(math.random(10))
      tile.flip = math.random(1) > 0.5 and 1 or 0
      --tile.rot = 0
    end
  end

  return tile
end

function TileMgr:set_tile(x, y, tile_id)
  local tile = self.tiles[y][x]
  tile_id = tile_id or biomes[tile.biome].tile_id_offset
  if tile.is_land and not tile.ore and not tile.is_border then
    tile.sprite_id = tile_id
    tile.is_tree = false
  end
  if tile.ore then
    tile.ore = false
    tile.is_tree = false
    tile.sprite_id = biomes[tile.biome].tile_id_offset
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
      local tile = self.tiles[worldY][worldX]
      local sx = (screenX - 1) * 8 - subTileX
      local sy = (screenY - 1) * 8 - subTileY

      --Here, AutoMap is called once per tile during draw
      --AutoMap is what sets the 'border' or edge tiles
      if not tile.visited and tile.is_land then AutoMap(worldX, worldY) end

      if tile.ore then
        sspr(biomes[tile.biome].tile_id_offset, sx, sy)
        --rect(sx, sy, 8, 8, biomes[tile.biome].map_col)
        sspr(ores[tile.ore].tile_id, sx, sy, ores[tile.ore].color_keys, 1, 0, tile.rot)
      elseif not tile.is_border then
        local id, rot, flip = tile.sprite_id, tile.rot, tile.flip
        if not tile.is_land then
          if worldX % 2 == 1 and worldY % 2 == 1 then
              flip = 3 -- Both horizontal and vertical flip
          elseif worldX % 2 == 1 then
              flip = 1 -- Horizontal flip
          elseif worldY % 2 == 1 then
              flip = 2 -- Vertical flip
          end
          sspr(224, sx, sy, 0, 1, flip, rot)
        else
          sspr(id, sx, sy, -1, 1, flip, rot)
        end
      else
        if tile.biome == 1 then
          local flip = 0
          if worldX % 2 == 1 and worldY % 2 == 1 then
            flip = 3 -- Both horizontal and vertical flip
          elseif worldX % 2 == 1 then
            flip = 1 -- Horizontal flip
          elseif worldY % 2 == 1 then
            flip = 2 -- Vertical flip
          end
          sspr(224, sx, sy, -1, 1, flip)
          sspr(tile.sprite_id, sx, sy, 0, 1, 0, tile.rot)
        else
          sspr(tile.sprite_id, sx, sy, -1, 1, 0, tile.rot)
        end
        --if tile.ore then sspr(ores[tile.ore].tile_id, sx, sy, ores[tile.ore].color_keys, 1, tile.flip, tile.rot) end
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
      if tile.is_tree then
        --trace('drawing tree')
        sspr(biomes[tile.biome].tree_id, sx - 9 + tile.offset.x, sy - 28 + tile.offset.y, 0, 1, tile.flip, 0, 3, 4)
      end
      -- if tile.sprite_id == 19 then
      --   sspr(201, sx - 9 + tile.offset.x, sy - 28 + tile.offset.y, 0, 1, tile.flip, 0, 3, 4)
      -- elseif tile.sprite_id == 25 then
      --   sspr(198, sx - 6 + tile.offset.x, sy - 28 + tile.offset.y, 0, 1, tile.flip, 0, 3, 4)
      -- elseif tile.sprite_id == 41 then
      --   sspr(201, sx - 8 + tile.offset.x, sy - 28 + tile.offset.y, 0, 1, tile.flip, 0, 3, 4)
      -- end
    end
  end
end

function TileMgr:draw_worldmap(player, x, y, width, height, center)
  --Simple pixel map, using the tile's assigned biome in - biome[i].map_col
  x, y, width, height = x or 0, y or 0, width or 240, height or 136
  if center then
    x = (240/2) - (width/2)
    y = (136/2) - (height/2)
  end
  local map_x, map_y = x or 120 - (width/2) + 1, y or 68 - (height/2) + 2
  local startX, startY = floor(player.x/8 - (width/2) + 1), floor(player.y/8 - (height/2) + 2)
  local biome_col = biomes[self.tiles[startY][startY].biome].map_col
  rectb(map_x - 1, map_y - 1, width + 2, height + 2, 11)
  --rect(map_x, map_y, width, height, biome_col)
  for y = 0, height - 1 do
    for x = 0, width - 1 do
      --if rawget(self.tiles, startY + y - 1) and rawget(self.tiles[startY + y - 1], startX + x - 1) then
        --local tile = self.tiles[startY + y - 1][startX + x - 1]
        --if self.tiles[startY + y - 1][startX + x - 1].ore then
          pix(x + map_x, y + map_y, self.tiles[startY + y - 1][startX + x - 1].color)
        --dsend
      --end
    end
  end
end

-- local biome_count
-- for i = 1, #biomes do
--   biome_count[i] = {}
-- end

return TileMgr