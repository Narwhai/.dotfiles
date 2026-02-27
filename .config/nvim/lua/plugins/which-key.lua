return {
  { -- Useful plugin to show you pending keybinds.
    'folke/which-key.nvim',
    event = 'VimEnter', -- Sets the loading event to 'VimEnter'
    opts = {
      preset = 'helix',
      spec = {
        {
          mode = { 'n', 'v' },
          { '<leader>c', group = 'code' },
          { '<leader>d', group = 'document' },
          { '<leader>db', group = 'database' },
          { '<leader>dp', group = 'profiler' },
          { '<leader>r', group = '[R]ename' },
          { '<leader>f', group = 'file/find' },
          { '<leader>g', group = 'git' },
          { '<leader>gh', group = 'hunks' },
          { '<leader>s', group = 'search' },
          { '<leader>u', group = 'ui', icon = { icon = '󰙵 ', color = 'cyan' } },
          { '[', group = 'prev' },
          { ']', group = 'next' },
          { 'g', group = 'goto' },
          { 'gs', group = 'surround' },
          { 'z', group = 'fold' },
          {
            '<leader>b',
            group = 'buffer',
            expand = function()
              return require('which-key.extras').expand.buf()
            end,
          },
          {
            '<leader>w',
            group = 'windows',
            proxy = '<c-w>',
            expand = function()
              return require('which-key.extras').expand.win()
            end,
          },
          -- better descriptions
          { 'gx', desc = 'Open with system app' },
        },
      },
    },
  },
}
