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

	local function compare(a, b)
		a, b = a:lower(), b:lower()
		local a1, b1 = a:sub(1, 1), b:sub(1, 1)
		if a1:find('%W') and b1:find('%w') then return false
		elseif a1:find('%w') and b1:find('%W') then return true
		end
        return a < b
    end

	table.sort(Groups, compare)

    return Groups
end
