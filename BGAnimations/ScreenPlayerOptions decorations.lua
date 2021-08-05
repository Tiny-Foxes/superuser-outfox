local num_players = GAMESTATE:GetHumanPlayers()
local ColorTable = LoadModule("Theme.Colors.lua")

local t = LoadFallbackB()

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
		-- ShowEnteringOptionsCommand=function(self) self:sleep(0.4):decelerate(0.3):diffusealpha(0) end;
		-- HidePressStartForOptionsCommand=function(self) self:sleep(0.4):decelerate(0.3):diffusealpha(0) end;
	},

	Def.ActorFrame {
		OnCommand=function(self)
			self:visible(false)
		end,
		AskForGoToOptionsCommand=function(self)
			if showmessage then
				setenv("NewOptions","Main")
				self:visible(true):diffusealpha(0):vertalign(bottom):y(SCREEN_BOTTOM+120):decelerate(0.2):addy(-118):diffusealpha(1) 
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
		-- ShowEnteringOptionsCommand=function(self) self:sleep(0.4):decelerate(0.3):addy(120):diffusealpha(0) end;
		-- HidePressStartForOptionsCommand=function(self) self:sleep(0.4):decelerate(0.3):addy(120):diffusealpha(0) end;
		
		Def.Quad{
			InitCommand=function(self) self:vertalign(bottom):zoomto(SCREEN_WIDTH,120):x(SCREEN_CENTER_X):diffuse(ColorTable.Primary):diffusealpha(0) end,
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
