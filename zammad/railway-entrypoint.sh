#!/usr/bin/env bash
# Railway entrypoint: install or migrate, then run every Zammad process in
# this one container. If any of them exits, stop the rest and exit non-zero so
# Railway restarts the whole service.
set -euo pipefail
cd /opt/zammad

# Install on first boot, migrate on upgrade, point Zammad at Elasticsearch and
# build the search index if it's missing. Idempotent.
/opt/zammad/bin/docker-entrypoint zammad-init

bundle exec rails r /opt/railway/railway-setup.rb

pids=()
bundle exec puma -b tcp://127.0.0.1:3000 -e production & pids+=($!)
bundle exec script/websocket-server.rb -b 127.0.0.1 -p 6042 start & pids+=($!)
bundle exec script/background-worker.rb start & pids+=($!)

# Open the port only once Rails answers, so the health check passing means
# Zammad is up rather than nginx answering 502.
until curl -sf -o /dev/null http://127.0.0.1:3000/api/v1/signshow; do
  kill -0 "${pids[0]}" 2>/dev/null || { echo "puma exited during boot" >&2; exit 1; }
  sleep 1
done
echo "Zammad is ready, starting nginx on :8080"
nginx -g 'daemon off;' & pids+=($!)

trap 'kill -TERM "${pids[@]}" 2>/dev/null; wait' TERM INT
set +e
wait -n "${pids[@]}"
status=$?
echo "A Zammad process exited ($status), stopping the rest" >&2
kill -TERM "${pids[@]}" 2>/dev/null
wait
[ "$status" -eq 0 ] && status=1
exit "$status"
