-- env.lua --

-- This is where we build our environment. This environment is vital to the template's
-- Function, and if removed, will render it inoperable.

-- Big thanks to XeroOl for this code, it came from his Mirin template.


-- First, let's define a global variable for our environment. We feel powerful, in our own
-- castle of logical wizardry. Elevated and even privileged. Let's call it 'sudo'.
-- For no particular reason at all.
local sudo = {}

-- Let's do a really weird thing that's scary to think about. Don't do this in real life.
sudo = setmetatable(sudo, sudo)

-- We want our environment to have all of the stuff that _G has, which is everything, including
-- our environment, which will contain _G, the very one that contains our environment. This is
-- the recursion you should never think about and just accept as a natural law.
sudo.__index = _G

-- We want to be lazy and have sudo() as a shorthand for setting our environment, but we also
-- want to be thorough and have a shorthand for setting an environment for a specific function.
-- This is the function for exactly that. It will do everything for us. You ready?
-- nop
local function nop() end

-- nah just kidding here it is
local function envcall(self, f, name)
	if type(f) == 'string' then
		-- If we call sudo with a string, we need to load it as code.
		local err
		-- Try compiling the code.
		f, err = loadstring( 'return function(self)' .. f .. '\nend', name)
		-- If we error, tell us what we got and return nop.
		if err then SCREENMAN:SystemMessage(err) return nop end
		-- If we compile, grab the function.
		f, err = pcall(f)
		-- Again, give an error and return nop if we error.
		if err then SCREENMAN:SystemMessage(err) return nop end
	end
	-- Set our environment and return our function.
	setfenv(f or 2, self)
	return f
end

-- And this ties it to our call function (i.e., sudo())
function sudo:__call(f, name)
	return envcall(self, f, name)
end

-- It's dangerous to go alone; take this!
local dir = GAMESTATE:GetCurrentSong():GetSongDir()

-- Debug and Error prints
function sudo.print(s, ret)
	if s and type(s) == 'table' then
		print('KITSU: Printing '..tostring(s))
		PrintTable(s)
	else
		print('KITSU: '..tostring(s))
	end
	return ret or nil
end
function sudo.printerr(s, ret) lua.ReportScriptError('KITSU: '..tostring(s)) return ret end

-- Library importer
function sudo.import(lib)
	local env = getfenv(2)
	-- Catch in case we add .lua to our path.
	if lib:find('%.lua') then lib = lib:sub(1, lib:find('%.lua') - 1) end
	-- Make sure the file is there
	local file = dir..'lib/'..lib..'.lua'
	if not assert(loadfile(file)) then
		sudo.printerr('Unable to import library "'..lib..'": No file found.')
		return
	end
	-- Return our file in our environment
	return envcall(env, loadfile(file))()
end

-- Lua runner
function sudo.run(path)
	local env = getfenv(2)
	-- Catch in case we add .lua to our path.
	if path:find('%.lua') then path = path:sub(1, path:find('%.lua') - 1) end
	-- Make sure the file is there
	local file = dir..path..'.lua'
	if not assert(loadfile(file)) then
		sudo.printerr('Unable to run file "'..path..'": No file found.')
		return
	end
	-- Return our file in our environment
	return envcall(env, loadfile(file))()
end

function sudo.depend(lib, dependency, name)
	-- If we don't have it, try to load it.
	if dependency == nil and type(name) == 'string' then
		local env = getfenv(2)
		envcall(env, sudo.import(name))
	end
	-- If we still don't have it, throw an error.
	if dependency == nil then
		sudo.printerr('Error importing library "'..lib..'": Unable to load '..name..' dependency')
	end
end


-- Special thanks to Chegg for helping me help him help me get this working
function sudo.using(ns)
	local env = getfenv(2)
	local newenv = setmetatable(env[ns] or {}, {
		__index = env,
	})
	newenv._scope = ns
	env[ns] = env[ns] or {}
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

function sudo.getfrom(ns, deep)
	local env = getfenv(2)
	local target = env[ns] or sudo[ns]
	return function(t)
		if not target then
			sudo.printerr('No table or environment "'..ns..'" found (Is table local?)')
		else
			for _, v in ipairs(t) do
				if not target[v] then
					sudo.printerr('No variable "'..v..'" found (Is variable local?)')
				else
					if deep and type(target[v]) == 'table' then
						env[v] = DeepCopy(target[v])
					else
						env[v] = target[v]
					end
				end
			end
		end
	end
end

function sudo.switch(var)
	local env = getfenv(2)
	local ret = nop
	if not var then
		return sudo.printerr('switch: given variable is nil')
	else
		return function(t)
			ret = t['_'] or ret
			for k, v in pairs(t) do
				if type(v) ~= 'function' then
					return sudo.printerr('switch: expected case argument of type function, got '..type(v))
				elseif tostring(var) == k then
					ret = v or ret
				end
			end
			return ret()
		end
	end
end

-- TODO: Have an 'extern' function that will grab a variable from parent file. ~Sudo

sudo.Actors = Def.ActorFrame {
    InitCommand = function(self)
		sudo.FG = self
    end,
	ReadyCommand = function(self)
		self:luaeffect('Update')
	end,
}

return sudo
