local konko = LoadModule('Konko.Core.lua')
konko()

local SuperActor = LoadModule('Konko.SuperActor.lua')


local gameinfo = {
	"Dance\n\nSingle (4 panels)\nSolo (6 panels)\nThree (3 panels)\nDouble (8 panels)\nSolo Double (12 panels)\nThree Double (6 panels)",
	"Pump\n\nSingle (5 panels)\nHalfDouble (6 panels)\nDouble (10 panels)",
	"SMX\n\nSingle (5 panels)\nDual (6 panels)\nDouble (10 panels)",
	"Techno\n\nCross (4 panels)\nDiagonal (5 panels)\nSquare (8 panels)\nSquare+ (9 panels)\nCross Double (8 panels)\nDiagonal Double (10 panels)\nSquare Double (16 panels)\nSquare+ Double (18 panels)",
	"Be-Mu\n\nSingle 5 (5 buttons, 1 turntable)\nSingle 7 (7 buttons, 1 turntable)\nDouble 10 (10 buttons, 2 turntables)\nDouble 14 (14 buttons, 2 turntables)",
	"Po-Mu\n\n3 buttons\n4 buttons\n5 buttons\n7 buttons\n9 buttons\n18 buttons",
	"GDDM\n\n10-piece (8 drums, bass pedal, hi-hat pedal)\n9-piece (7 drums, bass pedal, hi-hat pedal)\n6-piece (5 drums, bass pedal)",
	"GDGF\n\nGuitar 5 (5 frets)\nBass 5 (5 frets, open strum)\nGuitar 6 (6 frets)\nGuitar 3 (3 frets)\nBass 3 (3 frets, open strum)",
	"GH\n\nSolo, Bass, Rhythm (5 frets)",
	"Taitai\n\nSingle (drumhead/red, rim/blue)",
	"Para\n\nSingle (5 sensors)\nDouble (10 sensors)",
	"KBX\n\n1 to 19 buttons",
	"Ez2Dancer\n\nSingle (3 panels, 2 sensors)\nReal (3 panels, 2 upper sensors, 2 lower sensors)\nDouble (6 panels, 4 sensors)",
	"3DDX\n\nSingle (4 panels, 4 sensors)\nSingle (5 panels, 4 sensors)\nDual (8 panels, 8 sensors)\nDual (10 panels, 8 sensors)",
	"DMX\n\nSingle (4 sensors)\nDouble (8 sensors)",
	"StepStage\n\nTwin (3 panel rows)\nSingle (6 panels)",
	--"lights",
	"KickBox\n\nHuman\nQuadarm\nInsect\nArachnid"
}

local games = {
	"dance",
	"pump",
	"smx",
	"techno",
	"be-mu",
	"po-mu",
	"gddm",
	"gdgf",
	"gh",
	"taiko",
	"para",
	"kbx",
	"ez2",
	"ds3ddx",
	"maniax",
	"stepstage",
	--"lights",
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
