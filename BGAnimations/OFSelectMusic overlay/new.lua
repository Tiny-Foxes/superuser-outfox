--[[

	ROADMAP:
		X Use only 1 song wheel.
		X Use only 12 ActorFrames on wheel.
		X Switch out text for wheels rather than entire wheels.
		X Add song preview.
		X Add difficulty select subscreen.
		X Allow dynamic player join and unjoin.
		X Add song elements to music select screen.
		- Add chart preview on difficulty select screen.
		- Add player option select subscreen.
		- Pretty up music select screen.
		- Add difficulty pips to song wheel.
		- Preview player option modifiers.
		- Allow custom sorting on wheel and groups.
		- Add song and group search.
		- Preview modcharts?
		- SHIP IT.

	NOTES:

--]]


local ThemeColor = LoadModule('Theme.Colors.lua')
local konko = LoadModule('Konko.Core.lua')
konko()

PlayersJoined = PlayersJoined or {
	[PLAYER_1] = false,
	[PLAYER_2] = false,
}
for k in pairs(PlayersJoined) do
	PlayersJoined[k] = GAMESTATE:IsSideJoined(k)
end
-- Song list indices.
-- Group, song, and difficulty. Difficulty has one for each player.
Index = Index or {
	Group = 1,
	Song = 1,
}
-- Wheel offsets.
-- Size, increment offset, decrement offset, center offset.
local wheel = {
	Focus = 'Song',
	NextScreen = 'OFGameplay',
	Song = {
		Size = 13,
		Inc = -6,
		Dec = 6,
		Ctr = 0,
	},
	Group = {
		Size = 13,
		Inc = -6,
		Dec = 6,
		Ctr = 0,
	}
}

local style = TF_WHEEL.QuickStyleDB[GAMESTATE:GetCurrentGame():GetName()]
local AllSongs = LoadModule('Wheel/Songs.Loader.lua')(style)
local AllGroups = LoadModule('Wheel/Group.List.lua')(AllSongs)
local SongList = LoadModule('Wheel/Group.Sort.lua')(AllSongs)

local CurGroup = AllGroups[Index.Group]
local CurSongs = SongList[CurGroup]

local RequestOptions = false

-- Function for moving along the song wheel.
local function MoveSong(self, offset, Songs, reset)
	local songCount = #Songs
	if reset then
		Index.Song = 1
		wheel.Song.Dec = 6
		wheel.Song.Inc = -6
		wheel.Song.Ctr = 0
		self:stoptweening():aux(0)
	else
		Index.Song = Index.Song + offset
		while Index.Song > songCount do Index.Song = Index.Song - songCount end
		while Index.Song < 1 do Index.Song = Index.Song + songCount end

		wheel.Song.Dec = wheel.Song.Dec + offset
		while wheel.Song.Dec > wheel.Song.Size do wheel.Song.Dec = wheel.Song.Dec - wheel.Song.Size end
		while wheel.Song.Dec < 1 do wheel.Song.Dec = wheel.Song.Dec + wheel.Song.Size end

		wheel.Song.Inc = wheel.Song.Inc + offset
		while wheel.Song.Inc > wheel.Song.Size do wheel.Song.Inc = wheel.Song.Inc - wheel.Song.Size end
		while wheel.Song.Inc < 1 do wheel.Song.Inc = wheel.Song.Inc + wheel.Song.Size end

		wheel.Song.Ctr = wheel.Song.Ctr + offset
		while wheel.Song.Ctr > wheel.Song.Size do wheel.Song.Ctr = wheel.Song.Ctr - wheel.Song.Size end
		while wheel.Song.Ctr < 1 do wheel.Song.Ctr = wheel.Song.Ctr + wheel.Song.Size end
	end

	if offset ~= 0 then
		for i = 1, wheel.Song.Size do

			local pos = Index.Song + (offset * 6) - 1
			while pos > songCount do pos = pos - songCount end
			while pos < 1 do pos = pos + songCount end

			local aux = self:getaux() + offset
			self:stoptweening():easeoutexpo(0.2):aux(aux)

			if (i == wheel.Song.Inc and offset < 0) or (i == wheel.Song.Dec and offset > 0) then
				local contAF = self:GetChild('Container'..i)
				contAF:GetChild('Title'):settext(Songs[pos]:GetDisplayMainTitle()):zoom(0.5):maxwidth(540)
				contAF:GetChild('SubTitle'):settext(Songs[pos]:GetDisplaySubTitle()):zoom(0.5):maxwidth(540)
				if contAF:GetChild('SubTitle'):GetText() == '' then
					contAF:GetChild('Title'):y(0)
					contAF:GetChild('SubTitle'):y(0)
				else
					contAF:GetChild('Title'):y(-8)
					contAF:GetChild('SubTitle'):y(10)
				end
			end

		end
	else
		for i = 1, wheel.Song.Size do

			local off = i + wheel.Song.Ctr + 1
			while off > wheel.Song.Size do off = off - wheel.Song.Size end
			while off < 1 do off = off + wheel.Song.Size end

			local pos = Index.Song + i
			if i > 6 then
				pos = Index.Song + i - wheel.Song.Size
			end
			while pos > songCount do pos = pos - songCount end
			while pos < 1 do pos = pos + songCount end
			local contAF = self:GetChild('Container'..off)
			contAF:GetChild('Title'):settext(Songs[pos]:GetDisplayMainTitle()):zoom(0.5):maxwidth(540)
			contAF:GetChild('SubTitle'):settext(Songs[pos]:GetDisplaySubTitle()):zoom(0.5):maxwidth(540)
			if contAF:GetChild('SubTitle'):GetText() == '' then
				contAF:GetChild('Title'):y(0)
				contAF:GetChild('SubTitle'):y(0)
			else
				contAF:GetChild('Title'):y(-8)
				contAF:GetChild('SubTitle'):y(10)
			end

		end
	end
	GAMESTATE:SetCurrentSong(Songs[Index.Song])
