return LoadActorWithParams(THEME:GetPathG('', 'screenheader'), {}) .. {
	-- This solely exists for the purpose of updating Discord status. ~Sudo
	Def.Actor {
		InitCommand = function(self)
			GAMESTATE:UpdateDiscordScreenInfo('Selecting Mode', '', 1)
		end
	}
}
