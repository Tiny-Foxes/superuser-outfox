local konko = LoadModule('Konko.Core.lua')
konko()

local ThemeColor = LoadModule('Theme.Colors.lua')
local SuperActor = LoadModule('Konko.SuperActor.lua')

--[[
	local options = {
		StartIndex = 1,
		{'Option1', function(self)
			-- this one goes to next screen
		end},
		{'Option2', function(self)
			-- this one shaves your leggies
		end}
	}
	local optwheel = LoadModule('Options.Wheel.lua')(options)
--]]

return function(t)

	local Index = t.StartIndex or 1

	local function MoveSelection(self, offset)
		Index = Index + offset
		while Index < 1 do Index = Index + #t end
		while Index > #t do Index = Index - #t end
		local params = {Index = Index}
		MESSAGEMAN:Broadcast('MoveOptions', params)
		local aux = self:getaux() + offset
		if not t.Loop then aux = Index - 1 end
		if offset ~= 0 then
			self:stoptweening():easeoutexpo(0.15):aux(aux)
			if not t.Mute then
				SOUND:PlayOnce(THEME:GetPathS('Common', 'value'), true)
			end
		else
			self:aux(aux)
		end
	end

	local wheel = SuperActor.new('ActorScroller')

	do wheel
		:SetAttribute('UseScroller', true)
		:SetAttribute('SecondsPerItem', 0)
		:SetAttribute('NumItemsToDraw', 9)
		:SetAttribute('ItemPaddingStart', 0)
		:SetAttribute('ItemPaddingEnd', 0)
		:SetAttribute('TransformFunction', function(self, offset, itemIndex, numItems)
			if not self:GetVisible() then return end
			self:xy(offset * -48, offset * 96)
			if offset > -1 and offset < 1 then
				self
					:zoom( 1.5 + (0.5 - math.abs(offset * 0.5)) )
					:x( (offset * -48) - (80 - (math.abs(offset * 80))) )
			else
				self:zoom(1.5)
			end
			if offset > 3 and offset < -3 then
				self:zoom(1.5)
				for _, child in ipairs(self:GetChildren()) do
					child:diffusealpha(1 - (math.abs(offset) - 3))
				end
			end
		end)
		:SetCommand('Init', function(self)
			self
				:xy(SR - 210, SCY)
				:SetLoop(t.Loop or false)
				:SetFastCatchup(true)
				:aux(0)
		end)
		:SetCommand('On', function(self)
			SCREENMAN:GetTopScreen():AddInputCallback(TF_WHEEL.Input(self))
			self:SetUpdateFunction(function(self)
				self:SetCurrentAndDestinationItem(self:getaux())
			end)
			MoveSelection(self, 0)
			self:addx(SCX):easeoutexpo(0.5):addx(-SCX)
		end)
		:SetCommand('Off', function(self)
			SCREENMAN:GetTopScreen():RemoveInputCallback(TF_WHEEL.Input(self))
			self:easeoutexpo(0.5):addx(SCX)
		end)
		:SetCommand('StartTransitioning', function(self)
			self:easeoutexpo(0.5):addx(SCX)
		end)
		:SetCommand('MenuUp', function(self)
			MoveSelection(self, -1)
		end)
		:SetCommand('MenuDown', function(self)
			MoveSelection(self, 1)
		end)
		:SetCommand('MenuLeft', function(self)
			MoveSelection(self, -1)
		end)
		:SetCommand('MenuRight', function(self)
			MoveSelection(self, 1)
		end)
		:SetCommand('Back', function(self)
			SCREENMAN:GetTopScreen():Cancel()
		end)
		:SetCommand('Start', function(self)
			t[Index][2](self)
			SCREENMAN:PlayStartSound()
		end)
	end

	for i = 1, #t do

		local option = SuperActor.new('ActorFrame')
		local panel = SuperActor.new('Quad')
		local text = SuperActor.new('BitmapText')

		do panel
			:SetCommand('Init', function(self)
				self
					:SetSize(320, 48)
					:diffuse(ThemeColor.Elements)
					:skewx(-0.5)
					:shadowlength(2, 2)
			end)
		end
		do text
			:SetAttribute('Font', 'Common Large')
			:SetAttribute('Text', t[i][1])
			:SetCommand('Init', function(self)
				self:zoom(0.5):maxwidth(540)
			end)
		end
		do option
			:AddChild(panel, 'Panel')
			:AddChild(text, 'Text')
		end
		wheel:AddChild(option)
	end

	wheel:AddToTree('Wheel')

	return SuperActor.GetTree()

end
