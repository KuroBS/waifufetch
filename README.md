# waifufetch (Gelbooru fork)

`waifufetch` is a fastfetch wrapper that shows a booru image as the terminal logo, caches images locally, prints clickable image tags, and keeps a small image history.

This fork (branched from [KuroBS/waifufetch](https://github.com/KuroBS/waifufetch)) adds **Gelbooru** as the default image source, because `danbooru.donmai.us` is unreachable from some networks/regions (Cloudflare blocks it). Danbooru is still available by changing one config line.

## What this fork changes

- **Gelbooru API support** via `page=dapi&s=post&q=index` (with `api_key` + `user_id`), random images with `sort:random`.
- **Gelbooru tag categories**: artist / copyright / character are recovered by asking the Gelbooru tag API for the post's tags, so the clickable tag rows keep working.
- **Rating translation** between sites: `rating:g|s|q|e` (danbooru style) is sent as `rating:general|sensitive|questionable|explicit` on Gelbooru, and vice versa. Existing configs keep working.
- **Hotlink fix**: Gelbooru's image CDN redirects to the post page unless a `Referer: https://gelbooru.com/` header is sent.
- **Survives API outages**: an unreachable API no longer aborts the script; it warns and keeps showing the cached image.
- **Renders in terminals without graphics protocol** (alacritty, xterm, ...): fastfetch's built-in `chafa` backend is used instead of `logo.type: "auto"`, which dumps raw bytes on those terminals. History previews, slideshow and collage fall back to chafa too.
- **Clicking a tag keeps the rating filter**, so a click never drops the SFW restriction.

## Features (upstream)

- Booru image fetching with local buffer and history.
- Fastfetch integration with image logo.
- Full-terminal slideshow mode with pause, next image, live delay changes, and cache rotation.
- Auto-sized collage mode that fills the terminal with cached images.
- Clickable `artist`, `copyright`, and `character` tags in OSC 8 capable terminals (kitty, alacritty, wezterm...).
- Click a tag to write it to `~/.config/fastfetch/waifu-tags.conf`.
- Manual edits to `waifu-tags.conf` are detected and refresh the image buffer.
- History command with image preview, tags, and source.

## Requirements

- `bash`
- `fastfetch` (compiled with the `chafa` feature for terminals without image protocols)
- `curl`
- `jq`
- ImageMagick `magick`
- `kitty`/`kitten` for the best terminal image experience (optional; chafa is used otherwise)
- Optional: `img2sixel` as another fallback

## Install

```bash
git clone https://github.com/YOUR_USER/waifufetch-gelbooru.git
cd waifufetch-gelbooru
./install.sh
```

The installer writes scripts to `~/.local/bin` and `~/.config/fastfetch`, creates symlinks for `waifufetch` and `fastfetch-waifu`, and registers the click handler for `waifufetch-tag://` links.

Then add your Gelbooru credentials (the API returns `401` without them):

```bash
cat > ~/.config/fastfetch/gelbooru-auth.conf <<'EOF'
GELBOORU_API_KEY='your_api_key'
GELBOORU_USER_ID='your_user_id'
EOF
chmod 600 ~/.config/fastfetch/gelbooru-auth.conf
```

Prefetch a buffer so the first run is instant:

```bash
waifufetch --prefetch-buffer
```

## Usage

```bash
waifufetch
waifufetch --tag "1girl rating:general"
waifufetch --rating general      # or s / q / e, g/q also accepted
waifufetch --rating ""           # drop the rating filter
waifufetch --buffer-size 20
waifufetch --open-source
waifufetch --history
waifufetch --history 5
waifufetch --history all
waifufetch-history 5
waifufetch --slideshow
waifufetch --slideshow --slide-delay 12
waifufetch --collage
waifufetch --collage 12
```

## Slideshow

`waifufetch --slideshow` shows the image as large as the terminal allows, keeps rotating through the local buffer while refilling it in the background, and reserves the top lines for clickable artist, IP/copyright, characters, controls, and source.

Controls:

```text
space  pause/resume
n      next image
+ / -  increase/decrease delay
o      open current source
q      quit
```

The initial delay is configured per run:

```bash
waifufetch --slideshow --slide-delay 10
```

## Collage

`waifufetch --collage` skips fastfetch and renders only a collage of cached images. It measures the terminal size and chooses an appropriate grid automatically.

You can force the number of images:

```bash
waifufetch --collage 12
```

## Configuration

### Image source

Default is Gelbooru. To switch back to Danbooru:

```text
~/.config/fastfetch/waifufetch-source.conf
```

```text
BOORU_SITE=danbooru
```

(`BOORU_SITE=gelbooru` is the default when the file is missing.)

### Tags

```text
~/.config/fastfetch/waifu-tags.conf
```

Example (Gelbooru):

```text
1girl rating:general
```

Example (Danbooru):

```text
1girl rating:g
```

Ratings are translated automatically, so either spelling works on either site.

### Buffer size

```text
~/.config/fastfetch/waifu-buffer-size.conf
```

```text
BUFFER_SIZE=20
```

### Credentials

Gelbooru (`~/.config/fastfetch/gelbooru-auth.conf`, `chmod 600`):

```bash
GELBOORU_API_KEY='your_api_key'
GELBOORU_USER_ID='your_user_id'
```

Danbooru (`~/.config/fastfetch/danbooru-auth.conf`, `chmod 600`):

```bash
DANBOORU_LOGIN='your_username'
DANBOORU_API_KEY='your_api_key'
```

## Shell autostart

If you want the image on every new terminal, call `fastfetch` from your shell greeting (CachyOS/Arch fish config does this by default) or from `~/.bashrc`. The included `config/config.jsonc` already points the logo at `~/.cache/fastfetch/waifus/current.png`.

## License

MIT
