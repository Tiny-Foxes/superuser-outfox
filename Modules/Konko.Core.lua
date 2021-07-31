--[[
	This is a stripped down version of nodeloader.lua from Kitsu template.
	allows Kitsu node system specifically OUTSIDE of modfiles.
--]]

-- environment builder stolen this from xero thanks xero
_G.sudo = {}
local sudo = setmetatable(sudo, sudo)
sudo.__index = _G
local function nop() end
function sudo:__call(f, name)
	if type(f) == 'string' then
		-- if we call sudo with a string, we need to load it as code
		local err
		-- try compiling the code
		f, err = loadstring( 'return function(self)' .. f .. '\nend', name)
		if err then SCREENMAN:SystemMessage(err) return nop end
		-- grab the function
		f, err = pcall(f)
		if err then SCREENMAN:SystemMessage(err) return nop end
	end
	-- set environment
	setfenv(f or 2, self)
	return f
end

sudo()

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- Environment global variables, mostly shortcuts
SW, SH = SCREEN_WIDTH, SCREEN_HEIGHT -- screen width and height
SCX, SCY = SCREEN_CENTER_X, SCREEN_CENTER_Y -- screen center x and y

TIME = 0 -- overall elapsed time
OFFSET = 0 -- offset in seconds to first beat
DT = 0 -- seconds since last frame
BPM = 120 -- dont set this to 0 or i will eat you
BPS = BPM / 60
SPB = 1 / BPS

if not _G.Tweens.instant then
	Tweens.instant = function(x) return 1 end
end

return Def.ActorFrame {
	InitCommand = function(self)
		self:sleep(9e9)
	end,
	OnCommand = function(self)
		self:playcommand('Ready')
	end,
	Def.ActorFrame {
		BeginFrameCommand = function(self)
			DT = self:GetEffectDelta()
			BPS = BPM / 60
			SPB = 1 / BPS
			MESSAGEMAN:Broadcast('Update')
		end,
		UpdateMessageCommand = function(self)
			if sudo.update then
				sudo.update(DT)
			end
			self:queuecommand('EndFrame')
		end,
		EndFrameCommand = function(self)
			self:sleep(DT)
			self:queuecommand('BeginFrame')
		end,
		ReadyCommand = function(self)
			if sudo.ready then
				sudo.ready()
			end
			self:queuecommand('Start')
		end,
		StartCommand = function(self)
			self:queuecommand('BeginFrame')
		end,
	},
	LoadModule('Konko.Node.lua')
}
