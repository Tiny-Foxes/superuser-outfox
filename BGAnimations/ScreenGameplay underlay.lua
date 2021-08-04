local ThemeColor = LoadModule('Theme.Colors.lua')

return Def.ActorFrame {
    Def.ActorFrame {
        InitCommand = function(self)
            self
                :xy(SCREEN_CENTER_X, 80)
        end,
        OnCommand = function(self)
            self
                :addy(-80)
                :sleep(0.25)
                :easeinoutexpo(0.5)
                :addy(80)
        end,
        Def.Quad {
            InitCommand = function(self)
                self
                    :SetSize(SCREEN_WIDTH, 88)
                    :diffuse(ThemeColor.Black)
                    :fadetop(0.1)
                    :fadebottom(0.1)
                    :diffusealpha(0.5)
            end,
        }
        Def.Quad {
            InitCommand = function(self)
                self
                    :SetSize(SCREEN_WIDTH, 80)
                    :diffuse(ThemeColor.Primary)
                    :diffusebottomedge(ThemeColor.Secondary)
                    :diffusealpha(0.75)
            end,
        },
    },
}
