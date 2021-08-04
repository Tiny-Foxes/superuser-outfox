local t = Def.ActorFrame {
}

local plr = ...

local playerstats = STATSMAN:GetCurStageStats():GetPlayerStageStats(plr)
local notescores = {
	--Taps = playerstats:GetTapNoteScores()
}
local grades = {
	Grade_Tier01 = 'SSS',
	Grade_Tier02 = 'SS+',
	Grade_Tier03 = 'SS',
	Grade_Tier04 = 'SS-',
	Grade_Tier05 = 'S+',
	Grade_Tier06 = 'S',
	Grade_Tier07 = 'S-',
	Grade_Tier08 = 'A+',
	Grade_Tier09 = 'A',
	Grade_Tier10 = 'A-',
	Grade_Tier11 = 'B+',
	Grade_Tier12 = 'B',
	Grade_Tier13 = 'B-',
	Grade_Tier14 = 'C+',
	Grade_Tier15 = 'C',
	Grade_Tier16 = 'C-',
	Grade_Tier17 = 'D',
	Grade_Failed = 'F',
}

local function GetPlrScore()
	return FormatPercentScore(playerstats:GetPercentDancePoints())
end

local function GetPlrGrade()
	local grade = grades[playerstats:GetGrade()]
	return grade
end

lua.Trace(grades[playerstats:GetGrade()]) 



t[#t + 1] = Def.ActorFrame {
	InitCommand = function(self)
	end,
	Def.Quad {
		InitCommand = function(self)
			self
				:addy(-60)
				:SetSize(SCREEN_CENTER_X * 0.75, 160)
				:diffuse(color('#000000'))
				:diffusealpha(0.25)
				:cropright(1)
		end,
		OnCommand = function(self)
			self
				:sleep(0.25)
				:easeinoutexpo(0.25)
				:cropright(0)
		end,
		OffCommand = function(self)
			self
				:sleep(0.25)
				:easeinoutexpo(0.25)
				:cropright(1)
		end,
	},
	Def.BitmapText {
		Font = '_xiaxide 80px',
		Text = GetPlrGrade(),
		InitCommand = function(self)
			self
				:skewx(0.25)
				:addx(10)
				:addy(-40)
				:zoom(1.75)
				:diffuse(ColorLightTone(PlayerColor(plr)))
				:addx(40)
				:diffusealpha(0)
		end,
		OnCommand = function(self)
			self
				:sleep(0.5)
				:easeoutexpo(0.5)
				:addx(-40)
				:diffusealpha(1)
		end,
		OffCommand = function(self)
			self
				:easeinexpo(0.25)
				:addx(40)
				:diffusealpha(0)
		end,
	},
	Def.ActorFrame {
		InitCommand = function(self)
			self:xy(SCREEN_CENTER_X * 0.165, 60)
		end,
		Def.BitmapText {
			Font = '_xide/40px',
			Text = GetPlrScore(),
			InitCommand = function(self)
				self
					:skewx(0.25)
					:horizalign('right')
					:x(20)
					:zoom(1.5)
					:diffuse(ColorLightTone(PlayerColor(plr)))
					:addx(40)
					:diffusealpha(0)
			end,
			OnCommand = function(self)
				self
					:sleep(0.55)
					:easeoutexpo(0.5)
					:addx(-40)
					:diffusealpha(1)
			end,
			OffCommand = function(self)
				self
					:sleep(0.05)
					:easeinexpo(0.25)
					:addx(40)
					:diffusealpha(0)
			end,
		},
	},
}

t[#t + 1] = loadfile(THEME:GetPathB('ScreenEvaluation', 'underlay/Page1.lua'))(plr)

return t