-- run while you still can
if true then return Def.ActorFrame {} end
-- This is going to be painful. ~Sudo
return Def.ActorFrame {
	OnCommand = function(self)
		SCREENMAN:GetTopScreen():GetChild('RoomWheel'):visible(false)
		for pn, plr in pairs(PlayerNumber) do
			SCREENMAN:set_input_redirected(plr, true)
		end
		local roominfo = SCREENMAN:GetTopScreen():GetChild('RoomInfoDisplay')
		local screen = SCREENMAN:GetTopScreen()
		for k, v in pairs(screen:GetChildren()) do
			lua.ReportScriptError(k..': '..tostring(v))
		end
		lua.ReportScriptError(tostring(roominfo))
		roominfo:x(SCREEN_LEFT + 160)
		-- yup this is painful. ~Sudo
		local chatinput = SCREENMAN:GetTopScreen():GetChild('ChatInput')
		
	end,
	LoadModule('Options.Wheel.lua') {
		StartIndex = 1,
		Loop = true,
		{'Create Room', function(self)
			lua.ReportScriptError('go away')
		end},
		{'Call Your Mom', function(self)
			lua.ReportScriptError('good bean')
		end},
	},
	OffCommand = function(self)
		for pn, plr in pairs(PlayerNumber) do
			SCREENMAN:set_input_redirected(plr, false)
		end
	end,
	CancelCommand = function(self)
		self:playcommand('Off')
	end,
	StartTransitioningCommand = function(self)
		self:playcommand('Off')
	end,
}
