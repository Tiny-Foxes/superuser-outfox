local t = Def.ActorFrame {
	Def.Model {
		Meshes=NOTESKIN:GetPath('_down','tap lift model');
		Materials=NOTESKIN:GetPath('_down','tap lift model');
		Bones=NOTESKIN:GetPath('_down','tap lift model');
		InitCommand=function(self)
			self:pulse();
			self:effectmagnitude(1, 0.75, 1);
			self:effectclock('bgm');
			self:effectperiod(1);
		end;
	};
};

return t;
