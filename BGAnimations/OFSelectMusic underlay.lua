local ThemeColor = LoadModule('Theme.Colors.lua')

return Def.ActorFrame {
	Name = 'Underlay',
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
	Def.Sprite {
		Name = 'Background',
		InitCommand = function(self)
			self
				:Center()
				:scaletoclipped(SCREEN_WIDTH, SCREEN_HEIGHT)
		end,
		CurrentSongChangedMessageCommand = function(self)
			self
				:stoptweening()
				:easeinoutsine(0.2)
				:diffusealpha(0)
				:sleep(0.1)
				:queuecommand('LoadBackground')
		end,
		LoadBackgroundCommand = function(self)
			if not GAMESTATE:IsCourseMode() and TF_CurrentSong:GetPreviewVidPath() then
				self:Load(TF_CurrentSong:GetPreviewVidPath())
			else
				self:LoadFromSongBackground(TF_CurrentSong)
			end
			self
				:easeinoutsine(0.5)
				:diffusealpha(0.25)
		end,
	},
	Def.ActorFrame {
		Name = 'BannerFrame',
		InitCommand = function(self)
			self:xy(290, 250)
		end,
		Def.Banner {
			Name = 'Banner',
			InitCommand = function(self)
				self:scaletoclipped(512, 160)
			end,
			CurrentSongChangedMessageCommand = function(self)
				self
					:stoptweening()
					:linear(0.1)
					:diffusealpha(0)
					:sleep(0.25)
					:queuecommand('LoadBanner')
			end,
			LoadBannerCommand = function(self)
				local song = TF_CurrentSong
				if song:HasBanner() then
					self:LoadFromCachedBanner(song:GetBannerPath())
				else
					self:LoadFromSongGroup(song:GetGroupName())
				end
				self:easeinoutsine(0.2):diffusealpha(1)
			end,
		},
	},
	Def.ActorFrame {
		Name = 'InfoFrame',
		InitCommand = function(self)
			self:xy(290, 460)
		end,
		Def.BitmapText {
			Font = '_xide/40px',
			Name = 'Text',
			InitCommand = function(self)
				self
					:valign(1)
					:addy(-24)
					:maxwidth(488)
			end,
			CurrentSongChangedMessageCommand = function(self)
				self
					:stoptweening()
					:linear(0.1)
					:diffusealpha(0)
					:sleep(0.25)
					:queuecommand('LoadTitle')
			end,
			LoadTitleCommand = function(self)
				local song = TF_CurrentSong
				local title = song:GetDisplayFullTitle()
				if not GAMESTATE:IsCourseMode() then
					if song:GetDisplaySubTitle() and song:GetDisplaySubTitle() ~= '' then
						title = song:GetDisplayMainTitle()..'\n'..song:GetDisplaySubTitle()
					end
				end
				self
					:settext(title)
					:easeinoutsine(0.2)
					:diffusealpha(1)
			end,
		},
		Def.BitmapText {
			Font = '_xide/40px',
			Name = 'Separator',
			Text = '--',
			InitCommand = function(self)
				self
					:maxwidth(488)
					:diffusealpha(0)
			end,
			CurrentSongChangedMessageCommand = function(self)
				self
					:stoptweening()
					:linear(0.1)
					:diffusealpha(0)
					:sleep(0.25)
					:easeinoutsine(0.2)
					:diffusealpha(1)
			end,
		},
		Def.BitmapText {
			Font = '_xide/40px',
			Name = 'Artist',
			InitCommand = function(self)
				self
					:valign(0)
					:addy(24)
					:maxwidth(488)
			end,
			CurrentSongChangedMessageCommand = function(self)
				self
					:stoptweening()
					:linear(0.1)
					:diffusealpha(0)
					:sleep(0.25)
					:queuecommand('LoadArtist')
			end,
			LoadArtistCommand = function(self)
				local song = TF_CurrentSong
				local artist = (GAMESTATE:IsCourseMode() and song:GetScripter()) or song:GetDisplayArtist()
				self
					:settext(artist)
					:easeinoutsine(0.2)
					:diffusealpha(1)
			end,
		},
	},
}
