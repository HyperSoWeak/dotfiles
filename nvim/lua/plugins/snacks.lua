return {
  {
    "folke/snacks.nvim",
    opts = {
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
}
