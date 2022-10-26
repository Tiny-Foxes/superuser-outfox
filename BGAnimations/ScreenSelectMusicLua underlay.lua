return Def.ActorFrame {
	OnCommand = function(self)
		SCREENMAN:GetTopScreen():GetMusicWheel():visible(false)
		self:AddChildFromPath(THEME:GetPathB('OFSelectMusic', 'underlay'))
		self:AddChildFromPath(THEME:GetPathB('OFSelectMusic', 'overlay'))
	end,
}
