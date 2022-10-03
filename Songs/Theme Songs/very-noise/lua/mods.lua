-- Libraries
import 'stdlib'
import 'konko-node'
import 'konko-mods'
import 'mirin-syntax'


-- Constants from stdlib
getfrom 'std' {
	'SW', 'SH',
	'SCX', 'SCY',
	'PL', 'POS',
}

-- Proxies
for pn = 1, #GAMESTATE:GetEnabledPlayers() do
	Node.new('ActorProxy'):AddToTree()
		:SetReady(function(self)
			std.ProxyPlayer(self, pn)
		end)
	Node.new('ActorProxy'):AddToTree()
		:SetReady(function(self)
			std.ProxyJudgment(self, pn)
		end)
	Node.new('ActorProxy'):AddToTree()
		:SetReady(function(self)
			std.ProxyCombo(self, pn)
		end)
end


--[[
	Constants:
	-	Screen Width -> SW
	-	Screen Height -> SH
	-	Screen Center X -> SCX
	-	Screen Center Y -> SCY

	Variables:
	-	Current Beat -> BEAT

	Actors:
	-	Top Screen -> SCREEN
	-	Player -> PL[pn].Player
	-	Judgment -> PL[pn].Judgment
	-	Combo -> PL[pn].Combo
	-	Player Proxies -> PL[pn].ProxyP[i]
	-	Add Player Proxy -> std.ProxyPlayer(proxy, pn)
]]

-- Mods
using 'mirin' (function()

	-- Default mods
	setdefault {
		1.5, 'xmod',
		100, 'modtimersong',
	}
	-- Mode code goes hode

end)
-- Node functions
using 'Node' (function()

	func {std.START, function()
		Node.HideOverlay(false)
	end}
	-- Nod cod gos hod

end)

-- Called on InitCommand
function init()

end

-- Called on ReadyCommand
function ready()

end

-- Called on UpdateCommand
function update(dt)

end

-- Called on InputMessageCommand
function input(event)

end

-- Called on Actors.Mods:Draw()
function draw()

end


-- Actors
return Def.ActorFrame {

	Node.GetTree(),
	-- Actors gactors hactor

}
