--converted to tic-80 format, original author's pico-8 page
--https://www.lexaloffle.com/bbs/?pid=67049

function shuffle(tbl)
  for i = 0,#tbl do
    local j = math.floor(math.random(i + 1))
    tbl[i], tbl[j] = tbl[j], tbl[i]
  end
  return tbl
end

perlin = {}
function perlin()
    local p ={
        perm_size = 256,
        view_size = 18,
        view_size_x = math.floor(240/8),
        vsx = math.floor(240/8),
        vsy = math.floor(136/8),
        view_size_y = math.floor(136/8),
        text_view_size = 18,
        pixel_view_size = 130,
        pixel_view_size_x = 240,
        pixel_view_size_y = 136,
        pixel_mode = false,
        mapp = {},
        drawout={},
        dx = 0,
        dy = 0,
        old_dx = 0,
        old_dy = 0,
        permutation = {},
        p = {},
        init=function(self)
            for i=0,self.perm_size do
                self.permutation[i] = i
            end
            self.permutation = shuffle(self.permutation)
            for i=1,self.perm_size do
                self.p[i] = self.permutation[i]
                self.p[self.perm_size+i] = self.p[i]
            end
        end,
        move=function(self,dir)
            if dir == "u" then
                self.old_dy = self.dy
                self.dy = self.dy - 1
               
                self.mapp[self.old_dy+self.view_size_y]=nil -- clear out memory
               
                self:getmapdata(self.dx,self.dx+self.view_size_x,self.dy,self.old_dy)
            elseif dir == "d" then
                self.old_dy = self.dy
                self.dy = self.dy + 1
               
                self.mapp[self.old_dy]=nil -- clear out memory
               
                self:getmapdata(self.dx,self.dx+self.view_size_x,self.old_dy+self.view_size_y,self.dy+self.view_size_y)
            elseif dir == "l" then
                self.old_dx = self.dx
                self.dx = self.dx - 1
               
                for y=self.dy,self.dy+self.view_size_y do
                    self.mapp[y][self.old_dx+self.view_size_x] = nil -- clear out memory
                end
               
                self:getmapdata(self.dx,self.old_dx,self.dy,self.dy+self.view_size_y)
            elseif dir == "r" then
                self.old_dx = self.dx
                self.dx = self.dx + 1
               
                for y=self.dy,self.dy+self.view_size_y do
                    self.mapp[y][self.old_dx] = nil -- clear out memory
                end
               
                self:getmapdata(self.old_dx+self.view_size_x,self.dx+self.view_size_x,self.dy,self.dy+self.view_size_y)
            end
        end,
        draw=function(self)
            for y=self.dy,self.dy+self.view_size_y do
                for x=self.dx,self.dx+self.view_size_x do
                    if self.pixel_mode then
                        pix(x-self.dx,y-self.dy,math.floor(self.mapp[y][x]))
                    else
                        print(math.floor(self.mapp[y][x]),(x-self.dx)*8,(y-self.dy)*8,math.floor(self.mapp[y][x]), true, 1, true)
                    end
                end
            end
        end,
        getmapdata=function(self,fromx,tox, fromy,toy)
            for y=fromy,toy do
                if self.mapp[y] == nil then self.mapp[y] = {} end
                for x=fromx,tox do
                    local nx = x/16 - 0.5
                    local ny = y/16 - 0.5
                    local v = ((self:noise(nx,ny,0)/ 2.0 + 0.5)*15)
                    local n = math.floor((v/15)*10)
                    self.mapp[y][x] = v
                end
            end
        end,
       
        noise=function(self, x, y, z )
            local nx = math.floor(x) % self.perm_size
            local ny = math.floor(y) % self.perm_size
            local nz = math.floor(z) % self.perm_size
            x = x - math.floor(x)
            y = y - math.floor(y)
            z = z - math.floor(z)
            local u = fade(x)
            local v = fade(y)
            local w = fade(z)

            local a  = self.p[nx+1]+ny
            local aa = self.p[a+1]+nz
            local ab = self.p[a+2]+nz
            local b  = self.p[nx+2]+ny
            local ba = self.p[b+1]+nz
            local bb = self.p[b+2]+nz

            return lerp(w, lerp(v, lerp(u, grad(self.p[aa+1], x  , y  , z  ),
                                           grad(self.p[ba+1], x-1, y  , z  )),
                                   lerp(u, grad(self.p[ab+1], x  , y-1, z  ),
                                           grad(self.p[bb+1], x-1, y-1, z  ))),
                           lerp(v, lerp(u, grad(self.p[ab+2], x  , y  , z-1),
                                           grad(self.p[ba+2], x-1, y  , z-1)),
                                   lerp(u, grad(self.p[ab+2], x  , y-1, z-1),
                                           grad(self.p[bb+2], x-1, y-1, z-1))))
        end,
    }
    return p
end

function fade( t )
    return t * t * t * (t * (t * 6 - 15) + 10)
end

function lerp( t, a, b )
    return a + t * (b - a)
end

function grad( hash, x, y, z )
    local h = hash % 16
    local u = h < 8 and x or y
    local v = h < 4 and y or ((h == 12 or h == 14) and x or z)
    return ((h % 2) == 0 and u or -u) + ((h % 3) == 0 and v or -v)
end


-----------------------
p={}
function init()
    p = perlin()
    p:init()
    p:getmapdata(p.dx,p.dx+p.view_size_x,p.dy,p.dy+p.view_size_y) -- Initial full screen
end

function draw()
    cls()
    p:draw()
    -- rectfill(0,0,46,20,0)
    -- print('mem:'..stat(0), 0, 0, 7)
    -- print('cpu:'..stat(1), 0, 8, 7)
    -- print('fps:'..stat(7).."/"..stat(8), 0, 16, 7)
end


--example usage:

-- init()
-- function TIC()
--     if btn(0) then
--         p:move("u")
--     end
--     if btn(1) then
--         p:move("d")
--     end
--     if btn(2) then
--         p:move("l")
--     end
--     if btn(3) then
--         p:move("r")
--     end
   
--     if btn(4) then
--         p.pixel_mode = true
--         p.view_size_x, p.view_size_y = p.pixel_view_size_x, p.pixel_view_size_y
--         p.mapp = {}
--         p:getmapdata(p.dx,p.dx+p.view_size_x,p.dy,p.dy+p.view_size_y) -- Initial full screen
--     end
--     if btn(5) then
--         p.pixel_mode = false
--         p.view_size_x, p.view_size_y = p.vsx, p.vsy
--         p.mapp = {}
--         p:getmapdata(p.dx,p.dx+p.view_size_x,p.dy,p.dy+p.view_size_y) -- Initial full screen
--     end
--     draw()
-- end
