local ThemeColor = LoadModule('Theme.Colors.lua')

local toasties = Def.ActorFrame {}

if GAMESTATE:IsHumanPlayer(PLAYER_1) then
	if LoadModule("Config.Load.lua")("ToastiesDraw",CheckIfUserOrMachineProfile(0).."/OutFoxPrefs.ini") then
		toasties[#toasties+1] = LoadModule("Options.SmartToastieActors.lua")(1)
	end
end

if GAMESTATE:IsHumanPlayer(PLAYER_2) then
	if LoadModule("Config.Load.lua")("ToastiesDraw",CheckIfUserOrMachineProfile(1).."/OutFoxPrefs.ini") then
		toasties[#toasties+1] = LoadModule("Options.SmartToastieActors.lua")(2)
	end
end

return Def.ActorFrame {
	-- Chart Difficulties
	Def.ActorFrame {
		InitCommand = function(self)
			self
				:addx(SCREEN_LEFT - 260)
				:addy(SCREEN_BOTTOM - 46)
				:visible(false)
		end,
		OnCommand = function(self)
			self
				:visible(GAMESTATE:IsSideJoined(PLAYER_1))
				:sleep(0.25)
				:easeoutexpo(0.5)
				:addx(256)
		end,
		OffCommand = function(self)
			self
				:easeoutexpo(0.5)
				:addx(-256)
		end,
		Def.Quad {
			InitCommand = function(self)
				self
					:SetSize(512, 46)
					:addx(-8)
					:skewx(-0.5)
					:diffuse(ColorLightTone(PlayerColor(PLAYER_1)))
			end,
		},
		Def.BitmapText {
			Font = 'Common Normal',
			InitCommand = function(self)
				self
					:sleep(0.25)
					:easeoutexpo(0.75)
					:zoom(1.25)
					:addx(224)
					:addy(-2)
					:halign(1)
				local diff = GAMESTATE:GetCurrentSteps(PLAYER_1)
				if diff then
					self:settext(diff:GetMeter())
				end
			end,
		},
		Def.BitmapText {
			Font = 'Common Normal',
			InitCommand = function(self)
				self
					:zoom(1.25)
					:addx(24)
					:addy(-2)
					:halign(0)
				local diff = GAMESTATE:GetCurrentSteps(PLAYER_1)
				if diff then
					self:settext(THEME:GetString("CustomDifficulty",ToEnumShortString(diff:GetDifficulty())))
				end
			end,
		}
	},
	Def.ActorFrame {
		InitCommand = function(self)
			self
				:addx(SCREEN_RIGHT + 260)
				:addy(SCREEN_HEIGHT - 46)
				:visible(false)
		end,
		OnCommand = function(self)
			self
				:visible(GAMESTATE:IsSideJoined(PLAYER_2))
				:sleep(0.25)
				:easeoutexpo(0.75)
				:addx(-256)
		end,
		OffCommand = function(self)
			self
				:easeoutexpo(0.5)
				:addx(256)
		end,
		Def.Quad {
			InitCommand = function(self)
				self
					:SetSize(512, 46)
					:addx(8)
					:skewx(-0.5)
					:diffuse(ColorLightTone(PlayerColor(PLAYER_2)))
			end,
		},
		Def.BitmapText {
			Font = 'Common Normal',
			InitCommand = function(self)
				self
					:zoom(1.25)
					:addx(-224)
					:addy(-2)
					:halign(0)
				local diff = GAMESTATE:GetCurrentSteps(PLAYER_2)
				if diff then
					self:settext(diff:GetMeter())
				end
			end,
		},
		Def.BitmapText {
			Font = 'Common Normal',
			InitCommand = function(self)
				self
					:sleep(0.25)
					:easeoutexpo(0.75)
					:zoom(1.25)
					:addx(-24)
					:addy(-2)
					:halign(1)
				local diff = GAMESTATE:GetCurrentSteps(PLAYER_2)
				if diff then
					self:settext(THEME:GetString("CustomDifficulty",ToEnumShortString(diff:GetDifficulty())))
				end
			end,
		}
	},
	-- Toasties
	toasties,
}