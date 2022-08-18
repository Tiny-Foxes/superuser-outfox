return Def.ActorFrame {
	LoadActor(THEME:GetPathB('Fade', 'in')),
	Def.BitmapText {
		Font = '_xide/40px',
		Text = 'Loading...',
		InitCommand = Actor.Center,
		OnCommand=function(self) 
			self:easeinexpo(0.5):diffusealpha(0):addy(-SCREEN_CENTER_Y * 1.2)
		end
	}
}
