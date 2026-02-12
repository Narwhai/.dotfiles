vim.api.nvim_create_autocmd('OptionSet', {
  pattern = 'background',
  callback = function()
    vim.cmd 'colorscheme flexoki'
  end,
})
