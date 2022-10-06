local ThemeColor = LoadModule('Theme.Colors.lua')

return Def.ActorFrame {
	Def.Quad {
		InitCommand = function(self)
			self
				:SetSize(64, 56)
				:cropleft(0.1)
				:cropright(0.1)
		end,
		SetCommand = function(self, param)
			if not param then return end
			if not ThemeColor[param.CustomDifficulty] then
				lua.Trace('No color for difficulty "'..param.CustomDifficulty..'".')
				return
			end
			self:diffuse(ThemeColor[param.CustomDifficulty])
		end,
	},
	Def.Quad {
		InitCommand = function(self)
			self
				:SetSize(64, 56)
				:shadowlength(2, 2)
				:cropleft(0.1)
				:cropright(0.1)
				:fadetop(1)
				:diffuse(ThemeColor.Pink)
		end,
		SetCommand = function(self, param)
			if not param then return end
			if param.Steps and param.Steps:IsAutogen() then
				self:diffusealpha(0.5)
			else
				self:diffusealpha(0)
			end
		end,
	},
}