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
	OnCommand = function(self)
		-- discord support UwU -y0sefu
		local player = GAMESTATE:GetMasterPlayerNumber()
		GAMESTATE:UpdateDiscordProfile(GAMESTATE:GetPlayerDisplayName(player))
		if GAMESTATE:IsCourseMode() then
			GAMESTATE:UpdateDiscordScreenInfo("Selecting Course","",1)
		else
			local StageIndex = GAMESTATE:GetCurrentStageIndex()
			GAMESTATE:UpdateDiscordScreenInfo("Selecting a Song (Stage ".. StageIndex + 1 .. ")	","",1)
		end
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
					:SetSize(SCREEN_WIDTH * 0.5 + 24, 320)
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
			Name = 'BannerFrame',
			InitCommand = function(self)
				self
					:xy(48, -SCREEN_CENTER_Y + 104)
					:diffusealpha(0)
					:addx(-24)
					:addy(12)
			end,
			OnCommand = function(self)
				-- You may now admire your glorious artwork, Chegg. You better use my theme now. ~Sudo
				local InputHandler = function(event)
					if event.button ~= 'Up' and event.button ~= 'Down' then return end
					local children = {
						self:GetChild('BannerFade'),
						self:GetChild('BPM'),
						self:GetChild('Length'),
						self:GetChild('SongInfo'),
						self:GetChild('Jacket'),
					}
					if event.button == 'Down' then
						if event.type == 'InputEventType_FirstPress' then
							for _, v in ipairs(children) do
								v:stoptweening():sleep(0.5):linear(0.1):diffusealpha(0)
							end
						elseif event.type == 'InputEventType_Release' then
							for i, v in ipairs(children) do
								if v:GetName() == 'BannerFade' then
									if GAMESTATE:GetCurrentSong() then
										v:stoptweening():linear(0.1):diffusealpha(0.75)
									else
										v:stoptweening():linear(0.1):diffusealpha(0.5)
									end
								else
									v:stoptweening():linear(0.1):diffusealpha(1)
								end
							end
						end
					elseif event.button == 'Up' then
						if event.type == 'InputEventType_FirstPress' then
							for _, v in ipairs(children) do
								if v:GetName() ~= 'Jacket' then
									v:stoptweening():sleep(0.5):linear(0.1):diffusealpha(0)
								end
							end
							self:GetChild('Jacket'):stoptweening():sleep(0.5):easeoutexpo(0.2):zoom(128 / 48)
						elseif event.type == 'InputEventType_Release' then
							for _, v in ipairs(children) do
								if v:GetName() == 'BannerFade' then
									if GAMESTATE:GetCurrentSong() then
										v:stoptweening():linear(0.1):diffusealpha(0.75)
									else
										v:stoptweening():linear(0.1):diffusealpha(0.5)
									end
								elseif v:GetName() ~= 'Jacket' then
									v:stoptweening():linear(0.1):diffusealpha(1)
								end
							end
							self:GetChild('Jacket'):stoptweening():easeoutexpo(0.2):zoom(1)
						end
					end
					return InputHander
				end
				SCREENMAN:GetTopScreen():AddInputCallback(InputHandler)
				self
					:sleep(0.25)
					:easeoutexpo(0.5)
					:addx(24)
					:diffusealpha(1)
			end,
			OffCommand = function(self)
				--SCREENMAN:GetTopScreen():RemoveInputCallback(InputHandler)
				self
					:sleep(0.25)
					:easeinexpo(0.5)
					:addx(-24)
					:diffusealpha(0)
			end,
			Def.Banner {
				Name = 'Banner',
				InitCommand = function(self)
					self
						:xy(208 - 16, -220 + 84 + 68)
						:scaletoclipped(418, 164)
						:addy(6)
				end,
				OnCommand = function(self)
					local song = GAMESTATE:GetCurrentSong()
					local course = GAMESTATE:GetCurrentCourse()
					local wheel = SCREENMAN:GetTopScreen():GetMusicWheel()
					if song then
						if song:HasBanner() then
							self:LoadFromSong(song)
						else
							self:LoadFromSongGroup(song:GetGroupName())
						end
					elseif course then
						if course:HasBanner() then
							self:LoadFromCourse(course)
						end
					elseif FILEMAN:DoesFileExist(SOMGMAN:GetSongGroupBannerPath(wheel:GetSelectedSection())) then
						self:LoadFromSongGroup(wheel:GetSelectedSection())
					else
						self:LoadFromCachedBanner(THEME:GetPathG('Common', 'fallback banner'))
					end
				end,
				CurrentSongChangedMessageCommand = function(self)
					local song = GAMESTATE:GetCurrentSong()
					local course = GAMESTATE:GetCurrentCourse()
					local wheel = SCREENMAN:GetTopScreen():GetMusicWheel()
					print(wheel:GetSelectedSection())
					if song then
						if song:HasBanner() then
							self:LoadFromSong(song)
						else
							self:LoadFromSongGroup(song:GetGroupName())
						end
					elseif course then
						if course:HasBanner() then
							self:LoadFromCourse(course)
						end
					elseif wheel:GetSelectedSection() then
						self:LoadFromSongGroup(wheel:GetSelectedSection())
					else
						self:LoadFromCachedBanner(THEME:GetPathG('Common', 'fallback banner'))
					end
				end,
			},
			Def.Quad {
				Name = 'BannerFade',
				InitCommand = function(self)
					self
						:xy(208 - 16, -220 + 84 + 68)
						:SetSize(418, 164)
						:diffuse(ThemeColor.Primary)
						:diffusealpha(0.75)
						:faderight(0.75)
						:addy(6)
				end,
				-- Hiding this is a good idea, but I'm using it for the immervise banner action instead. ~Sudo
				CurrentSongChangedMessageCommand = function(self)
					local song = GAMESTATE:GetCurrentSong()
					if not song then
						self:diffusealpha(0.5)
						--self:visible(false)
					else
						self:diffusealpha(0.75)
						--self:visible(true)
					end
				end,
			},
			Def.BitmapText {
				Name = 'Group',
				Font = 'Common Normal',
				InitCommand = function(self)
					self
						:zoom(1.5)
						:addx(-15)
						:addy(-168)
						:horizalign('left')
						:maxwidth(278)
				end,
				CurrentSongChangedMessageCommand = function(self)
					local song = GAMESTATE:GetCurrentSong()
					local wheel = SCREENMAN:GetTopScreen():GetMusicWheel()

					if song then
						self:settext(song:GetGroupName())
					elseif wheel:GetSelectedSection() then
						self:settext(wheel:GetSelectedSection())
					else
						self:settext('')
					end
				end,
			},
			Def.BitmapText {
				Name = 'BPM',
				Font = 'Common Normal',
				InitCommand = function(self)
					self
						:addy(-8)
						:horizalign('left')
				end,
				OnCommand = function(self)
					local bpmstr = 'BPM: '
					local song = GAMESTATE:GetCurrentSong()
					if song then
						-- check if the bpm is hidden -y0sefu
						if song:IsDisplayBpmRandom() then
							self:settext('BPM: ???') -- The spaces seemed a bit unnecessary to me. ~Sudo
							-- return early -y0sefu
							return
						end

						local minBPM = math.floor(song:GetDisplayBpms()[1])
						local maxBPM = math.floor(song:GetDisplayBpms()[2])

						if minBPM == maxBPM then
							bpmstr = bpmstr .. math.floor(song:GetDisplayBpms()[2])
						else
							bpmstr = bpmstr .. minBPM .. ' - ' .. maxBPM
						end
					else
						--bpmstr = bpmstr .. '--'
						bpmstr = ''
					end
					self:settext(bpmstr)
				end,
				CurrentSongChangedMessageCommand = function(self)
					local bpmstr = 'BPM: '
					local song = GAMESTATE:GetCurrentSong()
					if song then
						-- check if the bpm is hidden -y0sefu
						if song:IsDisplayBpmRandom() then
							self:settext('BPM: ???') -- The spaces seemed a bit unnecessary to me. ~Sudo
							-- return early -y0sefu
							return
						end

						local minBPM = math.floor(song:GetDisplayBpms()[1])
						local maxBPM = math.floor(song:GetDisplayBpms()[2])

						if minBPM == maxBPM then
							bpmstr = bpmstr .. math.floor(song:GetDisplayBpms()[2])
						else
							bpmstr = bpmstr .. minBPM .. ' - ' .. maxBPM
						end
					else
						--bpmstr = bpmstr .. '--'
						bpmstr = ''
					end
					self:settext(bpmstr)
				end,
			},
			Def.BitmapText {
				Name = 'Length',
				Font = 'Common Normal',
				InitCommand = function(self)
					self
						:addy(-32)
						:horizalign('left')
				end,
				OnCommand = function(self)
					local lenstr = 'Length: '
					local song = GAMESTATE:GetCurrentSong()
					if song then
						lenstr = lenstr .. math.floor(song:GetLastSecond() / 60)..':'..string.format('%02d',math.floor(song:GetLastSecond() % 60))
					else
						--lenstr = lenstr .. '--'
						lenstr = ''
					end
					self:settext(lenstr)
				end,
				CurrentSongChangedMessageCommand = function(self)
					local lenstr = 'Length: '
					local song = GAMESTATE:GetCurrentSong()
					if song then
						lenstr = lenstr .. math.floor(song:GetLastSecond() / 60)..':'..string.format('%02d',math.floor(song:GetLastSecond() % 60))
					else
						--lenstr = lenstr .. '-:--'
						lenstr = ''
					end
					self:settext(lenstr)
				end,
			},
			Def.ActorFrame {
				Name = 'SongInfo',
				InitCommand = function(self)
					self
						:zoom(1.5)
						:addy(-120 + 16)
						:addy(6)
				end,
				Def.BitmapText {
					Name = 'Title',
					Font = 'Common Normal',
					Text = '',
					InitCommand = function(self)
						self
							:addy(-12)
							:horizalign('left')
							:maxwidth(240)
					end,
					CurrentSongChangedMessageCommand = function(self)
						local song = GAMESTATE:GetCurrentSong()
						if not song then
							-- local wheel = SCREENMAN:GetTopScreen():GetMusicWheel()
							self:settext('')
							return
						end
						self:settext(song:GetDisplayFullTitle())
					end,
				},
				Def.BitmapText {
					Name = 'Artist',
					Font = 'Common Normal',
					Text = '',
					InitCommand = function(self)
						self
							:addy(12)
							:horizalign('left')
							:maxwidth(240)
					end,
					CurrentSongChangedMessageCommand = function(self)
						local song = GAMESTATE:GetCurrentSong()
						if not song then self:settext('') return end
						self:settext(song:GetDisplayArtist())
					end,
				},
			},
			-- Let's move this down here uwu ~Sudo
			Def.Sprite {
				Name = 'Jacket',
				InitCommand = function(self)
					-- Now that we moved and squished it, we can support non-widescreen ^-^ ~Sudo
					self
						:visible(true)
						:horizalign('right')
						:vertalign('bottom')
						:addx(384)
						:addy(4)
						:scaletoclipped(48, 48)
				end,
				OnCommand = function(self)
					local song = GAMESTATE:GetCurrentSong()
					-- I kinda don't want the jacket to show up if there isn't one. ~Sudo
					--[[
					if song then
						local jacketpath = ''

						if song:HasJacket() then
							jacketpath = song:GetJacketPath()
						elseif song:HasBackground() then
							jacketpath = song:GetBackgroundPath()
						else
							jacketpath = THEME:GetPathG('Common', 'fallback jacket')
						end
						self:Load(jacketpath)
					end
					--]]
					if song and song:HasJacket() then
						self
							:visible(true)
							:Load(song:GetJacketPath())
					else
						self:visible(false)
					end
				end,
				CurrentSongChangedMessageCommand = function(self)
					local song = GAMESTATE:GetCurrentSong()
					--[[
					if song then
						local jacketpath = ''

						if song:HasJacket() then
							jacketpath = song:GetJacketPath()
						elseif song:HasBackground() then
							jacketpath = song:GetBackgroundPath()
						else
							jacketpath = THEME:GetPathG('Common', 'fallback jacket')
						end
						self:Load(jacketpath)
					end
					--]]
					if song and song:HasJacket() then
						self
							:visible(true)
							:Load(song:GetJacketPath())
					else
						self:visible(false)
					end
				end,
			},
		},
		-- Chart Info
		Def.ActorFrame {
			Name = 'ChartInfo',
			InitCommand = function(self)
				self
					:x(152)
					:y(10)
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
				Name = 'StepNameP1',
				Font = 'Common Normal',
				Text = '--',
				InitCommand = function(self)
					self
						:x(-140)
						:addy(-138)
						:horizalign('left')
						:maxwidth(80)
						:visible(GAMESTATE:IsSideJoined(PLAYER_1))
						:diffuse(ColorLightTone(ThemeColor.P1))
						:diffusebottomedge(ThemeColor.P1)
					if GAMESTATE:GetCurrentSteps(PLAYER_1) then
						local diff = tostring(GAMESTATE:GetCurrentSteps(PLAYER_1):GetDifficulty())
						local diff = diff:sub(diff:find('_') + 1, -1)
						self
							:diffuse(ColorLightTone(ThemeColor[diff]))
							:diffusebottomedge(ThemeColor[diff])
					end
				end,
				PlayerJoinedMessageCommand = function(self, param)
					self:visible(GAMESTATE:IsSideJoined(PLAYER_1))
				end,
				CurrentStepsP1ChangedMessageCommand = function(self)
					local song = GAMESTATE:GetCurrentSong()
					local course = GAMESTATE:GetCurrentCourse()
					if not song and not course then
						self
							:settext('--')
							:diffuse(ColorLightTone(ThemeColor.P1))
							:diffusebottomedge(ThemeColor.P1)
						return
					end
					local diff = GAMESTATE:GetCurrentSteps(PLAYER_1)
					if diff then
						self:settext(THEME:GetString("CustomDifficulty",ToEnumShortString(diff:GetDifficulty())))
						local diffname = diff:GetDifficulty()
						local diffname = diffname:sub(diffname:find('_') + 1, -1)
						self
							:diffuse(ColorLightTone(ThemeColor[diffname]))
							:diffusebottomedge(ThemeColor[diffname])
					end
				end,
			},
			Def.BitmapText {
				Name = 'StepArtistP1',
				Font = 'Common Normal',
				Text = '--',
				InitCommand = function(self)
					self
						:x(-140)
						:addy(-118)
						:horizalign('left')
						:maxwidth(80)
						:diffuse(ColorLightTone(ThemeColor.P1))
						:diffusebottomedge(ThemeColor.P1)
						:visible(GAMESTATE:IsSideJoined(PLAYER_1))
				end,
				PlayerJoinedMessageCommand = function(self, param)
					self:visible(GAMESTATE:IsSideJoined(PLAYER_1))
				end,
				CurrentStepsP1ChangedMessageCommand = function(self)
					local song = GAMESTATE:GetCurrentSong()
					local course = GAMESTATE:GetCurrentCourse()
					if not song and not course then
						self:settext('--')
						return
					end
					local diff = GAMESTATE:GetCurrentSteps(PLAYER_1)
					if diff then self:settext(diff:GetAuthorCredit()) end
				end,
			},
			Def.BitmapText {
				Name = 'StepHighScoreP1',
				Font = 'Common Normal',
				Text = '--',
				InitCommand = function(self)
					self
						:x(-140)
						:addy(-98)
						:horizalign('left')
						:maxwidth(80)
						:diffuse(ColorLightTone(ThemeColor.P1))
						:diffusebottomedge(ThemeColor.P1)
						:visible(GAMESTATE:IsSideJoined(PLAYER_1))
				end,
				PlayerJoinedMessageCommand = function(self, param)
					self:visible(GAMESTATE:IsSideJoined(PLAYER_1))
				end,
				CurrentStepsP1ChangedMessageCommand = function(self)
					local song = GAMESTATE:GetCurrentSong()
					local course = GAMESTATE:GetCurrentCourse()
					if not song and not course then
						self:settext('--')
						return
					end
					local diff = GAMESTATE:GetCurrentSteps(PLAYER_1)
					if diff then
						local scorelist = PROFILEMAN:GetProfile(PLAYER_1):GetHighScoreList(song, diff)
						--self:settext(diff:GetAuthorCredit())
						local highscore = scorelist:GetHighScores()[1]
						if highscore then
							local perc = highscore:GetPercentDP() * 100
							--print()
							self:settext(string.format('%.2f', perc) .. '%')
						else
							self:settext('--')
						end
					end
				end,
			},
			Def.BitmapText {
				Name = 'StepNameP2',
				Font = 'Common Normal',
				Text = '--',
				InitCommand = function(self)
					self
						:x(-40 + 72)
						:addy(-138)
						:horizalign('right')
						:maxwidth(80)
						:diffuse(ColorLightTone(ThemeColor.P2))
						:diffusebottomedge(ThemeColor.P2)
						:visible(GAMESTATE:IsSideJoined(PLAYER_2))
					if GAMESTATE:GetCurrentSteps(PLAYER_2) then
						local diff = tostring(GAMESTATE:GetCurrentSteps(PLAYER_2):GetDifficulty())
						local diff = diff:sub(diff:find('_') + 1, -1)
						self
							:diffuse(ColorLightTone(ThemeColor[diff]))
							:diffusebottomedge(ThemeColor[diff])
					end
				end,
				PlayerJoinedMessageCommand = function(self, param)
					self:visible(GAMESTATE:IsSideJoined(PLAYER_2))
				end,
				CurrentStepsP2ChangedMessageCommand = function(self)
					local song = GAMESTATE:GetCurrentSong()
					local course = GAMESTATE:GetCurrentCourse()
					if not song and not course then
						self
							:settext('--')
							:diffuse(ColorLightTone(ThemeColor.P2))
							:diffusebottomedge(ThemeColor.P2)
						return
					end
					local diff = GAMESTATE:GetCurrentSteps(PLAYER_2)
					if diff then
						self:settext(THEME:GetString("CustomDifficulty",ToEnumShortString(diff:GetDifficulty())))
						local diffname = diff:GetDifficulty()
						local diffname = diffname:sub(diffname:find('_') + 1, -1)
						self
							:diffuse(ColorLightTone(ThemeColor[diffname]))
							:diffusebottomedge(ThemeColor[diffname])
					end
				end,
			},
			Def.BitmapText {
				Name = 'StepArtistP2',
				Font = 'Common Normal',
				Text = '--',
				InitCommand = function(self)
					self
						:x(-40 + 72)
						:addy(-118)
						:horizalign('right')
						:maxwidth(80)
						:diffuse(ColorLightTone(ThemeColor.P2))
						:diffusebottomedge(ThemeColor.P2)
						:visible(GAMESTATE:IsSideJoined(PLAYER_2))
				end,
				PlayerJoinedMessageCommand = function(self, param)
					self:visible(GAMESTATE:IsSideJoined(PLAYER_2))
				end,
				CurrentStepsP2ChangedMessageCommand = function(self)
					local song = GAMESTATE:GetCurrentSong()
					local course = GAMESTATE:GetCurrentCourse()
					if not song and not course then
						self:settext('--')
						return
					end
					local diff = GAMESTATE:GetCurrentSteps(PLAYER_2)
					if diff then self:settext(diff:GetAuthorCredit()) end
				end,
			},
			Def.BitmapText {
				Name = 'StepHighScoreP2',
				Font = 'Common Normal',
				Text = '--',
				InitCommand = function(self)
					self
						:x(-40 + 72)
						:addy(-98)
						:horizalign('right')
						:maxwidth(80)
						:diffuse(ColorLightTone(ThemeColor.P2))
						:diffusebottomedge(ThemeColor.P2)
						:visible(GAMESTATE:IsSideJoined(PLAYER_2))
				end,
				PlayerJoinedMessageCommand = function(self, param)
					self:visible(GAMESTATE:IsSideJoined(PLAYER_2))
				end,
				CurrentStepsP2ChangedMessageCommand = function(self)
					local song = GAMESTATE:GetCurrentSong()
					local course = GAMESTATE:GetCurrentCourse()
					if not song and not course then
						self:settext('--')
						return
					end
					local diff = GAMESTATE:GetCurrentSteps(PLAYER_2)
					if diff then
						local scorelist = PROFILEMAN:GetProfile(PLAYER_2):GetHighScoreList(song, diff)
						--self:settext(diff:GetAuthorCredit())
						local highscore = scorelist:GetHighScores()[1]
						if highscore then
							local perc = highscore:GetPercentDP() * 100
							--print()
							self:settext(string.format('%.2f', perc) .. '%')
						else
							self:settext('--')
						end
					end
				end,
			},
			-- TODO: Stop doing this bullshit. ~Sudo
			Def.BitmapText {
				Name = 'StepLabels',
				Font = 'Common Normal',
				Text = 'Notes\nHolds\nRolls\nJumps\nHands\n\nMines\nLifts\nFakes',
				InitCommand = function(self)
					self
						:x(-140)
						:addy(22)
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
				Name = 'ChartInfoP1',
				Font = 'Common Normal',
				InitCommand = function(self)
					self
						:addx(-60)
						:addy(34)
						:horizalign('left')
						:maxwidth(36)
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
						self:y(22)
						self:settext('--\n--\n--\n--\n--\n\n--\n--\n--')
					else
						self:y(34)
						local cur_diff = GAMESTATE:GetCurrentSteps(PLAYER_1)
						if not cur_diff then return end
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
							local num = cur_diff:GetRadarValues(PLAYER_1):GetValue('RadarCategory_'..v)
							ret = ret..num ..'\n'
							if v == 'Hands' then ret = ret..'\n' end
						end
						self:settext(ret)
					end
				end,
				CurrentSongChangedMessageCommand = function(self)
					MESSAGEMAN:Broadcast('CurrentStepsP1Changed')
				end,
			},
			Def.BitmapText {
				Name = 'ChartInfoP2',
				Font = 'Common Normal',
				InitCommand = function(self)
					self
						:addx(-10 + 36)
						:addy(34)
						:horizalign('right')
						:maxwidth(36)
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
						self:y(22)
						self:settext('--\n--\n--\n--\n--\n\n--\n--\n--')
					else
						self:y(34)
						local cur_diff = GAMESTATE:GetCurrentSteps(PLAYER_2)
						if not cur_diff then return end
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
							local num = cur_diff:GetRadarValues(PLAYER_2):GetValue('RadarCategory_'..v)
							ret = ret..num ..'\n'
							if v == 'Hands' then ret = ret..'\n' end
						end
						self:settext(ret)
					end
				end,
				CurrentSongChangedMessageCommand = function(self)
					MESSAGEMAN:Broadcast('CurrentStepsP2Changed')
				end,
			}
		},
	},
	LoadActor(THEME:GetPathG('ScreenSelectMusic', 'DifficultyList')),
}