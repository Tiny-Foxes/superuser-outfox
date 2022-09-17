local gs = LoadModule('GrooveStats.Handler.lua')

local function ReportTable(t, ind)
	ind = ind or 0
	local indent = ''
	for i = 1, ind do
		indent = indent..' '
	end
	for k, v in pairs(t) do
		local vtype = type(v)
		local str = indent..k..': '..tostring(v)
		if vtype == 'table' then str = str..' ('..#v..')' end
		lua.ReportScriptError(str)
		if vtype == 'table' then ReportTable(v, ind + 2) end
	end
end

return Def.ActorFrame {
	LoadActorWithParams(THEME:GetPathG('', 'screenheader'), {}),
	Def.Actor {
		OnCommand = function(self)
			SCREENMAN:GetTopScreen():AddInputCallback(LoadModule('Lua.InputSystem.lua')(self))
		end,
		MenuUpCommand = function(self)
			local plr = self.pn
			local pn = PlayerNumber:Reverse()[plr] + 1
			local prof = PROFILEMAN:GetProfile(plr)
			if not prof then
				SCREENMAN:SystemMessage('No profile loaded.')
				return
			end
			local path = PROFILEMAN:GetProfileDir(ProfileSlot[pn])
			if not path then
				SCREENMAN:SystemMessage('Profile path not found.')
				return
			end
			local gsData = IniFile.ReadFile(path..'GrooveStats.ini')
			if not gsData.GrooveStats then
				SCREENMAN:SystemMessage('No GrooveStats metrics detected.')
				return
			end
			if not gsData.GrooveStats.ApiKey then
				SCREENMAN:SystemMessage('No API key for profile.')
				return
			end
			SCREENMAN:SystemMessage('Submitting score to GrooveStats, please wait...')
			local res = gs.submit {
				['player'..pn] = {
					apiKey = gsData.GrooveStats.ApiKey,
					profileName = prof:GetDisplayName(),
					chartHash = GAMESTATE:GetCurrentSteps(plr):GetHash(),
					rate = GAMESTATE:GetSongOptionsObject('ModsLevel_Preferred'):MusicRate() * 100,
					comment = GAMESTATE:GetPlayerState(plr):GetPlayerOptionsString('ModsLevel_Preferred'),
					score = STATSMAN:GetCurStageStats():GetPlayerStageStats(plr):GetActualDancePoints() * 100,
				}
			}
			if res then
				if res.status ~= 'success' then
					SCREENMAN:SystemMessage('Failed to submit score: connection '..res.status..'.')
					return
				end
				SCREENMAN:SystemMessage('Submitted score to GrooveStats.')
				return
			end
			SCREENMAN:SystemMessage('Failed to submit score: no response from server.')
		end,
	}
}
