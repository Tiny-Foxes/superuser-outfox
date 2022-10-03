-- mirin-syntax.lua --

--[[
	Available commands:
	- set {start, percent, mod, ...}
	- ease {start, length, ease, percent, mod, ...}
	- definemod {name, funtion, return}
	- setdefault {percent, mod, ...}
	
	Mirin documentation available at https://xerool.github.io/notitg-mirin
--]]

depend ('mirin-syntax', Mods, 'konko-mods')

mirin = {}

local function set(t)
	table.insert(t, 2, 0)
	table.insert(t, 3, Tweens.instant)
	local plr = t.plr or nil
	local offset = t.offset or nil
	t.plr = nil
	t.offset = nil
	if plr then
		if type(plr) ~= 'table' then plr = {plr} end
		for i = 1, #plr do
			Mods:Mirin(t, offset, plr[i])
		end
	else
		Mods:Mirin(t, offset)
	end
	return set
end

local function ease(t)
	local pn = (type(t.plr) ~= 'table' and t.plr) or nil
	local offset = t.offset or nil
	t.plr = nil
	t.offset = nil
	Mods:Mirin(t, offset, pn)
	return ease
end

local function definemod(t)
	local ret = {}
	for i = 3, #t do
		ret[#ret + 1] = t[i]
	end
	Mods:Define(t[1], t[2], ret)
	return definemod
end

local function setdefault(t)
	local t2 = {}
	for i = 1, #t, 2 do
		table.insert(t2, {t[i], t[i + 1]})
	end
	Mods:Default(t2)
	return setdefault
end

local function players(t)
	Mods.PlayerCount(t[1])
end

local function register(t)
	Mods.RegisterField(t[1], t[2])
end

mirin = {
	VERSION = '1.3',
	AUTHOR = 'Sudospective',
	set = set,
	ease = ease,
	definemod = definemod,
	setdefault = setdefault,
	players = players,
	register = register,
}
mirin.__index = mirin

print('Loaded Mirin Syntax v'..mirin.VERSION)
