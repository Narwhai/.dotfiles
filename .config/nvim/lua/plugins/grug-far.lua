return {
  {
    'MagicDuck/grug-far.nvim',
    opts = { headerMaxWidth = 80 },
    cmd = 'GrugFar',
    keys = {
      {
        '<leader>rr',
        function()
          local grug = require 'grug-far'
          local ext = vim.bo.buftype == '' and vim.fn.expand '%:e'
          grug.open {
            transient = true,
            prefills = {
              filesFilter = ext and ext ~= '' and '*.' .. ext or nil,
            },
          }
        end,
        mode = { 'n', 'v' },
        desc = 'Search and Replace',
      },
    },
  },
  -- { 'MagicDuck/grug-far.nvim',
  --   config = function()
  --     -- optional setup call to override plugin options
  --     -- alternatively you can set options with vim.g.grug_far = { ... }
  --     require('grug-far').setup {
  --       opts = { headerMaxWidth = 80 },
  --       -- options, see Configuration section below
  --       -- there are no required options atm
  --       -- engine = 'ripgrep' is default, but 'astgrep' or 'astgrep-rules' can
  --       -- be specified
  --     }
  --   end,
  -- },
}
