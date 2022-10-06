local konko = LoadModule('Konko.Core.lua')
konko()

local ThemeColor = LoadModule('Theme.Colors.lua')
local SuperActor = LoadModule('Konko.SuperActor.lua')

local plrs = {
	[PLAYER_1] = false,
	[PLAYER_2] = false,
}
for k in pairs(plrs) do
	plrs[k] = GAMESTATE:IsSideJoined(k)
end
local PlayerReady = {
	[PLAYER_1] = false,
	[PLAYER_2] = false,
}

Index = Index or {}
Index.Diff = Index.Diff or {
	[PLAYER_1] = 1,
	[PLAYER_2] = 1,
}

local CurSong = GAMESTATE:GetCurrentSong()
local DiffLoader = LoadModule('Wheel/Difficulty.Sort.lua')
local AllDiffs = DiffLoader(CurSong)
local CurDiff = {
	[PLAYER_1] = AllDiffs[1],
	[PLAYER_2] = AllDiffs[1],
}

local function MoveDifficulty(self, offset, Diffs)
	local diffCount = #Diffs
	if plrs[self.pn] then
		Index.Diff[self.pn] = Index.Diff[self.pn] + offset
		while Index.Diff[self.pn] > diffCount do Index.Diff[self.pn] = Index.Diff[self.pn] - diffCount end
		while Index.Diff[self.pn] < 1 do Index.Diff[self.pn] = Index.Diff[self.pn] + diffCount end
		CurDiff[self.pn] = Diffs[Index.Diff[self.pn]]
		self:queuecommand('SetDifficulty'..ToEnumShortString(self.pn))
	end
end

