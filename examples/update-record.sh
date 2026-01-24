#!/bin/bash
# Update an existing DNS record
#
# Example Response:
# {
#     "success": true,
#     "message": "Record updated"
# }
#
# Error Response:
# {
#     "success": false,
#     "error": "name, type, old_content, and content are required"
# }

API_KEY="your-api-key"
BASE_URL="https://namecrane.org/index.php"

# Update an A record's IP address
curl -s -X POST \
  -H "X-API-Key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "www",
    "type": "A",
    "old_content": "192.168.1.1",
    "content": "192.168.1.100",
    "ttl": 3600
  }' \
  "$BASE_URL?m=cranedns&action=api&method=update"

# Update a TXT record
curl -s -X POST \
  -H "X-API-Key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "@",
    "type": "TXT",
    "old_content": "v=spf1 include:_spf.google.com ~all",
    "content": "v=spf1 include:_spf.workspace.org ~all",
    "ttl": 3600
  }' \
  "$BASE_URL?m=cranedns&action=api&method=update"
