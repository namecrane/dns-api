#!/bin/bash
# Delete a DNS record
#
# Example Response:
# {
#     "success": true,
#     "message": "Record deleted"
# }
#
# Error Response:
# {
#     "success": false,
#     "error": "name, type, and content are required"
# }

API_KEY="your-api-key"
BASE_URL="https://namecrane.org/index.php"

# Delete an A record
curl -s -X POST \
  -H "X-API-Key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"name": "www", "type": "A", "content": "192.168.1.1"}' \
  "$BASE_URL?m=cranedns&action=api&method=delete"

# Delete a TXT record
curl -s -X POST \
  -H "X-API-Key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"name": "@", "type": "TXT", "content": "v=spf1 include:_spf.google.com ~all"}' \
  "$BASE_URL?m=cranedns&action=api&method=delete"
