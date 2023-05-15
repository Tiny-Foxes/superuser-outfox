local scx, scy = SCREEN_CENTER_X, SCREEN_CENTER_Y
local sw, sh = SCREEN_WIDTH, SCREEN_HEIGHT
local scale = sh / 480

local ThemeColor = LoadModule('Theme.Colors.lua')

return Def.ActorFrame {
	-- Starfield
	Def.Sprite {
		Texture = THEME:GetPathG('ScreenWithMenuElements', 'nebula'),
		OnCommand = function(self)
			self
				:Center()
				:zoom((sh / 1080) * 1.1)
		end,
	},
	Def.ActorFrame {
		Name = 'Starfield',
		OnCommand = function(self)
			self
				:Center()
				:fov(105)
				:zoom(1.2)
				:fardistz(1000 * scale)
				:diffusealpha(0.5)
				:wag()
				:effectperiod(16)
				:effectmagnitude(0, 0, 0.1)
		end,
		Def.Sprite {
			Texture = THEME:GetPathG('ScreenWithMenuElements', 'starfield'),
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
			Texture = THEME:GetPathG('ScreenWithMenuElements', 'starfield'),
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
			Texture = THEME:GetPathG('ScreenWithMenuElements', 'starfield'),
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
			Texture = THEME:GetPathG('ScreenWithMenuElements', 'starfield'),
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
				:diffuse(ThemeColor.Primary)
				:diffusebottomedge(ThemeColor.Secondary)
				:diffusealpha(0.15)
		end,
		ThemeColorChangedMessageCommand = function(self, color)
			self
				:stoptweening()
				:linear(0.25)
				:diffuse(color.Primary)
				:diffusebottomedge(color.Secondary)
				:diffusealpha(0.15)
		end,
	},
	-- Dimmer
	Def.Quad {
		OnCommand = function(self)
			local a = LoadModule('Config.Load.lua')('SuperuserBGBrightness', 'Save/OutFoxPrefs.ini') or 1
			self
				:FullScreen()
				:diffuse(0, 0, 0, 1 - a)
		end,
		ThemeColorChangedMessageCommand = function(self)
			local a = LoadModule('Config.Load.lua')('SuperuserBGBrightness', 'Save/OutFoxPrefs.ini') or 1
			self
				:stoptweening()
				:linear(0.25)
				:diffuse(0, 0, 0, 1 - a)
		end,
	},
}
