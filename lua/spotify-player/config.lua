return {
	command_playpause = { "spotify_player", "playback", "play-pause" },
	command_next = { "spotify_player", "playback", "next" },
	command_update = { "spotify_player", "get", "key", "playback" },

	lualine_update_min_ms = 5000,
	lualine_update_max_ms = 60000,
	lualine_update_trackend_padding_ms = 2000,
	lualine_chars_min = 5,
	lualine_chars_max = 20,

	lualine_timer_update_ms = 200,
}
