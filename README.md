Operate the [spotify_player TUI](https://github.com/aome510/spotify-player) program within NeoVim using the commands:

```
:SpotifyPlayPause
:SpotifyNext
```

Install with Lazy plugin:

```
return {
	"coreyb-git/spotify-player.nvim",
	"folke/which-key.nvim",
	opts = {},
	keys = {
		{ "<leader>S", "", desc = "[S]potify" },
		{ "<leader>Sp", "<cmd>SpotifyPlayPause<cr>", desc = "[P]lay/Pause" },
		{ "<leader>Sn", "<cmd>SpotifyNext<cr>", desc = "[N]ext Track" },
	},
}
```

Includes custom Lualine components.
