-- Return this for versions of SM under 5.3
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
				self:easeoutexpo(0.5):addx(20)
			end,
			StartTransitioningCommand = function(self)
				self:easeoutexpo(0.5):addx(-20)
			end
		}
	},
	Def.BitmapText {
		Text = 'Hey!',
		Font = '_xide/40px',
		InitCommand = function(self)
			self
				:valign(1)
				:xy(SCREEN_TOP + 180, SCREEN_CENTER_Y)
				:cropright(1)
		end,
		OnCommand = function(self)
			self:linear(0.5):cropright(0)
		end,
		StartTransitioningCommand = function(self)
			self:linear(0.5):diffusealpha(0)
		end,
	},
	Def.BitmapText {
		Font = 'Sudo/36px',
		InitCommand = function(self)
			local text = (
				'Sudo here. I\'m the creator of this theme.\n'..
				'First off, I want to say thank you for downloading Superuser!\n'..
				'\n'..
				'Unfortunately, this theme only works on Project OutFox. The theme currently detects\n'..
				'the game\'s product ID as '..id..'. This will cause issues later in the theme,\n'..
				'as it uses OutFox-specific functions and variables not present in '..id..'.\n'..
				'\n'..
				'You can download Project OutFox at projectoutfox.com and play this theme with\n'..
				'dance, pump, taiko, gh, and so many more amazing game modes! Check them out!\n'..
				'\n'..
				'If you don\'t want to try out OutFox, and you still want to use this theme,\n'..
				'Feel free to start a discussion on the Superuser GitHub for me to support your\n'..
				'StepMania version! As of now, I haven\'t been asked, and have no plans, but you can\n'..
				'let me know that you want your version supported and with enough feedback I\'ll do\n'..
				'my best and give it a shot.\n'..
				'\n'..
				'Thank you!'
			)
			self
				:valign(0)
				:xy(SCREEN_TOP + 200, SCREEN_CENTER_Y)
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