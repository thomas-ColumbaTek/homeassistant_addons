# PortBridge (Ingress) – Documentation

PortBridge exposes any local host service (e.g., `127.0.0.1:7000`) inside Home Assistant via Ingress.

## Options

| Option                   | Type   | Default                    | Description |
|--------------------------|--------|----------------------------|-------------|
| `upstream_host`          | string | `127.0.0.1`                | Host of the upstream service |
| `upstream_port`          | int    | `7000`                     | Port of the upstream service |
| `upstream_scheme`        | enum   | `http`                     | `http` or `https` |
| `upstream_insecure`      | bool   | `false`                    | When `https`, skip TLS verification |
| `strip_x_frame_options`  | bool   | `true`                     | Hide upstream `X-Frame-Options` header |
| `content_security_policy`| string | `frame-ancestors 'self';`  | CSP header for iframe embedding |

## Usage
1. Install the add-on.
2. Configure the upstream host/port/scheme.
3. Start the add-on and click **Open Web UI** to access via Ingress.
4. To embed in a dashboard, use a **Webpage** card and paste the Ingress URL (relative path works).

## Notes
- Ingress provides **same-origin** access via Home Assistant (no mixed content/CORS issues).
- WebSockets are supported out of the box.
- If your upstream injects strict CSP headers (e.g., `frame-ancestors 'none'`), this add-on overrides CSP with the configured value.
