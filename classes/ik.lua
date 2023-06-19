-- calculates a target position for the leg offsetted and
-- slightly moved to the out, based on the spiders body position
function getTargetPos(bodyPos, legOffset)
	return bodyPos + legOffset * 2.5 + vec2(0, 25)
end

function updateLeg(self, bodyPos)
	local targetPos = getTargetPos(bodyPos, self.offset)
	local targetDiff = (targetPos - self.targetPos):length()

	-- to achieve a leg animation only update the leg position when
	-- when a specified threshold/distance is reached (updateDist)
	if targetDiff > self.updateDist then
		self.currentTargetPos = self.targetPos
		local future = targetPos - self.targetPos
		-- offset legs target position by random number to make it look more natural
		self.targetPos = targetPos + (vec2(math.random(), math.random()) * 20 - vec2(10))
		self.targetPos = self.targetPos + future * .5
	end

	-- animate the leg over time
	local diff = self.targetPos - self.currentTargetPos
	local speed = 15
	if diff:length() < speed then
		self.currentTargetPos = self.targetPos
	else
		self.currentTargetPos = self.currentTargetPos + diff:normalize() * speed
	end

	-- using this explanation to calculate the angles between body - bone1
	-- and bone1 - bone2 https://www.alanzucconi.com/2018/05/02/ik-2d-1/
	self.joint1 = bodyPos + self.offset
	local diff = self.currentTargetPos - self.joint1
	local dist = (diff):length()
	local atan = math.atan2(diff.y, diff.x)

	if self.bone1Length + self.bone2Length < dist then
		self.angle1 = atan
		self.angle2 = self.angle1 + 0
	else 
		-- local cosAngle0 = ((dist * dist) + (self.bone1Length * self.bone1Length) - (self.bone2Length * self.bone2Length)) / (2 * dist * self.bone1Length)
		-- self.angle1 = atan - math.acos(cosAngle0)

		-- local cosAngle1 = ((self.bone2Length * self.bone2Length) + (self.bone1Length * self.bone1Length) - (dist * dist)) / (2 * self.bone2Length * self.bone1Length)
		-- self.angle2 = self.angle1 + math.pi - math.acos(cosAngle1)
        -- ... snip ...
        local cosAngle0 = ((dist * dist) + (self.bone1Length * self.bone1Length) - (self.bone2Length * self.bone2Length)) / (2 * dist * self.bone1Length)
        -- Clamping cosAngle0 within the range [-1, 1]
        cosAngle0 = math.max(-1, math.min(1, cosAngle0))
        self.angle1 = atan - math.acos(cosAngle0)
    
        local cosAngle1 = ((self.bone2Length * self.bone2Length) + (self.bone1Length * self.bone1Length) - (dist * dist)) / (2 * self.bone2Length * self.bone1Length)
        -- Clamping cosAngle1 within the range [-1, 1]
        cosAngle1 = math.max(-1, math.min(1, cosAngle1))
        self.angle2 = self.angle1 + math.pi - math.acos(cosAngle1)
        -- ... snip ...
    

	end
	
	-- flipping the leg by mirroring the angles based on the angle of
	--  joint1 - targetPos
	if self.flipped then
		local diff = self.angle1 - atan
		self.angle1 = atan - diff
		diff = self.angle2 - atan
		self.angle2 = atan - diff
	end

	-- calculating the angles https://www.alanzucconi.com/2018/05/02/ik-2d-2/
	self.joint2 = self.joint1 + vec2(math.cos(self.angle1), math.sin(self.angle1)) * self.bone1Length
	self.foot = self.joint2 + vec2(math.cos(self.angle2), math.sin(self.angle2)) * self.bone2Length
end

