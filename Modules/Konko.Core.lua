-- environment builder stolen this from xero thanks xero
_G.su = {}
local su = setmetatable(su, su)
su.__index = _G
local function nop() end
function envcall(self, f, name)
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
function su:__call(f, name)
	return envcall(self, f, name)
end
function su.using(ns)
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
function su.getfrom(ns, deep)
	local env = getfenv(2)
	local target = env[ns] or su[ns]
	return function(t)
		if not target then
			su.printerr('No table or environment "'..ns..'" found (Is table local?)')
		else
			for _, v in ipairs(t) do
				if not target[v] then
					su.printerr('No variable "'..v..'" found (Is variable local?)')
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

su.printerr = lua.ReportScriptError

function su.switch(var)
	local env = getfenv(2)
	local ret = nop
	if not var then
		return su.printerr('switch: given variable is nil')
	else
		return function(t)
			ret = t['_'] or ret
			for k, v in pairs(t) do
				if type(v) ~= 'function' then
					return su.printerr('switch: expected case argument of type function, got '..type(v))
				elseif tostring(var) == k then
					ret = v or ret
				end
			end
			return ret()
		end
	end
end

su()

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

Def.KonkoAF = Def.KonkoAF or function(t)
	local env = getfenv(2)
	local af = Def.ActorFrame(t)

	local init = af.InitCommand
	local on = af.OnCommand
	af.InitCommand = function(self)
		if init then init(self) end
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
	}
	return af
end

return su
