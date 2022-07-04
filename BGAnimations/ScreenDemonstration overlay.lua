local ThemeColor = LoadModule('Theme.Colors.lua')

return Def.ActorFrame {
    Def.ActorFrame {
        InitCommand = function(self)
            self:draworder(99999)
        end,
        OnCommand = function(self)
            self
                :diffusealpha(0)
                :sleep(0.2)
                :easeinexpo(0.5)
                :diffusealpha(1)
        end,
        OffCommand = function(self)
            self
                :easeinexpo(0.1)
                :diffuse(1,1,1,1)
        end,
        Def.Quad {
            InitCommand = function(self)
                self
                    :SetSize(SCREEN_WIDTH,50)
                    :xy(SCREEN_CENTER_X,SCREEN_CENTER_Y)
                    :diffuse(ThemeColor.Primary)
                    :diffusealpha(0.95)
            end,
        },
        Def.Quad {
            OnCommand = function(self)
                self
                    :sleep(0.2)
                    :SetSize(SCREEN_WIDTH,50)
                    :xy(SCREEN_CENTER_X,SCREEN_CENTER_Y)
                    :diffusealpha(0.1)
                    :glowshift()
                    :effectcolor1(1,1,1,0)
                    :effectcolor2(1,1,1,1)
                    :effectperiod(2)
            end,
        },
        Def.BitmapText {
            Font = 'Common normal',
            Text = "Demonstration",
            InitCommand = function(self)
                self
                    :xy(SCREEN_CENTER_X,SCREEN_CENTER_Y)
            end,
        },
    },
}