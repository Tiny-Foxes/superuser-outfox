local gs = LoadModule('GrooveStats.Handler.lua')

local function ReportTable(t, ind)
	ind = ind or 0
	local indent = ''
	for i = 1, ind do
		indent = indent..' '
	end
	for k, v in pairs(t) do
		local vtype = type(v)
		local str = indent..k..': '..tostring(v)
		if vtype == 'table' then str = str..' ('..#v..')' end
		lua.ReportScriptError(str)
		if vtype == 'table' then ReportTable(v, ind + 2) end
	end
end

local function GetJLineValue(line, pl)
	if line == "Held" then
		return STATSMAN:GetCurStageStats():GetPlayerStageStats(pl):GetHoldNoteScores("HoldNoteScore_Held")
	elseif line == "MaxCombo" then
		return STATSMAN:GetCurStageStats():GetPlayerStageStats(pl):MaxCombo()
	else
		return STATSMAN:GetCurStageStats():GetPlayerStageStats(pl):GetTapNoteScores("TapNoteScore_" .. line)
	end
	return "???"
end

return Def.ActorFrame {
	LoadActorWithParams(THEME:GetPathG('', 'screenheader'), {}),
	Def.ActorFrame {
		InitCommand = function(self)
		end,
		OnCommand = function(self)
		end,
		Def.BitmapText {
			Font = 'Common Normal',
			InitCommand = function(self)
				self:align(0, 0):xy(12, 48):diffusealpha(0.5)
			end,
			OnCommand = function(self)
				if gs.Enabled() then
					gs.leaderboards {
						maxLeaderboardResults = 10,
						player1 = {
							chartHash = gs.ChartHash(PlayerNumber[1]),
							apiKey = gs.GetAPI(PlayerNumber[1]),
						}
					}
				end
			end,
			PlayerLeaderboardsMessageCommand = function(self, res)
				if not res then
					SCREENMAN:SystemMessage('Failed to get leaderboard: no respons from server.')
					return
				elseif res.status ~= 'success' then
					SCREENMAN:SystemMessage('Failed to get leaderboard: connection '..res.status..'.')
					return
				end
				local scores = {}
				for v in ivalues(res.data.player1.gsLeaderboard) do
					scores[tonumber(v.rank)] = v.rank..': '..v.name..' - '..FormatPercentScore(tonumber(v.score) * 0.0001)
				end
				self:settext(table.concat(scores, '\n'))
				if self:GetText() == '' then
					self:settext('No leaderboard for song')
				end
			end,
		}
	},
	Def.Actor {
		OnCommand = function(self)
			SCREENMAN:GetTopScreen():AddInputCallback(LoadModule('Lua.InputSystem.lua')(self))
		end,
		MenuUpCommand = function(self)
			if not gs.Enabled() then
				SCREENMAN:SystemMessage('GrooveStats is not enabled.')
				return
			end
			local plr = self.pn
			--[[
			if not gs.IsPadPlayer(plr) then
				SCREENMAN:SystemMessage('Cannot submit score for non-pad players.')
			end
			--]]
			local pn = PlayerNumber:Reverse()[plr] + 1
			local prof = PROFILEMAN:GetProfile(plr)
			if not prof then
				SCREENMAN:SystemMessage('No profile loaded.')
				return
			end
			local api = gs.GetAPI(plr)
			if not api then
				SCREENMAN:SystemMessage('No API key found.')
				return
			end
			SCREENMAN:SystemMessage('Submitting score to GrooveStats, please wait...')
			local jlines = {}
			local names, length = LoadModule('Options.SmartTapNoteScore.lua')
			names = names()
			table.sort(names)
			names[#names + 1] = 'Miss'
			local total = 0
			for i, v in ipairs(names) do
				jlines[v] = GetJLineValue(v, plr)
				if v ~= 'Miss' then total = total + jlines[v] end
			end
			jlines.totalSteps = total
			gs.submit {
				['player'..pn] = {
					apiKey = api,
					profileName = prof:GetDisplayName(),
					chartHash = gs.ChartHash(plr),
					rate = GAMESTATE:GetSongOptionsObject('ModsLevel_Preferred'):MusicRate() * 100,
					comment = GAMESTATE:GetPlayerState(plr):GetPlayerOptionsString('ModsLevel_Preferred'),
					score = math.floor(STATSMAN:GetCurStageStats():GetPlayerStageStats(plr):GetPercentDancePoints() * 10000),
					--judgmentCounts = jlines,
					--usedCMod = (GAMESTATE:GetPlayerState(plr):GetPlayerOptions('ModsLevel_Preferred'):CMod() ~= nil),
				},
			}
		end,
		ScoreSubmitMessageCommand = function(self, res)
			if not res then
				SCREENMAN:SystemMessage('Failed to submit score: no response from server.')
				return
			elseif res.status ~= 'success' then
				SCREENMAN:SystemMessage('Failed to submit score: connection '..res.status..'.')
				return
			end
			SCREENMAN:SystemMessage('Submitted score to GrooveStats.')
		end,
	}
}
