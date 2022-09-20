local ThemeColor = LoadModule('Theme.Colors.lua')
local p = ...
local t = Def.ActorFrame{}
local pane_x_position = string.find(p, "P1") and -GAMESTATE:GetCurrentStyle():GetWidth(p)+20 or GAMESTATE:GetCurrentStyle():GetWidth(p)-20
local pane_align = string.find(p, "P1") and right or left
local DLW = LoadModule("Config.Load.lua")("DisableLowerWindows","Save/OutFoxPrefs.ini") or false

if GAMESTATE:IsHumanPlayer(p) then
	-- Main evaluation
	local Name, Length = LoadModule("Options.SmartTapNoteScore.lua")()
	table.sort(Name)
	Name[#Name+1] = "Miss"
	Name[#Name+1] = "MaxCombo"
	Length = Length + 2
	-- max 12
	local yspacing = Length == 12 and 24 or 32
	local fontzoom = Length == 12 and 0.6 or 0.75
	local backupy = Length < 12 and scale( Length, 1, 12, 360, -160 ) or 32
	for i, v in ipairs( Name ) do
		local JudgVar = 0
		t[#t+1] = Def.ActorFrame {
			OnCommand=function(self)
				local plr = SCREENMAN:GetTopScreen():GetChild('Player'..ToEnumShortString(p))
				self:xy(plr:GetX()+pane_x_position,(SCREEN_CENTER_Y+backupy)+(yspacing*i) + (v == "MaxCombo" and 20 or 0) )
				:diffusealpha(0):decelerate(0.4):diffusealpha(0.86)
			end,
			OffCommand=function(self) self:decelerate(0.3):diffusealpha(0) end,
			-- Numbers numbers numbers!
			Def.BitmapText {
				Font = "Common Large",
				Text=0,
				InitCommand=function(self)
					self:diffuse(BoostColor(ThemeColor[v], 1.1))
					self:strokecolor(Color.Black)
					self:zoom(fontzoom):diffusealpha(1.0):shadowlength(1):maxwidth(120):horizalign(pane_align)
					if DLW then
						for i=0,1 do
							if (v == 'W'..(5-i) and tonumber(DLW) >= (i+1)) then self:diffusealpha( 0.4 ) end
						end
					end
				end,
				JudgmentMessageCommand=function(self,params) 
					if params.Player ~= p or params.HoldNoteScore then return end
					if params.TapNoteScore and ToEnumShortString(params.TapNoteScore) == v then
						JudgVar = JudgVar + 1
						self:settext(JudgVar)
					end
					if v == "MaxCombo" then
						self:settext( STATSMAN:GetCurStageStats():GetPlayerStageStats(p):MaxCombo() )
					end
				end
			}
		}
	end
	-- The outlayer
	t[#t+1] = Def.BitmapText {
		Font = "Common Normal",
		InitCommand=function(self)
			self:diffuse(BoostColor((JudgmentLineToColor("JudgmentLine_MaxCombo")),1.1))
			:strokecolor(ColorDarkTone((JudgmentLineToColor("JudgmentLine_MaxCombo"))))
			:zoom(0.5):skewx(-0.2):diffusealpha(1.0):shadowlength(1):maxwidth(140):horizalign(pane_align)
			:settext(JudgmentLineToLocalizedString("MaxCombo"))
		end,
		OnCommand=function(self)
			local plr = SCREENMAN:GetTopScreen():GetChild('Player'..ToEnumShortString(p))
			self:xy(plr:GetX()+pane_x_position,SCREEN_CENTER_Y+backupy+(yspacing*Length))
			:diffusealpha(0):decelerate(0.4):diffusealpha(0.86)
		end,
		OffCommand=function(self) self:decelerate(0.3):diffusealpha(0) end
	}
end
	
return t
