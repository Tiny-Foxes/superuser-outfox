local ThemeColor = LoadModule('Theme.Colors.lua')

return Def.ActorFrame {
	Def.Quad {
		InitCommand = function(self)
			self
				:SetSize(320, 48)
				:diffuse(ThemeColor.Elements)
				:skewx(-0.5)
				:shadowlength(2, 2)
		end,
	}
}
