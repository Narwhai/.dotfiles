return {
  {
    'tpope/vim-dadbod',
    cmd = { 'DB', 'DBUI', 'DBUIToggle', 'DBUIAddConnection', 'DBUIFindBuffer' },
  },
  {
    'kristijanhusak/vim-dadbod-completion',
    ft = { 'sql', 'mysql', 'plsql' },
    dependencies = { 'tpope/vim-dadbod' },
    config = function()
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'sql', 'mysql', 'plsql' },
        callback = function()
          vim.bo.omnifunc = 'vim_dadbod_completion#omni'
        end,
      })
    end,
  },
  {
    'kristijanhusak/vim-dadbod-ui',
    cmd = { 'DBUI', 'DBUIToggle', 'DBUIAddConnection', 'DBUIFindBuffer' },
    dependencies = {
      'tpope/vim-dadbod',
      'kristijanhusak/vim-dadbod-completion',
    },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_save_location = vim.fn.stdpath('data') .. '/dadbod_ui'
    end,
    config = function()
      vim.keymap.set('n', '<leader>du', '<cmd>DBUIToggle<cr>', { desc = 'DB: Toggle UI' })
      vim.keymap.set('n', '<leader>df', '<cmd>DBUIFindBuffer<cr>', { desc = 'DB: Find buffer' })
      vim.keymap.set('n', '<leader>da', '<cmd>DBUIAddConnection<cr>', { desc = 'DB: Add connection' })
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
