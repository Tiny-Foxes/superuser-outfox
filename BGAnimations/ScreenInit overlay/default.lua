collectgarbage()

local function aft(self)
	self
		:SetWidth(SCREEN_WIDTH)
		:SetHeight(SCREEN_HEIGHT)
		:EnableFloat(false)
		:EnableDepthBuffer(true)
		:EnableAlphaBuffer(true)
		:EnablePreserveTexture(false)
		:Create()
end
local function aftrecursive(self)
	self
		:SetWidth(SCREEN_WIDTH)
		:SetHeight(SCREEN_HEIGHT)
		:EnableDepthBuffer(true)
		:EnableAlphaBuffer(false)
		:EnableFloat(false)
		:EnablePreserveTexture(true)
		:Create()
end
function sprite(self)
	self:Center()
end
function aftsprite(aft, sprite)
	sprite:SetTexture(aft:GetTexture())
end

local t = Def.ActorFrame {
	Def.ActorFrameTexture {
		Name = 'InitAFT',
		InitCommand = aft,
		loadfile(THEME:GetPathB('ScreenWithMenuElements', 'background'))(),
		Def.Sprite {
			Name = 'InitSprite',
			InitCommand = sprite,
			OnCommand = function(self)
				local aft = self:GetParent():GetParent():GetChild('InitAFTR')
				aftsprite(aft, self)
				self
					:zoom(1.05)
					:diffusealpha(0)
			end,
		},
		LoadModule('Konko.Core.lua'),
	},
	Def.Sprite {
		Name = 'InitShowActors',
		InitCommand = sprite,
		OnCommand = function(self)
			local aft = self:GetParent():GetChild('InitAFT')
			aftsprite(aft, self)
		end,
	},
	Def.ActorFrameTexture {
		Name = 'InitAFTR',
		InitCommand = aftrecursive,
		Def.Sprite {
			Name = 'InitSpriteR',
			InitCommand = sprite,
			OnCommand = function(self)
				local aft = self:GetParent():GetParent():GetChild('InitAFT')
				aftsprite(aft, self)
			end,
		},
	},
}

t[#t + 1] = Def.ActorFrame {
	InitCommand = function(self)
		self:Center()
	end,
	OnCommand = function(self)
		SOUND:PlayMusicPart(THEME:GetPathB('ScreenInit', 'overlay/insane.ogg'), 0, 24)
	end
}


---------------- Animations Here ----------------
sudo()

OFFSET = 0.15
BPM = 146

local InsaneQuads = {}

for i = 1, 16 do
	InsaneQuads[i] = Node.new('Quad')
	InsaneQuads[i]
		:SetReady(function(self)
			local length = math.random(8, 32)
			self:xy(math.random(120, SW - 120), math.random(120, SH - 120))
			self:SetSize(length, length)
			self:zoom(0)
		end)
		for beat = 0, 8, 4 do
			local start = ((i - 1) * 0.25) + beat
			InsaneQuads[i]
				:AddTween {start, 0.5, Tweens.outback, 0, 1, 'zoom'}
				:AddTween {start + 1, 1, Tweens.incircle, 1, 0, 'zoom'}
				:AddTween {start + 4, 0, Tweens.instant, 0, math.random(120, SW - 120), 'x'}
				:AddTween {start + 4, 0, Tweens.instant, 0, math.random(120, SH - 120), 'y'}
		end
	InsaneQuads[i]:AddToNodeTree()
end

function ready()
	local InitSprite = SCREENMAN:GetTopScreen():GetChild('Overlay'):GetChild('InitAFT'):GetChild('InitSprite')
	Node.tween
		{InitSprite, 8, 6, Tweens.outquad, 0, 0.85, 'diffusealpha'}
		{InitSprite, 12, 4, Tweens.inoutquad, 0.85, 0, 'diffusealpha'}
end
-------------------------------------------------


return t
