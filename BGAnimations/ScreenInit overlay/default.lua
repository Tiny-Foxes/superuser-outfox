-- Call this again since NoteSkins don't fully populate.
-- Hacky, but it works. ~Sudo
LoadModule("Row.Prefs.lua")(LoadModule("Options.Prefs.lua"))

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