--[[
	This is a stripped down version of SuperActorloader.lua from Kitsu template.
	allows Kitsu SuperActor system specifically OUTSIDE of modfiles.
--]]

local konko = LoadModule('Konko.Core.lua')
konko()

local SuperActor = {}
local VERSION = '1.0'

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
end

local ActorTree = Def.ActorFrame {
	UpdateCommand = function(self)
		UpdateTweens(self)
	end
}

local function new(obj)
	--print('SuperActor.new')
	local t
	if type(obj) == 'string' then
		t = { Type = obj }
		if obj == 'BitmapText' then t.Font = 'Common Normal' end
	else
		t = obj or {}
	end
	if not t.Name then t.Name = 'SuperActor'..actor_idx end
	actor_idx = actor_idx + 1
	setmetatable(t, SuperActor)
	return t
end
local function SetAttribute(self, attr, val)
	--print('SuperActor:SetAttribute')
	self[attr] = val
	return self
end
local function GetAttribute(self, attr)
	--print('SuperActor:GetAttribute')
	return self[attr]
end
local function SetCommand(self, name, func)
	--print('SuperActor:SetCommand')
	if type(func) ~= 'function' then
		printerr('SuperActor.SetCommand: Invalid argument #2 (expected function, got '..type(func)..')')
		return
	end
	self[name..'Command'] = function(self)
		return func(self)
	end
	return self
end
local function GetCommand(self, name)
	--print('SuperActor:GetCommand')
	return self[name..'Command']
end
local function SetMessage(self, name, func)
	--print('SuperActor:SetSignal')
	if type(func) ~= 'function' then
		printerr('SuperActor.SetSignal: Invalid argument #2 (expected function, got '..type(func)..')')
		return
	end
	self[name..'MessageCommand'] = function(self)
		return func(self)
	end
	return self
end
local function GetMessage(self, name)
	--print('SuperActor:GetMessage')
	return self[name..'MessageCommand']
end
local function SetInput(self, func)
	--print('SuperActor:SetInput')
	self.InputMessageCommand = function(self, args)
		return func(self, args[1])
	end
	return self
end
local function SetDraw(self, func)
	local allowed = {
		ActorFrame = true,
		ActorFrameTexture = true,
		ActorScroller = true,
	}
	if not allowed[self.Type] then
		printerr('Node.SetDraw: Cannot set draw function of type '..self.Type)
		return
	end
	local on = self.OnCommand
	self.OnCommand = function(self)
		if on then on(self) end
		self:SetDrawFunction(func)
	end
	return self
end
local function SetName(self, name)
	--print('SuperActor:SetName')
	self.Name = name
	return self
end
local function AddChild(self, child, idx, name)
	--print('SuperActor:AddChild')
	local allowed = {
		ActorFrame = true,
		ActorFrameTexture = true,
		ActorScroller = true,
	}
	if not allowed[self.Type] then
		printerr('SuperActor.AddChild: Cannot add child to type '..self.Type)
		return
	end
	if type(idx) == 'string' then
		name = idx
		idx = nil
	end
	if name then child:SetName(name) end
	child = Def[child.Type](child)
	if idx then
		table.insert(self, idx, child)
	else
		table.insert(self, child)
	end
	return self
end
local function GetChildIndex(self, name)
	--print('SuperActor:GetChildIndex')
	local allowed = {
		ActorFrame = true,
		ActorFrameTexture = true,
		ActorScroller = true,
	}
	if not allowed[self.Type] then
		printerr('SuperActor.GetChildIndex: Cannot add child to type '..self.Type)
		return
	end
	for i, v in ipairs(self) do
		if v.Name == name then
			return i
		end
	end
end
local function AddToTree(self)
	--lua.Trace('SuperActor:AddToTree')
	table.insert(ActorTree, self)
end
local function GetTree()
	--lua.Trace('SuperActor.GetTree')
	return ActorTree
end

local function tween(t)
	--lua.Trace('SuperActor.tween')
	local actor = t[1]
	table.remove(t, 1)
	table.insert(t, actor)
	table.insert(func_table, t)
	return tween
end
-- SuperActor:AddTween {beat, len, ease, startAmp, endAmp, func}
local function AddTween(self, t)
	--lua.Trace('SuperActor:AddTween')
	table.insert(t, self.Name)
	table.insert(func_table, t)
	return self
end

SuperActor = {
	VERSION = VERSION,
	new = new,
	SetAttribute = SetAttribute,
	GetAttribute = GetAttribute,
	SetCommand = SetCommand,
	GetCommand = GetCommand,
	SetMessage = SetMessage,
	GetMessage = GetMessage,
	SetInput = SetInput,
	SetDraw = SetDraw,
	SetName = SetName,
	AddChild = AddChild,
	GetChildIndex = GetChildIndex,
	AddToTree = AddToTree,
	GetTree = GetTree,
	tween = tween,
	AddTween = AddTween,
}
SuperActor.__index = SuperActor

return SuperActor
