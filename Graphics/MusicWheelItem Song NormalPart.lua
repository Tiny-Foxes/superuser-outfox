local ThemeColor = LoadModule('Theme.Colors.lua')

local song = Var 'Song'

local ret = Def.ActorFrame {
	Def.Quad {
		InitCommand = function(self)
			self
				:SetSize(320, 48)
				:diffuse(ThemeColor.Elements)
				:skewx(-0.5)
				:shadowlength(2, 2)
		end,
	},
}

local function get_diffs(song, b)
	local doubs = b or false
	if not song then return end
	local ret, charts = {}, {}
	if GAMESTATE:IsCourseMode() then
		charts = song:GetAllTrails()
	else
		charts = song:GetAllSteps()
	end
	if charts then
		for _, d in ipairs(charts) do
			local match = d:GetStepsType()
			match = match:lower()
			if match:find(GAMESTATE:GetCurrentGame():GetName()) then
				if not (match:find('double') and ((GAMESTATE:GetNumPlayersEnabled() > 1) or not doubs)) then
					ret[#ret + 1] = d
				end
			end
		end
	end
	return ret
end

local charts = get_diffs(song, true)
for i, chart in ipairs(charts) do
	local pip = Def.ActorFrame {
		Name = 'Diff'..i,
		InitCommand = function(self)
			self
				:valign(0)
				:xy(-150, -20)
				:addx(i * 20)
			if chart:GetStepsType():lower():find('_double') then
				self:addx(10)
				self:visible(SU_Wheel.IncludeDoubles())
			end
		end,
		ChangeDifficultyCommand = function(self)
			if chart:GetStepsType():lower():find('_double') then
				self:visible(SU_Wheel.IncludeDoubles())
			end
		end,
		Def.Quad {
			InitCommand = function(self)
				self
					:SetSize(16, 12)
					:skewx(-0.5)
					:diffuse(ThemeColor[chart:GetDifficulty():sub(chart:GetDifficulty():find('_') + 1, -1)] or color('#080808'))
					if chart:IsAutogen() then self:diffusebottomedge(ThemeColor.Pink) end
			end
		}
	}
	if chart:GetStepsType():lower():find('_double') then
		pip[#pip + 1] = Def.BitmapText {
			Font = 'Common Normal',
			Text = 'D',
			InitCommand = function(self)
				self:zoom(0.5):xy(1, -1)
			end,
		}
	end
	ret[#ret + 1] = pip
	--actor[#actor + 1] = pip
end

return ret
