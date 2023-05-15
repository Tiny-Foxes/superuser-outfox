local af = Def.ActorFrame {}

af[#af + 1] = Def.Quad {
	InitCommand = function(self)
		self:FullScreen()
		self:diffusealpha(0.25)
	end,
}
af[#af + 1] = Def.BitmapText {
	Text = "Screen Unimplemented\n(Press Enter to go back to menu)",
	Font = "Common Normal",
	InitCommand = function(self)
		self:Center()
	end,
}

return af
