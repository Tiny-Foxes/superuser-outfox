local ThemeColor = LoadModule("Theme.Colors.lua")

local t = Def.ActorFrame {
	FOV=90,
}


t[#t+1] = Def.Quad {
	InitCommand=function(self) 
        self
            :SetSize(500,60)
            :diffuse(ThemeColor.Secondary)
            :shadowlength(2, 2)
            :addx(200)
            :skewx(-0.5)
    end
}

--[[
t[#t+1] = Def.Quad {
	InitCommand=function(self) 
        self
            :SetSize(900,60)
            :diffuse(1,1,1,0.2)
            :shadowlength(2, 2)
            :skewx(-0.5)
    end
}]]

t[#t+1] = Def.ActorFrame {
    InitCommand = function(self)
        self
            :addx(-SCREEN_CENTER_X+((SCREEN_WIDTH-900)/2)+175)
    end,
    --[[
    OnCommand = function(self)
		self
			:diffusealpha(0)
			:x(SCREEN_CENTER_X)
			:easeoutexpo(0.5)
			:diffusealpha(1)
			:x(0)
	end,
	OffCommand = function(self)
		self
			:easeinoutexpo(0.5)
			:diffusealpha(0)
	end,]]
    Def.Quad {
        InitCommand = function(self)
            self
                :SetSize(350, 60)
                :diffuse(ThemeColor.Elements)
                :skewx(-0.5)
                :shadowlength(2, 2)
        end,
    },
    Def.ActorFrame {
        SetCommand = function(self, params)
            if params.Song then
                self:GetChild("Title"):settext( params.Song:GetMainTitle() ):diffuse( SONGMAN:GetSongColor(params.Song) )
                self:GetChild("Artist"):playcommand("Exists"):settext( params.Song:GetDisplayArtist() )

                if params.Song:GetDisplaySubTitle() ~= "" then
                    self
                        :GetChild("Title")
                        :zoom(0.9)
                        :y(0)

                    self
                        :GetChild("Artist")
                        :y(-16)
                    
                    self
                        :GetChild("Subtitle")
                        :settext(params.Song:GetDisplaySubTitle())
                        :playcommand("Exists")
                end
            else
                self:GetChild("Title"):settext( params.Course:GetTitle() ):GetChild("Title"):diffuse( SONGMAN:GetCourseColor(params.Course) );
            end
        end,
        Def.BitmapText {
            Name = "Artist",
            Font = 'Common Normal',
            Text = "???",
            InitCommand = function(self)
                self
                    :maxwidth(325)
                    :zoom(0.6)
                    :y(-13)
                    :visible(false)
            end,
            ExistsCommand = function(self)
                self
                    :visible(true)
            end,
        },
        Def.BitmapText {
            Name = "Title",
            Font = 'Common Normal',
            Text = "???",
            InitCommand = function(self)
                self
                    :maxwidth(325)
                    :y(8)
            end,
        },
        Def.BitmapText {
            Name = "Subtitle",
            Font = 'Common Normal',
            Text = 'How are you even seeing this?',
            InitCommand = function(self)
                self
                    :maxwidth(325)
                    :zoom(0.6)
                    :y(16)
                    :visible(false)
            end,
            ExistsCommand = function(self)
                self
                    :visible(true)
            end,
        }
    }
}

local NumColumns = THEME:GetMetric(Var "LoadingScreen", "NumColumns")

local c
local Scores = Def.ActorFrame {
	InitCommand = function(self)
		c = self:GetChildren()
	end
}

t[#t+1] = Scores

for i = 1, NumColumns do
	local x_pos = (500/NumColumns * (i-1) + 500/NumColumns/2)-50
    --[[
	Scores[#Scores+1] = LoadFont(Var "LoadingScreen","Name") .. {
		Name = i .. "Name"
		InitCommand=function(self) self:x(x_pos):y(8):shadowlength(1):maxwidth(68) end
		OnCommand=function(self) self:zoom(0.75) end
	}
	Scores[#Scores+1] = LoadFont(Var "LoadingScreen","Score") .. {
		Name = i .. "Score"
		InitCommand=function(self) self:x(x_pos):y(-9):shadowlength(1):maxwidth(68) end
		OnCommand=function(self) self:zoom(0.75) end
	}
	Scores[#Scores+1] = LoadActor("empty") .. {
		Name = i .. "Empty"
		InitCommand=function(self) self:x(x_pos) end
		OnCommand=function(self) self:zoom(0.75) end
	}
	]]
    Scores[#Scores+1] = Def.BitmapText {
		Name = i .. "Name",
        Font = 'Common Normal',
		InitCommand=function(self) self:x(x_pos):y(8):shadowlength(1):maxwidth(68) end,
		OnCommand=function(self) self:zoom(0.75) end
	}
	Scores[#Scores+1] = Def.BitmapText {
		Name = i .. "Score",
        Font = 'Common Normal',
		InitCommand=function(self) self:x(x_pos):y(-9):shadowlength(1):maxwidth(68) end,
		OnCommand=function(self) self:zoom(0.75) end
	}
	Scores[#Scores+1] = Def.BitmapText {
		Name = i .. "Empty",
        Font = 'Common Normal',
		InitCommand=function(self) self:x(x_pos) end,
		OnCommand=function(self) self:zoom(0.75) end
	}
end

local sNoScoreName = THEME:GetMetric("Common", "NoScoreName")

Scores.SetCommand=function(self, params)
	local pProfile = PROFILEMAN:GetMachineProfile()

	for name, child in pairs(c) do
		child:visible(false)
	end
	for i=1,NumColumns do
		c[i .. "Empty"]:visible(true)
	end

	local Current = params.Song or params.Course
	if Current then
		for i, CurrentItem in pairs(params.Entries) do
			if CurrentItem then
				local hsl = pProfile:GetHighScoreList(Current, CurrentItem)
				local hs = hsl and hsl:GetHighScores()

				local name = c[i .. "Name"]
				local score = c[i .. "Score"]
				local empty = c[i .. "Empty"]
				
				name:visible( true )
				score:visible( true )
				empty:visible( false )
				
				if hs and #hs > 0 then
					name:settext( hs[1]:GetName() )
					score:settext( FormatPercentScore( hs[1]:GetPercentDP() ) )
				else
					name:settext( sNoScoreName )
					score:settext( FormatPercentScore( 0 ) )
				end
			end
		end
	end
end

return t
