return Def.ActorFrame {
	StartTransitioningCommand=function(self) self:sleep(1) end,
	Def.Quad {
		InitCommand=function(self) self:xy(SCREEN_CENTER_X,SCREEN_CENTER_Y):zoomto(SCREEN_WIDTH+1,SCREEN_HEIGHT):draworder(10000) end,
		StartTransitioningCommand=function(self)
			self:diffuse(color("0,0,0,0")):diffusealpha(0):sleep(1):linear(0.25):diffusealpha(1) 
		end
	}
}