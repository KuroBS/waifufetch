# waifufetch (Gelbooru fork)

`waifufetch` is a fastfetch wrapper that shows a booru image as the terminal logo, caches images locally, prints clickable image tags, and keeps a small image history.

This fork (branched from [KuroBS/waifufetch](https://github.com/KuroBS/waifufetch)) adds **Gelbooru** as the default image source, because `danbooru.donmai.us` is unreachable from some networks/regions (Cloudflare blocks it). Danbooru is still available by changing one config line.

## What this fork changes

- **Gelbooru API support** via `page=dapi&s=post&q=index` (with `api_key` + `user_id`), random images with `sort:random`.
- **Gelbooru tag categories**: artist / copyright / character are recovered by asking the Gelbooru tag API for the post's tags, so the clickable tag rows keep working.
- **Rating translation** between sites: `rating:g|s|q|e` (danbooru style) is sent as `rating:general|sensitive|questionable|explicit` on Gelbooru, and vice versa. Existing configs keep working.
- **Hotlink fix**: Gelbooru's image CDN redirects to the post page unless a `Referer: https://gelbooru.com/` header is sent.
- **Survives API outages**: an unreachable API no longer aborts the script; it warns and keeps showing the cached image.
- **Renders without libchafa**: fastfetch only draws image logos when the optional `chafa` library is installed; when it is missing fastfetch silently prints the distro ASCII logo (tags show, picture does not). This fork pre-renders the picture as truecolor ANSI half-blocks (`logo.ansi`) with ImageMagick and prints it via `logo.type: "file-raw"`, so the image shows in alacritty, xterm, kitty, tmux... with no extra packages. History previews, slideshow and collage use the same renderer.
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

## Why the picture did not show (upstream bug)

`fastfetch` has `--logo-type chafa` compiled in, but it loads `libchafa.so` at
runtime (Arch package marks `chafa` as an *optional* dependency). Without that
library it silently falls back to the distro ASCII logo while still printing
all modules, so it looks like the config is fine but the image is "missing".
`--logo-type kitty`/`sixel` fall back the same way on terminals without those
protocols.

This fork sidesteps the problem: the image is converted once to ANSI blocks
(`~/.cache/fastfetch/waifus/logo.ansi`) and fastfetch just prints that file
with `logo.type: "file-raw"`. If you later install `chafa` as root and prefer
its dithering, set `LOGO_MODE=chafa` in
`~/.config/fastfetch/waifufetch-source.conf`.

## Requirements

- `bash`
- `fastfetch` (image support does *not* require the optional `chafa` library: this fork renders the blocks itself)
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

### Logo rendering

`LOGO_MODE` in `~/.config/fastfetch/waifufetch-source.conf`:

```text
LOGO_MODE=ansi    # default: ImageMagick renders the blocks, works everywhere
LOGO_MODE=chafa   # only if the chafa package (libchafa.so) is installed
```

The block width follows `logo.width` in `~/.config/fastfetch/config.jsonc`
(33 columns by default, which fits an 80-column terminal next to the modules).

A shell greeting can call `waifufetch-greeting` instead of `fastfetch`: it
regenerates `logo.ansi` when the image changed and never leaves the distro
ASCII logo on screen.

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
