local gc = Var("GameCommand");
local item_width = 260;
local item_height = 48;

return Def.ActorFrame {
	InitCommand = function(self)
		self
			:SetSize(item_width, item_height)
			:diffusealpha(0.75)
			:fov(70)
	end,
	OnCommand = function(self)
		self
			:diffusealpha(0)
			:x(SCREEN_CENTER_X)
			:easeoutexpo(0.5)
			:diffusealpha(1)
			:x(0)
	end,
	OffCommand = function(self)
		self
			:easeoutexpo(0.5)
			:diffusealpha(0)
	end,
	Def.ActorFrame {
		GainFocusCommand = function(self)
			self
				:stoptweening()
				:easeoutexpo(0.1)
				:x(12)
				--:rotationy(10)
				:zoom(1.1)
		end,
		LoseFocusCommand = function(self)
			self
				:stoptweening()
				:easeoutexpo(0.1)
				:x(0)
				:rotationy(0)
				:zoom(1)
		end,
		Def.Quad {
			InitCommand = function(self)
				self
					:SetSize(item_width, item_height)
					:diffuse(color('#9D276C'))
					:skewx(-0.5)
					:shadowlength(2, 2)
			end,
		},
		Def.BitmapText {
			Font = 'Common Normal',
			Text = THEME:GetString('ScreenTitleMenu', gc:GetText()),
		},
		Def.Quad {
			InitCommand = function(self)
				self
					:SetSize(item_width, item_height)
					:diffuse(color('#777777')) -- get it haha
			end,
			DisabledCommand = function(self)
				self:diffuse(0, 0, 0, 0.6)
			end,
			EnabledCommand = function(self)
				self:diffuse(1, 1, 1, 0)
			end,
		},
	},
}