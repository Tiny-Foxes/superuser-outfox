local ThemeColor = LoadModule('Theme.Colors.lua')

return function(pn, opts)

	local plrprefs = GAMESTATE:GetPlayerState(pn):GetPlayerOptions('ModsLevel_Preferred')

	-- Menu Container
	local af = Def.ActorFrame {
		Name = 'MenuContainer',
		InitCommand = function(self)
			self:y(SCREEN_CENTER_Y * 0.5)
		end,
	}

	--[[

		Main Menu
		- Modifiers
		  - Speed Type - ""
		  - Speed Value - ##
		  - Zoom - ##
		- Appearance
		  - NoteSkin - ""
		  - Judgment - ""
		  - Hold Judgment - ""
		- More Options (goes to ScreenPlayerOptions)

	--]]

	local main = Def.ActorScroller {
		Name = 'MainOptions',
		UseScroller = true,
		UpdateCommand = function(self)
			self:SetCurrentAndDestinationItem(self:getaux())
		end,
		MenuDownCommand = function(self)
		end,
	}

	for v in ivalues {'Modifiers', 'Appearance', 'More Options'} do
		main[#main + 1] = Def.ActorFrame {
			Name = v,
			Def.Quad {
				InitCommand = function(self)
					self:SetSize(240, 64):diffuse(ThemeColor[ToEnumShortString(pn)])
				end,
			},
			Def.BitmapText {
				Font = 'Common Normal',
				Text = v,
			}
		}
	end

	local mods = Def.ActorScroller {
		Name = 'ModifierOptions',
	}

	local look = Def.ActorScroller {
		Name = 'AppearanceOptions',
	}

end