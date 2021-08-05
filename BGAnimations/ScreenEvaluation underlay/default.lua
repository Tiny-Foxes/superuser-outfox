local ThemeColor = LoadModule('Theme.Colors.lua')

return Def.ActorFrame {
	Def.ActorFrame {
		Name = 'P1EvalFrame',
		InitCommand = function(self)
			self
				:Center()
				:addx(-SCREEN_CENTER_X * 0.4)
				:skewx(-0.25)
		end,
		Def.Quad {
			InitCommand = function(self)
				self
					:SetSize(SCREEN_CENTER_X * 0.75 + 8, SCREEN_HEIGHT)
					:diffuse(ThemeColor.Black)
					:fadeleft(0.01)
					:faderight(0.01)
					:diffusealpha(0.5)
					:cropbottom(1)
			end,
			OnCommand = function(self)
				self
					:easeinoutexpo(0.25)
					:cropbottom(0)
			end,
			OffCommand = function(self)
				self
					:sleep(0.25)
					:easeinoutexpo(0.25)
					:cropbottom(1)
			end,
		},
		Def.Quad {
			InitCommand = function(self)
				self
					:SetSize(SCREEN_CENTER_X * 0.75, SCREEN_HEIGHT)
					:diffuse(ColorDarkTone(PlayerColor(PLAYER_1)))
					:diffusealpha(0.75)
					:cropbottom(1)
			end,
			OnCommand = function(self)
				self
					:easeinoutexpo(0.25)
					:cropbottom(0)
			end,
			OffCommand = function(self)
				self
					:sleep(0.25)
					:easeinoutexpo(0.25)
					:cropbottom(1)
			end,
		},
		loadfile(THEME:GetPathB('ScreenEvaluation', 'underlay/NoteScores.lua'))(PLAYER_1),
	},
	Def.ActorFrame {
		Name = 'P2EvalFrame',
		InitCommand = function(self)
			self
				:Center()
				:addx(SCREEN_CENTER_X * 0.4)
				:skewx(-0.25)
		end,
		Def.Quad {
			InitCommand = function(self)
				self
					:SetSize(SCREEN_CENTER_X * 0.75 + 8, SCREEN_HEIGHT)
					:diffuse(ThemeColor.Black)
					:fadeleft(0.01)
					:faderight(0.01)
					:diffusealpha(0.5)
					:croptop(1)
			end,
			OnCommand = function(self)
				self
					:sleep(0.125)
					:easeinoutexpo(0.25)
					:croptop(0)
			end,
			OffCommand = function(self)
				self
					:sleep(0.375)
					:easeinoutexpo(0.25)
					:croptop(1)
			end,
		},
		Def.Quad {
			InitCommand = function(self)
				self
					:SetSize(SCREEN_CENTER_X * 0.75, SCREEN_HEIGHT)
					:diffuse(ColorDarkTone(PlayerColor(PLAYER_2)))
					:diffusealpha(0.75)
					:croptop(1)
			end,
			OnCommand = function(self)
				self
					:sleep(0.125)
					:easeinoutexpo(0.25)
					:croptop(0)
			end,
			OffCommand = function(self)
				self
					:sleep(0.375)
					:easeinoutexpo(0.25)
					:croptop(1)
			end,
		},
		loadfile(THEME:GetPathB('ScreenEvaluation', 'underlay/NoteScores.lua'))(PLAYER_2)
	},
	Def.ActorFrame {
		InitCommand = function(self)
			self
				:xy(SCREEN_CENTER_X, 120)
				:skewx(-0.5)
		end,
		Def.Quad {
			InitCommand = function(self)
				self
					:SetSize(SCREEN_WIDTH * 1.5, 168)
					:diffuse(ThemeColor.Black)
					:diffusealpha(0.5)
					:fadetop(0.02)
					:fadebottom(0.02)
					:cropleft(1)
			end,
			OnCommand = function(self)
				self
					:easeinoutexpo(0.5)
					:cropleft(0)
			end,
			OffCommand = function(self)
				self
					:easeinoutexpo(0.5)
					:cropleft(1)
			end,
		},
		Def.Quad {
			InitCommand = function(self)
				self
					:SetSize(SCREEN_WIDTH * 1.5, 160)
					:diffuse(ThemeColor.Elements)
					:diffuseleftedge(ThemeColor.Secondary)
					:diffusetopedge(ThemeColor.Primary)
					:diffusealpha(0.75)
					:cropleft(1)
			end,
			OnCommand = function(self)
				self
					:easeinoutexpo(0.5)
					:cropleft(0)
			end,
			OffCommand = function(self)
				self
					:easeinoutexpo(0.5)
					:cropleft(1)
			end,
		},
		Def.Sprite {
			InitCommand = function(self)
				local target = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse() or GAMESTATE:GetCurrentSong()
				if GAMESTATE:IsCourseMode() then
					if target and target:HasBanner() then			
						self:LoadFromCached("banner",target:GetBannerPath()):scaletoclipped(402,160)
					else
						--self:Load(THEME:GetPathG("Common fallback", "jacket")):scaletoclipped(402,160)
					end
				else
					if target and target:HasBanner() then			
						self:LoadFromCached("banner",target:GetBannerPath()):scaletoclipped(402,160)
					else
						--self:Load(THEME:GetPathG("Common fallback", "jacket")):scaletoclipped(402,160)
					end
				end
				self
					:skewx(0.5)
					:fadeleft(1)
					:faderight(1)
					:diffusealpha(0)
					:x(SCREEN_CENTER_X)
			end,
			OnCommand = function(self)
				self
					:sleep(0.5)
					:easeoutexpo(0.25)
					:diffusealpha(1)
					:addx(-200)
			end,
			OffCommand = function(self)
				self
					:easeinexpo(0.25)
					:diffusealpha(0)
					:addx(200)
			end,
		},
		Def.ActorFrame {
			InitCommand = function(self)
				self
					:x(SCREEN_CENTER_X)
					:skewx(0.5)
					:diffusealpha(0)
			end,
			OnCommand = function(self)
				self
					:sleep(0.5)
					:easeoutexpo(0.25)
					:diffusealpha(1)
					:addx(-300)
			end,
			OffCommand = function(self)
				self
					:easeinexpo(0.25)
					:diffusealpha(0)
					:addx(300)
			end,
			Def.BitmapText {
				Name = 'SongTitleM',
				Font = '_xide/40px',
				InitCommand = function(self)
					self
						:horizalign('right')
						:vertalign('bottom')
						:addy(-10)
						:maxwidth(SCREEN_WIDTH * 0.35)
					local target = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse() or GAMESTATE:GetCurrentSong()
					self:settext(target:GetDisplayMainTitle())
				end,
				OnCommand = function(self)
					if self:GetParent():GetChild('SongTitleS'):GetWidth() > 0 then
						self
							:addx((self:GetParent():GetChild('SongTitleS'):GetWidth() + 10) * -1.5)
					end
				end,
			},
			Def.BitmapText {
				Name = 'SongTitleS',
				Font = '_xide/20px',
				InitCommand = function(self)
					self
						:zoom(1.5)
						:horizalign('right')
						:vertalign('bottom')
						:addy(-10)
						:maxwidth((SCREEN_WIDTH * 0.35) * 0.75)
					local target = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse() or GAMESTATE:GetCurrentSong()
					self:settext(target:GetDisplaySubTitle())
				end,
			},
			Def.BitmapText {
				Name = 'SongTitle',
				Font = '_xide/20px',
				InitCommand = function(self)
					self
						:horizalign('right')
						:vertalign('top')
						:addy(10)
						:maxwidth(SCREEN_WIDTH * 0.75)
					local target = GAMESTATE:IsCourseMode() and GAMESTATE:GetCurrentCourse() or GAMESTATE:GetCurrentSong()
					self:settext(target:GetDisplayArtist())
				end,
				OffCommand = function(self)
					self:sleep(1.25)
				end,
			},
		},
	}
}