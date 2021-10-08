local ThemeColor = LoadModule('Theme.Colors.lua')

local t = Def.ActorFrame {
}

local plr = ...

local playerstats = STATSMAN:GetCurStageStats():GetPlayerStageStats(plr)
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

local function GetPlrDiff()
	local diff = GAMESTATE:GetCurrentSteps(plr):GetDifficulty()
	local cdiff = THEME:GetString("CustomDifficulty",ToEnumShortString(diff))
	local meter = GAMESTATE:GetCurrentSteps(plr):GetMeter()
	return cdiff..'  '..meter
end

t[#t + 1] = Def.ActorFrame {
	InitCommand = function(self)
	end,
	Def.Quad {
		InitCommand = function(self)
			self
				:addy(-80)
				:SetSize(SCREEN_CENTER_X * 0.75, 140)
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
	GAMESTATE:IsSideJoined(plr) and Def.BitmapText {
		Font = '_xiaxide 80px',
		Text = GetPlrGrade(),
		InitCommand = function(self)
			local diff = GAMESTATE:GetCurrentSteps(plr):GetDifficulty()
			local cdiff = THEME:GetString("CustomDifficulty",ToEnumShortString(diff))
			self
				:skewx(0.25)
				:addx(10)
				:addy(-58)
				:zoom(2)
				:diffuse(ColorLightTone(PlayerColor(plr)))
				:addx(40)
				:diffusealpha(0)
		end,
		OnCommand = function(self)
			self
				:queuecommand('Bob')
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
		BobCommand=function(self)
			self
				:bob()
				:effectperiod(8)
				:effectmagnitude(-4, 0, 0)
		end,
	},
	GAMESTATE:IsSideJoined(plr) and Def.ActorFrame {
		InitCommand = function(self)
			self:xy(SCREEN_CENTER_X * 0.3, 30)
		end,
		Def.BitmapText {
			Font = '_xide/40px',
			Text = GetPlrScore(),
			InitCommand = function(self)
				self
					:skewx(0.25)
					:horizalign('right')
					:zoom(1.5)
					:diffuse(ColorLightTone(PlayerColor(plr)))
					:addx(-40)
					:diffusealpha(0)
			end,
			OnCommand = function(self)
				self
					:queuecommand('Bob')
					:sleep(0.55)
					:easeoutexpo(0.5)
					:addx(40)
					:diffusealpha(1)
			end,
			OffCommand = function(self)
				self
					:sleep(0.05)
					:easeinexpo(0.25)
					:addx(-40)
					:diffusealpha(0)
			end,
			BobCommand=function(self)
				self
					:bob()
					:effectperiod(8)
					:effectmagnitude(4, 0, 0)
			end,
		},
	},
}

t[#t + 1] = Def.ActorFrame {
	InitCommand = function(self)
		self:y(180)
	end,
	Def.Quad {
		InitCommand = function(self)
			self
				:addy(35)
				:SetSize(SCREEN_CENTER_X * 0.75, 275)
				:diffuse(color('#000000'))
				:diffusealpha(0.25)
				:cropright(1)
		end,
		OnCommand = function(self)
			self
				:sleep(0.15)
				:easeinoutexpo(0.25)
				:cropright(0)
		end,
		OffCommand = function(self)
			self
				:sleep(0.15)
				:easeinoutexpo(0.25)
				:cropright(1)
		end,
	},
	GAMESTATE:IsSideJoined(plr) and loadfile(THEME:GetPathB('ScreenEvaluation', 'underlay/Page1.lua'))(plr)
}

return t