local lualine_require = require("lualine_require")
local M = lualine_require.require("lualine.component"):extend()

function M:update_status()
	return require("spotify-player.llinit").get_icon()
end

return M
