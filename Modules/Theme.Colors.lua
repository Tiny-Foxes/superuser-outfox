local list_only = ...

local function JudgmentColor(j)
	local timing = LoadModule('Options.ReturnCurrentTiming.lua')().Name
	local c = {}
	c = {
		Original = {
			W1 = color("#92d5dd"),
			W2 = color("#ccd01f"),
			W3 = color("#b2dd56"),
			W4 = color("#32abd3"),
			W5 = color("#c84ad2"),
			Miss = color("#fa282f"),
		},
		ITG = {
			W1 = color("#a3dde4"),
			W2 = color("#d0d41f"),
			W3 = color("#8ecd04"),
			W4 = color("#9d30d3"),
			W5 = color("#ea8035"),
			Miss = color("#fa282f"),
		},
		Advanced = {
			ProW1 = color("#eee133"),
			ProW2 = color("#f7ebc0"),
			ProW3 = color("#acf8fa"),
			ProW4 = color("#e3ebf1"),
			ProW5 = color("#b3dbf1"),
			W1 = color("#bfeaff"),
			W2 = color("#fff568"),
			W3 = color("#a4ff00"),
			W4 = color("#34bfff"),
			W5 = color("#e44dff"),
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
	{
		Name = 'Default',
		-- Theme Colors
		Primary = color('#3F162D'),
		Secondary = color('#4E2635'),
		Elements = color('#9D276C'),
		Text = color('#FFFFFF'),
		Title = color('#CF3B98'),
		TitleTop = color('#CF3B98'),
		TitleBottom = color('#CF3B98'),

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
		Couple = color('#F04D7B'),
		Routine = color('#5292EB'),
		
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
	},
	{
		Name = 'Power',
		Primary = color('#A22200'),
		Secondary = color('#B84C2B'),
		Elements = color('#CC7052'),
		Title = color('#FF8000'),
	},
	{
		Name = 'Eulbink',
		Primary = color('#252446'),
		Secondary = color('#203562'),
		Elements = color('#1E579C'),
		Title = color('#AAAAAA'),
	},
	{
		Name = 'Olive',
		Primary = BoostColor(color('#3A4E48'), 0.75),
		Secondary = BoostColor(color('#57756C'), 0.75),
		Elements = BoostColor(color('#8B9D83'), 0.75),
		Title = BoostColor(color('#8B9D83'), 1.25),
	},
	{
		Name = 'Cotton Candy',
		Primary = color('#9C89B8'),
		Secondary = color('#B8BEDD'),
		Elements = color('#EFC3E6'),
		Title = color('#F0A6CA'),
	},
	{
		Name = '24 Karet',
		Primary = color('#50300C'),
		Secondary = color('#734D0F'),
		Elements = color('#B29106'),
		Title = color('#CBB800'),
	},
	{
		Name = 'Spearmint',
		Primary = color('#175F56'),
		Secondary = color('#167E8B'),
		Elements = color('#00BD9F'),
		Title = color('#00DECE'),
	},
	{
		Name = 'Polterheist',
		Primary = color('#204020'),
		Secondary = color('#00FFFF'),
		Elements = color('#FF00FF'),
		Title = color('#2F832F')
	},
	{
		Name = 'Feat. Umbra',
		--Primary = ,
		--Secondary = ,
		--Elements = ,
		--TitleTop = ,
		--TitleBottom = ,
	},
	{
		Name = 'Kit',
		Primary = color('#E5AF4C'),
		Secondary = color('#993333'),
		Elements = color('#798BA8'),
		Title = color('#FFFF00'),
	},
	{
		Name = 'Aka Ao',
		Primary = color('#FF008A'),
		Secondary = color('#B590FF'),
		Elements = color('#33D6FF'),
		Title = color('#E85ED7')
	},
	{
		Name = 'Feat. Chegg',
		--Primary = ,
		--Secondary = ,
		--Elements = ,
		--TitleTop = ,
		--TitleBottom = ,
	},
	{
		Name = 'Trans Pride',
		Primary = color('#F5AAB9'),
		Secondary = color('#A0A0A0'),
		Elements = color('#5BCFFA'),
		TitleTop = BoostColor(color('#FC6FA8'), 1.25),
		TitleBottom = BoostColor(color('#5BCFFA'), 1.25),
	},
	{
		Name = 'Enby Pride',
		Primary = color('#968802'),
		Secondary = color('#282828'),
		Elements = color('#9D59D2'),
		TitleTop = BoostColor(color('#FCF431'), 1.25),
		TitleBottom = BoostColor(color('#9D59D2'), 1.25),
	},
	{
		Name = 'Ace Pride',
		Primary = color('#5E1984'),
		Secondary = color('#282828'),
		Elements = color('#9E9E9E'),
		TitleTop = BoostColor(color('#5E1984'), 1.25),
		TitleBottom = BoostColor(color('#282828'), 1.25),
	},
}

for i, v in ipairs(Colors) do
	if i ~= 1 then
		for k, v2 in pairs(Colors[1]) do
			if not k:find('Title') and not k:find('Name') then
				v[k] = v[k] or v2
			end
		end
	end
	v.Name = v.Name or ('Color '..i)
end

local scheme = tonumber(LoadModule('Config.Load.lua')('SuperuserSubTheme', 'Save/OutFoxPrefs.ini'))

if list_only then
	local list = {
		Choices = {},
		Values = {}
	}
	for i, v in ipairs(Colors) do
		table.insert(list.Choices, v.Name)
		table.insert(list.Values, i)
	end
	return list
end
return Colors[scheme] or Colors[1]
