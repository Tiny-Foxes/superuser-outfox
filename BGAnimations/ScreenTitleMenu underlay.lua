local scx, scy = SCREEN_CENTER_X, SCREEN_CENTER_Y
local sw, sh = SCREEN_WIDTH, SCREEN_HEIGHT
local scale = sh / 480

local ThemeColor = LoadModule('Theme.Colors.lua')

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
	Def.Sprite {
		Texture = THEME:GetPathG('ScreenTitleMenu', 'mascot'),
		InitCommand = function(self)
			self
				:zoom(1.2)
				:y(320)
				:bob()
				:effectmagnitude(0, 4, 0)
				:effectperiod(4)
		end,
		OnCommand = function(self)
			self
				:x(-180)
				:easeoutexpo(0.5)
				:x(-160)
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
		end,
	},
	Def.Quad {
		InitCommand = function(self)
			self
				:SetSize(sw, 256)
				:diffuse(ThemeColor.Elements)
				:diffusealpha(0.5)
		end,
	},
	-- Text
	Def.ActorFrame {
		OnCommand = function(self)
			self
				--:zoom(1.1)
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
					:linear(0.1)
					:cropright(0)
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
					:sleep(0.1)
					:linear(0.2)
					:cropright(0)
			end,
		},
		Def.BitmapText {
			Font = 'Common Normal',
			Text = 'Theme by Sudospective\nPowered by Konko Module System',
			InitCommand = function(self)
				self
					:zoom(0.5)
					:xy(40, 56)
					:horizalign('right')
					:vertalign('top')
					:cropright(1)
					:sleep(0.3)
					:linear(0.1)
					:cropright(0)
			end,
		},
	}
}

return t