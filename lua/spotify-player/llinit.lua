local M = {}
local Config = require("spotify-player.config")
local marquee = require("spotify-player.marquee")

local State = {
	NextPoll_ms = 0,

	isNull = true,
	Playing = false,
	AlbumTitle = "",
	TrackTitle = "",
	TimeElapsed = 0,
	TimeTotal = 0,
}

function M.isPlaying()
	return State.Playing
end

function M.get_icon()
	if State.isNull then
		return ""
	end
	if State.Playing then
		return " "
	end
	return " "
end

function M.get_text()
	if State.isNull then
		return ""
	else
		return marquee.getText()
	end
end

local function Update_Callback(Returned)
	local result = Returned.stdout

	State.Playing = false
	State.AlbumTitle = ""
	State.TrackTitle = ""

	if Returned.code > 0 then --if error
		return
	end

	if string.find(result, "null") == 1 then
		State.isNull = true
		State.AlbumTitle = "Not Playing"
	else
		State.isNull = false
		local isPlaying = string.find(result, '"is_playing":true')
		if isPlaying ~= nil then
			State.Playing = true
		end

		if State.isNull == false then
			local index = string.find(result, '"item":')
			index = string.find(result, '"artists":', index)
			if index == nil then --probably Spotify DJ talking, so no actual track being played.
				State.AlbumTitle = "Spotify"
				State.TrackTitle = "DJ X"
				State.TimeElapsed = 0
				State.TimeTotal = 10000 --try to update again in 10 seconds
			else
				index = string.find(result, '"name":"', index)
				index = index + 8 --move to right of double quote
				local indexend = string.find(result, '"', index) - 1
				local AlbumTitle = string.sub(result, index, indexend)
				State.AlbumTitle = AlbumTitle

				index = string.find(result, '"is_local":')
				index = string.find(result, '"name":"', index)
				index = index + 8 --move to right of double quote
				indexend = string.find(result, '"', index) - 1
				local TrackTitle = string.sub(result, index, indexend)
				State.TrackTitle = TrackTitle

				index = string.find(result, '"progress_ms":')
				index = index + 14
				indexend = string.find(result, ",", index) - 1
				State.TimeElapsed = string.sub(result, index, indexend)

				index = string.find(result, '"duration_ms":')
				index = index + 14
				indexend = string.find(result, ",", index) - 1
				State.TimeTotal = string.sub(result, index, indexend)
			end
		end
	end
	marquee.setText(State.AlbumTitle, State.TrackTitle)

	local ms = Config.lualine_update_max_ms

	if State.Playing then
		local TimeLeft = tonumber(State.TimeTotal) - tonumber(State.TimeElapsed)
		ms = TimeLeft + 1000 --add extra time so it updates after new track starts
	end

	--clamp
	if ms > Config.lualine_update_max_ms then
		ms = Config.lualine_update_max_ms
	end
	if ms < Config.lualine_update_min_ms then
		ms = Config.lualine_update_min_ms
	end
	State.NextPoll_ms = ms
end

local function onError(err, data)
	State.isNull = true
	State.Playing = false
end

function M.ForcePoll()
	State.NextPoll_ms = 0
end

function TimerUpdate()
	marquee.Update()

	State.NextPoll_ms = State.NextPoll_ms - Config.lualine_timer_update_ms
	if State.NextPoll_ms <= 0 then
		State.NextPoll_ms = Config.lualine_update_max_ms
		vim.system(Config.command_update, { stderr = onError }, Update_Callback)
	end

	vim.defer_fn(TimerUpdate, Config.lualine_timer_update_ms)
end

TimerUpdate()

return M
