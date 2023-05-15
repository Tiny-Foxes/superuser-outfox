local ThemeColor = LoadModule('Theme.Colors.lua')

local song = GAMESTATE:GetCurrentSong()
local songPos = GAMESTATE:GetSongPosition()

return Def.ActorFrame {
	Def.ActorFrame {
		Name = 'SongInfo',
		InitCommand = function(self)
			self
				:xy(SCREEN_CENTER_X, 40)
				:addy(-120)
		end,
		ShowSongInfoMessageCommand = function(self)
			self
				:stoptweening()
				:easeoutexpo(0.5)
				:y(40)
		end,
		HideSongInfoMessageCommand = function(self)
			self
				:stoptweening()
				:easeinexpo(0.5)
				:y(-80)
		end,
		OnCommand = function(self)
			self:queuemessage('ShowSongInfo')
		end,
		OffCommand = function(self)
			self:queuemessage('HideSongInfo')
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
				local cur = songPos:GetMusicSeconds()
				local last = song:GetLastSecond()
				self:cropright(0.99 - (cur / (last * 1.01)))
			end,
		},
		--Text
		Def.BitmapText {
			Font = 'Stylized Large',
			InitCommand = function(self)
				if song then
					self:settext(song:GetDisplayFullTitle())
				end
				self
					:zoom(0.75)
					:vertalign('bottom')
					:maxwidth(SCREEN_CENTER_X)
			end,
		},
		Def.BitmapText {
			Font = 'Stylized Normal',
			InitCommand = function(self)
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
	},
}
