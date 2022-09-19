local konko = LoadModule('Konko.Core.lua')

return Def.ActorFrame {
	StartTransitioningCommand = function(self)
		if SCREENMAN:GetTopScreen():GetNextScreenName() == 'ScreenReloadSongs' then
			TF_WHEEL.AllSongs = nil
			konko.Index = nil
		end
	end,
}