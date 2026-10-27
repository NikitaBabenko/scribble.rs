#!/bin/sh
set -eu
app_pid=''
nginx_pid=''
cleanup() {
    trap - TERM INT EXIT
    [ -z "$app_pid" ] || kill -TERM "$app_pid" 2>/dev/null || true
    [ -z "$nginx_pid" ] || kill -TERM "$nginx_pid" 2>/dev/null || true
    [ -z "$app_pid" ] || wait "$app_pid" 2>/dev/null || true
    [ -z "$nginx_pid" ] || wait "$nginx_pid" 2>/dev/null || true
}
trap cleanup EXIT
trap 'exit 0' TERM INT
# Override inherited PORT/NETWORK_ADDRESS to keep the backend off the container
# network even when reusing a project with stale environment variables.
PORT=8081 NETWORK_ADDRESS=127.0.0.1 /usr/local/bin/scribblers &
app_pid=$!
nginx -g 'daemon off;' &
nginx_pid=$!
# Exit the container if either process dies; no silent backend-only failure.
while kill -0 "$app_pid" 2>/dev/null && kill -0 "$nginx_pid" 2>/dev/null; do
    sleep 1
done
exit 1
