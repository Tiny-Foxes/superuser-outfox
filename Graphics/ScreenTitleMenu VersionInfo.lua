return Def.BitmapText {
	Font = 'Common Normal',
	Text = string.format("%s %s", ProductFamily(), ProductVersion()),
	InitCommand = function(self) self:zoom(1):diffuse(color('#FFFFFF')) end
}