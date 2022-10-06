local SongFG = Def.ActorFrame {
	Name = 'SongForeground',
	ScreenReadyCommand = function(self)
		ActorUtil.LoadAllCommands(self, 'ScreenGameplay')
		self:sleep(2 - offset):queuecommand('Propagate')
	end,
	PropagateCommand = function(self)
		self:SetUpdateFunction(function()
			ArrowEffects.Update()
		end)
		self:playcommand('Init'):queuecommand('On')
	end,
}
local song = GAMESTATE:GetCurrentSong()
local fgactors = Def.ActorFrame {}
local fgchanges = {}
local data = File.Read(song:GetSongFilePath())
local idx = data:find('#FGCHANGES') + string.len('#FGCHANGES:')
local start = data:sub(idx, data:find('=', idx) - 1)
idx = data:find('=', idx) + 1
local path = data:sub(idx, data:find('=', idx) - 1)
table.insert(fgchanges, {start_beat = start, file1 = path, rate = 1})
for k, v in pairs(fgchanges) do
	if v.file1 ~= '' then
		local file = v.file1
		if not loadfile(song:GetSongDir()..file) then
			file = file..'/default.lua'
		end
		if assert(loadfile(song:GetSongDir()..file)) then
			table.insert(SongFG, LoadActor(song:GetSongDir()..file))
		end
	end
end

return SongFG
