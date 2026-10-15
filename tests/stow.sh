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

pi_managed=(
  .pi/agent/AGENTS.md .pi/agent/settings.json
  .pi/agent/extensions/auto-theme.ts .pi/agent/extensions/papercuts.ts
  .pi/agent/extensions/whimsical.ts
  .pi/agent/themes/flexoki-dark.json .pi/agent/themes/flexoki-light.json
)
pi_ignored=(
  .pi/state .pi/todos/state.json .pi/.git/config .pi/.pi/todos/state.json
  .pi/node_modules/package/index.js
  .pi/agent/auth.json .pi/agent/auth.json.bak .pi/agent/trust.json
  .pi/agent/models.json .pi/agent/models-store.json .pi/agent/mcp.json .pi/agent/modes.json
  .pi/agent/settings.local.json .pi/agent/settings.json.lock/state
  .pi/agent/sessions/session.jsonl .pi/agent/install/release.js .pi/agent/bin/pi
  .pi/agent/git/checkout/file .pi/agent/npm/node_modules/package/index.js
  .pi/agent/node_modules/package/index.js .pi/agent/tmux-subagents/state.json
  .pi/agent/papercuts.jsonl .pi/agent/papercuts.md .pi/agent/pi-crash.log
  .pi/agent/extensions/private.json .pi/agent/extensions/unselected.ts
  .pi/agent/extensions/auto-theme.ts.bak .pi/agent/extensions/nested/index.ts
  .pi/agent/extensions/node_modules/package/index.js .pi/agent/extensions/.pi/state
  .pi/agent/themes/private.json .pi/agent/themes/flexoki-dark.json.bak
  .pi/agent/skills/local/SKILL.md .config/nvim/.pi/state .config/fish/.pi/state
)

deploy "$repo" "$sandbox/target"
for path in \
  .zshenv .config/niri/config.kdl .config/ghostty/config .config/fish/config.fish \
  .config/fish/conf.d/fish_frozen_theme.fish .config/fish/conf.d/fish_frozen_key_bindings.fish \
  .config/fish/themes/Flexoki-Dark.theme .config/fish/themes/Flexoki-Light.theme \
  .config/noctalia/config.toml .config/noctalia/palettes/Flexoki.json \
  .config/ohmyposh/config.toml \
  .config/nvim/init.lua .config/nvim/.luarc.json .config/nvim/.tool-versions \
  .config/nvim/doc/mini-migration-plan.md "${pi_managed[@]}"; do
  assert_link "$repo/$path" "$sandbox/target/$path"
done
for path in .git .gitignore README.md .stow-local-ignore tests .tool-versions \
  .config/nvim/.pi .config/zsh/.zcompdump .config/rofi/global/history.txt \
  .config/darkman/config.yaml .pi/todos .pi/.git .pi/agent/sessions .pi/agent/install \
  .pi/agent/git .pi/agent/npm .pi/node_modules "${pi_ignored[@]}"; do
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
  .git/config .gitignore .gitmodules README.md LICENSE COPYING .tool-versions
  tests/stow.sh .config/nvim/.pi/state .config/zsh/.zcompdump .config/zsh/.zcompdump.host
  .config/ranger/__pycache__/module.pyc .config/ranger/module.pyo
  .config/rofi/global/history.txt .config/darkman/config.yaml "${pi_ignored[@]}"
)
managed=(.zshenv .config/app/config .config/nvim/.tool-versions .config/nvim/README.md "${pi_managed[@]}")
for path in "${ignored[@]}" "${managed[@]}"; do
  mkdir -p -- "$(dirname -- "$sandbox/package/$path")"
  printf 'fixture\n' > "$sandbox/package/$path"
done
mkdir -p "$sandbox/fixture-target/.config/zsh" "$sandbox/fixture-target/.config/darkman" \
  "$sandbox/fixture-target/.pi/agent" "$sandbox/fixture-target/.pi/.git"
printf 'local tool versions\n' > "$sandbox/fixture-target/.tool-versions"
printf 'local completion cache\n' > "$sandbox/fixture-target/.config/zsh/.zcompdump"
printf 'private local location\n' > "$sandbox/fixture-target/.config/darkman/config.yaml"
printf 'private authentication fixture\n' > "$sandbox/fixture-target/.pi/agent/auth.json"
printf 'local backup repository fixture\n' > "$sandbox/fixture-target/.pi/.git/config"
cp -- "$sandbox/fixture-target/.tool-versions" "$sandbox/tool-versions-before"
cp -- "$sandbox/fixture-target/.config/zsh/.zcompdump" "$sandbox/zcompdump-before"
cp -- "$sandbox/fixture-target/.config/darkman/config.yaml" "$sandbox/darkman-before"
cp -- "$sandbox/fixture-target/.pi/agent/auth.json" "$sandbox/auth-before"
cp -- "$sandbox/fixture-target/.pi/.git/config" "$sandbox/backup-repo-before"
deploy "$sandbox/package" "$sandbox/fixture-target"
for path in "${managed[@]}"; do
  assert_link "$sandbox/package/$path" "$sandbox/fixture-target/$path"
done
for path in "${ignored[@]}" .stow-local-ignore; do
  case "$path" in
    .tool-versions|.config/zsh/.zcompdump|.config/darkman/config.yaml|.pi/agent/auth.json|.pi/.git/config) continue;;
  esac
  assert_absent "$sandbox/fixture-target/$path"
done
cmp -- "$sandbox/tool-versions-before" "$sandbox/fixture-target/.tool-versions"
cmp -- "$sandbox/zcompdump-before" "$sandbox/fixture-target/.config/zsh/.zcompdump"
cmp -- "$sandbox/darkman-before" "$sandbox/fixture-target/.config/darkman/config.yaml"
cmp -- "$sandbox/auth-before" "$sandbox/fixture-target/.pi/agent/auth.json"
cmp -- "$sandbox/backup-repo-before" "$sandbox/fixture-target/.pi/.git/config"
for path in "${pi_ignored[@]}"; do
  git -C "$repo" check-ignore --quiet --no-index -- "$path"
done
for path in "${pi_managed[@]}"; do
  status=0
  git -C "$repo" check-ignore --quiet --no-index -- "$path" || status=$?
  if [[ "$status" -ne 1 ]]; then
    printf 'Expected portable Pi file to be eligible for tracking: %s\n' "$path" >&2
    exit 1
  fi
done
while IFS= read -r -d '' path; do
  allowed=false
  for selected in "${pi_managed[@]}"; do
    if [[ "$path" == "$selected" ]]; then allowed=true; break; fi
  done
  if [[ "$allowed" != true ]]; then
    printf 'Unselected Pi file must not be tracked: %s\n' "$path" >&2
    exit 1
  fi
done < <(git -C "$repo" ls-files -z -- .pi)
git -C "$repo" check-ignore --quiet --no-index -- .config/darkman/config.yaml
if git -C "$repo" ls-files --error-unmatch -- .config/darkman/config.yaml >/dev/null 2>&1; then
  printf 'Private Darkman config must not be tracked.\n' >&2
  exit 1
fi
printf 'Stow deployment, repeatability, and ignore tests passed.\n'
