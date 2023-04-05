if GAMESTATE:IsCourseMode() then return Def.Actor {} end

return Def.ActorFrame {
	Name = 'GroupInfoFrame',
	InitCommand = function(self)
		self:xy(SCREEN_WIDTH / 4 * 3, 140):diffusealpha(0)
	end,
	GroupUnselectMessageCommand = function(self)
		self
			:sleep(0.25)
			:linear(0.15)
			:diffusealpha(1)
			--:x(SCREEN_WIDTH / 4 * 3)
	end,
	GroupSelectMessageCommand = function(self)
		self
			:linear(0.15)
			:diffusealpha(0)
			--:x(SCREEN_WIDTH / 4 * 3 + SCREEN_CENTER_X)
	end,
	Def.Quad {
		Name = 'InfoDim',
		InitCommand = function(self)
			self
				:addx(-275)
				:addy(220)
				:SetSize(SCREEN_WIDTH, SCREEN_HEIGHT)
				:diffuse(color('#000000FF'))
				:fadeleft(0.05)
				:cropleft(0.45)
		end,
	},
	Def.ActorFrame {
		Name = 'GroupBannerFrame',
		Def.Banner {
			Name = 'GroupBanner',
			InitCommand = function(self)
				--self:scaletoclipped(512, 160)
			end,
			CurrentSongChangedMessageCommand = function(self)
				self
					:stoptweening()
					:linear(0.1)
					:diffusealpha(0)
					:sleep(0.1)
					:queuecommand('LoadBanner')
			end,
			LoadBannerCommand = function(self)
				local song = GAMESTATE:GetCurrentSong()
				if song.GetGroupName then
					self:LoadFromSongGroup(song:GetGroupName())
				else
					self:LoadFromCourse(song)
				end
				local w, h = self:GetWidth(), self:GetHeight()
				self:zoomto(160 * w/h, 160)
				self:easeinoutsine(0.1):diffusealpha(1)
			end,
		},
	},
	Def.BitmapText {
		Name = "SongCount",
		Font = "Common Normal",
		Text = "SONGS IN GROUP:",
		InitCommand = function(self)
			self
				:xy(-250, 100)
				:zoom(1)
				:horizalign("left")
				:vertalign("middle")
		end,
		CurrentSongChangedMessageCommand = function(self)
			local song = GAMESTATE:GetCurrentSong()
			self
				:stoptweening()
				:settext("SONGS IN GROUP: "..#SONGMAN:GetSongsInGroup(song:GetGroupName()))
			if #SONGMAN:GetSongsInGroup(song:GetGroupName()) == 69 then
				self:rainbowscroll(true)
					:settext(self:GetText()..' (nice)') -- alright, yosefu, how about this then. ~Sudo
			else
				self:rainbowscroll(false)
			end
		end,
	},
	Def.BitmapText {
		Name = "ChartCount",
		Font = "Common Normal",
		Text = "",
		InitCommand = function(self)
			self
				:xy(-250, 135)
				:zoom(1)
				:horizalign("left")
				:vertalign("middle")
		end,
		CurrentSongChangedMessageCommand = function(self)
			local song = GAMESTATE:GetCurrentSong()
			local numcharts = 0
			local sgroup = SONGMAN:GetSongsInGroup(song:GetGroupName())

			for i = 1, #sgroup do
				for _, c in ipairs(sgroup[i]:GetAllSteps()) do
					if c:GetStepsType():lower():find(GAMESTATE:GetCurrentGame():GetName()) then
						numcharts = numcharts + 1
					end
				end
			end

			self:stoptweening():settext(GAMESTATE:GetCurrentGame():GetName().." CHARTS IN GROUP: "..numcharts)
		end,
	},
	Def.BitmapText {
		Name = "FeaturedSongArtistsHeader",
		Font = "Common Normal",
		Text = "FEATURED SONG ARTISTS:",
		InitCommand = function(self)
			self
				:xy(-250, 170)
				:zoom(1)
				:horizalign("left")
				:vertalign("middle")
		end,
	},
	Def.BitmapText {
		Name = "FeaturedSongArtists",
		Font = "Common Normal",
		Text = "",
		InitCommand = function(self)
			self
				:xy(-250, 185)
				:zoom(1)
				:horizalign("left")
				:vertalign("top")
		end,
		CurrentSongChangedMessageCommand = function(self)
			local song = GAMESTATE:GetCurrentSong()
			local sgroup = SONGMAN:GetSongsInGroup(song:GetGroupName())
			local artists = {}

			for i = 1, #sgroup do
				-- We'll break out of here if we hit over 11. ~Sudo
				--if i > 11 then break end
				artists[#artists + 1] = sgroup[i]:GetDisplayArtist()
			
				-- this SHOULD remove duplicate song artists but it only removes one duplicate ~ yosefu
				for j = 1, #artists do
					-- I accidentally deleted everything because i was j. ~Sudo
					if artists[i] == artists[j] and i ~= j then
						-- We can remove them easier if they're blank. ~Sudo
						artists[j] = ''
					end
				end
			end

			-- We need to ONLY increment when we DON'T delete. ~Sudo
			local i = 0
			while i <= #artists do
				if artists[i] == '' then
					table.remove(artists, i)
				else
					i = i + 1
				end
			end
			-- Now we gotta remove all the extra stuff and put the 'and more'! ~Sudo
			if #artists > 10 then
				for i = 11, #artists do
					table.remove(artists, #artists)
				end
				artists[11] = "and more"
			end

			self:stoptweening():settext(table.concat(artists, '\n'))
		end,
	},
}