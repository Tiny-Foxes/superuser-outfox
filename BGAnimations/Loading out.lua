return Def.ActorFrame {
	LoadActor(THEME:GetPathB('Fade', 'out')),
	Def.BitmapText {
		Font = '_xide/40px',
		Text = 'Loading...',
		InitCommand = Actor.Center,
		StartTransitioningCommand=function(self) 
			self:diffusealpha(0):addy(SCREEN_CENTER_Y * 1.2):easeoutexpo(0.5):diffusealpha(1):addy(-SCREEN_CENTER_Y * 1.2)
		end
	}
}