end

-- Function for moving along the group wheel.
local function MoveGroup(self, offset, Groups, reset)
	if reset then
		Index.Group = 1
		wheel.Group.Dec = 6
		wheel.Group.Inc = -6
		wheel.Group.Ctr = 0
		self:stoptweening():aux(0)
	else
		Index.Group = Index.Group + offset
		while Index.Group > #Groups do Index.Group = Index.Group - #Groups end
		while Index.Group < 1 do Index.Group = #Groups + Index.Group end

		wheel.Group.Dec = wheel.Group.Dec + offset
		while wheel.Group.Dec > wheel.Group.Size do wheel.Group.Dec = wheel.Group.Dec - wheel.Group.Size end
		while wheel.Group.Dec < 1 do wheel.Group.Dec = wheel.Group.Size + wheel.Group.Dec end

		wheel.Group.Inc = wheel.Group.Inc + offset
		while wheel.Group.Inc > wheel.Group.Size do wheel.Group.Inc = wheel.Group.Inc - wheel.Group.Size end
		while wheel.Group.Inc < 1 do wheel.Group.Inc = wheel.Group.Size + wheel.Group.Inc end

		wheel.Group.Ctr = wheel.Group.Ctr + offset
		while wheel.Group.Ctr > wheel.Group.Size do wheel.Group.Ctr = wheel.Group.Ctr - wheel.Group.Size end
		while wheel.Group.Ctr < 1 do wheel.Group.Ctr = wheel.Group.Size + wheel.Group.Ctr end
	end

	if offset ~= 0 then
		for i = 1, wheel.Group.Size do

			local pos = Index.Group + (offset * 6) - 1
			while pos > #Groups do pos = pos - #Groups end
			while pos < 1 do pos = #Groups + pos end

			local aux = self:getaux() + offset
			self:stoptweening():easeoutexpo(0.2):aux(aux)

			if (i == wheel.Group.Inc and offset < 0) or (i == wheel.Group.Dec and offset > 0) then
				local contAF = self:GetChild('Container'..i)
				contAF:GetChild('Title'):settext(Groups[pos]):zoom(0.5):maxwidth(540)
			end
		end
	else
		for i = 1, wheel.Group.Size do

			local off = i + wheel.Group.Ctr + 1
			while off > wheel.Group.Size do off = off - wheel.Group.Size end
			while off < 1 do off = off + wheel.Group.Size end

			local pos = Index.Group + i
			if i > 6 then
				pos = Index.Group + i - wheel.Group.Size
			end
			while pos > wheel.Group.Size do pos = pos - #Groups end
			while pos < 1 do pos = #Groups + pos end

			local contAF = self:GetChild('Container'..off)
			contAF:GetChild('Title'):settext(Groups[pos]):zoom(0.5):maxwidth(540)

		end
	end
	CurGroup = AllGroups[Index.Group]
	CurSongs = SongList[CurGroup]
end

