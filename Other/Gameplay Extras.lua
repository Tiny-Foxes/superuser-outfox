return Def.ActorFrame { 
	LoadModule("Options.SmartTiming.lua"), 
	LoadModule("Options.SmartScoring.lua"),
	LoadModule("Options.SmartCombo.lua"),
	OnCommand=function(self)
		if(SCREENMAN:GetTopScreen():GetName() == "ScreenGameplay") then
			self:AddChildFromPath(GetModule("Gameplay.Pause.lua"))
		end
	end
}