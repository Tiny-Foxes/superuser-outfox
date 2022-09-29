local finished = false

return Def.ActorFrame {
	Def.Quad {
		InitCommand = function(self)
			self:FullScreen():diffuse(0, 0, 0, 1)
		end,
	},
	Def.Actor {
		LoadingKeysoundMessageCommand = function(self, params)
			if params.Done then self:queuecommand('NextScreen') end
		end,
		NextScreenCommand = function(self)
			if not finished then
				SCREENMAN:GetTopScreen():StartTransitioningScreen('SM_GoToNextScreen')
				finished = true
			end
		end,
	},
}
