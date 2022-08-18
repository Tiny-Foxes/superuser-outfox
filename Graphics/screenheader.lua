local ThemeColor = LoadModule('Theme.Colors.lua')

return Def.ActorFrame {
	InitCommand = function(self)
		self
			:xy(SCREEN_CENTER_X, 20)
			:skewx(-0.5)
			:addy(-40)
	end,
	OnCommand = function(self)
		self
			:easeoutexpo(0.25)
			:addy(40)
	end,
	OffCommand = function(self)
		self
			:easeinexpo(0.25)
			:addy(-40)
	end,
	-- its the fuckin song bullshit again
	Def.Quad {
		InitCommand = function(self)
			self
				:SetSize(SCREEN_WIDTH * 1.5, 44)
				:diffuse(ThemeColor.Black)
				:diffusealpha(0.5)
				:fadetop(0.02)
				:fadebottom(0.02)
		end,
	},
	Def.Quad {
		InitCommand = function(self)
			self
				:SetSize(SCREEN_WIDTH * 1.5, 40)
				:diffuse(ThemeColor.Primary)
				:diffusealpha(1)
		end,
	},
	Def.Quad {
		InitCommand = function(self)
			self
				:SetSize(SCREEN_WIDTH * 1.5, 40)
				:diffuse(ThemeColor.Black)
				:diffusealpha(0.25)
		end,
	},
	Def.BitmapText {
		Name = 'Text',
		Font = 'Common Large',
		OnCommand = function(self)
			self
				:xy(-SCREEN_CENTER_X + 20, 10)
				:skewx(0.5)
				:zoom(0.5)
				:horizalign('left')
				:vertalign('bottom')
				:settext(THEME:GetString(SCREENMAN:GetTopScreen():GetName(), 'HeaderText'))
		end,
		OffCommand = function(self)
		end,
	},
	Def.BitmapText {
		Name = 'SubText',
		Font = 'Common Normal',
		OnCommand = function(self)
			self
				:xy(-SCREEN_CENTER_X + 20 + self:GetParent():GetChild('Text'):GetZoomedWidth() + 12, 10)
				:skewx(0.5)
				:zoom(0.5)
				:horizalign('left')
				:vertalign('bottom')
				:settext(THEME:GetString(SCREENMAN:GetTopScreen():GetName(), 'HeaderSubText'))
		end,
		OffCommand = function(self)
		end,
	},

	-- ScreenSelectMusic specific stuff
	Def.BitmapText {
		Font = 'Common Normal',
		InitCommand = function(self)
			self
				:x(SCREEN_CENTER_X / 2)
				:skewx(0.5)
		end,
		CurrentSongChangedMessageCommand = function(self)
			if Var "LoadingScreen" == "ScreenSelectMusic" then
				self:settext(string.sub(GAMESTATE:GetSortOrder(), 11))
			else
				self:settext('')
			end
		end,
	},

	-- TODO: Show what Song number we're on ~ -YOSEFU-
}
