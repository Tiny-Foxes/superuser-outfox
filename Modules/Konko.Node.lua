sudo()

Node = {}

local func_table = {}

local actor_idx = 1

local function UpdateTweens(self)
	local beat = TIME * BPS
	if beat == 0 then
		TIME = TIME - OFFSET
		OFFSET = 0
	end
	for i, v in ipairs(func_table) do
		local actor
		if type(v[7]) == 'string' then
			actor = self:GetChild(v[7])
		else
			actor = v[7]
		end
		local func = v[6]
		if beat >= v[1] and beat < (v[1] + v[2]) then
			local ease = v[3]((beat - v[1]) / v[2]) - v[4]
			local amp = ease * (v[5] - v[4])
			actor[func](actor, amp)
		elseif beat >= (v[1] + v[2]) then
			actor[func](actor, v[5])
			table.remove(func_table, i)
		end
	end
	TIME = TIME + DT
end

local NodeTree = Def.ActorFrame {
	UpdateMessageCommand = function(self)
		UpdateTweens(self)
	end,
}

-- This would be used for extending the metatable of the node, I hope? For whatever reason...
local function extends(self, nodeType)
	self = Def[nodeType](self)
end

local function new(obj)
	--lua.Trace('Node.new')
	local t
	if type(obj) == 'string' then
		t = { Type = obj }
	else
		t = obj or {}
	end
	t.Name = 'Actor'..actor_idx
	actor_idx = actor_idx + 1
	setmetatable(t, Node)
	return t
end
local function SetReady(self, func)
	--lua.Trace('Node:SetReady')
	self.ReadyCommand = function(self)
		return func(self)
	end
	return self
end
local function SetUpdate(self, func)
	--lua.Trace('Node:SetUpdate')
	self.UpdateMessageCommand = function(self)
		return func(self, DT)
	end
	return self
end
local function SetInput(self, func)
	--lua.Trace('Node:SetInput')
	self.InputMessageCommand = function(self, args)
		return func(self, args[1])
	end
	return self
end
local function SetName(self, name)
	--lua.Trace('Node:SetName')
	self.Name = name
	return self
end
local function AddToNodeTree(self)
	--lua.Trace('Node:AddToNodeTree')
	table.insert(NodeTree, self)
end
local function GetNodeTree()
	--lua.Trace('Node.GetNodeTree')
	return Nodes
end

local function tween(t)
	local actor = t[1]
	table.remove(t, 1)
	table.insert(t, actor)
	table.insert(func_table, t)
	return tween
end
-- Node:AddTween {beat, len, ease, startAmp, endAmp, func}
local function AddTween(self, t)
	--lua.Trace('Node:AddTween')
	table.insert(t, self.Name)
	table.insert(func_table, t)
	return self
end

Node = {
	extends = extends,
	new = new,
	AttachScript = AttachScript,
	SetReady = SetReady,
	SetUpdate = SetUpdate,
	SetInput = SetInput,
	SetName = SetName,
	AddToNodeTree = AddToNodeTree,
	SetSRTStyle = SetSRTStyle,
	GetNodeTree = GetNodeTree,
	tween = tween,
	AddTween = AddTween,
}
Node.__index = Node

return Def.ActorFrame {
	NodeTree
}
