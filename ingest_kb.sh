#!/bin/bash
# ingest_kb.sh — Daily KB session ingestion via script (cron-safe)
set -euo pipefail
python3 /tmp/ingest_hermes_sessions.py
