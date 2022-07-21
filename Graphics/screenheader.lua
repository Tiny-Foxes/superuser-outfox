local ThemeColor = LoadModule('Theme.Colors.lua')

return Def.ActorFrame {
	Def.ActorFrame {
		InitCommand = function(self)
			self
				:xy(SCREEN_CENTER_X, 30)
				:skewx(-0.5)
				:addy(-60)
		end,
		OnCommand = function(self)
			self
				:easeoutexpo(0.25)
				:addy(60)
		end,
		OffCommand = function(self)
			self
				:easeinexpo(0.25)
				:addy(-60)
		end,
		-- its the fuckin song bullshit again
		Def.Quad {
			InitCommand = function(self)
				self
					:SetSize(SCREEN_WIDTH * 1.5, 64)
					:diffuse(ThemeColor.Black)
					:diffusealpha(0.5)
					:fadetop(0.02)
					:fadebottom(0.02)
			end,
		},
		Def.Quad {
			InitCommand = function(self)
				self
					:SetSize(SCREEN_WIDTH * 1.5, 60)
					:diffuse(ThemeColor.Primary)
					:diffusealpha(1)
			end,
		},
		Def.Quad {
			InitCommand = function(self)
				self
					:SetSize(SCREEN_WIDTH * 1.5, 60)
					:diffuse(ThemeColor.Black)
					:diffusealpha(0.25)
			end,
		},
		Def.BitmapText {
			Font = 'Common Large',
			OnCommand = function(self)
				self
					:x(-SCREEN_CENTER_X + 15)
					:y(0)
					:zoom(0.7)
					:skewx(0.5)
					:horizalign('left')
				self:settext(THEME:GetString(SCREENMAN:GetTopScreen():GetName(), 'HeaderText'))
			end,
			OffCommand = function(self)
			end,
		},
		-- ScreenSelectMusic specific stuff
		Def.BitmapText {
			Font = 'Common Large',
			InitCommand = function(self)
				self
					:x(SCREEN_CENTER_X / 2)
					:zoom(0.7)
					:skewx(0.5)
			end,
			CurrentSongChangedMessageCommand = function(self)
				if SCREENMAN:GetTopScreen() and SCREENMAN:GetTopScreen():GetName() == "ScreenSelectMusic" then
					self:settext(string.sub(GAMESTATE:GetSortOrder(), 11))
				else
					self:settext('')
				end
			end,
		},
		-- TODO: Show what Song number we're on ~ -YOSEFU-
	},
	Def.ActorFrame {
		InitCommand = function(self)
			self
				:visible(PREFSMAN:GetPreference("MenuTimer") and THEME:GetMetric(Var "LoadingScreen","TimerSeconds") ~= -1)
				:x(SCREEN_WIDTH+120)
				:y(-90)
		end,
		OnCommand = function(self)
			self
				:easeoutexpo(0.6)
				:addx(-180)
				:addy(135)
		end,
		OffCommand = function(self)
			self
				:easeinoutexpo(0.6)
				:addx(180)
				:addy(-135)
		end,
		Def.Quad {
			InitCommand = function(self)
				self
					:SetSize(124,98)
					:diffuse(ThemeColor.Black)
					:diffusealpha(0.5)
					:fadetop(0.04)
					:fadebottom(0.04)
					:skewx(-0.5)
			end,
		},
		Def.Quad {
			InitCommand = function(self)
				self
					:SetSize(120,90)
					:diffuse(ThemeColor.Primary)
					:skewx(-0.5)
			end,
		}
	},
	
}
