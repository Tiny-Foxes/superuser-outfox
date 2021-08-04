-- Orignal code by Team OutFox, used in Soundwaves theme
local t = Def.ActorFrame {}
local p = ...
local fade_out_speed = 0.2
local fade_out_pause = 0.1
local off_wait = 0.75
local CurPrefTiming = LoadModule("Options.ReturnCurrentTiming.lua")().Name
local SelJudg = {2,4,5}

local eval_radar = {
	Types = { 'Holds', 'Rolls', 'Hands', 'Mines', 'Lifts' },
}

-- And a function to make even better use out of the table.
local function GetJLineValue(line, pl)
	if line == "Held" then
		return STATSMAN:GetCurStageStats():GetPlayerStageStats(pl):GetHoldNoteScores("HoldNoteScore_Held")
	elseif line == "MaxCombo" then
		return STATSMAN:GetCurStageStats():GetPlayerStageStats(pl):MaxCombo()
	else
		return STATSMAN:GetCurStageStats():GetPlayerStageStats(pl):GetTapNoteScores("TapNoteScore_" .. line)
	end
	return "???"
end

-- You know what, we'll deal with getting the overall scores with a function too.
local function GetPlScore(pl, scoretype)
	local primary_score = STATSMAN:GetCurStageStats():GetPlayerStageStats(pl):GetScore()
	local secondary_score = FormatPercentScore(STATSMAN:GetCurStageStats():GetPlayerStageStats(pl):GetPercentDancePoints())

	if PREFSMAN:GetPreference("PercentageScoring") then
		primary_score, secondary_score = secondary_score, primary_score
	end

	if scoretype == "primary" then
		return primary_score
	else
		return secondary_score
	end
end

local eval_part_offs = 0
local score_parts_offs = string.find(p, "P1") and -100 or 100

-- Step counts.
t[#t+1] = Def.BitmapText {
    Font = "Common Normal",
    InitCommand=function(self)
        self:skewx(0.25):zoom(1):y(-80):maxwidth(260):horizalign(center)
        self:diffuse(color('#FFFF80')):diffusebottomedge(color('#FF8000')):diffusealpha(0)
    end;
	OnCommand=function(self)
		self:sleep(0.6):queuecommand('Bob'):diffusealpha(1)
	end,
    OffCommand=function(self)
        self:linear(0.2):diffusealpha(0)
    end;
	BobCommand=function(self)
		self:bob():effectperiod(8):effectmagnitude(4, 0, 0)
	end;
    Text=THEME:GetString("ScreenEvaluation","Statistics");
};


local Name,Length = LoadModule("Options.SmartTapNoteScore.lua")()
local DLW = LoadModule("Config.Load.lua")("DisableLowerWindows","Save/OutFoxPrefs.ini") or false
table.sort(Name)
Name[#Name+1] = "Miss"
Length = Length + 1
local DoubleSet = Length*2
Name[#Name+1] = "MaxCombo"
Length = Length + 1

for i,v in ipairs( Name ) do
	local Con = Def.ActorFrame{
		OffCommand=function(self)
			self:sleep(fade_out_pause):decelerate(fade_out_speed):diffusealpha(0)
		end,
		Def.BitmapText {
			Font = "Common Normal",
			Text=GetJLineValue(v, p),
			InitCommand=function(self)
				self:skewx(0.25):diffuse(ColorLightTone(PlayerColor(p)))
	        	self:xy(eval_part_offs+70,-80+((44-(Length*2))*i)):halign(0):zoom(1.475-(Length*0.075)):halign(1)
			end,
			OnCommand=function(self)
				self:diffusealpha(0):sleep(0.6 + 0.01 * i):queuecommand('Bob'):decelerate(0.6):diffusealpha(1)
				if DLW then
					for i=0,1 do
						if (v == 'W'..(5-i) and tonumber(DLW) >= (i+1)) then self:diffusealpha( 0.4 ) end
					end
				end
			end,
			BobCommand=function(self)
				self:bob():effectperiod(8):effectmagnitude(4, 0, 0)
			end,
		}
	}
	Con[#Con+1] = Def.BitmapText {
		Font = "Common Normal",
		Text=ToUpper(THEME:GetString( CurPrefTiming or "Original" , "Judgment"..v )),
		InitCommand=function(self)
			self:skewx(0.25):diffuse(BoostColor((JudgmentLineToColor("JudgmentLine_" .. v)),1.3))
			self:xy((eval_part_offs-150),-80+((44-(Length*2))*i)):zoom(1.475-(Length*0.075)):halign(0)
		end,
		OnCommand=function(self)
			self:diffusealpha(0):sleep(0.6 + 0.01 * i):queuecommand('Bob'):decelerate(0.6):diffusealpha(0.86)
			if DLW then
				for i=0,1 do
					if (v == 'W'..(5-i) and tonumber(DLW) >= (i+1)) then self:diffusealpha( 0.4 ) end
				end
			end
		end,
		BobCommand=function(self)
			self:bob():effectperiod(8):effectmagnitude(4, 0, 0)
		end,
	}
	t[#t+1] = Con
end	
-- Other stats (holds, mines, etc.)
for i, rc_type in ipairs(eval_radar.Types) do
	local performance = STATSMAN:GetCurStageStats():GetPlayerStageStats(p):GetRadarActual():GetValue( "RadarCategory_"..rc_type )
	local possible = STATSMAN:GetCurStageStats():GetPlayerStageStats(p):GetRadarPossible():GetValue( "RadarCategory_"..rc_type )
	local label = THEME:GetString("RadarCategory", rc_type)
	local spacing = 46*i
	t[#t+1] = Def.ActorFrame {
		InitCommand=function(self) 	self:x(eval_part_offs+90):y((-103)+(spacing)) end;
		OnCommand=function(self)
			self:diffusealpha(0):sleep(0.6 + 0.01 * i):queuecommand('Bob'):decelerate(0.5):diffusealpha(1)
		end;
		OffCommand=function(self)
			self:sleep(fade_out_pause):decelerate(fade_out_speed):diffusealpha(0)
		end;
		BobCommand=function(self)
			self:bob():effectperiod(8):effectmagnitude(4, 0, 0)
		end;
			-- Item name
			Def.BitmapText {
				Font = "Common Normal",
				Text = ToUpper(label),
				InitCommand=function(self)
					self:skewx(0.25):zoom(0.7):horizalign(left):diffuse(color("#FFFFFF")):y(20):maxwidth(80)
				end;
			};
			-- Value
			Def.BitmapText {
			Font = "Common Normal",
			InitCommand=function(self)
				self:skewx(0.25):diffuse(ColorLightTone(PlayerColor(p)))
				self:zoom(0.8):diffusealpha(1.0):shadowlength(1):maxwidth(80):horizalign(left)
			end;
			BeginCommand=function(self)
				self:settext(performance .. "/" .. possible)
			end
			};
	};
end;

return t;
