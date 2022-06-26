local ThemeColor = LoadModule('Theme.Colors.lua')

return Def.ActorFrame {
	Name = 'Underlay',
	OnCommand = function(self)
		-- discord support UwU -y0sefu
		local player = GAMESTATE:GetMasterPlayerNumber()
		if player then
			GAMESTATE:UpdateDiscordProfile(GAMESTATE:GetPlayerDisplayName(player))
		end
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
			if not GAMESTATE:IsCourseMode() and SU_Wheel.CurSong:GetPreviewVidPath() then
				self:Load(SU_Wheel.CurSong:GetPreviewVidPath())
			else
				self:LoadFromSongBackground(SU_Wheel.CurSong)
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
				--self:scaletoclipped(512, 160)
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
				local song = SU_Wheel.CurSong
				if song:HasBanner() then
					self:LoadFromCachedBanner(song:GetBannerPath())
				else
					self:LoadFromSongGroup(song:GetGroupName())
				end
				local w, h = self:GetWidth(), self:GetHeight()
				self:zoomto(160 * w/h, 160)
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
			Font = 'Common Large',
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
				local song = SU_Wheel.CurSong
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
			Font = 'Common Large',
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
			Font = 'Common Large',
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
				local song = SU_Wheel.CurSong
				local artist = (GAMESTATE:IsCourseMode() and song:GetScripter()) or song:GetDisplayArtist()
				self
					:settext(artist)
					:easeinoutsine(0.2)
					:diffusealpha(1)
			end,
		},
	},
	Def.ActorFrame {
		Name = 'ControlsFrame',
		InitCommand = function(self)
			self:xy(SCREEN_LEFT + 20, SCREEN_BOTTOM - 80)
		end,
		Def.Quad {
			InitCommand = function(self)
				self:halign(0.25):valign(1)
				self
					:SetSize(480, 100)
					:y(20)
					:diffuse(color('#00000080'))
					:skewx(-0.5)
			end,
		},
		Def.BitmapText {
			Font = 'Common Normal',
			Text = '&LEFT;&RIGHT;: Change Selection\n&DOWN;&UP;: Change Wheel',
			InitCommand = function(self)
				self:halign(0):y(-30)
			end,
		}
	}
}
