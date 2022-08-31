-- environment builder stolen this from xero thanks xero
if _G._su then return _G._su end
_G._su = {}
local _su = setmetatable(_su, _su)
_su.__index = _G
local function nop() end
function envcall(self, f, name)
	if type(f) == 'string' then
		-- if we call _sudo with a string, we need to load it as code
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
function _su:__call(f, name)
	return envcall(self, f, name)
end
function _su.using(ns)
	local env = getfenv(2)
	local newenv = setmetatable(env[ns] or {}, {
		__index = env,
	})
	env[ns] = env[ns] or {_scope = ns}
	return function(f)
		local ret = envcall(newenv, f)()
		for k, v in pairs(newenv) do
			if type(v) == 'table' and newenv._scope == ns then
				env[ns][k] = DeepCopy(v)
			else
				env[ns][k] = v
			end
		end
		return ret
	end
end
function _su.getfrom(ns, deep)
	local env = getfenv(2)
	local target = env[ns] or _su[ns]
	return function(t)
		if not target then
			_su.printerr('No table or environment "'..ns..'" found (Is table local?)')
		else
			for _, v in ipairs(t) do
				if not target[v] then
					_su.printerr('No variable "'..v..'" found (Is variable local?)')
				else
					if deep == true then
						env[v] = DeepCopy(target[v])
					else
						env[v] = target[v]
					end
				end
			end
		end
	end
end

_su.printerr = lua.ReportScriptError

function _su.switch(var)
	local env = getfenv(2)
	local ret = nop
	if not var then
		return _su.printerr('switch: given variable is nil')
	else
		return function(t)
			ret = t['_'] or ret
			for k, v in pairs(t) do
				if type(v) ~= 'function' then
					return _su.printerr('switch: expected case argument of type function, got '..type(v))
				elseif tostring(var) == k then
					ret = v or ret
				end
			end
			return ret()
		end
	end
end

_su()

-- Environment global variables, mostly shortcuts
SL, SR = SCREEN_LEFT, SCREEN_RIGHT
ST, SB = SCREEN_TOP, SCREEN_BOTTOM
SW, SH = SCREEN_WIDTH, SCREEN_HEIGHT -- screen width and height
SCX, SCY = SCREEN_CENTER_X, SCREEN_CENTER_Y -- screen center x and y

TIME = 0 -- overall elapsed time
OFFSET = 0 -- offset in seconds to first beat
BPM = 120 -- set this to 0 or less and ill eat u
DT = 0 -- seconds since last frame
	
if not _G.Tweens.instant then
	_G.Tweens.instant = function(x) return 1 end
end

KonkoAF = KonkoAF or function(t)
	local env = getfenv(2)
	local af = Def.ActorFrame(t)

	local init = af.InitCommand
	local on = af.OnCommand
	af.InitCommand = function(self)
		if init then init(self) end
		if env.init then
			env.init()
		end
		KonkoAF = self
	end
	af.OnCommand = function(self)
		if on then on(self) end
		self:luaeffect('Update')
	end

	af[#af + 1] = Def.ActorFrame {
		OnCommand = function(self)
			if env.ready then
				env.ready()
			end
			self:SetDrawFunction(env.draw)
		end,
		UpdateCommand = function(self)
			DT = self:GetEffectDelta()
			TIME = TIME + DT
			BPS = BPM / 60
			SPB = 1 / BPS
			if env.update then
				env.update(DT)
			end
		end,
		InputMessageCommand = function(self, event)
			if env.input then
				env.input(event)
			end
		end,
	}
	return af
end

return _su
