# PortBridge (Ingress) – Home Assistant Add-on Repository

**Expose any local host service/port inside Home Assistant via Ingress.**  
Works great for terminals, dashboards, small web apps – with WebSockets and iFrame headers handled.

## Features
- Ingress (same-origin with Home Assistant)
- Pass-through WebSockets/SSE
- Optional header fixes: remove `X-Frame-Options`, set CSP `frame-ancestors`
- Host network access to reach `127.0.0.1:<port>` services
- Supports multiple instances (one per upstream port)

## Repository Structure
```text
repository.yaml                # Required repo metadata for HA
portbridge/                    # The add-on folder
  config.yaml                  # Add-on manifest & options schema
  Dockerfile                   # Container build
  DOCS.md                      # User docs shown in Add-on UI
  README.md                    # Short add-on readme (store card)
  CHANGELOG.md                 # (optional) Changelog
  icon.png, logo.png           # Store visuals (placeholders)
  rootfs/
    etc/cont-init.d/00-config.sh      # Generate nginx config from options
    etc/services.d/nginx/run          # Start nginx (s6 overlay)
    etc/nginx/nginx.conf              # Placeholder (generated at runtime)
.github/workflows/
  ci-build.yml                 # Test-build the add-on on PRs/pushes
```

## How to use in Home Assistant
1. Push this repository to GitHub (or host it anywhere Git can reach).
2. In **Settings → Add-ons → Add-on Store**, click the menu (⋮) → **Repositories** and add the repository URL, e.g.  
   `https://github.com/YOUR_GITHUB_USERNAME/portbridge-addon-repo`
3. Install **PortBridge (Ingress)** from **Local add-ons / Custom repositories**.
4. Configure:
   - `upstream_host`: e.g. `127.0.0.1`
   - `upstream_port`: e.g. `7000`
   - `upstream_scheme`: `http` or `https`
   - `upstream_insecure`: set `true` to skip TLS verify for self-signed upstreams
   - `strip_x_frame_options`: removes upstream `X-Frame-Options`
   - `content_security_policy`: default allows framing from HA
5. Start the add-on → Open Web UI (Ingress) to verify it loads.
6. Embed in a dashboard using a **Webpage/iFrame** card and paste the Ingress URL,
   or use a relative Ingress path (copied from your browser when opening the add-on).

## Multiple services
This repository allows **multiple instances** of the add-on. Create a second instance and point it to another port (e.g., `:7001`).

## Building & Publishing
- By default, **Supervisor will build the image locally** from `Dockerfile` (no registry needed).
- To publish prebuilt images (GHCR, Docker Hub), add an `image:` key to `portbridge/config.yaml`
  and set the `version:` to match the image tag. See `ci-build.yml` for a basic GitHub Action.

## License
MIT. See [LICENSE](LICENSE).

## Maintainers
PortBridge Maintainers <maintainers@example.com>

