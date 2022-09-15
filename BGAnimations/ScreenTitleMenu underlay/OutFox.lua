-- Load Konko core module and initialize environment
local konko = LoadModule('Konko.Core.lua')
konko()
if not SetMeFree then SetMeFree = false end

-- Load SuperActor module
local SuperActor = LoadModule('Konko.SuperActor.lua')

-- Define local variables and functions
local scale = SH /480
local splash = false

local ThemeColor = LoadModule('Theme.Colors.lua')
local taglines = LoadModule('Theme.Taglines.lua')

local function initAFT(self, recursive)
	recursive = recursive or false
	self
		:SetSize(SW, SH)
		:EnableFloat(false)
		:EnableDepthBuffer(true)
		:EnableAlphaBuffer(not recursive)
		:EnablePreserveTexture(recursive)
		:Create()
end
local function mapAFT(aft, sprite)
	sprite:Center():SetTexture(aft:GetTexture())
end
local function blurAFT(self, scale)
	scale = scale or 2
	self:SetSize(SW / scale, SH / scale)
end
local function blurSprite(self, scale)
	self:Center():basezoom(scale)
end

-- Define SuperActors

-- Title ActorFrameTexture
local titleAFT = SuperActor.new('ActorFrameTexture')
-- Title AFT Background
local bg = LoadActor(THEME:GetPathB('ScreenWithMenuElements', 'background'))
-- Title AFT BG Dimmer
local bgDim = SuperActor.new('Quad')
-- Title AFT Sprite
local titleSprite = SuperActor.new('Sprite')
-- Mascot ActorFrame
local mascotAF = SuperActor.new('ActorFrame')
-- The mascot herself
local mascot = SuperActor.new('Sprite')

-- Recursive Title AFT
local titleAFTR = SuperActor.new('ActorFrameTexture')
-- Recursive Title AFT Sprite
local titleSpriteR = SuperActor.new('Sprite')

-- UI Wrapper
local uiWrap = SuperActor.new('ActorFrame')
-- UI ActorFrame
local uiAF = SuperActor.new('ActorFrame')
-- UI Shadow
local uiShadow = SuperActor.new('Quad')
-- UI Panel
local uiPanel = SuperActor.new('Quad')
-- UI Text AF
local uiText = SuperActor.new('ActorFrame')
-- UI 'Powered By' Credit
local uiPoweredBy = SuperActor.new('BitmapText')
-- UI Theme Title
local uiTitle = SuperActor.new('Sprite')
-- UI Tagline
local uiTagline = SuperActor.new('BitmapText')
-- UI Creator Text
local uiAuthor = SuperActor.new('BitmapText')
-- UI Theme Version
local uiVersion = SuperActor.new('BitmapText')
-- UI Social Text
local uiSocial = SuperActor.new('BitmapText')

-- ShowTitle Sprite
local showTitle = SuperActor.new('Sprite')


-- Set Actor attributes and commands
-- I use `do` here to make everything collapsable. ~Sudo

-- TitleAFT
do titleAFT
	:SetCommand('Init', function(self)
		initAFT(self, false)
	end)
end
-- TitleAFT.BGDimmer
-- (Which means you can call SuperActor.GetTree().TitleAFT.BGDimmer to get this Actor :3c)
do bgDim
	:SetCommand('Init', function(self)
		self:FullScreen():diffuse(color('#00000000'))
	end)
	:SetCommand('On', function(self)
		self:easeoutexpo(0.5):diffusealpha(0.5)
	end)
	:SetCommand('Off', function(self)
		self:linear(0.5):diffusealpha(0)
	end)
end
-- TitleAFT.Sprite
do titleSprite
	:SetCommand('On', function(self)
		mapAFT(SuperActor.GetTree().TitleAFTR, self)
		self
			:blend('BlendMode_Add')
			:diffusealpha(0)
			:easeoutexpo(0.5)
			:diffusealpha(0.75)
			:zoom(1.005)
			:queuecommand('Breathe')
	end)
	:SetCommand('Breathe', function(self)
		self
			:easeinoutsine(3.5)
			:zoom(1.01)
			:easeinoutsine(3.5)
			:zoom(1.005)
			:queuecommand('Breathe')
	end)
	:SetCommand('Off', function(self)
		self
			:stoptweening(0)
			:linear(0.5)
			:diffusealpha(0)
			:zoom(1)
	end)
end

