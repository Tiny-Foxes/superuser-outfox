-- Best/Worst Window
return function()
    local JudgNames = LoadModule("Options.SmartTapNoteScore.lua")()
    table.sort(JudgNames)
    -- We need to check what is the worst window available.
    local CurPrefTiming = LoadModule("Config.Load.lua")("SmartTimings","Save/OutFoxPrefs.ini")
    local LowestWindow = nil
    local HighestWindow = nil
    local n = LoadModule( "Options.ReturnCurrentTiming.lua" )()

    -- Now, calculate the lowest.
    for k,v in pairs( JudgNames ) do
        -- lua.ReportScriptError( v )
        if n.Timings[ "TapNoteScore_"..v ] > 0 then
            local ConvertedTime = GetWindowSeconds(n.Timings[ "TapNoteScore_"..v ], 1, 0)
            if not HighestWindow then HighestWindow = ConvertedTime end
            LowestWindow = ConvertedTime
        end
    end
    return LowestWindow, HighestWindow
end