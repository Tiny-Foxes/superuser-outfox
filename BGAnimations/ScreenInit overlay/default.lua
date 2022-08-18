local Intro = {
	'Sudospective',
	--'Insane',
}

return Def.ActorFrame {
	OnCommand = function(self)
		SOUND:StopMusic()
		self:Center()
	end,
	loadfile(THEME:GetPathB('ScreenInit', 'overlay/'..Intro[math.random(1, #Intro)]))()
}