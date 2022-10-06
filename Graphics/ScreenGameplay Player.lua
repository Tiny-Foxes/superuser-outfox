local pn = ...

local function metricN(class, metric)
	return tonumber(THEME:GetMetric(class, metric))
end

local plrpos
if GAMESTATE:GetNumPlayersEnabled() == 1 then
	plrpos = (PREFSMAN:GetPreference('Center1Player') and 'OnePlayerTwoSides') or 'OnePlayerOneSide'
else
	plrpos = 'TwoPlayersTwoSides'
end

local nf = {
	dda = metricN('Player', 'DrawDistanceAfterTargetsPixels'),
	ddb = metricN('Player', 'DrawDistanceBeforeTargetsPixels'),
	yrevoff = metricN('Player', 'ReceptorArrowsYReverse') - metricN('Player', 'ReceptorArrowsYStandard'),
	y = metricN('Player', 'ReceptorArrowsYStandard') + metricN('Player', 'ReceptorArrowsYReverse'),
}
local plrpop = GAMESTATE:GetPlayerState(pn):GetPlayerOptions('ModsLevel_Preferred')

return Def.ActorFrame {
	Name = 'Player'..ToEnumShortString(pn),
	FOV = 45,
	SetupCommand = function(self)
		self:fardistz(10000):fov(45)
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
			return self:GetChild('NoteField'):GetNoteData(start_beat, end_beat)
		end
		self
			:xy(metricN('ScreenGameplay', 'Player'..ToEnumShortString()..plrpos..'X'), SCREEN_CENTER_Y)
			:vanishpoint(SCREEN_CENTER_X - self:GetX(), SCREEN_CENTER_Y - self:GetY())
			:zoom(SCREEN_HEIGHT / 480)
			:visible(true)
	end,
	SpeedChoiceChangedMessageCommand = function(self, param)
		local poptions = self:GetChild('NoteField'):GetPlayerOptions('ModsLevel_Current')
		if param.pn ~= pn then return end
		local speedmod = param.mode:upper()..'Mod'
		if speedmod == 'XMod' then
			poptions:XMod(param.speed * 0.01)
		else
			poptions[speedmod](poptions, param.speed)
		end
	end,
	AppearanceChoiceChangedMessageCommand = function(self, param)
		PrintTable(param)
	end,
	ResetCommand = function(self)
		if self:GetNumWrapperStates() > 0 then
			for i = 1, self:GetNumWrapperStates() do
				self:GetWrapperState(i)
					:xy(0, 0):z(0)
					:rotationx(0)
					:rotationy(0)
					:rotationz(0)
					:zoom(1)
					:zoomx(1)
					:zoomy(1)
					:zoomz(1)
					:skewx(0)
					:skewy(0)
					:stopeffect()
					:fov(45)
					:visible(true)
				self:RemoveWrapperState(i)
			end
		end
		self
			:xy(metricN('ScreenGameplay', 'Player'..ToEnumShortString(pn)..plrpos..'X'), 0):z(0)
			:rotationx(0)
			:rotationy(0)
			:rotationz(0)
			:zoom(1)
			:zoomx(1)
			:zoomy(1)
			:zoomz(1)
			:skewx(0)
			:skewy(0)
			:stopeffect()
			:fov(45)
			:vanishpoint(0, 0)
			:zoom(SCREEN_HEIGHT / 480)
			:visible(true)
	end,
	Def.NoteField {
		Name = 'NoteField',
		Player = pn,
		FieldID = PlayerNumber:Reverse()[pn],
		AutoPlay = (PREFSMAN:GetPreference('AutoPlay') == 'Human' and false) or true,
		NoteSkin = GAMESTATE:GetPlayerState(pn):GetPlayerOptions('ModsLevel_Preferred'):NoteSkin(),
		DrawDistanceAfterTargetsPixels = nf.dda,
		DrawDistanceBeforeTargetsPixels = nf.ddb,
		YReverseOffsetPixels = nf.yrevoff,
		SetupCommand = function(self)
			self
				:y(nf.y)
				:visible(true)
		end,
		ResetCommand = function(self)
				self
				:xy(0, nf.y):z(0)
				:rotationx(0)
				:rotationy(0)
				:rotationz(0)
				:zoom(1)
				:zoomx(1)
				:zoomy(1)
				:zoomz(1)
				:skewx(0)
				:skewy(0)
				:stopeffect()
				:fov(45)
				:visible(true)
		end,
		CurrentStepsP1ChangedMessageCommand = function(self)
			self:SetNoteDataFromLua({})
			self:visible(false)
			local song = GAMESTATE:GetCurrentSong()
			if not song then return end
			local chart
			for n, c in ipairs(song:GetAllSteps()) do
				if c == GAMESTATE:GetCurrentSteps(pn) then
					chart = n
				end
			end
			if not chart then return end
			local nd = song:GetNoteData(chart)
			if not nd then return end
			self:SetNoteDataFromLua(nd)
			self:visible(true)
		end,
	},
	Def.Sprite { Name = 'Judgment' },
	Def.BitmapText { Name = 'Combo', Font = 'Common Normal' },
}
