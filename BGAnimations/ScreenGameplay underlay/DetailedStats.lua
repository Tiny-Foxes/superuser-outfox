local ThemeColor = LoadModule('Theme.Colors.lua')
local player = ...
assert(player, "[DetailedStats] No player was found!")

local pNum = player == PLAYER_1 and 1 or 2
local pos = THEME:GetMetric("ScreenGameplay","PlayerP".. (player == PLAYER_1 and 2 or 1) .."MiscX")

-- Adjust position for game modes that aren't Dance as it gets more convoluted with a higher ammount of columns.
local columns = GAMESTATE:GetCurrentStyle():ColumnsPerPlayer()
if columns > 4 then
    pos = pos + (scale( columns, 5, 6, 30, 40 )*(pNum == 2 and -1 or 1))
end

local t = Def.ActorFrame{
    OnCommand=function(s)
        s:xy( pos, 24 ):diffusealpha(0):sleep(0.5):linear(0.5):diffusealpha(1)
    end,
    OffCommand=function(self)
        self:sleep(0.75):decelerate(0.3):addy(75):diffusealpha(0)
    end,
    ["CurrentSteps"..ToEnumShortString(player).."ChangedMessageCommand"]=function(self) self:playcommand("Set") end
}

-- These values represent the Height of the entire segment and the height of the ScatterPlot.
local maxwidth = 440
local maxheight = 60

local function upref(key,default)
	if LoadModule("Config.Exists.lua")(key,CheckIfUserOrMachineProfile(pNum-1).."/OutFoxPrefs.ini") then
		return LoadModule("Config.Load.lua")(key,CheckIfUserOrMachineProfile(pNum-1).."/OutFoxPrefs.ini")
	end 
	return default
end

-- These are user customizable options.
-- These options are the defaults, the cycle after this table handles the options.
local UserOptions = {
    judgmentscatter = upref("judgmentscatter",false),    -- Enables the judgment Scattergraph.
    npsscatter = upref("npsscatter",true),              -- Enables the NPS Graph.
    lifescatter = upref("lifescatter",true),            -- Enables the life Graph.
    progressquad = upref("progressquad",true),          -- Enables the Progress quad. This dims the song area that has already been cleared.
    labelnps = upref("labelnps",true),                  -- Enables the Max NPS label.
    scattery = upref("scattery",200),                   -- Scatterplot's global Y position.
    judgmenty = upref("judgmenty",-80),                 -- Global Y Position of judgment area.
    showmiscjud = upref("showmiscjud",true),            -- Show miscelanous judgments (Jumps, Mines, Holds, Rolls, Lifts)
}

-- Draw BG
local ColorTable = LoadModule("Theme.Colors.lua")
t[#t+1] = Def.Quad{
    OnCommand=function(s)
        s:stretchto( -(maxwidth/2),56,(maxwidth/2),SCREEN_HEIGHT )
        :diffuse( Alpha(ColorDarkTone( ThemeColor[ToEnumShortString(player)] ), 0.7) )
    end,
}

t[#t+1] = Def.ActorFrame {
        Def.ActorFrame {
            InitCommand=function(self) self:xy(-170,SCREEN_TOP+100) end,
            OffCommand=function(self) self:sleep(0.05):decelerate(0.3):diffusealpha(0) end,
            -- Quad
            Def.ActorFrame {
                ["CurrentSteps"..ToEnumShortString(player).."ChangedMessageCommand"]=function(self) self:playcommand("Set") end,
                    SetCommand=function(self)
                        local steps_data = GAMESTATE:GetCurrentSteps(player)
                        if GAMESTATE:GetCurrentSong() then
                            if steps_data == nil then return end
                            local st = steps_data:GetStepsType()
                            local diff = steps_data:GetDifficulty()
                            local cd = GetCustomDifficulty(st, diff)
                            self:diffuse(CustomDifficultyToColor(cd)):diffuserightedge(ColorLightTone(CustomDifficultyToColor(cd))):diffusealpha(0.8)
                        end
                    end,		
                Def.Quad {
                    InitCommand=function(self)
                        self:zoomto(62,56):diffuse(color("#8F8F8F")):diffusebottomedge(color("#E0E0E0"))
                    end,
                }
            },
            -- Number
            Def.BitmapText {
                Font="Common Large",
                InitCommand=function(self) self:zoom(0.8):maxwidth(40/0.8):y(-2) end,
                OnCommand=function(self)
                    self:playcommand("Set"):diffusealpha(0):sleep(0.2+0.3):linear(0.3):diffusealpha(1)
                end,
                SetCommand=function(self)
                    local steps_data = GAMESTATE:GetCurrentSteps(player)
                    if GAMESTATE:GetCurrentSong() then
                        if steps_data == nil then return end
                        self:settext(steps_data:GetMeter())
                    end
                end
            }
        }
}

