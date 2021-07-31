local scx, scy = SCREEN_CENTER_X, SCREEN_CENTER_Y
local sw, sh = SCREEN_WIDTH, SCREEN_HEIGHT
local scale = sh / 480

return Def.ActorFrame {
	-- Starfield
	Def.ActorFrame {
		Name = 'Starfield',
		OnCommand = function(self)
			self
				:Center()
				:fov(150)
				:fardistz(1000 * scale)
				:spin()
				:effectmagnitude(0, 0, 5)
		end,
		Def.Sprite {
			Texture = THEME:GetPathG('ScreenTitleMenu', 'starfield'),
			OnCommand = function(self)
				self
					:xy(-scx, 0)
					:z(-500)
					:zoomto(math.max(sw, sh), math.max(sw, sh))
					:rotationy(-60 * scale)
					:customtexturerect(0, 0, 1, 1)
					:texcoordvelocity(0.1, 0)
					:faderight(1)
			end
		},
		Def.Sprite {
			Texture = THEME:GetPathG('ScreenTitleMenu', 'starfield'),
			OnCommand = function(self)
				self
					:xy(scx, 0)
					:z(-500)
					:zoomto(math.max(sw, sh), math.max(sw, sh))
					:rotationy(60 * scale)
					:customtexturerect(0, 0, 1, 1)
					:texcoordvelocity(-0.1, 0)
					:fadeleft(1)
			end
		},
		Def.Sprite {
			Texture = THEME:GetPathG('ScreenTitleMenu', 'starfield'),
			OnCommand = function(self)
				self
					:xy(0, -scx)
					:z(-500)
					:zoomto(math.max(sw, sh), math.max(sw, sh))
					:rotationx(60 * scale)
					:customtexturerect(0, 0, 1, 1)
					:texcoordvelocity(0, 0.1)
					:fadebottom(1)
			end
		},
		Def.Sprite {
			Texture = THEME:GetPathG('ScreenTitleMenu', 'starfield'),
			OnCommand = function(self)
				self
					:xy(0, scx)
					:z(-500)
					:zoomto(math.max(sw, sh), math.max(sw, sh))
					:rotationx(-60 * scale)
					:customtexturerect(0, 0, 1, 1)
					:texcoordvelocity(0, -0.1)
					:fadetop(1)
			end
		},
	},
	-- Tint
	Def.Quad {
		OnCommand = function(self)
			self
				:FullScreen()
				:diffuse(color('#4F263D'))
				:diffusebottomedge(color('#5E2645'))
				:diffusealpha(0.25)
		end,
	}
}
