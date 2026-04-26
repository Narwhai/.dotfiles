return {
  { -- You can easily change to a different colorscheme.
    -- Change the name of the colorscheme plugin below, and then
    -- change the command in the config to whatever the name of that colorscheme is.
    --
    -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
    'hylophile/flatwhite.nvim',
    name = 'flatwhite',
    priority = 1000,
    config = function()
      require('flatwhite').setup {
        transparent_bg = true,
      }
      -- vim.cmd.colorscheme 'flatwhite'
    end,
  },
}
