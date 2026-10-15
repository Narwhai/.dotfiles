#!/usr/bin/env bash
set -euo pipefail

repo="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"
sandbox="$(mktemp -d)"
trap 'rm -rf -- "$sandbox"' EXIT
mkdir -p "$sandbox/home" "$sandbox/target" "$sandbox/package" "$sandbox/fixture-target"
export HOME="$sandbox/home"

assert_link() {
  if [[ ! -L "$2" || ! "$1" -ef "$2" ]]; then
    printf 'Expected link: %s -> %s\n' "$2" "$1" >&2
    return 1
  fi
}

assert_absent() {
  if [[ -e "$1" || -L "$1" ]]; then
    printf 'Unexpected deployed path: %s\n' "$1" >&2
    return 1
  fi
}

deploy() {
  stow --dir="$1" --target="$2" --no-folding .
}

deploy "$repo" "$sandbox/target"
for path in \
  .zshenv .config/niri/config.kdl .config/ghostty/config .config/fish/config.fish \
  .config/fish/conf.d/fish_frozen_theme.fish .config/fish/conf.d/fish_frozen_key_bindings.fish \
  .config/fish/themes/Flexoki-Dark.theme .config/fish/themes/Flexoki-Light.theme \
  .config/noctalia/config.toml .config/noctalia/palettes/Flexoki.json \
  .config/ohmyposh/config.toml \
  .config/nvim/init.lua .config/nvim/.luarc.json .config/nvim/.tool-versions \
  .config/nvim/doc/mini-migration-plan.md; do
  assert_link "$repo/$path" "$sandbox/target/$path"
done
for path in .git .gitignore README.md .stow-local-ignore tests .pi .tool-versions \
  .config/nvim/.pi .config/zsh/.zcompdump .config/rofi/global/history.txt \
  .config/darkman/config.yaml; do
  assert_absent "$sandbox/target/$path"
done
before="$(find "$sandbox/target" -type l -printf '%P -> %l\n' | LC_ALL=C sort)"
deploy "$repo" "$sandbox/target"
after="$(find "$sandbox/target" -type l -printf '%P -> %l\n' | LC_ALL=C sort)"
if [[ "$before" != "$after" ]]; then
  printf 'Repeated deployment changed the symlink layout.\n' >&2
  exit 1
fi

# Exercise exclusions even in a clean checkout without local caches or metadata.
cp -- "$repo/.stow-local-ignore" "$sandbox/package/.stow-local-ignore"
ignored=(
  .git/config .gitignore .gitmodules README.md LICENSE COPYING .pi/state .tool-versions
  tests/stow.sh .config/nvim/.pi/state .config/zsh/.zcompdump .config/zsh/.zcompdump.host
  .config/ranger/__pycache__/module.pyc .config/ranger/module.pyo
  .config/rofi/global/history.txt .config/darkman/config.yaml
)
managed=(.zshenv .config/app/config .config/nvim/.tool-versions .config/nvim/README.md)
for path in "${ignored[@]}" "${managed[@]}"; do
  mkdir -p -- "$(dirname -- "$sandbox/package/$path")"
  printf 'fixture\n' > "$sandbox/package/$path"
done
mkdir -p "$sandbox/fixture-target/.config/zsh" "$sandbox/fixture-target/.config/darkman"
printf 'local tool versions\n' > "$sandbox/fixture-target/.tool-versions"
printf 'local completion cache\n' > "$sandbox/fixture-target/.config/zsh/.zcompdump"
printf 'private local location\n' > "$sandbox/fixture-target/.config/darkman/config.yaml"
cp -- "$sandbox/fixture-target/.tool-versions" "$sandbox/tool-versions-before"
cp -- "$sandbox/fixture-target/.config/zsh/.zcompdump" "$sandbox/zcompdump-before"
cp -- "$sandbox/fixture-target/.config/darkman/config.yaml" "$sandbox/darkman-before"
deploy "$sandbox/package" "$sandbox/fixture-target"
for path in "${managed[@]}"; do
  assert_link "$sandbox/package/$path" "$sandbox/fixture-target/$path"
done
for path in "${ignored[@]}" .stow-local-ignore; do
  case "$path" in .tool-versions|.config/zsh/.zcompdump|.config/darkman/config.yaml) continue;; esac
  assert_absent "$sandbox/fixture-target/$path"
done
cmp -- "$sandbox/tool-versions-before" "$sandbox/fixture-target/.tool-versions"
cmp -- "$sandbox/zcompdump-before" "$sandbox/fixture-target/.config/zsh/.zcompdump"
cmp -- "$sandbox/darkman-before" "$sandbox/fixture-target/.config/darkman/config.yaml"
git -C "$repo" check-ignore --quiet --no-index -- .config/darkman/config.yaml
if git -C "$repo" ls-files --error-unmatch -- .config/darkman/config.yaml >/dev/null 2>&1; then
  printf 'Private Darkman config must not be tracked.\n' >&2
  exit 1
fi
printf 'Stow deployment, repeatability, and ignore tests passed.\n'
