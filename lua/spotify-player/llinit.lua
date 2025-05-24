local M = {}
local Config = require("spotify-player.config")

M.State = {
	isNil = true,
	Playing = false,
	Title = "",
}

function M.StateUpdate()
	local handle = io.popen(Config.command_getdata)
	local result = handle:read("*a")
	handle:close()

	M.State.isNil = true
	M.State.Playing = false
	local playback = string.find(result, '"is_playing":true')
	if playback == nil then
		M.State.Playing = false
	else
		M.State.isNil = false
		M.State.Playing = true
	end

	M.State.Title = ""
	if M.State.Playing then
		local index = string.find(result, '"item":')
		index = string.find(result, '"artists":', index)
		index = string.find(result, '"name":"', index)
		local indexend = string.find(result, '"', index)
		local title = string.sub(result, index, indexend)
		M.State.Title = title
	end

	vim.defer_fn(M.StateUpdate, Config.lualine_update_timer_ms)
end

function M.AnimUpdate()
	--todo
	vim.defer_fn(M.AnimUpdate, Config.lualine_anim_timer_ms)
end

M.StateUpdate()
M.AnimUpdate()

return M
