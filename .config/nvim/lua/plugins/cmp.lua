return {
  { -- Autocompletion
    'saghen/blink.cmp',
    event = 'InsertEnter',
    version = '1.*',
    dependencies = {
      {
        'L3MON4D3/LuaSnip',
        build = (function()
          if vim.fn.has 'win32' == 1 or vim.fn.executable 'make' == 0 then
            return
          end
          return 'make install_jsregexp'
        end)(),
        dependencies = {
          -- {
          --   'rafamadriz/friendly-snippets',
          --   config = function()
          --     require('luasnip.loaders.from_vscode').lazy_load()
          --   end,
          -- },
        },
      },
    },
    opts = {
      snippets = { preset = 'luasnip' },
      appearance = {
        use_nvim_cmp_as_default = true,
      },
      completion = {
        list = {
          selection = {
            preselect = false,
            auto_insert = false,
          },
        },
      },
      sources = {
        default = { 'lsp', 'path', 'snippets', 'buffer' },
      },
      keymap = {
        preset = 'default',
        ['<C-n>'] = { 'select_next' },
        ['<C-p>'] = { 'select_prev' },
        ['<C-b>'] = { 'scroll_documentation_up' },
        ['<C-f>'] = { 'scroll_documentation_down' },
        ['<C-y>'] = { 'select_and_accept' },
        ['<C-Space>'] = { 'show' },
        ['<Tab>'] = {
          'snippet_forward',
          function()
            local suggestion = require('copilot.suggestion')
            if suggestion.is_visible() then
              -- copilot.lua passes 0 to apply_text_edits which breaks on Neovim 0.11+
              -- monkey-patch it to use the current buffer number
              local orig = vim.lsp.util.apply_text_edits
              vim.lsp.util.apply_text_edits = function(edits, bufnr, ...)
                if bufnr == 0 then
                  bufnr = vim.api.nvim_get_current_buf()
                end
                return orig(edits, bufnr, ...)
              end
              suggestion.accept()
              vim.lsp.util.apply_text_edits = orig
              return true
            end
          end,
          function()
            return require('sidekick').nes_jump_or_apply()
          end,
          'fallback',
        },
      },
    },
    config = function(_, opts)
      local blink = require 'blink.cmp'
      local luasnip = require 'luasnip'

      luasnip.config.setup {}
      blink.setup(opts)

      vim.keymap.set({ 'i', 's' }, '<C-l>', function()
        if luasnip.expand_or_locally_jumpable() then
          luasnip.expand_or_jump()
        end
      end, { silent = true })

      vim.keymap.set({ 'i', 's' }, '<C-h>', function()
        if luasnip.locally_jumpable(-1) then
          luasnip.jump(-1)
        end
      end, { silent = true })
    end,
  },
}
-- vim: ts=2 sts=2 sw=2 et
