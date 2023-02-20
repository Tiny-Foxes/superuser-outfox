local UIHelper = LoadModule("UI/UIHelper.OptionList.lua")
local speedVal = 0
-- ?: Is it a good look? Maybe it could be a helper module, not sure.
local function song_option( name, type, margin, min, max, format, formatVis )
    return { Name = name, Type = type, Value = "song_option", Margin = margin, Min = min, Max = max, Format = format, FormatVisible = formatVis }
end

local speedprx = {"%.2fx","C%d","M%d","A%d","CA%d"}
local speedType = 1
local speedstep = 25
local DetailedPaneMenuOpen = false
local PaceMenuOpen = false
local speedFuncs
local JudgmentTypeGraphics = LoadModule("Options.SmartJudgeChoices.lua")()
local JudgmentValues = LoadModule("Options.SmartJudgeChoices.lua")("Value")
local ComboTypeGraphics = LoadModule("Options.SmartCombo.lua")("Show")
return {
    Name = "New Area!",
    { Icon = THEME:GetPathG("SelectMusic/Play","Triangle"), Name = "Ready!", Type="message", Value = "PlayerIsReady" },
    -- { Name = "SongRate", Type = "number",  }
    song_option( "MusicRate", "number", 0.02, 0.2, 3, "%.2f", UIHelper.decimalNumber ),
    {
        SkipIf = not NETMAN or not NETMAN:IsConnectionEstablished(),
        Icon = THEME:GetPathG("MenuIcon","network"),
        Name = "AutoSaveOnlineScore",
        Type = "boolean",
        Default = true,
        Value = "outfox_pref",
    },
    {
        Name = "General Options",
        MessageOnEntry = "ShowPreview",
        Menu = {
            MessageOnExit = "HidePreview",
            { 
                Name = "Speed",
                FormatVisible = function(self)
                    lua.ReportScriptError( rin_inspect(self.player) )

                    if speedVal == 0 then
                        local pOptions = GAMESTATE:GetPlayerState(self.player):GetPlayerOptions("ModsLevel_Preferred")
                        speedType = UIHelper.ObtainSpeedType( pOptions )
                        speedVal = UIHelper.GetSpeed( pOptions, speedType )
                    end

                    local value = speedVal
                    local isXMod = speedType == 1
                    return string.format(speedprx[speedType], speedVal * (isXMod and 0.01 or 1) )
                end,
                MessageOnEntry = "ShowSpeeds",
                Menu = {
                    MessageOnExit = "HideSpeeds",
                    -- The speed value needs to calculate specific conversions when changing the type.
                    { Name = "Current Speed", Type = "number", Min = 0, Margin = speedstep, Value = speedVal,
                    Load = function( self, Player )
                        local pOptions = GAMESTATE:GetPlayerState(Player):GetPlayerOptions("ModsLevel_Preferred")
                        
                        local tmpp = UIHelper.ObtainSpeedType( pOptions )
                        local speed = UIHelper.GetSpeed( pOptions, tmpp )

                        speedVal = speed
                        MESSAGEMAN:Broadcast("SpeedChange",{ Player = Player, Speed = speed, Type = tmpp })
                        return speed
                    end,
                    Save = function( self, Player )
                        local pOptions = GAMESTATE:GetPlayerState(Player):GetPlayerOptions("ModsLevel_Preferred")
                        local finalspeed = (speedType == 1 and speedVal*.01 or speedVal)
                        speedFuncs[speedType]( pOptions, finalspeed )
                        MESSAGEMAN:Broadcast("PlayerOptionChange",{ Player = player })
                    end,
                    FormatVisible = function(value)
                        -- SCREENMAN:SystemMessage(speedType)
                        local isXMod = speedType == 1
                        return string.format(speedprx[speedType], value * (isXMod and 0.01 or 1) )
                    end,
                    SubscribedMessage = "Speed Mod Type",
                    UpdateFromMessage = function(Container,newValue,player)
                        Container.ValueE = Container.Load( nil, player )
                        Container.Margin = speedstep
                        -- Container.Margin = speedType == 1 and 0.25 or 25
                        
                        Container.Save( Container, player )
                        MESSAGEMAN:Broadcast("SpeedChange",{ Player = player, Speed = newValue, Type = speedType })
                    end,
                    NotifyOfChange = function(Container,newValue,player)
                        speedVal = newValue
                        -- MESSAGEMAN:Broadcast("PlayerOptionChange",{ Player = player })
                        MESSAGEMAN:Broadcast("SpeedChange",{ Player = player, Speed = newValue, Type = speedType })
                    end
                },
                { Name = "Speed Mod Type", Type = "list", Value = 1, Values = {"XMod", "CMod", "MMod", "AMod", "CAMod"},
                    Load = function( self, Player )
                        -- Time to find what speed mod is the player using right now.
                        local pOptions = GAMESTATE:GetPlayerState(Player):GetPlayerOptions("ModsLevel_Preferred")
                        speedFuncs = {
                            pOptions.XMod,
                            pOptions.CMod,
                            pOptions.MMod,
                            pOptions.AMod,
                            pOptions.CAMod,
                        }

                        local sptype = UIHelper.ObtainSpeedType( pOptions )
                        speedType = sptype

                        MESSAGEMAN:Broadcast("CheckForMessages",{Value="Speed Mod Type"})
                        return sptype
                    end,
                    -- SubscribedMessage = "Speed Step",
                    NotifyOfChange = function(Container,newValue,player)
                        local pOptions = GAMESTATE:GetPlayerState(player):GetPlayerOptions("ModsLevel_Preferred")
                        speedType = newValue
                        SCREENMAN:SystemMessage(newValue)
                        -- funcs
                        MESSAGEMAN:Broadcast("SpeedChange",{ Player = Player, Speed = speedVal, Type = speedType })
                        MESSAGEMAN:Broadcast("CheckForMessages",{Value="Speed Mod Type"})
                    end
                },
                {
		            Name = "Speed Increment", Type = "number", Min = 1, Max = 50, Margin = 1, Value = "outfox_pref", Default = 25,
                    AfterLoad = function(self)
                        -- Update the step of speed after load was successful.
                        speedstep = self.container.ValueE
                        -- To prevent problems, send this new value so the speed number type
                        -- doesn't break with the older number it stored.
                        MESSAGEMAN:Broadcast("CheckForMessages",{Value="Speed Mod Type"})
                    end,
                    NotifyOfChange = function(Container,newValue,player)
                        speedstep = newValue
                        MESSAGEMAN:Broadcast("CheckForMessages",{Value="Speed Mod Type"})
                    end
                }
            } },
            { Name = "Mini", Type = "number", Margin = 0.01, Min = -2, Max = 2, Format = "%.2f", FormatVisible = UIHelper.formatToPercent, Value = "player_mod" },
            { Name = "Persp", Type = "list", Value = "player_mod_table", Values = {"Hallway","Incoming","Overhead","Space","Distant"} },
            { Name = "Reverse", Type = "number", Margin = 0.05, Min = 0, Max = 1, Format = "%.2f", FormatVisible = UIHelper.formatToPercent, Value = "player_mod" },
            -- The player_mod flag will tell the list to look for this option from PlayerOptions.
            { Name = "NoteSkin", Type = "list", Value = "player_mod", Values = NOTESKIN:GetNoteSkinNames() },
        }
    },
    {
        Icon = THEME:GetPathG("","UI/Gear"),
        Name = "Song Options",
        Menu = {
            { Name = "LifeSetting", Type="list", Value = "player_mod",
                Values = {"LifeType_Bar", "LifeType_Battery", "LifeType_Time"},
                -- Custom data that can be accessed from the self space.
                Strings = {"Bar","Battery","LifeTime"},
                FormatVisible = function(self,value)
                    return THEME:GetString("OptionNames", self.container.Strings[value])
                end,
                Save = function( self, player )
                    local val = self.container.Values[self.container.ValueE]
                    -- Proably only need Preferred and Song.
                    GAMESTATE:GetPlayerState(player):GetPlayerOptions("ModsLevel_Preferred"):LifeSetting( val )
                    GAMESTATE:GetPlayerState(player):GetPlayerOptions("ModsLevel_Song"):LifeSetting( val )
                    GAMESTATE:GetPlayerState(player):GetPlayerOptions("ModsLevel_Current"):LifeSetting( val )
                end
            },
            {
                Name = "FailSetting", Type = "list", Value = "player_mod",
                Values = {"FailType_Immediate","FailType_ImmediateContinue","FailType_EndOfSong","FailType_Off"},
                Strings = {"Immediate","ImmediateContinue","EndOfSong","Off"},
                FormatVisible = function(self,value)
                    return THEME:GetString("OptionNames",self.container.Strings[value])
                end,
                Save = function(self,player)
                    local val = UIHelper.GetItemFromContainerIndex(self)
                    GAMESTATE:GetPlayerState(player):GetPlayerOptions("ModsLevel_Preferred"):FailSetting(val)
                end
            },
            { Name="AllPlayerSettings", Type = "label" },
            song_option( "AssistClap", "boolean" ),
            song_option( "AssistMetronome", "boolean" ),
            { Name="ShowLyrics", Type = "boolean", Value = "system_option" },
        }
    },
    {
        -- OutFox-specific options.
        Icon = THEME:GetPathG("","UI/Gear"),
        Name = "Additional Options",
        MessageOnEntry = "ShowPreview",
        Menu = {
            MessageOnExit = "HidePreview",
            {
                Name = "StatsPane",
                Type="boolean",
                Value="outfox_pref",
                AfterLoad = function(self)
                    DetailedPaneMenuOpen = self.container.ValueE
                    MESSAGEMAN:Broadcast("CheckForMessages",{Value="StatsPane"})
                end,
                NotifyOfChange = function(Container,newValue,player)
                    DetailedPaneMenuOpen = newValue
                    MESSAGEMAN:Broadcast("CheckForMessages",{Value="StatsPane"})
                end
            },
            {
                Name = "StatsPane Settings",
                Disabled = not DetailedPaneMenuOpen,
                SubscribedMessage = "StatsPane",
                UpdateFromMessage = function(Container,newValue,player)
                    Container.Disabled = not DetailedPaneMenuOpen
                end,
                Menu = {
                    { Name = "showmiscjud", Type="boolean", Value="outfox_pref", Default = true },
                    { Name = "colorlifescatter", Type="boolean", Value="outfox_pref", Default = true },
                    { Name = "judgmentscatter", Type="boolean", Value="outfox_pref" },
                    { Name = "labelnps", Type="boolean", Value="outfox_pref" },
                    { Name = "alwaysmovegraph", Type="boolean", Value="outfox_pref" },
                    { Name = "showfullgraph", Type="boolean", Value="outfox_pref" },
                    { Name = "progressquad", Type="boolean", Value="outfox_pref", Default = true },
                }
            },
            {
                Name = "PaceMaker",
                Type="boolean",
                Value="outfox_pref",
                AfterLoad = function(self)
                    PaceMenuOpen = self.container.ValueE
                    MESSAGEMAN:Broadcast("CheckForMessages",{Value="PaceMaker"})
                end,
                NotifyOfChange = function(Container,newValue,player)
                    PaceMenuOpen = newValue
                    MESSAGEMAN:Broadcast("CheckForMessages",{Value="PaceMaker"})
                end
            },
            {
                Name = "PaceMaker Settings",
                Disabled = not PaceMenuOpen,
                SubscribedMessage = "PaceMaker",
                UpdateFromMessage = function(Container,newValue,player)
                    Container.Disabled = not PaceMenuOpen
                end,
                Menu = {
                    { Name="TODO: Add specific items on this submenu", Type = "label" },
                    { Name = "showmiscjud", Type="boolean", Value="outfox_pref", Default = true },
                    { Name = "colorlifescatter", Type="boolean", Value="outfox_pref", Default = true },
                    { Name = "judgmentscatter", Type="boolean", Value="outfox_pref" },
                    { Name = "labelnps", Type="boolean", Value="outfox_pref" },
                    { Name = "alwaysmovegraph", Type="boolean", Value="outfox_pref" },
                    { Name = "showfullgraph", Type="boolean", Value="outfox_pref" },
                    { Name = "progressquad", Type="boolean", Value="outfox_pref", Default = true },
                }
            },
            { Name = "OffsetBar", Type="boolean", Value="outfox_pref",
                NotifyOfChange = function(Container,newValue,player)
                    MESSAGEMAN:Broadcast("OffsetBarChange",{Value=newValue, pn = player})
                end
            },
            { Name = "MeasureCounter", Type="boolean", Value="outfox_pref" },
            { Name = "OverTopGraph", Type="boolean", Value="outfox_pref" },
            { Name = "MissCounter", Type="boolean", Value="outfox_pref",
                NotifyOfChange = function(Container,newValue,player)
                    MESSAGEMAN:Broadcast("MissCounterChange",{Value=newValue, pn = player})
                end
            },
            {
                Name = "BeatBars", Type="boolean", Value="outfox_pref",
                NotifyOfChange = function(Container,newValue,player)
                    MESSAGEMAN:Broadcast("BeatBarsChange",{Value=newValue, pn = player})
                end
            },
            { Name = "ScreenFilter", Type="number", Default = 0, Margin = 0.1, Min = 0, Max = 1, Format = "%.2f", FormatVisible = UIHelper.formatToPercent, Value="outfox_pref",
                NotifyOfChange = function(Container,newValue,player)
                    MESSAGEMAN:Broadcast("ScreenFilterChange",{Value=newValue, pn = player})
                end
            },
            -- TODO: outfox_pref_table
            { Name = "SmartTimings", Type="list", Value = "outfox_pref_table", MachinePref = true, Values = TimingModes,
                NotifyOfChange = function(Container,newValue,player)
                    local newtimingwindow = TimingModes[newValue]
                    -- GAMESTATE:Env()["SmartTimings"] = newtimingwindow
                    JudgmentTypeGraphics = LoadModule("Options.SmartJudgeChoices.lua")(nil,newtimingwindow)
                    JudgmentValues = LoadModule("Options.SmartJudgeChoices.lua")("Value",newtimingwindow)
                    MESSAGEMAN:Broadcast("CheckForMessages",{Value="SmartTimings"})
                end
            },
            { 
                Name = "SmartJudgments",
                Type="list",
                Value = "outfox_pref_table",
                Values = JudgmentTypeGraphics,
                SubscribedMessage = "SmartTimings",
                UpdateFromMessage = function(Container,newValue,player)
                    Container.Values = JudgmentTypeGraphics
                end,
                NotifyOfChange = function(Container,newValue,player)
                    MESSAGEMAN:Broadcast("JudgementGraphicChange",{Value=newValue, pn = player, Choices = JudgmentTypeGraphics})
                end
            },
            { 
                Name = "SmartCombo",
                Type="list",
                Value = "outfox_pref_table",
                Values = ComboTypeGraphics,
                NotifyOfChange = function(Container,newValue,player)
                    MESSAGEMAN:Broadcast("ComboGraphicChange",{Value=newValue, pn = player, Choices = ComboTypeGraphics})
                end
            }
        }
    },
    {
        -- Options related to other kinds of modifiers.
        Name = "More Options",
        MessageOnEntry = "ShowPreview",
        Menu = {
            MessageOnExit = "HidePreview",
            {
                Name = "Note Display",
                -- MessageOnEntry = "ShowPreview",
                Menu = {
                    -- MessageOnExit = "HidePreview",
                    { Name = "NoteSkin", Type = "list", Value = "player_mod", Values = NOTESKIN:GetNoteSkinNames() },
                    { Name = "Mini", Type = "number", Margin = 0.01, Format = "%.2f", FormatVisible = UIHelper.formatToPercent, Value = "player_mod" },
                    { Name = "NotefieldBG", Type = "number", Margin = 0.01, Format = "%.2f", FormatVisible = UIHelper.formatToPercent, Value = 0 },
                    { Name = "Persp", Type = "list", Value = "player_mod_table", Values = {"Hallway","Incoming","Overhead","Space","Distant"} },
                    { Name = "Dark", Type = "boolean", Value = "player_mod" },
                }
            },
            {
                Name = "Chart Modifiers",
                -- MessageOnEntry = "ShowPreview",
                Menu = {
                    { Name = "Left", Type = "boolean", Value = "player_mod" },
                    { Name = "Right", Type = "boolean", Value = "player_mod" },
                    { Name = "Mirror", Type = "boolean", Value = "player_mod" },
                    { Name = "Backwards", Type = "boolean", Value = "player_mod" },
                    { Name = "Shuffle", Type = "boolean", Value = "player_mod" },
                    { Name = "SuperShuffle", Type = "boolean", Value = "player_mod" },
                    { Name = "SoftShuffle", Type = "boolean", Value = "player_mod" },
                }
            },
            {
                Name = "Insert Modifiers",
                -- MessageOnEntry = "ShowPreview",
                Menu = {
                    { Name = "Wide", Type = "boolean", Value = "player_mod", LiteralBool = true },
                    { Name = "Big", Type = "boolean", Value = "player_mod", LiteralBool = true },
                    { Name = "Quick", Type = "boolean", Value = "player_mod", LiteralBool = true },
                    { Name = "BMRize", Type = "boolean", Value = "player_mod", LiteralBool = true },
                    { Name = "Skippy", Type = "boolean", Value = "player_mod", LiteralBool = true },
                    { Name = "Echo", Type = "boolean", Value = "player_mod", LiteralBool = true },
                    { Name = "Stomp", Type = "boolean", Value = "player_mod", LiteralBool = true },
                }
            },
            {
                Name = "Remove Notes",
                -- MessageOnEntry = "ShowPreview",
                Menu = {
                    { Name = "NoStretch", Type = "boolean", Value = "player_mod" },
                    { Name = "NoRolls", Type = "boolean", Value = "player_mod" },
                    { Name = "NoLifts", Type = "boolean", Value = "player_mod" },
                    { Name = "NoFakes", Type = "boolean", Value = "player_mod" },
                }
            },
            {
                Name = "Note Effects",
                -- MessageOnEntry = "ShowPreview",
                Menu = {
                    -- MessageOnExit = "HidePreview",
                    {
                        Name = "Effects",
                        Menu = {
                            { Name = "Drunk", Type = "boolean", Value = "player_mod" },
                            { Name = "Dizzy", Type = "boolean", Value = "player_mod" },
                            { Name = "Twirl", Type = "boolean", Value = "player_mod" },
                            { Name = "Roll", Type = "boolean", Value = "player_mod" },
                            { Name = "Confusion", Type = "boolean", Value = "player_mod" },
                            { Name = "Mini", Type = "number", Margin = 0.01, Format = "%.2f", FormatVisible = UIHelper.formatToPercent, Value = "player_mod" },
                            { Name = "Tiny", Type = "number", Margin = 0.01, Format = "%.2f", FormatVisible = UIHelper.formatToPercent, Value = "player_mod" },
                            { Name = "Beat", Type = "boolean", Value = "player_mod" },
                            { Name = "Bumpy", Type = "boolean", Value = "player_mod" },
                            { Name = "Confusion", Type = "boolean", Value = "player_mod" },
                            { Name = "Dizzy", Type = "boolean", Value = "player_mod" },
                            { Name = "Flip", Type = "boolean", Value = "player_mod" },
                            { Name = "Invert", Type = "boolean", Value = "player_mod" },
                            { Name = "Tipsy", Type = "boolean", Value = "player_mod" },
                            { Name = "Tornado", Type = "boolean", Value = "player_mod" },
                            { Name = "Xmode", Type = "boolean", Value = "player_mod" }
                        }
                    },
                    {
                        Name = "Scroll",
                        Menu = {
                            { Name = "Boost", Type = "boolean", Value = "player_mod" },
                            { Name = "Boomerang", Type = "boolean", Value = "player_mod" },
                            { Name = "Brake", Type = "boolean", Value = "player_mod" },
                            { Name = "Expand", Type = "boolean", Value = "player_mod" },
                            { Name = "Wave", Type = "boolean", Value = "player_mod" },

                            { Name = "Reverse", Type = "boolean", Value = "player_mod" },
                            { Name = "Split", Type = "boolean", Value = "player_mod" },
                            { Name = "Alternate", Type = "boolean", Value = "player_mod" },
                            { Name = "Cross", Type = "boolean", Value = "player_mod" },
                            { Name = "Centered", Type = "boolean", Value = "player_mod" },
                        }
                    },
                    {
                        Name = "Vision",
                        Menu = {
                            { Name = "Hidden", Type = "boolean", Value = "player_mod" },
                            { Name = "Sudden", Type = "boolean", Value = "player_mod" },
                            { Name = "Blink", Type = "boolean", Value = "player_mod" },
                            { Name = "RandomVanish", Type = "boolean", Value = "player_mod" },
                        }
                    }
                }
            },
        }
    },
    { Icon = THEME:GetPathG("","UI/Back"), Name = "Return to Music Selection", Type="cancel", ForceSave=true, Value = SelectMusicOrCourse() },
}
