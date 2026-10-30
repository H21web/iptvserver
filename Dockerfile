# JioTV Go on Voroa — thin wrapper around the upstream image.
# Upstream: https://github.com/rabilrbl/jiotv_go (CC BY 4.0)
# This repo contains NO JioTV code of its own and NO credentials.
# It only starts the upstream server on Render's $PORT.
FROM ghcr.io/rabilrbl/jiotv_go:latest

WORKDIR /app

COPY --chmod=755 start.sh /app/start.sh

# Replace the upstream entrypoint so we can expand $PORT at runtime.
ENTRYPOINT ["/bin/sh", "/app/start.sh"]
