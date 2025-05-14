Operate the spotify-player CLI/TUI program within NeoVim using the commands:

```
:SpotifyPlayPause
:SpotifyNext
```

Install with Lazy plugin:

```
return {
	"coreyb-git/spotify-player.nvim",
	keys = {
        -- Comment-out the following 2 lines if the which-key plugin isn't being used.
		{ "<leader>Sp", "<cmd>SpotifyPlayPause<cr>", desc = "Spotify Play/Pause" },
		{ "<leader>Sn", "<cmd>SpotifyNext<cr>", desc = "Spotify Next Track" },
	},
}
```
