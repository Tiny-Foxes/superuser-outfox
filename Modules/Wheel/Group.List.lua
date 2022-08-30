return function(Songs, Sort)

	Sort = Sort or 'Group'

    local Groups = {}

	for v in ivalues(Songs) do
		local Add = true
		for v2 in ivalues(Groups) do
			if v2 == TF_WHEEL.SortType[Sort](v) then Add = false break end
		end
		if Add then
			Groups[#Groups+1] = TF_WHEEL.SortType[Sort](v)
		end
	end

	local function compare(a,b)
		if not a:sub(1, 1):find('%w') and b:sub(1, 1):find('%w') then return false end
        return a:lower() < b:lower()
    end

	table.sort(Groups, compare)

    return Groups
end
