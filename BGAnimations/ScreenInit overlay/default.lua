collectgarbage()

local function aft(self)
	self
		:SetWidth(sw)
		:SetHeight(sh)
		:EnableFloat(false)
		:EnableDepthBuffer(true)
		:EnableAlphaBuffer(true)
		:EnablePreserveTexture(false)
		:Create()
end
local function aftrecursive(self)
	self
		:SetWidth(sw)
		:SetHeight(sh)
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


local t = Def.ActorFrame { LoadModule('Konko.Core.lua') }

sudo()

OFFSET = 0.15
BPM = 146

---[[
local InsaneQuads = {}

for i = 1, 16 do
	InsaneQuads[i] = Node.new('Quad')
	InsaneQuads[i]
		:SetReady(function(self)
			local length = math.random(16, 64)
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
--]]

t[#t + 1] = Def.ActorFrame {
	InitCommand = function(self)
		self:Center()
	end,
	OnCommand = function(self)
		SOUND:PlayMusicPart(THEME:GetPathB('ScreenInit', 'overlay/insane.ogg'), 0, 24, 0, 0, false, true)
	end
}

return t
