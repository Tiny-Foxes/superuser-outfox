-- konko-mods.lua --

---------------------------
--	Mods:Insert(start, len, ease, modpairs, [offset], [plr]) - Writes mods to branch
--      start - Starting time
--      len - Length to full percentage
--      ease - Ease function
--      modpairs - {{end_p, mod, [begin_p]}, ...}
--          end_p - Ending percent
--          mod - Mod to activate (PascalCase uses player option functions)
--          begin_p - Beginning percent (optional)
--      offset - Offset between each mod in modpairs (optional)
--      plr - Player to apply mods (optional)
--	Mods:Define(name, func, return) - Defines a new mod from a function
--	Mods:FromFile(path) - Reads mods from a separate file
--	Mods:Mirin({start, len, ease, perc, mod, ...}, [offset], [plr]) - Writes mods to branch Mirin style
--	Mods:Exsch(start, len, begin_p, end_p, mod, timing, ease, [offset], [plr]) - Write mods to branch Exschwasion style
--	Mods:Default(modpairs) - Writes default mods to branch
---------------------------
depend ('konko-mods', std, 'stdlib')

Mods = {}
setmetatable(Mods, {})

-- Version and author
local VERSION = '1.5'
local AUTHOR = 'Sudospective'


local POptions = {}
local plrcount = 0
for i, v in ipairs( GAMESTATE:GetEnabledPlayers() ) do
    POptions[i] = GAMESTATE:GetPlayerState(v):GetPlayerOptions('ModsLevel_Song')
end

local modlist = {}
local mod_percents = {}
local note_percents = {}
local custom_mods = {}
local default_mods = {}
local active = {}

local function PlayerCount(num)
	plrcount = num
	for pn = 1, plrcount do
		mod_percents[pn] = {}
		note_percents[pn] = {}
		custom_mods[pn] = {}
		default_mods[pn] = {}
		active[pn] = {}
	end
end

PlayerCount(2)

--[[
local function ApplyMods(mod, percent, pn)
	if custom_mods[pn][mod] ~= nil then
		local new_perc = custom_mods[pn][mod].Function(percent, pn)
		local new_mod = custom_mods[pn][mod].Return
		percent = new_perc -- haha :TacMeme2:
		mod = new_mod
	end
    if mod then
		-- TODO: Fix mod ease calculations so percentage doesn't end up backwards
		local modstring = '*-1 '..(percent)..' '..mod:lower()
		if mod:sub(2):lower() == 'mod' then
			modstring = '*-1 '..percent..mod:sub(1, 1):lower()
		end
		if pn then
			POptions[pn]:FromString(modstring)
		else
			for p = 1, plrcount do
				POptions[p]:FromString(modstring)
			end
		end
	end
end
--]]
-- TODO: Make sure this doesn't run on unnecessary frames. ~Sudo
local function ApplyMods()
	for pn = 1, plrcount do
		local modstring = ''
		for mod, percent in pairs(mod_percents[pn]) do
			if custom_mods[pn][mod] ~= nil then
				local new_perc = {custom_mods[pn][mod].Function(percent, pn)}
				local new_mod = custom_mods[pn][mod].Return
				for i = 1, #new_perc do
					percent = new_perc[i]
					mod = new_mod[i]
					if POptions[pn][mod] then
						if mod:sub(2) == 'Mod' then
							POptions[pn][mod](POptions[pn], percent, 9e9)
						else
							POptions[pn][mod](POptions[pn], percent * 0.01, 9e9)
						end
					elseif mod:lower() == 'xmod' then
						modstring = modstring..'*-1 '..percent..mod:sub(1, 1):lower()..','
					elseif mod:sub(2):lower() == 'mod' then
						modstring = modstring..'*-1 '..mod:sub(1, 1):lower()..percent..','
					else
						modstring = modstring..'*-1 '..(percent)..' '..mod:lower()..','
					end
				end
			elseif mod then
				if POptions[pn][mod] then
					if mod:sub(2) == 'Mod' then
						POptions[pn][mod](POptions[pn], percent, 9e9)
					else
						POptions[pn][mod](POptions[pn], percent * 0.01, 9e9)
					end
				elseif mod:lower() == 'xmod' then
					modstring = modstring..'*-1 '..percent..mod:sub(1, 1):lower()..','
				elseif mod:sub(2):lower() == 'mod' then
					modstring = modstring..'*-1 '..mod:sub(1, 1):lower()..percent..','
				else
					modstring = modstring..'*-1 '..(percent)..' '..mod:lower()..','
				end
			end
		end
		if modstring ~= '' then POptions[pn]:FromString(modstring) end
	end
end

