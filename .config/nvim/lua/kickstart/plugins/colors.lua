-- return {
--   { -- You can easily change to a different colorscheme.
--     -- Change the name of the colorscheme plugin below, and then
--     -- change the command in the config to whatever the name of that colorscheme is.
--     --
--     -- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
--     'catppuccin/nvim',
--     name = 'catppuccin',
--     priority = 1000,
--     config = function()
--       require('catppuccin').setup {
--         flavour = 'mocha',
--         transparent_background = true,
--       }
--       -- vim.cmd.colorscheme 'catppuccin'
--     end,
--   }
-- }
return {
  "rose-pine/neovim",
  name = "rose-pine",
  priority = 1000,
  config = function()
    require('rose-pine').setup {
      variant = 'moon',
      styles = {
        bold = false,
        italic = false,
        transparency = true,
      }
    }
    vim.cmd.colorscheme 'rose-pine'
  end,
  -- 'folke/tokyonight.nvim',
  --  priority = 1000, -- Make sure to load this before all the other start plugins.
  --  init = function()
    --   -- Load the colorscheme here.
    --   -- Like many other themes, this one has different styles, and you could load
    --   -- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
    --   vim.cmd.colorscheme 'tokyonight'
    --
    --   -- You can configure highlights by doing something like:
    --   vim.cmd.hi 'Comment gui=none'
    -- end,
    -- "nyoom-engineering/oxocarbon.nvim",
    --   priority = 1000,
    --   config = function()
      --     vim.opt.background = 'dark'
      --     vim.cmd.colorscheme 'oxocarbon'
      --   end,
      -- "nyngwang/nvimgelion",
      --   priority = 1000,
      --   config = function()
        --     -- vim.opt.background = 'dark'
        --     vim.cmd.colorscheme 'nvimgelion'
        --   end,
      }
      -- vim: ts=2 sts=2 sw=2 et
