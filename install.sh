#!/usr/bin/env bash

set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

install -d "$HOME/.local/bin"
install -d "$HOME/.local/share/applications"
install -d "$HOME/.config/fastfetch"

install -m 755 "$repo_dir/bin/fastfetch-waifu" "$HOME/.config/fastfetch/fastfetch-waifu"
install -m 755 "$repo_dir/bin/waifufetch-tag-handler" "$HOME/.local/bin/waifufetch-tag-handler"
install -m 755 "$repo_dir/bin/waifufetch-history" "$HOME/.local/bin/waifufetch-history"
ln -sfn "$HOME/.config/fastfetch/fastfetch-waifu" "$HOME/.local/bin/fastfetch-waifu"
ln -sfn "$HOME/.config/fastfetch/fastfetch-waifu" "$HOME/.local/bin/waifufetch"

if [[ ! -f "$HOME/.config/fastfetch/config.jsonc" ]]; then
    install -m 644 "$repo_dir/config/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"
fi

if [[ ! -f "$HOME/.config/fastfetch/waifu-tags.conf" ]]; then
    printf '%s\n' '1girl rating:general' > "$HOME/.config/fastfetch/waifu-tags.conf"
fi

if [[ ! -f "$HOME/.config/fastfetch/waifu-buffer-size.conf" ]]; then
    printf '%s\n' 'BUFFER_SIZE=20' > "$HOME/.config/fastfetch/waifu-buffer-size.conf"
fi

if [[ ! -f "$HOME/.config/fastfetch/gelbooru-auth.conf" ]]; then
    umask 077
    cat > "$HOME/.config/fastfetch/gelbooru-auth.conf" <<'EOF'
# Gelbooru credentials (https://gelbooru.com/index.php?page=account&s=options)
GELBOORU_API_KEY=''
GELBOORU_USER_ID=''
EOF
    chmod 600 "$HOME/.config/fastfetch/gelbooru-auth.conf"
    needs_gelbooru_auth=1
fi

sed "s#Exec=.*#Exec=$HOME/.local/bin/waifufetch-tag-handler %u#" \
    "$repo_dir/applications/waifufetch-tag-handler.desktop" \
    > "$HOME/.local/share/applications/waifufetch-tag-handler.desktop"

if command -v xdg-mime >/dev/null 2>&1; then
    xdg-mime default waifufetch-tag-handler.desktop x-scheme-handler/waifufetch-tag || true
fi

printf 'Installed waifufetch.\n'
if [[ "${needs_gelbooru_auth:-0}" -eq 1 ]]; then
    printf 'Fill in your Gelbooru credentials: %s\n' "$HOME/.config/fastfetch/gelbooru-auth.conf"
    printf '  GELBOORU_API_KEY=... and GELBOORU_USER_ID=...\n'
fi
printf 'Run: waifufetch --prefetch-buffer && waifufetch\n'
