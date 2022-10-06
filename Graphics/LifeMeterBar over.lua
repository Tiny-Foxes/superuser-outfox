local ThemeColor = LoadModule('Theme.Colors.lua')

return Def.ActorFrame {
	InitCommand = function(self)
		self:skewx(-0.5)
	end,
	-- Lifebar Ticks
	Def.ActorFrame {
		Def.Quad {
			InitCommand = function(self)
				self
					:SetSize(2, 30)
					:x(-75)
					:diffuse(ThemeColor.Gray)
			end,
		},
		Def.Quad {
			InitCommand = function(self)
				self
					:SetSize(2, 30)
					:diffuse(ThemeColor.Gray)
			end,
		},
		Def.Quad {
			InitCommand = function(self)
				self
					:SetSize(2, 30)
					:x(75)
					:diffuse(ThemeColor.Gray)
			end,
		},
	},
	-- Lifebar Frame
	Def.ActorFrame {
		Def.Quad {
			InitCommand = function(self)
				self:addy(-13):SetSize(300, 4):diffuse(ThemeColor.Gray)
			end,
		},
		Def.Quad {
			InitCommand = function(self)
				self:addx(-148):SetSize(4, 30):diffuse(ThemeColor.Gray)
			end,
		},
		Def.Quad {
			InitCommand = function(self)
				self:addy(13):SetSize(300, 4):diffuse(ThemeColor.Gray)
			end,
		},
		Def.Quad {
			InitCommand = function(self)
				self:addx(148):SetSize(4, 30):diffuse(ThemeColor.Gray)
			end,
		},
	},
}
