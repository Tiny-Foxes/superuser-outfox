collectgarbage()

local scx, scy = SCREEN_CENTER_X, SCREEN_CENTER_Y
local sw, sh = SCREEN_WIDTH, SCREEN_HEIGHT
local scale = sh / 480

local ThemeColor = LoadModule('Theme.Colors.lua')

local function aft(self)
	self
		:SetSize(SCREEN_WIDTH, SCREEN_HEIGHT)
		:EnableFloat(false)
		:EnableDepthBuffer(true)
		:EnableAlphaBuffer(true)
		:EnablePreserveTexture(false)
		:Create()
end
local function aftR(self)
	self
		:SetSize(SCREEN_WIDTH, SCREEN_HEIGHT)
		:EnableFloat(false)
		:EnableDepthBuffer(true)
		:EnableAlphaBuffer(false)
		:EnablePreserveTexture(true)
		:Create()
end
local function aftblur(self, scale)
	self
		:SetSize(SCREEN_WIDTH / scale, SCREEN_HEIGHT / scale)
		:EnableFloat(false)
		:EnableDepthBuffer(true)
		:EnableAlphaBuffer(true)
		:EnablePreserveTexture(false)
		:Create()
end
local function sprite(self)
	self:Center()
end
local function spriteblur(self, scale)
	self
		:Center()
		:basezoom(scale)
end
local function aftsprite(aft, sprite)
	sprite:SetTexture(aft:GetTexture())
end

local t = Def.ActorFrame {
	InitCommand = function(self)
		self:Center()
	end,
}

-- Mascot
local mascot = Def.ActorFrame {
	InitCommand = function(self)
		self:Center()
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

-- UI
t[#t + 1] = Def.ActorFrame {
	InitCommand = function(self)
		self
			:y(scy - 192)
	end,
	-- Panel
	Def.Quad {
		InitCommand = function(self)
			self
				:skewx(-0.5)
				:SetSize(sw * 1.5, 264)
				:diffuse(ThemeColor.Black)
				:diffusealpha(0.75)
				:fadetop(0.01)
				:fadebottom(0.01)
				:cropleft(1)
		end,
		OnCommand = function(self)
			self
				:easeoutexpo(0.5)
				:cropleft(0)
		end,
		OffCommand = function(self)
			self
				:sleep(0.5)
				:easeoutexpo(0.5)
				:cropleft(1)
		end,
	},
	Def.Quad {
		InitCommand = function(self)
			self
				:skewx(-0.5)
				:SetSize(sw * 1.5, 256)
				:diffuse(ThemeColor.Elements)
				:diffusebottomedge(ThemeColor.Secondary)
				:diffuserightedge(ThemeColor.Elements)
				:diffusealpha(0.5)
				:cropleft(1)
		end,
		OnCommand = function(self)
			self
				:easeoutexpo(0.5)
				:cropleft(0)
		end,
		OffCommand = function(self)
			self
				:sleep(0.5)
				:easeoutexpo(0.5)
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
					:sleep(0.2)
					:linear(0.05)
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
					:sleep(0.25)
					:linear(0.1)
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
					:sleep(0.5)
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
						--'80% of the work takes 20% of the effort.',
						'Only you can limit your creativity.',
						'Shoot the moon and you will hit it.',
						'Faith can be the greatest logic of all.',
						'Take your time to find your inner peace.',
						'Here lies a tranquil void.',
						'Love could be two conversations away.',
						'Boundless potential is at your will.',
						
						'Thank you for being here.',
						'Your existence is appreciated.',
						'Your presence is invaluable.',
					},
					ja = {},
				}
				local langtags = taglines[THEME:GetCurLanguage()]
				if not langtags then langtags = taglines.en end
				local rng = MersenneTwister.Random(1, #langtags)
				self:settext('"'..langtags[rng]..'"')
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
					:sleep(0.3)
					:linear(0.05)
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

-- The title menu gets to look extra pretty.
return Def.ActorFrame {
	Def.ActorFrameTexture {
		Name = 'TitleAFT',
		InitCommand = function(self)
			aft(self)
		end,
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
					:easeoutexpo(0.5)
					:diffusealpha(0.5)
			end,
			OffCommand = function(self)
				self
					:linear(0.5)
					:diffusealpha(0)
			end,
		},
		Def.Sprite {
			Name = 'TitleSprite',
			InitCommand = function(self)
				sprite(self)
			end,
			OnCommand = function(self)
				local aft = self:GetParent():GetParent():GetChild('TitleAFTR')
				aftsprite(aft, self)
				self
					:blend('BlendMode_Add')
					:diffusealpha(0)
					:easeoutexpo(0.5)
					:diffusealpha(0.75)
					:zoom(1.005)
					:queuecommand('Breathe')
			end,
			BreatheCommand = function(self)
				self
					:easeinoutsine(3.5)
					:zoom(1.01)
					:easeinoutsine(3.5)
					:zoom(1.005)
					:queuecommand('Breathe')
			end,
			OffCommand = function(self)
				self
					:stoptweening(0)
					:linear(0.5)
					:diffusealpha(0)
					:zoom(1)
			end,
		},
		mascot,
	},
	Def.ActorFrameTexture {
		Name = 'TitleAFTR',
		InitCommand = function(self)
			aftR(self)
		end,
		Def.Sprite {
			Name = 'TitleSpriteR',
			InitCommand = function(self)
				sprite(self)
			end,
			OnCommand = function(self)
				local aft = self:GetParent():GetParent():GetChild('TitleAFT')
				aftsprite(aft, self)
			end,
		}
	},
	Def.Sprite {
		Name = 'ShowTitle',
		InitCommand = function(self)
			sprite(self)
		end,
		OnCommand = function(self)
			local aft = self:GetParent():GetChild('TitleAFT')
			aftsprite(aft, self)
		end,
	},
	t,
}