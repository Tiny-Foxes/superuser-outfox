local ThemeColor = LoadModule('Theme.Colors.lua')

return Def.ActorFrame {
	InitCommand = function(self)
		self
			:Center()
			:sleep(4)
	end,
	Def.Quad {
		InitCommand = function(self)
			self
				:SetSize(SCREEN_WIDTH, SCREEN_HEIGHT)
				:diffuse(color('#000000'))
				:diffusealpha(0)
		end,
		StartTransitioningCommand = function(self)
			self
				:easeoutexpo(1)
				:diffusealpha(0.5)
		end,
	},
	Def.Quad {
		InitCommand = function(self)
			self
				:SetSize(SCREEN_WIDTH * 1.5, 206)
				:diffuse(ColorLightTone(ThemeColor.Red))
				:skewx(-0.5)
				:cropright(1)
		end,
		StartTransitioningCommand = function(self)
			self
				:easeinoutexpo(0.5)
				:cropright(0)
				:sleep(3.5)
				:easeinoutexpo(0.5)
				:cropleft(1)
		end,
	},
	Def.Quad {
		InitCommand = function(self)
			self
				:SetSize(SCREEN_WIDTH * 1.5, 192)
				:diffuse(ColorDarkTone(ThemeColor.Red))
				:diffusebottomedge(ColorDarkTone(ColorDarkTone(ThemeColor.Red)))
				:skewx(-0.5)
				:cropright(1)
		end,
		StartTransitioningCommand = function(self)
			self
				:easeinoutexpo(0.5)
				:cropright(0)
				:sleep(3.5)
				:easeinoutexpo(0.5)
				:cropleft(1)
		end,
	},
	Def.BitmapText {
		Font = '_xiaxide 80px',
		Text = 'FAILED',
		InitCommand = function(self)
			self
				:diffuse(ThemeColor.White)
				:blend('add')
				:diffusealpha(0)
				:addx(-50)
				:addy(20)
				:zoom(2)
		end,
		StartTransitioningCommand = function(self)
			self
				:sleep(0.25)
				:easeoutexpo(0.25)
				:addx(40)
				:diffusealpha(0.5)
				:linear(3)
				:addx(20)
				:easeinexpo(0.25)
				:addx(40)
				:diffusealpha(0)
		end,
	},
	Def.Sound {
		File = THEME:GetPathS(Var('LoadingScreen'), 'failed'),
		StartTransitioningCommand = function(self)
			self:play()
		end,
	},
}
