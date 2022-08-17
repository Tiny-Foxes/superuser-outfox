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

return function(Songs)

	local Groups = LoadModule('Wheel/Group.List.lua')(Songs)
	
	local GroupsAndSongs = {}
	
	for _, v in ipairs(Groups) do
		GroupsAndSongs[v] = GroupsAndSongs[v] or {}
		for _, v2 in ipairs(Songs) do
			if v2:GetGroupName() == v then
				GroupsAndSongs[v][#GroupsAndSongs[v] + 1] = v2
			end
		end
	end

	return GroupsAndSongs
end
