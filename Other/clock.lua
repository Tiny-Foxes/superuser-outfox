return Def.Actor {
	Name = 'UpdateClock',
	OnCommand = function(self)
		self:luaeffect('Update')
	end,
}