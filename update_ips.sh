#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="${1:-config.json}"
LOG_FILE="update_ips.log"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

get_current_ip() {
  local sources
  sources=$(jq -r '.ip_sources[]' "$CONFIG_FILE")

  for source in $sources; do
    ip=$(curl -s --max-time 5 "$source" 2>/dev/null) && {
      echo "$ip"
      return 0
    }
  done

  return 1
}

main() {
  log "Starting IP update check"

  current_ip=$(get_current_ip) || {
    log "ERROR: Failed to retrieve current IP"
    exit 1
  }

  log "Current IP: $current_ip"

  if [ -f "last_ip.txt" ]; then
    last_ip=$(cat last_ip.txt)
    if [ "$current_ip" = "$last_ip" ]; then
      log "IP unchanged, no update needed"
      exit 0
    fi
    log "IP changed from $last_ip to $current_ip"
  fi

  echo "$current_ip" > last_ip.txt
  log "IP updated successfully"
}

main
