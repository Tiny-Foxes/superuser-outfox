local function metricN(class, metric)
	return tonumber(THEME:GetMetric(class, metric))
end

local plrpos
if GAMESTATE:GetNumPlayersEnabled() == 1 then
	plrpos = (PREFSMAN:GetPreference('Center1Player') and 'OnePlayerTwoSides') or 'OnePlayerOneSide'
else
	plrpos = 'TwoPlayersTwoSides'
end

local song, songpos

local nf = {
	dda = metricN('Player', 'DrawDistanceAfterTargetsPixels'),
	ddb = metricN('Player', 'DrawDistanceBeforeTargetsPixels'),
	yrevoff = metricN('Player', 'ReceptorArrowsYReverse') - metricN('Player', 'ReceptorArrowsYStandard'),
	y = metricN('Player', 'ReceptorArrowsYStandard') + metricN('Player', 'ReceptorArrowsYReverse'),
	chart = {}
}

local af = Def.ActorFrame {
	Name = 'Preview',
	OnCommand = function(self)
		local aft = self:GetChild('PreviewAFT')
		local preview = self:GetChild('PreviewSprite')
		preview:SetTexture(aft:GetTexture())
		self:queuemessage('Setup')
	end,
	SetupMessageCommand = function(self)
		song = GAMESTATE:GetCurrentSong()
		songpos = GAMESTATE:GetSongPosition()
		if not song then return end
		local chart = {}
		for n, c in ipairs(song:GetAllSteps()) do
			for i, v in ipairs(GAMESTATE:GetEnabledPlayers()) do
				if c == GAMESTATE:GetCurrentSteps(v) then
					chart[i] = n
				end
			end
		end
		for i = 1, #chart do
			local nd = song:GetNoteData(chart[i])
			nf.chart[i] = nd
		end
		self:luaeffect('CheckMusicLoop')
	end,
	CurrentSongChangedMessageCommand = function(self)
		song = GAMESTATE:GetCurrentSong()
		songpos = GAMESTATE:GetSongPosition()
	end,
	CheckMusicLoopCommand = function(self)
		if not song then return end
		local sample_end = song:GetSampleStart() + song:GetSampleLength()
		local target = sample_end - songpos:GetMusicSeconds()
		local dt = self:GetEffectDelta()

		if target >= (0.5 - dt * 2) and target <= (0.5 + dt * 2) then
			MESSAGEMAN:Broadcast('MusicLoopNearEnd')
		end
		if target >= (song:GetSampleLength() - dt * 2) and target <= (song:GetSampleLength() + dt * 2) then
			MESSAGEMAN:Broadcast('MusicLoopEnd')
		end
	end,
}
local aft = Def.ActorFrameTexture {
	Name = 'PreviewAFT',
	InitCommand = function(self)
		self
			:SetSize(SCREEN_WIDTH, SCREEN_HEIGHT)
			:EnableAlphaBuffer(true)
			:EnableDepthBuffer(false)
			:EnableFloat(false)
			:EnablePreserveTexture(false)
			:Create()
	end,
}

