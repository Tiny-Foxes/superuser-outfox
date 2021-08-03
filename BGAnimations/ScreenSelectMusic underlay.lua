local ThemeColor = LoadModule('Theme.Colors.lua')

local function CallSongFunc(func)
	local song = GAMESTATE:GetCurrentSong()
	if song then return song[func](song) end
	return ''
end

return Def.ActorFrame {
	InitCommand = function(self)
		self
			:xy(SCREEN_CENTER_X, SCREEN_CENTER_Y + 120)
	end,
	Def.Quad {
		InitCommand = function(self)
			self
				:SetSize(SCREEN_WIDTH * 1.5, 428)
				:diffuse(ThemeColor.Black)
				:skewx(-0.5)
				:fadetop(0.01)
				:fadebottom(0.01)
				:diffusealpha(0.75)
				:fadeleft(0.1)
				:cropleft(1)
		end,
		OnCommand = function(self)
			self
				:easeoutexpo(0.25)
				:fadeleft(0)
				:cropleft(0)
		end,
		OffCommand = function(self)
			self
				:sleep(0.25)
				:easeoutexpo(0.25)
				:fadeleft(0.1)
				:cropleft(1)
		end,
	},
	Def.Quad {
		InitCommand = function(self)
			self
				:SetSize(SCREEN_WIDTH * 1.5, 420)
				:diffuse(ThemeColor.Primary)
				:skewx(-0.5)
				:diffusealpha(0.25)
				:fadeleft(0.1)
				:cropleft(1)
		end,
		OnCommand = function(self)
			self
				:easeoutexpo(0.25)
				:fadeleft(0)
				:cropleft(0)
		end,
		OffCommand = function(self)
			self
				:sleep(0.25)
				:easeinexpo(0.25)
				:fadeleft(0.1)
				:cropleft(1)
		end,
	},
	Def.ActorFrame {
		InitCommand = function(self)
			self
				:x(-SCREEN_CENTER_X)
		end,
		Def.Quad {
			InitCommand = function(self)
				self
					:skewx(-0.5)
					:SetSize(SCREEN_WIDTH * 0.5, 320)
					:diffuse(ThemeColor.Elements)
					:shadowlength(2, 2)
					:diffusealpha(0.5)
					:faderight(0.1)
					:cropright(1)
			end,
			OnCommand = function(self)
				self
					:sleep(0.25)
					:easeoutexpo(0.25)
					:faderight(0)
					:cropright(0)
			end,
			OffCommand = function(self)
				self
					:easeinexpo(0.25)
					:faderight(0.1)
					:cropright(1)
			end,
		},
		-- Song Info
		Def.ActorFrame {
			Name = 'SongInfo',
			InitCommand = function(self)
				self
					:x(152)
					:y(10)
					--:y(-120)
					:addx(-SCREEN_CENTER_X + ((SCREEN_WIDTH / SCREEN_HEIGHT) - (640 / 480)) * 100)
			end,
			OnCommand = function(self)
				self
					:sleep(0.25)
					:easeoutexpo(0.25)
					:addx(SCREEN_CENTER_X)
			end,
			OffCommand = function(self)
				self
					:easeinexpo(0.25)
					:addx(-SCREEN_CENTER_X)
			end,
			Def.BitmapText {
				Name = 'InfoLabels',
				Font = 'Common Normal',
				Text = 'Notes\nHolds\nRolls\nJumps\nHands\n\nMines\nLifts\nFakes',
				InitCommand = function(self)
					self
						:x(-140)
						:addy(-10)
						:horizalign('left')
						:addx(-SCREEN_CENTER_X)
						:maxwidth(60)
				end,
				OnCommand = function(self)
					self
						:sleep(0.25)
						:easeoutexpo(0.25)
						:addx(SCREEN_CENTER_X)
				end,
				OffCommand = function(self)
					self
						:easeinexpo(0.25)
						:addx(-SCREEN_CENTER_X)
				end,
			},
			Def.BitmapText {
				Name = 'StepInfoP1',
				Font = 'Common Normal',
				Text = '--\n--\n--\n--\n--\n\n--\n--\n--',
				InitCommand = function(self)
					self
						:addx(-60)
						:horizalign('left')
						:maxwidth(40)
						:visible(GAMESTATE:IsSideJoined(PLAYER_1))
						:diffuse(ColorLightTone(PlayerColor(PLAYER_1)))
				end,
				PlayerJoinedMessageCommand = function(self, param)
					self:visible(GAMESTATE:IsSideJoined(PLAYER_1))
				end,
				CurrentStepsP1ChangedMessageCommand = function(self)
					local song = GAMESTATE:GetCurrentSong()
					local course = GAMESTATE:GetCurrentCourse()
					if not song and not course then
						self:settext('--\n--\n--\n--\n--\n\n--\n--\n--')
					else
						local steps = GAMESTATE:GetCurrentSteps(PLAYER_1)
						local ret = ''
						for i, v in ipairs({
							'TapsAndHolds',
							'Holds',
							'Rolls',
							'Jumps',
							'Hands',
							'Mines',
							'Lifts',
							'Fakes'
						}) do
							local num = steps:GetRadarValues(PLAYER_1):GetValue('RadarCategory_'..v)
							ret = ret..num ..'\n'
							if v == 'Hands' then ret = ret..'\n' end
						end
						self:settext(ret)
					end
				end,
			},
			Def.BitmapText {
				Name = 'StepInfoP2',
				Font = 'Common Normal',
				Text = '--\n--\n--\n--\n--\n\n--\n--\n--',
				InitCommand = function(self)
					self
						:addx(0)
						:horizalign('left')
						:maxwidth(40)
						:visible(GAMESTATE:IsSideJoined(PLAYER_2))
						:diffuse(ColorLightTone(PlayerColor(PLAYER_2)))
				end,
				PlayerJoinedMessageCommand = function(self, param)
					self:visible(GAMESTATE:IsSideJoined(PLAYER_2))
				end,
				CurrentStepsP2ChangedMessageCommand = function(self)
					local song = GAMESTATE:GetCurrentSong()
					local course = GAMESTATE:GetCurrentCourse()
					if not song and not course then
						self:settext('--\n--\n--\n--\n--\n\n--\n--\n--')
					else
						local steps = GAMESTATE:GetCurrentSteps(PLAYER_2)
						local ret = ''
						for i, v in ipairs({
							'TapsAndHolds',
							'Holds',
							'Rolls',
							'Jumps',
							'Hands',
							'Mines',
							'Lifts',
							'Fakes'
						}) do
							local num = steps:GetRadarValues(PLAYER_2):GetValue('RadarCategory_'..v)
							ret = ret..num ..'\n'
							if v == 'Hands' then ret = ret..'\n' end
						end
						self:settext(ret)
					end
				end,
			}
		},
	},
	LoadActor(THEME:GetPathG('ScreenSelectMusic', 'DifficultyList')),
}