--[[
	These are actual Actor tables. I created this module,
	I love this module, I am keeping this module.
	If you need help on how to use these modules, please,
	I BEG you, ping me on the OutFox server. I would be
	more than happy to explain how this module works.
	But if you have an object-oriented mind like me,
	you would probably already know how they work
	just from looking at the rest of the code.

	Get used to seeing this all over the place.
	I'm going to completely restructure the entire
	theme using this module for Actor creation.
--]]
local SuperActor = LoadModule('Konko.SuperActor.lua')

local af = SuperActor.new('ActorFrame')

local songWheel = SuperActor.new('ActorScroller')
local songSelect = SuperActor.new('ActorFrame')

local groupCover = SuperActor.new('Quad')

local groupWheel = SuperActor.new('ActorScroller')
local groupSelect = SuperActor.new('ActorFrame')

local diffCover = SuperActor.new('Quad')

local songPreview = SuperActor.new('Actor')


local songTransform = function(self, offset, itemIndex, numItems)
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
end
local groupTransform = function(self, offset, itemIndex, numItems)
	if not self:GetVisible() then return end
	self:xy(offset * -48, offset * 96)
	if offset > -1 and offset < 1 then
		self
			:zoom( 1.5 + (0.5 - math.abs(offset * 0.5)) )
			:x( (offset * -48) + (80 - (math.abs(offset * 80))) )
	else
		self:zoom(1.5)
	end
	if offset > 3 and offset < -3 then
		self:zoom(1.5)
		for _, child in ipairs(self:GetChildren()) do
			child:diffusealpha(1 - (math.abs(offset) - 3))
		end
	end
end

local songIdx = 0
for i = 1, wheel.Song.Size do
	songIdx = songIdx + 1
	if songIdx > #CurSongs then songIdx = 1 end
	local song = SuperActor.new('ActorFrame')
	local panel = SuperActor.new('Quad')
	local title = SuperActor.new('BitmapText')
	local subtitle = SuperActor.new('BitmapText')
	do panel
		:SetCommand('Init', function(self)
			self
				:SetSize(320, 48)
				:diffuse(ThemeColor.Elements)
				:skewx(-0.5)
				:shadowlength(2, 2)
		end)
	end
	do title
		:SetAttribute('Font', 'Common Large')
		:SetAttribute('Text', CurSongs[songIdx]:GetDisplayMainTitle())
		:SetCommand('Init', function(self)
			self:zoom(0.5):maxwidth(540)
		end)
	end
	do subtitle
		:SetAttribute('Font', 'Common Normal')
		:SetAttribute('Text', CurSongs[songIdx]:GetDisplaySubTitle())
		:SetCommand('Init', function(self)
			self:zoom(0.5):maxwidth(540)
		end)
	end
	do song
		:AddChild(panel, 'Panel')
		:AddChild(title, 'Title')
		:AddChild(subtitle, 'SubTitle')
		:SetCommand('Init', function(self)
			if self:GetChild('SubTitle'):GetText() == '' then
				self:GetChild('Title'):y(0)
				self:GetChild('SubTitle'):y(0)
			else
				self:GetChild('Title'):y(-8)
				self:GetChild('SubTitle'):y(10)
			end
		end)
	end
	songWheel:AddChild(song, 'Container'..i)
end

