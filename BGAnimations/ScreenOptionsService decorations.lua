local music_playing = false
return Def.ActorFrame {
	Def.Actor {
		OnCommand = function(self)
			self:queuecommand('Color')
		end,
		ColorCommand = function(self)
			MESSAGEMAN:Broadcast('ThemeColorChanged', LoadModule('Theme.Colors.lua'))
		end,
	},
	Def.Actor {
		ChangeRowMessageCommand = function(self, params)
			local rows = split(',', THEME:GetMetric('ScreenOptionsService', 'LineNames'))
			if rows[params.RowIndex + 1] == 'WakeUp' then
				SOUND:PlayMusicPart(
					THEME:GetPathS('', 'wake'),
					0,
					200,
					5,
					5,
					true
				)
			else
				SOUND:StopMusic()
			end
		end,
	}
}
