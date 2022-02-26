local ThemeColor = LoadModule('Theme.Colors.lua')

local wheel = Def.ActorFrame { Name = 'Wheel' }

-- Must be global.

GAMESTATE:SetCurrentPlayMode('PlayMode_Regular')
if GAMESTATE:IsSideJoined(PLAYER_1) and GAMESTATE:IsSideJoined(PLAYER_2) then
	GAMESTATE:SetCurrentStyle('versus')
else
	GAMESTATE:SetCurrentStyle('single')
end

local profile = PROFILEMAN:GetProfile(GAMESTATE:GetMasterPlayerNumber())
TF_CurrentSong = TF_CurrentSong or profile:GetLastPlayedSong()
if not TF_CurrentSong then TF_CurrentSong = SONGMAN:GetAllSongs()[1] end

local Groups = SONGMAN:GetSongGroupNames()
Groups.Index = 1
for i = 1, #Groups do
	if TF_CurrengSong and TF_CurrentSong:GetGroupName() == Groups[i] then
		Groups.Index = i
		break
	end
end
Groups.Active = 'Song'
Groups.Loop = false
local Songs = SONGMAN:GetSongsInGroup(Groups[Groups.Index])
Songs.Index = 1
for i = 1, #Songs do
	if TF_CurrentSong == Songs[i] then
		print('Found a match at index '..i)
		Songs.Index = i
		break
	end
