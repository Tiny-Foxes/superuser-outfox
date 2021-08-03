return Def.ActorFrame {
	Def.BitmapText {
		Font = 'Common Normal',
		InitCommand = function(self)
			self
				:skewx(0.5)
				:zoom(0.5)
				:addy(12)
				:maxwidth(72)
		end,
		SetMessageCommand = function(self, param)
			if not param then return end
			local stepstype = THEME:GetString('StepsType', ToEnumShortString(param.StepsType))
			self:settext(stepstype)
		end,
	},
}