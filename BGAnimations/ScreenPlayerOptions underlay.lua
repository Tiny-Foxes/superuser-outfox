return Def.ActorFrame {
	OnCommand = function(self)
		self:AddChildFromPath(THEME:GetPathG('Players', 'preview'))
	end
}
