return Def.Quad {
	InitCommand = function(self)
		self
			:SetSize(300, 32)
			:skewx(-0.5)
			:diffuse(color('#000000'))
			:diffusealpha(0.5)
			:fadetop(0.1)
			:fadebottom(0.1)
	end,
}