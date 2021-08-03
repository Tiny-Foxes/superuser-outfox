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
	--[[
	Def.Quad {
		InitCommand = function(self)
			self
				:y(-(SCREEN_CENTER_Y + 120) + 82+68)
				:skewx(-0.5)
				:SetSize(SCREEN_WIDTH * 1.5, 170 + 48)
				:diffuse(ThemeColor.Black)
				:fadetop(0.02)
				:fadebottom(0.02)
				:diffusealpha(0.75)
				:faderight(0.1)
				:cropright(1)
		end,
		OnCommand = function(self)
			self
				:easeinoutexpo(0.25)
				:faderight(0)
				:cropright(0)
		end,
	},
	Def.Quad {
		InitCommand = function(self)
			self
				:y(-(SCREEN_CENTER_Y + 120)  + 82+68)
				:skewx(-0.5)
				:SetSize(SCREEN_WIDTH * 1.5, 164 + 48)
				:diffuse(ThemeColor.Primary)
				:diffusealpha(0.5)
				:faderight(0.1)
				:cropright(1)
		end,
		OnCommand = function(self)
			self
				:easeinoutexpo(0.25)
				:faderight(0)
				:cropright(0)
		end,
	},
	--]]
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
		},
		Def.BitmapText {
			Font = 'Common Normal',
			Text = 'TITLE\n\nARTIST\n\n\nNotes\nHolds\nRolls\nHands\nMines\nFakes',
			InitCommand = function(self)
				self
					:x(32)
					:y(-120)
					:horizalign('left')
					:vertalign('top')
					:addx(-SCREEN_CENTER_X)
			end,
			OnCommand = function(self)
				self
					:easeinoutexpo(0.5)
					:addx(SCREEN_CENTER_X)
			end,
		},
		-- Song Info
		Def.ActorFrame {
			Name = 'SongInfo',
			InitCommand = function(self)
				self
					:x(32 + 120)
					:y(-120)
					:addx(-SCREEN_CENTER_X)
			end,
			OnCommand = function(self)
				self
					:sleep(0.25)
					:easeoutexpo(0.25)
					:addx(SCREEN_CENTER_X)
			end,
			Def.BitmapText {
				Name = 'Title',
				Font = 'Common Normal',
				Text = '--',
				InitCommand = function(self)
					self
						:horizalign('left')
						:vertalign('top')
						:maxwidth(160)
				end,
				GetInfoCommand = function(self)
					self:settext(CallSongFunc('GetDisplayMainTitle'))
				end,
				OnCommand = function(self)
					self:playcommand('GetInfo')
				end,
				CurrentSongChangedMessageCommand = function(self)
					self:playcommand('GetInfo')
				end,
			},
			Def.BitmapText {
				Name = 'Subtitle',
				Font = 'Common Normal',
				Text = '--',
				InitCommand = function(self)
					self
						:addy(24)
						:horizalign('left')
						:vertalign('top')
						:maxwidth(160)
				end,
				GetInfoCommand = function(self)
					self:settext(CallSongFunc('GetDisplaySubTitle'))
				end,
				OnCommand = function(self)
					self:playcommand('GetInfo')
				end,
				CurrentSongChangedMessageCommand = function(self)
					self:playcommand('GetInfo')
				end,
			},
			Def.BitmapText {
				Name = 'Artist',
				Font = 'Common Normal',
				Text = '--',
				InitCommand = function(self)
					self
						:addy(48)
						:horizalign('left')
						:vertalign('top')
						:maxwidth(160)
				end,
				GetInfoCommand = function(self)
					self:settext(CallSongFunc('GetDisplayArtist'))
				end,
				OnCommand = function(self)
					self:playcommand('GetInfo')
				end,
				CurrentSongChangedMessageCommand = function(self)
					self:playcommand('GetInfo')
				end,
			},
			LoadActor(THEME:GetPathG('ScreenSelectMusic', 'Difficulties')),
		},
	},
}