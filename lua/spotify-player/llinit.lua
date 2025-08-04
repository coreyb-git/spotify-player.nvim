local M = {}
local Config = require("spotify-player.config")
local marquee = require("spotify-player.marquee")

local PlayingState = {
	Stopped = 1,
	Paused = 2,
	PlayingTrack = 3,
	Podcast = 4,
	Ad = 10,
	DJ_X = 20,
	Unknown = 999,
	Error = 1234,
}

local Icons = {}
Icons[PlayingState.Stopped] = " "
Icons[PlayingState.Paused] = "󰏤 "
Icons[PlayingState.PlayingTrack] = " "
Icons[PlayingState.Podcast] = " "
Icons[PlayingState.Ad] = "󰢤 "
Icons[PlayingState.DJ_X] = " "
Icons[PlayingState.Unknown] = "?"
Icons[PlayingState.Error] = "Error"

local State = {
	NextPoll_ms = 0,

	PlayingState = PlayingState.Stopped,
	AlbumTitle = "",
	TrackTitle = "",
	TimeElapsed = 0,
	TimeTotal = 0,
}

function M.get_icon()
	if State.PlayingState == PlayingState.Stopped then
		return ""
	end
	return Icons[State.PlayingState]
end

function M.get_text()
	if State.PlayingState == PlayingState.Stopped then
		return ""
	end
	return marquee.getText()
end

local function Update_Callback(Returned)
	local result = Returned.stdout

	-- Reset state variables for each update to ensure clean data
	State.PlayingState = PlayingState.Unknown
	State.AlbumTitle = ""
	State.TrackTitle = ""
	State.TimeElapsed = 0
	State.TimeTotal = 0

	local poll_ms_for_state = Config.lualine_update_max_ms -- Default poll time for non-playing, errors, etc.

	-- Handle command errors or "null" response (no active device)
	if string.find(result, "null") == 1 then
		State.PlayingState = PlayingState.Stopped
		State.AlbumTitle = ""
		State.TrackTitle = ""
		marquee.setText(State.AlbumTitle, State.TrackTitle)
		State.NextPoll_ms = poll_ms_for_state
		return
	end

	if Returned.code > 0 then
		State.PlayingState = PlayingState.Error
		--[[State.AlbumTitle = "Returned code: " .. Returned.code
		State.TrackTitle = Returned.stderr or ""
		--print(vim.inspect(Returned))
		marquee.setText(State.AlbumTitle, State.TrackTitle)]]
		State.NextPoll_ms = poll_ms_for_state
		return
	end

	local data = vim.json.decode(result)

	-- Handle JSON decoding errors
	if not data then
		State.PlayingState = PlayingState.Unknown
		State.AlbumTitle = "Error"
		State.TrackTitle = "Failed to parse JSON"
		marquee.setText(State.AlbumTitle, State.TrackTitle)
		State.NextPoll_ms = poll_ms_for_state
		return
	end

	State.TimeElapsed = data.progress_ms or 0
	State.TimeTotal = (data.item and (type(data.item) == "table") and data.item.duration_ms) or 0

	if data.item then
		if data.item == vim.NIL then
			State.PlayingState = PlayingState.DJ_X
			State.AlbumTitle = "Spotify"
			State.TrackTitle = "DJ X"
			State.NextPoll_ms = Config.lualine_update_min_ms
			marquee.setText(State.AlbumTitle, State.TrackTitle)
			return
		end

		if data.currently_playing_type == "track" then
			State.PlayingState = PlayingState.PlayingTrack
			State.AlbumTitle = (data.item.artists and #data.item.artists > 0 and data.item.artists[1].name)
				or "Unknown Artist"
			State.TrackTitle = data.item.name or "Unknown Track"
			poll_ms_for_state = (data.item.duration_ms - data.progress_ms) + Config.lualine_update_trackend_padding_ms
		elseif data.currently_playing_type == "episode" then
			State.PlayingState = PlayingState.Podcast
			State.AlbumTitle = (data.item.show and data.item.show.name) or "Podcast"
			State.TrackTitle = data.item.name or "Unknown Episode"
			poll_ms_for_state = (data.item.duration_ms - data.progress_ms) + Config.lualine_update_trackend_padding_ms
		elseif data.currently_playing_type == "ad" then
			State.PlayingState = PlayingState.Ad
			State.AlbumTitle = "Advertisement"
			State.TrackTitle = "Playing Now"
			poll_ms_for_state = Config.lualine_update_min_ms -- Poll frequently during ads
		else
			-- Covers Spotify DJ, "unsupported" type, or other cases where no 'item' is present but player is active.
			State.PlayingState = PlayingState.Unknown
			State.AlbumTitle = "Unknown"
			State.TrackTitle = "Unknown"
			poll_ms_for_state = Config.lualine_update_max_ms
		end
	end

	local is_playing = data.is_playing or false
	if not is_playing then
		State.PlayingState = PlayingState.Paused
	end

	marquee.setText(State.AlbumTitle, State.TrackTitle)

	-- Clamp NextPoll_ms within configured bounds
	State.NextPoll_ms = math.min(poll_ms_for_state, Config.lualine_update_max_ms)
	State.NextPoll_ms = math.max(State.NextPoll_ms, Config.lualine_update_min_ms)
end

local function onError(err, _)
	State.PlayingState = PlayingState.Error
	--[[State.AlbumTitle = "Error"
	State.TrackTitle = err or "Command Failed"
	State.NextPoll_ms = Config.lualine_update_max_ms -- Wait longer after an error
	marquee.setText(State.AlbumTitle, State.TrackTitle)]]
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
