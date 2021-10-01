local ThemeColor = LoadModule('Theme.Colors.lua')

return Def.ActorFrame {
	-- Filter
	Def.ActorFrame {
		-- Player 1
		Def.Quad {
			OnCommand = function(self)
				local plr = SCREENMAN:GetTopScreen():GetChild('PlayerP1')
				self:visible(false)
				if ((IsGame('dance') or IsGame('pump')) and plr) then
					self
						:visible(true)
						:xy(plr:GetX(), plr:GetY())
						--:xy(SCREEN_CENTER_X, SCREEN_CENTER_Y)
						:SetSize(96 * GAMESTATE:GetCurrentStyle():ColumnsPerPlayer(), SCREEN_HEIGHT)
					local c = tonumber(LoadModule('Config.Load.lua')('ScreenFilterColor', PROFILEMAN:GetProfileDir(0)..'/OutFoxPrefs.ini'))
					local colors = {
						{
							ThemeColor.Black,
							ColorDarkTone(ThemeColor.P1),
						},
						{
							ThemeColor.Black,
							ThemeColor.Black,
						},
						{
							ThemeColor.P1,
							ColorDarkTone(ThemeColor.P1),
						},
						{
							ThemeColor.White,
							ThemeColor.White,
						},
						{
							ThemeColor.Gray,
							ThemeColor.Gray,
						}
					}
					print(colors[c])
					local a = LoadModule('Config.Load.lua')('ScreenFilter', PROFILEMAN:GetProfileDir(0)..'/OutFoxPrefs.ini')
					self:diffuse(colors[c][1])
					self:diffusebottomedge(colors[c][2])
					self:diffusealpha(a)
				end
			end,
		},
		-- Player 2
		Def.Quad {

		},
	},
	-- Everything Else
	Def.ActorFrame {
		InitCommand = function(self)
			self
				:xy(SCREEN_CENTER_X, 40)
				:addy(-120)
		end,
		OnCommand = function(self)
			self
				:easeoutexpo(0.5)
				:addy(120)
				:luaeffect('ReportCursor')
		end,
		OffCommand = function(self)
			self
				:easeinexpo(0.5)
				:addy(-120)
		end,
		-- Panel
		Def.Quad {
			InitCommand = function(self)
				self
					:SetSize(SCREEN_WIDTH, 88)
					:diffuse(ThemeColor.Black)
					:diffusealpha(0.5)
					:fadetop(0.1)
					:fadebottom(0.1)
			end,
		},
		Def.Quad {
			InitCommand = function(self)
				self
					:SetSize(SCREEN_WIDTH, 80)
					:diffuse(ThemeColor.Primary)
					:diffusealpha(0.75)
			end,
		},
		Def.Quad {
			InitCommand = function(self)
				self
					:SetSize(SCREEN_WIDTH + 4, 8)
					:addy(36)
					:diffuse(ThemeColor.Elements)
					:cropright(1)
					:skewx(-0.5)
					:luaeffect('SongTime')
			end,
			SongTimeCommand = function(self)
				local cur = GAMESTATE:GetSongPosition():GetMusicSeconds()
				local last = GAMESTATE:GetCurrentSong():GetLastSecond()
				self:cropright(0.99 - (cur / (last * 1.01)))
			end,
		},
		--Text
		Def.BitmapText {
			Font = 'Common Normal',
			InitCommand = function(self)
				local song = GAMESTATE:GetCurrentSong()
				if song then
					self:settext(song:GetDisplayFullTitle())
				end
				self
					:zoom(1.5)
					:vertalign('bottom')
					:maxwidth(SCREEN_CENTER_X * 0.5)
			end,
		},
		Def.BitmapText {
			Font = 'Common Normal',
			InitCommand = function(self)
				local song = GAMESTATE:GetCurrentSong()
				if song then
					self:settext(song:GetDisplayArtist())
				end
				self
					:zoom(0.75)
					:vertalign('top')
					:addy(12)
					:maxwidth(SCREEN_CENTER_X * 0.5)
			end,
		},
		-- Chart Difficulties
		Def.ActorFrame {
			InitCommand = function(self)
				self
					:addx(-SCREEN_CENTER_X - 260)
					:addy(SCREEN_HEIGHT - 84)
					:visible(false)
			end,
			OnCommand = function(self)
				self
					:visible(GAMESTATE:IsSideJoined(PLAYER_1))
					:sleep(0.25)
					:easeoutexpo(0.5)
					:addx(256)
			end,
			OffCommand = function(self)
				self
					:easeoutexpo(0.5)
					:addx(-256)
			end,
			Def.Quad {
				InitCommand = function(self)
					self
						:SetSize(512, 46)
						:addx(-8)
						:skewx(-0.5)
						:diffuse(ColorLightTone(PlayerColor(PLAYER_1)))
				end,
			},
			Def.BitmapText {
				Font = 'Common Normal',
				InitCommand = function(self)
					self
						:sleep(0.25)
						:easeoutexpo(0.75)
						:zoom(1.25)
						:addx(224)
						:addy(-2)
						:halign(1)
					local diff = GAMESTATE:GetCurrentSteps(PLAYER_1)
					if diff then
						self:settext(diff:GetMeter())
					end
				end,
			},
			Def.BitmapText {
				Font = 'Common Normal',
				InitCommand = function(self)
					self
						:zoom(1.25)
						:addx(24)
						:addy(-2)
						:halign(0)
					local diff = GAMESTATE:GetCurrentSteps(PLAYER_1)
					if diff then
						self:settext(THEME:GetString("CustomDifficulty",ToEnumShortString(diff:GetDifficulty())))
					end
				end,
			}
		},
		Def.ActorFrame {
			InitCommand = function(self)
				self
					:addx(SCREEN_CENTER_X + 260)
					:addy(SCREEN_HEIGHT - 84)
					:visible(false)
			end,
			OnCommand = function(self)
				self
					:visible(GAMESTATE:IsSideJoined(PLAYER_2))
					:sleep(0.25)
					:easeoutexpo(0.75)
					:addx(-256)
			end,
			OffCommand = function(self)
				self
					:easeoutexpo(0.5)
					:addx(256)
			end,
			Def.Quad {
				InitCommand = function(self)
					self
						:SetSize(512, 46)
						:addx(8)
						:skewx(-0.5)
						:diffuse(ColorLightTone(PlayerColor(PLAYER_2)))
				end,
			},
			Def.BitmapText {
				Font = 'Common Normal',
				InitCommand = function(self)
					self
						:zoom(1.25)
						:addx(-224)
						:addy(-2)
						:halign(0)
					local diff = GAMESTATE:GetCurrentSteps(PLAYER_2)
					if diff then
						self:settext(diff:GetMeter())
					end
				end,
			},
			Def.BitmapText {
				Font = 'Common Normal',
				InitCommand = function(self)
					self
						:sleep(0.25)
						:easeoutexpo(0.75)
						:zoom(1.25)
						:addx(-24)
						:addy(-2)
						:halign(1)
					local diff = GAMESTATE:GetCurrentSteps(PLAYER_2)
					if diff then
						self:settext(THEME:GetString("CustomDifficulty",ToEnumShortString(diff:GetDifficulty())))
					end
				end,
			}
		},
		loadfile(THEME:GetPathB('','ButtonLayout'))(),
	},
}
