local konko = LoadModule('Konko.Core.lua')
konko()

local ThemeColor = LoadModule('Theme.Colors.lua')
local SuperActor = LoadModule('Konko.SuperActor.lua')

local FRAMERATE = 0

local GRAVITY = 5
local JUMP_HEIGHT = 1
local MAX_VELOCITY = 1
local FRICTION = 6
local APEX_TIME = 0.75
local ACCEL = 8

local XMOVE = {
	LEFT = 0,
	RIGHT = 0,
}

local VELOCITY = {
	X = 0,
	Y = 0
}

local stage = SuperActor.new('ActorFrame')

local player = SuperActor.new('Sprite')
local walls = SuperActor.new('ActorFrame')

local floor = SuperActor.new('Quad')
local platform = SuperActor.new('Quad')

local box = SuperActor.new('Quad')

do box
	:SetCommand('Ready', function(self)
		self
			:SetSize(4, 4)
			:visible(false)
	end)
end

do floor
	:SetCommand('Ready', function(self)
		self
			:SetSize(SW, 128)
			:xy(SCX, SB)
			:diffuse(color('#000000'))
	end)
end


do platform
	:SetCommand('Ready', function(self)
		self
			:SetSize(256, 64)
			:xy(SL + 360, SB - 240)
			:diffuse(color('#000000'))
	end)
end

do player
	:SetAttribute('Texture', THEME:GetPathB('ScreenPlatformer', 'underlay/karen'))
	:SetCommand('Ready', function(self)
		local w, h = self:GetTexture():GetImageWidth(), self:GetTexture():GetImageHeight()
		self
			--:SetSize(32, 64)
			:SetSize(64 * (w / h), 64)
			:Center()
			:SetJumping(false)
			:shadowlengthx(4)
			:shadowlengthy(8)
	end)
end

do walls
	:AddChild(floor, 'Floor')
	:AddChild(platform, 'Platform')
end

do stage
	:AddChild(walls, 'Walls')
	:AddChild(player, 'Player')
	:AddChild(box, 'Box')
	:AddToTree('Stage')
end

local function aabb(obj)
	local x1 = obj:GetWidth() * -0.5
	local x2 = obj:GetWidth() * 0.5
	local y1 = obj:GetHeight() * -0.5
	local y2 = obj:GetHeight() * 0.5

	local rot = math.rad(obj:GetRotationZ())

	local corner = {
		x1 = (x1 * math.cos(rot)) - (y1 * math.sin(rot)),
		x2 = (x2 * math.cos(rot)) - (y2 * math.sin(rot)),
		y1 = (x1 * math.sin(rot)) + (y1 * math.cos(rot)),
		y2 = (x2 * math.sin(rot)) + (y2 * math.cos(rot)),
	}

	local aabb = {
		x1 = obj:GetX() + corner.x1,
		x2 = obj:GetX() + corner.x2,
		y1 = obj:GetY() + corner.y1,
		y2 = obj:GetY() + corner.y2,
	}
	return aabb
end

local function collide(obj1, obj2)
	local aabb1, aabb2 = aabb(obj1), aabb(obj2)
	return (
		aabb1.x1 < aabb2.x2
		and aabb2.x1 < aabb1.x2
		and aabb1.y1 < aabb2.y2
		and aabb2.y1 < aabb1.y2
	)
end

function ready()

	local stage = SuperActor.GetTree().Stage

	function stage.Player:Move(x, y)
		local dir = XMOVE.RIGHT - XMOVE.LEFT
		if dir ~= 0 then
			self:zoomx(dir)
		end
		return self:addx(x):addy(y)
	end
	function stage.Player:SetJumping(b)
		self.jumping = b
		return self
	end
	function stage.Player:IsJumping()
		return self.jumping
	end

end

