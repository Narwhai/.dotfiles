return {
  {
    'gbprod/substitute.nvim',
    config = function()
      require('substitute').setup {
        on_substitute = nil,
        yank_substituted_text = false,
        preserve_cursor_position = false,
        highlight_substituted_text = {
          enabled = true,
          timer = 500,
        },
        range = {
          prefix = 's',
          prompt_current_text = false,
          confirm = false,
          complete_word = false,
          motion1 = false,
          motion2 = false,
          suffix = '',
        },
        exchange = {
          motion = false,
          use_esc_to_cancel = true,
          preserve_cursor_position = false,
        },
      }
      vim.keymap.set('n', 's', require('substitute').operator, { noremap = true })
      vim.keymap.set('n', 'ss', require('substitute').line, { noremap = true })
      vim.keymap.set('n', 'S', require('substitute').eol, { noremap = true })
      vim.keymap.set('x', 's', require('substitute').visual, { noremap = true })
    end,
  },
}
