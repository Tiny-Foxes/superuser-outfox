local ThemeColor = LoadModule('Theme.Colors.lua')
local p = ...
local t = Def.ActorFrame{}
local pane_x_position = string.find(p, "P1") and (GAMESTATE:GetCurrentStyle():GetWidth(p)*SCREEN_HEIGHT/480*0.5)+5 or -(GAMESTATE:GetCurrentStyle():GetWidth(p)*SCREEN_HEIGHT/480*0.5)-5
local pane_align = string.find(p, "P1") and left or right
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
	local backupy = (Length < 12 and scale( Length, 1, 12, 360, -160 ) or 32) - 60
	t[#t+1] = Def.Quad {
		OnCommand = function(self)
			local plr = SCREENMAN:GetTopScreen():GetChild('Player'..ToEnumShortString(p))
			self:xy(plr:GetX()+pane_x_position+(p:find('P1') and -5 or 5),(SCREEN_CENTER_Y+backupy)-10)
			:horizalign(pane_align):SetSize(120, SCREEN_HEIGHT * 0.75):skewy(p:find('P1') and 0.5 or -0.5):valign(0)
			if (IsGame('dance') or IsGame('pump')) then
				local c = tonumber(LoadModule('Config.Load.lua')('ScreenFilterColor', PROFILEMAN:GetProfileDir(0)..'/OutFoxPrefs.ini'))
				local colors = {
					{
						ThemeColor.Black,
						ColorDarkTone(ThemeColor[ToEnumShortString(p)]),
					},
					{
						ThemeColor.Black,
						ThemeColor.Black,
					},
					{
						ThemeColor[ToEnumShortString(p)],
						ColorDarkTone(ThemeColor[ToEnumShortString(p)]),
					},
					{
						ThemeColor.White,
						ThemeColor.White,
					},
					{
						ThemeColor.Gray,
						ThemeColor.Gray,
					}
				}
				local a = LoadModule('Config.Load.lua')('ScreenFilter', PROFILEMAN:GetProfileDir(0)..'/OutFoxPrefs.ini')
				if a then
					self:diffuse(ColorDarkTone(BoostColor(colors[c][2], 0.97)))
					self:diffusebottomedge(ColorLightTone(BoostColor(colors[c][2], 0.8)))
					self:diffusealpha(a)
				else
					self:visible(false)
				end
			end
			if p:find('P1') then self:cropright(0.5):faderight(0.25) else self:cropleft(0.5):fadeleft(0.25) end
		end,
	}
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