local af = SuperActor.new('ActorFrame')
for k in pairs(plrs) do

	local PN = ToEnumShortString(k)

	local diffAF = SuperActor.new('ActorFrame')
	local backPanel = SuperActor.new('Quad')
	local meterPanel = SuperActor.new('Quad')
	local meterText = SuperActor.new('BitmapText')
	local diffText = SuperActor.new('BitmapText')
	local diffTitle = SuperActor.new('BitmapText')
	local diffInfo = SuperActor.new('ActorFrame')
	local diffScore = SuperActor.new('BitmapText')
	local diffAward = SuperActor.new('BitmapText')
	local readyText = SuperActor.new('BitmapText')

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
		:SetCommand('On', function(self)
			self:diffuse(ThemeColor[ToEnumShortString(CurDiff[k]:GetDifficulty())])
		end)
		:SetCommand('SetDifficulty'..PN, function(self)
			self
				:stoptweening()
				:easeoutsine(0.1)
				:diffuse(ThemeColor[ToEnumShortString(CurDiff[k]:GetDifficulty())])
		end)
	end

	do meterText
		:SetAttribute('Font', 'Common Large')
		:SetCommand('Init', function(self)
			self:addx(-SCY * 0.6 + 3):addy(-12)
		end)
		:SetCommand('On', function(self)
			local meter = math.floor(CurDiff[k]:GetMeter() * 10) * 0.1
			self:settext(meter)
		end)
		:SetCommand('SetDifficulty'..PN, function(self)
			local meter = math.floor(CurDiff[k]:GetMeter() * 10) * 0.1
			self:settext(meter)
		end)
	end

	do diffText
		:SetAttribute('Font', 'Common Normal')
		:SetCommand('Init', function(self)
			self
				:zoom(0.75)
				:addx(-SCY * 0.6 - 12)
				:addy(24)
		end)
		:SetCommand('On', function(self)
			self:settext(THEME:GetString('CustomDifficulty', ToEnumShortString(CurDiff[k]:GetDifficulty())))
		end)
		:SetCommand('SetDifficulty'..PN, function(self)
			self:settext(THEME:GetString('CustomDifficulty', ToEnumShortString(CurDiff[k]:GetDifficulty())))
		end)
	end

	do diffTitle
		:SetCommand('Init', function(self)
			self
				:valign(1)
				:addy(-60)
				:zoom(0.6)
		end)
		:SetCommand('SetDifficulty'..PN, function(self)
			local title = CurDiff[k]:GetChartName()
			if title == '' then title = THEME:GetString('CustomDifficulty', ToEnumShortString(CurDiff[k]:GetDifficulty())) end
			self
				:settext(title)
				:stoptweening()
				:cropright(1)
				:linear(0.05)
				:cropright(0)
		end)
	end

	do diffScore
		:SetCommand('Init', function(self)
			self
				:halign(1)
				:valign(1)
				:addx(300)
				:addy(-60)
				:zoom(0.6)
		end)
		:SetCommand('SetDifficulty'..PN, function(self)
			self:settext('')
			local prof = (PROFILEMAN:IsPersistentProfile(k) and PROFILEMAN:GetProfile(k)) or PROFILEMAN:GetMachineProfile()
			local scorelist = prof:GetHighScoreListIfExists(CurSong, CurDiff[k])
			if scorelist then
				-- TODO: Check for timing windows before choosing the score to display. ~Sudo
				local highscore = scorelist:GetHighScores()[1]
				if not highscore then return end
				self:settext(FormatPercentScore(highscore:GetPercentDP()))
			end
			self
				:stoptweening()
				:cropright(1)
				:sleep(0.05)
				:linear(0.05)
				:cropright(0)
		end)
	end

	do diffAward
		:SetCommand('Init', function(self)
			self
				:halign(1)
				:valign(1)
				:addx(240)
				:addy(-60)
				:zoom(0.6)
		end)
		:SetCommand('SetDifficulty'..PN, function(self)
			self:settext('')
			local prof = (PROFILEMAN:IsPersistentProfile(k) and PROFILEMAN:GetProfile(k)) or PROFILEMAN:GetMachineProfile()
			local scorelist = prof:GetHighScoreListIfExists(CurSong, CurDiff[k])
			if scorelist then
				local highscore = scorelist:GetHighScores()[1]
				if not highscore then return end
				local award = highscore:GetStageAward()
				if not award then return end
				if not award:find('Percent') then
					award = ToEnumShortString(award)
					local fc = award:sub(award:find('W'), -1)
					self:settext('FC'):diffuse(ThemeColor[fc]):diffusebottomedge(ColorDarkTone(ThemeColor[fc]))
				end
			end
			self
				:stoptweening()
				:cropright(1)
				:linear(0.05)
				:cropright(0)
		end)
	end

	for i, v in ipairs {
		'Author', 'Taps', 'Holds', 'Rolls',
		'Style', 'Jumps', 'Hands', 'Lifts',
		'Info',			  'Fakes', 'Mines',
	} do
		local text = SuperActor.new('BitmapText')
		do text
			:SetAttribute('Font', 'Common Normal')
			:SetCommand('Init', function(self)
				self
					:halign(0)
					:valign(0.25)
					:zoom(0.5)
					:xy(-10 * math.floor((i - 1) / 4) + ((i - 1) % 4) * 90, math.floor((i - 1) / 4) * 24)
				if i % 4 == 1 then
					self:addx(-15)
				else
					self:addx(15)
				end
				if i > 9 then self:addx(90) end
			end)
			:SetCommand('SetDifficulty'..PN, function(self)
				local newln = ''
				local datum = ''
				local chart = CurDiff[k]
				if i % 4 == 1 then
					newln = '\n   '
					if v == 'Author' then
						datum = chart:GetAuthorCredit()
					elseif v == 'Style' then
						datum = THEME:GetString('LongStepsType', ToEnumShortString(chart:GetStepsType()))
					elseif v == 'Info' then
						datum = chart:GetDescription()
					end
				else
					local radar = CurDiff[k]:GetRadarValues(k)
					local map = {
						Taps = 6,
						Holds = 9,
						Rolls = 12,
						Jumps = 8,
						Hands = 11,
						Lifts = 13,
						Fakes = 14,
						Mines = 10,
					}
					datum = radar:GetValue(RadarCategory[map[v]])
				end
				self
					:stoptweening()
					:settext(v..': '..newln..datum)
					:cropright(1)
					:sleep(i * 0.01)
					:linear(0.05)
					:cropright(0)
			end)
		end
		diffInfo:AddChild(text, v)
	end

	do diffInfo
		:SetCommand('Init', function(self)
			self
				:halign(0)
				:valign(0)
				:xy(-SCY * 0.3, -30)
		end)
	end

	do readyText
		:SetAttribute('Font', 'Common Large')
		:SetAttribute('Text', 'Ready')
		:SetCommand('Init', function(self)
			self
				:bob()
				:effectmagnitude(0, 2, 0)
				:shadowlength(2, 2)
				:diffuse(color('#FFFF9900'))
		end)
		:SetCommand('Ready'..PN, function(self)
			self
				:stoptweening()
				:zoom(2)
				:diffusealpha(0)
				:glow(1, 1, 1, 1)
				:easeoutexpo(0.25)
				:zoom(1)
				:diffusealpha(1)
				:glow(1, 1, 1, 0.5)
		end)
		:SetCommand('NotReady'..PN, function(self)
			self
				:stoptweening()
				:zoom(1)
				:diffusealpha(1)
				:glow(1, 1, 1, 0.5)
				:easeoutsine(0.1)
				:zoom(0.9)
				:diffusealpha(0)
				:glow(1, 1, 1, 0)
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
		:AddChild(meterPanel, 'MeterPanel')
		:AddChild(meterText, 'Meter')
		:AddChild(diffText, 'DiffName')
		:AddChild(diffTitle, 'DiffTitle')
		:AddChild(diffScore, 'DiffScore')
		:AddChild(diffAward, 'DiffAward')
		:AddChild(diffInfo, 'DiffInfo')
		:AddChild(readyText, 'ReadyText')
	end

	af:AddChild(diffAF, 'Difficulty'..PN)
end

do af
	:SetCommand('Init', function(self)
		self:Center():addy(SH)
	end)
	:SetCommand('On', function(self)
		self
			:finishtweening()
			:sleep(0.25)
			:easeoutexpo(0.25)
			:y(SCY)
		SCREENMAN:GetTopScreen():AddInputCallback(function(event)
			if not plrs[event.PlayerNumber] then return end
			TF_WHEEL.Input(self)(event)
		end)
		for k in pairs(plrs) do
			self.pn = k
			MoveDifficulty(self, 0, AllDiffs)
		end
	end)
	:SetCommand('Off', function(self)
		for pn in ivalues(GAMESTATE:GetHumanPlayers()) do
			if PROFILEMAN:GetProfile(pn) then PROFILEMAN:SaveProfile(pn) end
			if  plrs[PLAYER_1] and plrs[PLAYER_2] then
				GAMESTATE:SetCurrentStyle('versus')
			elseif CurDiff[pn]:GetStepsType():lower():find('double') then
				GAMESTATE:SetCurrentStyle('double')
			else
				local type = CurDiff[pn]:GetStepsType()
				GAMESTATE:SetCurrentStyle(type:sub(1 - type:reverse():find('_'), -1))
			end
			GAMESTATE:SetCurrentSteps(pn, CurDiff[pn])
		end
		if not PROFILEMAN:GetProfile(PLAYER_1) and not PROFILEMAN:GetProfile(PLAYER_2) then
			PROFILEMAN:SaveMachineProfile()
		end
		SCREENMAN:GetTopScreen():lockinput(0.25)
		self
			:finishtweening()
			:easeinexpo(0.25)
			:addy(SH)
			:queuecommand('DiffCancel')
	end)
	:SetMessage('CurrentSongChanged', function(self)
		for k in pairs(plrs) do
			self.pn = k
			MoveDifficulty(self, 0, AllDiffs)
		end
	end)
	:SetCommand('DiffCancel', function(self)
		SCREENMAN:GetTopScreen():Cancel()
	end)
	:SetCommand('MenuLeft', function(self)
		if PlayerReady[self.pn] then return end
		MoveDifficulty(self, -1, AllDiffs)
	end)
	:SetCommand('MenuRight', function(self)
		if PlayerReady[self.pn] then return end
		MoveDifficulty(self, 1, AllDiffs)
	end)
	:SetCommand('MenuDown', function(self)
		self:stoptweening():playcommand('Off')
		SCREENMAN:GetTopScreen():queuemessage('EnterOptions', CurDiff)
	end)
	:SetCommand('Back', function(self)
		if (plrs[PLAYER_1] and plrs[PLAYER_2]) then
			if PlayerReady[self.pn] then
				PlayerReady[self.pn] = false
				self:queuecommand('NotReady'..ToEnumShortString(self.pn))
			elseif not (PlayerReady[PLAYER_1] or PlayerReady[PLAYER_2]) then
				PlayerReady[PLAYER_1] = false
				PlayerReady[PLAYER_2] = false
				MESSAGEMAN:Broadcast('SongUnselect')
				self
					:easeinexpo(0.25)
					:addy(SH)
					:queuecommand('DiffCancel')
			end
		else
			MESSAGEMAN:Broadcast('SongUnselect')
			self
				:easeinexpo(0.25)
				:addy(SH)
				:queuecommand('DiffCancel')
		end
	end)
	:SetCommand('Start', function(self)
		if (plrs[PLAYER_1] and plrs[PLAYER_2]) then
			if not PlayerReady[self.pn] then
				PlayerReady[self.pn] = true
				self:queuecommand('Ready'..ToEnumShortString(self.pn))
			elseif PlayerReady[PLAYER_1] and PlayerReady[PLAYER_2] then
				SOUND:PlayOnce(THEME:GetPathS('Common', 'Start'), true)
				self:stoptweening():playcommand('Off')
				SCREENMAN:GetTopScreen():queuemessage('EnterGameplay', CurDiff)
			end
		else
			SOUND:PlayOnce(THEME:GetPathS('Common', 'Start'), true)
			self:stoptweening():playcommand('Off')
			SCREENMAN:GetTopScreen():queuemessage('EnterGameplay', CurDiff)
		end
	end)
	:AddToTree('DifficultyFrame')
end

local diffControl = SuperActor.new('ActorFrame')
do diffControl
	:SetCommand('Init', function(self)
		self:xy(SL + 20, SB - 80):diffusealpha(0)
	end)
	:SetCommand('On', function(self)
		self:sleep(0.5):linear(0.1):diffusealpha(1)
	end)
	:SetMessage('SongUnselect', function(self)
		self:linear(0.1):diffusealpha(0)
	end)
	:AddChild(
		SuperActor.new('Quad')
			:SetCommand('Init', function(self)
				self:halign(0.25):valign(1)
					:SetSize(480, 100)
					:y(20)
					:diffuse(0, 0, 0, 0.75)
					:skewx(-0.5)
			end)
	)
	:AddChild(
		SuperActor.new('BitmapText')
			:SetAttribute('Font', 'Common Normal')
			:SetAttribute('Text', '&LEFT;&RIGHT;: Change Difficulty\n&DOWN;: Go to Player Options\n&START;: Select Difficulty\n&SELECT;: Switch to Song')
			:SetCommand('Init', function(self)
				self:halign(0):y(-30)
			end)
	)
	:AddToTree('DiffControl')
end

return SuperActor.GetTree()
