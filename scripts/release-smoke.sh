#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y --no-install-recommends libx264-164 libyuv0 libopus0 libpulse0 libxcb1 xvfb curl ca-certificates
ldd /dist/voxl
if ldd /dist/voxl | grep -q 'not found'; then exit 1; fi
/dist/voxl --version | grep -F '0.3.3-beeuni.1'
/dist/voxl --help | grep -F 'Beeuni Computer'
Xvfb :99 -screen 0 1280x720x24 -shmem >/tmp/xvfb.log 2>&1 &
display_pid=$!
trap 'kill ${server_pid:-} "$display_pid" 2>/dev/null || true' EXIT
export DISPLAY=:99
sleep 1
/dist/voxl --addr=127.0.0.1 --port=6901 --audio-enabled=false --enable-basic-auth=false --allowed-hosts=.daytonaproxy01.net >/tmp/voxl.log 2>&1 &
server_pid=$!
for attempt in $(seq 1 30); do
  if curl -fsS http://127.0.0.1:6901/healthz; then break; fi
  sleep 1
done
curl -fsS http://127.0.0.1:6901/ | grep -F 'Beeuni Computer'
curl -fsS http://127.0.0.1:6901/favicon.ico -o /tmp/favicon.ico
cmp /tmp/favicon.ico /web/favicon.ico
test "$(curl -s -o /dev/null -w '%{http_code}' -H 'Host: attacker.example' http://127.0.0.1:6901/)" = 403
test "$(curl -s -o /dev/null -w '%{http_code}' -H 'Origin: https://attacker.example' http://127.0.0.1:6901/)" = 403
curl -fsS -H 'Host: desktop.daytonaproxy01.net' http://127.0.0.1:6901/healthz
kill "$server_pid"
wait "$server_pid" || true
VOXL_PASSWORD=release-smoke /dist/voxl --addr=127.0.0.1 --port=6901 --audio-enabled=false >/tmp/voxl-auth.log 2>&1 &
server_pid=$!
for attempt in $(seq 1 30); do
  if curl -fsS http://127.0.0.1:6901/healthz; then break; fi
  sleep 1
done
test "$(curl -s -o /dev/null -w '%{http_code}' http://127.0.0.1:6901/)" = 401
curl -fsS -u viewer:release-smoke http://127.0.0.1:6901/ | grep -F 'Beeuni Computer'