-- MascotFrame
do mascotAF
	:SetCommand('Init', function(self)
		self:Center():diffusealpha(0):visible(not SetMeFree)
	end)
	:SetCommand('On', function(self)
		self:linear(0.5):diffusealpha(1)
	end)
	:SetCommand('Off', function(self)
		self:linear(0.5):diffusealpha(0)
	end)
end
-- MascotFrame.Mascot
do mascot
	-- NOTE: Maybe random mascots here? ~Sudo
	:SetAttribute('Texture', THEME:GetPathG('ScreenTitleMenu', 'mascot'))
	:SetCommand('Init', function(self)
		self
			:zoom(1.2)
			:xy(-180, 320)
			:bob()
			:effectmagnitude(0, 4, 0)
			:effectperiod(4)
			:visible(splash or LoadModule('Config.Load.lua')('ShowMascotCharacter', 'Save/OutFoxPrefs.ini'))
	end)
	:SetCommand('On', function(self)
		self:easeoutexpo(0.5):addx(20)
	end)
	:SetCommand('Off', function(self)
		self:easeinexpo(0.5):addx(-20)
	end)
end

-- TitleAFTR
do titleAFTR
	:SetCommand('Init', initAFT)
end
-- TitleAFTR.Sprite
do titleSpriteR
	:SetCommand('On', function(self)
		mapAFT(SuperActor.GetTree().TitleAFT, self)
	end)
end

do showTitle
	:SetCommand('On', function(self)
		mapAFT(SuperActor.GetTree().TitleAFT, self)
	end)
end

-- UIWrap
do uiWrap
	:SetAttribute('FOV', 90)
	:SetCommand('Init', function(self)
		self:Center():fardistz(9e9)
	end)
	:SetCommand('On', function(self)
		local start, switched = Second(), false
		self:SetUpdateFunction(function(self)
			if not switched and (Second() - start + 1) % 5 == 0 then
				switched = true
				self:queuecommand('RandomAngle')
			end
		end)
	end)
	:SetMessage('DropBeats', function(self)
		self
			:stoptweening()
			:zoomz(1.5)
			:easeoutquint(0.77)
			:zoomz(1)
			:sleep(0.77)
			:zoomz(3)
			:easeoutquint(0.385)
			:zoomz(1)
			:easeinquint(0.385)
			:zoomz(3)
	end)
end
-- UIWrap.UI
do uiAF
	:SetAttribute('FOV', 90)
	:SetCommand('Init', function(self)
		self:y(SCY - 192)
	end)
	:SetCommand('On', function(self)
		-- Discord RCP support from Yosefu
		GAMESTATE:UpdateDiscordScreenInfo('In Title Menu', '', 1)
	end)
end
-- UIWrap.UI.Shadow
do uiShadow
	:SetCommand('Init', function(self)
		self
			:skewx(-0.5)
			:SetSize(SW * 1.5, 264)
			:diffuse(ThemeColor.Black)
			:diffusealpha(0.75)
			:fadetop(0.01)
			:fadebottom(0.01)
			:cropleft(1)
	end)
	:SetCommand('On', function(self)
		self:easeoutexpo(0.5):cropleft(0)
	end)
	:SetCommand('Off', function(self)
		self:sleep(0.5):easeoutexpo(0.5):cropleft(1)
	end)
end
-- UIWrap.UI.Shadow.Panel
do uiPanel
	:SetCommand('Init', function(self)
		self
			:skewx(-0.5)
			:SetSize(SW * 1.5, 256)
			:diffuse(ThemeColor.Elements)
			:diffusebottomedge(ThemeColor.Secondary)
			:diffuserightedge(ThemeColor.Elements)
			:diffusealpha(0.5)
			:cropleft(1)
	end)
	:SetCommand('On', function(self)
		self:easeoutexpo(0.5):cropleft(0)
	end)
	:SetCommand('Off', function(self)
		self:sleep(0.5):easeoutexpo(0.5):cropleft(1)
	end)
end
-- UIWrap.UI.Text
do uiText
	:SetAttribute('FOV', 90)
	:SetCommand('Init', function(self)
		self:xy(20, -10):vanishpoint(SCX - 200, SCY - 182)
	end)