t[#t+1] = Def.BitmapText{
    Font="Common Normal",
    OnCommand=function(s)
        s:xy( -130,85 )
        s:halign(0):maxwidth(340):playcommand("Set")
    end,
    OffCommand=function(self) self:sleep(0.1):decelerate(0.3):diffusealpha(0) end,
    SetCommand=function(s)
        local dialog = "N/A"
        if GAMESTATE:GetCurrentSteps(player) then
            local s = GAMESTATE:GetCurrentSteps(player)
            dialog = s:GetChartName() ~= "" and s:GetChartName() or (s:GetDescription() ~= "" and s:GetDescription() or dialog)
        end
        s:settext(dialog):diffusealpha( dialog ~= "N/A" and 1 or 0.6 )
    end,
}

t[#t+1] = Def.BitmapText{
    Font="Common Normal",
    OnCommand=function(s)
        s:xy( -130,115 ):visible(false)
        s:halign(0):maxwidth(340):playcommand("Set")
    end,
    OffCommand=function(self) self:sleep(0.1):decelerate(0.3):diffusealpha(0) end,
    SetCommand=function(s)
        if GAMESTATE:GetCurrentSteps(player) then
            local st = GAMESTATE:GetCurrentSteps(player)
            if st:GetAuthorCredit() ~= "" and not (st:GetAuthorCredit() == st:GetDescription() ) then
                s:visible(true)
                s:settext( st:GetAuthorCredit() )
            end
        end
    end,
}

local verts = {
    life = {},
    step = {},
    nps = {},
    label = {}
}

local SongTotal = 0
local SongMargin = { Start = 0, End = 0 }
local tnp, npst = 0,{}
local needsScatterPlotToMove = false
local calc = 0
local tempxpos = 0
t[#t+1] = Def.Quad{
    OnCommand=function(s)
        s:zoomto( maxwidth, maxheight*2 ):diffuse( color("#00000099") ):y( UserOptions.scattery )
    end,
    InitCommand=function(s)
        MESSAGEMAN:Broadcast("CurrentSongChanged")
    end,
    CurrentSongChangedMessageCommand=function()
        if GAMESTATE:GetCurrentSong() then
            if GAMESTATE:Env()["ChartData"..player] then
                local data = GAMESTATE:Env()["ChartData"..player]
                tnp, npst = data[1], data[2]
            end
            SongTotal = GAMESTATE:GetCurrentSong():GetLastSecond()
            SongMargin = {
                Start = math.min(GAMESTATE:GetCurrentSong():GetTimingData():GetElapsedTimeFromBeat(0), 0),
                End = GAMESTATE:GetCurrentSong():GetLastSecond(),
            }
            needsScatterPlotToMove = SongTotal >= 60*4
            calc = needsScatterPlotToMove and SongTotal*4 or maxwidth/2
            tempxpos = calc-220
        end
    end,
    OffCommand=function(self) self:sleep(0.15):decelerate(0.3):diffusealpha(0) end,
}

t[#t+1] = Def.Quad{
    BeginCommand=function(s)
        s:halign(0):xy( maxwidth/2, UserOptions.scattery ):MaskSource()
    end,
    CurrentSongChangedMessageCommand=function(s)
        if GAMESTATE:GetCurrentSong() then
            s:visible(needsScatterPlotToMove):zoomto( ((GAMESTATE:GetCurrentSong():MusicLengthSeconds()*4)*2), maxheight*2.2 )
        end
    end,
}
t[#t+1] = Def.Quad{
    BeginCommand=function(s)
        s:halign(1):xy( -maxwidth/2, UserOptions.scattery ):MaskSource()
    end,
    CurrentSongChangedMessageCommand=function(s)
        if GAMESTATE:GetCurrentSong() then
            s:visible(needsScatterPlotToMove):zoomto( ((GAMESTATE:GetCurrentSong():MusicLengthSeconds()*4)*2), maxheight*2.2 )
        end
    end,
}

