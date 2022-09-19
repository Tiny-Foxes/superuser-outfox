local ThemeColor = LoadModule('Theme.Colors.lua')

local toasties = Def.ActorFrame {}

if GAMESTATE:IsHumanPlayer(PLAYER_1) then
	if not LoadModule("Config.Load.lua")("ToastiesDraw",CheckIfUserOrMachineProfile(0).."/OutFoxPrefs.ini") then
		toasties[#toasties+1] = LoadModule("Options.SmartToastieActors.lua")(1)
	end
end

if GAMESTATE:IsHumanPlayer(PLAYER_2) then
	if not LoadModule("Config.Load.lua")("ToastiesDraw",CheckIfUserOrMachineProfile(1).."/OutFoxPrefs.ini") then
		toasties[#toasties+1] = LoadModule("Options.SmartToastieActors.lua")(2)
	end
end

local song = GAMESTATE:GetCurrentSong()
local songPos = GAMESTATE:GetSongPosition()

return Def.ActorFrame {
	OnCommand=function(self) self:playcommand("UpdateDiscordInfo") end,
	UpdateDiscordInfoCommand=function(s)
		-- discord support UwU
		local player = GAMESTATE:GetMasterPlayerNumber()
		local StageIndex = GAMESTATE:GetCurrentStageIndex()
		if GAMESTATE:GetCurrentSong() then
			local title = PREFSMAN:GetPreference("ShowNativeLanguage") and GAMESTATE:GetCurrentSong():GetDisplayMainTitle() or GAMESTATE:GetCurrentSong():GetTranslitFullTitle()
			local artist = PREFSMAN:GetPreference("ShowNativeLanguage") and GAMESTATE:GetCurrentSong():GetDisplayArtist() or GAMESTATE:GetCurrentSong():GetTranslitArtist()
			local songname = title .. " by ".. artist .." - " .. GAMESTATE:GetCurrentSong():GetGroupName()
			local state = GAMESTATE:IsDemonstration() and "Watching Song" or "Playing Song (".. StageIndex+1 ..")"
			GAMESTATE:UpdateDiscordProfile(GAMESTATE:GetPlayerDisplayName(player))
			local stats = STATSMAN:GetCurStageStats()
			if not stats then
				return
			end
			local courselength = function()
				if GAMESTATE:IsCourseMode() then
					if GAMESTATE:GetPlayMode() ~= "PlayMode_Endless" then
						return GAMESTATE:GetCurrentCourse():GetDisplayFullTitle().. " (Song ".. stats:GetPlayerStageStats( player ):GetSongsPassed()+1 .. " of ".. GAMESTATE:GetCurrentCourse():GetEstimatedNumStages() ..")" or ""
					end
					return GAMESTATE:GetCurrentCourse():GetDisplayFullTitle().. " (Song ".. stats:GetPlayerStageStats( player ):GetSongsPassed()+1 .. ")" or ""
				end
			end
			GAMESTATE:UpdateDiscordSongPlaying(GAMESTATE:IsCourseMode() and courselength() or state,songname,GAMESTATE:GetCurrentSong():GetLastSecond())
		end
	end,
	CurrentSongChangedMessageCommand=function(s) s:playcommand("UpdateDiscordInfo") end,
	-- Toasties
	toasties,
	-- Filter
	Def.ActorFrame {
		-- Player 1
		Def.Quad {
			OnCommand = function(self)
				local plr = SCREENMAN:GetTopScreen():GetChild('PlayerP1')
				self:visible(false)
				if ((IsGame('dance') or IsGame('pump')) and plr) then
					self
						:visible(true)
						:xy(plr:GetX(), plr:GetY())
						:SetSize(GAMESTATE:GetCurrentStyle():GetWidth(PLAYER_1) * SCREEN_HEIGHT / 480, SCREEN_HEIGHT)
					local c = tonumber(LoadModule('Config.Load.lua')('ScreenFilterColor', PROFILEMAN:GetProfileDir(0)..'/OutFoxPrefs.ini'))
					local colors = {
						{
							ThemeColor.Black,
							ColorDarkTone(ThemeColor.P1),
						},
						{
							ThemeColor.Black,
							ThemeColor.Black,
						},
						{
							ThemeColor.P1,
							ColorDarkTone(ThemeColor.P1),
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
						self:diffuse(colors[c][1])
						self:diffusebottomedge(colors[c][2])
						self:diffusealpha(a)
					else
						self:visible(false)
					end
				end
			end,
		},
		-- Player 2
		Def.Quad {
			OnCommand = function(self)
				local plr = SCREENMAN:GetTopScreen():GetChild('PlayerP2')
				self:visible(false)
				if ((IsGame('dance') or IsGame('pump')) and plr) then
					self
						:visible(true)
						:xy(plr:GetX(), plr:GetY())
						:SetSize(GAMESTATE:GetCurrentStyle():GetWidth(PLAYER_1) * SCREEN_HEIGHT / 480, SCREEN_HEIGHT)
					local c = tonumber(LoadModule('Config.Load.lua')('ScreenFilterColor', PROFILEMAN:GetProfileDir(1)..'/OutFoxPrefs.ini'))
					local colors = {
						{
							ThemeColor.Black,
							ColorDarkTone(ThemeColor.P2),
						},
						{
							ThemeColor.Black,
							ThemeColor.Black,
						},
						{
							ThemeColor.P2,
							ColorDarkTone(ThemeColor.P2),
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
					print(colors[c])
					local a = LoadModule('Config.Load.lua')('ScreenFilter', PROFILEMAN:GetProfileDir(1)..'/OutFoxPrefs.ini')
					if a then
						self:diffuse(colors[c][1])
						self:diffusebottomedge(colors[c][2])
						self:diffusealpha(a)
					else
						self:visible(false)
					end
				end
			end,
		},
	},
	-- The fuckin uhhhhhhhhhh song info thingy or whatever fukkinnnnnn uuuUUUUUU
	Def.ActorFrame {
		InitCommand = function(self)
			self
				:xy(SCREEN_CENTER_X, 40)
				:addy(-120)
		end,
		OnCommand = function(self)
			self
				:easeoutexpo(0.5)
				:addy(120)
				--:luaeffect('ReportCursor')
		end,
		OffCommand = function(self)
			self
				:easeinexpo(0.5)
				:addy(-120)
		end,
		-- Panel
		Def.Quad {
			InitCommand = function(self)
				self
					:SetSize(SCREEN_WIDTH, 88)
					:diffuse(ThemeColor.Black)
					:diffusealpha(0.5)
					:fadetop(0.1)
					:fadebottom(0.1)
			end,
		},
		Def.Quad {
			InitCommand = function(self)
				self
					:SetSize(SCREEN_WIDTH, 80)
					:diffuse(ThemeColor.Primary)
					:diffusealpha(0.75)
			end,
		},
		Def.Quad {
			InitCommand = function(self)
				self
					:SetSize(SCREEN_WIDTH + 4, 8)
					:addy(36)
					:diffuse(ThemeColor.Elements)
					:cropright(1)
					:skewx(-0.5)
					:luaeffect('SongTime')
			end,
			SongTimeCommand = function(self)
				local cur = songPos:GetMusicSeconds()
				local last = song:GetLastSecond()
				self:cropright(0.99 - (cur / (last * 1.01)))
			end,
		},
		--Text
		Def.BitmapText {
			Font = 'Common Large',
			InitCommand = function(self)
				if song then
					self:settext(song:GetDisplayFullTitle())
				end
				self
					:zoom(0.75)
					:vertalign('bottom')
					:maxwidth(SCREEN_CENTER_X * 0.5)
			end,
		},
		Def.BitmapText {
			Font = 'Common Normal',
			InitCommand = function(self)
				if song then
					self:settext(song:GetDisplayArtist())
				end
				self
					:zoom(0.75)
					:vertalign('top')
					:addy(12)
					:maxwidth(SCREEN_CENTER_X * 0.5)
			end,
		},
		LoadActorWithParams(THEME:GetPathG('','ButtonLayout'), {}),
	},
}
