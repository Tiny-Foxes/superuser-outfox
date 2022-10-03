-- stdlib.lua --

std = {}
setmetatable(std, {})

std.VERSION = '1.5'
std.AUTHOR = 'Sudospective'

-- Standard library variables, mostly shortcuts
std.POS = GAMESTATE:GetSongPosition()
std.DIR = GAMESTATE:GetCurrentSong():GetSongDir()

std.COLNUM = GAMESTATE:GetCurrentStyle():ColumnsPerPlayer()
std.GAME = GAMESTATE:GetCurrentGame()

std.SW, std.SH = SCREEN_WIDTH, SCREEN_HEIGHT -- screen width and height
std.SCX, std.SCY = SCREEN_CENTER_X, SCREEN_CENTER_Y -- screen center x and y

std.SCREEN = SCREENMAN:GetTopScreen()

std.DT = 0 -- time since last frame in seconds

std.BEAT = std.POS:GetSongBeat() -- current beat
std.BPS = std.POS:GetCurBPS() -- current beats per second
std.BPM = std.BPS * 60 -- beats per minute
std.SPB = 1 / std.BPS -- seconds per beat
std.PL = {} -- Player table

local start
local song = GAMESTATE:GetCurrentSong()
if song.GetFGChanges then
	for _, v in ipairs(song:GetFGChanges()) do
		if v[2] == 'main' then start = v[1] end
	end
end
std.START = start or -10 -- start of the modfile


-- This might not be added on the engine side yet.
if not Tweens.instant then
	Tweens.instant = function(x) return 1 end
end
if not Tweens.sleep then
	Tweens.sleep = function(x) return (x < 1 and 0) or 1 end
end


local env = getfenv(2)

local InputHandler = function(event)
	if input then
		input(event)
	end
	MESSAGEMAN:Broadcast(env._scope..'Input', {event})
end


FG[#FG + 1] = Def.ActorFrame {
	Name = 'stdlib',
	InitCommand = function(self)
		if init then
			init()
		end
	end,
	ReadyCommand = function(self)
		std.SCREEN = SCREENMAN:GetTopScreen()
		std.SCREEN:AddInputCallback(InputHandler)
		for i, v in ipairs( GAMESTATE:GetEnabledPlayers() ) do
			local info = {}
	
			local pl = std.SCREEN:GetChild('Player'..ToEnumShortString(v))
			if not plr and std.SCREEN.GetEditState then
				for _,v in pairs(std.SCREEN:GetChild('')) do
					if string.find(tostring(v),'Player') then
						pl = v
					end
				end
			end
			info.Player = pl
			info.Number = v
			info.InitX = pl:GetX()
			info.InitY = pl:GetY()
			info.Life = std.SCREEN:GetChild('Life'..ToEnumShortString(v))
			info.Score = std.SCREEN:GetChild('Score'..ToEnumShortString(v))
			info.Combo = pl:GetChild('Combo')
			info.Judgment = pl:GetChild('Judgment')
			info.NoteField = pl:GetChild('NoteField')
			info.NoteData = pl:GetNoteData()
			info.State = GAMESTATE:GetPlayerState(v)
			info.Stats = STATSMAN:GetCurStageStats():GetPlayerStageStats(v)
			info.Options = GAMESTATE:GetPlayerState(v):GetPlayerOptions('ModsLevel_Song')
			info.Columns = pl:GetChild('NoteField'):GetColumnActors()
	
			std.PL[i] = info
		end
		std.PL = setmetatable(std.PL, {
			__index = function(this, number)
				if number < 1 or number > #this then
					print( string.format("[PL] No player was found on index %i, using first item instead.", number) )
					return this[1]
				end
				return this
			end
		})
		-- We need new values for these ASAP, since before init gives us bad values.
		std.BEAT = std.POS:GetSongBeat() -- current beat
		std.BPS = std.POS:GetCurBPS() -- current beats per second
		std.BPM = std.BPS * 60 -- beats per minute
		std.SPB = 1 / std.BPS -- seconds per beat
		std.DT = self:GetEffectDelta() -- time since last frame in seconds
		self:queuecommand('Start')
	end,
	StartCommand = function(self)
		if ready then
			ready()
		end
		if draw then
			self:SetDrawFunction(draw)
		end
	end,
	UpdateCommand = function(self)
		std.BEAT = std.POS:GetSongBeat()
		std.BPS = std.POS:GetCurBPS()
		std.BPM = std.BPS * 60
		std.SPB = 1 / std.BPS
		std.DT = self:GetEffectDelta()
		if update then
			update(std.DT)
		end
	end,
	OffCommand = function(self)
		std.SCREEN:RemoveInputCallback(InputHandler)
	end,
}