local scrolled
local sizingspace = 30
local ScAFrm =Def.ActorFrame{
    CurrentSongChangedMessageCommand=function(s)
        if GAMESTATE:GetCurrentSong() then
            s:xy( tempxpos,UserOptions.scattery )
            if needsScatterPlotToMove then
                s:queuecommand("UpdatePos")
            end
        end
    end,
    OffCommand=function(self) self:sleep(0.15):decelerate(0.3):diffusealpha(0) end,
    UpdatePosCommand=function(s)
        if GAMESTATE:GetCurMusicSeconds() < SongTotal-30 then
            s:x( GAMESTATE:GetCurMusicSeconds() > 27 and scale( GAMESTATE:GetCurMusicSeconds(), 0, SongTotal-30, tempxpos+(maxwidth/2), -calc+220 ) or tempxpos )
            scrolled = scale( GAMESTATE:GetCurMusicSeconds(), 0, SongTotal-30, tempxpos+(maxwidth/2), -calc+220 )
        end
        s:sleep(1/60):queuecommand("UpdatePos")
    end
}

if UserOptions.npsscatter then
    ScAFrm[#ScAFrm+1] = Def.ActorMultiVertex{
        LastNPS=0,
        --[[
            This AMV is controlled by Quad Strip, which are objects formed by 2 vertices.
                1 - - 1 - - 2
                |   / |   / |
                | /   | /   |
                2 - - 2 - - 2
                When new vertices are added, they connect to the previous one, forming a wider quad.
        ]]
        Condition=UserOptions.npsscatter,
        InitCommand=function(s) s.LastNPS=1 end,
        OnCommand=function(s)
            s:MaskDest():SetDrawState{Mode="DrawMode_QuadStrip"}
        end,
        CurrentSongChangedMessageCommand=function(s)
            -- Grab every instance of the NPS data.
            s:finishtweening()
            verts.nps = {}
            if GAMESTATE:GetCurrentSong() then
                local SongMargin = {
                    Start = math.min(GAMESTATE:GetCurrentSong():GetTimingData():GetElapsedTimeFromBeat(0), 0),
                    End = GAMESTATE:GetCurrentSong():GetLastSecond(),
                }
                local SongTotal = GAMESTATE:GetCurrentSong():GetLastSecond()
                local needsScatterPlotToMove = SongTotal >= 60*4
                local calc = needsScatterPlotToMove and SongTotal*4 or maxwidth/2
                
                if npst then
					local step = GAMESTATE:GetCurrentSteps(player)
                    for k,v in pairs( npst ) do 
                            -- Each NPS area is per MEASURE. not beat. So multiply the area by 4 beats.
                            local t = step:GetTimingData():GetElapsedTimeFromBeat((k-1)*4)
                            -- With this conversion on t, we now apply it to the x coordinate.
                            local x = scale( t, math.min(step:GetTimingData():GetElapsedTimeFromBeat(0), 0), GAMESTATE:GetCurrentSong():GetLastSecond(),
								-calc, calc
							)
                            -- Now scale that position on v to the y coordinate.
                            local y = scale( v, 0, tnp, maxheight, -maxheight )
							if y < -maxheight then y = -maxheight end
                            -- And send them to the table to be rendered.
                            -- Also make sure they don't go out the boundry...
                            if x < calc then
                                verts.nps[#verts.nps+1] = {{x, maxheight, 0}, PlayerColor(player) }
                                verts.nps[#verts.nps+1] = {{x, y, 0}, ColorDarkTone(PlayerColor(player))}
                            end
                    end
                end
                s:SetNumVertices( #verts.nps ):SetVertices( verts.nps )
                if needsScatterPlotToMove then
                    s:SetDrawState{Mode="DrawMode_QuadStrip", First=1, Num=(4*sizingspace)}
                    :queuecommand("Update")
                else
                    verts.nps = {} -- To free some memory, let's empty the table.
                end
            end
        end,
        UpdateCommand=function(s)
            -- If the scatterplot needs to move, then we need to start a check to start filtering the offscreen area.
            local marginfade
            local time = GAMESTATE:GetCurMusicSeconds()
            -- Only update on after and before the scatter area has reached center.
            if (time > 30 and time < SongTotal-30) then
                for i=s.LastNPS,#verts.nps do
                    if math.mod( i, 2 ) == 0 then
                        -- Once we found that the vertice is outside of the visible area...
                        if (verts.nps[i][1][1]*-1) > (scrolled+(maxwidth/2)+20) then
                            -- Set that margin as our starting point for the renderer.
                            marginfade = i+1
                            s.LastNPS = i+1    -- This value will be used as the new starting point for the cycle.
                            -- And set it.
                            s:SetDrawState{Mode="DrawMode_QuadStrip", First=marginfade, Num=(marginfade*4) > #verts.nps and -1 or (4*sizingspace)}
                        end
                    end
                end
            end
            s:sleep(1/20):queuecommand("Update")
        end,
    }
end

if UserOptions.progressquad then
    ScAFrm[#ScAFrm+1] = Def.Quad{
        Condition=UserOptions.progressquad,
        OnCommand=function(s)
            s:zoomto( 0, maxheight*2 ):MaskDest():halign(0):diffuse( color("#00000099") )
        end,
        CurrentSongChangedMessageCommand=function(s)
            if GAMESTATE:GetCurrentSong() then
                s:x( -(needsScatterPlotToMove and SongTotal*4 or maxwidth/2) ):playcommand("Update")
            end
        end,
        UpdateCommand=function(s)
            local length = scale( GAMESTATE:GetCurMusicSeconds(), SongMargin.Start, SongMargin.End, 0, calc*2 )
            s:zoomtowidth( GAMESTATE:GetCurMusicSeconds() > 0 and (length > calc*2 and calc*2 or length) or 0)
            if needsScatterPlotToMove and GAMESTATE:GetCurMusicSeconds() < SongTotal-30 then
                s:cropleft( GAMESTATE:GetCurMusicSeconds() > 27 and scale( GAMESTATE:GetCurMusicSeconds(), 27, SongMargin.End, 0, 0.8 ) or 0 )
            end
            s:sleep(1/20):queuecommand("Update")
        end,
    }
end

-- Judgment Scatterplot
if UserOptions.judgmentscatter then
    ScAFrm[#ScAFrm+1] = Def.ActorMultiVertex{
        --[[
            This AMV is controlled by Quads, which are objects formed by 4 vertices.
                1 -- 2
                |  / |
                | /  |
                3 -- 4
        ]]
        Condition=UserOptions.judgmentscatter,
        InitCommand=function(s)
            s.lastmaxstep = 1
            s.LastNoteMargin = 1
        end,
        OnCommand=function(s) s:MaskDest():SetDrawState{Mode="DrawMode_Quads"} end,
        JudgmentMessageCommand=function(s,params)
            -- When we recieve a judgment, we must filter the player to avoid null data.
            if params.Player == player and params.Notes and tnp < 700 then
                -- Let´s check what column was just hit
                -- to prevent bugs, we remove instances of Pump's checkpoints.
                if params.TapNoteOffset and (params.TapNoteScore ~= "TapNoteScore_CheckpointHit" and params.TapNoteScore ~= "TapNoteScore_CheckpointMiss") then
                    -- Time will be our total offset for the current vertices
                    local time = GAMESTATE:GetCurMusicSeconds()
                    
                    -- We need to define the type of judgment that it is.
                    local noff = params.TapNoteScore == "TapNoteScore_Miss" and "Miss" or params.TapNoteOffset
                    
                    -- Now that we have time, we have to place it on the scatter.
                    -- The spacing is from the start to the end of the song's visible area, not the entire song.
                    -- This is to prevent offsync margins.
                    local x = scale( time, 0, SongMargin.End, -calc, calc )
                    
                    -- Now we differenciate each judgment by giving it color.
                    local val = "JudgmentLine_"..ToEnumShortString( params.TapNoteScore )
                    local ColorType = JudgmentLineToColor( val )
                    
                    -- Now create a Square, with the judgment color
                    if #verts.step > 2 then
                        s.LastNoteMargin = x-verts.step[#verts.step][1][1]
                    end
                    if s.LastNoteMargin < 0.25 then
                    else
                        if noff ~= "Miss" then
                            local y = scale( noff, 0.25, -0.25, maxheight, -maxheight )
                            table.insert( verts.step, {{x, y, 0}, ColorType } )
                            table.insert( verts.step, {{x+1.5, y, 0}, ColorType } )
                            table.insert( verts.step, {{x+1.5, y+1.5, 0}, ColorType } )
                            table.insert( verts.step, {{x, y+1.5, 0}, ColorType } )
                        else
                            -- If it was a miss, create a tall rectangle to indicate it.
                            table.insert( verts.step, {{x, -maxheight, 0}, color("#ff000077")} )
                            table.insert( verts.step, {{x+2, -maxheight, 0}, color("#ff000077")} )
                            table.insert( verts.step, {{x+2, maxheight, 0}, color("#ff000077")} )
                            table.insert( verts.step, {{x, maxheight, 0}, color("#ff000077")} )
                        end
                    end
                end
            end
            local curvert = #verts.step
            s:SetVertices( verts.step )
            if needsScatterPlotToMove then
                local marginfade
                local time = GAMESTATE:GetCurMusicSeconds()
                if (time > 30 and time < SongTotal-30) then
                    for i=s.lastmaxstep,#verts.step do
                        if math.mod( i, 4 ) == 0 then
                            if (verts.step[i][1][1]*-1) > (scrolled+(maxwidth/2)) then
                                marginfade = i+1
                                s.lastmaxstep = i+1
                            end
                        end
                    end
                    s:SetDrawState{Mode="DrawMode_Quads", First=marginfade, Num=-1}
                end
            end
        end,
        CurrentSongChangedMessageCommand=function(s)
            verts.step = {}
            s:SetNumVertices(0):SetVertices( verts.step )
        end
    }
end

if UserOptions.lifescatter then
    ScAFrm[#ScAFrm+1] = Def.ActorMultiVertex{
        Condition=UserOptions.lifescatter,
        InitCommand=function(s)
            s.lastmaxlife=1
            s.drawmaxlife=1
        end,
        OnCommand=function(s) s:MaskDest():SetDrawState{Mode="DrawMode_LineStrip"}:SetLineWidth( 3 ) end,
        RefreshLineCommand=function(s)
            for i=s.drawmaxlife,SongMargin.End+1 do
                if GAMESTATE:GetCurMusicSeconds() >= (i-1) then
                    if GAMESTATE:GetSongPosition():GetMusicSeconds() > SongMargin.End then return end

                    -- Calculate vertical position
                    if not verts.life[i-1] then
                        local lifey = SCREENMAN:GetTopScreen():GetLifeMeter(player):GetLife()
                        local pos = GAMESTATE:GetSongPosition():GetMusicSecondsVisible()
                        local stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(player)
			            local c = { [6] = stats:GetTapNoteScores("TapNoteScore_Miss"), [7] = stats:GetHoldNoteScores("HoldNoteScore_LetGo") }
			            for q=1,5 do c[q] = stats:GetTapNoteScores("TapNoteScore_W"..q) end
                        local sumofbad = c[4]+c[5]+c[6]+c[7]
                        local colors = {
                            {(c[1] >= 0 and c[2] == 0 and sumofbad < 1), Color.Blue},
                            {(c[2] > 0 and c[3] == 0 and sumofbad < 1), Color.Yellow},
                            {(c[3] ~= 0 and sumofbad < 1), Color.Green}
                        }
                        local setc = Color.White
                        for v in ivalues(colors) do
                            if v[1] then
                                setc = v[2]
                                break
                            end
                        end
                        local pos = {
                            x = scale( pos, SongMargin.Start, SongMargin.End, -calc, calc ),
                            y = scale( lifey, 0, 1, maxheight, -maxheight )
                        }
                        verts.life[i-1] = {{pos.x,pos.y,0},setc}
                        s:SetVertices( verts.life )
                        s.drawmaxlife = s.drawmaxlife + 1
                        break
                    end
                end
            end
            if needsScatterPlotToMove then
                local marginfade
                local time = GAMESTATE:GetCurMusicSeconds()
                if (time > 30 and time < SongTotal-30) then
                    for i=s.lastmaxlife,#verts.life do
                        if (verts.life[i][1][1]*-1) > (scrolled+(maxwidth/2)) then
                            marginfade = i+1
                            s.lastmaxlife = i+1
                        end
                    end
                    s:SetDrawState{Mode="DrawMode_LineStrip", First=marginfade, Num=-1}
                end
            end
            s:sleep(0.25):queuecommand("RefreshLine")
        end,
        CurrentSongChangedMessageCommand=function(s)
            verts.life = {}
            s.drawmaxlife = 1
            s:finishtweening():SetNumVertices(0):SetVertices( verts.life ):queuecommand("RefreshLine")
        end
    }
end

t[#t+1] = ScAFrm

t[#t+1] = Def.BitmapText{
    Condition=UserOptions.labelnps,
    Font="Common Normal",
    OnCommand=function(s)
        s:xy( (maxwidth/2)-4, UserOptions.scattery-46 ):halign(1):zoom(0.8):diffusealpha(0.6)
    end,
    CurrentSongChangedMessageCommand=function(s)
        if GAMESTATE:GetCurrentSong() then
            s:settext( string.format( THEME:GetString("ScreenGameplay","MaxNPS"), tnp ) )
        end
    end,
}

-- And a function to make even better use out of the table.
local function GetJLineValue(line, pl)
	local cases = {
		["Held"] = STATSMAN:GetCurStageStats():GetPlayerStageStats(pl):GetHoldNoteScores("HoldNoteScore_Held"),
		["MaxCombo"] = STATSMAN:GetCurStageStats():GetPlayerStageStats(pl):MaxCombo(),
	}
	return cases[line] and cases[line] or STATSMAN:GetCurStageStats():GetPlayerStageStats(pl):GetTapNoteScores("TapNoteScore_"..line)
end

local Name,Length = LoadModule("Options.SmartTapNoteScore.lua")()
local CurPrefTiming = LoadModule("Options.ReturnCurrentTiming.lua")().Name
local DLW = LoadModule("Config.Load.lua")("DisableLowerWindows","Save/OutFoxPrefs.ini") or false
table.sort(Name)
Name[#Name+1] = "Miss"
Name[#Name+1] = "MaxCombo"
Length = Length + 2
for i,v in ipairs( Name ) do
	local Con = Def.ActorFrame{
        OffCommand=function(self) self:sleep(0.05 * i):decelerate(0.2):diffusealpha(0) end,
		Def.BitmapText {
			Font = "Common Normal",
			Text=0,
			InitCommand=function(self)
				self:diffuse(ThemeColor[ToEnumShortString(player)]):diffusetopedge(ColorLightTone(ThemeColor[ToEnumShortString(player)]))
	        	self:xy(70,SCREEN_CENTER_Y+(UserOptions.judgmenty)+((44-(Length*2))*i)):halign(0):zoom(1.725-(Length*0.075)):halign(1)
			end,
			OnCommand=function(self)
				self:diffusealpha(0):sleep(0.1 * i):decelerate(0.6):diffusealpha(1)
				if DLW then
					for i=0,1 do
						if (v == 'W'..(5-i) and tonumber(DLW) >= (i+1)) then self:diffusealpha( 0.4 ) end
					end
				end
            end,
            JudgmentMessageCommand=function(s)
                s:finishtweening():sleep(0.001):queuecommand("UpdateInfo")
            end,
            UpdateInfoCommand=function(s)
                s:settext( GetJLineValue(v, player) )
            end,
		}
	}
	Con[#Con+1] = Def.BitmapText {
        Font = "Common Normal",
        Text=ToUpper(THEME:GetString( CurPrefTiming or "Original" , "Judgment"..v )),
        InitCommand=function(self)
            self:diffuse(BoostColor(ThemeColor[v],1.1))
            self:xy(-180,SCREEN_CENTER_Y+(UserOptions.judgmenty)+((44-(Length*2))*i)):zoom(1.725-(Length*0.075)):halign(0)
        end,
        OffCommand=function(self) self:sleep(0.05 * i):decelerate(0.2):diffusealpha(0) end,
        OnCommand=function(self)
            self:diffusealpha(0):sleep(0.1 * i):decelerate(0.6):diffusealpha(0.86)
            if DLW then
                for i=0,1 do
                    if (v == 'W'..(5-i) and tonumber(DLW) >= (i+1)) then self:diffusealpha( 0.4 ) end
                end
            end
        end
    }
	t[#t+1] = Con
end

-- Other stats (holds, mines, etc.)
local eval_radar = {
	{"Holds","TapNoteSubType_Hold"},
	{"Rolls","TapNoteSubType_Roll"},
	{"Hands","TapNoteScore_Hands"},
	{"Mines","TapNoteScore_AvoidMine"},
	{"Lifts","TapNoteScore_Lift"}
}

for i, rc_type in ipairs(eval_radar) do
    local JudgVar = 0
	local MaxVal = 0
	local spacing = 46*i
	t[#t+1] = Def.ActorFrame {
        Condition=UserOptions.showmiscjud,
        InitCommand=function(self)
            self:xy(100,(_screen.cy+UserOptions.judgmenty-20)+spacing)
        end,
		OnCommand=function(self)
            self:diffusealpha(0):sleep(0.1 * i):decelerate(0.5):diffusealpha(1):playcommand("UpdateMaxValue")
        end,
        CurrentSongChangedMessageCommand=function(s) s:playcommand("UpdateMaxValue") end,
        UpdateMaxValueCommand=function(s)
            if GAMESTATE:GetCurrentSong() and (GAMESTATE:GetCurrentTrail(player) or GAMESTATE:GetCurrentSteps(player)) then
                local SongOrCourse = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentTrail(player) or GAMESTATE:GetCurrentSteps(player)
                MaxVal = SongOrCourse:GetRadarValues(player):GetValue( "RadarCategory_"..rc_type[1] )
            end
        end,
        OffCommand=function(self) self:sleep(0.1 * i):decelerate(0.2):diffusealpha(0) end,
        
			-- Item name
			Def.BitmapText {
                Font = "Common Normal",
                Text = ToUpper(THEME:GetString("RadarCategory", rc_type[1])),
				InitCommand=function(self)
					self:zoom(0.6):halign(0):y(18):maxwidth(120)
				end,
			},
			-- Value
			Def.BitmapText {
			Font = "Common Normal",
			InitCommand=function(self)
				self:diffuse(ThemeColor[ToEnumShortString(player)]):diffusetopedge(ColorLightTone(ThemeColor[ToEnumShortString(player)]))
				self:zoom(0.7):diffusealpha(1.0):shadowlength(1):maxwidth(120):halign(0)
			end,
            UpdateMaxValueCommand=function(self)
                if GAMESTATE:GetCurrentSong() then
                    self:settext(JudgVar .. (GAMESTATE:IsCourseMode() and "" or ("/" .. MaxVal)))
                end
            end,
            JudgmentMessageCommand=function(self,params)
                if params.Player ~= player or MaxVal == 0 then return end
                if params.TapNote or params.TapNoteScore then
                    if rc_type[1] == "Hands" or rc_type[1] == "Lifts" then
                        if params.Notes and params.Holds then
                            local sum = 0
                            local liftsum = 0
                            for i=1,columns do
                                sum = sum + (params.Notes[i] and (params.Notes[i]:GetTapNoteType() ~= "TapNoteType_Mine" and 1) or 0)
                                sum = sum + (params.Holds[i] and 1 or 0)
                                liftsum = liftsum + (params.Notes[i] and (params.Notes[i]:GetTapNoteType() == "TapNoteType_Lift" and 1) or 0)
                            end
                            if params.TapNoteScore ~= "TapNoteScore_CheckpointHit" and params.TapNoteScore ~= "TapNoteScore_CheckpointMiss" then
                                JudgVar = JudgVar + (rc_type[1] == "Hands" and (params.TapNoteScore ~= "TapNoteScore_Miss" and (sum > 2 and 1 or 0) or 0) or liftsum)
                                self:settext( JudgVar .. (GAMESTATE:IsCourseMode() and "" or ("/" .. MaxVal)))
                            end
                        end
                    else
                        if i <= 2 and (params.TapNote and params.TapNote:GetTapNoteSubType() == rc_type[2]) or params.TapNoteScore == rc_type[2] then
                            JudgVar = JudgVar + (
                                (params.TapNoteScore ~= "TapNoteScore_Miss" and
                                params.HoldNoteScore ~= "HoldNoteScore_MissedHold" and
                                params.HoldNoteScore ~= "HoldNoteScore_LetGo"
                                ) and 1 or 0
                            )
                            self:settext( JudgVar .. (GAMESTATE:IsCourseMode() and "" or ("/" .. MaxVal)))
                        end
                    end
                end
            end
			}
	}
end

return t

--[[
    Copyright 2020 Jose_Varela, Team Rizu

    All newly-created code is licensed under Apache License 2.0 (the License),
    and all graphics are dual-licensed under Creative Commons Attribution
    Share-Alike 4.0 (attributed to Team Rizu) and Apache License 2.0.

    You may not use these files except in compliance with the License.

    Unless required by applicable law or agreed to in writing, software
    distributed under the License is distributed on an "AS IS" BASIS,
    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

    See the License for the specific language governing permissions and
    limitations under the License.
]]
