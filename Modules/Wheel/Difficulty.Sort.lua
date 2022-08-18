local function compare(a, b)
	return TF_WHEEL.DiffTab[a:GetDifficulty()] < TF_WHEEL.DiffTab[b:GetDifficulty()]
end

return function(Song)
	local diffs = Song:GetAllSteps()
	table.sort(diffs, compare)
	return diffs
end
