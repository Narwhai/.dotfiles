return {
  { -- Set lualine as statusline
    'nvim-lualine/lualine.nvim',
    -- See `:help lualine.txt`
    event = 'BufReadPost',
    opts = function()
      return {
        options = {
          icons_enabled = true,
          component_separators = '|',
          section_separators = '',
          theme = 'auto',
        },
        sections = {
          lualine_a = { 'mode' },
          lualine_b = { 'branch', 'diff', 'diagnostics' },
          lualine_c = {
            'filename',
            -- Copilot status via sidekick
            {
              function()
                return ' '
              end,
              color = function()
                local ok, status = pcall(function()
                  return require('sidekick.status').get()
                end)
                if ok and status then
                  return status.kind == 'Error' and 'DiagnosticError'
                    or status.busy and 'DiagnosticWarn'
                    or 'Special'
                end
              end,
              cond = function()
                local ok, status = pcall(function()
                  return require('sidekick.status')
                end)
                return ok and status and status.get() ~= nil
              end,
            },
          },
          lualine_x = {
            -- CLI session status via sidekick
            {
              function()
                local ok, status = pcall(function()
                  return require('sidekick.status').cli()
                end)
                if ok and status then
                  return ' ' .. (#status > 1 and #status or '')
                end
                return ''
              end,
              cond = function()
                local ok, result = pcall(function()
                  return #require('sidekick.status').cli() > 0
                end)
                return ok and result
              end,
              color = function()
                return 'Special'
              end,
            },
            'encoding',
            'fileformat',
            'filetype',
          },
          lualine_y = { 'progress' },
          lualine_z = { 'location' },
        },
      }
    end,
  },
}
