local ThemeColor = LoadModule('Theme.Colors.lua')
local konko = LoadModule('Konko.Core.lua')
konko()

local plrs = {
	[PLAYER_1] = false,
	[PLAYER_2] = false,
}
for v in ivalues(GAMESTATE:GetEnabledPlayers()) do
	plrs[v] = true
end
local diffIndex = {
	[PLAYER_1] = 1,
	[PLAYER_2] = 1,
}

local DiffLoader = LoadModule('Wheel/Difficulty.Sort.lua')
local AllDiffs = DiffLoader(GAMESTATE:GetCurrentSong())
local CurDiff = {
	[PLAYER_1] = AllDiffs[1],
	[PLAYER_2] = AllDiffs[1],
}

local function MoveDifficulty(self, offset, Diffs)
	local diffCount = #Diffs
	if plrs[self.pn] then
		diffIndex[self.pn] = diffIndex[self.pn] + offset
		while diffIndex[self.pn] > diffCount do diffIndex[self.pn] = diffIndex[self.pn] - diffCount end
		while diffIndex[self.pn] < 1 do diffIndex[self.pn] = diffIndex[self.pn] + diffCount end
		CurDiff[self.pn] = Diffs[diffIndex[self.pn]]
		self:queuecommand('SetDifficulty')
	end
end

local SuperActor = LoadModule('Konko.SuperActor.lua')


local af = SuperActor.new('ActorFrame')
for k in pairs(plrs) do
	local diffAF = SuperActor.new('ActorFrame')
	local backPanel = SuperActor.new('Quad')
	local meterPanel = SuperActor.new('Quad')
	local meterText = SuperActor.new('BitmapText')
	local diffText = SuperActor.new('BitmapText')
	local diffTitle = SuperActor.new('BitmapText')
	local diffInfo = SuperActor.new('ActorFrame')
	local diffScore = SuperActor.new('BitmapText')

	do backPanel
		:SetCommand('Init', function(self)
			self
				:SetSize(SH * 0.65, 96)
				:addx(SCY * 0.15)
				:diffuse(ColorDarkTone(ThemeColor[ToEnumShortString(k)]))
				:diffusealpha(0.5)
				:skewx(-0.5)
		end)
	end

	do meterPanel
		:SetCommand('Init', function(self)
			self
				:SetSize(128, 96)
				:addx(-SCY * 0.6)
				:skewx(-0.5)
		end)
		:SetMessage('CurrentSteps'..ToEnumShortString(k)..'Changed', function(self)
			
		end)
	end

	do diffAF
		:SetCommand('Init', function(self)
			self:zoom(1.5):addy(20)
		end)
		:SetCommand('On', function(self)
			local y = (plrs[PLAYER_1] and plrs[PLAYER_2]) and 100 or 0
			self
				:addx(PositionPerPlayer(k, y * 0.5, y * -0.5))
				:addy(PositionPerPlayer(k, -y, y))
				:visible(plrs[k])
		end)
		:AddChild(backPanel, 'BackPanel')
	end

	af:AddChild(diffAF, 'Difficulty'..ToEnumShortString(k))
end

do af
	:SetCommand('Init', function(self)
		self:Center():addy(SH)
	end)
	:SetCommand('On', function(self)
		self
			:finishtweening()
			:easeoutexpo(0.25)
			:y(SCY)
		SCREENMAN:GetTopScreen():AddInputCallback(function(event)
			if not plrs[event.PlayerNumber] then return end
			TF_WHEEL.Input(self)(event)
		end)
	end)
	:SetCommand('DiffCancel', function(self)
		SCREENMAN:GetTopScreen():Cancel()
	end)
	:SetCommand('Back', function(self)
		MESSAGEMAN:Broadcast('SongUnselect')
		self
			:easeinexpo(0.25)
			:addy(SH)
			:queuecommand('DiffCancel')
	end)
	:AddToTree('DifficultyFrame')
end

return SuperActor.GetTree()
