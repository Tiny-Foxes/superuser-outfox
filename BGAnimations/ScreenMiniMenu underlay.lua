local ThemeColor = LoadModule('Theme.Colors.lua')

return Def.ActorFrame {
	OnCommand = function(self)
		self:queuecommand('Recenter')
	end,
	RecenterCommand = function(self)
		SCREENMAN:GetTopScreen():xy(0, 0)
	end,
	Def.Quad {
		InitCommand = function(self)
			self
				:FullScreen()
				:diffuse(ThemeColor.Primary)
				:diffusealpha(0)
		end,
		OnCommand = function(self)
			self
				:stoptweening()
				:linear(0.1)
				:diffusealpha(0.5)
		end,
		OffCommand = function(self)
			self
				:stoptweening()
				:linear(0.1)
				:diffusealpha(0)
		end,
	}

}
