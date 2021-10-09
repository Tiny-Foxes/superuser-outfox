local num_players = GAMESTATE:GetHumanPlayers()
local ColorTable = LoadModule("Theme.Colors.lua")

local t = LoadFallbackB()

local song = GAMESTATE:GetCurrentSong()
local course = GAMESTATE:GetCurrentCourse()
local selection = song or course
local bpm1, bpm2
if selection then
	bpm1 = math.floor(selection:GetDisplayBpms()[1])
	bpm2 = math.floor(selection:GetDisplayBpms()[2])
end

t[#t+1] = Def.ActorFrame {
	InitCommand = function(self)
		self
			:xy(112, 56)
			:diffusealpha(0)
	end,
	OnCommand = function(self)
		self
			:linear(0.1)
			:diffusealpha(1)
	end,
	OffCommand = function(self)
		self
			:linear(0.1)
			:diffusealpha(0)
	end,
	Def.ActorFrame {
		InitCommand = function(self)
			self:addx(64)
		end,
		Def.Quad {
			InitCommand = function(self)
				self
					:skewx(-0.5)
					:SetSize(160, 32)
					:diffuse(ColorTable.Gray)
			end,
		},
		Def.BitmapText {
			Font = 'Common Normal',
			InitCommand = function(self)
				if not selection then return end
				local bpmtext

				-- check if the song has hidden bpm
				if song:IsDisplayBpmRandom() then
					self:settext('? ? ?')
					-- return early
					return
				end

				if bpm2 and bpm1 ~= bpm2 then
					bpmtext = math.floor(bpm1)..' - '..math.floor(bpm2)
				else
					bpmtext = math.floor(bpm1)
				end
				self:settext(bpmtext)
			end,
		},
	},
	-- TODO: Join this in a for loop. ~Sudo
	Def.ActorFrame {
		InitCommand = function(self)
			self:addx(224)
		end,
		Def.Quad {
			InitCommand = function(self)
				self
					:skewx(-0.5)
					:SetSize(160, 32)
					:diffuse(ColorDarkTone(PlayerColor(PLAYER_1)))
			end,
		},
		Def.BitmapText {
			Font = 'Common Normal',
			InitCommand = function(self)
				if not selection then return end
				if not GAMESTATE:IsPlayerEnabled(PLAYER_1) then self:visible(false) return end
				self:diffuse(ColorLightTone(PlayerColor(PLAYER_1)))
				local poptions = GAMESTATE:GetPlayerState(PLAYER_1):GetPlayerOptions('ModsLevel_Preferred')
				local bpm1, bpm2 = bpm1, bpm2
				if poptions:XMod() then
					bpm1 = bpm1 * poptions:XMod()
					bpm2 = bpm2 * poptions:XMod()
				elseif poptions:CMod() then
					bpm1 = poptions:CMod()
					bpm2 = poptions:CMod()
				elseif poptions:MMod() then
					bpm1 = (bpm1 * poptions:MMod()) / bpm2 -- gamer moment
					bpm2 = poptions:MMod()
				elseif poptions:AMod() then
					local baseAvg = (bpm1 + bpm2) * 0.5
					local mult = poptions:AMod() / baseAvg -- mega gamer moment
					bpm1 = bpm1 * mult
					bpm2 = bpm2 * mult
				end
				local bpmtext = ''
				if bpm2 and bpm1 ~= bpm2 then
					bpmtext = math.floor(bpm1)..' - '..math.floor(bpm2)
				else
					bpmtext = math.floor(bpm1)
				end


				-- oh no the stepartist hid the display bpm D:
				if song:IsDisplayBpmRandom() then
					if poptions:XMod() then
						bpmtext = poptions:XMod()
					elseif poptions:CMod() then
						bpmtext = poptions:CMod()
					elseif poptions:MMod() then
						bpmtext = poptions:MMod()
					elseif poptions:AMod() then
						bpmtext = poptions:AMod()
					end
				end


				self:settext(bpmtext)
			end,
			SpeedChoiceChangedMessageCommand = function(self, param)
				if not selection then return end
				if param.pn ~= num_players[1] then return end
				local bpm1, bpm2 = bpm1, bpm2
				if param.mode == 'x' then
					bpm1 = bpm1 * (param.speed * 0.01)
					bpm2 = bpm2 * (param.speed * 0.01)
				elseif param.mode == 'c' then
					bpm1 = param.speed
					bpm2 = param.speed
				elseif param.mode == 'm' then
					bpm1 = (bpm1 * param.speed) / bpm2
					bpm2 = param.speed
				elseif param.mode == 'a' then
					local baseAvg = (bpm1 + bpm2) * 0.5
					local mult = param.speed / baseAvg
					bpm1 = bpm1 * mult
					bpm2 = bpm2 * mult
				end
				local bpmtext = ''
				if bpm2 and bpm1 ~= bpm2 then
					bpmtext = math.floor(bpm1)..' - '..math.floor(bpm2)
				else
					bpmtext = math.floor(bpm1)
				end


				-- oh no the stepartist hid the display bpm D:
				if song:IsDisplayBpmRandom() then
					if param.mode == 'x' then
						bpmtext = param.speed / 100
					else
						bpmtext = param.speed
					end
				end


				self:settext(bpmtext)
			end,
		},
	},
	Def.ActorFrame {
		InitCommand = function(self)
			self:addx(384)
		end,
		Def.Quad {
			InitCommand = function(self)
				self
					:skewx(-0.5)
					:SetSize(160, 32)
					:diffuse(ColorDarkTone(PlayerColor(PLAYER_2)))
			end,
		},
		Def.BitmapText {
			Font = 'Common Normal',
			InitCommand = function(self)
				if not selection then return end
				if not GAMESTATE:IsPlayerEnabled(PLAYER_2) then self:visible(false) return end
				self:diffuse(ColorLightTone(PlayerColor(PLAYER_2)))
				local poptions = GAMESTATE:GetPlayerState(PLAYER_2):GetPlayerOptions('ModsLevel_Preferred')
				local bpm1, bpm2 = bpm1, bpm2
				if poptions:XMod() then
					bpm1 = bpm1 * poptions:XMod()
					bpm2 = bpm2 * poptions:XMod()
				elseif poptions:CMod() then
					bpm1 = poptions:CMod()
					bpm2 = poptions:CMod()
				elseif poptions:MMod() then
					bpm1 = (bpm1 * poptions:MMod()) / bpm2
					bpm2 = poptions:MMod()
				elseif poptions:AMod() then
					local baseAvg = (bpm1 + bpm2) * 0.5
					local mult = poptions:AMod() / baseAvg
					bpm1 = bpm1 * mult
					bpm2 = bpm2 * mult
				end
				local bpmtext = ''
				if bpm2 and bpm1 ~= bpm2 then
					bpmtext = math.floor(bpm1)..' - '..math.floor(bpm2)
				else
					bpmtext = math.floor(bpm1)
				end


				-- oh no the stepartist hid the display bpm D:
				if song:IsDisplayBpmRandom() then
					if poptions:XMod() then
						bpmtext = poptions:XMod()
					elseif poptions:CMod() then
						bpmtext = poptions:CMod()
					elseif poptions:MMod() then
						bpmtext = poptions:MMod()
					elseif poptions:AMod() then
						bpmtext = poptions:AMod()
					end
				end


				self:settext(bpmtext)
			end,
			SpeedChoiceChangedMessageCommand = function(self, param)
				if not selection then return end
				if param.pn ~= num_players[2] then return end
				local bpm1, bpm2 = bpm1, bpm2
				if param.mode == 'x' then
					bpm1 = bpm1 * (param.speed * 0.01)
					bpm2 = bpm2 * (param.speed * 0.01)
				elseif param.mode == 'c' then
					bpm1 = param.speed
					bpm2 = param.speed
				elseif param.mode == 'm' then
					bpm1 = (bpm1 * param.speed) / bpm2
					bpm2 = param.speed
				elseif param.mode == 'a' then
					local baseAvg = (bpm1 + bpm2) * 0.5
					local mult = param.speed / baseAvg
					bpm1 = bpm1 * mult
					bpm2 = bpm2 * mult
				end
				local bpmtext = ''
				if bpm2 and bpm1 ~= bpm2 then
					bpmtext = math.floor(bpm1)..' - '..math.floor(bpm2)
				else
					bpmtext = math.floor(bpm1)
				end


				-- oh no the stepartist hid the display bpm D:
				if song:IsDisplayBpmRandom() then
					if param.mode == 'x' then
						bpmtext = param.speed / 100
					else
						bpmtext = param.speed
					end
				end


				self:settext(bpmtext)
			end,
		},
	},
}