local function ApplyNotes(beat, col, mod, percent, pn)
	-- Code to turn on notemods once will go here once function is implemented engine side
	mod = mod:lower()
	if pn then
		std.PL[pn].Player:AddNoteMod(beat, col, mod, percent * 0.01)
	else
		for p = 1, plrcount do
			std.PL[p].Player:AddNoteMod(beat, col, mod, percent * 0.01)
		end
	end
end

local function UpdateMods()
    for i, m in ipairs(modlist) do
		for j, v in ipairs(m.Modifiers) do
			-- If the player where we're trying to access is not available, then don't even update.
			if m.Player and not POptions[m.Player] then break end
			local BEAT = std.BEAT
			local pn = m.Player
			if (BEAT >= m.Start and BEAT < (m.Start + m.Length)) then
				if m.Type == 'Player' then
					-- Ease blending is a work in progress. Try to make sure two eases don't use the same mod.
					v[3] = v[3] or mod_percents[pn][v[2]] or 0
					active[pn][v[2]] = active[pn][v[2]] or {}
					v[4] = v[4] or (#active[pn][v[2]] + 1)
					active[pn][v[2]][v[4]] = m
					local perc = 0
					for n = 1, v[4] do
						local offset = (n > v[4]) and 1 or 0
						local cur_m = active[pn][v[2]][n]
						local cur_v1 = cur_m.Modifiers[j][1]
						local cur_v3 = cur_m.Modifiers[j][3]
						local cur_ease = cur_m.Ease((BEAT - cur_m.Start) / cur_m.Length) - offset
						if m.Length == 0 then cur_ease = cur_m.Ease(1) - offset end
						local cur_perc = cur_ease * (cur_v1 - cur_v3)
						if #active[pn][v[2]] == n then
							perc = perc + (cur_v3 + cur_perc)
						end
					end
					mod_percents[pn][v[2]] = perc
				elseif m.Type == 'bup' then
					v[3] = v[3] or mod_percents[pn][v[2]] or default_mods[pn][v[2]] or 0
					local ease = m.Ease((BEAT - m.Start) / m.Length)
					if m.Length == 0 then ease = m.Ease(1) end
					local perc = ease * (v[1] - v[3])
					mod_percents[pn][v[2]] = perc + v[3]
				elseif m.Type == 'Note' then
					local notemod = v[4]..'|'..v[1]..'|'..v[2]
					v[5] = v[5] or note_percents[pn][notemod] or default_mods[pn][notemod] or 0
					active[pn][notemod] = active[pn][notemod] or {}
					v[6] = v[6] or (#active[pn][notemod] + 1)
					active[pn][notemod][v[6]] = m
					local perc = 0
					for n = 1, v[6] do
						local offset = (n > v[6]) and 1 or 0
						local cur_m = active[pn][notemod][n]
						local cur_v3 = cur_m.Modifiers[j][3]
						local cur_v5 = cur_m.Modifiers[j][5]
						local cur_ease = cur_m.Ease((BEAT - cur_m.Start) / cur_m.Length) - offset
						if m.Length == 0 then cur_ease = 1 end
						local cur_perc = cur_ease * (cur_v3 - cur_v5)
						if #active[pn][notemod] == n then
							perc = perc + (cur_v5 + cur_perc)
						end
					end
					note_percents[pn][notemod] = perc
				end
			elseif BEAT >= (m.Start + m.Length) then
				if m.Type == 'Player' then
					v[3] = v[3] or mod_percents[pn][v[2]] or 0
					mod_percents[pn][v[2]] = m.Ease(1) * (v[1] - v[3]) + v[3]
					if v[4] and active[pn][v[2]] then
						active[pn][v[2]][v[4]] = nil
					end
				elseif m.Type == 'Note' then
					v[5] = v[5] or note_percents[pn][notemod] or 0
					local notemod = v[4]..'|'..v[1]..'|'..v[2]
					note_percents[pn][notemod] = m.Ease(1) * (v[3] - v[5]) + v[5]
					if v[6] and active[pn][notemod] then
						active[pn][notemod][v[6]] = nil
					end
				end
				if j == #m.Modifiers then
					m.Modifiers = {}
				end
			end
		end
    end
end

FG[#FG + 1] = Def.Actor {
	ReadyCommand = function(self)
		for pn = 1, plrcount do
			POptions[pn]:FromString('*-1 clearall')
		end
	end,
	UpdateCommand = function(self)
		UpdateMods()
		ApplyMods()
	end
}

local function RegisterField(notefield, pn)
	POptions[pn] = notefield:GetPlayerOptions('ModsLevel_Current')
end

-- Load a mod file.
local function FromFile(self, scriptpath)
	--printerr('Mods:LoadFromFile')
	run('lua/'..scriptpath)
	return self
end
-- Write default mods.
local function Default(self, modtable)
	--printerr('Mods:Default')
	for pn = 1, plrcount do
		for i = 1, #modtable do
			table.insert(default_mods[pn], modtable[i])
		end
	end
	local res = self:Insert(std.START, 0, function(x) return 1 end, modtable)
	return res
end
-- Define a new mod.
local function Define(self, name, func, ret)
	--printerr('Mods:Define')
	local t = {}
	if type(ret) ~= 'table' then ret = {ret} end
	t = {
		Function = func,
		Return = ret
	}
	for pn = 1, plrcount do
		custom_mods[pn][name] = t
	end
	return self
end
-- Insert a mod.
local function Insert(self, start, len, ease, modtable, offset, pn)
    --printerr('Mods:Insert')
	local t1, t = {}, {}
	for p = 2, plrcount do
		t[p] = {}
	end
    if not offset or offset == 0 then
		t1 = {
			Start = start,
			Length = len,
			Ease = ease,
			Modifiers = modtable,
			Type = 'Player',
			Player = pn or 1
		}
		table.insert(modlist, t1)
		if not pn then
			for p = 2, plrcount do
				t[p] = {
					Start = start,
					Length = len,
					Ease = ease,
					Modifiers = modtable,
					Type = 'Player',
					Player = p
				}
				table.insert(modlist, t[p])
			end
		end
    else
        for i, v in ipairs(modtable) do
            t1[i] = {
                Start = start + (offset * (i - 1)),
                Length = len,
                Ease = ease,
                Modifiers = {v},
				Type = 'Player',
                Player = pn or 1
            }
            table.insert(modlist, t1[i])
			if not pn then
				for p = 2, plrcount do
					t[p][i] = {
						Start = start + (offset * (i - 1)),
						Length = len,
						Ease = ease,
						Modifiers = {v},
						Type = 'Player',
						Player = p
					}
					table.insert(modlist, t[p][i])
				end
			end
        end
    end
    return self
end
-- We can't actually add notemods until they stop corrupting the stack.
local function Note(self, start, len, ease, notemodtable, offset, pn)
	--printerr(Mods:Note)
	local t1, t = {}, {}
	for p = 2, plrcount do
		t[p] = {}
	end
	if not offset or offset == 0 then
		t1 = {
			Start = start,
			Length = len,
			Ease = ease,
			Modifiers = notemodtable,
			Type = 'Note',
			Player = pn or 1
		}
		table.insert(modlist, t1)
		if not pn then
			for p = 2, plrcount do
				t[p] = {
					Start = start,
					Length = len,
					Ease = ease,
					Modifiers = notemodtable,
					Type = 'Note',
					Player = p
				}
				table.insert(modlist, t[p])
			end
		end
	else
		for i, v in ipairs(notemodtable) do
			t1[i] = {
				Start = start + (offset * (i - 1)),
				Length = len,
				Ease = ease,
				Modifiers = {v},
				Type = 'Note',
				Player = pn or 1
			}
			table.insert(modlist, t1[i])
			if not pn then
				for p = 2, plrcount do
					t[p][i] = {
						Start = start + (offset * (i - 1)),
						Length = len,
						Ease = ease,
						Modifiers = {v},
						Type = 'Note',
						Player = p
					}
					table.insert(modlist, t[p][i])
				end
			end
		end
	end
	return self
end
-- Insert a mod but you like extra wasabi
local function Exsch(self, start, len, str1, str2, mod, timing, ease, pn)
    --printerr('Mods:Exsch')
    if timing == 'end' then
        len = len - start
    end
    local res = self:Insert(start, len, ease, {{str2, mod, str1}}, 0, pn)
    return res
end
-- so-called "free thinkers" when mirin template
local function Mirin(self, t, offset, pn)
    --printerr('Mods:Mirin')
    local tmods = {}
    for i = 4, #t, 2 do
        if t[i] and t[i + 1] then
            tmods[#tmods + 1] = {t[i], t[i + 1]}
        end
    end
    local res = self:Insert(t[1], t[2], t[3], tmods, offset, pn)
    return res
end

Mods = {
	VERSION = VERSION,
	AUTHOR = AUTHOR,
	PlayerCount = PlayerCount,
	RegisterField = RegisterField,
	FromFile = FromFile,
	Define = Define,
	Insert = Insert,
	--Note = Note,
	Mirin = Mirin,
	Exsch = Exsch,
	Default = Default,
}
Mods.__index = Mods


print('Loaded Konko Mods v'..Mods.VERSION)
