#!/usr/bin/env bash
set -euo pipefail

load_token() {
  if command -v pbpaste >/dev/null 2>&1; then
    TOKEN="$(pbpaste | tr -d '\r\n')"
  elif command -v wl-paste >/dev/null 2>&1; then
    TOKEN="$(wl-paste | tr -d '\r\n')"
  elif command -v xclip >/dev/null 2>&1; then
    TOKEN="$(xclip -selection clipboard -o | tr -d '\r\n')"
  else
    echo "No clipboard tool found (pbpaste/wl-paste/xclip)" >&2
    return 1
  fi
}

main() {
  load_token

  if [ "${1:-}" = "--print-export" ]; then
    printf 'export TOKEN=%q\n' "$TOKEN"
    return
  fi

  if [ "${BASH_SOURCE[0]}" != "$0" ]; then
    export TOKEN
    echo "TOKEN loaded (length: ${#TOKEN})"
    return
  fi

  echo "Token copied from clipboard (length: ${#TOKEN})."
  echo "Run: eval \"\$(token --print-export)\""
}

main "$@"
