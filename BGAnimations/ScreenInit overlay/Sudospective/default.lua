local taglines = {

}

return Def.ActorFrame {
	OnCommand = function(self)
		self:zoom(SCREEN_HEIGHT / 720)
	end,
	Def.Sound {
		File = 'nyoron.ogg',
		OnCommand = function(self)
			self
				:sleep(0.25)
				:queuecommand('Play')
		end,
		PlayCommand = function(self)
			self:play()
		end,
	},
	Def.Sprite {
		Texture = 'bg.png',
		OnCommand = function(self)
			self:zoom(1.5)
		end,
	},
	Def.Sprite {
		Texture = 'banner.png',
		OnCommand = function(self)
			self
				:wag()
				:effectmagnitude(0, 0, 2)
				:zoom(0)
				:sleep(0.5)
				:easeoutback(0.25)
				:zoom(0.5)
				:sleep(2)
				:easeinback(0.25)
				:zoom(0)
		end,
	},
	Def.Quad {
		InitCommand = function(self)
			self
				:zoomto(SCREEN_WIDTH, SCREEN_HEIGHT)
				:diffuse(color('#000000'))
				:linear(0.25)
				:diffusealpha(0)
				:sleep(3)
				:linear(0.25)
				:diffusealpha(1)
				:sleep(1)
				:queuecommand('EndInit')
		end,
		EndInitCommand = function(self)
			SCREENMAN:GetTopScreen():StartTransitioningScreen('SM_GoToNextScreen')
		end,
	}
}
