return function(Mode)
	local Dir = FILEMAN:GetDirListing("Appearance/Judgments/",false,true)
	-- Include theme judgments as well. ~Sudo
	for v in ivalues(FILEMAN:GetDirListing(THEME:GetCurrentThemeDirectory()..'Judgments/', false, true)) do
		table.insert(Dir, v)
	end
	local NewDir = {}
	for _,v in pairs(Dir) do
		if Mode == "Show" then
			NewDir[#NewDir+1] = string.match(v,".+/(.-) %d")
		else
			NewDir[#NewDir+1] = v
		end
	end
	return NewDir
end