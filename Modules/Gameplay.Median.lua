-- Median Calculation
-- Requested heavily by Squirrel, this module manages the calculation, processing and display of the histogram for judgment offsets.

return function( player, offsetInfo, dimensions )
    local JudgNames = LoadModule("Options.SmartTapNoteScore.lua")()
    table.sort(JudgNames)

    local WindowScale = PREFSMAN:GetPreference("TimingWindowScale")
    local WindowAdd = PREFSMAN:GetPreference("TimingWindowAdd")
    -- STEP 1 : Worst Window
    ----
    -- We need to check what is the worst window available.
    local CurPrefTiming = LoadModule("Config.Load.lua")("SmartTimings","Save/OutFoxPrefs.ini")
    local LowestWindow, HighestWindow = LoadModule("Gameplay.TimingMargins.lua")()
    local n = LoadModule( "Options.ReturnCurrentTiming.lua" )()
    
    -- Ok, Now that we're done with that, calculate the secuence of offsets.
    local offsets = {}
    local val
    for t in ivalues(offsetInfo[player]) do
        -- the first value in t is CurrentMusicSeconds when the offset occurred, which we don't need here
        -- the second value in t is the offset value or the string "Miss"

        if type(t[2]) == "number" then
            val = t[2]
        
            if val then
                val = (math.floor(val*1000))/1000
        
                if not offsets[val] then
                    offsets[val] = 1
                else
                    offsets[val] = offsets[val] + 1
                end
            end
        end
    end

    -- STEP 2 : Generation
    ----

    local worst_offset = 0
    for offset, count in pairs(offsets) do
        if math.abs(offset) > worst_offset then worst_offset = math.abs(offset) end
    end

    -- smooth the offset distribution and store values in a new table, smooth_offsets
    local smooth_offsets = {}

    -- gaussian distribution for smoothing the histogram's jagged peaks and troughs
    local ScaleFactor = { 0.045, 0.090, 0.180, 0.370, 0.180, 0.090, 0.045 }

    local y, index
    for offset=-LowestWindow, LowestWindow, 0.001 do
        offset = math.round(offset,3)
        y = 0

        -- smooth like butter
        for j=-3,3 do
            index = clamp( offset+(j*0.001), -LowestWindow, LowestWindow )
            index = math.round(index,3)
            if offsets[index] then
                y = y + offsets[index] * ScaleFactor[j+4]
            end
        end

        smooth_offsets[offset] = y
    end

    local mode_offset = 0

    -- median_offset is the offset in the middle of an ordered list of all offsets
    -- 2 is the median in a set of { 1, 1, 2, 3, 4 } because it is in the middle
    local median_offset = 0

    -- highest_offset_count is how many times the mode_offset occurred
    -- we'll use it to scale the histogram to be an appropriate height
    local highest_offset_count = 0

    local sum_timing_error = 0
    local avg_timing_error = 0

    -- find the mode of the collected judgment offsets for this player
    -- loop through ALL offsets
    for k,v in pairs(offsets) do
        -- compare this particular offset to the current highest_offset
        -- if higher, it's the new mode
        if v > highest_offset_count then
            highest_offset_count = v
            mode_offset = round(k,3)
        end
    end

    local list = {}
    for offset=-LowestWindow, LowestWindow, 0.001 do
        offset = round(offset,3)

        if offsets[offset] then
            for i=1,offsets[offset] do
                list[#list+1] = offset
            end
        end
    end

    if #list > 0 then

        -- Now calculate the median
        if #list % 2 == 1 then
            median_offset = list[math.ceil(#list/2)]
        else
            median_offset = (list[#list/2] + list[#list/2+1])/2
        end
    
        -- loop through all offsets collected
        -- take the absolute value (because this offset could be negative)
        -- and add it to the running measure of total timing error
        for i=1,#list do
            sum_timing_error = sum_timing_error + math.abs(list[i])
        end
    
        -- calculate the avg timing error, rounded to 3 decimals
        avg_timing_error = round(sum_timing_error/#list,3)
    end

    local verts = {}
    
    local pane_width = dimensions[1]
    local pane_height = dimensions[2]

    local total_width = (LowestWindow * 2) * 1000 + 1
    local w = pane_width/total_width
    local x, c

    local i=6

    local function TimingWindowByValue(time)
        for k,v in pairs(JudgNames) do
            if math.abs(time) <= n.Timings[ "TapNoteScore_"..v ] then
                -- lua.ReportScriptError( "Timing ".. v .. " (".. Timings[ "TapNoteScore_"..v ] .. ") matches ".. math.abs(time) )
                return v
            end
        end
        return "W5"
    end

    for offset=-LowestWindow, LowestWindow, 0.001 do
        offset = math.round(offset,3)
        x = i * w
        y = smooth_offsets[offset] or 0

        -- don't bother adding vert data for offsets that were smoothed
        -- beyond whatever the worst_offset actually earned by the player was
        if math.abs(offset) <= worst_offset then
            -- scale the highest point on the histogram to be 0.75 times as high as the pane
            y = -1 * scale(y, 0, highest_offset_count, 0, pane_height)
            local tm = TimingWindowByValue( offset )
            c = JudgmentLineToColor( "JudgmentLine_".. tm )

            -- the ActorMultiVertex is in "QuadStrip" drawmode, like a series of quads placed next to one another
            -- each vertex is a table of two tables:
            -- {x, y, z}, {r, g, b, a}
            verts[#verts+1] = {{x, 0, 0}, c }
            verts[#verts+1] = {{x, y, 0}, c }
        end

        i = i+1
    end

    return {
        TimingList = {JudgNames,n.Timings},
        HighWindow = HighestWindow,
        LowWindow = LowestWindow,
        Vertex = verts,
        (avg_timing_error*1000),
        (median_offset*1000),
        (mode_offset*1000)
    }
end