af[#af + 1] = aft

local plrs = Def.ActorFrame {
	Name = 'PlayerFrame',
	InitCommand = function(self)
		self
			:Center()
			-- how glowramp work .n.
			--[[
			:glowramp()
			:effectcolor1(color('#FFFFFF'))
			:effectcolor2(color('#AAAAAA'))
			--:effectmagnitude(1.01, 1, 1)
			:effecttiming(0.1, 0, 0.4, 0, 0.5)
			:effectclock('bgm')
			--]]
	end,
	OnCommand = function(self)
		self:luaeffect('UpdateEffects')
	end,
	UpdateEffectsCommand = function(self)
		ArrowEffects.Update()
	end,
}

aft[#aft + 1] = plrs

---[[
for i, v in ipairs(GAMESTATE:GetEnabledPlayers()) do
	local plrpop = GAMESTATE:GetPlayerState(v):GetPlayerOptions('ModsLevel_Preferred')
	plrs[#plrs + 1] = Def.ActorFrame {
		Name = 'Player'..ToEnumShortString(v),
		FOV = 45,
		SetupMessageCommand = function(self)
			local notefield = self:GetChild('NoteField')
			-- vanish points...........
			local function scale(var, lower1, upper1, lower2, upper2)
				return ((upper2 - lower2) * (var - lower1)) / (upper1 - lower1) + lower2
			end
			local poptions = notefield:GetPlayerOptions('ModsLevel_Current')
			local skew = poptions:Skew()
			local vanishx = self.vanishpointx
			local vanishy = self.vanishpointy
			function self:vanishpointx(n)
				local offset = scale(skew, 0, 1, self:GetX(), SCREEN_CENTER_X)
				return vanishx(self, offset + n)
			end
			function self:vanishpointy(n)
				local offset = SCREEN_CENTER_Y
				return vanishy(self, offset + n)
			end
			function self:vanishpoint(x, y)
				return self:vanishpointx(x):vanishpointy(y)
			end
			function self:GetNoteData(start_beat, end_beat)
				self:GetChild('NoteField'):GetNoteData(start_beat, end_beat)
				return self
			end
			function self:SetNoteDataFromLua(t)
				self:GetChild('NoteField'):SetNoteDataFromLua(t)
				return self
			end
			function self:SetNoteData(i)
				local nd = GAMESTATE:GetCurrentSong():GetNoteData(i)
				return self:SetNoteDataFromLua(nd)
			end
			local plr = SCREENMAN:GetTopScreen():GetChild('Player'..ToEnumShortString(v))
			if plr then
				self
					:SetFakeParent(plr)
					:addx(-SCREEN_CENTER_X * 480 / SCREEN_HEIGHT)
					:addy(-SCREEN_CENTER_Y * 480 / SCREEN_HEIGHT)
					:vanishpoint(SCREEN_CENTER_X, SCREEN_CENTER_Y)
			else
				self
					:xy(metricN('ScreenGameplay', 'Player'..ToEnumShortString(v)..plrpos..'X') - SCREEN_CENTER_X, 0)
					:basezoom(SCREEN_HEIGHT / 480)
					:vanishpoint(SCREEN_CENTER_X, SCREEN_CENTER_Y)
				if GAMESTATE:GetNumPlayersEnabled() < 2 then self:x(0):vanishpointx(SCREEN_CENTER_X) end
			end
			self:luaeffect('UpdateMods')
		end,
		SpeedChoiceChangedMessageCommand = function(self, params)
			local poptions = self:GetChild('NoteField'):GetPlayerOptions('ModsLevel_Current')
			if params.pn ~= v then return end
			local speedmod = params.mode:upper()..'Mod'
			if speedmod == 'XMod' then
				poptions:XMod(params.speed * 0.01)
			else
				poptions[speedmod](poptions, params.speed)
			end
		end,
		UpdateModsCommand = function(self, param)
			if not SCREENMAN:GetTopScreen().GetGoToOptions then return end
			if getenv('NewOptions') ~= 'Effects' then return end
			local scr = SCREENMAN:GetTopScreen()
			local idx = scr:GetCurrentRowIndex(v)
			local opt = scr:GetOptionRow(idx)
			print(opt:GetChoiceInRowWithFocus(v))
			self:GetChild('NoteField'):GetPlayerOptions('ModsLevel_Current')
				:FromString(GAMESTATE:GetPlayerState(v):GetPlayerOptionsString('ModsLevel_Preferred'))
		end,
		Def.NoteField {
			Name = 'NoteField',
			Player = v,
			FieldID = i,
			AutoPlay = true,
			NoteSkin = GAMESTATE:GetPlayerState(v):GetPlayerOptions('ModsLevel_Preferred'):NoteSkin(),
			DrawDistanceAfterTargetsPixels = nf.dda,
			DrawDistanceBeforeTargetsPixels = nf.ddb,
			YReverseOffsetPixels = nf.yrevoff,
			SetupMessageCommand = function(self)
				self:y(nf.y)
				self:GetPlayerOptions('ModsLevel_Current')
					:FromString(GAMESTATE:GetPlayerState(v):GetPlayerOptionsString('ModsLevel_Preferred'))
				self:luaeffect('UpdateTransform')
			end,
			UpdateTransformCommand = function(self)
				local poptions = GAMESTATE:GetPlayerState(v):GetPlayerOptions('ModsLevel_Song')
				local mini = scale(poptions:Mini(), 0, 1, 1, 0.5)
				local tilt = 1 - (0.1 * math.abs(poptions:Tilt()))
				local rotx = -30 * poptions:Tilt()
				self
					:zoom(mini * tilt)
					:rotationx(rotx)
			end,
			['CurrentSteps'..ToEnumShortString(v)..'ChangedMessageCommand'] = function(self)
				self:queuecommand('SetPreviewChart')
			end,
			SetPreviewChartCommand = function(self)
				self:AutoPlay(false)
				self:SetNoteDataFromLua({})
				if not song then return end
				local chart
				for n, c in ipairs(song:GetAllSteps()) do
					if c == GAMESTATE:GetCurrentSteps(v) then
						chart = n
					end
				end
				if not chart then return end
				local nd = song:GetNoteData(chart)
				if not nd then return end
				self:SetNoteDataFromLua(nd)
				self:AutoPlay(true)
				nf.chart[i] = nd
			end,
			MusicLoopEndMessageCommand = function(self)
				self:AutoPlay(false)
				self:SetNoteDataFromLua(nf.chart[i])
				self:AutoPlay(true)
			end,
			LuaNoteSkinsChangedMessageCommand = function(self, param)
				if param.pn ~= v then return end
				self:GetPlayerOptions('ModsLevel_Current'):NoteSkinCol(nil, param.choicename)
			end,
		},
		Def.Sprite { Name = 'Judgment', InitCommand = function(self) self:visible(false) end },
		Def.BitmapText { Name = 'Combo', Font = 'Common Normal', InitCommand = function(self) self:visible(false) end },
	}
end
--]]

af[#af + 1] = Def.Sprite {
	Name = 'PreviewSprite',
	InitCommand = function(self)
		self:Center():fadetop(0.25):fadebottom(0.25):glow(0, 0, 0, 0.5)
	end,
	OnCommand = function(self)
		--self:queuecommand('SetPreviewColor')
	end,
	CurrentSongChangedMessageCommand = function(self)
		--self:queuecommand('SetPreviewColor')
	end,
	SetPreviewColorCommand = function(self)
		local TS = SCREENMAN:GetTopScreen()
		if not TS.GetMusicWheel then return end
		if not song then return end
		local bpms = song:GetDisplayBpms()
		local bpm = bpms[#bpms]
		local red = math.min(bpm / 255, 1) * 0.5
		self
			:stoptweening()
			:sleep(0.25)
			:easeinoutcircle(1)
			:diffuse(0.5 + red, 1 - red, 0.5, 1)
	end,
	CurrentSongChangedMessageCommand = function(self)
		self:stoptweening():diffusealpha(0):glow(0, 0, 0, 0)
	end,
	MusicLoopNearEndMessageCommand = function(self)
		self:stoptweening():diffusealpha(1):easeinoutcircle(0.25):diffusealpha(0):glow(0, 0, 0, 0)
	end,
	MusicLoopEndMessageCommand = function(self)
		self:stoptweening():diffusealpha(0):easeinoutcircle(0.25):diffusealpha(1):glow(0, 0, 0, 0.5)
	end,
}

return af
