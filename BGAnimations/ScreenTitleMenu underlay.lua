local scx, scy = SCREEN_CENTER_X, SCREEN_CENTER_Y
local sw, sh = SCREEN_WIDTH, SCREEN_HEIGHT
local scale = sh / 480

local t = Def.ActorFrame {
	InitCommand = function(self)
		self:Center()
	end
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
				:diffuse(color('#000000'))
				:diffusealpha(0.75)
				:fadetop(0.01)
				:fadebottom(0.01)
		end,
	},
	Def.Quad {
		InitCommand = function(self)
			self
				:SetSize(sw, 256)
				:diffuse(color('#9D276C'))
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
					:xy(-360, -32)
					:horizalign('right')
					:shadowlengthy(2)
					:diffuse(color('#FFFF00'))
					:diffusebottomedge(color('#FF8000'))
					:cropright(1)
					:linear(0.1)
					:cropright(0)
			end,
		},
		Def.BitmapText {
			Font = '_xiaxide 80px',
			Text = 'Superuser',
			InitCommand = function(self)
				self
					:xy(-180, 32)
					:shadowlengthy(4)
					:diffuse(color('#CF3A98'))
					:diffusebottomedge(color('#A33179'))
					:cropright(1)
					:sleep(0.1)
					:linear(0.2)
					:cropright(0)
	
			end,
		},
		Def.BitmapText {
			Font = 'Common Normal',
			Text = 'Theme by Sudospective\nPowered by Konko',
			InitCommand = function(self)
				self
					:zoom(0.5)
					:xy(-120, 56)
					:horizalign('left')
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