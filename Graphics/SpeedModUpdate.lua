-- Speed Mod Updater
local pn = ...
local t = Def.ActorFrame{}

local speed = {}
speed[pn] = {0,""}
local col = (pn == PlayerNumber[2] and 2) or 1
local Speedmargin = LoadModule("Config.Load.lua")("SpeedMargin","Save/OutFoxPrefs.ini") and LoadModule("Config.Load.lua")("SpeedMargin","Save/OutFoxPrefs.ini")*100 or 25
local ORNum = 1

t[#t+1] = Def.Actor{
	Font="Common Normal",
	SpeedModTypeChangeMessageCommand=function(s,param)
		if param.pn == pn then
			speed[pn][2] = param.choicename
			local text = ""
			if speed[pn][2] == "x" then
				text = speed[pn][1] * .01 .. "x"
			else
				text = string.upper(speed[pn][2]) .. speed[pn][1]
			end
			s:playcommand("UpdateString", {Speed=text} )
		end
	end,
	UpdateStringCommand=function(s)
		if speed[pn][1] < Speedmargin then
			speed[pn][1] = Speedmargin
		end
		if (getenv("NewOptions") == "Main" or getenv("NewOptions") == nil) and SCREENMAN:GetTopScreen() and SCREENMAN:GetTopScreen():GetOptionRow(ORNum) then
			local text = ""
			if speed[pn][2] == "x" then
				text = speed[pn][1] * 0.01 .. "x"
			else
				text = string.upper(speed[pn][2]) .. speed[pn][1]
			end
			MESSAGEMAN:Broadcast("SpeedChoiceChanged",{pn=pn,mode=speed[pn][2],speed=speed[pn][1]})
			SCREENMAN:GetTopScreen():GetOptionRow(ORNum):GetChild(""):GetChild("Item")[col]:settext( text )
		end
	end,
	OnCommand=function(s)
		local playeroptions = GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred")
		if playeroptions:XMod() then speed[pn][1] = math.floor(playeroptions:XMod()*100) speed[pn][2] = "x" end
		if playeroptions:CMod() then speed[pn][1] = math.floor(playeroptions:CMod()) speed[pn][2] = "c" end
		if playeroptions:MMod() then speed[pn][1] = math.floor(playeroptions:MMod()) speed[pn][2] = "m" end
		if playeroptions:AMod() then speed[pn][1] = math.floor(playeroptions:AMod()) speed[pn][2] = "a" end
		if playeroptions:CAMod() then speed[pn][1] = math.floor(playeroptions:CAMod()) speed[pn][2] = "ca" end
		if playeroptions:AVMod() then speed[pn][1] = math.floor(playeroptions:AVMod()) speed[pn][2] = "av" end
		if speed[pn][1] > 10000 then
			speed[pn][1] = 100
		end
		while speed[pn][1] % 25 ~= 0 do
			speed[pn][1] = math.floor(speed[pn][1] * 0.2) * 5 + 5
		end
		if SCREENMAN:GetTopScreen() then
			-- Automatic check for the optionrow that contains the speed mod.
			for i=0,SCREENMAN:GetTopScreen():GetNumRows()-1 do
				if SCREENMAN:GetTopScreen():GetOptionRow(i):GetName() == "SpeedModVal" then
					ORNum = i
					break
				end
			end
			local text = ""
			if speed[pn][2] == "x" then
				text = speed[pn][1] * 0.01 .. "x"
			else
				text = string.upper(speed[pn][2]) .. speed[pn][1]
			end
			MESSAGEMAN:Broadcast("SpeedChoiceChanged",{pn=pn,mode=speed[pn][2],speed=speed[pn][1]})
			s:sleep(0.2):queuecommand("UpdateString")
		end
	end,
	["MenuLeft"..ToEnumShortString(pn).."MessageCommand"]=function(s)
		local row_index = SCREENMAN:GetTopScreen():GetCurrentRowIndex(pn)
		if row_index == ORNum then
			SOUND:PlayOnce( THEME:GetPathS("Common","value") )
			speed[pn][1] = speed[pn][1] - Speedmargin
			s:playcommand("UpdateString")
		end
	end,
	["MenuRight"..ToEnumShortString(pn).."MessageCommand"]=function(s)
		local row_index = SCREENMAN:GetTopScreen():GetCurrentRowIndex(pn)
		if row_index == ORNum then
			SOUND:PlayOnce( THEME:GetPathS("Common","value") )
			speed[pn][1] = speed[pn][1] + Speedmargin
			s:playcommand("UpdateString")
		end
	end,
	OffCommand=function(s)
		local playeroptions = GAMESTATE:GetPlayerState(pn):GetPlayerOptions("ModsLevel_Preferred")

		if speed[pn][2] == "x" then
			playeroptions:XMod(speed[pn][1]*0.01)
		elseif speed[pn][2] == "c" then
			playeroptions:CMod(speed[pn][1])
		elseif speed[pn][2] == "m" then
			playeroptions:MMod(speed[pn][1])
		elseif speed[pn][2] == "a" then
			playeroptions:AMod(speed[pn][1])
		elseif speed[pn][2] == "ca" then
			playeroptions:CAMod(speed[pn][1])
		elseif speed[pn][2] == "av" then
			playeroptions:AVMod(speed[pn][1])
		end
	end,
}

return t;