end
-- UIWrap.UI.Text.PoweredBy
do uiPoweredBy
	:SetAttribute('Font', '_xide/20px')
	:SetAttribute('Text', 'Project\nOutFox')
	:SetCommand('Init', function(self)
		self
			:xy(-370, -32)
			:halign(1)
			:shadowlength(4)
			:diffuse(ThemeColor.Yellow)
			:diffusebottomedge(ThemeColor.Orange)
			:cropright(1)
	end)
	:SetCommand('On', function(self)
		self
			:sleep(0.2)
			:linear(0.05)
			:cropright(0)
	end)
	:SetCommand('Off', function(self)
		self
			:sleep(0.35)
			:linear(0.1)
			:cropright(1)
	end)
end

local uiTitleBack = SuperActor.new('Model')
do uiTitleBack
	--:SetAttribute('Texture', THEME:GetPathG('ScreenTitleMenu', 'supertext'))
	:SetAttribute('Materials', THEME:GetPathG('ScreenTitleMenu', 'logo'))
	:SetAttribute('Meshes', THEME:GetPathG('ScreenTitleMenu', 'logo'))
	:SetAttribute('Bones', THEME:GetPathG('ScreenTitleMenu', 'logo'))
	:SetCommand('Init', function(self)
		self
			:rotationx(-360)
			:basezoomz(0.5)
			:CelShading(true)
			:visible(SetMeFree)
			:bob()
			:effectmagnitude(0, -5, 0)
			:effectperiod(20)
	end)
	:SetCommand('On', function(self)
		self
			:zoom(5)
			:y(0)
			:z(1000)
			:easeoutquint(0.77)
			:zoom(0.75)
			:y(-30)
			:z(200)
			:rotationx(-15)
	end)
	:SetCommand('RandomAngle', function(self)
		self
			:stoptweening()
			:zoom(0.75 + math.random() * 0.5)
			:x(-SW * 0.3 + math.random() * SW * 0.6)
			:y(-SH * 0.1 + math.random() * SH * 0.15)
			:rotationx(-30 + math.random() * 60)
			:rotationy(-30 + math.random() * 60)
			:rotationz(-10 + math.random() * 20)
			:linear(4)
			:addrotationy((self:GetRotationY() / math.abs(self:GetRotationY())) * -25)
			:addrotationz((self:GetRotationZ() / math.abs(self:GetRotationZ())) * -5)
			:queuecommand('RandomAngle')
	end)
	:SetCommand('Off', function(self)
		self
			:stoptweening()
			:linear(0.5)
			:diffusealpha(0)
	end)
end

-- UIWrap.UI.Text.Title
do uiTitle
	:SetAttribute('Texture', THEME:GetPathG('ScreenTitleMenu', 'supertext'))
	:SetCommand('Init', function(self)
		self
			:xy(-220, 28)
			:zoom(0.45)
			:shadowlengthy(4)
			:cropright(1)
			:rotationx(SetMeFree and -60 or 0)
	end)
	:SetCommand('On', function(self)
		self
			:sleep(0.25)
			:linear(0.1)
			:cropright(0)
	end)
	:SetCommand('Off', function(self)
		self
			:sleep(0.15)
			:linear(0.2)
			:cropright(1)
	end)
