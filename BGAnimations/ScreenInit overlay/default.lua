local Intro = {
	'Sudospective'
}

return Def.ActorFrame {
	OnCommand = function(self)
		self:Center()
	end,
	loadfile(THEME:GetPathB('ScreenInit', 'overlay/'..Intro[math.random(1, #Intro)]))()
}