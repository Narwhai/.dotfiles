return {
  { -- You can easily change to a different colorscheme.
    -- Change the name of the colorscheme plugin below, and then
    -- change the command in the config to whatever the name of that colorscheme is.
    --
    -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
    'nuvic/flexoki-nvim',
    name = 'flexoki',
    priority = 1000,
    config = function()
      require('flexoki').setup {
        variant = 'moon',
        dim_inactive_windows = false,
        extend_background_behind_borders = true,

        enable = {
          terminal = true,
        },
        -- palette = {
        --   -- Override the builtin palette per variant
        --   moon = {
        --     base = '#100f0f',
        --     overlay = '#1c1b1a',
        --   },
        -- },
        highlight_groups = {
          Normal = { bg = 'none' },
          NormalFloat = { bg = 'none' },
          FloatBorder = { bg = 'none' },
          Pmenu = { bg = 'none' },
        },
      }
      vim.cmd.colorscheme 'flexoki'
      -- transparent background
      -- vim.api.nvim_set_hl(0, 'Normal', { bg = 'none' })
      -- vim.api.nvim_set_hl(0, 'NormalFloat', { bg = 'none' })
      -- vim.api.nvim_set_hl(0, 'FloatBorder', { bg = 'none' })
      -- vim.api.nvim_set_hl(0, 'Pmenu', { bg = 'none' })
    end,
  },
}
