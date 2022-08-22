local song = GAMESTATE:GetCurrentSong()
local plrs = GAMESTATE:GetEnabledPlayers()

return Def.ActorFrame {
	FOV = 45,
	OnCommand = function(self)
		SCREENMAN:GetTopScreen():fardistz(10000):fov(45)
		for v in ivalues(plrs) do
			SCREENMAN:GetTopScreen():AddChildFromPath(THEME:GetPathG('OFGameplay', 'Player'..ToEnumShortString(v)))
		end
		--self:GetParent():AddChildFromPath(THEME:GetPathG('Players', 'gameplay'))
		local P1 = SCREENMAN:GetTopScreen():GetChild('PlayerP1')
		local N1
		if P1 then
			P1:queuecommand('Setup')
			N1 = P1:GetChild('NoteField')
		end
		local P2 = SCREENMAN:GetTopScreen():GetChild('PlayerP2')
		local N2
		if P2 then
			P2:queuecommand('Setup')
			N2 = P2:GetChild('NoteField')
		end
		if N1 and N2 then
			local p1x = N1:GetX()
			local p2x = N2:GetX()
			N1
				:x(p1x - SCREEN_WIDTH)
				:sleep(0.1)
				:easeoutexpo(1)
				:x(p1x)
			N2
				:x(p2x + SCREEN_WIDTH)
				:sleep(0.1)
				:easeoutexpo(1)
				:x(p2x)
		else
			local plr = N1 or N2
			local plry = plr:GetY()
			plr
				:y(SCREEN_HEIGHT * 1.5)
				:sleep(0.1)
				:easeoutexpo(1)
				:y(plry)
		end
		SCREENMAN:GetTopScreen():AddInputCallback(LoadModule('Lua.InputSystem.lua')(self))
		self:queuecommand('ScreenReady')
	end,
	ScreenReadyCommand = function(self)
		SOUND:PlayMusicPart(
			song:GetMusicPath(),
			-2,
			song:GetLastSecond() + 3,
			0,
			0,
			false,
			true,
			true
		)
	end,
	BackCommand = function(self)
		SOUND:StopMusic()
		SCREENMAN:GetTopScreen():Cancel()
	end,
	LoadActor(THEME:GetPathB('ScreenGameplay', 'overlay')),
	Def.ActorFrame {
		Name = 'Modfiles',
		ScreenReadyCommand = function(self)
			lua.ReportScriptError(tostring(#GAMESTATE:GetCurrentSong():GetFGChanges()))
			for k, v in pairs(song:GetBGChanges()) do
				lua.ReportScriptError(tostring(v))
			end
			for k, v in pairs(song:GetFGChanges()) do
				lua.ReportScriptError(tostring(v))
				if v.file1 ~= '' then
					local file = v.file1
					if not loadfile(song:GetSongDir()..file) then
						file = file..'/default.lua'
					end
					if assert(loadfile(song:GetSongDir()..file)) then
						local offset = 2 + (v.start_beat * GAMESTATE:GetSongBPS())
						self:AddChildFromPath(song:GetSongDir()..file)
						self:GetChildAt(self:GetNumChildren())
							--:SetUpdateRate(v.rate or 1)
							:playcommand('Init')
							:sleep(offset)
							:queuecommand('On')
					end
				end
			end
		end,
		UpdateCommand = function(self)
			--[[
			for v in ivalues {PLAYER_1, PLAYER_2} do
				local plr = SCREENMAN:GetTopScreen():GetChild('Player'..ToEnumShortString(v))
				if plr then
					local mods = GAMESTATE:GetPlayerState(v):GetPlayerOptionsString('ModsLevel_Song')
					plr:GetChild('NoteField'):GetPlayerOptions('ModsLevel_Current'):FromString(mods)
				end
			end
			--]]
			SCREENMAN:GetTopScreen():GetChild('Overlay'):visible(true)
		end,
	},
	Def.Actor {
		Name = 'ENDME',
		ScreenReadyCommand = function(self)
			self:sleep(song:GetLastSecond() + 3):queuecommand('SongFinished')
		end,
		SongFinishedCommand = function(self)
			SCREENMAN:GetTopScreen()
				:SetNextScreenName('ScreenEvaluation')
				-- TODO: Manipulate PlayerStats so this can be replaced with 'SM_DoNextScreen'. ~Sudo
				:StartTransitioningScreen('SM_GoToNextScreen')
		end,
	}
}
