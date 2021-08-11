local function InputHandler(event)
	MESSAGEMAN:Broadcast('Input', {event})
end

local af = Def.ActorFrame {
	OnCommand = function(self)
		SCREENMAN:GetTopScreen():AddInputCallback(InputHandler)
	end,
	OffCommand = function(self)
		SCREENMAN:GetTopScreen():RemoveInputCallback(InputHandler)
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

					local diffuseColor = color('#FFFFFF')

					if event.type ~= 'InputEventType_Release' then
						diffuseColor = color('#FF0000')
					else
						diffuseColor = color('#FFFFFF')
					end

					if event.button == 'Left' then
						self:diffuse(diffuseColor)
					end
				end
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

					local diffuseColor = color('#FFFFFF')

					if event.type ~= 'InputEventType_Release' then
						diffuseColor = color('#FF0000')
					else
						diffuseColor = color('#FFFFFF')
					end

					if event.button == 'Right' then
						self:diffuse(diffuseColor)
					end
				end
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

					local diffuseColor = color('#FFFFFF')

					if event.type ~= 'InputEventType_Release' then
						diffuseColor = color('#FF0000')
					else
						diffuseColor = color('#FFFFFF')
					end

					if event.button == 'Up' then
						self:diffuse(diffuseColor)
					end
				end
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

					local diffuseColor = color('#FFFFFF')

					if event.type ~= 'InputEventType_Release' then
						diffuseColor = color('#FF0000')
					else
						diffuseColor = color('#FFFFFF')
					end

					if event.button == 'Down' then
						self:diffuse(diffuseColor)
					end
				end
			},
		}
	end
end

return af
