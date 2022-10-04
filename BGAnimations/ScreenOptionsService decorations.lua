return Def.ActorFrame {
	Def.Actor {
		OnCommand = function(self)
			self:queuecommand('Color')
		end,
		ColorCommand = function(self)
			MESSAGEMAN:Broadcast('ThemeColorChanged', LoadModule('Theme.Colors.lua'))
		end,
	},
}
