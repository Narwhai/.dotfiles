return {
  {
    'ThePrimeagen/harpoon',
    branch = 'harpoon2',
    dependencies = { 'nvim-lua/plenary.nvim' },

    config = function()
      -- local harpoon = require ('harpoon').setup {}

      local harpoon = require 'harpoon'
      harpoon:setup()

      local conf = require('telescope.config').values
      local function toggle_telescope(harpoon_files)
        local file_paths = {}
        for _, item in ipairs(harpoon_files.items) do
          table.insert(file_paths, item.value)
        end

        require('telescope.pickers')
          .new({}, {
            prompt_title = 'Harpoon',
            finder = require('telescope.finders').new_table {
              results = file_paths,
            },
            previewer = conf.file_previewer {},
            sorter = conf.generic_sorter {},
          })
          :find()
      end

      vim.keymap.set('n', '<leader>a', function()
        harpoon:list():append()
      end)

      vim.keymap.set('n', '<C-e>', function()
        harpoon.ui:toggle_quick_menu(harpoon:list())
      end)

      vim.keymap.set('n', '<A-e>', function()
        toggle_telescope(harpoon:list())
      end, { desc = 'Open harpoon window' })

      vim.keymap.set('n', '<A-h>', function()
        harpoon:list():select(1)
      end)
      vim.keymap.set('n', '<A-j>', function()
        harpoon:list():select(2)
      end)
      vim.keymap.set('n', '<A-k>', function()
        harpoon:list():select(3)
      end)
      vim.keymap.set('n', '<A-l>', function()
        harpoon:list():select(4)
      end)
      vim.keymap.set('n', '<A-y>', function()
        harpoon:list():select(5)
      end)
      vim.keymap.set('n', '<A-u>', function()
        harpoon:list():select(6)
      end)
      vim.keymap.set('n', '<A-i>', function()
        harpoon:list():select(7)
      end)
      vim.keymap.set('n', '<A-o>', function()
        harpoon:list():select(8)
      end)

      -- Toggle previous & next buffers stored within Harpoon list
      vim.keymap.set('n', '<C-S-P>', function()
        harpoon:list():prev()
      end)
      vim.keymap.set('n', '<C-S-N>', function()
        harpoon:list():next()
      end)
    end,
  },
}
