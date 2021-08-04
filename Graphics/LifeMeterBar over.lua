local ThemeColor = LoadModule('Theme.Colors.lua')
return Def.ActorFrame {
	Name = 'LifeBar',
	Def.ActorFrame {
		Name = 'LifeBarTicks',
		Def.Quad {
			InitCommand = function(self)
				self:addx(-75):SetSize(2, 30):diffuse(ThemeColor.Gray)
			end,
		},
		Def.Quad {
			InitCommand = function(self)
				self:SetSize(4, 30):diffuse(ThemeColor.Gray)
			end,
		},
		Def.Quad {
			InitCommand = function(self)
				self:addx(75):SetSize(2, 30):diffuse(ThemeColor.Gray)
			end,
		},
	},
	Def.ActorFrame {
		Name = 'LifeBarFrame',
		Def.Quad {
			InitCommand = function(self)
				self:addy(-11):SetSize(300, 8):diffuse(ThemeColor.Gray)
			end,
		},
		Def.Quad {
			InitCommand = function(self)
				self:addx(-146):SetSize(8, 30):diffuse(ThemeColor.Gray)
			end,
		},
		Def.Quad {
			InitCommand = function(self)
				self:addy(11):SetSize(300, 8):diffuse(ThemeColor.Gray)
			end,
		},
		Def.Quad {
			InitCommand = function(self)
				self:addx(146):SetSize(8, 30):diffuse(ThemeColor.Gray)
			end,
		},
	}
}
