local ThemeColor = LoadModule('Theme.Colors.lua')

return Def.ActorFrame {
	InitCommand = function(self)
		self:xy(SCREEN_CENTER_X, -16)
	end,
	OnCommand = function(self)
		self
			:easeoutexpo(0.5)
			:addy(32)
	end,
	OffCommand = function(self)
		self
			:easeinexpo(0.5)
			:addy(-32)
	end,
	Def.Quad {
		InitCommand = function(self)
			self
				:SetSize(SCREEN_WIDTH, 40)
				:diffuse(ThemeColor.Black)
				:fadetop(0.1)
				:fadebottom(0.1)
				:diffusealpha(1)
		end,
	},
	Def.Quad {
		InitCommand = function(self)
			self
				:SetSize(SCREEN_WIDTH, 32)
				:diffuse(ThemeColor.Primary)
				:diffusealpha(0.5)
		end,
	},
	Def.BitmapText {
		Font = 'Common Normal',
		Text = 'Select Music',
		InitCommand = function(self)
			self
				:horizalign('left')
				:x(-SCREEN_CENTER_X + 16)
		end
	}
}