do songWheel
	:SetAttribute('UseScroller', true)
	:SetAttribute('SecondsPerItem', true)
	:SetAttribute('NumItemsToDraw', 9)
	:SetAttribute('ItemPaddingStart', 0)
	:SetAttribute('ItemPaddingEnd', 0)
	:SetAttribute('TransformFunction', songTransform)
	:SetCommand('Init', function(self)
		self
			:xy(SR - 210, SCY)
			:SetLoop(true)
			:SetFastCatchup(true)
			:aux(0)
		MoveSong(self, 0, CurSongs)
	end)
	:SetCommand('On', function(self)
		SCREENMAN:GetTopScreen():AddInputCallback(function(event)
			if wheel.Focus == 'Song' then
				TF_WHEEL.Input(self)(event)
			end
		end)
		self:luaeffect('Update')
	end)
	:SetMessage('SongSelect', function(self)
		self:finishtweening():easeinoutexpo(0.25):addx(640)
		SCREENMAN:PlayStartSound()
		SCREENMAN:AddNewScreenToTop('OFSelectDifficulty')
	end)
	:SetMessage('SongUnselect', function(self)
		self:finishtweening():sleep(0.25):easeinoutexpo(0.25):addx(-640)
		SOUND:PlayOnce(THEME:GetPathS('MusicWheel', 'expand'), true)
	end)
	:SetCommand('MenuUp', function(self)
		if PlayersJoined[self.pn] then
			MoveSong(self, -1, CurSongs)
			SOUND:PlayOnce(THEME:GetPathS('MusicWheel', 'change'), true)
		end
	end)
	:SetCommand('MenuDown', function(self)
		if PlayersJoined[self.pn] then
			MoveSong(self, 1, CurSongs)
			SOUND:PlayOnce(THEME:GetPathS('MusicWheel', 'change'), true)
		end
	end)
	:SetCommand('MenuLeft', function(self)
		if PlayersJoined[self.pn] then
			MoveSong(self, -1, CurSongs)
			SOUND:PlayOnce(THEME:GetPathS('MusicWheel', 'change'), true)
		end
	end)
	:SetCommand('MenuRight', function(self)
		if PlayersJoined[self.pn] then
			MoveSong(self, 1, CurSongs)
			SOUND:PlayOnce(THEME:GetPathS('MusicWheel', 'change'), true)
		end
	end)
	:SetCommand('Back', function(self)
		if PlayersJoined[self.pn] then
			MESSAGEMAN:Broadcast('GroupUnselect')
		end
	end)
	:SetCommand('Start', function(self)
		-- If this player is not joined, join them.
		if not PlayersJoined[self.pn] then
			GAMESTATE:JoinPlayer(self.pn)
			PlayersJoined[self.pn] = true
		-- Otherwise, select the current song.
		else
			MESSAGEMAN:Broadcast('SongSelect')
		end
	end)
	:SetCommand('Update', function(self)
		self:SetCurrentAndDestinationItem(self:getaux())
	end)
	:AddToTree('SongWheel')
end

do songSelect
	:SetCommand('Init', function(self)
		self:xy(SR - 290, SCY):zoom(2):visible(false):queuecommand('Setup')
	end)
	:SetCommand('Setup', function(self)
		self:y(SCY):visible(false)
	end)
	:SetMessage('Show', function(self)
		self:visible(true)
	end)
	:SetMessage('Hide', function(self)
		self:visible(false)
	end)
	:SetMessage('SongSelect', function(self)
		self:finishtweening():queuecommand('Show'):easeinoutexpo(0.5):y(SB - 96)
	end)
	:SetMessage('SongUnselect', function(self)
		self:finishtweening():easeinoutexpo(0.5):y(SCY):queuecommand('Hide')
	end)
	:SetCommand('CurrentSongChanged', function(self)
		if self:GetChild('SubTitle'):GetText() == '' then
			self:GetChild('Title'):y(0)
			self:GetChild('SubTitle'):y(0)
		else
			self:GetChild('Title'):y(-8)
			self:GetChild('SubTitle'):y(10)
		end
	end)
	:AddChild(
		SuperActor.new('Quad')
			:SetCommand('Init', function(self)
				self
					:SetSize(320, 48)
					:diffuse(ThemeColor.Elements)
					:skewx(-0.5)
					:shadowlength(2, 2)
			end),
		'Panel'
	)
	:AddChild(
		SuperActor.new('BitmapText')
			:SetAttribute('Font', 'Common Large')
			:SetCommand('Init', function(self)
				self:zoom(0.5):maxwidth(540)
			end)
			:SetMessage('CurrentSongChanged', function(self)
				self:settext(GAMESTATE:GetCurrentSong():GetDisplayMainTitle())
			end),
		'Title'
	)
	:AddChild(
		SuperActor.new('BitmapText')
			:SetAttribute('Font', 'Common Normal')
			:SetCommand('Init', function(self)
				self:zoom(0.5):maxwidth(540)
			end)
			:SetMessage('CurrentSongChanged', function(self)
				self:settext(GAMESTATE:GetCurrentSong():GetDisplaySubTitle())
				if self:GetText() == '' then
					self:GetParent():GetChild('Title'):y(0)
					self:y(0)
				else
					self:GetParent():GetChild('Title'):y(-8)
					self:y(10)
				end
			end),
		'SubTitle'
	)
	:AddToTree('SongSelector')
end

do groupCover
	:SetCommand('Init', function(self)
		self:FullScreen():diffuse(color('#00000000'))
	end)
	:SetMessage('GroupSelect', function(self)
		self:stoptweening():easeinoutsine(0.25):diffusealpha(0)
	end)
	:SetMessage('GroupUnselect', function(self)
		self:stoptweening():easeinoutsine(0.25):diffusealpha(0.75)
	end)
	:AddToTree('GroupCover')
