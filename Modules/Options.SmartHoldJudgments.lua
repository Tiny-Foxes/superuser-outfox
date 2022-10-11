return function(Mode)
	local Dir = FILEMAN:GetDirListing(THEME:GetCurrentThemeDirectory()..'HoldJudgments/', false, true)
	local NewDir = {}
	for _, v in pairs(Dir) do
		if Mode == 'Show' then
			table.insert(NewDir, string.match(v, '.+/(.-) %d'))
		else
			local name = string.match(v, '.+/(.-) %d')
			NewDir[name] = v
		end
	end
	return NewDir
end
