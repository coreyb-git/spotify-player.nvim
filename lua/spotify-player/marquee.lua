local M = {}
local Config = require("spotify-player.config")

local EndBlanks = ""

local State = {
	Text = "",
	CharCount = 0,
	ShownText = "",
	AnimIndex = -2,
	AnimEndIndex = 1,
}

function M.setText(Album, Track)
	local alb = "[" .. Album .. "]"
	local s = alb .. " " .. Track .. "     " .. alb
	local stotal = s .. " " .. Track .. EndBlanks
	if State.Text ~= stotal then -- if the song has changed then reset animation
		State.CharCount = string.len(alb)
		local tracklen = string.len(Track)
		if State.CharCount < tracklen then
			State.CharCount = tracklen
		end
		if State.CharCount < Config.lualine_chars_min then
			State.CharCount = Config.lualine_chars_min
		end
		if State.CharCount > Config.lualine_chars_max then
			State.CharCount = Config.lualine_chars_max
		end
		State.AnimIndex = -9
		State.AnimEndIndex = string.len(s) + 1
		State.Text = stotal
		M.Update()
	end
end

function M.Update()
	local forceRefresh = false
	if State.AnimIndex <= State.AnimEndIndex then
		State.AnimIndex = State.AnimIndex + 1
		forceRefresh = true
	end

	local index = State.AnimIndex
	if index < 1 then
		index = 1
	end

	--State.ShownText = string.sub(State.Text, index, index + Config.lualine_chars_max - 1)
	State.ShownText = string.sub(State.Text, index, index + State.CharCount - 1)
	if forceRefresh then
		require("lualine").refresh({ scope = "all", place = { "statusline" } })
	end
end

function M.getText()
	return State.ShownText
end

for c = 1, Config.lualine_chars_max do
	EndBlanks = EndBlanks .. " "
end

return M
