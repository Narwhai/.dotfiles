return {
  { -- Highlight, edit, and navigate code
    'nvim-treesitter/nvim-treesitter',
    build = ':TSUpdate',
    opts = {
      ensure_installed = {
        'bash',
        'html',
        'lua',
        'markdown',
        'vim',
        'vimdoc',
        'typescript',
        'javascript',
        'css',
        'angular',
      },
      -- Autoinstall languages that are not installed
      auto_install = true,
      highlight = {
        enable = true,
        -- Some languages depend on vim's regex highlighting system (such as Ruby) for indent rules.
        --  If you are experiencing weird indenting issues, add the language to
        --  the list of additional_vim_regex_highlighting and disabled languages for indent.
        additional_vim_regex_highlighting = { 'ruby' },
      },
      indent = { enable = true, disable = { 'ruby' } },
    },
    config = function(_, opts)
      -- [[ Configure Treesitter ]] See `:help nvim-treesitter`

      require('nvim-treesitter.query_predicates')

      local query = require('vim.treesitter.query')
      local directive_opts = vim.fn.has('nvim-0.10') == 1 and { force = true, all = false } or true

      local html_script_type_languages = {
        importmap = 'json',
        module = 'javascript',
        ['application/ecmascript'] = 'javascript',
        ['text/ecmascript'] = 'javascript',
      }

      local non_filetype_match_injection_language_aliases = {
        ex = 'elixir',
        pl = 'perl',
        sh = 'bash',
        ts = 'typescript',
        uxn = 'uxntal',
      }

      local function capture_node(match, capture_id)
        local nodes = match[capture_id]
        if nodes == nil then
          return nil
        end
        if vim.islist(nodes) then
          return nodes[1]
        end
        return nodes
      end

      local function parser_from_markdown_info_string(injection_alias)
        local match = vim.filetype.match({ filename = 'a.' .. injection_alias })
        return match or non_filetype_match_injection_language_aliases[injection_alias] or injection_alias
      end

      query.add_directive('set-lang-from-mimetype!', function(match, _, bufnr, pred, metadata)
        local node = capture_node(match, pred[2])
        if node == nil then
          return
        end
        local type_attr_value = vim.treesitter.get_node_text(node, bufnr)
        local configured = html_script_type_languages[type_attr_value]
        if configured ~= nil then
          metadata['injection.language'] = configured
          return
        end
        local parts = vim.split(type_attr_value, '/', {})
        metadata['injection.language'] = parts[#parts]
      end, directive_opts)

      query.add_directive('set-lang-from-info-string!', function(match, _, bufnr, pred, metadata)
        local node = capture_node(match, pred[2])
        if node == nil then
          return
        end
        local injection_alias = vim.treesitter.get_node_text(node, bufnr):lower()
        metadata['injection.language'] = parser_from_markdown_info_string(injection_alias)
      end, directive_opts)

      ---@diagnostic disable-next-line: missing-fields
      require('nvim-treesitter.configs').setup(opts)

      -- There are additional nvim-treesitter modules that you can use to interact
      -- with nvim-treesitter. You should go explore a few and see what interests you:
      --
      --    - Incremental selection: Included, see `:help nvim-treesitter-incremental-selection-mod`
      --    - Show your current context: https://github.com/nvim-treesitter/nvim-treesitter-context
      --    - Treesitter + textobjects: https://github.com/nvim-treesitter/nvim-treesitter-textobjects
    end,
  },
  -- {
  --   'nvim-treesitter/nvim-treesitter-context',
  -- },
}
-- vim: ts=2 sts=2 sw=2 et
