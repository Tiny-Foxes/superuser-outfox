-- default.lua --

--[[

    Woah! You're not supposed to be here! This is the backend!
    I suppose that since you're here, you wanna learn the
    * @ ~ . # - A D V A N C E D   S H I T - # . ~ @ *
    
    This is a very customizable but very experimental template,
	and bugs are to be expected, but the idea of this template
	is having extreme plug-and-play libraries and modability,
	while still having a base to work on or just use directly for
	quick and dirty modfile prototyping. If it looks hard to
	master the backend, that's because it IS hard to master the
	backend. There's a lot of things going on to ensure that
	everything I need is included, but everything YOU need can
	be included alongside or even instead of it. Using the template
	shouldn't be any more difficult than the standard stuff you'd
	expect in OutFox Lua, but if you need help with anything, feel
	more than free to send me a message on Discord. I'll be waiting
	in the OutFox server.

    Have your Lua manual handy, this is some hardcore C-style shit.

]]--

-- First off, let's take out the trash.
collectgarbage()

-- Now let's get our song directory real quick.
local dir = GAMESTATE:GetCurrentSong():GetSongDir()

-- This loads the absolutely necessary stuff for the template's environment to work properly.
local subo = assert(loadfile(dir .. 'main/env.lua'))()

-- We're going to use our subo table to call our subo environment that takes our subo table
-- and assigns it to our subo table in our subo environment, subo subo subo, subo subo,
-- subo subo subo subo.
subo.using 'subo' (function()
	subo = subo
	subo.VERSION = '4.0.0'
end)


-- This loads our mods.lua in its own environment, within the subo environment.
-- This means a global variable 'bup' assigned in mods.lua will ultimately be
-- assigned to subo.mods.bup.
-- After compiling it returns a function, which we call and return at the end of the file.
local modfile = subo(function()
	using 'mods' (function()
		function init() end
		function ready() end
		function update(dt) end
		function input(event) end
		function draw() end
		FG = Def.ActorFrame {
			Name = 'Mods',
			InitCommand = function(self)
				FG = self
				subo.Actors.Mods = self
			end
		}
		subo.Actors.Mods = FG
		table.insert(subo.Actors, FG)
		table.insert(FG, run 'lua/mods')
	end)

	-- This is our overarching ActorFrame which will hold everything on screen.
	return Def.ActorFrame {
		OnCommand = function(self)
			self:queuecommand('Ready')
		end,
		Def.Actor { InitCommand = function(self) self:sleep(9e9) end },
		Actors
	}
end)

-- Finally, run our compiled function to return our actors.
return modfile()

--[[

	The rest is a deep dive through the files of the template. I really encourage you to explore them.
	I've left a lot of helpful comments. Have fun.
	
	~ Sudo

    ---------------------------------------
    | Kitsu (n.): A clever canid creature |
    |   known for its cunning and speed.  |
    ---------------------------------------

--]]
