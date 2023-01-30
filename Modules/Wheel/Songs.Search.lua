-- This module does not assume course mode.
return function(Songs, Search)

	local Results = {}

	for v in ivalues(Songs) do
		-- Concatenate searchable parts of data.
		local searchname = v:GetDisplayFullTitle()..' '..v:GetDisplayArtist()
		if searchname:lower():find(Search:lower()) then
			table.insert(Results, v)
		end
	end

	return Results

end