end

local groupIdx = 0
for i = 1, wheel.Group.Size do
	groupIdx = groupIdx + 1
	if groupIdx > #AllGroups then groupIdx = 1 end
	local group = SuperActor.new('ActorFrame')
	local panel = SuperActor.new('Quad')
	local title = SuperActor.new('BitmapText')
	panel
		:SetCommand('Init', function(self)
			self
				:SetSize(320, 48)
				:diffuse(ThemeColor.Primary)
				:skewx(-0.5)
				:shadowlength(2, 2)
		end)
	title
		:SetAttribute('Font', 'Common Large')
		:SetAttribute('Text', AllGroups[groupIdx])
		:SetCommand('Init', function(self)
			self:zoom(0.5):maxwidth(540)
		end)
	group
		:AddChild(panel, 'Panel')
		:AddChild(title, 'Title')
	groupWheel
		:AddChild(group, 'Container'..i)
end

do groupWheel
	:SetAttribute('UseScroller', true)
	:SetAttribute('SecondsPerItem', true)
	:SetAttribute('NumItemsToDraw', 9)
	:SetAttribute('ItemPaddingStart', 0)
	:SetAttribute('ItemPaddingEnd', 0)
	:SetAttribute('TransformFunction', groupTransform)
	:SetCommand('Init', function(self)
		self
			:xy(SL + 210, SCY)
			:SetLoop(true)
			:SetFastCatchup(true)
			:aux(0)
			:queuecommand('Setup')
		MoveGroup(self, 0, AllGroups)
	end)
	:SetCommand('Setup', function(self)
		self:addx(-640)
	end)
	:SetCommand('On', function(self)
		SCREENMAN:GetTopScreen():AddInputCallback(function(event)
			if wheel.Focus == 'Group' then
				TF_WHEEL.Input(self)(event)
			end
		end)
		self:luaeffect('Update')
	end)
	:SetMessage('GroupSelect', function(self)
		self:finishtweening():easeinoutexpo(0.25):addx(-640)
		SOUND:PlayOnce(THEME:GetPathS('MusicWheel', 'collapse'), true)
	end)
	:SetMessage('GroupUnselect', function(self)
		self:finishtweening():sleep(0.25):easeinoutexpo(0.25):addx(640)
		SOUND:PlayOnce(THEME:GetPathS('MusicWheel', 'expand'), true)
	end)
	:SetCommand('MenuUp', function(self)
		if PlayersJoined[self.pn] then
			MoveGroup(self, -1, AllGroups)
			MoveSong(SuperActor.GetTree():GetChild('SongWheel'), 0, CurSongs, true)
			SOUND:PlayOnce(THEME:GetPathS('MusicWheel', 'change'), true)
		end
	end)
	:SetCommand('MenuDown', function(self)
		if PlayersJoined[self.pn] then
			MoveGroup(self, 1, AllGroups)
			MoveSong(SuperActor.GetTree():GetChild('SongWheel'), 0, CurSongs, true)
			SOUND:PlayOnce(THEME:GetPathS('MusicWheel', 'change'), true)
		end
	end)
	:SetCommand('MenuLeft', function(self)
		if PlayersJoined[self.pn] then
			MoveGroup(self, -1, AllGroups)
			MoveSong(SuperActor.GetTree():GetChild('SongWheel'), 0, CurSongs, true)
			SOUND:PlayOnce(THEME:GetPathS('MusicWheel', 'change'), true)
		end
	end)
	:SetCommand('MenuRight', function(self)
		if PlayersJoined[self.pn] then
			MoveGroup(self, 1, AllGroups)
			MoveSong(SuperActor.GetTree():GetChild('SongWheel'), 0, CurSongs, true)
			SOUND:PlayOnce(THEME:GetPathS('MusicWheel', 'change'), true)
		end
	end)
	:SetCommand('Back', function(self)
		-- If both players are joined, unjoin the player at input.
		if PlayersJoined[PLAYER_1] and PlayersJoined[PLAYER_2] then
			GAMESTATE:UnjoinPlayer(self.pn)
			PlayersJoined[self.pn] = false
		-- Otherwise, if this player is still joined, cancel to the previous screen.
		elseif PlayersJoined[self.pn] then
			SCREENMAN:PlayCancelSound()
			SCREENMAN:GetTopScreen():Cancel()
		end
	end)
	:SetCommand('Start', function(self)
		-- If this player is not joined, join them.
		if not PlayersJoined[self.pn] then
			GAMESTATE:JoinPlayer(self.pn)
			PlayersJoined[self.pn] = true
		-- Otherwise, select the current group.
		else
			MESSAGEMAN:Broadcast('GroupSelect')
		end
	end)
	:SetCommand('Update', function(self)
		self:SetCurrentAndDestinationItem(self:getaux())
	end)
	:AddToTree('GroupWheel')
