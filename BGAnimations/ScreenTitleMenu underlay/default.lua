collectgarbage()

local id = ProductID()

-- Check for OutFox. This theme will break if we aren't running on it.
-- (Older versions of OutFox might not be supported.) ~Sudo

-- TODO: Check for more SM instances to prepare for compatibility requests. ~Sudo
if not string.find(string.lower(id), 'outfox') then
	return LoadActor(THEME:GetPathB('ScreenTitleMenu', 'underlay/SM51.lua'))
else
	return LoadActor(THEME:GetPathB('ScreenTitleMenu', 'underlay/OutFox.lua'))
end
