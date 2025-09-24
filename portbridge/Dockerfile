# Base image for Home Assistant add-ons (includes s6-overlay & bashio)
ARG BUILD_FROM=ghcr.io/hassio-addons/base:17.1.0
FROM $BUILD_FROM

# Install a tiny, fast reverse proxy (nginx)
RUN apk add --no-cache nginx

# Copy runtime files (s6 services + templates)
COPY rootfs/ /

# Local HTTP port (Ingress proxies to this port)
EXPOSE 8099
