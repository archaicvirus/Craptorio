--credit goes to https://cxong.github.io/tic-80-examples/
--only changes I made were converting to lua code

return function(id,x,y,colorkey,sx,sy,flip,rotate,w,h,ox,oy,shx1,shy1,shx2,shy2)
  --aspr(338,8,8,-1,0.375,0.375,0,0,1,1,1,1,0,0,0,0)
  colorkey = colorkey or -1
  sx = sx or 1
  sy = sy or 1
  flip = flip or 0
  rotate = rotate or 0
  w = w or 1
  h = h or 1
  ox = ox or (w*8) // 2
  oy = oy or (h*8) // 2
  shx1 = shx1 or 0
  shy1 = shy1 or 0
  shx2 = shx2 or 0
  shy2 = shy2 or 0
  -- Draw a sprite using two textured triangles.
  -- Apply affine transformations: scale, shear, rotate, flip
 
  -- scale / flip
  if (flip%2) == 1 then
    sx = -sx
  end
  if flip >= 2 then 
    sy = -sy
  end
  ox = ox * (-sx)
  oy = oy * (-sy)
  -- shear / rotate
  shx1 = shx1 * (-sx)
  shy1 = shy1 * (-sy)
  shx2 = shx2 * (-sx)
  shy2 = shy2 * (-sy)
  local function rot(x, y, rotate)
    local sa = math.sin(math.rad(rotate))
    local ca = math.cos(math.rad(rotate))
    return x * ca - y * sa, x * sa + y * ca
  end
  local rx1, ry1 = rot(ox + shx1, oy + shy1, rotate)
  local rx2, ry2 = rot(((w * 8) * sx) + ox + shx1, oy + shy2, rotate)
  local rx3, ry3 = rot(ox + shx2, ((h * 8) * sy) + oy + shy1, rotate)
  local rx4, ry4 = rot(((w * 8) * sx) + ox + shx2, ((h * 8) * sy) + oy + shy2, rotate)
  local x1 = x + rx1
  local y1 = y + ry1
  local x2 = x + rx2
  local y2 = y + ry2
  local x3 = x + rx3
  local y3 = y + ry3
  local x4 = x + rx4
  local y4 = y + ry4
  -- UV coords
  local u1 = (id % 16) * 8
  local v1 = id//16*8
  local u2 = u1 + w * 8
  local v2 = v1 + h * 8
 
  ttri(x1,y1,x2,y2,x3,y3,u1,v1,u2,v1,u1,v2,false,colorkey)
  ttri(x3,y3,x4,y4,x2,y2,u1,v2,u2,v2,u2,v1,false,colorkey)
end
