return Def.ActorFrame {
	Def.Model {
		Meshes = '_down tap lift model',
		Materials = '_down tap lift model',
		Bones = '_down tap lift model',
		InitCommand = function(self)
			self
				:pulse()
				:effectmagnitude(1, 0.75, 1)
				:effectclock('bgm')
				:effectperiod(1)
		end,
	},
}
