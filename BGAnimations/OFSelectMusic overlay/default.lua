if GAMESTATE:IsCourseMode() then TF_WHEEL.PreferredSort = 'Group' end
local wheel = 'superuser'
return Def.ActorFrame {
	OnCommand = function(self)
		self:queuecommand('RandomSubText')
	end,
	RandomSubTextCommand = function(self)
		self:GetChildAt(2):GetChild('SubText'):settext(TF_WHEEL.RandomSubText())
	end,
	LoadActor(THEME:GetPathB('OFSelectMusic', 'overlay/'..wheel)),
	LoadActor(THEME:GetPathG('', 'screenheader.lua')),
}