end
-- UIWrap.UI.Text.Tagline
do uiTagline
	:SetAttribute('Font', 'Common Normal')
	:SetCommand('Init', function(self)
		self
			:playcommand('SetTagline')
			:zoom(0.75)
			:xy(-480, 64)
			:halign(0)
			:valign(0)
			:cropright(1)
	end)
	:SetCommand('On', function(self)
		self
			:sleep(0.5)
			:linear(0.1)
			:cropright(0)
	end)
	:SetCommand('Off', function(self)
		self
			:sleep(0.05)
			:linear(0.1)
			:cropright(1)
	end)
	:SetCommand('SetTagline', function(self)
		if SetMeFree then
			self:settext('"Set Me Free."')
			return
		end
		-- I'm working on translating these titles, but getting some translators
		-- is pretty much essential at this point.
		-- Taglines default to English if there aren't any for that language.
		local langtags = taglines[THEME:GetCurLanguage()]
		if not langtags then langtags = taglines.en end
		local rng = math.ceil(OFMath.randomfloat() * #langtags)
		self:settext('"'..langtags[rng]..'"')
		if splash then self:settext('Hello, World.') end
	end)
end
-- UIWrap.UI.Text.Author
do uiAuthor
	:SetAttribute('Font', 'Common Normal')
	:SetAttribute('Text', 'Theme by Sudospective')
	:SetCommand('Init', function(self)
		self
			:zoom(0.5)
			:xy(40, 0)
			:halign(1)
			:valign(1)
			:cropright(1)
		if not splash and LoadModule('Config.Load.lua')('ShowMascotCharacter', 'Save/OutFoxPrefs.ini') then
			self:settext('Theme by Sudospective\nArt by PrincessRaevinFlash')
		end
	end)
	:SetCommand('On', function(self)
		self
			:sleep(0.3)
			:linear(0.05)
			:cropright(0)
	end)
	:SetCommand('Off', function(self)
		self
			:linear(0.1)
			:cropright(1)
	end)
end
-- UIWrap.UI.Text.Version
do uiVersion
	:SetAttribute('Font', 'Common Normal')
	:SetAttribute('Text', 'v'..THEME:GetMetric('Common', 'ThemeVersion'))
	:SetCommand('Init', function(self)
		self
			:zoom(0.75)
			:xy(40, 64)
			:halign(1)
			:valign(0)
			:cropright(1)
	end)
	:SetCommand('On', function(self)
		self
			:sleep(0.4)
			:linear(0.05)
			:cropright(0)
	end)
	:SetCommand('Off', function(self)
		self
			:sleep(0.15)
			:linear(0.05)
			:cropright(1)
	end)
end
-- UIWrap.UI.Text.Social
do uiSocial
	:SetAttribute('Font', 'Common Normal')
	:SetAttribute('Text', 'Art by PrincessRaevinFlash\nsudospective.net / @sudospective\nprojectoutfox.com / @projectoutfox')
	:SetCommand('Init', function(self)
		self
			:zoom(0.5)
			:xy(420, 76)
			:halign(1)
			:valign(1)
			:visible(false)
		if splash then self:visible(true) end
	end)
	:SetCommand('On', function(self)
		self
			:linear(0.4)
			:cropright(0)
	end)
	:SetCommand('Off', function(self)
		self
			:linear(0.4)
			:cropright(1)
	end)
end

-- Add Actors in their respective nesting and order
-- Not sure if this supports negative ints, but it
-- DOES support nil ints (insert at last position).
do mascotAF
	:AddChild(mascot, 'Mascot')
end
do titleAFT
	:AddChild(bg, 'BG')
	:AddChild(bgDim, 'BGDimmer')
	:AddChild(titleSprite, 'Sprite')
	:AddChild(mascotAF, 'MascotFrame')
	:AddToTree('TitleAFT')
end
do titleAFTR
	:AddChild(titleSpriteR, 'Sprite')
	:AddToTree('TitleAFTR')
end
do showTitle
	:AddToTree('ShowTitle')
end
do uiText
	:AddChild(uiPoweredBy, 'PoweredBy')
	:AddChild(uiTitle, 'Title')
	:AddChild(uiTagline, 'Tagline')
	:AddChild(uiAuthor, 'Author')
	:AddChild(uiVersion, 'Version')
	:AddChild(uiSocial, 'Social')
	:AddChild(SuperActor.new('Sprite')
		:SetAttribute('Texture', THEME:GetPathG('', 'karen'))
		:SetCommand('Init', function(self)
			self
				:xy(-60, 70)
				:zoom(0.05)
				:rotationz(-10)
				:bob()
				:effectmagnitude(0, 4, 0)
				:effectperiod(8)
				:visible(SetMeFree)
				:diffusealpha(0)
		end)
		:SetCommand('On', function(self)
			self
				:diffusealpha(0)
				:sleep(0.25)
				:linear(0.5)
				:diffusealpha(1)
		end)
		:SetCommand('Off', function(self)
			self
				:diffusealpha(1)
				:linear(0.5)
				:diffusealpha(0)
		end)
	)
end
do uiAF
	:AddChild(uiShadow, 'Shadow')
	:AddChild(uiPanel, 'Panel')
	:AddChild(uiText, 'Text')
end
do uiWrap
	:AddChild(uiTitleBack, 'TitleBack')
	:AddChild(uiAF, 'UI')
	:AddToTree('UIWrap')
end
--[[
	Current tree structure:

	- TitleAFT
	  - BG
	  - BGDimmer
	  - Sprite
	  - MascotFrame
	    - Mascot
	- TitleAFTR
	  - Sprite
	- ShowTitle
	- UIWrap
	  - UI
	    - Shadow
	    - Panel
	    - Text
	      - PoweredBy
	      - Title
	      - Tagline
	      - Author
	      - Version
	      - Social
--]]


-- Return SuperActor Tree
return SuperActor.GetTree()
