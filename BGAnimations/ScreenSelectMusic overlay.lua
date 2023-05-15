local songpos = GAMESTATE:GetSongPosition()

return Def.ActorFrame {
	LoadActorWithParams(THEME:GetPathG('', 'screenheader'), {}),
	Def.Sprite {
		Texture = THEME:GetPathG('', 'niko'),
		InitCommand = function(self)
			self
				:xy(SCREEN_WIDTH - 80, SCREEN_HEIGHT - 120)
				:zoom(0.5)
				:diffusealpha(0)
				:visible(false)
		end,
		OnCommand = function(self)
			self
				:diffusealpha(0)
				:luaeffect('UpdateDanceSpeed')
		end,
		CurrentSongChangedMessageCommand = function(self)
			self
				:stoptweening()
				:diffusealpha(0)
		end,
		MusicLoopNearEndMessageCommand = function(self)
			self
				:linear(0.25)
				:diffusealpha(0)
		end,
		MusicLoopEndMessageCommand = function(self)
			songpos = GAMESTATE:GetSongPosition()
			self
				:position(0)
				:linear(0.5)
				:diffusealpha(1)
		end,
		UpdateDanceSpeedCommand = function(self)
			local speed = songpos:GetCurBPS()
			if songpos:GetDelay() or songpos:GetFreeze() then
				speed = 0
			end
			self:rate(speed)
		end,
	}
}
