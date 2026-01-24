#!/bin/bash
# DDNS Cron Script
# Keep your dynamic IP updated automatically
#
# Installation:
#   1. Save this file and make it executable: chmod +x ddns-cron.sh
#   2. Edit the API_KEY and ENDPOINT variables below
#   3. Add to crontab to run every 5 minutes:
#      */5 * * * * /path/to/ddns-cron.sh >> /var/log/ddns.log 2>&1
#
# Example Success Output:
#   2024-01-15 10:30:00: DDNS updated successfully to 203.0.113.45
#
# Example Error Output:
#   2024-01-15 10:30:00: DDNS update failed - Invalid API key

API_KEY="your-64-character-api-key"
ENDPOINT="https://namecrane.org/index.php?m=cranedns&action=api&method=ddns&name=home"

response=$(curl -s -H "X-API-Key: $API_KEY" "$ENDPOINT")

if echo "$response" | grep -q '"success":true'; then
    ip=$(echo "$response" | grep -o '"content":"[^"]*"' | cut -d'"' -f4)
    echo "$(date '+%Y-%m-%d %H:%M:%S'): DDNS updated successfully to $ip"
else
    error=$(echo "$response" | grep -o '"error":"[^"]*"' | cut -d'"' -f4)
    echo "$(date '+%Y-%m-%d %H:%M:%S'): DDNS update failed - $error" >&2
    exit 1
fi
