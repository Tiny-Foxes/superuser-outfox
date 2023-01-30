-- Return the main function that contains a list of the groups.
-- Edited from Jousway's code by Sudospective to make a nested table:
-- 		- AllGroups
-- 			- GroupName 1
-- 				- Song 1
-- 				- Song 2
-- 			- GroupName 2
-- 				- Song 1
-- 				- Song 2
-- 				- Song 3

return function(Songs, Sort, ...)

	Sort = Sort or 'Group'

	local Groups = LoadModule('Wheel/Group.List.lua')(Songs, Sort)
	local GroupsAndSongs = {}

	if Sort == 'Search' then
		return {Results = LoadModule('Wheel/Songs.Search.lua')(Songs, ...)}
	end

	for v in ivalues(Groups) do
		GroupsAndSongs[v] = GroupsAndSongs[v] or {}
		for v2 in ivalues(Songs) do
			if TF_WHEEL.SortType[Sort](v2) == v or GAMESTATE:IsCourseMode() then
				GroupsAndSongs[v][#GroupsAndSongs[v] + 1] = v2
			end
		end
	end

	return GroupsAndSongs
end
