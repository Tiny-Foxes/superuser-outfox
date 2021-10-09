return Def.Quad {
	InitCommand=function(self)
		self:stretchto(0,0,SCREEN_WIDTH,SCREEN_HEIGHT)
		self:diffuse(Alpha(Color.Black,0)):draworder(12000)
	end,
	StartTransitioningCommand=function(self)
		self:decelerate(0.2):diffusealpha(1)
		MESSAGEMAN:Broadcast("TweenCancel")
	end
}