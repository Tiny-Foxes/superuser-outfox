local ThemeColor = LoadModule("Theme.Colors.lua")

return Def.ActorFrame {
	Name = "ArcadeOverlay",
	InitCommand = function(self)
		ActorUtil.LoadAllCommandsAndSetXY(self,Var "LoadingScreen")
        self:draworder(100)
	end,
	Def.BitmapText {
		Font = "_xide/20px",
        Text = "Something's gone very wrong!",
        InitCommand = function(self)
            self:zoom(1):vertalign(middle):diffuse(color("#EEF1FF")):diffusealpha(0)
            self:diffuseblink()
            self:effectcolor1(1,1,1,1)
            self:effectcolor2(1,1,1,0)
            self:effectperiod(2)
			:shadowlengthy(3)
			:shadowcolor(0,0,0,1)
        end,
        OnCommand = function(self)
            self:playcommand("Refresh")
			self:diffusealpha(1)
        end,
		OffCommand = function(self)
			self:diffusealpha(0)
		end,
		CoinInsertedMessageCommand = function(self)
            self:playcommand("Refresh")
        end,
	    CoinModeChangedMessageCommand = function(self)
            self:playcommand("Refresh")
        end,
		RefreshCommand=function(self)
			local bCanPlay = GAMESTATE:EnoughCreditsToJoin()
			local bReady = GAMESTATE:GetNumSidesJoined() > 0
			if bCanPlay or bReady then
				self:settext( ToUpper(THEME:GetString("ScreenTitleJoin","HelpTextJoin")) )
			else
				self:settext( ToUpper(THEME:GetString("ScreenTitleJoin","HelpTextWait")) )
			end
		end
	}
}
