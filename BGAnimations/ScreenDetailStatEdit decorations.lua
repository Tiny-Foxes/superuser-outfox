local t = LoadFallbackB()

local profileid = GAMESTATE:GetEditLocalProfileID()

local player = GAMESTATE:GetMasterPlayerNumber()
assert(player, "[DetailedStats] No player was found!")

local pNum = tonumber(string.sub(ToEnumShortString(player),-1))

local pos = THEME:GetMetric("ScreenGameplay","PlayerP2MiscX")

local sp = Def.ActorFrame{
    OnCommand=function(s)
        s:xy( pos+ scale( SCREEN_WIDTH, 960,1280, 30, 0 ) , 0 )
        s:diffusealpha(0):linear(0.5):diffusealpha(1)
    end,
    OffCommand=function(s)
        s:linear(0.3):diffusealpha(0)
    end,
}

local profile_location = "Save/LocalProfiles/".. GAMESTATE:GetEditLocalProfileID() .."/OutFoxPrefs.ini"
-- These values represent the Height of the entire segment and the height of the ScatterPlot.
local maxwidth = 440
local maxheight = 60

local function upref(key,default)
	if LoadModule("Config.Exists.lua")(key,profile_location) then
		return LoadModule("Config.Load.lua")(key,profile_location)
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
sp[#sp+1] = Def.Quad{
    OnCommand=function(s)
        s:stretchto( -(maxwidth/2),56,(maxwidth/2),SCREEN_HEIGHT )
        :diffuse( ColorDarkTone( PlayerColor(player) ) )
    end,
}

sp[#sp+1] = Def.ActorFrame {
        Def.ActorFrame {
            InitCommand=function(self)
                self:horizalign(center):xy(-170,SCREEN_TOP+100)
            end;
            -- Quad
            Def.ActorFrame {
                ["CurrentSteps"..ToEnumShortString(player).."ChangedMessageCommand"]=function(self) self:playcommand("Set") end;
                    SetCommand=function(self)
                            local steps_data = GAMESTATE:GetCurrentSteps(player)
                            local song = randsong;
                                if song then
                                    if steps_data ~= nil then
                                    local st = steps_data:GetStepsType();
                                    local diff = steps_data:GetDifficulty();
                                    local cd = GetCustomDifficulty(st, diff);
                                    self:diffuse(CustomDifficultyToColor(cd)):diffuserightedge(ColorLightTone(CustomDifficultyToColor(cd))):diffusealpha(0.8);
                                end
                            end
                    end;			
                Def.Quad {
                    InitCommand=function(self)
                        self:horizalign(center):zoomto(62,56):diffuse(color("#8F8F8F")):diffusebottomedge(color("#E0E0E0"))
                    end;
                };
            };
            -- Number
            Def.BitmapText {
                Font="_Plex Numbers 40px";
                InitCommand=function(self)
                    self:zoom(0.8):horizalign(center):maxwidth(40/0.8):y(-2)
                    end;
                OnCommand=function(self)
                    self:playcommand("Set"):diffusealpha(0):sleep(0.2+0.3):linear(0.3):diffusealpha(1)
                end;
                SetCommand=function(self)
                        local steps_data = GAMESTATE:GetCurrentSteps(player)
                        local song = randsong;
                            if song then
                                if steps_data ~= nil then
                                local st = steps_data:GetStepsType();
                                local diff = steps_data:GetDifficulty();
                                local cd = GetCustomDifficulty(st, diff);
                                self:settext(steps_data:GetMeter())
                                self:diffuse(Color.White);
                            end
                        end
                end;
            };
        };
};

sp[#sp+1] = Def.BitmapText{
    Font="_Condensed Medium",
    OnCommand=function(s)
        s:xy( -130,85 )
        s:halign(0):playcommand("Set")
    end,
    SetCommand=function(s)
        local dialog = "N/A"
        if GAMESTATE:GetCurrentSteps(player) then
            local s = GAMESTATE:GetCurrentSteps(player)
            dialog = s:GetChartName() ~= "" and s:GetChartName() or (s:GetDescription() ~= "" and s:GetDescription() or dialog)
        end
        s:settext(dialog):diffusealpha( dialog ~= "N/A" and 1 or 0.6 )
    end,
}

