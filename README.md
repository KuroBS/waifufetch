# waifufetch

`waifufetch` is a fastfetch wrapper that shows a Danbooru image as the terminal logo, caches images locally, prints clickable image tags, and keeps a small image history.

## Features

- Danbooru image fetching with local buffer and history.
- Fastfetch integration with image logo.
- Full-terminal slideshow mode with pause, next image, live delay changes, and cache rotation.
- Auto-sized collage mode that fills the terminal with cached images.
- Clickable `artist`, `copyright`, and `character` tags in kitty/OSC 8 capable terminals.
- Click a tag to write it to `~/.config/fastfetch/waifu-tags.conf`.
- Manual edits to `waifu-tags.conf` are detected and refresh the image buffer.
- History command with image preview, tags, and source.

## Requirements

- `bash`
- `fastfetch`
- `curl`
- `jq`
- ImageMagick `magick`
- `kitty`/`kitten` for the best terminal image and clickable-link experience
- Optional: `img2sixel` as fallback for history previews

## Install

```bash
git clone https://github.com/YOUR_USER/waifufetch.git
cd waifufetch
./install.sh
```

The installer writes scripts to `~/.local/bin` and `~/.config/fastfetch`, creates symlinks for `waifufetch` and `fastfetch-waifu`, and registers the click handler for `waifufetch-tag://` links.

## Usage

```bash
waifufetch
waifufetch --tag "1girl rating:g"
waifufetch --rating s
waifufetch --rating ""
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

Tags live in:

```text
~/.config/fastfetch/waifu-tags.conf
```

Example:

```text
umamusume rating:g
```

Buffer size lives in:

```text
~/.config/fastfetch/waifu-buffer-size.conf
```

Example:

```text
BUFFER_SIZE=20
```

Optional Danbooru auth can be added in:

```text
~/.config/fastfetch/danbooru-auth.conf
```

```bash
DANBOORU_LOGIN='your_username'
DANBOORU_API_KEY='your_api_key'
```

Then:

```bash
chmod 600 ~/.config/fastfetch/danbooru-auth.conf
```

## Kitty autostart

If you run `waifufetch` from your shell startup file, kitty can scroll back to the top after fastfetch renders so small terminal windows still show the image. This repo includes only the waifufetch commands; add any shell autostart integration in your dotfiles.

## License

MIT
