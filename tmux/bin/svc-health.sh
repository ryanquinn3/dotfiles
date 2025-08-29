#!/usr/bin/env bash
set -euo pipefail

URL="http://127.0.0.1:8080/health"
NAME="web"
THRESHOLD_MS=400         # warn (⚠) if slower than this
CONNECT_TIMEOUT=0.25     # seconds
TOTAL_TIMEOUT=0.8        # seconds

while getopts ":u:n:t:c:m:" opt; do
  case "$opt" in
    u) URL="$OPTARG" ;;
    n) NAME="$OPTARG" ;;
    t) THRESHOLD_MS="$OPTARG" ;;
    c) CONNECT_TIMEOUT="$OPTARG" ;;
    m) TOTAL_TIMEOUT="$OPTARG" ;;
  esac
done

# Get HTTP code and total time (seconds) from curl. "000" when it can't connect.
out="$(curl -sS -o /dev/null \
  -w '%{http_code} %{time_total}' \
  --connect-timeout "$CONNECT_TIMEOUT" \
  --max-time "$TOTAL_TIMEOUT" \
  "$URL" || true)"

code="${out%% *}"
secs="${out##* }"
[[ -z "${code:-}" ]] && code="000"
[[ -z "${secs:-}" ]] && secs="0"

# Convert seconds -> integer ms
ms=$(awk -v s="$secs" 'BEGIN{printf("%d", s*1000 + 0.5)}')

if [[ "$code" == "200" ]]; then
  if (( ms > THRESHOLD_MS )); then
    echo "#[fg=yellow]⚠ ${NAME}"
  else
    echo "#[fg=green]✅ ${NAME}"
  fi
else
  echo "#[fg=red]❌ ${NAME}"
fi