sp[#sp+1] = Def.BitmapText{
    Font="_Condensed Medium",
    OnCommand=function(s)
        s:xy( -130,115 ):visible(false)
        s:halign(0):playcommand("Set")
    end,
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

sp[#sp+1] = Def.Quad{
    OnCommand=function(s)
        s:zoomto( maxwidth, maxheight*2 ):diffuse( color("#00000099") ):y( UserOptions.scattery )
    end,
    scatteryChangeMessageCommand=function(s,param)
        s:y( param.choicename )
    end,
}
-- Each segment will be a 15 second chunk.
local randsong = SONGMAN:GetRandomSong()

local segments = math.floor( randsong:MusicLengthSeconds() )
local SongTotal = randsong:MusicLengthSeconds()
local SongMargin = {
    Start = math.min(randsong:GetTimingData():GetElapsedTimeFromBeat(0), 0),
    End = randsong:GetLastSecond(),
}
local LastBeat = randsong:GetLastBeat()

local tnp, npst = LoadModule("Chart.GetNPS.lua")( GAMESTATE:GetCurrentSteps(player) )
local measurestotal = math.floor(GAMESTATE:GetSongPosition():GetSongBeatVisible())/4
local maxnps = 0
if npst then
    for k,v in pairs( npst ) do
        maxnps = v > maxnps and v or maxnps
    end
else
    for i=1,90 do
        npst[i] = {k, math.random( 5,20 )}
    end
end
local currentlabel = 1
local labels = {}
for k,v in pairs( GAMESTATE:GetCurrentSteps(player):GetTimingData():GetLabels() ) do
    for time, name in string.gmatch(v, "(.-)=(.+)") do
        labels[#labels+1] = {tonumber(time), name}
    end 
end
if #labels > 1 then
    for k,v in pairs(labels) do
        if labels[k+1] then
            local tims = labels[k+1][1] - labels[k][1]
            labels[k] = {v[1], v[2], tims}
        else
            labels[k] = {v[1], v[2], 0 }
        end
    end
end

local needsScatterPlotToMove = SongTotal >= 60*4
local calc = needsScatterPlotToMove and SongTotal*4 or maxwidth/2
local SctMargin = {
    Left = -(calc),
    Right = (calc)
}

sp[#sp+1] = Def.Quad{
    Condition=needsScatterPlotToMove,
    OnCommand=function(s)
        s:zoomto( ((SongTotal*4)*2), maxheight*2.2 ):halign(0):xy( maxwidth/2, UserOptions.scattery ):MaskSource()
    end,
    scatteryChangeMessageCommand=function(s,param)
        s:y( param.choicename )
    end,
}
sp[#sp+1] = Def.Quad{
    Condition=needsScatterPlotToMove,
    OnCommand=function(s)
        s:zoomto( 100, maxheight*2.2 ):halign(1):xy( -maxwidth/2, UserOptions.scattery ):MaskSource()
    end,
    scatteryChangeMessageCommand=function(s,param)
        s:y( param.choicename )
    end,
}

local tempxpos = SctMargin.Right-220
local scrolled
local lastmaxnps = 1
local lastmaxstep = 1
local lastmaxlife = 1
local sizingspace = 30
sp[#sp+1] = Def.ActorFrame{
    OnCommand=function(s)
        s:xy( tempxpos,UserOptions.scattery )
    end,
    scatteryChangeMessageCommand=function(s,param)
        s:y( param.choicename )
    end,
    Def.ActorMultiVertex{
        Condition=#labels > 1,
        OnCommand=function(s) s:MaskDest():SetDrawState{Mode="DrawMode_Quads"}
            for k,v in pairs( labels ) do
                    local anem = color( tostring((math.random(255)/255)..","..(math.random(255)/255)..","..(math.random(255)/255)..",0.6") ) 
                    local start = scale( v[1], 0, LastBeat, SctMargin.Left, SctMargin.Right )
                    local ending = scale( v[1]+(v[3] == 0 and (LastBeat-v[1]) or v[3]), 0, LastBeat, SctMargin.Left, SctMargin.Right )
                    verts.label[#verts.label+1] = { { start, -maxheight, 0 } , anem }
                    verts.label[#verts.label+1] = { { ending, -maxheight, 0 } , anem }
                    verts.label[#verts.label+1] = { { ending, maxheight, 0 } , anem }
                    verts.label[#verts.label+1] = { { start, maxheight, 0 } , anem }
            end
            s:SetVertices( verts.label )
        end,
    },

    Def.ActorMultiVertex{
        --[[
            This AMV is controlled by Quad Strip, which are objects formed by 2 vertices.
                1 - - 1 - - 2
                |   / |   / |
                | /   | /   |
                2 - - 2 - - 2
                When new vertices are added, they connect to the previous one, forming a wider quad.
        ]]
        OnCommand=function(s) s:MaskDest():SetDrawState{Mode="DrawMode_QuadStrip"}
            s:visible( UserOptions.npsscatter )
            -- Grab every instance of the NPS data.
            for k,v in pairs( npst ) do
                -- If the data is 0 NPS, then there's no need to draw it at all. Skip it.
                if v > 0 then
                    -- Each NPS area is per MEASURE. not beat. So multiply the area by 4 beats.
                    local t = randsong:GetTimingData():GetElapsedTimeFromBeat((k-1)*4)
                    -- With this conversion on t, we now apply it to the x coordinate.
                    local x = scale( t, SongMargin.Start, SongMargin.End, SctMargin.Left, SctMargin.Right )
                    -- Now scale that position on v to the y coordinate.
                    local y = scale( v, 0, tnp, maxheight, -maxheight )
                    -- And send them to the table to be rendered.
                    if x < SctMargin.Right then
                        verts.nps[#verts.nps+1] = {{x, maxheight, 0}, PlayerColor(player) }
                        verts.nps[#verts.nps+1] = {{x, y, 0}, ColorDarkTone(PlayerColor(player))}
                    end
                end
            end
            s:SetVertices( verts.nps ):queuecommand("Update")
        end,
        maxscatternpsChangeMessageCommand=function(s,param)
            -- Grab every instance of the NPS data.
            local newmax = param.choicename
            verts.nps = {}
            for k,v in pairs( npst ) do
                -- If the data is 0 NPS, then there's no need to draw it at all. Skip it.
                if v > 0 then
                    -- Each NPS area is per MEASURE. not beat. So multiply the area by 4 beats.
                    local t = randsong:GetTimingData():GetElapsedTimeFromBeat((k-1)*4)
                    -- With this conversion on t, we now apply it to the x coordinate.
                    local x = scale( t, SongMargin.Start, SongMargin.End, SctMargin.Left, SctMargin.Right )
                    -- The maximum NPS allowed by the scattergraph is set on UserOptions.nps. so if anything is higher than this,
                    -- set it back to UserOptions.nps.
                    v = v > newmax and newmax or v
                    -- Now scale that position on v to the y coordinate.
                    local y = scale( v, 0, newmax, maxheight, -maxheight )
                    -- And send them to the table to be rendered.
                    verts.nps[#verts.nps+1] = {{x, maxheight, 0}, PlayerColor(player) }
                    verts.nps[#verts.nps+1] = {{x, y, 0}, ColorDarkTone(PlayerColor(player))}
                end
            end
            s:SetVertices( verts.nps ):queuecommand("Update")
        end,
        npsscatterChangeMessageCommand=function(s,param)
            s:visible( param.choicename )
        end,
    },

    Def.Quad{
        OnCommand=function(s)
            s:visible( UserOptions.progressquad )
            s:zoomto(maxwidth/2 , maxheight*2 ):MaskDest():halign(0):diffuse( color("#00000099") ):x( SctMargin.Left )
        end,
        progressquadChangeMessageCommand=function(s,param)
            s:visible( param.choicename )
        end,
    },

    -- Judgment Scatterplot
    Def.ActorMultiVertex{
        --[[
            This AMV is controlled by Quads, which are objects formed by 4 vertices.
                1 -- 2
                |  / |
                | /  |
                3 -- 4
        ]]
        OnCommand=function(s)
            for i=1,60 do
                local col = JudgmentLineToColor("JudgmentLine_W"..math.random(1,5))
                local x = scale( i, 0, 60, SctMargin.Left, SctMargin.Right/2 )
                local y = scale( math.random(60), -30, 90, maxheight, -maxheight )
                table.insert( verts.step, {{x, y, 0}, col } )
                table.insert( verts.step, {{x+1.5, y, 0}, col } )
                table.insert( verts.step, {{x+1.5, y+1.5, 0}, col } )
                table.insert( verts.step, {{x, y+1.5, 0}, col } )
            end
            s:SetVertices(verts.step)
            s:MaskDest():SetDrawState{Mode="DrawMode_Quads"}
            s:visible( UserOptions.judgmentscatter )
        end,
        judgmentscatterChangeMessageCommand=function(s,param)
            s:visible( param.choicename )
        end,
    },

    Def.ActorMultiVertex{
        OnCommand=function(s)
            s:visible( UserOptions.lifescatter )
            for i=1,20 do
                verts.life[i] = {
                    {
                        scale( i, 1, 20, SctMargin.Left, SctMargin.Right ),
                        scale( math.random(60), 0, 60, maxheight, -maxheight ),
                        0
                    },
                    Color.White
                }
            end
            s:SetVertices( verts.life )
            s:MaskDest():SetDrawState{Mode="DrawMode_LineStrip"}:SetLineWidth( 2 )
        end,
        lifescatterChangeMessageCommand=function(s,param)
            s:visible( param.choicename )
        end,
    }
}

sp[#sp+1] = Def.BitmapText{
    Font="_Condensed Medium",
    OnCommand=function(s)
        s:visible( UserOptions.labelnps )
        s:settext( string.format( THEME:GetString("ScreenGameplay","MaxNPS"), maxnps )  )
        :xy( (maxwidth/2)-4, UserOptions.scattery-42 ):halign(1):zoom(0.8):diffusealpha(0.6)
    end,
    labelnpsChangeMessageCommand=function(s,param)
        s:visible( param.choicename )
    end,
    scatteryChangeMessageCommand=function(s,param)
        s:y( param.choicename-46 )
    end,
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

local CurPrefTiming = LoadModule("Options.ReturnCurrentTiming.lua")().Name
local Name,Length = LoadModule("Options.SmartTapNoteScore.lua")()
local DLW = LoadModule("Config.Load.lua")("DisableLowerWindows","Save/OutFoxPrefs.ini") or false
table.sort(Name)
Name[#Name+1] = "Miss"
Name[#Name+1] = "MaxCombo"
Length = Length + 2
for i,v in ipairs( Name ) do
	local Con = Def.ActorFrame{
		Def.BitmapText {
			Font = "_Bold",
			Text=math.random( 300 ),
			InitCommand=function(self)
				self:diffuse(ColorLightTone(PlayerColor(player))):diffusetopedge(ColorLightTone(PlayerCompColor(player)))
	        	self:xy(70,SCREEN_CENTER_Y+(UserOptions.judgmenty)+((44-(Length*2))*i)):halign(0):zoom(1.475-(Length*0.075)):halign(1)
            end,
            judgmentyChangeMessageCommand=function(s,param)
                s:y( (_screen.cy+param.choicename)+((44-(Length*2))*i))
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
                s:finishtweening():sleep(0.01):queuecommand("UpdateInfo")
            end,
            UpdateInfoCommand=function(s)
                s:settext( GetJLineValue(v, player) )
            end,
		}
	}
	Con[#Con+1] = Def.BitmapText {
        Font = "_Bold",
        Text=ToUpper(THEME:GetString( CurPrefTiming or "Original" , "Judgment"..v )),
        InitCommand=function(self)
            self:diffuse(BoostColor((JudgmentLineToColor("JudgmentLine_" .. v)),1.3))
            self:xy(-180,SCREEN_CENTER_Y+(UserOptions.judgmenty)+((44-(Length*2))*i)):zoom(1.475-(Length*0.075)):halign(0)
        end,
        judgmentyChangeMessageCommand=function(s,param)
            s:y( (_screen.cy+param.choicename)+((44-(Length*2))*i))
        end,
        OnCommand=function(self)
            self:diffusealpha(0):sleep(0.1 * i):decelerate(0.6):diffusealpha(0.86)
            if DLW then
                for i=0,1 do
                    if (v == 'W'..(5-i) and tonumber(DLW) >= (i+1)) then self:diffusealpha( 0.4 ) end
                end
            end
        end
    }
	sp[#sp+1] = Con
end

-- Other stats (holds, mines, etc.)
local columns = GAMESTATE:GetCurrentStyle():ColumnsPerPlayer()
local eval_radar = {
	{"Holds","TapNoteSubType_Hold"},
	{"Rolls","TapNoteSubType_Roll"},
	{"Hands","TapNoteScore_Hands"},
	{"Mines","TapNoteScore_AvoidMine"},
	{"Lifts","TapNoteScore_Lift"}
}

for i, rc_type in ipairs(eval_radar) do
    local JudgVar = 0
	local MaxVal = GAMESTATE:GetCurrentSteps(player):GetRadarValues(player):GetValue( "RadarCategory_"..rc_type[1] )
	local label = THEME:GetString("RadarCategory", rc_type[1])
	local spacing = 46*i
	sp[#sp+1] = Def.ActorFrame {
        InitCommand=function(self) 	self:x(100):y((_screen.cy+UserOptions.judgmenty-20)+(spacing)) end;
		OnCommand=function(self)
            self:visible( UserOptions.showmiscjud )
			self:diffusealpha(0):sleep(0.1 * i):decelerate(0.5):diffusealpha(1)
        end;
        judgmentyChangeMessageCommand=function(s,param)
            s:y( (_screen.cy+param.choicename-20)+(spacing) )
        end,
        showmiscjudChangeMessageCommand=function(s,param)
            s:visible( param.choicename )
        end,
			-- Item name
			Def.BitmapText {
				Font = "_Bold",
				InitCommand=function(self)
					self:zoom(0.6):horizalign(left):diffuse(color("#FFFFFF")):y(18):maxwidth(120)
				end;
				BeginCommand=function(self)
					self:settext( ToUpper(label) )
				end;
			};
			-- Value
			Def.BitmapText {
			Font = "_Bold",
			InitCommand=function(self)
				self:diffuse(ColorLightTone(PlayerColor(player))):diffusetopedge(ColorLightTone(PlayerCompColor(player)))
				self:zoom(0.6):diffusealpha(1.0):shadowlength(1):maxwidth(120):horizalign(left)
			end;
			BeginCommand=function(self)
				self:settext(JudgVar .. "/" .. MaxVal)
            end,
			};
	};
end;

t[#t+1] = sp

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