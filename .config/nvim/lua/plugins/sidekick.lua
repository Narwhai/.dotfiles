return {
  {
    'folke/sidekick.nvim',
    event = 'BufReadPost',
    opts = {
      nes = {
        diff = {
          inline = 'words',
          show = 'always',
        },
        signs = true,
      },
      cli = {
        watch = true,
        win = {
          layout = 'right',
          split = {
            width = 80,
          },
        },
        mux = {
          backend = 'tmux',
          enabled = true,
        },
        picker = 'snacks',
      },
    },
    -- stylua: ignore
    keys = {
      -- NES: Tab to jump/apply next edit suggestion
      {
        '<tab>',
        function()
          if not require('sidekick').nes_jump_or_apply() then
            return '<Tab>'
          end
        end,
        expr = true,
        desc = 'Goto/Apply Next Edit Suggestion',
      },
      -- CLI: toggle focus
      {
        '<c-.>',
        function() require('sidekick.cli').focus() end,
        desc = 'Sidekick Focus',
        mode = { 'n', 't', 'i', 'x' },
      },
      -- CLI: toggle
      { '<leader>aa', function() require('sidekick.cli').toggle() end, desc = 'Sidekick Toggle CLI' },
      -- CLI: select tool
      { '<leader>as', function() require('sidekick.cli').select() end, desc = 'Sidekick Select CLI' },
      -- CLI: detach session
      { '<leader>ad', function() require('sidekick.cli').close() end, desc = 'Sidekick Detach CLI' },
      -- CLI: send context
      { '<leader>at', function() require('sidekick.cli').send({ msg = '{this}' }) end, mode = { 'x', 'n' }, desc = 'Sidekick Send This' },
      { '<leader>af', function() require('sidekick.cli').send({ msg = '{file}' }) end, desc = 'Sidekick Send File' },
      { '<leader>av', function() require('sidekick.cli').send({ msg = '{selection}' }) end, mode = { 'x' }, desc = 'Sidekick Send Selection' },
      -- CLI: prompts
      { '<leader>ap', function() require('sidekick.cli').prompt() end, mode = { 'n', 'x' }, desc = 'Sidekick Select Prompt' },
      -- CLI: direct tool shortcuts
      { '<leader>ac', function() require('sidekick.cli').toggle({ name = 'claude', focus = true }) end, desc = 'Sidekick Toggle Claude' },
      { '<leader>ai', function() require('sidekick.cli').toggle({ name = 'pi', focus = true }) end, desc = 'Sidekick Toggle Pi' },
    },
  },
}
