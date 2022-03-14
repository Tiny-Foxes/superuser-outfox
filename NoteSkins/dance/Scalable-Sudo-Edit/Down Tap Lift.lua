local t = Def.ActorFrame {
	Def.Model {
		Meshes = NOTESKIN:GetPath('_down','tap lift model'),
		Materials = NOTESKIN:GetPath('_down','tap lift model'),
		Bones = NOTESKIN:GetPath('_down','tap lift model'),
		InitCommand = function(self)
			self
				:pulse()
				:effectmagnitude(1, 0.75, 1)
				:effectclock('bgm')
				:effectperiod(1)
		end
	}
}

return t
