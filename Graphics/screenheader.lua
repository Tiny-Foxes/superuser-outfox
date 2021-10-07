local ThemeColor = LoadModule('Theme.Colors.lua')

return Def.ActorFrame {
	InitCommand = function(self)
		self
			:xy(SCREEN_CENTER_X, 20)
			:skewx(-0.5)
			:addy(-40)
	end,
	OnCommand = function(self)
		self
			:easeoutexpo(0.25)
			:addy(40)
	end,
	OffCommand = function(self)
		self
			:easeinexpo(0.25)
			:addy(-40)
	end,
	-- its the fuckin song bullshit again
	Def.Quad {
		InitCommand = function(self)
			self
				:SetSize(SCREEN_WIDTH * 1.5, 44)
				:diffuse(ThemeColor.Black)
				:diffusealpha(0.5)
				:fadetop(0.02)
				:fadebottom(0.02)
		end,
	},
	Def.Quad {
		InitCommand = function(self)
			self
				:SetSize(SCREEN_WIDTH * 1.5, 40)
				:diffuse(ThemeColor.Primary)
				:diffusealpha(1)
		end,
	},
	Def.Quad {
		InitCommand = function(self)
			self
				:SetSize(SCREEN_WIDTH * 1.5, 40)
				:diffuse(ThemeColor.Black)
				:diffusealpha(0.25)
		end,
	},
	Def.BitmapText {
		Font = 'Common Normal',
		OnCommand = function(self)
			self
				:x(-SCREEN_CENTER_X + 10)
				:y(-10)
				:skewx(0.5)
				:horizalign('left')
				:vertalign('top')
			self:settext(THEME:GetString(SCREENMAN:GetTopScreen():GetName(), 'HeaderText'))
		end,
		OffCommand = function(self)
		end,
	},
}
