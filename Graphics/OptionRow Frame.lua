local Judges = Def.ActorFrame{}

local function WideToMax( minscale, maxscale )
	return SCREEN_WIDTH <= 1280 and scale( SCREEN_WIDTH, 960, 1280, minscale, maxscale ) or maxscale
end

-- Generate Block background for element.
-- Usual size can be found in OptionRow
local item_width = THEME:GetMetric("OptionRow","ItemsStartX") + scale( SCREEN_WIDTH, 960, 1280, SCREEN_RIGHT-300 + 30, SCREEN_RIGHT-20 + 30)
Judges[#Judges+1] = Def.Quad{
	OnCommand=function(self) self:zoomto(SCREEN_WIDTH,50):halign(0):diffuse( color("#00000076") ) end,
}
Judges[#Judges+1] = Def.ActorFrame {
	Condition=not GAMESTATE:GetPlayMode();
	OnCommand=function(s) s:x(SCREEN_CENTER_X):zoomx(0):playcommand("GainFocus") end,
	GainFocusCommand=function(self)
		local focus = self:GetParent():GetParent():GetParent():HasFocus( GAMESTATE:GetMasterPlayerNumber() )
		self:stoptweening():linear(0.16):diffusealpha(1):zoomx( focus and 1 or 0 )
	end;
	LoseFocusCommand=function(self) self:stoptweening():linear(0.16):diffusealpha(0):zoomx(0) end;
	Def.Quad {InitCommand=function(self) self:zoomto(item_width,4):vertalign(top):y(-52/2):diffuse(color("#FFC447")):diffuseleftedge(color("#FF8D47")) end,},
	Def.Quad {InitCommand=function(self) self:zoomto(item_width,4):vertalign(bottom):y(52/2):diffuse(color("#FF8D47")):diffuseleftedge(color("#FFC447")) end,},
};

