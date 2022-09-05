local konko = LoadModule('Konko.Core.lua')
konko()

local SuperActor = LoadModule('Konko.SuperActor.lua')


local gameinfo = {
	"Dance\n\nSingle (4 Panel)\nSolo (6 Panel)\nThree (3 Panel)\nDouble (8 Panel)",
	"Pump\n\nSingle (5 Panel)\nHalfDouble (6 Panel)\nDouble (10 Panel)",
	"SMX\n\nSingle (5 Panel)\nDual (6 Panel)\nDouble (10 Panel)",
	"Keyboard\n\nSingle (1-19 Button)",
	"ez2\n\nSingle (3 Panel 2 Hand)\nReal(3 Panel 4 Hand)\nDouble(6 Panel 4 Hand)",
	"Para\n\nSingle (5 Sensor)",
	"DS3DDX\n\nSingle (4 Panel 4 Hand)",
	"Be-Mu\n\nSingle5 (5 Button 1 Scratch)\nSingle7 (7 Button 1 Scratch)\nDouble5 (10 Button 2 Scratch)\nDouble7 (14 Button 2 Scratch)",
	"DMX\n\nSingle (4 Sensor)\nDouble (8 Sensor)",
	"TechnoMotion\n\nSingle4 (4 Panel)\nSingle5 (5 Panel)\nSingle8 (8 Panel)\nDouble4 (8 Panel)\nDouble5 (10 Panel)\nDouble8 (16 Panel)",
	"Po-Mu\n\nFive (5 Button)\nSeven (7 Button)\nNine (9 Button)",
	"GDDM\n\nSingle (9 Parts)",
	"GDGF\n\n5 Guitar (5 Fret)\n5 Bass (5 Fret 1 Snare)\n3 Guitar (3 Fret)\n3 Bass (3 Fret 1 Snare)",
	"Guitarh\n\n6 Guitar (5 Fret 1 Snare)\n6 Bass (5 Fret 1 Snare)\n(6 Guitar 1 Snare)\n(6 Bass 1 Snare)",
	--"lights",
	"KickBox\n\nHuman (4 Panel)\nQuadarm (4 Panel\nInsect (6 Panel)\nArachnid (8 Panel)"
}

local games = {
	"dance",
	"pump",
	"smx",
	"kbx",
	"ez2",
	"para",
	"ds3ddx",
	"be-mu",
	"maniax",
	"techno",
	"po-mu",
	"gddm",
	"gdgf",
	"guitarh",
	--"lights", -- should change this to another screen option.
	"kickbox"
}

local index = 1

local options = {}
for i, v in ipairs(games) do
	options[#options + 1] = {v, function(self)
		GAMEMAN:SetGame(v:lower())
	end}
	if v == GAMESTATE:GetCurrentGame():GetName() then index = i end
end

options.StartIndex = index

local wheel = LoadModule('Options.Wheel.lua')(options)

local info = SuperActor.new('BitmapText')

do info
	:SetAttribute('Font', 'Common Large')
	:SetCommand('Init', function(self)
		self
			:xy(SL + 120, ST + 120)
			:halign(0)
			:valign(0)
			:zoom(0.75)
	end)
	:SetMessage('MoveOptions', function(self, params)
		self
			:stoptweening()
			:settext(gameinfo[params.Index])
			:cropright(1)
			:linear(0.25)
			:cropright(0)
	end)
	:AddToTree('Info')
end

return Def.ActorFrame {
	wheel,
	SuperActor.GetTree()
}