end
local Diffs = {}
for _, d in ipairs(TF_CurrentSong:GetAllSteps()) do
	if d:GetStepsType():lower():find(GAMESTATE:GetCurrentGame():GetName()) then
		Diffs[#Diffs + 1] = d
	end
end


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
	local groupSongs = SONGMAN:GetSongsInGroup(group)
	local actor = loadfile(THEME:GetPathG('MusicWheelItem', 'SectionExpanded NormalPart'))() .. {
		InitCommand = function(self)
			for i = 1, self:GetNumWrapperStates() do
				self:RemoveWrapperState(i)
			end
			self:AddWrapperState()
		end,
	}
	actor[#actor + 1] = Def.BitmapText {
		Font = 'Common Normal',
		Text = group,
		InitCommand = function(self)
			self:maxwidth(280)
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
	for _, song in ipairs(groupSongs) do
		local actor = loadfile(THEME:GetPathG('MusicWheelItem', 'Song NormalPart'))() .. {
			InitCommand = function(self)
				for i = 1, self:GetNumWrapperStates() do
					self:RemoveWrapperState(i)
				end
				self:AddWrapperState()
			end,
		}
		actor[#actor + 1] = Def.BitmapText {
			Font = 'Common Normal',
			Text = song:GetDisplayMainTitle(),
			InitCommand = function(self)
				self:maxwidth(280)
			end,
		}
		songList[#songList + 1] = actor
	end

	folderSongs[#folderSongs + 1] = songList
end

local f = Def.ActorFrame {
	Name = 'SongTab',
}
for _, v in ipairs(folderSongs) do
	f[#f + 1] = v
end
wheel[#wheel + 1] = f

wheel[#wheel + 1] = Def.Quad {
	Name = 'GroupDim',
	InitCommand = function(self)
		self
			:Center()
			:SetSize(SCREEN_WIDTH, SCREEN_HEIGHT)
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
			:Center()
			:SetSize(SCREEN_WIDTH, SCREEN_HEIGHT)
			:diffuse(color('#00000000'))
	end,
}

local diffTab = Def.ActorFrame {
	Name = 'DifficultyTab',
	InitCommand = function(self)
		self:y(SCREEN_WIDTH)
	end,
}

for pn = 1, 2 do
	local diff = Def.ActorFrame {
		Name = 'DifficultyP'..pn,
		InitCommand = function(self)
			self:Center():zoom(1.5):aux(1)
			self:GetChild('BackFrame')
				:SetSize(SCREEN_HEIGHT * 0.65, 96)
				:addx(SCREEN_CENTER_Y * 0.05)
				:diffuse(0, 0, 0, 0.5)
				:skewx(-0.5)
			self:GetChild('MeterFrame')
				:SetSize(128, 96)
				:addx(-SCREEN_CENTER_Y * 0.6)
				:skewx(-0.5)
			self:GetChild('Meter'):addx(-SCREEN_CENTER_Y * 0.6 + 3):addy(-12)
			self:GetChild('DiffName'):zoom(0.75):addx(-SCREEN_CENTER_Y * 0.6 - 12):addy(24)
			self:visible(GAMESTATE:IsSideJoined(PlayerNumber[pn]))
		end,
		OnCommand = function(self)
			local y = (GAMESTATE:IsSideJoined(PLAYER_1) and GAMESTATE:IsSideJoined(PLAYER_2)) and 80 or 0
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
					:stoptweening()
					:cropright(1)
					:sleep(i * 0.01)
					:linear(0.05)
					:cropright(0)
			end
			self:GetChild('Meter'):settext(params.meter)
			self:GetChild('DiffName'):settext(params.name)
			self:GetChild('MeterFrame')
				:stoptweening()
				:easeinoutsine(params.time)
				:diffuse(ThemeColor[params.difficulty])
		end,
		Def.Quad { Name = 'BackFrame' },
		Def.Quad { Name = 'MeterFrame' },
		Def.BitmapText { Font = '_xide/40px', Name = 'Meter' },
		Def.BitmapText { Font = 'Common Normal', Name = 'DiffName' },
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
	diffTab[#diffTab + 1] = diff
end

wheel[#wheel + 1] = diffTab

local popTab = Def.ActorFrame {
	Name = 'OptionsTab',
}

for pn = 1, 2 do
	local popt = Def.ActorFrame {
		Name = 'OptionsP'..pn,

	}
end

wheel[#wheel + 1] = popTab


local function WheelSwap(self, input)
	if Groups.Active == 'Group' then
		self:playcommand('ChangeFocus', {element = 'Song'})
	elseif Groups.Active == 'Song' then
		self:playcommand('ChangeFocus', {element = 'Group'})
	end
	if Groups.Active ~= 'Difficulty' then SOUND:PlayOnce(THEME:GetPathS('MusicWheel', 'collapse'), true) end
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
	self:playcommand('Change'..Groups.Active, {pn = PlayerNumber[pn], direction = -1, time = 0.25})
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
	self:playcommand('Change'..Groups.Active, {pn = PlayerNumber[pn], direction = 1, time = 0.25})
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
		if #Diffs ~= 0 then
			SOUND:PlayOnce(THEME:GetPathS('Common', 'Start'), true)
			self:playcommand('EnterGameplay')
		else
			self:playcommand('ChartWarning')
		end
	end
end
local function Unconfirm(self, input)
	if Groups.Active == 'Difficulty' then
		SOUND:PlayOnce(THEME:GetPathS('Common', 'Cancel'), true)
		self:playcommand('ChangeFocus', {element = 'Song'})
	elseif Groups.Active == 'Group' then
		SOUND:PlayOnce(THEME:GetPathS('MusicWheel', 'collapse'), true)
		self:playcommand('ChangeFocus', {element = 'Song'})
	elseif Groups.Active == 'Song' then
		SOUND:PlayOnce(THEME:GetPathS('Common', 'Cancel'), true)
		self:playcommand('EnterTitleMenu')
	end
end

local Controls = {
	MenuLeft = WheelUp,
	MenuRight = WheelDown,
	MenuUp = WheelSwap,
	MenuDown = WheelSwap,
	Start = Confirm,
	Back = Unconfirm,
}

local function InputHandler(event)
	if event.type ~= 'InputEventType_Release' then
		MESSAGEMAN:Broadcast(event.GameButton, event)
	end
end

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
		Songs = SONGMAN:GetSongsInGroup(Groups[Groups.Index])
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
		TF_CurrentSong = Songs[Songs.Index]
		GAMESTATE:SetCurrentSong(TF_CurrentSong)
		Diffs = {}
		for _, d in ipairs(TF_CurrentSong:GetAllSteps()) do
			if d:GetStepsType():lower():find(GAMESTATE:GetCurrentGame():GetName()) then
				Diffs[#Diffs + 1] = d
			end
		end
		for pn = 1, 2 do
			if GAMESTATE:IsSideJoined(PlayerNumber[pn]) then
				self:playcommand('ChangeDifficulty', {pn = PlayerNumber[pn], direction = 0, time = 0})
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
		local diff = self:GetChild('Wheel'):GetChild('DifficultyTab'):GetChild('Difficulty'..ToEnumShortString(params.pn))
		if #Diffs == 0 then
			if diff:getaux() ~= 0 then
				print('No compatible chart found.')
				diff:playcommand('SetDifficulty', {
					pn = params.pn,
					difficulty = 'Black',
					name = 'Empty',
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
			if diff:getaux() > #Diffs then diff:aux(#Diffs) return
			elseif diff:getaux() < 1 then diff:aux(1) return
			end
			local d = Diffs[diff:getaux()]
			while not d or not d:GetMeter() do
				diff:addaux(-1)
				if diff:getaux() < 1 then diff:aux(#Diffs) end
				d = Diffs[diff:getaux()]
			end
			local diffstr = d:GetDifficulty()
			diffstr = diffstr:sub(diffstr:find('_') + 1, -1)
			local radar = d:GetRadarValues(params.pn)
			local data = {
				author = d:GetAuthorCredit(),
				style = THEME:GetString('LongStepsType', ToEnumShortString(d:GetStepsType())),
				info = d:GetDescription(),


				taps = radar:GetValue(RadarCategory[6]),
				holds = radar:GetValue(RadarCategory[9]),
				rolls = radar:GetValue(RadarCategory[12]),
				jumps = radar:GetValue(RadarCategory[8]),
				hands = radar:GetValue(RadarCategory[11]),
				lifts = radar:GetValue(RadarCategory[13]),
				fakes = radar:GetValue(RadarCategory[14]),
				mines = radar:GetValue(RadarCategory[10]),
			}
			diff:playcommand('SetDifficulty', {
				pn = params.pn,
				difficulty = diffstr,
				name = THEME:GetString('CustomDifficulty', ToEnumShortString(d:GetDifficulty())),
				meter = math.floor(d:GetMeter() * 10) * 0.1,
				time = params.time,
				data = data
			})
			if Groups.Active == 'Difficulty' and diff:getaux() ~= 0 then SOUND:PlayOnce(THEME:GetPathS('Common', 'value'), true) end
		end
	end,
	ChangeFocusCommand = function(self, params)
		if not params.element then return end
		Groups.Active = params.element
		local x = {
			Song = 0,
			Group = 0,
			Difficulty = 0,
		}
		local y = {
			Song = 0,
			Group = 0,
			Difficulty = 0,
		}
		local dim = {
			Song = 0,
			Group = 0,
			Difficulty = 0,
		}
		if Groups.Active == 'Song' then
			x.Song, y.Song = 0, 0
			x.Group, y.Group = -630, -SCREEN_CENTER_Y + 82
			x.Difficulty, y.Difficulty = 0, SCREEN_HEIGHT
			dim.Song, dim.Group, dim.Difficulty = 0, 0, 0
		elseif Groups.Active == 'Group' then
			x.Song, y.Song = 0, 0
			x.Group, y.Group = 0, 0
			x.Difficulty, y.Difficulty = 0, SCREEN_HEIGHT
			dim.Song, dim.Group, dim.Difficulty = 0, 0.5, 0
		elseif Groups.Active == 'Difficulty' then
			x.Song, y.Song = 630, SCREEN_CENTER_Y - 82
			x.Group, y.Group = -630, -SCREEN_CENTER_Y + 82
			x.Difficulty, y.Difficulty = 0, 0
			dim.Song, dim.Group, dim.Difficulty = 0, 0, 0.5
		end
		for _, name in ipairs {'Song', 'Group', 'Difficulty'} do
			local tab = self:GetChild('Wheel'):GetChild(name..'Tab')
			if tab then tab:stoptweening():easeinoutexpo((params.time or 0.4)):xy(x[name], y[name]) end
			local dimmer = self:GetChild('Wheel'):GetChild(name..'Dim')
			if dimmer then dimmer:stoptweening():easeinoutexpo((params.time or 0.4)):diffusealpha(dim[name]) end
			if Groups.Active == 'Difficulty' and name == Groups.Active then
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
			elseif name == 'Difficulty' then
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
		--SOUND:StopMusic()
		for _, pn in ipairs(GAMESTATE:GetHumanPlayers()) do
			PROFILEMAN:SaveProfile(pn)
			GAMESTATE:SetCurrentSteps(pn, Diffs[self:GetChild('Wheel'):GetChild('DifficultyTab'):GetChild('Difficulty'..ToEnumShortString(pn)):getaux()])
		end
		SCREENMAN:GetTopScreen()
			:SetNextScreenName('ScreenGameplay')
			:StartTransitioningScreen('SM_GoToNextScreen')
	end,
	EnterTitleMenuCommand = function(self)
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
		CurrentSongChangedMessageCommand = function(self)
			SOUND:StopMusic()
			self
				:stoptweening()
				:sleep(0.4)
				:queuecommand('PreviewMusic')
		end,
		PreviewMusicCommand = function(self)
			local song = Songs[Songs.Index]
			SOUND:PlayMusicPart(
				song:GetPreviewMusicPath(),
				song:GetSampleStart(),
				song:GetSampleLength(),
				0,
				1,
				true
			)
		end,
	}
}

for msg, func in pairs(Controls) do
	ret[msg..'MessageCommand'] = function(self, params)
		func(self, params)
	end
end

return ret
