local can_play = false
local gc = Var("GameCommand");
local item_width = 260;
local item_height = 48;

return Def.ActorFrame {
    InitCommand = function(self)
        self:zoom(1.1)
    end,
    OnCommand = function(self)
        self:playcommand("Refresh")
    end,
    CoinInsertedMessageCommand = function(self)
        self:playcommand("Refresh")
    end,
    CoinModeChangedMessageCommand = function(self)
        self:playcommand("Refresh")
    end,
    RefreshCommand=function(self)
        can_play = (GAMESTATE:EnoughCreditsToJoin() or (GAMESTATE:GetNumSidesJoined() > 0))
        self:GetChild("OverlayQuad"):playcommand("Init")
    end,
    Def.Quad {
        Name = "OverlayQuad",
        InitCommand = function(self)
            self
                :SetSize(item_width, item_height)
                :diffuse(0.2,0.2,0.2,0.5)
                :skewx(-0.5)
                :draworder(100)
                :playcommand("Refresh")
        end,
        RefreshCommand = function(self)
            if can_play then
                self
                    :diffuse(1,1,1,0.3)
                    :glowshift()
                    :effectcolor1(0,0,0,0)
                    :effectcolor2(1,1,1,1)
            end
        end
    },
    Def.Quad {
        InitCommand = function(self)
            self
                :SetSize(item_width, item_height)
                :diffuse(color('#9D276C'))
                :skewx(-0.5)
                :shadowlength(2, 2)
        end,
    },
    Def.BitmapText {
        Font = 'Common Normal',
        Text = THEME:GetString('ScreenTitleMenu', gc:GetText()),
        InitCommand = function(self)
            self:draworder(101)
        end
    },
}