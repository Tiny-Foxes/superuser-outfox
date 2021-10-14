return Def.ActorFrame {
	Def.Quad {
		InitCommand = function(self)
			self:FullScreen():diffuse(color('#000000'))
			lua.Trace('ScreenStageInformation')
		end,
	},
}