-- Load all noteskins for the previewer.
local icol = 2
if GAMESTATE:GetCurrentStyle():ColumnsPerPlayer() < 2 then
	icol = 1
end
local column = GAMESTATE:GetCurrentStyle():GetColumnInfo( GAMESTATE:GetMasterPlayerNumber(), icol )
if getenv("NewOptions") == "Main" or getenv("NewOptions") == nil then
	for _,v in pairs(NOTESKIN:GetNoteSkinNames()) do
		local noteskinset = NOTESKIN:LoadActorForNoteSkin( column["Name"] , "Tap Note", v )
		if noteskinset then
			t[#t+1] = noteskinset..{
				Name="NS"..string.lower(v), InitCommand=function(s) s:visible(false) end,
				OnCommand=function(s) s:diffusealpha(0):sleep(0.2):linear(0.2):diffusealpha(1) end,
				OffCommand=function(s) s:linear(0.2):diffusealpha(0) end
			}
		else
			lua.ReportScriptError(string.format("The noteskin %s failed to load.", v))
			t[#t+1] = Def.Actor{ Name="NS"..string.lower(v) }
		end
	end

	for i=1,#num_players do
		t[#t+1] = loadfile( THEME:GetPathG("","SpeedModUpdate") )( num_players[i] )
	end
end

local showmessage = true
t[#t+1] = Def.ActorFrame{
	Def.Quad {
		InitCommand=function(self)
			setenv("DifferentScreen",false)
			self:draworder(160):FullScreen():diffuse(color("0,0,0,1")):diffusealpha(0)
		end,
		-- Not implemented fully yet, just do this instead.
		ShowPressStartForOptionsCommand=function(self) self:decelerate(0.2):diffusealpha(0.3):sleep(1):decelerate(0.2):diffusealpha(0) end,
		ShowEnteringOptionsCommand=function(self) self:sleep(0.4):decelerate(0.3):diffusealpha(0) end;
		HidePressStartForOptionsCommand=function(self) self:sleep(0.4):decelerate(0.3):diffusealpha(0) end;
	},

	Def.ActorFrame {
		OnCommand=function(self)
			self:visible(false)
		end,
		AskForGoToOptionsCommand=function(self)
			if showmessage then
				setenv("NewOptions","Main")
				self:visible(true):diffusealpha(0):vertalign('bottom'):y(SCREEN_BOTTOM+120):decelerate(0.2):addy(-118):diffusealpha(1) 
				self:sleep(1):decelerate(0.2):addy(118):diffusealpha(0)
			end
		end,
		GoToOptionsCommand=function(s)
			if GAMESTATE:Env()["NewOptions"] == "Main" and showmessage and SCREENMAN:GetTopScreen():GetGoToOptions() then
				SCREENMAN:GetTopScreen():SetNextScreenName( "ScreenSongOptions" )
			end
		end,
		PlayerOptionNextScreenChangeMessageCommand=function(s,param)
			showmessage = param.choice == 1
			GAMESTATE:Env()["PlayerOptionsNextScreen"] = param.choice == 5 and SelectMusicOrCourse() or param.choicename
			SCREENMAN:GetTopScreen():SetNextScreenName( GAMESTATE:Env()["PlayerOptionsNextScreen"] )
		end,
		ShowEnteringOptionsCommand=function(self) self:sleep(0.4):decelerate(0.3):addy(120):diffusealpha(0) end;
		HidePressStartForOptionsCommand=function(self) self:sleep(0.4):decelerate(0.3):addy(120):diffusealpha(0) end;
		
		Def.Quad{
			InitCommand=function(self) self:vertalign('bottom'):zoomto(SCREEN_WIDTH,120):x(SCREEN_CENTER_X):diffuse(ColorTable.Primary):diffusealpha(0) end,
			AskForGoToOptionsCommand=function(self) self:diffusealpha(1) end,
		},
		StandardDecorationFromFileOptional("SongOptions","SongOptionsText") .. {
			AskForGoToOptionsCommand=THEME:GetMetric(Var "LoadingScreen","SongOptionsShowCommand"),
			GoToOptionsCommand=THEME:GetMetric(Var "LoadingScreen","SongOptionsEnterCommand"),
			HidePressStartForOptionsCommand=THEME:GetMetric(Var "LoadingScreen","SongOptionsHideCommand")
		}
	}
}

return t
