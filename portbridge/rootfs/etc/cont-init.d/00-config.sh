#!/command/with-contenv bashio
# Configure nginx at container start based on add-on options.
# Generates /etc/nginx/nginx.conf dynamically.
set -euo pipefail

UPSTREAM_HOST="$(bashio::config 'upstream_host')"
UPSTREAM_PORT="$(bashio::config 'upstream_port')"
SCHEME="$(bashio::config 'upstream_scheme')"
INSECURE="$(bashio::config 'upstream_insecure')"
STRIP_XFO="$(bashio::config 'strip_x_frame_options')"
CSP="$(bashio::config 'content_security_policy')"

PROXY_PASS="${SCHEME}://${UPSTREAM_HOST}:${UPSTREAM_PORT}"

mkdir -p /var/log/nginx /var/lib/nginx/tmp /run/nginx

# Base nginx configuration
cat >/etc/nginx/nginx.conf <<'NGINX_BASE'
user nginx;
worker_processes auto;

events {
  worker_connections 1024;
}

http {
  include       /etc/nginx/mime.types;
  default_type  application/octet-stream;

  # Enable WebSocket pass-through
  map $http_upgrade $connection_upgrade {
    default upgrade;
    ''      close;
  }

  sendfile        on;
  tcp_nopush      on;
  tcp_nodelay     on;
  keepalive_timeout  65;
  client_max_body_size 50m;

  server {
    # Port that HA Ingress connects to
    listen 8099 default_server;

    # Single catch-all location proxied to the configured upstream
    location / {
      proxy_http_version 1.1;
      proxy_set_header Host $host;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;

      # WebSocket headers
      proxy_set_header Upgrade $http_upgrade;
      proxy_set_header Connection $connection_upgrade;

      # Stream responses as-is (good for terminals/SSE)
      proxy_buffering off;

      # Keep connections open for long-lived streams/websockets
      proxy_read_timeout 86400;
NGINX_BASE

{
  echo "          proxy_pass ${PROXY_PASS};"

  # Allow self-signed upstream when requested
  if [ "${SCHEME}" = "https" ] && bashio::var.true "${INSECURE}"; then
    echo "          proxy_ssl_verify off;"
  fi

  # Remove classic iframe blocker header if present
  if bashio::var.true "${STRIP_XFO}"; then
    echo "          proxy_hide_header X-Frame-Options;"
  fi

  # Set/override Content-Security-Policy to allow framing from HA
  if [ -n "${CSP}" ]; then
    echo "          add_header Content-Security-Policy \"${CSP}\" always;"
  fi
} >> /etc/nginx/nginx.conf

# Close server/http blocks
cat >>/etc/nginx/nginx.conf <<'NGINX_END'
    }
  }
}
NGINX_END
