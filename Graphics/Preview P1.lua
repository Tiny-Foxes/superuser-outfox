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
local state = GAMESTATE:GetPlayerState(PlayerNumber[1])
local plrpop = state:GetPlayerOptions('ModsLevel_Preferred')
local songpop = state:GetPlayerOptions('ModsLevel_Song')
local curpop = state:GetPlayerOptions('ModsLevel_Current')
local pref = state:GetPlayerOptionsString('ModsLevel_Preferred')


return Def.ActorFrame {
	Name = 'PlayerP1',
	FOV = 45,
	OnCommand = function(self)
		self:queuecommand('Setup')
	end,
	SetupCommand = function(self)
		self:fardistz(10000):fov(45)
		local notefield = self:GetChild('NoteField')
		local poptions = notefield:GetPlayerOptions('ModsLevel_Current')
		local skew = poptions:Skew()
		local vanishx = self.vanishpointx
		local vanishy = self.vanishpointy
		function self:vanishpointx(n)
			local offset = scale(skew, 0, 1, self:GetX(), SCREEN_CENTER_X)
			return vanishx(self, offset + n)
		end
		function self:vanishpointy(n)
			local offset = self:GetY() + nf.ybase
			return vanishy(self, offset + n)
		end
		function self:GetNoteData(start_beat, end_beat)
			return self:GetChild('NoteField'):GetNoteData(start_beat, end_beat)
		end
		self
			:xy(metricN('ScreenGameplay', 'PlayerP1'..plrpos..'X'), SCREEN_CENTER_Y)
			:vanishpointx(0)
			:vanishpointy(0)
			:zoom(SCREEN_HEIGHT / 480)
			:visible(true)
	end,
	-- this is a fuck
	Def.NoteField {
		Name = 'NoteField',
		Player = PlayerNumber[1],
		FieldID = 1,
		AutoPlay = (PREFSMAN:GetPreference('AutoPlay') == 'Human' and false) or true,
		NoteSkin = plrpop:NoteSkin(),
		DrawDistanceAfterTargetsPixels = nf.dda,
		DrawDistanceBeforeTargetsPixels = nf.ddb,
		YReverseOffsetPixels = nf.yrevoff,
		SetupCommand = function(self)
			self:GetPlayerOptions('ModsLevel_Current'):FromString(pref)
			self
				:y(nf.ybase)
				:visible(true)
				:luaeffect('UpdateTransform')
		end,
		UpdateTransformCommand = function(self)
			self:GetPlayerOptions('ModsLevel_Current')
				--:FromString(state:GetPlayerOptionsString('ModsLevel_Song'))
				:FromString(state:GetPlayerOptionsString('ModsLevel_Current'))
			local mini = scale(curpop:Mini(), 0, 1, 1, 0.5)
			local tilt = 1 - (0.1 * math.abs(curpop:Tilt()))
			local rotx = -30 * curpop:Tilt()
			self
				:zoom(mini * tilt)
				:rotationx(rotx)
		end,
		ResetCommand = function(self)
				self
				:xy(0, nf.ybase):z(0)
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
				:visible(true)
		end,
	},
	Def.Sprite { Name = 'Judgment' },
	Def.BitmapText { Name = 'Combo', Font = 'Common Normal' },
}
