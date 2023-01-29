local next_screen = 'PuzzleIntro'
if FILEMAN:DoesFileExist(THEME:GetCurrentThemeDirectory()..'Other/save.json') then next_screen = 'PuzzleTitleMenu' end
return Def.Actor {
	OnCommand = function(self)
		SCREENMAN:GetTopScreen()
			:SetNextScreenName(next_screen)
			:StartTransitioningScreen('SM_GoToNextScreen')
	end,
}
