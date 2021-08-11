local function InputHandler(event)
	MESSAGEMAN:Broadcast('Input', {event})
end

local StepHandler = {}

for pn = 1, 2 do
	StepHandler[pn] = function(col, tns)
		local ret = {
			column = col,
			tns = tns,
		}
		MESSAGEMAN:Broadcast('StepP'..pn, ret)
	end
end

local af = Def.ActorFrame {
	OnCommand = function(self)
		SCREENMAN:GetTopScreen():AddInputCallback(InputHandler)
		for pn = 1, 2 do
			local plr = SCREENMAN:GetTopScreen():GetChild('PlayerP'..pn)
			if plr then plr:GetChild('NoteField'):set_step_callback(StepHandler[pn]) end
		end
	end,
	OffCommand = function(self)
		SCREENMAN:GetTopScreen():RemoveInputCallback(InputHandler)
		for pn = 1, 2 do
			local plr = SCREENMAN:GetTopScreen():GetChild('PlayerP'..pn)
			if plr then plr:GetChild('NoteField'):set_step_callback() end
		end
	end,
}

for pn = 1, 2 do
	if GAMESTATE:GetCurrentGame():GetName() == 'dance' then
		af[#af + 1] = Def.ActorFrame {
			Name = 'BtnOverlayP'..pn,
			InitCommand = function(self)
				self
					:zoom(0.5)
					:xy(SCREEN_CENTER_X - (112 * (0.5 - (pn - 1))), 145)
				if not GAMESTATE:IsSideJoined(PlayerNumber[pn]) then
					self:visible(false)
				end
			end,
			Def.Quad {
				Name = 'BtnLeft',
				InitCommand = function(self)
					self
						:x(-64)
						:SetSize(64, 64)
				end,
				InputMessageCommand = function(self, param)
					local event = param[1]

					if event.PlayerNumber ~= 'PlayerNumber_P'..pn then return end
					if event.type ~= 'InputEventType_Release' then return end

					if event.button == 'Left' then
						self:diffuse(color('#FFFFFF'))
					end
				end,
				['StepP'..pn..'MessageCommand'] = function(self, step)
					if step.column == 1 then
						if step.tns ~= 'TapNoteScore_None' then
							local jl = 'JudgmentLine_'..step.tns:sub(step.tns:find('_') + 1, -1)
							self:diffuse(JudgmentLineToColor(jl))
						else
							self:diffuse(color('#808080'))
						end
					end
				end,
				OffCommand = function(self)
					self:diffuse(color('#FFFFFF'))
				end,
			},
			Def.Quad {
				Name = 'BtnRight',
				InitCommand = function(self)
					self
						:x(64)
						:SetSize(64, 64)
				end,
				InputMessageCommand = function(self, param)
					local event = param[1]

					if event.PlayerNumber ~= 'PlayerNumber_P'..pn then return end
					if event.type ~= 'InputEventType_Release' then return end

					if event.button == 'Right' then
						self:diffuse(color('#FFFFFF'))
					end
				end,
				['StepP'..pn..'MessageCommand'] = function(self, step)
					if step.column == 4 then
						if step.tns ~= 'TapNoteScore_None' then
							local jl = 'JudgmentLine_'..step.tns:sub(step.tns:find('_') + 1, -1)
							self:diffuse(JudgmentLineToColor(jl))
						else
							self:diffuse(color('#808080'))
						end
					end
				end,
				OffCommand = function(self)
					self:diffuse(color('#FFFFFF'))
				end,
			},
			Def.Quad {
				Name = 'BtnUp',
				InitCommand = function(self)
					self
						:y(-64)
						:SetSize(64, 64)
				end,
				InputMessageCommand = function(self, param)
					local event = param[1]

					if event.PlayerNumber ~= 'PlayerNumber_P'..pn then return end
					if event.type ~= 'InputEventType_Release' then return end

					if event.button == 'Up' then
						self:diffuse(color('#FFFFFF'))
					end
				end,
				['StepP'..pn..'MessageCommand'] = function(self, step)
					if step.column == 3 then
						if step.tns ~= 'TapNoteScore_None' then
							local jl = 'JudgmentLine_'..step.tns:sub(step.tns:find('_') + 1, -1)
							self:diffuse(JudgmentLineToColor(jl))
						else
							self:diffuse(color('#808080'))
						end
					end
				end,
				OffCommand = function(self)
					self:diffuse(color('#FFFFFF'))
				end,
			},
			Def.Quad {
				Name = 'BtnDown',
				InitCommand = function(self)
					self
						:y(64)
						:SetSize(64, 64)
				end,
				InputMessageCommand = function(self, param)
					local event = param[1]

					if event.PlayerNumber ~= 'PlayerNumber_P'..pn then return end
					if event.type ~= 'InputEventType_Release' then return end

					if event.button == 'Down' then
						self:diffuse(color('#FFFFFF'))
					end
				end,
				['StepP'..pn..'MessageCommand'] = function(self, step)
					if step.column == 2 then
						if step.tns ~= 'TapNoteScore_None' then
							local jl = 'JudgmentLine_'..step.tns:sub(step.tns:find('_') + 1, -1)
							self:diffuse(JudgmentLineToColor(jl))
						else
							self:diffuse(color('#808080'))
						end
					end
				end,
				OffCommand = function(self)
					self:diffuse(color('#FFFFFF'))
				end,
			},
		}
	end
end

return af
