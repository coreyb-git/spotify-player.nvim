local lualine_require = require("lualine_require")
local M = lualine_require.require("lualine.component"):extend()

function M:update_status()
	local s = require("spotify-player.llinit")

	if s.State.Playing then
		return "|>"
	end
	return "||"
end

return M
