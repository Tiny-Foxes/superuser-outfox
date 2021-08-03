collectgarbage()

local scx, scy = SCREEN_CENTER_X, SCREEN_CENTER_Y
local sw, sh = SCREEN_WIDTH, SCREEN_HEIGHT
local scale = sh / 480

local ThemeColor = LoadModule('Theme.Colors.lua')

local function aft(self)
	self
		:SetWidth(SCREEN_WIDTH)
		:SetHeight(SCREEN_HEIGHT)
		:EnableFloat(false)
		:EnableDepthBuffer(true)
		:EnableAlphaBuffer(true)
		:EnablePreserveTexture(false)
		:Create()
end
local function aftrecursive(self)
	self
		:SetWidth(SCREEN_WIDTH)
		:SetHeight(SCREEN_HEIGHT)
		:EnableDepthBuffer(true)
		:EnableAlphaBuffer(false)
		:EnableFloat(false)
		:EnablePreserveTexture(true)
		:Create()
end
function sprite(self)
	self:Center()
end
function aftsprite(aft, sprite)
	sprite:SetTexture(aft:GetTexture())
end

local t = Def.ActorFrame {
	InitCommand = function(self)
		self:Center()
	end,
}

-- Mascot
t[#t + 1] = Def.ActorFrame {
	InitCommand = function(self)
		self:diffusealpha(0)
	end,
	OnCommand = function(self)
		self
			:linear(0.5)
			:diffusealpha(1)
	end,
	OffCommand = function(self)
		self
			:linear(0.5)
			:diffusealpha(0)
	end,
	Def.Sprite {
		Texture = THEME:GetPathG('ScreenTitleMenu', 'mascot'),
		InitCommand = function(self)
			self
				:zoom(1.2)
				:xy(-180, 320)
				:bob()
				:effectmagnitude(0, 4, 0)
				:effectperiod(4)
				:visible(LoadModule("Config.Load.lua")("ShowMascotCharacter","Save/OutFoxPrefs.ini"))
		end,
		OnCommand = function(self)
			self
				:easeoutexpo(0.5)
				:addx(20)
		end,
		OffCommand = function(self)
			self
				:easeinexpo(0.5)
				:addx(-20)
		end,
	},
}

