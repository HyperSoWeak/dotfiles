return {
  {
    "folke/snacks.nvim",
    opts = {
      image = {},
      dashboard = {
        preset = {
          header = [[
██╗  ██╗██╗   ██╗██████╗ ███████╗██████╗   ██╗   ██╗██╗███╗   ███╗
██║  ██║╚██╗ ██╔╝██╔══██╗██╔════╝██╔══██╗  ██║   ██║██║████╗ ████║
███████║ ╚████╔╝ ██████╔╝█████╗  ██████╔╝  ██║   ██║██║██╔████╔██║
██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══╝  ██╔══██╗  ╚██╗ ██╔╝██║██║╚██╔╝██║
██║  ██║   ██║   ██║     ███████╗██║  ██║   ╚████╔╝ ██║██║ ╚═╝ ██║
╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚══════╝╚═╝  ╚═╝    ╚═══╝  ╚═╝╚═╝     ╚═╝]],
        },
      },
      picker = {
        sources = {
          explorer = {
            layout = {
              preset = "sidebar",
              preview = false,
              layout = {
                width = 24,
                min_width = 24,
              },
            },
            -- Zed-style explorer keymaps
            actions = {
              explorer_open_system = function(picker)
                local item = picker:current()
                if item then
                  vim.ui.open(item.file or item.dir)
                end
              end,
            },
            keys = {
              ["l"]     = "confirm",
              ["a"]     = "explorer_add",
              ["A"]     = { "explorer_add", config = { dir = true } },
              ["y"]     = "explorer_copy",
              ["p"]     = "explorer_paste",
              ["x"]     = "explorer_cut",
              ["d"]     = "explorer_del",
              ["r"]     = "explorer_rename",
              ["e"]     = "explorer_open_system",
            },
          },
        },
      },
    },
  },
  {
    "folke/snacks.nvim",
    opts = function()
      -- snacks.image probes the terminal with an escape sequence. Inside tmux with
      -- extended-keys "always", the reply gets typed into the buffer as text; upstream
      -- only handles "on" (folke/snacks.nvim#2332), so skip the probe for ghostty.
      if vim.env.TMUX and vim.env.GHOSTTY_RESOURCES_DIR then
        local term = require("snacks.image.terminal")
        term._terminal = { terminal = "ghostty", version = "unknown" }
        term.transform = function(data)
          return ("\027Ptmux;" .. data:gsub("\027", "\027\027")) .. "\027\\"
        end
      end
    end,
  },
}
