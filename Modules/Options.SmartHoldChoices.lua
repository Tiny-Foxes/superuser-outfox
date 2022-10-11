return function(Mode)
	local HJ = LoadModule("Options.SmartHoldJudgments.lua")("Show")

	local HoldGraphics = {}
	for i, v in ipairs(HJ) do
		local v2 = string.match(v, '(.-) %d')
		local datatype = (Mode == 'Value' and v) or (v2 ~= nil and v2 or v)
		table.insert(HoldGraphics, datatype)
	end

	return HoldGraphics
end