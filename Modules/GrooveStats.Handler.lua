local gs = {}

local path = '/Save/GrooveStats/'

function gs.request(type, data)
	local id = CRYPTMAN:GenerateRandomUUID()
	local now = GetTimeSinceStart()
	local time = 0
	local timeout = 59
	if type == 'ping' then
		id = type
		data = {
			action = 'ping',
			protocol = 1,
		}
	end
	local req = coroutine.create(function(data)
		File.Write(path..'requests/'..id..'.json', JsonEncode(data))
		while true do
			time = time + (GetTimeSinceStart() - now)
			now = GetTimeSinceStart()
			local res = File.Read(path..'responses/'..id..'.json')
			if res then
				coroutine.yield(JsonDecode(res))
				break
			end
			if time > timeout then
				res = {
					status = 'timeout',
					data = {}
				}
				coroutine.yield(res)
				break
			end
			coroutine.yield()
		end
	end)
	local s, ret = coroutine.resume(req, data)
	if s and ret then return ret end
end

function gs.ping()
	return gs.request('ping', {
		action = 'ping',
		protocol = 1,
	})
end
function gs.session()
	return gs.request('session', {
		action = 'groovestats/new-session',
		chartHashVersion = 3
	})
end
function gs.scores(data)
	data.action = 'groovestats/player-scores'
	return gs.request('player-scores', data)
end
function gs.leaderboards(data)
	data.action = 'groovestats/player-leaderboards'
	return gs.request('player-leaderboards', data)
end
function gs.submit(data)
	data.action = 'groovestats/score-submit'
	return gs.request('score-submit', data)
end

return gs
