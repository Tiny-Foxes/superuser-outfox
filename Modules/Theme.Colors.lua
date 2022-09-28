local function JudgmentColor(j)
	local timing = LoadModule('Options.ReturnCurrentTiming.lua')().Name
	local c = {}
	c = {
		Original = {
			W1	= color("#bfeaff"),
			W2	= color("#fff568"),
			W3	= color("#a4ff00"),
			W4	= color("#34bfff"),
			W5	= color("#e44dff"),
			Miss = color("#ff3c3c"),
		},
		ITG = {
			W1 = color("#a7ffff"),
			W2 = color("#ffff84"),
			W3 = color("#a7ffa7"),
			W4 = color("#ffa7ff"),
			W5 = color("#ffb8a7"),
			Miss = color("#ff8b8b"),
		},
		Advanced = {
			ProW1 = color("#eee133"),
			ProW2 = color("#f7ebc0"),
			ProW3 = color("#acf8fa"),
			ProW4 = color("#e3ebf1"),
			ProW5 = color("#b3dbf1"),
			W1	= color("#bfeaff"),
			W2	= color("#fff568"),
			W3	= color("#a4ff00"),
			W4	= color("#34bfff"),
			W5	= color("#e44dff"),
			Miss = color("#ff3c3c"),
		},
		FAPlus = {
		},
		ECFA = {
			ProW1 = color("#f2f6fb"),
			W1 = color("#a7ffff"),
			W2 = color("#ffff84"),
			W3 = color("#a7ffa7"),
			W4 = color("#ffa7ff"),
			W5 = color("#ffb8a7"),
			Miss = color("#ff8b8b"),
		},
	}
	return c[timing][j] or color("#ffffff")
end

local Colors = {
	-- Theme Colors
	Primary = color('#3F162D'),
	Secondary = color('#4E2635'),
	Elements = color('#9D276C'),

	-- Player Colors
	P1 = color('#F04D7B'),
	P2 = color('#5292EB'),

	-- Difficulty Colors
	Beginner = color('#59365A'),
	Easy = color('#699429'),
	Medium = color('#B4943F'),
	Hard = color('#AB3541'),
	Crazy = color('#AB3541'),
	Challenge = color('#618FB0'),
	Nightmare = color('#618FB0'),
	Edit = color('#808080'),
	
	-- Judgment Colors
	ProW1	= JudgmentColor('ProW1'),
	ProW2	= JudgmentColor('ProW2'),
	ProW3	= JudgmentColor('ProW3'),
	ProW4	= JudgmentColor('ProW4'),
	ProW5	= JudgmentColor('ProW5'),
	W1	= JudgmentColor('W1'),
	W2	= JudgmentColor('W2'),
	W3	= JudgmentColor('W3'),
	W4	= JudgmentColor('W4'),
	W5	= JudgmentColor('W5'),
	Miss = JudgmentColor('Miss'),
	Held = color("#ffffff"),
	MaxCombo = color("#ffc600"),

	-- General Colors
	Black = color('#000000'),
	Gray = color('#808080'),
	White = color('#FFFFFF'),
	Red = color('#FF0000'),
	Orange = color('#FF8000'),
	Yellow = color('#FFFF00'),
	Haze = color('#FFFF80'),
	Tulip = color('#FF8080'),
	Chartreuse = color('#80FF00'),
	Green = color('#00FF00'),
	Spring = color('#00FF80'),
	Lime = color('#80FF80'),
	Electric = color('#80FFFF'),
	Cyan = color('#00FFFF'),
	Slate = color('#8080FF'),
	Dodger = color('#0080FF'),
	Blue = color('#0000FF'),
	Indigo = color('#8000FF'),
	Magenta = color('#FF00FF'),
	Fuchsia = color('#FF80FF'),
	Pink = color('#FF0080'),

}

return Colors
