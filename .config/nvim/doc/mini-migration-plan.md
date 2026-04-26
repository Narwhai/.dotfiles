# Mini-focused migration plan

This plan keeps the existing architecture (lazy.nvim + modular plugins) while swapping in more `mini.*` modules where they make sense. It’s ordered from “low risk” to “more tradeoffs.”

## Phase 1: Low-risk swaps (near 1:1)
1. **which-key → `mini.clue`**
   - Replace `lua/plugins/which-key.lua` with a `mini.clue` setup.
   - Port existing group labels (e.g., `<leader>g`, `<leader>f`, etc.) into `mini.clue` triggers and clues.
   - Outcome: lightweight key-hinting without the full which-key UI.

2. **indent-blankline/indent_line → `mini.indentscope`**
   - You already use `mini.indentscope` in `lua/plugins/mini.lua`.
   - Remove `lua/plugins/indent_line.lua` and plugin registration (if enabled).
   - Outcome: single indentation visualization source.

3. **gitsigns → `mini.diff` (overlay only)**
   - `mini.diff` is already enabled; wire keymaps for hunk navigation if desired.
   - Remove `lua/plugins/gitsigns.lua` once you’re OK losing hunk staging/preview.
   - Outcome: a lightweight diff overlay instead of line-level git UX.

## Phase 2: Mostly-good swaps (tradeoffs)
4. **oil.nvim → `mini.files`**
   - `mini.files` is already configured. Ensure all desired keymaps are in `mini.lua`.
   - Remove `lua/plugins/oil.lua` if you’re not relying on Oil-specific features.

5. **persistence.nvim → `mini.sessions`**
   - `mini.sessions` is already enabled with `autowrite = true`.
   - Remove `lua/plugins/persistence.lua` when you’re satisfied with session behavior.

6. **harpoon → `mini.visits` + `mini.pick`**
   - Use `mini.visits` to track frequently used files.
   - Use `mini.pick` to list and jump.
   - Tradeoff: you lose Harpoon’s exact UX and quick‑slot behavior.

7. **nvim-autopairs → `mini.pairs`**
   - Enable `mini.pairs` in `lua/plugins/mini.lua`.
   - Tradeoff: fewer integration hooks than nvim-autopairs.

## Phase 3: Optional additions (mini-first UX)
8. **Add `mini.pick`**
   - Replace telescope/snacks pickers for simple file/grep workflows.
   - Tradeoff: fewer integrations vs Telescope.

9. **Add `mini.bufremove`**
   - Safer buffer deletion without closing windows.

10. **Add `mini.splitjoin`**
   - Split/join lists and arguments quickly.

11. **Add `mini.bracketed`**
   - Extra motions for quick navigation (buffers, windows, quickfix, etc.).

12. **Add `mini.tabline`**
   - If you want a minimal tabline without another plugin.

## Plugins likely to keep (no mini replacement)
- `nvim-lspconfig`, `conform`, `lint`, `blink.cmp`, `noice`, `trouble`, `aerial`, `treesitter`, `dadbod`.

## Suggested order of changes
1. which-key → mini.clue
2. gitsigns → mini.diff
3. oil → mini.files
4. persistence → mini.sessions
5. harpoon → mini.visits + mini.pick
6. autopairs → mini.pairs
7. optional: mini.pick, mini.bufremove, mini.splitjoin, mini.bracketed, mini.tabline
