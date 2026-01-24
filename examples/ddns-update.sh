#!/bin/bash
# DDNS Update - Update A/AAAA record with client's IP address
# Useful for dynamic DNS scenarios where your IP changes frequently
#
# Example Response (IPv4):
# {
#     "success": true,
#     "message": "DDNS updated",
#     "name": "home",
#     "type": "A",
#     "content": "203.0.113.45"
# }
#
# Example Response (IPv6):
# {
#     "success": true,
#     "message": "DDNS updated",
#     "name": "home",
#     "type": "AAAA",
#     "content": "2001:db8::1"
# }
#
# Error Response:
# {
#     "success": false,
#     "error": "name parameter is required"
# }

API_KEY="your-api-key"
BASE_URL="https://namecrane.org/index.php"

# Update A record with current IPv4
curl -s -H "X-API-Key: $API_KEY" \
  "$BASE_URL?m=cranedns&action=api&method=ddns&name=home"

# Update AAAA record with current IPv6
curl -s -H "X-API-Key: $API_KEY" \
  "$BASE_URL?m=cranedns&action=api&method=ddns&name=home&type=AAAA"

# Using wget (useful for routers/embedded devices)
wget -qO- --header="X-API-Key: $API_KEY" \
  "$BASE_URL?m=cranedns&action=api&method=ddns&name=home"
