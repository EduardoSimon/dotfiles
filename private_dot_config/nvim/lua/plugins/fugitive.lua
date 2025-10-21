return {
  "tpope/vim-fugitive",
  config = function()
    vim.keymap.set('n', '<leader>gb', ':Git blame<CR>', { desc = 'Fugitive Git blame' })
    vim.keymap.set('n', '<leader>gvd', ':Gvdiffsplit master<CR>', { desc = 'Fugitive Git vertical diff side by side with master' })
  end
}
