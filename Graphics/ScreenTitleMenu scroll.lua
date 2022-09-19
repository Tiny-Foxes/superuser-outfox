local gc = Var("GameCommand")
local item_width = 260
local item_height = 48
local splash = false

local hovered = false

local id = ProductID()
if not string.find(id, 'OutFox') then
	return Def.Actor {}
end

local function UpdateMouse(self)
	local mouseX, mouseY = INPUTFILTER:GetMouseX(), INPUTFILTER:GetMouseY()
	local targetX, targetY = self:GetParent():GetX() + self:GetDestX(), self:GetParent():GetY() + self:GetDestY()
	local isOnX = (mouseX > targetX - (item_width * 0.5) and mouseX < targetX + (item_width * 0.5))
	local isOnY = (mouseY > targetY - (item_height * 0.5) and mouseY < targetY + (item_height * 0.5))
	if isOnX and isOnY then
		if not hovered then self:playcommand('MouseHovered') end
	else
		if hovered then self:playcommand('MouseUnhovered') end
	end
end

return Def.ActorFrame {
	Name = gc:GetText(),
	InitCommand = function(self)
		if ProductVersion():find('0.5') then self:SetUpdateFunction(UpdateMouse) end
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
			:easeinoutexpo(0.5)
			:diffusealpha(0)
	end,
	MouseHoveredMessageCommand = function(self)
		hovered = true
		SOUND:PlayOnce(THEME:GetPathS('Common', 'value'), true)
		self:queuecommand('GainFocus')
	end,
	MouseUnhoveredMessageCommand = function(self)
		hovered = false
		self:queuecommand('LoseFocus')
	end,
	MouseLeftClickMessageCommand = function(self, params)
		if not params.IsPressed then return end
		if hovered then
			SCREENMAN
				:PlayStartSound()
				:GetTopScreen()
					:SetNextScreenName(gc:GetScreen())
					:StartTransitioningScreen('SM_GoToNextScreen')
		end
	end,
	Def.ActorFrame {
		InitCommand = function(self)
			self:visible(true)
			if splash then self:visible(false) end
		end,
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
		Def.Quad {
			InitCommand= function(self)
				self
					:SetSize(item_width, item_height)
					:diffuse(color('#FFFFFF'))
					:skewx(-0.5)
			end,
			GainFocusCommand = function(self)
				self
					:diffusealpha(0.3)
					:glowshift()
					:effectcolor1(color('#00000000'))
					:effectcolor2(color('#FFFFFFFF'))
			end,
			LoseFocusCommand = function(self)
				self
					:diffusealpha(0)
					:stopeffect()
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