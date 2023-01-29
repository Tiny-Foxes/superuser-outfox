local game = GAMESTATE:GetCurrentGame():GetName():lower()
GAMESTATE:SetCurrentStyle(TF_WHEEL.QuickStyleDB[game])
local song = SONGMAN:FindSong('tutorial-'..game)
if song then GAMESTATE:SetCurrentSong(song) end
local steps = GAMESTATE:GetCurrentSong():GetAllSteps()

local choices = {
	dance = {
		'Basic Steps\n\nBest for absolute beginners.\n\n\n\nMaterial Covered:\n- Screen Info\n- Timing\n- Tap Notes\n- Hold Notes\n- Jumps',
		'Rookie Playstyle\n\nGood for those not too familiar,\nor if it\'s been a long time.\n\n\nMaterial Covered:\n- Roll Notes\n- Mines\n- Hand Notes',
		'Pro Strats\n\nGreat for people looking to\nup their game.\n\n\nMaterial Covered:\n- Lifts\n- Fakes\n- Chart Flow\n- Comprehensive Patterns',
		'Insane Techniques\n\nA choice for people wanting to\ntop the leaderboards.\n\n\nMaterial Covered:\n- Stamina Streams\n- Technical Patterns',
		'An Extra Challenge\n\nModfiles:\nReading Charts at a\nCollege Grade Level\n\nMaterial Covered:\n- Modifiers\n- Mod Parsing\n- Chart Chunking',
	}
}

local options = {
	StartIndex = 1,
	{'Tutorial 1', function(self)
		_SUPERUSER.TutorialLevel = 'Beginner'
		local step
		for _, v in ipairs(steps) do
			if (
				ToEnumShortString(v:GetDifficulty()) == _SUPERUSER.TutorialLevel and
				v:GetStepsType():lower():find(game)
			) then
				step = v
			end
		end
		if not step then return end
		for _, v in ipairs(GAMESTATE:GetEnabledPlayers()) do
			GAMESTATE:SetCurrentSteps(v, step)
		end
		SCREENMAN:GetTopScreen()
			:SetNextScreenName('ScreenGameplayTutorial')
			:StartTransitioningScreen('SM_GoToNextScreen')
	end},
	{'Tutorial 2', function(self)
		_SUPERUSER.TutorialLevel = 'Easy'
		local step
		for _, v in ipairs(steps) do
			if (
				ToEnumShortString(v:GetDifficulty()) == _SUPERUSER.TutorialLevel and
				v:GetStepsType():lower():find(game)
			) then
				step = v
			end
		end
		if not step then return end
		for _, v in ipairs(GAMESTATE:GetEnabledPlayers()) do
			GAMESTATE:SetCurrentSteps(v, step)
		end
		SCREENMAN:GetTopScreen()
			:SetNextScreenName('ScreenGameplayTutorial')
			:StartTransitioningScreen('SM_GoToNextScreen')
	end},
	{'Tutorial 3', function(self)
		_SUPERUSER.TutorialLevel = 'Medium'
		local step
		for _, v in ipairs(steps) do
			if (
				ToEnumShortString(v:GetDifficulty()) == _SUPERUSER.TutorialLevel and
				v:GetStepsType():lower():find(game)
			) then
				step = v
			end
		end
		if not step then return end
		for _, v in ipairs(GAMESTATE:GetEnabledPlayers()) do
			GAMESTATE:SetCurrentSteps(v, step)
		end
		SCREENMAN:GetTopScreen()
			:SetNextScreenName('ScreenGameplayTutorial')
			:StartTransitioningScreen('SM_GoToNextScreen')
	end},
	{'Tutorial 4', function(self)
		_SUPERUSER.TutorialLevel = 'Hard'
		local step
		for _, v in ipairs(steps) do
			if (
				ToEnumShortString(v:GetDifficulty()) == _SUPERUSER.TutorialLevel and
				v:GetStepsType():lower():find(game)
			) then
				step = v
			end
		end
		if not step then return end
		for _, v in ipairs(GAMESTATE:GetEnabledPlayers()) do
			GAMESTATE:SetCurrentSteps(v, step)
		end
		SCREENMAN:GetTopScreen()
			:SetNextScreenName('ScreenGameplayTutorial')
			:StartTransitioningScreen('SM_GoToNextScreen')
	end},
	{'Tutorial X', function(self)
		_SUPERUSER.TutorialLevel = 'Challenge'
		local step
		for _, v in ipairs(steps) do
			if (
				ToEnumShortString(v:GetDifficulty()) == _SUPERUSER.TutorialLevel and
				v:GetStepsType():lower():find(game)
			) then
				step = v
			end
		end
		if not step then return end
		for _, v in ipairs(GAMESTATE:GetEnabledPlayers()) do
			GAMESTATE:SetCurrentSteps(v, step)
		end
		SCREENMAN:GetTopScreen()
			:SetNextScreenName('ScreenGameplayTutorial')
			:StartTransitioningScreen('SM_GoToNextScreen')
	end},
}

local wheel = LoadModule('Options.Wheel.lua')(options)

return Def.ActorFrame {
	wheel,
	Def.BitmapText {
		Font = 'Common Large',
		InitCommand = function(self)
			self
				:xy(SCREEN_LEFT + 120, SCREEN_TOP + 120)
				:halign(0)
				:valign(0)
				:zoom(0.75)
		end,
		MoveOptionsMessageCommand = function(self, params)
			self
				:stoptweening()
				:settext(choices[game][params.Index])
				:cropright(1)
				:linear(0.25)
				:cropright(0)
		end,
	}
}
