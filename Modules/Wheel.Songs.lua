local allsongs = ...
local game = GAMESTATE:GetCurrentGame():GetName()

local function BothSidesJoined()
	return (GAMESTATE:IsSideJoined(PLAYER_1) and GAMESTATE:IsSideJoined(PLAYER_2))
end

local function GrabDiffs(song)
	if not song then return end
	local ret, charts = {}, {}
	if GAMESTATE:IsCourseMode() then
		charts = song:GetAllTrails()
	else
		charts = song:GetAllSteps()
	end
	if charts then
		for _, d in ipairs(charts) do
			local match = d:GetStepsType()
			match = match:lower()
			if match:find(game) then
				if not (match:find('double') and BothSidesJoined()) then
					ret[#ret + 1] = d
				end
			end
		end
	end
	return ret
end

local function GrabSongs(group)
	if not group then return end
	local ret, songs = {}, {}
	--[[
	if GAMESTATE:IsCourseMode() then
		songs = SONGMAN:GetCoursesInGroup(group, true)
	else
		songs = SONGMAN:GetSongsInGroup(group)
	end
	if songs then
		for _, s in ipairs(songs) do
			if s:IsEnabled() and #GrabDiffs(s) > 0 then
				ret[#ret + 1] = s
			end
		end
	end
	--]]
	for _, s in ipairs(allsongs) do
		if s:GetGroupName() == group then
			ret[#ret + 1] = s
		end
	end
	return ret
end

local function GrabGroups()
	local ret, groups = {}, {}
	if GAMESTATE:IsCourseMode() then
		groups = SONGMAN:GetCourseGroupNames()
	else
		groups = SONGMAN:GetSongGroupNames()
	end
	if groups then
		for _, g in ipairs(groups) do
			if #GrabSongs(g) > 0 then
				ret[#ret + 1] = g
			end
		end
	end
	return ret
end

return GrabGroups, GrabSongs, GrabDiffs
