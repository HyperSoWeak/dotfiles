-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.api.nvim_create_user_command("W", function()
    vim.cmd("write !sudo tee % >/dev/null")
    vim.cmd("edit!")
end, {})

-- Format (Zed: alt-shift-f)
vim.keymap.set({ "n", "v" }, "<A-S-f>", function()
    vim.lsp.buf.format({ async = true })
end, { desc = "Format" })

-- Toggle soft wrap (Zed: alt-z)
vim.keymap.set("n", "<A-z>", "<cmd>set wrap!<cr>", { desc = "Toggle Wrap" })

-- Toggle terminal (Zed: ctrl-j toggle bottom dock)
-- Overrides LazyVim's <C-j> window-down navigation
vim.keymap.set({ "n", "t" }, "<C-j>", function()
    Snacks.terminal.toggle()
end, { desc = "Toggle Terminal" })

-- Window navigation (Recommended alternatives since alt-hjkl is used by tmux)
-- Option 1: <leader>w + hjkl (Space + w + h/j/k/l - LazyVim default window prefix)
-- Option 2: <leader> + hjkl (Space + h/j/k/l - fast, overrides <leader>l Lazy UI)
-- Option 3: <S-Left/Down/Up/Right> (Shift + Arrows - intuitive, no conflicts)
vim.keymap.set("n", "<leader>wh", "<C-w>h", { desc = "Go to Left Window" })
vim.keymap.set("n", "<leader>wl", "<C-w>l", { desc = "Go to Right Window" })
vim.keymap.set("n", "<leader>wj", "<C-w>j", { desc = "Go to Lower Window" })
vim.keymap.set("n", "<leader>wk", "<C-w>k", { desc = "Go to Upper Window" })

-- Wrap Snacks.explorer.open to maintain the opened <path> across toggles
local orig_explorer = Snacks.explorer.open
local last_cwd = nil
Snacks.explorer.open = function(opts)
    opts = opts or {}
    local picker = Snacks.picker.get({ source = "explorer" })[1]
    if picker then
        last_cwd = picker:cwd()
        picker:close()
        return
    end
    if not opts.cwd and last_cwd then
        opts.cwd = last_cwd
    end
    return orig_explorer(opts)
end

-- Focus file explorer / code buffer (Zed: ctrl-h toggle focus)
-- Overrides LazyVim's <C-h> window-left navigation
vim.keymap.set("n", "<C-h>", function()
    local picker = Snacks.picker.get({ source = "explorer" })[1]
    if picker then
        if picker:is_focused() then
            if vim.api.nvim_win_is_valid(picker.main) then
                vim.api.nvim_set_current_win(picker.main)
            else
                vim.cmd("wincmd p")
            end
        else
            picker:focus()
        end
    else
        Snacks.explorer()
    end
end, { desc = "Toggle Explorer Focus" })

-- File finder (Zed: ctrl-p)
vim.keymap.set("n", "<C-p>", function()
    Snacks.picker.files()
end, { desc = "Find Files" })

-- Close active buffer (Zed: alt-ctrl-w)
vim.keymap.set("n", "<A-C-w>", "<cmd>bd<cr>", { desc = "Close Buffer" })

-- Next / prev buffer (Zed: alt-o / alt-i)
vim.keymap.set("n", "<A-o>", "<cmd>bnext<cr>", { desc = "Next Buffer" })
vim.keymap.set("n", "<A-i>", "<cmd>bprev<cr>", { desc = "Prev Buffer" })

-- Move lines in visual mode (Zed: shift-k / shift-j in visual)
vim.keymap.set("v", "K", "<cmd>m '<-2<cr>gv=gv", { desc = "Move Lines Up" })
vim.keymap.set("v", "J", "<cmd>m '>+1<cr>gv=gv", { desc = "Move Lines Down" })

-- Rename symbol (Zed: gm)
vim.keymap.set("n", "gm", vim.lsp.buf.rename, { desc = "Rename Symbol" })

-- Swap jump backward / forward to match Zed (Zed ctrl-i = back, ctrl-o = forward)
-- Neovim default is opposite: <C-o> = back, <C-i> = forward
-- noremap ensures these reference the built-ins, not each other
vim.keymap.set("n", "<C-i>", "<C-o>", { desc = "Jump Backward", noremap = true })
vim.keymap.set("n", "<C-o>", "<C-i>", { desc = "Jump Forward", noremap = true })