function std.aftmult(a)
	return a * 0.9
end

function std.InitAFT(aft, recursive)
	if not recursive then
		aft
			:SetSize(std.SW, std.SH)
			:EnableFloat(false)
			:EnableDepthBuffer(true)
			:EnableAlphaBuffer(false)
			:EnablePreserveTexture(false)
			:Create()
	else
		aft
			:SetSize(std.SW, std.SH)
			:EnableFloat(false)
			:EnableDepthBuffer(false)
			:EnableAlphaBuffer(false)
			:EnablePreserveTexture(true)
			:Create()
	end
end

function std.MapAFT(aft, sprite)
	sprite
		:Center()
		:SetTexture(aft:GetTexture())
end

function std.RegisterPlayer(plr, pn)
	local env = getfenv(2)
	local info = {}

	local plrcopy = math.mod(pn - 1, 2) + 1

	info.Player = plr
	info.Number = math.mod(pn - 1, 2)
	info.InitX = plr:GetX()
	info.InitY = plr:GetY()
	info.Life = std.PL[plrcopy].Life
	info.Score = std.PL[plrcopy].Score
	info.Judgment = std.PL[plrcopy].Judgment
	info.NoteField = plr:GetChild('NoteField')
	info.NoteData = std.PL[plrcopy].NoteData
	info.State = std.PL[plrcopy].State -- some day.......
	info.Stats = std.PL[plrcopy].Stats
	info.Options = plr:GetChild('NoteField'):GetPlayerOptions('ModsLevel_Current')
	info.Columns = plr:GetChild('NoteField'):GetColumnActors()

	std.PL[pn] = info


end

function std.ProxyPlayer(proxy, pn, vanish)
	local plr = std.PL[pn].Player
	if not proxy:GetTarget() then
		proxy:SetTarget(plr)
		if vanish then
			plr:vanishpointx(std.SCX - plr:GetX())
		end
		plr:visible(false)
		local t = std.PL[pn].ProxyP or {}
		t[#t + 1] = proxy
		std.PL[pn].ProxyP = t
	end
	return proxy
end

function std.ProxyJudgment(proxy, pn)
	local plr = std.PL[pn].Player
	proxy
		:SetTarget(plr:GetChild('Judgment'))
		:xy(std.SCX * 0.5 + (std.SCX * (pn - 1)), std.SCY)
		:zoom(sh / 480)
	plr:GetChild('Judgment')
		:visible(false)
		:sleep(9e9)
	std.PL[pn].ProxyJ = proxy
	return proxy
end

function std.ProxyCombo(proxy, pn)
	local plr = std.PL[pn].Player
	proxy
		:SetTarget(plr:GetChild('Combo'))
		:xy(std.SCX * 0.5 + (std.SCX * (pn - 1)), std.SCY)
		:zoom(sh / 480)
	plr:GetChild('Combo')
		:visible(false)
		:sleep(9e9)
	std.PL[pn].ProxyC = proxy
	return proxy
end


std.__index = std

print('Loaded Kitsu Standard Library v'..std.VERSION)
