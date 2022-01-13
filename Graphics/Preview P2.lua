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
local plrpop = GAMESTATE:GetPlayerState(PlayerNumber[2]):GetPlayerOptions('ModsLevel_Preferred')
return Def.ActorFrame {
	Name = 'PlayerP2',
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
		self
			:xy(metricN('ScreenGameplay', 'PlayerP2'..plrpos..'X'), SCREEN_CENTER_Y)
			:vanishpoint(SCREEN_CENTER_X, SCREEN_CENTER_Y)
			:zoom(SCREEN_HEIGHT / 480)
			:visible(true)
	end,
	SpeedChoiceChangedMessageCommand = function(self, param)
		local poptions = self:GetChild('NoteField'):GetPlayerOptions('ModsLevel_Current')
		if param.pn ~= PlayerNumber[2] then return end
		local speedmod = param.mode:upper()..'Mod'
		if speedmod == 'XMod' then
			poptions:XMod(param.speed * 0.01)
		else
			poptions[speedmod](poptions, param.speed)
		end
	end,
	Def.NoteField {
		Name = 'NoteField',
		Player = PlayerNumber[2],
		FieldID = 2,
		Autoplay = true,
		NoteSkin = GAMESTATE:GetPlayerState(PlayerNumber[2]):GetPlayerOptions('ModsLevel_Preferred'):NoteSkin(),
		DrawDistanceAfterTargetsPixels = nf.dda,
		DrawDistanceBeforeTargetsPixels = nf.ddb,
		YReverseOffsetPixels = nf.yrevoff,
		SetupCommand = function(self)
			self
				:y(nf.y)
				:visible(true)
		end,
		CurrentStepsP2ChangedMessageCommand = function(self)
			self:SetNoteDataFromLua({})
			self:visible(false)
			local song = GAMESTATE:GetCurrentSong()
			if not song then return end
			local chart
			for n, c in ipairs(song:GetAllSteps()) do
				if c == GAMESTATE:GetCurrentSteps(PlayerNumber[2]) then
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
