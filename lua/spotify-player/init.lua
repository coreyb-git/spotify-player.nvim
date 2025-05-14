local M = {}
local config = require("spotify-player.config")

function M.setup(opts)
	for i, v in pairs(opts) do
		config[i] = v
	end
end

function M.PlayPause()
	local handle = io.popen(config.command_playpause)
end

function M.Next()
	local handle = io.popen(config.command_next)
end

vim.api.nvim_create_user_command(
	"SpotifyPlayPause",
	M.PlayPause,
	{ nargs = 0, desc = "Spotify Play/Pause.", bang = false }
)
vim.api.nvim_create_user_command("SpotifyNext", M.Next, { nargs = 0, desc = "Spotify Next Track.", bang = false })

return M