-- Logo
t[#t + 1] = Def.ActorFrame {
	InitCommand = function(self)
		self
			:y(scy - 192)
	end,
	Def.Quad {
		InitCommand = function(self)
			self
				:SetSize(sw, 264)
				:diffuse(ThemeColor.Black)
				:diffusealpha(0.75)
				:fadetop(0.01)
				:fadebottom(0.01)
				:cropleft(1)
		end,
		OnCommand = function(self)
			self
				:easeinoutexpo(0.25)
				:cropleft(0)
		end,
		OffCommand = function(self)
			self
				:sleep(0.5)
				:easeinoutexpo(0.25)
				:cropleft(1)
		end,
	},
	Def.Quad {
		InitCommand = function(self)
			self
				:SetSize(sw, 256)
				:diffuse(ThemeColor.Elements)
				:diffusealpha(0.5)
				:cropleft(1)
		end,
		OnCommand = function(self)
			self
				:easeinoutexpo(0.25)
				:cropleft(0)
		end,
		OffCommand = function(self)
			self
				:sleep(0.5)
				:easeinoutexpo(0.25)
				:cropleft(1)
		end,
	},
	-- Text
	Def.ActorFrame {
		InitCommand = function(self)
			self
				:xy(20, -10)
		end,
		Def.BitmapText {
			Font = '_xide/20px',
			Text = 'Project\nOutfox',
			InitCommand = function(self)
				self
					:xy(-370, -32)
					:horizalign('right')
					:shadowlengthy(4)
					:diffuse(ThemeColor.Yellow)
					:diffusebottomedge(ThemeColor.Orange)
					:cropright(1)
			end,
			OnCommand = function(self)
				self
					:linear(0.1)
					:cropright(0)
			end,
			OffCommand = function(self)
				self
					:sleep(0.35)
					:linear(0.1)
					:cropright(1)
			end,
		},
		Def.Sprite {
			Texture = THEME:GetPathG('ScreenTitleMenu', 'supertext'),
			InitCommand = function(self)
				self
					:xy(-220, 28)
					:zoom(0.45)
					:shadowlengthy(4)
					:cropright(1)
			end,
			OnCommand = function(self)
				self
					:sleep(0.1)
					:linear(0.2)
					:cropright(0)
			end,
			OffCommand = function(self)
				self
					:sleep(0.15)
					:linear(0.2)
					:cropright(1)
			end,
		},
		Def.BitmapText {
			Font = 'Common Normal',
			Text = '"This is who we are."',
			InitCommand = function(self)
				self
					:playcommand('Tagline')
					:zoom(0.75)
					:xy(-480, 64)
					:horizalign('left')
					:vertalign('top')
					:cropright(1)
			end,
			OnCommand = function(self)
				self
					:sleep(0.3)
					:linear(0.1)
					:cropright(0)
			end,
			OffCommand = function(self)
				self
					:sleep(0.05)
					:linear(0.1)
					:cropright(1)
			end,
			TaglineCommand = function(self)
				-- TODO: Make this more international friendly.
				local taglines = {
					en = {
						'This is who we are.',
						'Let\'s get technical.',
						'You ARE the elevated privilege.',
						'80% of the work takes 20% of the effort.',
						'Only you can limit your creativity.',
						'Your presence is invaluable.',
						'Shoot the moon and you will hit it.',
						'Faith can be the greatest logic of all.',
						'Take your time.',
					},
					ja = {},
				}
				local rng = math.random(1, #taglines.en)
				self:settext('"'..taglines.en[rng]..'"')
			end,
		},
		Def.BitmapText {
			Font = 'Common Normal',
			Text = 'Theme by Sudospective',
			InitCommand = function(self)
				self
					:zoom(0.5)
					:xy(40, 0)
					:horizalign('right')
					:vertalign('bottom')
					:cropright(1)
			end,
			OnCommand = function(self)
				self
					:sleep(0.35)
					:linear(0.1)
					:cropright(0)
			end,
			OffCommand = function(self)
				self
					:linear(0.1)
					:cropright(1)
			end,
		},
	}
}

return Def.ActorFrame {
	Def.ActorFrameTexture {
		Name = 'TitleAFT',
		InitCommand = aft,
		LoadActor(THEME:GetPathB('ScreenWithMenuElements', 'background')),
		Def.Quad {
			InitCommand = function(self)
				self
					:FullScreen()
					:diffuse(color('#000000'))
					:diffusealpha(0)
			end,
			OnCommand = function(self)
				self
					:easeoutquad(0.5)
					:diffusealpha(0.75)
			end,
			OffCommand = function(self)
				self
					:easeinquad(0.5)
					:diffusealpha(0)
			end,
		},
		Def.Sprite {
			Name = 'TitleSprite',
			InitCommand = sprite,
			OnCommand = function(self)
				local aft = self:GetParent():GetParent():GetChild('TitleAFTR')
				aftsprite(aft, self)
				self
					:blend('BlendMode_Add')
					:diffusealpha(0)
					:easeoutquad(0.5)
					:diffusealpha(0.65)
					:zoom(1.005)
					:queuecommand('Breathe')
			end,
			BreatheCommand = function(self)
				self
					:easeinoutsine(3.5)
					:diffusealpha(0.75)
					:zoom(1.01)
					:easeinoutsine(3.5)
					:diffusealpha(0.65)
					:zoom(1.005)
					:queuecommand('Breathe')
			end,
			OffCommand = function(self)
				self
					:stoptweening(0)
					:easeinquad(0.49)
					:diffusealpha(0)
					:zoom(1)
			end,
		},
		t,
	},
	Def.Sprite {
		Name = 'ShowTitle',
		InitCommand = sprite,
		OnCommand = function(self)
			local aft = self:GetParent():GetChild('TitleAFT')
			aftsprite(aft, self)
		end,
	},
	Def.ActorFrameTexture {
		Name = 'TitleAFTR',
		InitCommand = aftrecursive,
		Def.Sprite {
			Name = 'TitleSpriteR',
			InitCommand = sprite,
			OnCommand = function(self)
				local aft = self:GetParent():GetParent():GetChild('TitleAFT')
				aftsprite(aft, self)
			end,
		}
	}
}