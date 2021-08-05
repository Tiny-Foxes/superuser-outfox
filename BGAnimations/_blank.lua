return Def.ActorFrame {
	Def.Quad {
		InitCommand=function(self) self:xy(SCREEN_CENTER_X,SCREEN_CENTER_Y):zoomto(1,1):diffusealpha(0) end,
		StartTransitioningCommand=function(self) end
	}
}