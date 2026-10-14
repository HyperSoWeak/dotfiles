return {
  {
    "lewis6991/gitsigns.nvim",
    opts = function(_, opts)
      local parent_on_attach = opts.on_attach

      opts.on_attach = function(buffer)
        if parent_on_attach then
          parent_on_attach(buffer)
        end

        vim.keymap.set("n", "do", function()
          local preview = require("gitsigns.actions.preview")
          local bufnr = vim.api.nvim_get_current_buf()

          if preview.has_preview_inline(bufnr) then
            local ns = vim.api.nvim_create_namespace("gitsigns_preview_inline")
            vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
            if vim.api.nvim__ns_set then
              vim.api.nvim__ns_set(ns, { wins = {} })
            end
            return
          end

          require("gitsigns").preview_hunk_inline()
        end, { buffer = buffer, desc = "Toggle Hunk Preview", silent = true })
      end
    end,
  },
}
