-- The Songs loader for custom wheels.
-- Accepts Style.
return function(Style)

	-- All the Compatible Songs Container.
	local AllCompSongs = {}
		
	-- For all Songs.
	for CurSong in ivalues(SONGMAN:GetAllSongs()) do
	
		-- Temp Difficulty Container.
		local DiffCon = {}
			
		-- Set the first value to be Current Looped Song, In the Temp Current Song Container.
		local CurSongCon = {CurSong}
		

		-- For all the playable steps in Current looped Song.
		for CurStep in ivalues(SongUtil.GetPlayableSteps(CurSong)) do
			-- Find if Steps supports current selected Style.
			if string.find(CurStep:GetStepsType():lower(), Style) then

				-- Check the type of Steps 
				local Type = 1

				-- Check if its HalfDoubles.
				if string.find(CurStep:GetStepsType():lower(), "half") then
					Type = 2
				--Check if its Doubles.
				elseif string.find(CurStep:GetStepsType():lower(), "double") then
					Type = 3
				end
				
				-- Check the step level.
				local Meter = tonumber(CurStep:GetMeter())
				-- If the step level is under 10, Add a 0 in front.
				if tonumber(CurStep:GetMeter()) < 10 then
					-- Add the 0.
					Meter = "0"..CurStep:GetMeter()
				end
				-- Add the Difficulty to the Temp Difficulty Contrainer.
				DiffCon[Type.."_"..tonumber(Difficulty:Reverse()[CurStep:GetDifficulty()] + 1).."_"..Meter] = CurStep
			end
		end

		-- We want to sort the Difficulties, So we grab the Keys and Sort based on them.
		local Keys = {}
		for k in pairs(DiffCon) do table.insert(Keys, k) end
		table.sort(Keys)

		-- Now we put the Difficulies inside the Temp Current Song Contrainer.
		for k in ivalues(Keys) do
			if DiffCon[k] then
				CurSongCon[#CurSongCon+1] = DiffCon[k]
			end

		end

		-- If a Difficulty exist for song using Style, Add it to All Compatible Songs.
		if CurSongCon[2] then
			AllCompSongs[#AllCompSongs+1] = CurSong
		end
	end

	local function compare(a, b)
		a, b = a:GetDisplayFullTitle():lower(), b:GetDisplayFullTitle():lower()
		local a1, b1 = a:sub(1, 1), b:sub(1, 1)
		if a1:find('%W') and b1:find('%w') then return false
		elseif a1:find('%w') and b1:find('%W') then return true
		end
		return a < b
    end

	table.sort(AllCompSongs, compare)

	-- Return all the Songs, That support Current Style.
	return AllCompSongs
end