function update(dt)

	local stage = SuperActor.GetTree().Stage


	-- X Movement

	VELOCITY.X = VELOCITY.X + (MAX_VELOCITY * ACCEL * (XMOVE.RIGHT - XMOVE.LEFT) * dt)
	if VELOCITY.X > MAX_VELOCITY then
		VELOCITY.X = MAX_VELOCITY
	end

	--


	-- Y Movement

	VELOCITY.Y = VELOCITY.Y + (GRAVITY * dt)

	local vel = math.sqrt(VELOCITY.X ^ 2, VELOCITY.Y ^ 2)
	if vel > MAX_VELOCITY then
		local vs = MAX_VELOCITY / vel
		for v in ivalues(VELOCITY) do
			v = v * vs
		end
	end

	VELOCITY.X = VELOCITY.X / (1 + (FRICTION * dt))

	local g = (JUMP_HEIGHT * 2) / (APEX_TIME ^ 2)
	local initJump = math.sqrt(g * JUMP_HEIGHT * 2)

	APEX_TIME = initJump / g

	VELOCITY.Y = VELOCITY.Y + (g * dt)

	for _, v in pairs(stage.Walls:GetChildren()) do
		if collide(stage.Player, v) then
			if stage.Player.jumping then
				VELOCITY.Y = VELOCITY.Y - initJump
				stage.Player:SetJumping(false)
			else
				VELOCITY.Y = 0
				if stage.Player:GetY() < v:GetY() then
					stage.Player:addy(-0.1)
				elseif stage.Player:GetY() > v:GetY() then
					stage.Player:addy(0.1)
				end
			end
		end
	end

	--


	stage.Player:Move(VELOCITY.X, VELOCITY.Y)

end

function input(event)
	if event.type:find('Press') then
		if event.GameButton == 'Back' then
			SCREENMAN:GetTopScreen():Cancel()
		elseif event.GameButton == 'MenuUp' then
			SuperActor.GetTree().Stage.Player:SetJumping(true)
		elseif event.GameButton == 'MenuLeft' then
			XMOVE.LEFT = 1
		elseif event.GameButton == 'MenuRight' then
			XMOVE.RIGHT = 1
		end
	elseif event.type:find('Repeat') then
	elseif event.type:find('Release') then
		if event.GameButton == 'MenuUp' then
		elseif event.GameButton == 'MenuLeft' then
			XMOVE.LEFT = 0
		elseif event.GameButton == 'MenuRight' then
			XMOVE.RIGHT = 0
		end
	end
end

function input_repeat(event)
end

function input_release(event)
end

function draw()
end


return Def.ActorFrame {
	InitCommand = function(self)
		if init then init() end
	end,
	OnCommand = function(self)
		self:queuecommand('Ready')
	end,
	ReadyCommand = function(self)
		if ready then ready() end
		local lastframe = 0
		self:SetUpdateFunction(function(self)
			local dt = self:GetEffectDelta()
			if FRAMERATE and FRAMERATE ~= 0 then
				lastframe = lastframe + self:GetEffectDelta()
				if lastframe >= 1/FRAMERATE then
					update(1/FRAMERATE)
					lastframe = 0
				end
			else
				update(self:GetEffectDelta())
			end
		end)
		SCREENMAN:GetTopScreen():AddInputCallback(function(event)
			if event.type:find('Press') then
				self:playcommand('InputPress', event)
				if input_press then input_press(event) end
			elseif event.type:find('Repeat') then
				self:playcommand('InputRepeat', event)
				if input_repeat then input_repeat(event) end
			else
				self:playcommand('InputRelease', event)
				if input_release then input_release(event) end
			end
			if input then input(event) end
		end)
	end,
	Def.BitmapText {
		Font = 'Sudo/36px',
		Text = 'hewo to my plamtformer thabks\n\nu can have do a subo hop! (pres in the uppies)',
		InitCommand = function(self)
			self
				:xy(SCX, ST + 60)
				:shadowlengthy(2)
		end,
	},
	SuperActor.GetTree(),
	Def.ActorFrame {
		OnCommand = function(self)
			self:SetDrawFunction(draw)
		end
	},
	Def.Actor {
		ReadyCommand = function(self)
			SOUND:PlayMusicPart(
				THEME:GetPathB('ScreenPlatformer', 'underlay/music.ogg'),
				0,
				13.45,
				0,
				0,
				true
			)
		end,
	}
}
