M = {}

function M.check()
	vim.health.start("Checking if spotify_player can be called")
	if os.execute("spotify_player --version") == 0 then
		local handle = io.popen("spotify_player --version")
		local result = handle:read("*a")
		vim.health.ok(result)
	else
		vim.health.error("spotify_player not available.")
	end
end

return M
