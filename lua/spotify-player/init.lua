local M = {}
local config = require("spotify-player.config")
local llinit = require("spotify-player.llinit")

function M.setup(opts)
	for i, v in pairs(opts) do
		config[i] = v
	end
end

local function Command_Update(Returned)
	--[[
	print("code: " .. Returned.code)
	print("signal: " .. Returned.signal)
	print("stdout: " .. Returned.stdout)
	print("stderr: " .. Returned.stderr)
	]]
	--
	if Returned.code ~= 0 then
		require("notify")
		local notifyopts = { title = "spotify-player", timeout = 5000 }
		local s = ""
		local level = vim.log.levels.INFO
		if string.find(Returned.stderr, "no playback found") then
			s = "Spotify isn't playing..\n\nStart a track in Spotify first."
		else
			s = Returned.stderr
			level = vim.log.levels.ERROR
		end
		vim.notify(s, level, notifyopts)
	end
	llinit.ForcePoll()
end

function M.PlayPause()
	vim.system(config.command_playpause, {}, Command_Update)
end

function M.Next()
	vim.system(config.command_next, {}, Command_Update)
end

vim.api.nvim_create_user_command(
	"SpotifyPlayPause",
	M.PlayPause,
	{ nargs = 0, desc = "Spotify Play/Pause.", bang = false }
)
vim.api.nvim_create_user_command("SpotifyNext", M.Next, { nargs = 0, desc = "Spotify Next Track.", bang = false })

return M
