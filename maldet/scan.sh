#!/bin/bash

# Give other services a moment to start up if needed
sleep 15

# Perform an initial signature update on startup
echo "Maldet container started. Performing initial signature update..."
if ! /usr/local/maldetect/maldet -u >> /var/log/maldet_update.log 2>&1; then
  echo "[$(date)] ERROR: Maldet signature update failed!" | tee -a /var/log/maldet_error.log
fi

echo "Initial update complete. Starting scan loop..."

# Set scan interval (in seconds). Default: 6 hours (21600 seconds)
SCAN_INTERVAL=${SCAN_INTERVAL:-21600}

# Track last scan timestamp
LAST_SCAN_FILE="/tmp/maldet_last_scan"


# Central log file for scan results (with log rotation)
MALDET_SCAN_LOG="/var/log/maldet_scan.log"
MAX_LOG_SIZE=10485760  # 10MB
rotate_log() {
  if [ -f "$MALDET_SCAN_LOG" ] && [ $(stat -c%s "$MALDET_SCAN_LOG") -ge $MAX_LOG_SIZE ]; then
    mv "$MALDET_SCAN_LOG" "$MALDET_SCAN_LOG.$(date +%Y%m%d%H%M%S)"
    touch "$MALDET_SCAN_LOG"
  fi
}

# Loop forever
while true; do
  rotate_log
  echo "[$(date)] Starting incremental Maldet scan of /scan..." | tee -a "$MALDET_SCAN_LOG"
  # Use --monitor mode for incremental/inotify-based scan if available, else fallback to --scan-recent
  if /usr/local/maldetect/maldet --help | grep -q -- '--monitor'; then
    /usr/local/maldetect/maldet --monitor /scan >> "$MALDET_SCAN_LOG" 2>&1 &
    echo "[$(date)] Monitor mode started. Sleeping indefinitely." | tee -a "$MALDET_SCAN_LOG"
    tail -f /dev/null
  else
    # Fallback: scan only files changed in the last scan interval
    if ! /usr/local/maldetect/maldet --scan-recent /scan $((SCAN_INTERVAL/60)) >> "$MALDET_SCAN_LOG" 2>&1; then
      echo "[$(date)] ERROR: Maldet scan failed!" | tee -a /var/log/maldet_error.log
    else
      echo "[$(date)] Incremental scan complete. Updating signatures..." | tee -a "$MALDET_SCAN_LOG"
    fi
    if ! /usr/local/maldetect/maldet -u >> /var/log/maldet_update.log 2>&1; then
      echo "[$(date)] ERROR: Maldet signature update failed!" | tee -a /var/log/maldet_error.log
    fi
    echo "[$(date)] Sleeping for $SCAN_INTERVAL seconds." | tee -a "$MALDET_SCAN_LOG"
    sleep $SCAN_INTERVAL
  fi
done
