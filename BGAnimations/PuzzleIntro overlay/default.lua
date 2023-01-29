local allow_input = false

local usernames = PROFILEMAN:GetLocalProfileDisplayNames()
local dialog = {
	index = 1,
	JsonEncode({
		halign = 0.5,
		valign = 0.5,
		xy = {SCREEN_CENTER_X, SCREEN_CENTER_Y},
		sleep = 3,
	})..'Long ago...',
	'Gardenia, the goddess of the earth, roamed the land with all inhabitants.',
	'She spread life and growth wherever she walked.',
	'A true harmony was held between forest and humanity.',
	JsonEncode({
		sleep = 3,
	})..'One day, Gardenia came with grim news.',
	JsonEncode({
		sleep = 3,
	})..'"In twenty centuries and five score, there will pose a threat to all of life, and the entirety of Earth."',
	'"It will wish to consume all in its view."',
	'"I will protect you from the earth eater, but not in this form."',
	'"I shall manifest a stone, made of my immortal being, to put an end to the earth eater."',
	'"You must seal this stone until the time the earth eater arrives to claim the world in its belly."',
	JsonEncode({
		sleep = 3,
	})..'And so, Gardenia created the cardium stone from her own immortal being.',
	'The people obeyed her command, and sealed the stone away.',
	JsonEncode({
		sleep = 3,
	})..'And the stone now waits for a time that draws so near.',
}

return Def.ActorFrame {
	Def.BitmapText {
		Name = 'DialogText',
		Font = 'Common Normal',
		OnCommand = function(self)
			SCREENMAN:GetTopScreen():AddInputCallback(TF_WHEEL.Input(self))
			self.pn = PlayerNumber[1]
			allow_input = true
			self:queuecommand('Start')
		end,
		AllowInputCommand = function(self)
			allow_input = true
		end,
		DisallowInputCommand = function(self)
			allow_input = false
		end,
		StartCommand = function(self)
			if self.pn ~= PlayerNumber[1] or not allow_input then return
			else
				local line = dialog[dialog.index]
				if not line then line = '' end
				local commands = {}
				if line:find('{') and line:find('}') then
					commands = JsonDecode(line:sub(line:find('{'), line:find('}')))
					line = line:sub(line:find('}') + 1, -1)
				end
				self
					:stoptweening()
					:playcommand('DisallowInput')
					:halign(0)
					:valign(0)
					:xy(12, SCREEN_BOTTOM - 72)
					:cropright(1)
					:settext(line)
				for k, v in pairs(commands) do
					if type(v) == 'table' then
						self[k](self, table.unpack(v))
					else
						self[k](self, v)
					end
				end
				self
					:linear(0.003 * self:GetWidth())
					:cropright(0)
					:queuecommand('AllowInput')
				dialog.index = dialog.index + 1
			end
		end,
	}
}
