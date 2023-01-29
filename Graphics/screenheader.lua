local ThemeColor = LoadModule('Theme.Colors.lua')

local header = THEME:GetString(Var 'LoadingScreen', 'HeaderText')
local subheader = THEME:GetString(Var 'LoadingScreen', 'HeaderSubText')

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
		Font = 'Stylized Large',
		OnCommand = function(self)
			self
				:xy(-SCREEN_CENTER_X + 20, 8)
				:skewx(0.5)
				:zoom(0.5)
				:shadowlengthy(1)
				:horizalign('left')
				:vertalign('bottom')
				:settext(header)
		end,
		OffCommand = function(self)
		end,
	},
	Def.BitmapText {
		Name = 'SubText',
		Font = 'Common Normal',
		OnCommand = function(self)
			self
				:xy(-SCREEN_CENTER_X + 20 + self:GetParent():GetChild('Text'):GetZoomedWidth() + 12, 8)
				:skewx(0.5)
				:zoom(0.5)
				:shadowlengthy(1)
				:horizalign('left')
				:vertalign('bottom')
				:settext(subheader)
		end,
		OffCommand = function(self)
		end,
	},

	-- ScreenSelectMusic specific stuff
	Def.BitmapText {
		Font = 'Common Large',
		OnCommand = function(self)
			self
				:xy(SCREEN_CENTER_X - 280, 0)
				:skewx(0.5)
				:zoom(0.5)
				:shadowlengthy(1)
			self:queuecommand('ShowSort')
		end,
		CycleSortMessageCommand = function(self)
			self:queuecommand('ShowSort')
		end,
		ShowSortCommand = function(self)
			if SCREENMAN:GetTopScreen():GetName():find('OFSelectMusic') then
				self
					:settext(TF_WHEEL.PreferredSort)
			else
				self:visible(false)
			end
			--[[
			if GAMESTATE:GetSortOrder() and string.find(Var 'LoadingScreen', "SelectMusic") then
				self:settext(string.sub(GAMESTATE:GetSortOrder(), 11))
			elseif string.find(Var 'LoadingScreen', 'SelectMusic') then
				self:settext(TF_WHEEL.PreferredSort)
			else
				self:settext('')
			end
			--]]
		end,
	},
	-- TODO: Show what Song number we're on ~ -YOSEFU-
	Def.BitmapText {
		Font = 'Common Large',
		OnCommand = function(self)
			if not SCREENMAN:GetTopScreen():GetName():find('OFSelectMusic') then
				self:visible(false)
			else
				self
					:xy(0, 0)
					:skewx(0.5)
					:zoom(0.5)
					:shadowlengthy(1)
				if GAMESTATE:GetCurrentStage():find('Event') then
					self:settext('Event Mode')
				else
					self:settext(GAMESTATE:GetCurrentStage():gsub('%d+'))
				end
			end
		end,
	}
}
