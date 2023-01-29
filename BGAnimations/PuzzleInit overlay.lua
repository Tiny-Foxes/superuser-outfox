local next_screen = 'PuzzleIntro'
if FILEMAN:DoesFileExist(THEME:GetPathO('', 'save.json')) then next_screen = 'PuzzleTitleMenu' end
return Def.Actor {
	OnCommand = function(self)
		SCREENMAN:GetTopScreen()
			:SetNextScreenName(next_screen)
			:StartTransitioningScreen()
	end,
}