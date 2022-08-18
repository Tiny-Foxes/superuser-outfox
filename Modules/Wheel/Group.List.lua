return function(Songs)

    local Groups = {}

	for v in ivalues(Songs) do
		local Add = true
		for v2 in ivalues(Groups) do
			if v2 == v:GetGroupName() then Add = false break end
		end
		if Add then
			Groups[#Groups+1] = v:GetGroupName()
		end
    end

	local function compare(a,b)
		if a:sub(1, 1):find('%p') then return false end
        return a:lower() < b:lower()
    end

	table.sort(Groups, compare)

    return Groups
end
