return {
	{
		"ThePrimeagen/harpoon",
		branch = "harpoon2",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function ()
			local status_ok, harpoon = pcall(require, "harpoon")
			if not status_ok then
				return
			end
			harpoon:setup()

			-- picker function
			local normalize_list = function(t)
				local normalized = {}
				for _, v in pairs(t) do
					if v ~= nil then
						table.insert(normalized, v)
					end
				end
				return normalized
			end

			-- keymaps
			vim.keymap.set("n", "<leader>a", function() harpoon:list():add() end)
			vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)
			vim.keymap.set("n", "<A-e>", function()
				Snacks.picker({
					finder = function()
						local file_paths = {}
						local list = normalize_list(harpoon:list().items)
						for i, item in ipairs(list) do
							table.insert(file_paths, { text = item.value, file = item.value })
						end
						return file_paths
					end,
					win = {
						input = {
							keys = { ["dd"] = { "harpoon_delete", mode = { "n", "x" } } },
						},
						list = {
							keys = { ["dd"] = { "harpoon_delete", mode = { "n", "x" } } },
						},
					},
					actions = {
						harpoon_delete = function(picker, item)
							local to_remove = item or picker:selected()
							harpoon:list():remove({ value = to_remove.text })
							harpoon:list().items = normalize_list(harpoon:list().items)
							picker:find({ refresh = true })
						end,
					},
				})
			end)
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
	}
}
