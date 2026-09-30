# cups-docker

Personal fork of [anujdatar/cups-docker](https://github.com/anujdatar/cups-docker) (MIT).

Differences from upstream:
- Base image pinned to `debian:bookworm-slim` instead of `debian:stable-slim`. Debian trixie no longer ships `printer-driver-gutenprint`, which broke the Canon MP550 queue (missing `rastertogutenprint.5.3`).
- `printer-driver-gutenprint` is installed explicitly and the build fails if its filter is missing.
- Slimmer package list (no hplip/foo2zjs/hpijs).
- Published to `ghcr.io/thijsdelft/cups`, rebuilt monthly for security updates.

## Usage (Portainer stack)

```yaml
services:
  cups:
    image: ghcr.io/thijsdelft/cups:bookworm
    container_name: cups
    restart: unless-stopped
    ports:
      - "631:631"
    device_cgroup_rules:
      - 'c 189:* rmw'
    environment:
      - CUPSADMIN=admin
      - CUPSPASSWORD=change-me   # escape a literal $ as $$
      - TZ=Europe/Amsterdam
    volumes:
      - /storage/docker/cups:/etc/cups
      - /dev/bus/usb:/dev/bus/usb
```

Bind-mount `/dev/bus/usb` (not `devices:`) so the container sees the new device node after the printer is power-cycled.
