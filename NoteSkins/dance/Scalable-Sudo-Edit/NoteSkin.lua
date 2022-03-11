-- SUDO'S NOTE
--[[
	I made a lot of edits to this noteskin to make it much more friendly to load, especially in OutFox.
	However, this noteskin should still be compatible with SM5.0+. I had the idea of anyone using 5.0.12,
	but it's compatible just for you weirdos.

	Most of the conversions were removing semicolons (all of them were used improperly) and removing the cmd
	function (using that at all causes problems with memory leaks iirc). If you don't understand why I did any
	of these changes, just talk to Squirrel in the OutFox server and he can explain it all to you.

	Doing these changes from the start is easy. It's converting them over that's the tedious part. Just do it
	right the first time. Here's a list of things to consider:

	1.	Semicolons are meant for writing a single line with multiple commands, and even then are unnecessary.
		In general, just don't use semicolons, it's completely unneeded and can even cause parsing errors in
		rare cases.
	2.	Using cmd for a list of actor functions is like using patroleum jelly for your sandwich. Sure, it looks
		like the same thing, but it's fucking awful and not fun for the person eating it. Change your cmd lines
		to actual functions. Anytime you see something like cmd(diffusealpha,0.1), this can be written like
		function(self) self:diffusealpha(0.1) end. It's longer to type, but this is what the engine is doing anyway.
	3.	You don't have to change everything to single quotes. I just plan on porting these to NotITG and it makes it
		easier when everything is single quotes because ANY double quotes at all WILL break the parsing. XML's great.
	4.	USW Noteskin.lua is very outdated, says the guy who made it himself. And I wouldn't hold my breath for an update
		any time soon. Just keep these things in mind if you plan on using anything from that era of asset creation.
		The future is now, old man.

	Hopefully this gives you some tips and a little insight when creating a noteskin. The rest just boils down to
	understanding how Lua works and how to use it effectively.
]]


--Unlimited Stepman Works Noteskin.lua for SM 5.0.12

--I am the bone of my noteskin
--Arrows are my body, and explosions are my blood
--I have created over a thousand noteskins
--Unknown to death
--Nor known to life
--Have withstood pain to create many noteskins
--Yet these hands will never hold anything
--So as I pray, Unlimited Stepman Works

local USWN = ... or {}

--Defining on which direction the other directions should be bassed on
--This will let us use less files which is quite handy to keep the noteskin directory nice
--Do remember this will Redirect all the files of that Direction to the Direction its pointed to
--If you only want some files to be redirected take a look at the 'custom hold/roll per direction'
USWN.ButtonRedir =
{
	Up = 'Down',
	Down = 'Down',
	Left = 'Down',
	Right = 'Down',
	UpLeft = 'Down',
	UpRight = 'Down',
}

-- Defined the parts to be rotated at which degree
USWN.Rotate =
{
	Up = 180,
	Down = 0,
	Left = 90,
	Right = -90,
	UpLeft = 135,
	UpRight = 225,
}


--Define elements that need to be redirected
USWN.ElementRedir =
{
	['Roll Explosion'] = 'Hold Explosion',
    ['Roll LiftTail Inactive'] = 'Hold LiftTail Inactive',
    ['Roll LiftTail Active'] = 'Hold LiftTail Active',
}

-- Parts of noteskins which we want to rotate
USWN.PartsToRotate =
{
	['Receptor'] = true,
	['Tap Explosion Dim W1'] = true,
	['Tap Explosion Dim W2'] = true,
	['Tap Explosion Dim W3'] = true,
	['Tap Explosion Dim W4'] = true,
	['Tap Explosion Dim W5'] = true,
	['Tap Note'] = true,
	['Tap Fake'] = true,
	['Tap Lift'] = true,
	['Tap Addition'] = true,
	['Hold Explosion'] = true,
	['Hold Head Active'] = true,
	['Hold Head Inactive'] = true,
	['Roll Explosion'] = true,
	['Roll Head Active'] = true,
	['Roll Head Inactive'] = true,
}

-- Parts that should be Redirected to _Blank.png
-- you can add/remove stuff if you want
USWN.Blank =
{
	['Hold Topcap Active'] = true,
	['Hold Topcap Inactive'] = true,
	['Roll Topcap Active'] = true,
	['Roll Topcap Inactive'] = true,
	['Hold Tail Active'] = true,
	['Hold Tail Inactive'] = true,
	['Roll Tail Active'] = true,
	['Roll Tail Inactive'] = true,
	['Tap Explosion Bright'] = true,
	['Tap Explosion Dim'] = true,
}

-- < 
--Between here we usally put all the commands the noteskin.lua needs to do, some are extern in other files
--If you need help with lua go to http://dguzek.github.io/Lua-For-SM5/API/Lua.xml there are a bunch of codes there
--Also check out common it has a load of lua codes in files there
--Just play a bit with lua its not that hard if you understand coding
--But SM can be an ass in some cases, and some codes jut wont work if you dont have the noteskin on FallbackNoteSkin=common in the metric.ini 
function USWN.Load()
	local sButton = Var 'Button'
	local sElement = Var 'Element'

	local Button = USWN.ButtonRedir[sButton] or sButton
			
	--Setting global element
	local Element = USWN.ElementRedir[sElement] or sElement

	if string.find(sElement, 'Head') then
		Element = 'Tap Note'
	end
	
	--Returning first part of the code, The redirects, Second part is for commands
	local t = LoadActor(NOTESKIN:GetPath(Button, Element))
	
	--Set blank redirects
	if USWN.Blank[sElement] then
		t = Def.Actor {}
		--Check if element is sprite only
		if Var 'SpriteOnly' then
			t = LoadActor(NOTESKIN:GetPath('', '_blank'))
		end
	end
	
	if USWN.PartsToRotate[sElement] then
		t.BaseRotationZ = USWN.Rotate[sButton] or nil
	end
	
	--Explosion should not be rotated, It calls other actors
	if sElement == 'Explosion' then
		t.BaseRotationZ = nil
	end
		
	return t
end
-- >

-- dont forget to return cuz else it wont work ;>
return USWN