function drawFootSprite(footx, footy, joint2x, joint2y, width, height, sprite_id, ck)
  -- Calculate the angle between the foot and joint2
  local dx = footx - joint2x
  local dy = footy - joint2y
  local angle = math.atan2(dy, dx) - (math.pi/2)
  
  -- Calculate the half width and height
  local half_width = width / 2
  local half_height = height / 2

  -- Define the four corner points of the sprite rectangle
  local points = {
      {footx - half_width, footy - half_height},  -- Top-left
      {footx + half_width, footy - half_height},  -- Top-right
      {footx + half_width, footy + half_height},  -- Bottom-right
      {footx - half_width, footy + half_height}   -- Bottom-left
  }

  -- Rotate each point around the foot position
  for _, point in ipairs(points) do
      point[1], point[2] = rotatePoint(footx, footy, angle, point[1], point[2])
  end

  -- Calculate the sprite's UV coordinates
  local spriteX = (sprite_id % 16) * 8
  local spriteY = math.floor(sprite_id / 32) * 8
  local spw = 8 -- Assuming each sprite tile is 8x8
  local sph = 8

  -- Draw the sprite using two textured triangles
  ttri(
      points[1][1], points[1][2],
      points[2][1], points[2][2],
      points[4][1], points[4][2],
      spriteX, spriteY,
      spriteX + spw, spriteY,
      spriteX, spriteY + sph,
      ck
  )

  ttri(
      points[3][1], points[3][2],
      points[4][1], points[4][2],
      points[2][1], points[2][2],
      spriteX + spw, spriteY + sph,
      spriteX, spriteY + sph,
      spriteX + spw, spriteY,
      ck
  )
end

function drawTexturedLeg(joint1x, joint1y, joint2x, joint2y, width, height, sprite_id, ck)
  -- Calculate the angle between the two joints
  local dx = joint2x - joint1x
  local dy = joint2y - joint1y
  local angle = math.atan2(dy, dx) + (math.pi / 2)
  if not angle then -- Check for NaN
    angle = 0 -- Assign default value
  end
  
  -- Calculate the half width and height
  local half_width = width / 2
  local half_height = height / 2

  -- Calculate the center point of the leg
  local center_x = (joint1x + joint2x) / 2
  local center_y = (joint1y + joint2y) / 2

  -- Define the four corner points of the leg rectangle
  local points = {
      {center_x - half_width, center_y - half_height},  -- Top-left
      {center_x + half_width, center_y - half_height},  -- Top-right
      {center_x + half_width, center_y + half_height},  -- Bottom-right
      {center_x - half_width, center_y + half_height}   -- Bottom-left
  }

  -- Rotate each point around the center of the rectangle
  for _, point in ipairs(points) do
      point[1], point[2] = rotatePoint(center_x, center_y, angle, point[1], point[2])
  end

  -- Calculate the sprite's UV coordinates
  local spriteX = (sprite_id % 16) * 8
  local spriteY = math.floor(sprite_id / 16) * 8
  local spw = 8 -- Assuming each sprite tile is 8x8
  local sph = 8

  -- Draw the leg using two textured triangles
  ttri(
      points[1][1], points[1][2],
      points[2][1], points[2][2],
      points[4][1], points[4][2],
      spriteX, spriteY,
      spriteX + spw, spriteY,
      spriteX, spriteY + sph,
      ck
  )

  ttri(
      points[3][1], points[3][2],
      points[4][1], points[4][2],
      points[2][1], points[2][2],
      spriteX + spw, spriteY + sph,
      spriteX, spriteY + sph,
      spriteX + spw, spriteY,
      ck
  )
end

function drawLeg(self)
  drawTexturedLeg(self.joint1.x, self.joint1.y, self.joint2.x, self.joint2.y, 6, self.bone1Length, 3, 0)
  drawTexturedLeg(self.joint2.x, self.joint2.y, self.foot.x, self.foot.y, 6, self.bone2Length, 3, 0)
  sspr(4, self.joint2.x - 3, self.joint2.y - 3, 0)
  drawFootSprite(self.foot.x, self.foot.y, self.joint2.x, self.joint2.y, 6, 8, 2, 0)
end

function new_leg(offset, bone1Length, bone2Length, updateDist, flipped)
	flipped = flipped or false

	return {
		bone1Length = bone1Length,
		bone2Length = bone2Length,
		angle1 = 0,
		angle2 = 0,
		offset = offset,
		joint1 = offset,
		joint2 = offset + vec2(bone1Length, 0),
		foot = offset + vec2(bone1Length + bone2Length, 0),
		flipped = flipped,
		targetPos = getTargetPos(vec2(), offset),
		currentTargetPos = vec2(),
		updateDist = updateDist,
		update = updateLeg,
		draw = drawLeg
	}
end