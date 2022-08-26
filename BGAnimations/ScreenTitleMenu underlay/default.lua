collectgarbage()

local id = ProductID()

-- Check for OutFox. This theme will break if we aren't running on it.
-- (Older versions of OutFox returned the Product ID as 'StepMania 5.3'.)

-- TODO: Check for more SM instances to prepare for compatibility requests.
if string.find(id, 'StepMania') and not string.find(id, '5.3') then
	return LoadActor(THEME:GetPathB('ScreenTitleMenu', 'underlay/SM51.lua'))
else
	return LoadActor(THEME:GetPathB('ScreenTitleMenu', 'underlay/OutFox.lua'))
end
