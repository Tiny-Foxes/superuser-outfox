local ThemeColor = LoadModule('Theme.Colors.lua')

local diffs = {}
local diffs_af = Def.ActorFrame {
	ReadDiffsCommand = function(self)
		if GAMESTATE:GetCurrentSong() then
			for _, v in ipairs(GAMESTATE:GetCurrentSong():GetAllSteps()) do
				local d = v:GetDifficulty()
				local m = v:GetMeter()
				if diffs[d] ~= m then diffs[d] = v:GetMeter() end
			end
		end
	end,
	OnCommand = function(self)
		self:playcommand('ReadDiffs')
	end,
	ChangeStepsMessageCommand = function(self)
		self:playcommand('ReadDiffs')
	end,
	CurrentSongChangedMessageCommand = function(self)
		self:playcommand('ReadDiffs')
	end,
}

for i, v in ipairs({
	'Beginner',
	'Easy',
	'Medium',
	'Hard',
	'Challenge',
}) do
	diffs_af[#diffs_af + 1] = Def.ActorFrame {
		InitCommand = function(self)
			self
				:addx(-33 * (i - 1))
				:addy(66 * (i - 1))
		end,
		Def.Quad {
			InitCommand = function(self)
				self
					:SetSize(64, 56)
					:skewx(-0.5)
					:diffuse(ThemeColor[v])
			end,
		},
		Def.BitmapText {
			Font = 'Common Normal',
			Text = '--',
			DiffTextCommand = function(self)
				self:settext('--')
				if GAMESTATE:GetCurrentSong() then
					local d = diffs['Difficulty_'..v]
					if d then self:settext(d) end
				end
			end,
			OnCommand = function(self)
				self:queuecommand('DiffText')
			end,
			CurrentSongChangedMessageCommand = function(self)
				self:queuecommand('DiffText')
			end,
			ChangeStepsMessageCommand = function(self)
				self:queuecommand('DiffText')
			end,
		},
	}
end

return Def.ActorFrame {
	Name = 'Difficulties',
	InitCommand = function(self)
		self
			:x(276)
			:y(-12.5)
	end,
	diffs_af,
}
