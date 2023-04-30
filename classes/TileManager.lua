local TileMgr = {}
TileMgr.__index = TileMgr

function TileMgr.new()
  local self = setmetatable({}, TileMgr)
  local tile_mt = {
    __index = function(row, x)
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

function ore_sample(x, y, ore)
  local scale = ore.scale
  local noise = (simplex.Noise2D(x * scale + (ore.offset * scale) + offset * scale, (y * scale) + (ore.offset * scale) + (offset * scale)) / 2 + 0.5) * 16
  return noise > ore.min and true or false
end

function TileMgr.create_tile(x, y)
  for i = 1, #ores do
    if ore_sample(x, y, ores[i]) then
      return {tile = ores[i].id, rot = math.random(4) % 4, index = i, is_ore = true}
    end
  end
  local id, r = 0, math.random(4) % 4
  if math.random(100) > 95 then
    id = floor(math.random(8) % 8)
    r = 0
  end
  return {tile = id, rot = r, index = 1, is_ore = false}
end

function TileMgr:get_tile_screen(screen_x, screen_y)
  local cam_x = player.x - 116
  local cam_y = player.y - 64
  local sub_tile_x = cam_x % 8
  local sub_tile_y = cam_y % 8
  local sx = floor((mouse_x + sub_tile_x) / 8)
  local sy = floor((mouse_y + sub_tile_y) / 8)
  local wx = floor(cam_x / 8) + sx + 1
  local wy = floor(cam_y / 8) + sy + 1
  return self.tiles[wy][wx]
end

function TileMgr:get_tile_world(world_x, world_y)
  return self.tiles[world_y][world_x]
end

function TileMgr:set_tile(tile, world_x, world_y)
  local id, r = 0, math.random(4) % 4
  if math.random(100) > 95 then
    id = floor(math.random(8) % 8)
    r = 0
  end
  self.tiles[world_y][world_x] = {tile = id, rot = r, index = 1, is_ore = false}
end

function TileMgr:draw(player, screenWidth, screenHeight)
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
      if tile.is_ore then
        sspr(ores[tile.index].tile_id, sx, sy, -1, 1, 0, tile.rot)
      else
        sspr(tile.tile, sx, sy, -1, 1, 0, tile.rot)
      end
    end
  end
end

function TileMgr:draw_p(player)
  local startX = player.x - 116
  local startY = player.y - 64

  for y = 0, 135 do
    for x = 0, 239 do
      local tile = self.tiles[startY + y - 1][startX + x - 1]
      if tile == 48 then tile = 5 end
      if tile == 49 then tile = 0 end
      if tile == 52 then tile = 14 end
      if tile == 65 then tile = 3 end
      pix(x, y, tile)
    end
  end
end

return TileMgr