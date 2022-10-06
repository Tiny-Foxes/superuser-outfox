return Def.ActorFrame {
	InitCommand = function(self)
		self:Center()
	end,
	StandardDecorationFromFileOptional("SongOptions","SongOptionsText") .. {
		AskForGoToOptionsCommand=THEME:GetMetric(Var "LoadingScreen","SongOptionsShowCommand"),
		GoToOptionsCommand=THEME:GetMetric(Var "LoadingScreen","SongOptionsEnterCommand"),
		HidePressStartForOptionsCommand=THEME:GetMetric(Var "LoadingScreen","SongOptionsHideCommand")
	}
}
