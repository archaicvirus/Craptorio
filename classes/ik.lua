-- calculates a target position for the leg offsetted and
-- slightly moved to the out, based on the spiders body position
function getTargetPos(bodyPos, legOffset)
	return bodyPos + legOffset * 2.5 + vec2(0, 30)
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
		local cosAngle0 = ((dist * dist) + (self.bone1Length * self.bone1Length) - (self.bone2Length * self.bone2Length)) / (2 * dist * self.bone1Length)
		self.angle1 = atan - math.acos(cosAngle0)

		local cosAngle1 = ((self.bone2Length * self.bone2Length) + (self.bone1Length * self.bone1Length) - (dist * dist)) / (2 * self.bone2Length * self.bone1Length)
		self.angle2 = self.angle1 + math.pi - math.acos(cosAngle1)

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

function drawLeg(self)
  line(self.joint1.x, self.joint1.y, self.joint2.x, self.joint2.y, 8)
  line(self.joint2.x, self.joint2.y, self.foot.x, self.foot.y, 8)
  circ(self.foot.x, self.foot.y, 2, 9)
  circ(self.joint2.x, self.joint2.y, 2, 9)
  -- circb(self.currentTargetPos.x, self.currentTargetPos.y, 4, 2)
  -- circb(self.targetPos.x, self.targetPos.y, 4, 6)
end

-- joint1: position of the first leg joint (positioned on the spiders body)
-- joint2: position of the second leg joint (dist = bone1Length)
-- foot: position of the legs foot (based on the target position)
-- bone1Length: length of the bone between joint1 and joint2
-- bone2Length: length of the bone between joint2 and foot
-- angle1: angle between joint1 and joint2
-- angle2: angle between joint2 and foot
-- offset: the offsetted position the legs first joint is placed based on the spiders position
-- targetPos: new target position for the leg which is calculated after a certain
-- distance to the previous position has been reached
-- currentTargetPos: for animating the leg movement
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