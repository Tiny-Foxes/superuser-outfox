return Def.ActorFrame {
	InitCommand = Actor.Center,
	Def.Quad {
		InitCommand = function(self)
			self:SetSize(SCREEN_WIDTH, SCREEN_HEIGHT):diffuse(0, 0, 0, 1)
		end,
	},
}
