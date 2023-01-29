local dir = THEME:GetCurrentThemeDirectory()..'Graphics/ScreenTitleMenu mascot/'
local mascots = {
	Choices = FILEMAN:GetDirListing(dir, false, false),
	Values = FILEMAN:GetDirListing(dir, false, true),
}

for _, v in ipairs(mascots.Choices) do
	v:gsub('%.(.+)', '')
end

return mascots