for _, pn in ipairs(GAMESTATE:GetEnabledPlayers()) do
	local pos = { [PLAYER_1] = 0, [PLAYER_2] = 300 }
	Judges[#Judges+1] = LoadActor(THEME:GetPathG('_StepsDisplayListRow', 'Cursor')) .. {
		Condition=GAMESTATE:IsHumanPlayer(pn) and GAMESTATE:GetPlayMode(),
		OnCommand=function(s)
			local margin = SCREEN_WIDTH > 1280 and 500 or 526
			s:xy( pn == PLAYER_1 and 40 or WideScale(722,526) , 0 )
			:diffuse( PlayerColor(pn) ):diffusealpha(0)
			--:zoomx( pn == PLAYER_2 and -1 or 1 )
			:playcommand("GainFocus")
		end,
		GainFocusCommand=function(self)
			local margin = SCREEN_WIDTH > 1280 and 350 or 360
			local focus = self:GetParent():GetParent():GetParent():HasFocus(pn)
			self:stoptweening():linear(0.16)
			self:diffusealpha(focus and 1 or 0)
			self:x( pn == PLAYER_1 and 40 or SCREEN_RIGHT - 50 )
		end;
		LoseFocusCommand=function(self)
			local focus = self:GetParent():GetParent():GetParent():HasFocus(pn)
			self:stoptweening():linear(0.16):diffusealpha(focus and 1 or 0)
			self:x( pn == PLAYER_1 and 10 or SCREEN_RIGHT - 10 )
		end;
	}

	Judges[#Judges+1] = Def.ActorFrame{
		OnCommand=function(s)
			if SCREENMAN:GetTopScreen() then
				s:visible( not string.find( SCREENMAN:GetTopScreen():GetName(), "ScreenMiniMenu" ) )
			end
		end,
		GainFocusCommand=function(self)
			local focus = self:GetParent():GetParent():GetParent():HasFocus(pn)
			self:stoptweening():linear(0.16):diffusealpha(focus and 1 or 0)
		end;
		LoseFocusCommand=function(self)
			local focus = self:GetParent():GetParent():GetParent():HasFocus(pn)
			self:stoptweening():linear(0.16):diffusealpha(focus and 1 or 0)
		end;
		Def.Quad {InitCommand=function(self)
			self:halign( _-1 ):x(pn == PLAYER_1 and 0 or SCREEN_RIGHT )
			:wag()
			:effectmagnitude(0, 45, 0)
			:fadeleft( pn == PLAYER_2 and 0.5 or 0 ):faderight( pn == PLAYER_1 and 0.5 or 0 )
			:zoomto(item_width/2,4):vertalign(top):y(-52/2):diffuse(PlayerColor(pn)):diffuseleftedge(ColorLightTone(PlayerColor(pn))) end,},
		Def.Quad {InitCommand=function(self)
			self:halign( _-1 ):x(pn == PLAYER_1 and 0 or SCREEN_RIGHT )
			:wag()
			:effectmagnitude(0, 45, 0)
			:fadeleft( pn == PLAYER_2 and 0.5 or 0 ):faderight( pn == PLAYER_1 and 0.5 or 0 )
			:zoomto(item_width/2,4):vertalign(bottom):y(52/2):diffuse(ColorLightTone(PlayerColor(pn))):diffuseleftedge(PlayerColor(pn)) end,},
	}

	local OriType = LoadModule("Config.Load.lua")("SmartTimings","Save/OutFoxPrefs.ini") or "Original"
	Judges[#Judges+1] = Def.Sprite{
		OnCommand=function(self)
			if self:GetParent():GetParent():GetParent():GetName() == "SmartJudgments" then
				self:x( SCREEN_CENTER_X + (pn == PLAYER_1 and WideToMax(-160,-200) or 380) ):zoom(0.5)
				self:Load(LoadModule("Options.SmartJudgments.lua")()[LoadModule("Options.ChoiceToValue.lua")(LoadModule("Options.SmartJudgments.lua")("Show"),LoadModule("Config.Load.lua")("SmartJudgments",CheckIfUserOrMachineProfile(string.sub(pn,-1)-1).."/OutFoxPrefs.ini") or THEME:GetMetric("Common","DefaultJudgment"))])
				self:playcommand("ReanimateState")
			end
		end,
		SmartJudgmentsChangeMessageCommand=function(self,params)
			if params.pn == pn and self:GetParent():GetParent():GetParent() and self:GetParent():GetParent():GetParent():GetName() == "SmartJudgments" then
				self:Load(LoadModule("Options.SmartJudgments.lua")()[LoadModule("Options.ChoiceToValue.lua")(LoadModule("Options.SmartJudgments.lua")("Show"),LoadModule("Options.SmartJudgeChoices.lua")("Value")[params.choice])])
				self:playcommand("ReanimateState")
			end
		end,
		SmartTimingsChangeMessageCommand=function(self,params)
			if self:GetParent():GetParent():GetParent() and self:GetParent():GetParent():GetParent():GetName() == "SmartJudgments" then
				self:stoptweening():playcommand("Change"):playcommand("ReanimateState")
			end
		end,
		ReanimateStateCommand=function(self)
			self:SetAllStateDelays(1)
		end,
		ChangeCommand=function(self)
			local found = nil
			if TimingWindow[getenv("SmartTimings")]().Name then
				found = LoadModule("Options.SmartJudgments.lua")()[
					LoadModule("Options.ChoiceToValue.lua")(LoadModule("Options.SmartJudgments.lua")("Show"),
					LoadModule("Options.SmartJudgeChoices.lua")("Value")[1])
				]
			end
			if found then
				self:Load( found )
			end
		end
	}
	Judges[#Judges+1] = Def.Sprite{
		OnCommand=function(self)
			if self:GetParent():GetParent():GetParent():GetName() == "SmartHoldJudgments" then
				self:x( SCREEN_CENTER_X + (pn == PLAYER_1 and WideToMax(-160,-200) or 380) ):zoom(0.75)
				self:Load(LoadModule("Options.SmartHoldJudgments.lua")()[LoadModule("Config.Load.lua")("SmartHoldJudgments",CheckIfUserOrMachineProfile(string.sub(pn,-1)-1).."/OutFoxPrefs.ini") or THEME:GetMetric("Common","DefaultHoldJudgment")])
				self:playcommand("ReanimateState")
			end
		end,
		SmartHoldJudgmentsChangeMessageCommand=function(self,params)
			if params.pn == pn and self:GetParent():GetParent():GetParent() and self:GetParent():GetParent():GetParent():GetName() == "SmartHoldJudgments" then
				self:Load(LoadModule("Options.SmartHoldJudgments.lua")()[LoadModule("Options.SmartHoldChoices.lua")("Value")[params.choice]])
				self:playcommand("ReanimateState")
			end
		end,
		ReanimateStateCommand=function(self)
			self:SetAllStateDelays(1)
		end,
	}

	Judges[#Judges+1] = Def.ActorProxy{
		OnCommand=function(self)
			if self:GetParent():GetParent():GetParent():GetName() == "LuaNoteSkins" then
				if SCREENMAN:GetTopScreen() then
					local CurNoteSkin = GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred"):NoteSkin()
					self:SetTarget( SCREENMAN:GetTopScreen():GetChild("NS"..string.lower(CurNoteSkin)) )
					:zoom(0.6):x( SCREEN_CENTER_X + (pn == PLAYER_1 and -200 or 380) )
				end
			end
		end,
		LuaNoteSkinsChangeMessageCommand=function(self,param)
			if self:GetParent():GetParent():GetParent() and self:GetParent():GetParent():GetParent():GetName() == "LuaNoteSkins" then
				if param.pn == pn then
					local name = NOTESKIN:GetNoteSkinNames()[param.choice]
					self:SetTarget( SCREENMAN:GetTopScreen():GetChild("NS"..string.lower(param.choicename)) )
				end
			end
		end,
	}
end
return Judges