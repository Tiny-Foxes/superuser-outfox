local Judges = Def.ActorFrame{}

-- Generate Block background for element.
-- Usual size can be found in OptionRow
local item_width = THEME:GetMetric("OptionRow","ItemsStartX") + SCREEN_RIGHT-300 + 30
local master = GAMESTATE:GetMasterPlayerNumber()
Judges[#Judges+1] = Def.Quad{
	OnCommand=function(self) self:halign(0):stretchto(-item_width/2,-24,item_width/2,24):x( -item_width ):diffuse( color("#00000076") ) end,
}
Judges[#Judges+1] = Def.ActorFrame {
	Condition=not GAMESTATE:GetPlayMode();
	OnCommand=function(s) s:zoomx(0):playcommand("GainFocus") end,
	GainFocusCommand=function(self)
		local focus = self:GetParent():GetParent():GetParent():HasFocus( master )
		self:stoptweening():linear(0.16):diffusealpha(1):zoomx( focus and 1 or 0 )
	end;
	LoseFocusCommand=function(self) self:stoptweening():linear(0.16):diffusealpha(0):zoomx(0) end;
	Def.Quad {InitCommand=function(self) self:zoomto(item_width,4):vertalign(top):y(-52/2):diffuse(color("#FFC447")):diffuseleftedge(color("#FF8D47")) end,},
	Def.Quad {InitCommand=function(self) self:zoomto(item_width,4):vertalign(bottom):y(52/2):diffuse(color("#FF8D47")):diffuseleftedge(color("#FFC447")) end,},
}

Judges[#Judges+1] = LoadActor(THEME:GetPathG('_StepsDisplayListRow', 'Cursor') .. {
	OnCommand=function(s)
		s:x( -WideScale(722,526) )
		:diffuse( PlayerColor(master) ):diffusealpha(0)
		:playcommand("GainFocus")
	end,
	GainFocusCommand=function(self)
		local focus = self:GetParent():GetParent():GetParent():HasFocus(master)
		self:stoptweening():linear(0.16)
		self:diffusealpha(focus and 1 or 0)
		self:x( -WideScale(240,360) )
	end,
	LoseFocusCommand=function(self)
		local focus = self:GetParent():GetParent():GetParent():HasFocus(master)
		self:stoptweening():linear(0.16):diffusealpha(focus and 1 or 0)
		self:x( -WideScale(250,370) )
	end,
}

Judges[#Judges+1] = Def.ActorFrame{
	InitCommand=function(s) s:diffusealpha(0) end,
	OffCommand=function(s) s:linear(0.2):diffusealpha(0) end,
	GainFocusCommand=function(self)
		local focus = self:GetParent():GetParent():GetParent():HasFocus(master)
		self:stoptweening():linear(0.16)
		self:diffusealpha(focus and 1 or 0)
	end;
	LoseFocusCommand=function(self)
		local focus = self:GetParent():GetParent():GetParent():HasFocus(master)
		self:stoptweening():linear(0.16):diffusealpha(focus and 1 or 0)
	end;
	Def.Quad {InitCommand=function(self) self:x( -SCREEN_WIDTH/2 )
		:faderight( 0.5 )
		:zoomto(SCREEN_WIDTH/2, 4 ):halign(0):vertalign(top):y(-52/2):diffuse(PlayerColor(master)):diffuseleftedge(ColorLightTone(PlayerColor(master)))
	 end
	},
	Def.Quad {InitCommand=function(self) self:x( -SCREEN_WIDTH/2 )
		:faderight( 0.5 )
		:zoomto(SCREEN_WIDTH/2, 4 ):halign(0):vertalign(bottom):y(52/2):diffuse(ColorLightTone(PlayerColor(master))):diffuseleftedge(PlayerColor(master))
	 end
	},
}

return Judges