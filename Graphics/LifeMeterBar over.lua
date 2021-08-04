local ThemeColor = LoadModule('Theme.Colors.lua')

return Def.ActorFrame {
	InitCommand = function(self)
		self:skewx(-0.5)
	end,
	-- Lifebar background
	Def.Quad {
		InitCommand = function(self)
			self
				:SetSize(300, 34)
				:diffuse(color('#000000'))
				:fadetop(0.1)
				:fadebottom(0.1)
		end,
	},
	-- Lifebar color
	Def.ActorFrame {
		InitCommand = function(self)
			self
				:SetSize(300, 30)
				:diffuse(color('#AAAAAA'))
		end,
		Def.Quad {
			InitCommand = function(self)
				self
					:SetSize(300, 30)
					:cropright(0.4)
			end,
			LifeChangedMessageCommand = function(self, param)
				local plr = param.Player
				local lifebar = param.LifeMeter
				self
					:stoptweening()
					:easeoutelastic(1.5)
					:cropright(1 - lifebar:GetLife())
			end,
		},
		Def.Quad {
			InitCommand = function(self)
				self
					:SetSize(300, 30)
					:blend('BlendMode_WeightedMultiply')
					:diffuse(ThemeColor.Cyan)
					:diffuseleftedge(ThemeColor.Slate)
			end,
			LifeChangedMessageCommand = function(self, param)
				local plr = param.Player
				local lifebar = param.LifeMeter
				if lifebar:IsHot() then
					self
						:stoptweening()
						:linear(0.25)
						:diffuse(ThemeColor.Orange)
						:diffuseleftedge(ThemeColor.Yellow)
				else
					self
						:stoptweening()
						:linear(0.25)
						:diffuse(ThemeColor.Cyan)
						:diffuseleftedge(ThemeColor.Slate)
				end
			end,
		}
	},
	-- Lifebar Ticks
	Def.ActorFrame {
		Def.Quad {
			InitCommand = function(self)
				self
					:SetSize(2, 30)
					:x(-75)
			end,
		},
		Def.Quad {
			InitCommand = function(self)
				self
					:SetSize(2, 30)
			end,
		},
		Def.Quad {
			InitCommand = function(self)
				self
					:SetSize(2, 30)
					:x(75)
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