end

do groupSelect
	:SetCommand('Init', function(self)
		self:xy(SL + 290, SCY):zoom(2):visible(false):queuecommand('Setup')
	end)
	:SetCommand('Setup', function(self)
		self:y(ST + 96):visible(true)
	end)
	:SetMessage('Show', function(self)
		self:visible(true)
	end)
	:SetMessage('Hide', function(self)
		self:visible(false)
	end)
	:SetMessage('GroupSelect', function(self)
		self:finishtweening():queuecommand('Show'):easeinoutexpo(0.5):y(ST + 96)
	end)
	:SetMessage('GroupUnselect', function(self)
		self:finishtweening():easeinoutexpo(0.5):y(SCY):queuecommand('Hide')
	end)
	:AddChild(
		SuperActor.new('Quad')
			:SetCommand('Init', function(self)
				self
					:SetSize(320, 48)
					:diffuse(ThemeColor.Primary)
					:skewx(-0.5)
					:shadowlength(2, 2)
			end),
		'Panel'
	)
	:AddChild(
		SuperActor.new('BitmapText')
			:SetAttribute('Font', 'Common Large')
			:SetCommand('Init', function(self)
				self:zoom(0.5):maxwidth(540)
			end)
			:SetMessage('CurrentSongChanged', function(self)
				self:settext(AllGroups[Index.Group])
			end),
		'Title'
	)
	:AddToTree('GroupSelector')
end

do diffCover
	:SetCommand('Init', function(self)
		self:FullScreen():diffuse(color('#00000000'))
	end)
	:SetMessage('SongSelect', function(self)
		self:stoptweening():easeinoutsine(0.25):diffusealpha(0.75)
	end)
	:SetMessage('SongUnselect', function(self)
		self:stoptweening():easeinoutsine(0.25):diffusealpha(0)
	end)
	:AddToTree('DiffCover')
end

do songPreview
	:SetCommand('On', function(self)
		self:queuemessage('CurrentSongChanged')
	end)
	:SetMessage('CurrentSongChanged', function(self)
		SOUND:StopMusic()
		self:stoptweening():sleep(0.4):queuecommand('SongPreview')
	end)
	:SetCommand('SongPreview', function(self)
		if GAMESTATE:IsCourseMode() then
			SOUND:PlayMusicPart(
				THEME:GetPathS('ScreenSelectMusic', 'loop music'),
				nil,
				nil,
				0,
				0,
				true
			)
		else
			--GAMESTATE:GetCurrentSong():PlayPreviewMusic() -- Doesn't fade out.
			---[[
			local song = GAMESTATE:GetCurrentSong()
			SOUND:PlayMusicPart(
				song:GetPreviewMusicPath(),
				song:GetSampleStart(),
				song:GetSampleLength(),
				0,
				1,
				true
			)
			--]]
		end
	end)
	:AddToTree('SongPreview')
end

do af
	:SetMessage('GroupSelect', function(self)
		wheel.Focus = 'Song'
	end)
	:SetMessage('GroupUnselect', function(self)
		wheel.Focus = 'Group'
	end)
	:SetMessage('SongSelect', function(self)
		wheel.Focus = 'None'
	end)
	:SetMessage('SongUnselect', function(self)
		wheel.Focus = 'Song'
	end)
	:SetMessage('EnterOptions', function(self)
		wheel.NextScreen = 'ScreenPlayerOptions'
		self:sleep(0.25):queuecommand('BeginTransition')
	end)
	:SetMessage('EnterGameplay', function(self)
		SOUND:DimMusic(0, 3)
		wheel.NextScreen = 'OFGameplay'
		self:sleep(0.25):queuecommand('BeginTransition')
	end)
	:SetCommand('BeginTransition', function(self)
		SCREENMAN:GetTopScreen()
			:SetNextScreenName(wheel.NextScreen)
			:StartTransitioningScreen('SM_GoToNextScreen')
	end)
	:AddToTree()
end

return SuperActor.GetTree()
