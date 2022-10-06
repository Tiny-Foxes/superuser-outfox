local plr = lua.GetThreadVariable('Player') or ...
if not plr then return Def.Actor {} end

local konko = LoadModule('Konko.Core.lua')
konko()

local SuperActor = LoadModule('Konko.SuperActor.lua')

local function metric(str)
	return tonumber(THEME:GetMetric('Player', str))
end

local nfattr = {
	dda = metric 'DrawDistanceAfterTargetsPixels',
	ddb = metric 'DrawDistanceBeforeTargetsPixels',
	yrevoff = metric 'ReceptorArrowsYReverse' - metric 'ReceptorArrowsYStandard',
	y = metric 'ReceptorArrowsYStandard' + metric 'ReceptorArrowsYReverse'
}

local pref = GAMESTATE:GetPlayerState(plr):GetPlayerOptions('ModsLevel_Preferred')

local PN = ToEnumShortString(plr)

local plrpos
if GAMESTATE:GetNumPlayersEnabled() == 1 then
	plrpos = (PREFSMAN:GetPreference('Center1Player') and 'OnePlayerTwoSides') or 'OnePlayerOneSide'
else
	plrpos = 'TwoPlayersTwoSides'
end

local preview = SuperActor.new('ActorFrame')
local nf = SuperActor.new('NoteField')

do nf
	:SetAttribute('Player', plr)
	:SetAttribute('AutoPlay', true)
	:SetAttribute('NoteSkin', pref:NoteSkin())
	:SetAttribute('DrawDistanceAfterTargetsPixels', nfattr.dda)
	:SetAttribute('DrawDistanceBeforeTargetsPixels', nfattr.ddb)
	:SetAttribute('YReverseOffsetPixels', nfattr.yrevoff)
	:SetCommand('Setup', function(self)
		self:y(nfattr.y):SetUpdateFunction(function(self)
			ArrowEffects.Update()
			self:GetPlayerOptions('ModsLevel_Current')
				:FromString(GAMESTATE:GetPlayerState(plr):GetPlayerOptionsString('ModsLevel_Preferred'))
		end)
	end)
	:SetCommand('SetDifficulty'..PN, function(self)
		self:queuecommand('SetPreviewChart')
	end)
	:SetCommand('SetPreviewChart', function(self)
		self:AutoPlay(false)
		local song = GAMESTATE:GetCurrentSong()
		if not song then return end
		local chart
		for n, c in ipairs(song:GetAllSteps()) do
			if c == GAMESTATE:GetCurrentSteps(plr) then
				chart = n
			end
		end
		if not chart then return end
		local nd = song:GetNoteData(chart)
		if not nd then return end
		self:SetNoteDataFromLua(nd)
		self:AutoPlay(true)
	end)
end

do preview
	:SetAttribute('FOV', 45)
	:SetCommand('On', function(self)
		self:queuecommand('Setup')
	end)
	:SetCommand('Setup', function(self)
		self:fardistz(9e9)
		local po = self:GetChild('NoteField'):GetPlayerOptions('ModsLevel_Current')
		function self:vanishpointx(n)
			local offset = scale(po:Skew(), 0, 1, self:GetX(), SCREEN_CENTER_X)
			return ActorFrame.vanishpointx(self, offset + n)
		end
		function self:vanishpointy(n)
			local offset = SCY
			return ActorFrame.vanishpointy(self, offset + n)
		end
		function self:vanishpoint(x, y)
			return self:vanishpointx(x):vanishpointy(y)
		end
		function self:x(n)
			self:vanishpointx(n - SCX)
			return Actor.x(self, n)
		end
		function self:y(n)
			self:vanishpointy(n - SCY)
			return Actor.y(self, n)
		end
		function self:xy(x, y)
			return self:x(x):y(y)
		end
		function self:Center()
			return self:xy(SCX, SCY)
		end
		self
			:xy(tonumber(THEME:GetMetric('ScreenGameplay', 'Player'..PN..plrpos..'X')), SCY)
			:zoom(SH / 480)
			:queuecommand('Setup')
	end)
	:AddChild(nf, 'NoteField')
	:AddToTree('Player')
end

return SuperActor.GetTree()
