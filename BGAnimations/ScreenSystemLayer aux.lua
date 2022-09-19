-- This isn't ready and might just be Alpha 4 exclusive. ~Sudo
local allow_cursor = false

local mouse = Def.Quad {
	Name = 'Cursor',
	InitCommand = function(self)
		self
			:SetSize(16, 16)
			:luaeffect('Update')
	end,
	UpdateCommand = function(self)
		self:xy(INPUTFILTER:GetMouseX(), INPUTFILTER:GetMouseY())
	end,
}
if Var 'LoadingScreen' == 'ScreenInit' or not allow_cursor then mouse = Def.Actor {} end

return Def.ActorFrame {
	mouse
}
