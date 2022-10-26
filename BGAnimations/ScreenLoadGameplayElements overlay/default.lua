local finished = false

local tips = {
	'You can change theme options in the Superuser settings.',
	'Be sure to clear any drinks from the controller area.',
	'dink your oiter',
}

return Def.ActorFrame {
	LoadActor(THEME:GetPathB('ScreenPlatformer', 'underlay')),
	OnCommand = function(self)
		for pn in ivalues(GAMESTATE:GetEnabledPlayers()) do
			SCREENMAN:set_input_redirected(pn, true)
		end
	end,
	OffCommand = function(self)
		for pn in ivalues(GAMESTATE:GetEnabledPlayers()) do
			SCREENMAN:set_input_redirected(pn, false)
		end
	end,
	StartTransitioningCommand = function(self)
		for pn in ivalues(GAMESTATE:GetEnabledPlayers()) do
			SCREENMAN:set_input_redirected(pn, false)
		end
	end,
	Def.Quad {
		InitCommand = function(self)
			self
				:valign(1)
				:xy(SCREEN_CENTER_X, SCREEN_BOTTOM)
				:SetSize(SCREEN_WIDTH, 40)
				:diffuse(0, 0, 0, 1)
		end,
	},
	Def.Sprite {
		Texture = THEME:GetPathG('ScreenLoadGameplayElements', 'spinner'),
		InitCommand = function(self)
			self
				:xy(SCREEN_LEFT + 20, SCREEN_BOTTOM - 20)
				:SetSize(20, 20)
				:spin()
		end,
	},
	Def.BitmapText {
		Font = 'Common Large',
		Text = 'Loading Keysounds...',
		InitCommand = function(self)
			self
				:align(0, 1)
				:xy(SCREEN_LEFT + 40, SCREEN_BOTTOM - 12)
				:zoom(0.5)
		end,
	},
	Def.BitmapText {
		Font = 'Common Large',
		InitCommand = function(self)
			self
				:align(1, 1)
				:xy(SCREEN_RIGHT - 12, SCREEN_BOTTOM - 12)
				:zoom(0.5)
				:queuecommand('NewTip')
		end,
		NewTipCommand = function(self)
			local idx = math.random(1, #tips)
			self
				:settext(tips[idx])
				:sleep(8)
				:queuecommand('NewTip')
		end,
		LoadingKeysoundMessageCommand = function(self, params)
			if params.Done then self:stoptweening() end
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
