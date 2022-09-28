return Def.ActorFrame {
	Def.Model {
		Meshes = '_mine model.txt',
		Materials = '_mine model.txt',
		Bones = '_mine model.txt',
		InitCommand = function(self)
			self:basezoom(1.25)
		end,
	},
}

