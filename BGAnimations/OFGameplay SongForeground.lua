return Def.ActorFrame {
	Name = 'SongForeground',
	ScreenReadyCommand = function(self)
		local song = GAMESTATE:GetCurrentSong()
		ActorUtil.LoadAllCommands(self, 'ScreenGameplay')
		for k, v in pairs(song:GetBGChanges()) do
		end
		--for k, v in pairs(song:GetFGChanges()) do
		---[[
		local fgchanges = {}
		local data = File.Read(song:GetSongFilePath())
		local idx = data:find('#FGCHANGES') + string.len('#FGCHANGES:')
		local start = data:sub(idx, data:find('=', idx) - 1)
		idx = data:find('=', idx) + 1
		local path = data:sub(idx, data:find('=', idx) - 1)
		fgchanges[#fgchanges + 1] = {start_beat = start, file1 = path, rate = 1}
		--]]
		for k, v in pairs(fgchanges) do
			if v.file1 ~= '' then
				local file = v.file1
				if not loadfile(song:GetSongDir()..file) then
					file = file..'/default.lua'
				end
				if assert(loadfile(song:GetSongDir()..file)) then
					local offset = (v.start_beat * GAMESTATE:GetSongBPS())
					if offset < 0 then offset = -1.98 end
					--lua.ReportScriptError(song:GetSongDir()..file)
					self:AddChildFromPath(song:GetSongDir()..file)
					self:GetChildAt(self:GetNumChildren())
						:effectclock('bgm')
						:effectperiod(0.5)
						:set_tween_uses_effect_delta()
					self:sleep(2 - offset):queuecommand('Propagate')
				end
			end
		end
	end,
	PropagateCommand = function(self)
		self:SetUpdateFunction(function()
			ArrowEffects.Update()
		end)
		self:playcommand('Init'):queuecommand('On')
	end,
}
