--[[

	ROADMAP:
		X Use only 1 song wheel.
		X Use only 12 ActorFrames on wheel.
		X Switch out text for wheels rather than entire wheels.
		X Add song preview.
		X Add difficulty select subscreen.
		X Allow dynamic player join and unjoin.
		X Add song elements to music select screen.
		- Pretty up music select screen.
		- Add difficulty pips to song wheel.
		- Add chart preview on difficulty select screen.
		- Add player option select subscreen.
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

local SuperActor = LoadModule('Konko.SuperActor.lua')

PlayersJoined = PlayersJoined or {
	[PLAYER_1] = false,
	[PLAYER_2] = false,
}
local profiles = {
	PROFILEMAN:GetProfile(PLAYER_1),
	PROFILEMAN:GetProfile(PLAYER_2),
}
for k in pairs(PlayersJoined) do
	PlayersJoined[k] = GAMESTATE:IsSideJoined(k)
end
-- Song list indices.
-- Group, song, and difficulty. Difficulty has one for each player.
GAMESTATE:Env().Index = GAMESTATE:Env().Index or {
	Group = 1,
	Song = 1,
}
local Index = GAMESTATE:Env().Index

-- Wheel offsets.
-- Size, increment offset, decrement offset, center offset.
local sorts = {
	'Group', 'Title', 'Artist', 'Credit', 'Length',
	Reverse = function(self)
		local t = {}
		for i, v in ipairs(self) do
			t[v] = i
		end
		return t
	end
}
local sortIdx = sorts:Reverse()[TF_WHEEL.PreferredSort]
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
GAMESTATE:Env().AllSongs = GAMESTATE:Env().AllSongs or LoadModule('Wheel/Songs.Loader.lua')(style)
local AllSongs = GAMESTATE:Env().AllSongs
if #AllSongs < 1 then
	local af = SuperActor.new('ActorFrame')
	local image = SuperActor.new('Sprite')
	local top = SuperActor.new('BitmapText')
	local bottom = SuperActor.new('BitmapText')
	local prompt = SuperActor.new('BitmapText')
	local msg = {
		'You know, the game\'s a lot more fun',
		'when you have some songs to play! But',
		'don\'t worry, I know a few places you',
		'can get some. Check out OutFox\'s pack',
		'series, Project OutFox Serenity! You can',
		'get the pack from projectoutfox.com. You',
		'can also use any of the content you have',
		'on other StepMania builds! And if you have',
		'any song files from other games like osu!,',
		'Taikojiro, Lunatic Rave, etc., you can use',
		'those, too! Try it out! Once you\'ve got some',
		'charts, come back here. I\'ll be waiting.',
		'',
		'- Sudo',
	}
	do image
		:SetAttribute('Texture', THEME:GetPathG('', 'what'))
		:SetCommand('Init', function(self)
			self
				:align(0, 1)
				:xy(SL, SB)
				:glow(0, 0, 0, 0.75)
		end)
		:AddToTree()
	end
	do top
		:SetAttribute('Font', 'Common Large')
		:SetAttribute('Text', 'Hey, wait a second!')
		:SetCommand('Init', function(self)
			self
				:valign(1)
				:y(-220)
		end)
	end
	do bottom
		:SetAttribute('Font', 'Sudo/Bold 36px')
		:SetAttribute('Text', table.concat(msg, '\n'))
		:SetCommand('Init', function(self)
			self
				:valign(0)
				:halign(0)
				:zoom(0.75)
				:xy(-210, -180)
		end)
	end
	do prompt
		:SetAttribute('Font', 'Common Large')
		:SetAttribute('Text', 'Got some songs? Press &START; to reload!')
		:SetCommand('Init', function(self)
			self
				:valign(0)
				:y(220)
		end)
		:SetCommand('On', function(self)
			SCREENMAN:GetTopScreen():AddInputCallback(LoadModule('Lua.InputSystem.lua')(self))
		end)
		:SetCommand('Start', function(self)
			SCREENMAN:SetNewScreen('ScreenReloadSongs')
		end)
		:SetCommand('Back', function(self)
			SCREENMAN:GetTopScreen():Cancel()
		end)
	end
	do af
		:SetCommand('Init', Actor.Center)
		:AddChild(top)
		:AddChild(bottom)
		:AddChild(prompt)
		:AddToTree()
	end
	return SuperActor.GetTree()
end
local AllGroups = LoadModule('Wheel/Group.List.lua')(AllSongs, TF_WHEEL.PreferredSort)
local SongList = LoadModule('Wheel/Group.Sort.lua')(AllSongs, TF_WHEEL.PreferredSort)

while Index.Group > #AllGroups do Index.Group = Index.Group - #AllGroups end
while Index.Group < 1 do Index.Group = Index.Group + #AllGroups end

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
			self:stoptweening():easeoutexpo(0.15):aux(aux)

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
		MESSAGEMAN:Broadcast('MoveWheel')
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
			self:stoptweening():easeoutexpo(0.15):aux(aux)

			if (i == wheel.Group.Inc and offset < 0) or (i == wheel.Group.Dec and offset > 0) then
				local contAF = self:GetChild('Container'..i)
				contAF:GetChild('Title'):settext(Groups[pos]):zoom(0.5):maxwidth(540)
			end
		end
		MESSAGEMAN:Broadcast('MoveWheel')
	else
		for i = 1, wheel.Group.Size do

			local off = i + wheel.Group.Ctr + 1
			while off > wheel.Group.Size do off = off - wheel.Group.Size end
			while off < 1 do off = off + wheel.Group.Size end

			local pos = Index.Group + i
			if i > 6 then
				pos = Index.Group + i - wheel.Group.Size
			end
			while pos > #Groups do pos = pos - #Groups end
			while pos < 1 do pos = #Groups + pos end

			local contAF = self:GetChild('Container'..off)
			contAF:GetChild('Title'):settext(Groups[pos]):zoom(0.5):maxwidth(540)

		end
	end
	CurGroup = AllGroups[Index.Group]
	CurSongs = SongList[CurGroup]
end


local songWheel = SuperActor.new('ActorScroller')
local songSelect = SuperActor.new('ActorFrame')

local groupCover = SuperActor.new('Quad')

local groupWheel = SuperActor.new('ActorScroller')
local groupSelect = SuperActor.new('ActorFrame')

local diffCover = SuperActor.new('Quad')

local songPreview = SuperActor.new('Actor')

local varControl = SuperActor.new('Actor')


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
	:SetAttribute('SecondsPerItem', 0)
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
			if GAMESTATE:GetNumPlayersEnabled() > 1 then
				GAMESTATE:SetCurrentStyle('versus')
			else
				GAMESTATE:SetCurrentStyle(style)
			end
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
		MESSAGEMAN:Broadcast('UnselectWheel')
	end)
	:SetCommand('MenuUp', function(self)
		if PlayersJoined[self.pn] then
			MoveSong(self, -1, CurSongs)
		end
	end)
	:SetCommand('MenuDown', function(self)
		if PlayersJoined[self.pn] then
			MoveSong(self, 1, CurSongs)
		end
	end)
	:SetCommand('MenuLeft', function(self)
		if PlayersJoined[self.pn] then
			MoveSong(self, -1, CurSongs)
		end
	end)
	:SetCommand('MenuRight', function(self)
		if PlayersJoined[self.pn] then
			MoveSong(self, 1, CurSongs)
		end
	end)
	:SetCommand('Back', function(self)
		if PlayersJoined[self.pn] then
			MESSAGEMAN:Broadcast('GroupUnselect')
		end
	end)
	:SetCommand('Select', function(self)
		if PlayersJoined[self.pn] then
			MESSAGEMAN:Broadcast('CycleSort')
		end
	end)
	:SetCommand('Start', function(self)
		-- If this player is not joined, join them.
		if not PlayersJoined[self.pn] then
			GAMESTATE:JoinPlayer(self.pn)
			GAMESTATE:LoadProfiles(true)
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

local songControl = SuperActor.new('ActorFrame')
do songControl
	:SetCommand('Init', function(self)
		self:xy(SL + 20, SB - 80)
	end)
	:SetMessage('SongUnselect', function(self)
		self:sleep(0.25):linear(0.25):diffusealpha(1)
	end)
	:SetMessage('SongSelect', function(self)
		self:linear(0.25):diffusealpha(0)
	end)
	:SetMessage('GroupUnselect', function(self)
		self:linear(0.25):diffusealpha(0)
	end)
	:SetMessage('GroupSelect', function(self)
		self:sleep(0.25):linear(0.25):diffusealpha(1)
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
			:SetAttribute('Text', '&LEFT;&DOWN;&UP;&RIGHT;: Change Song\n&START;: Select Song\n&BACK;: Switch to Group')
			:SetCommand('Init', function(self)
				self:halign(0):y(-30)
			end)
	)
	:AddToTree('SongControl')
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
		MESSAGEMAN:Broadcast('SelectWheel')
	end)
	:SetMessage('GroupUnselect', function(self)
		self:finishtweening():sleep(0.25):easeinoutexpo(0.25):addx(640)
		MESSAGEMAN:Broadcast('UnselectWheel')
	end)
	:SetCommand('MenuUp', function(self)
		if PlayersJoined[self.pn] then
			MoveGroup(self, -1, AllGroups)
			MoveSong(SuperActor.GetTree().SongWheel, 0, CurSongs, true)
		end
	end)
	:SetCommand('MenuDown', function(self)
		if PlayersJoined[self.pn] then
			MoveGroup(self, 1, AllGroups)
			MoveSong(SuperActor.GetTree().SongWheel, 0, CurSongs, true)
		end
	end)
	:SetCommand('MenuLeft', function(self)
		if PlayersJoined[self.pn] then
			MoveGroup(self, -1, AllGroups)
			MoveSong(SuperActor.GetTree().SongWheel, 0, CurSongs, true)
		end
	end)
	:SetCommand('MenuRight', function(self)
		if PlayersJoined[self.pn] then
			MoveGroup(self, 1, AllGroups)
			MoveSong(SuperActor.GetTree().SongWheel, 0, CurSongs, true)
		end
	end)
	:SetCommand('Back', function(self)
		-- If both players are joined, unjoin the player at input.
		if PlayersJoined[PLAYER_1] and PlayersJoined[PLAYER_2] then
			GAMESTATE:UnjoinPlayer(self.pn)
			GAMESTATE:SetCurrentStyle(style)
			PlayersJoined[self.pn] = false
		-- Otherwise, if this player is still joined, cancel to the previous screen.
		elseif PlayersJoined[self.pn] then
			SCREENMAN:PlayCancelSound()
			SCREENMAN:GetTopScreen():Cancel()
		end
	end)
	:SetCommand('Select', function(self)
		if PlayersJoined[self.pn] then
			MESSAGEMAN:Broadcast('CycleSort')
		end
	end)
	:SetCommand('Start', function(self)
		-- If this player is not joined, join them.
		if not PlayersJoined[self.pn] then
			GAMESTATE:JoinPlayer(self.pn)
			GAMESTATE:LoadProfiles(true)
			GAMESTATE:SetCurrentStyle('versus')
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

SuperActor.FromFile(THEME:GetPathG('OFSelectMusic', 'GroupInfo')):AddToTree('GroupInfo')

local groupControl = SuperActor.new('ActorFrame')
do groupControl
	:SetCommand('Init', function(self)
		self:xy(SL + 20, SB - 80):diffusealpha(0)
	end)
	:SetMessage('GroupUnselect', function(self)
		self:sleep(0.5):linear(0.1):diffusealpha(1)
	end)
	:SetMessage('GroupSelect', function(self)
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
			:SetAttribute('Text', '&LEFT;&DOWN;&UP;&RIGHT;: Change Group\n&START;: Select Group\n&BACK;: Exit to Title')
			:SetCommand('Init', function(self)
				self:halign(0):y(-30)
			end)
	)
	:AddToTree('GroupControl')
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

local changeSound = SuperActor.new('Sound')
local expandSound = SuperActor.new('Sound')
local collapseSound = SuperActor.new('Sound')

do changeSound
	:SetAttribute('File', THEME:GetPathS('MusicWheel', 'change'))
	:SetAttribute('IsAction', true)
	:SetAttribute('Precache', true)
	:SetCommand('Init', function(self)
		if not self:get() then
			self:load(THEME:GetPathS('MusicWheel', 'change'))
		end
		self:stop()
	end)
	:SetMessage('MoveWheel', function(self)
		self:play()
	end)
	:AddToTree()
end

do expandSound
	:SetAttribute('File', THEME:GetPathS('MusicWheel', 'expand'))
	:SetAttribute('IsAction', true)
	:SetAttribute('Precache', true)
	:SetCommand('Init', function(self)
		if not self:get() then
			self:load(THEME:GetPathS('MusicWheel', 'expand'))
		end
		self:stop()
	end)
	:SetMessage('SelectWheel', function(self)
		self:play()
	end)
	:AddToTree()
end

do collapseSound
	:SetAttribute('File', THEME:GetPathS('MusicWheel', 'collapse'))
	:SetAttribute('IsAction', true)
	:SetAttribute('Precache', true)
	:SetCommand('Init', function(self)
		if not self:get() then
			self:load(THEME:GetPathS('MusicWheel', 'collapse'))
		end
		self:stop()
	end)
	:SetMessage('UnselectWheel', function(self)
		self:play()
	end)
	:AddToTree()
end

do varControl
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
	:SetMessage('CycleSort', function(self)
		sortIdx = sortIdx + 1
		while sortIdx > #sorts do sortIdx = sortIdx - #sorts end
		TF_WHEEL.PreferredSort = sorts[sortIdx]
		AllGroups = LoadModule('Wheel/Group.List.lua')(AllSongs, TF_WHEEL.PreferredSort)
		SongList = LoadModule('Wheel/Group.Sort.lua')(AllSongs, TF_WHEEL.PreferredSort)
		CurGroup = AllGroups[Index.Group]
		CurSongs = SongList[CurGroup]
		MoveGroup(SuperActor.GetTree().GroupWheel, 0, AllGroups, true)
		MoveSong(SuperActor.GetTree().SongWheel, 0, CurSongs, true)
	end)
	:SetMessage('EnterOptions', function(self)
		wheel.NextScreen = 'ScreenPlayerOptions'
		self:sleep(0.25):queuecommand('BeginTransition')
	end)
	:SetMessage('EnterGameplay', function(self)
		SOUND:DimMusic(0, 3)
		wheel.NextScreen = 'ScreenStageInformation'
		self:sleep(0.25):queuecommand('BeginTransition')
	end)
	:SetCommand('BeginTransition', function(self)
		SCREENMAN:GetTopScreen()
			:SetNextScreenName(wheel.NextScreen)
			:StartTransitioningScreen('SM_GoToNextScreen')
	end)
	:AddToTree()
end

local previewAF = SuperActor.new('ActorFrame')

for plr in ivalues(GAMESTATE:GetEnabledPlayers()) do
	local PN = ToEnumShortString(plr)
	local preview = LoadModule('Chart.Preview.lua', plr)
	-- Wait until next alpha 5 release to add this. ~Sudo
	--previewAF:AddChild(preview, 'Preview'..PN)
end

do previewAF
	:SetCommand('Init', function(self)
		--self:y(SH)
	end)
	:SetCommand('SongSelect', function(self)
		self:sleep(0.25):easeoutexpo(0.5):y(0)
	end)
	:SetCommand('SongUnselect', function(self)
		--self:easeinexpo(0.5):y(SH)
	end)
	:AddToTree('PreviewFrame')
end

return SuperActor.GetTree()
