local ThemeColor = LoadModule('Theme.Colors.lua')

return Def.ActorFrame {
	InitCommand = function(self) self:skewx(-0.5) end,
	OnCommand = function(self)
		self:playcommand('ShowStepsDisplay')
	end,
	CurrentSongChangedMessageCommand = function(self)
		self:playcommand('ShowStepsDisplay')
	end,
	ShowStepsDisplayCommand = function(self)
		local bShow = GAMESTATE:GetCurrentSong() ~= nil or GAMESTATE:GetCurrentCourse() ~= nil
		self:visible(bShow)
	end,
	Def.StepsDisplayList {
		Name = 'StepsDisplayListRow',
		OnCommand = function(self)
			self
				:xy(-(SCREEN_CENTER_X * 0.5) + 56, -132)
				:addx(-SCREEN_CENTER_X)
				:sleep(0.25)
				:easeoutexpo(0.25)
				:addx(SCREEN_CENTER_X)
		end,
		OffCommand = function(self)
			self
				:easeinexpo(0.25)
				:addx(-SCREEN_CENTER_X)
		end,
		CursorP1 = Def.ActorFrame {
			InitCommand = function(self)
				self
					:addx(-28)
					:player(PLAYER_1)
			end,
			PlayerJoinedMessageCommand = function(self, params)
				if params.Player == PLAYER_1 then
					self
						:visible(true)
						:cropbottom(1)
						:easeinoutexpo(0.25)
						:cropbottom(0)
				end
			end,
			PlayerUnjoinedMessageCommand = function(self)
				if params.Player == PLAYER_1 then
					self
						:visible(true)
						:cropbottom(0)
						:easeinoutexpo(0.25)
						:cropbottom(1)
				end
			end,
			Def.Quad {
				Name = 'CursorP1',
				InitCommand = function(self)
					self
						:SetSize(8, 56)
						:diffuse(ColorLightTone(PlayerColor(PLAYER_1)))
				end,
			},
		},
		CursorP1Frame = Def.ActorFrame{},
		CursorP2 = Def.ActorFrame {
			InitCommand = function(self)
				self
					:addx(28)
					:player(PLAYER_2)
			end,
			PlayerJoinedMessageCommand = function(self, params)
				if params.Player == PLAYER_2 then
					self
						:visible(true)
						:cropbottom(1)
						:easeinoutexpo(0.25)
						:cropbottom(0)
				end
			end,
			PlayerUnjoinedMessageCommand = function(self)
				if params.Player == PLAYER_2 then
					self
						:visible(true)
						:cropbottom(0)
						:easeinoutexpo(0.25)
						:cropbottom(1)
				end
			end,
			Def.Quad {
				Name = 'CursorP2',
				InitCommand = function(self)
					self
						:SetSize(8, 56)
						:diffuse(ColorLightTone(PlayerColor(PLAYER_2)))
				end,
			},
		},
		CursorP2Frame = Def.ActorFrame{},
	},
}