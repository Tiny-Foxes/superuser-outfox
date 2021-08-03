local ThemeColor = LoadModule('Theme.Colors.lua')

return Def.ActorFrame {
	Def.Quad {
		InitCommand = function(self)
			self
				:SetSize(320, 48)
				:diffuse(ThemeColor.Primary)
				:skewx(-0.5)
		end,
	}
}
