return function(Mode)
	local Dir = FILEMAN:GetDirListing("Appearance/Judgments/",false,true)
	-- Include theme judgments as well. ~Sudo
	local ThemeDir = FILEMAN:GetDirListing(THEME:GetCurrentThemeDirectory()..'Judgments/', false, true)
	for k, v in pairs(ThemeDir) do
		Dir[k] = v
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