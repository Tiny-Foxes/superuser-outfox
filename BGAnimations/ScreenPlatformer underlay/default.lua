local konko = LoadModule('Konko.Core.lua')
konko()

local ThemeColor = LoadModule('Theme.Colors.lua')
local SuperActor = LoadModule('Konko.SuperActor.lua')

local FRAMERATE = 0

local GRAVITY = {
	P1 = 0.98,
	P2 = 0.98,
}
local JUMP_HEIGHT = {
	P1 = 1,
	P2 = 1,
}
local MAX_VELOCITY = {
	P1 = {
		X = 0.75,
		Y = 1,
	},
	P2 = {
		X = 0.75,
		Y = 1,
	},
}
local FRICTION = {
	P1 = 6,
	P2 = 6,
}
local APEX_TIME = {
	P1 = 0.75,
	P2 = 0.75,
}
local ACCEL = {
	P1 = 8,
	P2 = 8,
}

local XMOVE = {
	P1 = {
		LEFT = 0,
		RIGHT = 0,
	},
	P2 = {
		LEFT = 0,
		RIGHT = 0,
	},
}

local VELOCITY = {
	P1 = {
		X = 0,
		Y = 0,
	},
	P2 = {
		X = 0,
		Y = 0,
	},
}

local stage = SuperActor.new('ActorFrame')

local player1 = SuperActor.new('ActorFrame')
local player2 = SuperActor.new('ActorFrame')
local karen = SuperActor.new('Sprite')
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
			:diffuse(color('#202020'))
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

do karen
	:SetAttribute('Texture', THEME:GetPathB('ScreenPlatformer', 'underlay/karen'))
	:SetCommand('Ready', function(self)
		local w, h = self:GetTexture():GetImageWidth(), self:GetTexture():GetImageHeight()
		self
			:SetSize(64 * (w / h), 64)
			:shadowlengthx(4)
			:shadowlengthy(4)
	end)
end

do player1
	:SetCommand('Ready', function(self)
		local enabled = GAMESTATE:IsPlayerEnabled(PlayerNumber[1])
		local x, y = SCREEN_CENTER_X, SCREEN_CENTER_Y
		if GAMESTATE:IsPlayerEnabled(PlayerNumber[2]) then
			x = SCREEN_CENTER_X * 0.75
		end
		self
			:xy(x, y)
			:SetSize(64, 48)
			:SetJumping(false)
			:SetPlayer(PlayerNumber[1])
			:visible(enabled)
	end)
	:AddChild(karen, 'PSprite')
end
do player2
	:SetCommand('Ready', function(self)
		local enabled = GAMESTATE:IsPlayerEnabled(PlayerNumber[2])
		local x, y = SCREEN_CENTER_X, SCREEN_CENTER_Y
		if GAMESTATE:IsPlayerEnabled(PlayerNumber[1]) then
			x = SCREEN_CENTER_X * 1.25
		end
		self
			:xy(x, y)
			:SetJumping(false)
			:SetPlayer(PlayerNumber[2])
			:shadowlengthx(4)
			:shadowlengthy(8)
			:visible(enabled)
	end)
	:AddChild(karen, 'PSprite')
end

do walls
	:AddChild(floor, 'Floor')
	--:AddChild(platform, 'Platform')
end

do stage
	:AddChild(walls, 'Walls')
	:AddChild(player1, 'PlayerP1')
	:AddChild(player2, 'PlayerP2')
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

	for i = 1, 2 do
		local v = PlayerNumber[i]
		local plr = stage['Player'..ToEnumShortString(v)]
		function plr:SetPlayer(pn)
			self.Player = pn
			return self
		end
		function plr:GetPlayer()
			return self.Player
		end
		function plr:Move(x, y)
			local pn = ToEnumShortString(self.Player)
			local dir = XMOVE[pn].RIGHT - XMOVE[pn].LEFT
			if dir ~= 0 then
				self:zoomx(dir)
			end
			return self:addx(x):addy(y)
		end
		function plr:SetJumping(b)
			self.jumping = b
			return self
		end
		function plr:IsJumping()
			return self.jumping
		end
	end

