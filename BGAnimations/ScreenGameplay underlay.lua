local ThemeColor = LoadModule('Theme.Colors.lua')

return Def.ActorFrame {
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
					:addx(-SCREEN_CENTER_X + 24)
					:visible(false)
			end,
			OnCommand = function(self)
				self:visible(GAMESTATE:IsSideJoined(PLAYER_1))
			end,
			Def.Quad {
				InitCommand = function(self)
					self
						:SetSize(72, 46)
						:addx(-8)
						:skewx(-0.5)
						:diffuse(ColorLightTone(PlayerColor(PLAYER_1)))
				end,
			},
			Def.BitmapText {
				Font = 'Common Normal',
				InitCommand = function(self)
					self
						:zoom(1.25)
						:addy(-2)
					local diff = GAMESTATE:GetCurrentSteps(PLAYER_1)
					if diff then
						self:settext(diff:GetMeter())
					end
				end,
			}
		},
		Def.ActorFrame {
			InitCommand = function(self)
				self
					:addx(SCREEN_CENTER_X - 24)
					:visible(false)
			end,
			OnCommand = function(self)
				self:visible(GAMESTATE:IsSideJoined(PLAYER_2))
			end,
			Def.Quad {
				InitCommand = function(self)
					self
						:SetSize(72, 46)
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
						:addy(-2)
					local diff = GAMESTATE:GetCurrentSteps(PLAYER_2)
					if diff then
						self:settext(diff:GetMeter())
					end
				end,
			}
		},
	},
}
