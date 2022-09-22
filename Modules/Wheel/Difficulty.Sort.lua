local st = StepsType:Reverse()

local game = GAMESTATE:GetCurrentGame():GetName()

local game_remap = {
	['be-mu'] = 'bm',
	['po-mu'] = 'popn',
}

local function compare(a, b)
	if st[a:GetStepsType()] == st[b:GetStepsType()] then
		if TF_WHEEL.DiffTab[a:GetDifficulty()] == TF_WHEEL.DiffTab[b:GetDifficulty()] then
			return a:GetMeter() < b:GetMeter()
		else
			return TF_WHEEL.DiffTab[a:GetDifficulty()] < TF_WHEEL.DiffTab[b:GetDifficulty()]
		end
	else
		return st[a:GetStepsType()] < st[b:GetStepsType()]
	end
end

return function(Song)
	local diffs = Song:GetAllSteps()
	local compat = {}
	for chart in ivalues(diffs) do
		local match = chart:GetStepsType():lower()
		if match:find((game_remap[game] or game)) then
			if not (
				(match:find('double') or not match:find('couple')) and (
					GAMESTATE:IsSideJoined(PLAYER_1) and
					GAMESTATE:IsSideJoined(PLAYER_2)
				)
			) then
				compat[#compat + 1] = chart
			end
		end
	end
	table.sort(compat, compare)
	return compat
end
