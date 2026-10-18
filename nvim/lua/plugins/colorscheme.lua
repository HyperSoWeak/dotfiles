-- Catppuccin Macchiato, matching tmux and starship.
return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    opts = { flavour = "macchiato", transparent_background = true },
  },
  { "LazyVim/LazyVim", opts = { colorscheme = "catppuccin" } },
}
