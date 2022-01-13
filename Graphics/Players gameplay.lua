local af = Def.ActorFrame {
	Name = 'Gameplay',
}

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
---[[
for i, v in ipairs(GAMESTATE:GetEnabledPlayers()) do
	local plrpop = GAMESTATE:GetPlayerState(v):GetPlayerOptions('ModsLevel_Current')
	af[#af + 1] = Def.ActorFrame {
		Name = 'Player'..ToEnumShortString(v),
		FOV = 45,
		InitCommand = function(self)
			self:queuecommand('Setup')
		end,
		SetupCommand = function(self)
			local notefield = self:GetChild('NoteField')
			-- vanish points...........
			local function scale(var, lower1, upper1, lower2, upper2)
				return ((upper2 - lower2) * (var - lower1)) / (upper1 - lower1) + lower2
			end
			local poptions = notefield:GetPlayerOptions('ModsLevel_Current')
			local skew = poptions:Skew()
			local vanishx = self.vanishpointx
			local vanishy = self.vanishpointy
			local posx = self.x
			local posy = self.y
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
			function self:x(n)
				self:vanishpointx(n)
				return posx(self, n)
			end
			function self:y(n)
				self:vanishpointy(n)
				return posy(self, n)
			end
			function self:xy(x, y)
				return self:x(x):y(y)
			end
			function self:xyz(x, y, z)
				return self:xy(x, y):z(z)
			end
			function self:Center()
				return self:xy(SCREEN_CENTER_X, SCREEN_CENTER_Y)
			end
			function self:FullScreen()
				return self:Center():zoomto(SCREEN_WIDTH, SCREEN_HEIGHT)
			end
			self
				:xy(metricN('ScreenGameplay', 'Player'..ToEnumShortString(v)..plrpos..'X'), SCREEN_CENTER_Y)
				:zoom(SCREEN_HEIGHT / 480)
			notefield:y(nf.y)
			self:luaeffect('Poptions')
		end,
		PoptionsCommand = function(self)
			local pref = GAMESTATE:GetPlayerState(v):GetPlayerOptionsString('ModsLevel_Preferred')
			local poptions = self:GetChild('NoteField'):GetPlayerOptions('ModsLevel_Current')
			poptions:FromString(pref)
		end,
		Def.NoteField {
			Name = 'NoteField',
			Player = v,
			FieldID = i,
			Autoplay = GAMESTATE:GetPlayerState(v):GetPlayerOptions('ModsLevel_Preferred'):PlayerAutoPlay(),
			NoteSkin = GAMESTATE:GetPlayerState(v):GetPlayerOptions('ModsLevel_Preferred'):NoteSkin(),
			DrawDistanceAfterTargetsPixels = nf.dda,
			DrawDistanceBeforeTargetsPixels = nf.ddb,
			YReverseOffsetPixels = nf.yrevoff,
			InitCommand = function(self)
				self
					:y(nf.y)
					:SetStepCallback(function(param)
						print('steppy')
					end)
			end,
		},
		Def.Sprite { Name = 'Judgment' },
		Def.BitmapText { Name = 'Combo', Font = 'Common Normal'}
	}
end

return af
