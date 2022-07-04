-- REMOVE ME

local ThemeColor = LoadModule("Theme.Colors.lua")

return Def.Quad {
    InitCommand = function(self)
        self
            :SetSize(260, 48)
            :diffuse(ThemeColor.Elements)
            :skewx(-0.5)
            :shadowlength(2, 2)
    end,
}