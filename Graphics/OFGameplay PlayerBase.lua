local function metricN(class, metric)
	return tonumber(THEME:GetMetric(class, metric))
end

local function scale(var, lower1, upper1, lower2, upper2)
	return ((upper2 - lower2) * (var - lower1)) / (upper1 - lower1) + lower2
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
	ybase = metricN('Player', 'ReceptorArrowsYStandard') + metricN('Player', 'ReceptorArrowsYReverse'),
}

return function(pn)

	local state = GAMESTATE:GetPlayerState(pn)
	local prefpop = state:GetPlayerOptions('ModsLevel_Preferred')
	local curpop = state:GetPlayerOptions('ModsLevel_Current')
	local pref = state:GetPlayerOptionsString('ModsLevel_Preferred')

	return Def.ActorFrame {
		Name = 'Player'..ToEnumShortString(pn),
		FOV = 45,
		OnCommand = function(self)
			self:queuecommand('Setup')
		end,
		SetupCommand = function(self)
			self:fardistz(10000):fov(45)
			local notefield = self:GetChild('NoteField')
			local poptions = notefield:GetPlayerOptions('ModsLevel_Current')
			local vanishx = self.vanishpointx
			local vanishy = self.vanishpointy
			function self:vanishpointx(n)
				local offset = scale(poptions:Skew(), 0, 1, self:GetX(), SCREEN_CENTER_X)
				return vanishx(self, offset + n)
			end
			function self:vanishpointy(n)
				local offset = self:GetY() + nf.ybase
				return vanishy(self, offset + n)
			end
			function self:vanishpoint(x, y)
				return self:vanishpointx(x):vanishpointy(y)
			end
			function self:GetNoteData(start_beat, end_beat)
				return self:GetChild('NoteField'):GetNoteData(start_beat, end_beat)
			end
			self
				:xy(metricN('ScreenGameplay', 'Player'..ToEnumShortString(pn)..plrpos..'X'), SCREEN_CENTER_Y)
				:vanishpoint(0, 0)
				:zoom(SCREEN_HEIGHT / 480)
				:visible(true)
		end,
		-- this is a fuck
		Def.NoteField {
			Name = 'NoteField',
			Player = pn,
			FieldID = PlayerNumber:Reverse()[pn],
			AutoPlay = (PREFSMAN:GetPreference('AutoPlay') == 'Human' and false) or true,
			NoteSkin = prefpop:NoteSkin(),
			DrawDistanceAfterTargetsPixels = nf.dda,
			DrawDistanceBeforeTargetsPixels = nf.ddb,
			YReverseOffsetPixels = nf.yrevoff,
			SetupCommand = function(self)
				self:GetPlayerOptions('ModsLevel_Current'):FromString(pref)
				self
					:y(nf.ybase)
					:visible(true)
					:luaeffect('UpdateMods')
			end,
			UpdateModsCommand = function(self)
				local po = self:GetPlayerOptions('ModsLevel_Current')
				po:FromString(state:GetPlayerOptionsString('ModsLevel_Current'))
				local mini = scale(po:Mini(), 0, 1, 1, 0.5)
				local tilt = 1 - (0.1 * math.abs(po:Tilt()))
				local rotx = -30 * po:Tilt()
				self
					:zoom(mini * tilt)
					:rotationx(rotx)
			end,
		},
		Def.Sprite {
			Name = 'Judgment',
			InitCommand = function(self)
				self:y(-20)
			end,
		},
		Def.BitmapText {
			Name = 'Combo',
			Font = 'Common Normal',
			InitCommand = function(self)
				self:y(20)
			end,
		},
	}

end