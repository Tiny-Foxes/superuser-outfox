local function InputHandler(event)
	print(event.button)
	if event.button == 'Back' then
		SCREENMAN:GetTopScreen()
			:SetPrevScreenName(SelectMusicOrCourse())
		SCREENMAN
			:PlayCancelSound()
			:SetNewScreen(SCREENMAN:GetTopScreen():GetPrevScreenName())
		SOUND:StopMusic()
	end
end

return Def.ActorFrame {
	FOV = 45,
	OnCommand = function(self)
		SCREENMAN:GetTopScreen():fardistz(10000):fov(45)
		for i, v in ipairs(GAMESTATE:GetEnabledPlayers()) do
			SCREENMAN:GetTopScreen():AddChildFromPath(THEME:GetPathG('Preview', ToEnumShortString(v)))
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
		SCREENMAN:GetTopScreen():AddInputCallback(InputHandler)
		self:queuecommand('ScreenReady')
	end,
	ScreenReadyCommand = function(self)
		local song = GAMESTATE:GetCurrentSong()
		local pos = GAMESTATE:GetSongPosition()
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
		for k, v in pairs(song:GetFGChanges()) do
			if v.file1 ~= '' and v.start_beat ~= -10000 then
				local file = v.file1
				if not loadfile(song:GetSongDir()..file) then
					file = file..'/default.lua'
				end
				if assert(loadfile(song:GetSongDir()..file)) then
					self:AddChildFromPath(song:GetSongDir()..file)
					self:GetChildAt(self:GetNumChildren()):name('Modfile')
					self:GetChild('Modfile')
						:SetUpdateFunction(function(self)
							for i, v in ipairs(GAMESTATE:GetEnabledPlayers()) do
								local plr = SCREENMAN:GetTopScreen():GetChild('Player'..ToEnumShortString(v))
								local mods = GAMESTATE:GetPlayerState(v):GetPlayerOptionsString('ModsLevel_Song')
								plr:GetChild('NoteField'):GetPlayerOptions('ModsLevel_Current'):FromString(mods)
							end
							SCREENMAN:GetTopScreen():GetChild('Overlay'):visible(true)
						end)
						:SetUpdateRate(v.rate or 1)
						:playcommand('Init')
					local offset = 2 + (v.start_beat * GAMESTATE:GetSongBPS())
					self
						:sleep((offset > 0 and offset) or 0)
						:queuecommand('FGMods')
				end
			end
		end
	end,
	FGModsCommand = function(self)
		self:GetChild('Modfile'):playcommand('On')
	end,
	OffCommand = function(self)
		SCREENMAN:GetTopScreen():RemoveInputCallback(InputHandler)
	end,
	LoadActor(THEME:GetPathB('ScreenGameplay', 'overlay')),
}
