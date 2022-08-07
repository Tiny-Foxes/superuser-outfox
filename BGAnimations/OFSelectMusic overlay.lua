-- TODO: Finalize and refactor the hell out of this bullshit. ~Sudo

local ThemeColor = LoadModule('Theme.Colors.lua')

local wheel = Def.ActorFrame { Name = 'Wheel' }

SU_Wheel = SU_Wheel or {}
SU_Wheel.Players = SU_Wheel.Players or GAMESTATE:GetEnabledPlayers()
SU_Wheel.MainPlayer = SU_Wheel.MainPlayer or GAMESTATE:GetMasterPlayerNumber()

if not GAMESTATE:IsSideJoined(SU_Wheel.MainPlayer) then GAMESTATE:JoinPlayer(SU_Wheel.MainPlayer) end
for _, v in ipairs(SU_Wheel.Players) do
	if not GAMESTATE:IsSideJoined(v) and v ~= SU_Wheel.MainPlayer then GAMESTATE:JoinPlayer(v) end
end
GAMESTATE:LoadProfiles()


local SongActor = LoadActorWithParams(THEME:GetPathG('MusicWheelItem', 'Song NormalPart'), {})
local GroupActor = LoadActorWithParams(THEME:GetPathG('MusicWheelItem', 'SectionExpanded NormalPart'), {})

local function BothSidesJoined()
	return (GAMESTATE:IsSideJoined(PLAYER_1) and GAMESTATE:IsSideJoined(PLAYER_2))
end

--GAMESTATE:SetCurrentPlayMode('PlayMode_Regular')
if BothSidesJoined() then
	if GAMESTATE:GetCurrentGame():GetName() == 'taiko' then
		GAMESTATE:SetCurrentStyle('taiko-versus')
	else
		GAMESTATE:SetCurrentStyle('versus')
	end
else
	if GAMESTATE:GetCurrentGame():GetName() == 'taiko' then
		GAMESTATE:SetCurrentStyle('taiko-single')
	elseif GAMESTATE:GetCurrentGame():GetName() == 'kbx' then
		GAMESTATE:SetCurrentStyle('single4')
	else
		GAMESTATE:SetCurrentStyle('single')
	end
end
local profile = PROFILEMAN:GetMachineProfile()
if SU_Wheel.MainPlayer then
	profile = PROFILEMAN:GetProfile(SU_Wheel.MainPlayer)
end

SU_Wheel.AllSongs = SONGMAN:GetAllSongs()

local Groups, Songs, Diffs = {}, {}, {}

local GrabGroups, GrabSongs, GrabDiffs = LoadModule('Wheel/Songs.Grabber.lua', SU_Wheel.AllSongs)


if GAMESTATE:IsCourseMode() then
	--if tostring(SU_Wheel.CurSong):find('Song') then SU_Wheel.CurSong = nil end
	SU_Wheel.CurSong = SU_Wheel.CurSong or profile:GetLastPlayedCourse() or SU_Wheel.AllSongs[1]
else
	--if tostring(SU_Wheel.CurSong):find('Course') then SU_Wheel.CurSong = nil end
	SU_Wheel.CurSong = SU_Wheel.CurSong or profile:GetLastPlayedSong() or SU_Wheel.AllSongs[1]
end


local games = {
	'dance',
	'pump',
	'kbx',
}
local function InputHandler(event)
	if event.type ~= 'InputEventType_Release' then
		if event.PlayerNumber then
			MESSAGEMAN:Broadcast(event.GameButton, event)
		else
			for i, v in ipairs(games) do
				if event.DeviceInput.button:find(tostring(i)) then
					SU_Wheel.Players = GAMESTATE:GetEnabledPlayers()
					SU_Wheel.MainPlayer = GAMESTATE:GetMasterPlayerNumber()
					--GAMEMAN:SetGame(v, THEME:GetCurThemeName())
				end
			end
		end
	end
end


Groups = GrabGroups()
Groups.Index = 1
for i = 1, #Groups do
	if SU_Wheel.CurSong:GetGroupName() == Groups[i] then
		Groups.Index = i
		break
	end
end
Groups.Active = 'Song'
Groups.Last = 'Groups'
Groups.Loop = false
Songs = GrabSongs(Groups[Groups.Index])
Songs.Index = 1
for i = 1, #Songs do
	if SU_Wheel.CurSong == Songs[i] then
		Songs.Index = i
		break
	end
end
Diffs = GrabDiffs(Songs[Songs.Index])


local folderList = Def.ActorScroller {
	Name = 'Groups',
	UseScroller = true,
	SecondsPerItem = 0,
	NumItemsToDraw = 9,
	ItemPaddingStart = 0,
	ItemPaddingEnd = 0,
	TransformFunction = function(self, offset, itemIndex, numItems)
		self:xy(offset * -48, offset * 96)
		if offset > -1 and offset < 1 then
			self
				:zoom( 1.5 + (0.5 - math.abs(offset * 0.5)) )
				:x( (offset * -48) + (80 - (math.abs(offset * 80))) )
		else
			self:zoom(1.5)
		end
	end,
	InitCommand = function(self)
		self
			:xy(SCREEN_LEFT + 210, SCREEN_CENTER_Y)
			:SetLoop(Groups.Loop)
			:SetFastCatchup(true)
			:aux(1)
	end,
	OnCommand = function(self)
		self:queuecommand('StartUpdate')
	end,
	StartUpdateCommand = function(self)
		self:luaeffect('Update')
	end,
	UpdateCommand = function(self)
		for i = 1, self:GetNumChildren() do
			self:GetChildAt(i):GetWrapperState(1):x(0)
		end
		local idx = 1
		if not Groups.Loop then
			idx = Groups.Index
			if Groups.Index > 5 then idx = 5 end
		else
			idx = 5
			if self:GetNumChildren() < 5 then
				idx = self:GetNumChildren()
			end
		end
		self:SetCurrentAndDestinationItem(self:getaux() - 1)
		self:GetChildAt(idx):GetWrapperState(1):x(-self:GetParent():GetX())
	end,
}

