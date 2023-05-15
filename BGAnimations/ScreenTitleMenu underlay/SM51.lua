-- Return this for versions of SM under 5.3
local id = ProductID()
local function input(event)
	if string.find(event.type, 'FirstPress') then
		if string.find(event.button, 'Start') then
			SCREENMAN:PlayStartSound()
			SCREENMAN:GetTopScreen()
				:SetNextScreenName('ScreenExit')
				:StartTransitioningScreen('SM_GoToNextScreen')
		end
	end
end
return Def.ActorFrame {
	OnCommand = function(self)
		for _, v in ipairs {PLAYER_1, PLAYER_2} do
			SCREENMAN:set_input_redirected(v, true)
		end
		SCREENMAN:GetTopScreen():AddInputCallback(input):lockinput(5)
	end,
	OffCommand = function(self)
		SCREENMAN:GetTopScreen():RemoveInputCallback(input)
	end,
	Def.ActorFrame {
		InitCommand = function(self)
			self:Center():diffusealpha(0)
		end,
		OnCommand = function(self)
			self:linear(0.5):diffusealpha(1)
		end,
		StartTransitioningCommand = function(self)
			self:linear(0.5):diffusealpha(1)
		end,
		Def.Sprite {
			Name = 'subo',
			Texture = THEME:GetPathG('ScreenTitleMenu', 'mascot'),
			InitCommand = function(self)
				self
					:zoom(1.2)
					:xy(-180, 320)
					:bob()
					:effectmagnitude(0, 4, 0)
					:effectperiod(4)
			end,
			OnCommand = function(self)
				self:decelerate(0.5):addx(20)
			end,
			StartTransitioningCommand = function(self)
				self:decelerate(0.5):addx(-20)
			end
		}
	},
	Def.Quad {
		InitCommand = function(self)
			self
				:Center()
				:SetSize(640, 640)
				:diffusealpha(0.75)
		end,
	},
	Def.BitmapText {
		Text = 'Hey!',
		Font = '_xide/40px',
		InitCommand = function(self)
			self
				:valign(1)
				:xy(SCREEN_CENTER_X, SCREEN_TOP + 140)
				:cropright(1)
				:rainbow()
		end,
		OnCommand = function(self)
			self:sleep(0.25):linear(0.25):cropright(0)
		end,
		StartTransitioningCommand = function(self)
			self:linear(0.25):diffusealpha(0)
		end,
	},
	Def.BitmapText {
		Font = 'Sudo/36px',
		InitCommand = function(self)
			local text = (
				'Sudo here. I\'m the creator of this theme.\n'..
				'First off, I want to say thank you for downloading Superuser!\n'..
				'\n'..
				'Unfortunately, this theme only works on Project OutFox.\n'..
				' The theme currently detects the game\'s product ID as\n'..
				id..'This will cause issues later in the theme, as it\n'..
				'uses OutFox-specific functions and variables not\n'..
				'present in '..id..'.\n'..
				'\n'..
				'You can download Project OutFox at projectoutfox.com and\n'..
				'play this theme with dance, pump, taiko, gh, and so many\n'..
				'more amazing game modes! Check them out!\n'..
				'\n'..
				'If you don\'t want to try out OutFox, and you still want\n'..
				'to use this theme, feel free to start a discussion on the\n'..
				'Superuser GitHub for me to support your StepMania version!\n'..
				'As of now, I haven\'t been asked, and have no plans, but\n'..
				'you can let me know that you want your version supported\n'..
				'and with enough feedback I\'ll do my best and give it a shot.\n'..
				'\n'..
				'Thank you!'
			)
			self
				:valign(0)
				:xy(SCREEN_CENTER_X, SCREEN_TOP + 160)
				:diffuse(color('#000000'))
				:zoom(0.65)
				:settext(text)
				:cropright(1)
		end,
		OnCommand = function(self)
			self:sleep(0.5):linear(3):cropright(0)
		end,
		StartTransitioningCommand = function(self)
			self:linear(0.5):diffusealpha(0)
		end,
	}
}
