# Dotfiles

Personal application configs managed as one GNU Stow package. Files under
`.config/` map to `~/.config/`; `.zshenv` maps to `~/.zshenv`. Selected files under
`.pi/agent/` map to `~/.pi/agent/`.

## Apply

With GNU Stow installed, review the dry run before applying:

```sh
cd "$HOME/.dotfiles"
stow --simulate --verbose --no-folding --target="$HOME" .
stow --verbose --no-folding --target="$HOME" .
```

`--no-folding` creates individual file links instead of linking whole directories,
so ignored metadata and runtime files cannot leak through directory symlinks.
Existing correct links are left in place.

If a regular file causes a conflict, back it up and compare it with the repo's
version before replacing its location with a link. To import a live config, copy
it into the matching repo path, verify that the contents match, then move the
original outside the target tree before stowing. Do not use blanket `--adopt`:
it can overwrite repository files with target contents.

## Current desktop settings

- Niri, Ghostty, Fish, and Neovim use the configs in this repo.
- Fish loads `.config/ohmyposh/config.toml`; its frozen theme/key bindings and
  Flexoki themes are also included.
- Native Noctalia v5 uses `.config/noctalia/config.toml` and the custom palettes.
  Legacy Noctalia JSON settings and downloaded plugin assets remain local.
- Darkman's location settings remain local at `~/.config/darkman/config.yaml`;
  that file is excluded from both Git and Stow.

These are personal configs: review home paths, monitor names, and location settings
before sharing them or applying them on another machine. Programs, fonts, downloaded
plugins, wallpapers, credentials, and other application data are not installed by
Stow. Other apps' settings in `~/.config/` are not automatically covered by this repo.

## Pi configuration

Only these reviewed global Pi files are managed:

- `.pi/agent/AGENTS.md` and `.pi/agent/settings.json`
- `.pi/agent/extensions/auto-theme.ts`, `papercuts.ts`, and `whimsical.ts`
- `.pi/agent/themes/flexoki-dark.json` and `flexoki-light.json`

Both ignore files use an explicit allowlist. Adding another Pi config requires
reviewing it and updating both lists and the deployment tests. Keep credentials
out of the managed settings and extension files.

Everything else stays local: authentication, sessions, trust decisions, model/MCP
configuration, `modes.json`, logs, papercut records, installed packages, backups,
and project `.pi` metadata. The existing `~/.pi/.git` backup repository is not moved
or deployed; only the selected files become symlinks.

On another machine, install Pi separately and apply Stow with `--no-folding` as
shown above. Sign in separately with `/login`; `pi update --extensions` reconciles
the package declarations in the managed settings without versioning downloaded
packages. After editing Pi settings or resources, use `/reload` or restart Pi.

## Local state

`.gitignore` controls version control; `.stow-local-ignore` separately controls
deployment. Both exclude project Pi metadata and unselected global Pi files,
generated caches/history, the root `.tool-versions`, and Darkman's private location
file. The nested Neovim `.tool-versions` remains managed.

Generated files already tracked by Git must also be untracked with
`git rm --cached` after adding ignore rules; this leaves their local copies intact.
Keep runtime copies in `~/.config/` as regular files rather than links into the repo.
Do not import all of `~/.config/`: many applications store caches and secrets there.

## Verify

```sh
bash tests/stow.sh
```

This tests deployment into temporary targets, repeatability, and ignore rules
without changing the live home directory.
