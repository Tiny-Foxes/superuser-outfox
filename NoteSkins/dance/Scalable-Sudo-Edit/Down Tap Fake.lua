return Def.ActorFrame {
	Def.Model {
		Meshes = '_down tap note model',
		Materials = '_down tap note model',
		Bones = '_down tap note model',
		InitCommand = function(self)
			self:diffuse(0.5, 0.5, 0.5, 1)
		end,
	},
}
