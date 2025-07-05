local M = {}
local Config = require("spotify-player.config")

M.State = {
	isNull = true,
	Playing = false,
	AlbumTitle = "",
	TrackTitle = "",
	TimeElapsed = 0,
	TimeTotal = 0,
	NextPoll_ms = 0,
}

function M.isPlaying()
	return M.State.Playing
end

function M.get_icon()
	if M.State.isNull then
		return ""
	end
	if M.State.Playing then
		return " "
	end
	return " "
end

local function Update_Callback(Returned)
	local result = Returned.stdout

	M.State.Playing = false
	M.State.AlbumTitle = ""
	if string.find(result, "null") == 1 then
		M.State.isNull = true
		M.State.AlbumTitle = "Not Playing"
	else
		M.State.isNull = false
		local isPlaying = string.find(result, '"is_playing":true')
		if isPlaying ~= nil then
			M.State.Playing = true
		end

		if M.State.isNull == false then
			local index = string.find(result, '"item":')
			index = string.find(result, '"artists":', index)
			if index == nil then --probably Spotify DJ talking, so no actual track being played.
				M.State.AlbumTitle = "Spotify"
				M.State.TrackTitle = "DJ X"
				M.State.TimeElapsed = 0
				M.State.TimeTotal = 10000 --try to update again in 10 seconds
			else
				index = string.find(result, '"name":"', index)
				index = index + 8 --move to right of double quote
				local indexend = string.find(result, '"', index) - 1
				local AlbumTitle = string.sub(result, index, indexend)
				M.State.AlbumTitle = AlbumTitle

				index = string.find(result, '"is_local":')
				index = string.find(result, '"name":"', index)
				index = index + 8 --move to right of double quote
				indexend = string.find(result, '"', index) - 1
				local TrackTitle = string.sub(result, index, indexend)
				M.State.TrackTitle = TrackTitle

				index = string.find(result, '"progress_ms":')
				index = index + 14
				indexend = string.find(result, ",", index) - 1
				M.State.TimeElapsed = string.sub(result, index, indexend)

				index = string.find(result, '"duration_ms":')
				index = index + 14
				indexend = string.find(result, ",", index) - 1
				M.State.TimeTotal = string.sub(result, index, indexend)
			end
		end
	end
	require("spotify-player.marquee").setText(M.State.AlbumTitle, M.State.TrackTitle)

	local ms = Config.lualine_update_max_ms

	if M.State.Playing then
		local TimeLeft = tonumber(M.State.TimeTotal) - tonumber(M.State.TimeElapsed)
		ms = TimeLeft + 1000 --add extra time so it updates after new track starts
	end

	--clamp
	if ms > Config.lualine_update_max_ms then
		ms = Config.lualine_update_max_ms
	end
	if ms < Config.lualine_update_min_ms then
		ms = Config.lualine_update_min_ms
	end
	M.State.NextPoll_ms = ms
end

local function onError(err, data)
	M.State.isNull = true
	M.State.Playing = false
end

function M.ForcePoll()
	M.State.NextPoll_ms = 0
end

function TimerUpdate()
	require("spotify-player.marquee").Update()

	M.State.NextPoll_ms = M.State.NextPoll_ms - Config.lualine_timer_update_ms
	if M.State.NextPoll_ms <= 0 then
		M.State.NextPoll_ms = Config.lualine_update_max_ms
		vim.system(Config.command_update, { stderr = onError }, Update_Callback)
	end

	vim.defer_fn(TimerUpdate, Config.lualine_timer_update_ms)
end

TimerUpdate()

return M
