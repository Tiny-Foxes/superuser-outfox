local konko = LoadModule('Konko.Core.lua')
konko()

local SuperActor = LoadModule('Konko.SuperActor.lua')

local cursor = SuperActor.new('Quad')

do cursor
	:SetCommand('Init', function(self)
		self:SetSize(16, 16)
	end)
	:SetCommand('On', function(self)
		self:SetUpdateFunction(function(self)
			self:xy(INPUTFILTER:GetMouseX(), INPUTFILTER:GetMouseY())
		end)
	end)
	:AddToTree('Cursor')
end

return SuperActor.GetTree()