local folderSongs = {}

for i, group in ipairs(Groups) do
	local groupSongs = GrabSongs(group)
	local actor = GroupActor .. {
		InitCommand = function(self)
			for i = 1, self:GetNumWrapperStates() do
				self:RemoveWrapperState(i)
			end
			self:AddWrapperState()
		end,
	}
	actor[#actor + 1] = Def.BitmapText {
		Font = 'Common Large',
		Text = group,
		InitCommand = function(self)
			self
				:maxwidth(560)
				:zoom(0.5)
		end,
	}
	folderList[#folderList + 1] = actor
	local songList = Def.ActorScroller {
		Name = 'Songs'..i,
		UseScroller = true,
		SecondsPerItem = 0,
		NumItemsToDraw = 9,
		ItemPaddingStart = 0,
		ItemPaddingEnd = 0,
		TransformFunction = function(self, offset, itemIndex, numItems)
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
		end,
		CurrentSongChangedMessageCommand = function(self)
			self:visible(Groups[Groups.Index] == group)
		end,
		InitCommand = function(self)
			self
				:xy(SCREEN_RIGHT - 210, SCREEN_CENTER_Y)
				:SetLoop(Groups.Loop)
				:SetFastCatchup(true)
				:aux(1)
		end,
		OnCommand = function(self)
			self:queuecommand('StartUpdate')
		end,
		StartUpdateCommand = function(self)
			self:luaeffect('Update')
		end,
		UpdateCommand = function(self)
			for i = 1, self:GetNumChildren() do
				self:GetChildAt(i):GetWrapperState(1):x(0)
			end
			local idx = 1
			if not Groups.Loop then
				idx = Songs.Index
				if Songs.Index > 5 then idx = 5 end
			else
				idx = 5
				if self:GetNumChildren() < 5 then
					idx = self:GetNumChildren()
				end
			end
			self:SetCurrentAndDestinationItem(self:getaux() - 1)
			self:GetChildAt(idx):GetWrapperState(1):x(-self:GetParent():GetX())
		end,
	}
	for i, song in ipairs(groupSongs) do
		local actor = SongActor .. {
			Name = 'Song'..i,
			InitCommand = function(self)
				for i = 1, self:GetNumWrapperStates() do
					self:RemoveWrapperState(i)
				end
				self:AddWrapperState()
			end,
		}
		actor[#actor + 1] = Def.BitmapText {
			Font = 'Common Large',
			Text = song:GetDisplayFullTitle(),
			InitCommand = function(self)
				self
					:maxwidth(560)
					:zoom(0.5)
			end,
		}
		actor[#actor + 1] = Def.BitmapText {
			Font = 'Common Normal',
			InitCommand = function(self)
			end,
		}
		-- Currently, this causes massive performance issues.
		-- This requires a refactor to work properly.
		--[[
		local charts = GrabDiffs(song, true)
		for i, chart in ipairs(charts) do
			local pip = Def.ActorFrame {
				Name = 'Diff'..i,
				InitCommand = function(self)
					self
						:valign(0)
						:xy(-150, -20)
						:addx(i * 20)
					if chart:GetStepsType():lower():find('_double') then
						self:addx(10)
						self:visible(SU_Wheel.IncludeDoubles())
					end
				end,
				ChangeDifficultyCommand = function(self)
					if chart:GetStepsType():lower():find('_double') then
						self:visible(SU_Wheel.IncludeDoubles())
					end
				end,
				Def.Quad {
					InitCommand = function(self)
						self
							:SetSize(16, 12)
							:skewx(-0.5)
							:diffuse(ThemeColor[chart:GetDifficulty():sub(chart:GetDifficulty():find('_') + 1, -1)] or color('#080808'))
							if chart:IsAutogen() then self:diffusebottomedge(ThemeColor.Pink) end
					end
				}
			}
			if chart:GetStepsType():lower():find('_double') then
				pip[#pip + 1] = Def.BitmapText {
					Font = 'Common Normal',
					Text = 'D',
					InitCommand = function(self)
						self:zoom(0.5):xy(1, -1)
					end,
				}
			end
			actor[#actor + 1] = pip
		end
		--]]
		songList[#songList + 1] = actor
	end

	folderSongs[#folderSongs + 1] = songList
end

local f = Def.ActorFrame {
	Name = 'SongTab',
	Def.ActorFrame {
		Name = 'ControlsFrame',
		InitCommand = function(self)
			self:xy(SCREEN_LEFT + 20, SCREEN_BOTTOM - 80)
		end,
		Def.Quad {
			InitCommand = function(self)
				self:halign(0.25):valign(1)
				self
					:SetSize(480, 100)
					:y(20)
					:diffuse(color('#00000080'))
					:skewx(-0.5)
			end,
		},
		Def.BitmapText {
			Font = 'Common Normal',
			Text = '&LEFT;&RIGHT;: Change Selection\n&DOWN;&UP;: Change Wheel',
			InitCommand = function(self)
				self:halign(0):y(-30)
			end,
		}
	}
}
for _, v in ipairs(folderSongs) do
	f[#f + 1] = v
end
wheel[#wheel + 1] = f

wheel[#wheel + 1] = Def.Quad {
	Name = 'GroupDim',
	InitCommand = function(self)
		self
			:FullScreen()
			:diffuse(color('#00000000'))
	end,
}

wheel[#wheel + 1] = Def.ActorFrame {
	Name = 'GroupTab',
	folderList,
}

wheel[#wheel + 1] = Def.Quad {
	Name = 'DifficultyDim',
	InitCommand = function(self)
		self
			:FullScreen()
			:diffuse(color('#00000000'))
	end,
}

wheel[#wheel + 1] = Def.ActorFrame {
	Name = 'PreviewFrame',
	OnCommand = function(self)
		--self:AddChildFromPath(THEME:GetPathG('Players', 'preview'))
		self:y(SCREEN_HEIGHT)
	end,
	ChangeFocusCommand = function(self, params)
		if params.element == 'Difficulty' then
			self:finishtweening():easeinoutexpo(0.5):y(0)
		else
			self:finishtweening():easeinoutexpo(0.5):y(SCREEN_HEIGHT)
		end
	end,
	--[[
	ApplyModsMessageCommand = function(self, params)
		local nf = self:GetChild('Preview')
			:GetChild('PreviewAFT')
			:GetChild('PlayerFrame')
			:GetChild('Player'..pname(params.pn))
			:GetChild('NoteField')

		if params.modstring then nf:ModsFromString(params.modstring) end
		if params.noteskin then nf:GetPlayerOptions('ModsLevel_Current'):NoteSkinCol(nil, params.noteskin) end
	end,
	--]]
}

local diffTab = Def.ActorFrame {
	Name = 'DifficultyTab',
	InitCommand = function(self)
		self:x(SCREEN_WIDTH)
	end,
	Def.ActorFrame {
		Name = 'ControlsFrame',
		InitCommand = function(self)
			self:xy(SCREEN_RIGHT - 20, SCREEN_TOP + 120)
		end,
		Def.Quad {
			InitCommand = function(self)
				self:halign(0.75):valign(1)
				self
					:SetSize(480, 100)
					:y(20)
					:diffuse(color('#00000080'))
					:skewx(-0.5)
			end,
		},
		Def.BitmapText {
			Font = 'Common Normal',
			Text = '&LEFT;&RIGHT;: Change Selection\n&UP;: Show/Hide Doubles\n&DOWN;: Player Options',
			InitCommand = function(self)
				self:halign(0):xy(-320, -30)
			end,
		}
	}
}

for pn = 1, 2 do
	local diff = Def.ActorFrame {
		Name = 'DifficultyP'..pn,
		InitCommand = function(self)
			self:Center():zoom(1.5):aux(1):addy(20)
			self:GetChild('BackFrame')
				:SetSize(SCREEN_HEIGHT * 0.65, 96)
				:addx(SCREEN_CENTER_Y * 0.15)
				:diffuse(0, 0, 0, 0.5)
				:skewx(-0.5)
			self:GetChild('MeterFrame')
				:SetSize(128, 96)
				:addx(-SCREEN_CENTER_Y * 0.6)
				:skewx(-0.5)
			self:GetChild('Meter'):addx(-SCREEN_CENTER_Y * 0.6 + 3):addy(-12)
			self:GetChild('DiffName'):zoom(0.75):addx(-SCREEN_CENTER_Y * 0.6 - 12):addy(24)
			self:GetChild('DiffTitle'):valign(1):addy(-60):zoom(0.5)
			self:visible(GAMESTATE:IsSideJoined(PlayerNumber[pn]))
		end,
		OnCommand = function(self)
			local y = (GAMESTATE:IsSideJoined(PLAYER_1) and GAMESTATE:IsSideJoined(PLAYER_2)) and 100 or 0
			self:addy(PositionPerPlayer(PlayerNumber[pn], -y, y))
			self:addx(PositionPerPlayer(PlayerNumber[pn], y * 0.5, -y * 0.5))
		end,
		SetDifficultyCommand = function(self, params)
			for i = 1, self:GetChild('Data'):GetNumChildren() do
				local datum = self:GetChild('Data'):GetChildAt(i)
				local newln = ''
				if datum:GetName() == 'Author' or datum:GetName() == 'Style' or datum:GetName() == 'Info' then
					newln = '\n   '
				end
				datum
					:stoptweening()
					:settext(datum:GetName()..': '..newln..params.data[datum:GetName():lower()])
				if #Diffs > 1 then
					datum
						:stoptweening()
						:cropright(1)
						:sleep(i * 0.01)
						:linear(0.05)
						:cropright(0)
				end
			end
			self:GetChild('Meter'):settext(params.meter)
			self:GetChild('DiffName'):settext(params.name)
			self:GetChild('DiffTitle'):settext(params.title ~= '' and params.title or params.name)
				:stoptweening()
				:cropright(1)
				:linear(0.05)
				:cropright(0)
			self:GetChild('MeterFrame')
				:stoptweening()
				:easeinoutsine(params.time)
				:diffuse(ThemeColor[params.difficulty])
		end,
		Def.Quad { Name = 'BackFrame' },
		Def.Quad { Name = 'MeterFrame' },
		Def.BitmapText { Font = 'Common Large', Name = 'Meter' },
		Def.BitmapText { Font = 'Common Normal', Name = 'DiffName' },
		Def.BitmapText { Font = 'Common Large', Name = 'DiffTitle' },
	}
	local info = Def.ActorFrame {
		Name = 'Data',
		InitCommand = function(self)
			self:halign(0):valign(0)
			self:xy(-SCREEN_CENTER_Y * 0.3, -30)
		end,
	}
	for i, v in ipairs {
		'Author', 'Taps', 'Holds', 'Rolls',
		'Style', 'Jumps', 'Hands', 'Lifts',
		'Info', 		  'Fakes', 'Mines',
	} do
		info[#info + 1] = Def.BitmapText {
			Name = v,
			Font = 'Common Normal',
			InitCommand = function(self)
				self:halign(0)
				self:valign(0.25)
				self:zoom(0.5)
				self:settext(v..': ???')
				self:xy(-10 * math.floor((i - 1) / 4) + ((i - 1) % 4) * 90, math.floor((i - 1) / 4) * 24)
				if i == 1 or i == 5 or i == 9 then
					self:addx(-15)
				else
					self:addx(15)
				end
				if i > 9 then self:addx(90) end
			end,
		}
	end
	diff[#diff + 1] = info
	diff[#diff + 1] = Def.BitmapText {
		Font = 'Common Large',
		InitCommand = function(self)
			self:halign(1):valign(1):xy(290, -60):zoom(0.5)
		end,
		SetDifficultyCommand = function(self, params)
			self
				:stoptweening()
				:cropright(1)
				:settext('')
			local aux = self:GetParent():getaux()
			local diff = Diffs[aux]
			if not diff then return end
			local prof = PROFILEMAN:GetProfile(PlayerNumber[pn]) or PROFILEMAN:GetMachineProfile()
			local scorelist = prof:GetHighScoreListIfExists(SU_Wheel.CurSong, diff)
			if not scorelist then return end
			local score = scorelist:GetHighScores()[1]
			if not score then return end
			self
				:sleep(0.1)
				:settext(PrettyPercent(score:GetPercentDP(), 1))
				:linear(0.05)
				:cropright(0)
		end
	}
	diffTab[#diffTab + 1] = diff
end

wheel[#wheel + 1] = diffTab


wheel[#wheel + 1] = Def.Quad {
	Name = 'OptionsDim',
	InitCommand = function(self)
		self
			:FullScreen()
			:diffuse(color('#00000000'))
			:cropleft(0.5)
			:fadeleft(0.1)
			:cropright(0.5)
			:faderight(0.1)
	end,
}

local InOptions = {false, false}
for pn = 1, 2 do
	local popRows = {
	}
	local popTab = Def.ActorFrame {
		Name = 'OptionsTabP'..pn,
		InitCommand = function(self)
			self:y(SCREEN_HEIGHT * 1.75)
		end,
		Def.ActorFrame {
			Name = 'Options',
			InitCommand = function(self)
				local x = 0
				if BothSidesJoined() then x = SCREEN_CENTER_X * 0.5 end
				self:x(PositionPerPlayer(PlayerNumber[pn], SCREEN_CENTER_X - x, SCREEN_CENTER_X + x))
				self:visible(GAMESTATE:IsSideJoined(PlayerNumber[pn]))
			end,
			ShowOptionsTabCommand = function(self, params)
				if Groups.Active == 'Difficulty' and params.pn == PlayerNumber[pn] then
					--[[
					InOptions[pn] = true
					if pn == 1 then
						self:GetParent():GetParent():GetChild('OptionsDim'):stoptweening():easeinoutexpo(0.2):cropleft(0)
					else
						self:GetParent():GetParent():GetChild('OptionsDim'):stoptweening():easeinoutexpo(0.2):cropright(0)
					end
					SOUND:PlayOnce(THEME:GetPathS('MusicWheel', 'collapse'))
					self:stoptweening():easeinoutexpo(0.4):y(-SCREEN_HEIGHT)
					--]]
					---[[
					SCREENMAN:GetTopScreen()
						--:RemoveInputCallback(InputHandler)
						:SetNextScreenName('ScreenPlayerOptions')
						:StartTransitioningScreen('SM_GoToNextScreen')
					--]]
				end
			end,
			HideOptionsTabCommand = function(self, params)
				if Groups.Active == 'Difficulty' and params.pn == PlayerNumber[pn] then
					InOptions[pn] = false
					if pn == 1 then
						self:GetParent():GetParent():GetChild('OptionsDim'):stoptweening():easeinoutexpo(0.2):cropleft(0.5)
					else
						self:GetParent():GetParent():GetChild('OptionsDim'):stoptweening():easeinoutexpo(0.2):cropright(0.5)
					end
					SOUND:PlayOnce(THEME:GetPathS('MusicWheel', 'collapse'), true)
					self:stoptweening():easeinoutexpo(0.4):y(0)
				end
			end,
			ChangeOptionsCommand = function(self)
			end,
			ConfirmSelectionCommand = function(self)
				-- TODO: Fill these with the actual code
				self:playcommand('HideOptionsTab', {pn = PlayerNumber[pn]})
			end,
			CancelSelectionCommand = function(self)
				-- TODO: Fill these with the actual code
				self:playcommand('HideOptionsTab', {pn = PlayerNumber[pn]})
			end,
			Def.ActorFrame {
				InitCommand = function(self)
					self:skewx(-0.5)
				end,
				Def.Quad {
					InitCommand = function(self)
						self
							:SetSize(360, SCREEN_HEIGHT * 0.25)
							:diffuse(color('#000000'))
							:diffusealpha(0.75)
					end,
				},
				Def.Quad {
					InitCommand = function(self)
						self
							:SetSize(360, SCREEN_HEIGHT * 0.125)
							:y(-46)
							:diffuse(PlayerColor(PlayerNumber[pn]))
							:diffusealpha(0.5)
					end,
				},
				Def.BitmapText {
					Name = 'OptionType',
					Font = 'Common Normal',
					Text = 'Option',
					InitCommand = function(self)
						self:y(-46):skewx(0.5)
					end,
				},
				Def.BitmapText {
					Name = 'OptionValue',
					Font = 'Common Normal',
					Text = 'Value1',
					InitCommand = function(self)
						self:y(46):skewx(0.5)
					end,
				}
			},
		}
	}

	wheel[#wheel + 1] = popTab

end

local function WheelSwap(self, input)
	if Groups.Active == 'Group' then
		self:playcommand('ChangeFocus', {element = 'Song'})
	elseif Groups.Active == 'Song' then
		self:playcommand('ChangeFocus', {element = 'Group'})
	end
	local pn = PlayerNumber:Reverse()[input.PlayerNumber] + 1
	if Groups.Active == 'Difficulty' then
		if input.button:find('Up') then
			if input.PlayerNumber == GAMESTATE:GetMasterPlayerNumber() then
				local doubs = SU_Wheel.IncludeDoubles()
				SU_Wheel.IncludeDoubles(not doubs)
				Diffs = GrabDiffs(SU_Wheel.CurSong)
				for pn = 1, 2 do
					self:playcommand('ChangeDifficulty', {pn = PlayerNumber[pn], direction = 0, time = 0.25})
				end
			end
		elseif not InOptions[pn] then
			self:playcommand('ShowOptionsTab', {pn = PlayerNumber[pn]})
		end
	else
		SOUND:PlayOnce(THEME:GetPathS('MusicWheel', 'collapse'), true)
	end
end
local function WheelUp(self, input)
	if not Groups.Loop then
		if Groups.Active == 'Group' then
			if #Groups == 1 then return end
		elseif Groups.Active == 'Song' then
			if #Songs == 1 then return end
		end
	end
	local pn = PlayerNumber:Reverse()[input.PlayerNumber] + 1
	if InOptions[pn] then
		self:playcommand('ChangeOptions', {pn = PlayerNumber[pn], direction = {-1, 0}, time = 0.25})
	else
		self:playcommand('Change'..Groups.Active, {pn = PlayerNumber[pn], direction = -1, time = 0.25})
	end
	if Groups.Active ~= 'Difficulty' then SOUND:PlayOnce(THEME:GetPathS('MusicWheel', 'change'), true) end
end
local function WheelDown(self, input)
	if not Groups.Loop then
		if Groups.Active == 'Group' then
			if #Groups == 1 then return end
		elseif Groups.Active == 'Song' then
			if #Songs == 1 then return end
		end
	end
	local pn = PlayerNumber:Reverse()[input.PlayerNumber] + 1
	if InOptions[pn] then
		self:playcommand('ChangeOptions', {pn = PlayerNumber[pn], direction = {1, 0}, time = 0.25})
	else
		self:playcommand('Change'..Groups.Active, {pn = PlayerNumber[pn], direction = 1, time = 0.25})
	end
	if Groups.Active ~= 'Difficulty' then SOUND:PlayOnce(THEME:GetPathS('MusicWheel', 'change'), true) end
end
local function Confirm(self, input)
	if Groups.Active == 'Group' then
		SOUND:PlayOnce(THEME:GetPathS('MusicWheel', 'collapse'), true)
		self:playcommand('ChangeFocus', {element = 'Song'})
	elseif Groups.Active == 'Song' then
		SOUND:PlayOnce(THEME:GetPathS('Common', 'Start'), true)
		self:playcommand('ChangeFocus', {element = 'Difficulty'})
	elseif Groups.Active == 'Difficulty' then
		local pn = PlayerNumber:Reverse()[input.PlayerNumber] + 1
		local options = self:GetChild('Wheel'):GetChild('OptionsTab'..ToEnumShortString(input.PlayerNumber)):GetChild('Options')
		if InOptions[pn] then
			options:playcommand('ConfirmSelection')
		else
			if #Diffs ~= 0 then
				SOUND:PlayOnce(THEME:GetPathS('Common', 'Start'), true)
				self:playcommand('EnterGameplay')
			else
				self:playcommand('ChartWarning')
			end
		end
	end
end
local function Cancel(self, input)
	if Groups.Active == 'Difficulty' then
		local pn = PlayerNumber:Reverse()[input.PlayerNumber] + 1
		local options = self:GetChild('Wheel'):GetChild('OptionsTab'..ToEnumShortString(input.PlayerNumber)):GetChild('Options')
		if InOptions[pn] then
			options:playcommand('CancelSelection')
		else
			self:GetChild('Wheel'):GetChild('OptionsTabP'..(pn + 1)):GetChild('Options'):playcommand('CancelSelection')
			SOUND:PlayOnce(THEME:GetPathS('Common', 'Cancel'), true)
			self:playcommand('ChangeFocus', {element = 'Song'})
		end
	elseif Groups.Active == 'Group' then
		SOUND:PlayOnce(THEME:GetPathS('MusicWheel', 'collapse'), true)
		self:playcommand('ChangeFocus', {element = 'Song'})
	elseif Groups.Active == 'Song' then
		SOUND:PlayOnce(THEME:GetPathS('Common', 'Cancel'), true)
		self:playcommand('EnterTitleMenu')
	end
end

local function Random(self, input)
	if Groups.Active == 'Group' then
		self:playcommand('ChangeGroup', {direction = math.random(-#Groups, #Groups), time = 0.5})
	elseif Groups.Active == 'Songs' then
		self:playcommand('ChangeSong', {direction = math.random(-#Songs, #Songs), time = 0.5})
	elseif Groups.Active == 'Difficulty' then
		self:playcommand('ChangeDifficulty', {pn = input.PlayerNumber, direction = math.random(-#Diffs, #Diffs), time = 0})
	end
end

local Controls = {
	MenuLeft = WheelUp,
	MenuRight = WheelDown,
	MenuUp = WheelSwap,
	MenuDown = WheelSwap,
	Start = Confirm,
	Back = Cancel,
}

local ret = Def.ActorFrame {
	Name = 'Overlay',
	OnCommand = function(self)
		SCREENMAN:GetTopScreen():AddInputCallback(InputHandler)
		self:playcommand('ChangeFocus', {element = 'Group', time = 0})
		local si = Songs.Index
		self:playcommand('ChangeGroup', {direction = 1, time = 0})
		self:playcommand('ChangeGroup', {direction = -1, time = 0})
		self:playcommand('ChangeFocus', {element = 'Song', time = 0})
		self:playcommand('ChangeSong', {direction = si, time = 0})
		self:playcommand('ChangeSong', {direction = -1, time = 0})
		for pn = 1, 2 do
			self:playcommand('ChangeDifficulty', {pn = PlayerNumber[pn], direction = 0, time = 0})
		end
	end,
	OffCommand = function(self)
		SCREENMAN:GetTopScreen():RemoveInputCallback(InputHandler)
	end,
	ChangeGroupCommand = function(self, params)
		Groups.Index = Groups.Index + params.direction
		if Groups.Index > #Groups then Groups.Index = Groups.Index - #Groups
		elseif Groups.Index < 1 then Groups.Index = Groups.Index + #Groups
		end
		Songs = GrabSongs(Groups[Groups.Index])
		Songs.Index = 1
		self:playcommand('ChangeSong', {direction = 0, time = 0})
		local folders = self:GetChild('Wheel'):GetChild('GroupTab'):GetChild('Groups')
		folders
			:stoptweening()
			:easeoutexpo(params.time)
			:aux(Groups.Index)
	end,
	ChangeSongCommand = function(self, params)
		Songs.Index = Songs.Index + params.direction
		if Songs.Index > #Songs then Songs.Index = Songs.Index - #Songs
		elseif Songs.Index < 1 then Songs.Index = Songs.Index + #Songs
		end
		SU_Wheel.CurSong = Songs[Songs.Index]
		if GAMESTATE:IsCourseMode() then
			GAMESTATE:SetCurrentCourse(SU_Wheel.CurSong)
		else
			GAMESTATE:SetCurrentSong(SU_Wheel.CurSong)
		end
		Diffs = GrabDiffs(SU_Wheel.CurSong)
		for pn = 1, 2 do
			if GAMESTATE:IsSideJoined(PlayerNumber[pn]) then
				self:playcommand('ChangeDifficulty', {pn = PlayerNumber[pn], direction = 1, time = 0})
				self:playcommand('ChangeDifficulty', {pn = PlayerNumber[pn], direction = -1, time = 0})
			end
		end
		local songs = self:GetChild('Wheel'):GetChild('SongTab'):GetChild('Songs' .. Groups.Index)
		songs
			:stoptweening()
			:easeoutexpo(params.time)
			:aux(Songs.Index)
		MESSAGEMAN:Broadcast('CurrentSongChanged')
	end,
	ChangeDifficultyCommand = function(self, params)
		local moving = true
		local diff = self:GetChild('Wheel'):GetChild('DifficultyTab'):GetChild('Difficulty'..ToEnumShortString(params.pn))
		if #Diffs == 0 then
			moving = false
			if diff:getaux() ~= 0 then
				print('No compatible chart found.')
				diff:playcommand('SetDifficulty', {
					pn = params.pn,
					difficulty = 'Black',
					name = 'Empty',
					title = '???',
					meter = '?',
					time = params.time,
					data = {
						author = '???',
						style = '???',
						info = 'No compatible chart found.',
						
						taps = '???',
						holds = '???',
						rolls = '???',
						jumps = '???',
						hands = '???',
						lifts = '???',
						fakes = '???',
						mines = '???',
					}
				})
			end
			diff:aux(0)
		else
			diff:addaux(params.direction)
			if diff:getaux() > #Diffs then
				moving = false
				diff:aux(#Diffs)
			elseif diff:getaux() < 1 then
				moving = false
				diff:aux(1)
			end
			local d = Diffs[diff:getaux()]
			if not d then
				while not d or not d:GetMeter() do
					diff:addaux(-1)
					if diff:getaux() < 1 then diff:aux(#Diffs) end
					d = Diffs[diff:getaux()]
				end
			end
			local diffstr = d:GetDifficulty()
			diffstr = diffstr:sub(diffstr:find('_') + 1, -1)
			local radar = d:GetRadarValues(params.pn)
			local data = {
				author = (GAMESTATE:IsCourseMode() and SU_Wheel.CurSong:GetScripter()) or d:GetAuthorCredit(),
				style = THEME:GetString('LongStepsType', ToEnumShortString(d:GetStepsType())),
				info = (GAMESTATE:IsCourseMode() and (
					'Includes '..#d:GetTrailEntries()..' Entries.'
				)) or d:GetDescription(),


				taps = radar:GetValue(RadarCategory[6]),
				holds = radar:GetValue(RadarCategory[9]),
				rolls = radar:GetValue(RadarCategory[12]),
				jumps = radar:GetValue(RadarCategory[8]),
				hands = radar:GetValue(RadarCategory[11]),
				lifts = radar:GetValue(RadarCategory[13]),
				fakes = radar:GetValue(RadarCategory[14]),
				mines = radar:GetValue(RadarCategory[10]),
			}
			if moving or #Diffs == 1 then
				diff:playcommand('SetDifficulty', {
					pn = params.pn,
					difficulty = diffstr,
					name = THEME:GetString('CustomDifficulty', ToEnumShortString(d:GetDifficulty())),
					title = d:GetChartName(),
					meter = math.floor(d:GetMeter() * 10) * 0.1,
					time = params.time,
					data = data
				})
				if Groups.Active == 'Difficulty' and #Diffs > 1 then SOUND:PlayOnce(THEME:GetPathS('Common', 'value'), true) end
			end
			if GAMESTATE:IsSideJoined(params.pn) then GAMESTATE:SetCurrentSteps(params.pn, d) end
		end
	end,
	ChangeFocusCommand = function(self, params)
		if not params.element then return end
		Groups.Last = Groups.Active
		Groups.Active = params.element
		if Groups.Active == 'Group' then
			self:GetChild("GroupInfoFrame")
				:stoptweening()
				:easeinoutexpo((params.time or 0.4))
				:x(SCREEN_RIGHT - 280)
		else
			self:GetChild("GroupInfoFrame")
				:stoptweening()
				:easeinoutexpo((params.time or 0.4))
				:x((SCREEN_RIGHT - 280) + 630)
		end
		local x = {
			Song = 0,
			Group = 0,
			Difficulty = 0,
			Options = 0,
		}
		local y = {
			Song = 0,
			Group = 0,
			Difficulty = 0,
			Options = 0,
		}
		local dim = {
			Song = 0,
			Group = 0,
			Difficulty = 0,
			Options = 0,
		}
		if Groups.Active == 'Song' then
			x.Song, y.Song = 0, 0
			x.Group, y.Group = -630, -SCREEN_CENTER_Y + 82
			x.Difficulty, y.Difficulty = SCREEN_WIDTH, 0
			dim.Song, dim.Group, dim.Difficulty = 0, 0, 0
			if Groups.Last == 'Group' then
				SOUND:StopMusic()
				self:GetChild('Music')
					:stoptweening()
					:sleep(0.4)
					:queuecommand('PreviewMusic')
			end
		elseif Groups.Active == 'Group' then
			x.Song, y.Song = 0, 0
			x.Group, y.Group = 0, 0
			x.Difficulty, y.Difficulty = SCREEN_WIDTH, 0
			dim.Song, dim.Group, dim.Difficulty = 0, 0.75, 0
			SOUND:StopMusic()
			self:GetChild('Music')
				:stoptweening()
				:sleep(0.4)
				:queuecommand('GroupMusic')
		elseif Groups.Active == 'Difficulty' then
			x.Song, y.Song = 630, SCREEN_CENTER_Y - 82
			x.Group, y.Group = -630, -SCREEN_CENTER_Y + 82
			x.Difficulty, y.Difficulty = 0, 0
			dim.Song, dim.Group, dim.Difficulty = 0, 0, 0.75
		end
		for _, name in ipairs {'Song', 'Group', 'Difficulty'} do
			local tab = self:GetChild('Wheel'):GetChild(name..'Tab')
			if Groups.Active == 'Options' then
				tab = self:GetChild('Wheel'):GetChild(name..'Tab'..ToEnumShortString(params.pn))
			end
			if tab then
				tab:stoptweening():easeinoutexpo((params.time or 0.4)):xy(x[name], y[name])
				if Groups.Active ~= 'Group' then
					if name == 'Song' then
						tab:GetChild('ControlsFrame')
							:stoptweening()
							:sleep((x[name] == 0 and 0.2) or 0)
							:easeinoutexpo((params.time or 0.4) * 0.5)
							:x(SCREEN_LEFT + 20 - x[name])
					elseif name == 'Difficulty' then
						tab:GetChild('ControlsFrame')
							:stoptweening()
							:sleep((x[name] == 0 and 0.2) or 0)
							:easeinoutexpo((params.time or 0.4) * 0.5)
							:x(SCREEN_RIGHT - 20 + x[name])
					end
				end
			end
			local dimmer = self:GetChild('Wheel'):GetChild(name..'Dim')
			if dimmer then dimmer:stoptweening():easeinoutexpo((params.time or 0.4)):diffusealpha(dim[name]) end
			if name == 'Difficulty' and Groups.Active == 'Difficulty' then
				for pn = 1, 2 do
					for i = 1, tab:GetChild('DifficultyP'..pn):GetChild('Data'):GetNumChildren() do
						local v = tab:GetChild('DifficultyP'..pn):GetChild('Data'):GetChildAt(i)
						v:stoptweening():cropright(1):sleep((params.time or 0.4) + i * 0.01):linear(0.02):cropright(0)
					end
					tab:GetChild('DifficultyP'..pn):GetChild('BackFrame')
						:stoptweening()
						:cropright(1)
						:sleep(0.3)
						:easeinoutexpo((params.time or 0.4) * 0.5)
						:cropright(0)
				end
			elseif name == 'Difficulty' and Groups.Active == 'Song' then
				for pn = 1, 2 do
					for i = 1, tab:GetChild('DifficultyP'..pn):GetChild('Data'):GetNumChildren() do
						local v = tab:GetChild('DifficultyP'..pn):GetChild('Data'):GetChildAt(i)
						v:stoptweening():sleep(i * 0.01):linear(0.02):cropright(1)
					end
					tab:GetChild('DifficultyP'..pn):GetChild('BackFrame')
						:stoptweening()
						:cropright(0)
						:easeinoutexpo(0.2)
						:cropright(1)
				end
			end
		end
	end,
	EnterGameplayCommand = function(self)
		for _, pn in ipairs(GAMESTATE:GetHumanPlayers()) do
			if PROFILEMAN:GetProfile(pn) then PROFILEMAN:SaveProfile(pn) end
			if GAMESTATE:IsCourseMode() then
				GAMESTATE:SetCurrentTrail(pn, Diffs[self:GetChild('Wheel'):GetChild('DifficultyTab'):GetChild('Difficulty'..ToEnumShortString(pn)):getaux()])
			else
				GAMESTATE:SetCurrentSteps(pn, Diffs[self:GetChild('Wheel'):GetChild('DifficultyTab'):GetChild('Difficulty'..ToEnumShortString(pn)):getaux()])
			end
		end
		if not PROFILEMAN:GetProfile(PLAYER_1) and not PROFILEMAN:GetProfile(PLAYER_2) then
			PROFILEMAN:SaveMachineProfile()
		end
		SCREENMAN:GetTopScreen()
			:SetNextScreenName('ScreenGameplay')
			:StartTransitioningScreen('SM_GoToNextScreen')
	end,
	EnterTitleMenuCommand = function(self)
		SOUND:StopMusic()
		SCREENMAN:GetTopScreen():Cancel()
	end,
	ChartWarningCommand = function(self)
		SCREENMAN:SystemMessage('Cannot play song with no compatible chart.')
		self:GetChild('Wheel'):GetChild('DifficultyTab')
			:stoptweening()
			:vibrate()
			:effectmagnitude(15, 0, 0)
		self:sleep(0.25):queuecommand('ChartWarningEnd')
	end,
	ChartWarningEndCommand = function(self)
		self:GetChild('Wheel'):GetChild('DifficultyTab'):stopeffect()
	end,
	wheel,
	Def.Actor {
		Name = 'Music',
		CurrentSongChangedMessageCommand = function(self)
			if not GAMESTATE:IsCourseMode() then
				if Groups.Active == 'Song' then
					SOUND:StopMusic()
						self
							:stoptweening()
							:sleep(0.4)
							:queuecommand('PreviewMusic')
				end
			end
		end,
		PreviewMusicCommand = function(self)
			local song = Songs[Songs.Index]
			if not GAMESTATE:IsCourseMode() then
				if Groups.Active == 'Song' or Groups.Active == 'Difficulty' then
					SOUND:PlayMusicPart(
						song:GetPreviewMusicPath(),
						song:GetSampleStart(),
						song:GetSampleLength(),
						0,
						1,
						true
					)
				end
			end
		end,
		GroupMusicCommand = function(self)
			if not GAMESTATE:IsCourseMode() then
				SOUND:PlayMusicPart(
					THEME:GetPathS('', 'Interluden'),
					0,
					25.6,
					0,
					0,
					true
				)
			end
		end,
	},

	-- this is where the group info is
	Def.ActorFrame {
		Name = 'GroupInfoFrame',
		InitCommand = function(self)
			self:xy(SCREEN_WIDTH / 4 * 3, 140)
		end,
		Def.Quad {
			Name = 'InfoDim',
			InitCommand = function(self)
				self
					:addx(-275)
					:addy(220)
					:SetSize(SCREEN_WIDTH, SCREEN_HEIGHT)
					:diffuse(color('#000000FF'))
					:fadeleft(0.05)
					:cropleft(0.45)
			end,
		},
		--[[
		Def.FadingBanner {
			Name = 'GroupBanner',
			InitCommand = function(self)
				--self:scaletoclipped(512, 160)
			end,
			CurrentSongChangedMessageCommand = function(self)
				local song = SU_Wheel.CurSong
				self
					:stoptweening()
					:LoadFromSongGroup(song:GetGroupName())
				for i = 1, self:GetNumChildren() do
					local img = self:GetChildAt(i)
					local w, h = img:GetWidth(), img:GetHeight()
					img:zoomto(160 * w/h, 160)
				end
					
			end,
		},
		--]]
		Def.ActorFrame {
			Name = 'GroupBannerFrame',
			Def.Banner {
				Name = 'GroupBanner',
				InitCommand = function(self)
					--self:scaletoclipped(512, 160)
				end,
				CurrentSongChangedMessageCommand = function(self)
					self
						:stoptweening()
						:linear(0.1)
						:diffusealpha(0)
						:sleep(0.25)
						:queuecommand('LoadBanner')
				end,
				LoadBannerCommand = function(self)
					local song = SU_Wheel.CurSong
					self:LoadFromSongGroup(song:GetGroupName())
					local w, h = self:GetWidth(), self:GetHeight()
					self:zoomto(160 * w/h, 160)
					self:easeinoutsine(0.2):diffusealpha(1)
				end,
			},
		},
		Def.BitmapText {
			Name = "SongCount",
			Font = "Common Normal",
			Text = "SONGS IN GROUP:",
			InitCommand = function(self)
				self
					:xy(-250, 100)
					:zoom(1)
					:horizalign("left")
					:vertalign("middle")
			end,
			CurrentSongChangedMessageCommand = function(self)
				local song = SU_Wheel.CurSong
				self
					:stoptweening()
					:settext("SONGS IN GROUP: "..table.getn( SONGMAN:GetSongsInGroup(song:GetGroupName()) ))
				if table.getn( SONGMAN:GetSongsInGroup(song:GetGroupName()) ) == 69 then
					self:rainbowscroll(true)
				else
					self:rainbowscroll(false)
				end
			end,
		},
		Def.BitmapText {
			Name = "ChartCount",
			Font = "Common Normal",
			Text = "",
			InitCommand = function(self)
				self
					:xy(-250, 135)
					:zoom(1)
					:horizalign("left")
					:vertalign("middle")
			end,
			CurrentSongChangedMessageCommand = function(self)
				local song = SU_Wheel.CurSong
				local numcharts = 0
				local sgroup = SONGMAN:GetSongsInGroup(song:GetGroupName())
	
				for i = 1, #sgroup do
					for _, c in ipairs(sgroup[i]:GetAllSteps()) do
						if c:GetStepsType():lower():find(GAMESTATE:GetCurrentGame():GetName()) then
							numcharts = numcharts + 1
						end
					end
				end
	
				self:stoptweening():settext(GAMESTATE:GetCurrentGame():GetName().." CHARTS IN GROUP: "..numcharts)
			end,
		},
		Def.BitmapText {
			Name = "FeaturedSongArtistsHeader",
			Font = "Common Normal",
			Text = "FEATURED SONG ARTISTS:",
			InitCommand = function(self)
				self
					:xy(-250, 170)
					:zoom(1)
					:horizalign("left")
					:vertalign("middle")
			end,
		},
		Def.BitmapText {
			Name = "FeaturedSongArtists",
			Font = "Common Normal",
			Text = "",
			InitCommand = function(self)
				self
					:xy(-250, 185)
					:zoom(1)
					:horizalign("left")
					:vertalign("top")
			end,
			CurrentSongChangedMessageCommand = function(self)
				local song = SU_Wheel.CurSong
				local sgroup = SONGMAN:GetSongsInGroup(song:GetGroupName())
				local artists = {}
				local artistsnorepeats = {}
				local txt = ""
	
				local seenartist = ""
				for i = 1, #sgroup do
					-- We'll break out of here if we hit over 11. ~Sudo
					--if i > 11 then break end
					artists[#artists + 1] = sgroup[i]:GetDisplayArtist()
				
					-- this SHOULD remove duplicate song artists but it only removes one duplicate ~ yosefu
					for j = 1, #artists do
						-- I accidentally deleted everything because i was j. ~Sudo
						if artists[i] == artists[j] and i ~= j then
							-- We can remove them easier if they're blank. ~Sudo
							artists[j] = ''
						end
					end
				end

				-- We need to ONLY increment when we DON'T delete. ~Sudo
				local i = 0
				while i <= #artists do
					if artists[i] == '' then
						table.remove(artists, i)
					else
						i = i + 1
					end
				end
				-- Now we gotta remove all the extra stuff and put the 'and more'! ~Sudo
				if #artists > 10 then
					for i = 11, #artists do
						table.remove(artists, #artists)
					end
					artists[11] = "and more"
				end
	
				for _, i in ipairs(artists) do
					txt = txt..i.."\n"
				end
	
				self:stoptweening():settext(txt)
			end,
		},
	},
}

for msg, func in pairs(Controls) do
	ret[msg..'MessageCommand'] = function(self, params)
		func(self, params)
	end
end

return ret
