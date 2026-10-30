#!/bin/sh
# Voroa assigns a port at runtime via $PORT. jiotv_go does NOT read
# $PORT itself — it only takes a --port flag (default 5001) — so this
# script bridges the two. Without this, Voroa cannot find the server.
set -e
PORT="${PORT:-5001}"
echo "Starting JioTV Go on port $PORT"
exec ./jiotv_go --skip-update-check serve --public --port "$PORT"
