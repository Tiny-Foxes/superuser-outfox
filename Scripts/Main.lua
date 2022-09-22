LoadModule('Konko.Core.lua')

function OptionNameString(str)
	return THEME:GetString('OptionNames',str)
end

LoadModule("Row.Prefs.lua")(LoadModule("Options.Prefs.lua"))

Branch.GameplayScreen = function()
	return "ScreenGameplay"
end

Branch.AfterTitleMenu = function()
	return Branch.StartGame()
end

Branch.AfterSelectMusic = function()
	if SCREENMAN:GetTopScreen():GetGoToOptions() then
		return SelectFirstOptionsScreen()
	else
		return Branch.GameplayScreen()
	end
end

Branch.PlayerOptions = function()
	local pm = GAMESTATE:GetPlayMode()
	local restricted = { PlayMode_Oni= true, PlayMode_Rave= true,
		--"PlayMode_Battle" -- ??
	}
	local optionsScreen = "ScreenPlayerOptions"
	if restricted[pm] then
		optionsScreen = "ScreenPlayerOptionsRestricted"
	end
	if SCREENMAN:GetTopScreen():GetGoToOptions() then
		return optionsScreen
	else
		return Branch.GameplayScreen()
	end
end
Branch.SongOptions = function()
	if SCREENMAN:GetTopScreen():GetGoToOptions() then
		return "ScreenSongOptions"
	else
		return Branch.GameplayScreen()
	end
end

Branch.AfterSelectProfile = function()
	if getenv("StartFitness") == true then
		return "ScreenFitnessOptions"
	end
	if ( THEME:GetMetric("Common","AutoSetStyle") == true ) then
		-- use SelectStyle in online...
		return IsNetConnected() and "ScreenSelectStyle" or "ScreenSelectPlayMode"
	else
		return "ScreenSelectStyle"
	end
end

function check_stop_course_early()
	return course_stopped_by_pause_menu
end

function IsWidescreen()
	return SCREEN_WIDTH > 1150
end

function SPOChoices( itemSet )
	local TimingMode = GAMESTATE:GetCurrentGame():GetName() ~= "para" and "Timing," or ""
	local GHMode = GAMESTATE:GetCurrentGame():GetName() == "gh" and "GH," or ""
	local Items = {
		["Main"] = "SPM,SPV,NS,14,Mini,SF,FilterColor,".. TimingMode .."Judg,13,LuaRate,LuaHaste,LuaSoundEffect,18",
		--["Main"] = "1,NS,14,Mini,SF,FilterColor,".. TimingMode .."Judg,13,LuaRate,LuaHaste,LuaSoundEffect,18",
		["Special"] = "RotateFieldX,RotateFieldZ,MC,MCD,MCB,DLW,JudgImg,Combo,Toasty,ToastDraw,SP,OVG,OB,12",
		["Effects"] = "2,3A,3B,4,5,6,7,9,R1,"..GHMode.."10,11"
	}
	
	if GAMESTATE:IsHumanPlayer(PLAYER_1) then
		Items["Main"] = Items["Main"] .. ",P1_16"
	end
	
	if GAMESTATE:IsHumanPlayer(PLAYER_2) then
		Items["Main"] = Items["Main"] .. ",P2_16"
	end

	if LoadModule("Characters.AnyoneHasChar.lua")() then
		Items["Main"] = Items["Main"] .. ",St"
	end

	return Items[itemSet] .. ",PNScr"
end

function PlayerOptionsDefineNextScreen()
	if GAMESTATE:Env()["PlayerOptionsNextScreen"] then
		print('PlayerOptions | '..tostring(GAMESTATE:Env()["PlayerOptionsNextScreen"]))
		return GAMESTATE:Env()["PlayerOptionsNextScreen"]
	end
	return Branch.SongOptions()
end

function ExtraColorPreference()
	local Modes = {
		dance = 10,
		pump = 21,
		beat = 12,
		kb7 = 10,
		para = 10,
		techno = 10,
		lights = 10, -- lights shouldn't be playable
		kickbox= 100, -- extra color is lame
	}
	local ret = {
		["old"] = 10,
		["X"] = 15,
		["pump"] = 21,
	}
	if ret[LoadModule("Config.Load.lua")("PreferredMeter","Save/OutFoxPrefs.ini")] == "old" then 
		return Modes[CurGameName()] or 10
	else
		return ret[LoadModule("Config.Load.lua")("PreferredMeter","Save/OutFoxPrefs.ini")]
	end
end

function ArtistSetConversion(self)
	local Title=self:GetChild("Title");
	local Subtitle=self:GetChild("Subtitle");
	local Artist=self:GetChild("Artist");
	if Subtitle:GetText() == "" then
		Title:zoom(1.25):maxwidth(260):xy(-190,-6)
		Subtitle:visible(false)
		Artist:visible(false)
	else
		Title:zoom(1.25):maxwidth(260):xy(-190,-16)
		Subtitle:visible(true):zoom(0.8):maxwidth(516*0.8):xy(-190,14-3)
		Artist:visible(false)
	end
end

-- It's the same as the function above, but for courses.
function CourseSetConversion(self)
	local Title=self:GetChild("Title");
	local Subtitle=self:GetChild("Subtitle");
	local Artist=self:GetChild("Artist");
	if Subtitle:GetText() == "" then
		Title:zoom(1):maxwidth(SCREEN_WIDTH*0.5625):xy(-280,0)
		Subtitle:visible(false)
		Artist:visible(false)
	else
		Title:zoom(1):maxwidth(SCREEN_WIDTH*0.5625):xy(-280,-12)
		Subtitle:visible(true):zoom(0.75):maxwidth(SCREEN_WIDTH*0.8203125):xy(-280,14)
		Artist:visible(false)
	end
end