end

local enabledPlrs = GAMESTATE:GetEnabledPlayers()

function update(dt)

	local stage = SuperActor.GetTree().Stage


	for v in ivalues(enabledPlrs) do

		local pn = ToEnumShortString(v)
		local plr = stage['Player'..pn]

		--

		-- X Movement

		VELOCITY[pn].X = VELOCITY[pn].X + (MAX_VELOCITY[pn].X * ACCEL[pn] * (XMOVE[pn].RIGHT - XMOVE[pn].LEFT) * dt)
		if VELOCITY[pn].X > MAX_VELOCITY[pn].X then
			VELOCITY[pn].X = MAX_VELOCITY[pn].X
		end


		-- Y Movement

		VELOCITY[pn].Y = VELOCITY[pn].Y + (GRAVITY[pn] * dt)

		---[[
		local vel = {
			x = math.sqrt(VELOCITY[pn].X ^ 2),
			y = math.sqrt(VELOCITY[pn].Y ^ 2),
		}
		for k, v in pairs(vel) do
			if v > MAX_VELOCITY[pn][k:upper()] then
				local vs = MAX_VELOCITY[pn][k:upper()] / v
				VELOCITY[pn][k:upper()] = VELOCITY[pn][k:upper()] * vs
			end
		end
		--]]

		VELOCITY[pn].X = VELOCITY[pn].X / (1 + (FRICTION[pn] * dt))

		local g = (JUMP_HEIGHT[pn] * 2) / (APEX_TIME[pn] ^ 2)
		local initJump = math.sqrt(g * JUMP_HEIGHT[pn] * 2)

		APEX_TIME[pn] = initJump / g

		VELOCITY[pn].Y = VELOCITY[pn].Y + (g * dt)

		for _, v in pairs(stage.Walls:GetChildren()) do
			if collide(plr, v) then
				if plr:IsJumping() then
					VELOCITY[pn].Y = VELOCITY[pn].Y - initJump
					plr:SetJumping(false)
				else
					VELOCITY[pn].Y = 0
					if plr:GetY() < v:GetY() then
						plr:addy(-plr:GetHeight() * dt)
					elseif plr:GetY() > v:GetY() then
						plr:addy(plr:GetHeight() * dt)
					end
				end
			end
		end

		--


		plr:Move(VELOCITY[pn].X, VELOCITY[pn].Y)

	end

end

function input(event)
	if event.type:find('Press') and event.GameButton == 'Back' then
		SCREENMAN:GetTopScreen():Cancel()
	end
	if not event.PlayerNumber then return end
	local pn = ToEnumShortString(event.PlayerNumber)
	local plr = SuperActor.GetTree().Stage['Player'..pn]
	if event.type:find('Press') then
		if event.GameButton == 'MenuUp' then
			plr:SetJumping(true)
		elseif event.GameButton == 'MenuLeft' then
			XMOVE[pn].LEFT = 1
		elseif event.GameButton == 'MenuRight' then
			XMOVE[pn].RIGHT = 1
		end
	elseif event.type:find('Repeat') then
	elseif event.type:find('Release') then
		if event.GameButton == 'MenuUp' then
		elseif event.GameButton == 'MenuLeft' then
			XMOVE[pn].LEFT = 0
		elseif event.GameButton == 'MenuRight' then
			XMOVE[pn].RIGHT = 0
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
			if FRAMERATE and FRAMERATE ~= 0 then
				lastframe = lastframe + self:GetEffectDelta()
				if lastframe >= OFMath.oneoverx(FRAMERATE) then
					update(OFMath.oneoverx(FRAMERATE))
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
		StartTransitioningCommand = function(self)
			SOUND:DimMusic(0, 5)
		end,
	}
}
