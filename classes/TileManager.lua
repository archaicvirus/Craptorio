ores = {
  [1] = {
    name = 'iron',
    offset = 15000,
    id = 45,
    scale = 0.011,
    min = 14,
    max = 16
  },
  [2] = {
    name = 'copper',
    offset = 10000,
    id = 37,
    scale = 0.013,
    min = 15,
    max = 16
  },
  [3] = {
    name = 'coal',
    offset = 50000,
    id = 39,
    scale = 0.018,
    min = 14,
    max = 16
  }
}

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
      return ores[i].id
    end
  end
  return 0
end

function TileMgr:get_tile(x, y)
  return self.tiles[y][x]
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

      local tile = self:get_tile(worldX, worldY)
      local screenPosX = (screenX - 1) * 8 - subTileX
      local screenPosY = (screenY - 1) * 8 - subTileY
      spr(tile, screenPosX, screenPosY, -1)
    end
  end
end

function TileMgr:draw_p(player)
  local startX = player.x - 116
  local startY = player.y - 64

  for y = 0, 135 do
    for x = 0, 239 do
      local tile = self:get_tile(startY + y - 1, startX + x - 1)
      if tile == 48 then tile = 5 end
      if tile == 49 then tile = 0 end
      if tile == 52 then tile = 14 end
      if tile == 65 then tile = 3 end
      pix(x, y, tile)
    end
  end
end

return TileMgr