#!/bin/bash
# Create DNS records
#
# Example Response:
# {
#     "success": true,
#     "message": "Record created"
# }
#
# Error Response:
# {
#     "success": false,
#     "error": "Invalid IPv4 address format"
# }

API_KEY="your-api-key"
BASE_URL="https://namecrane.org/index.php"

# Create an A record
curl -s -X POST \
  -H "X-API-Key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"name": "www", "type": "A", "content": "192.168.1.1", "ttl": 3600}' \
  "$BASE_URL?m=cranedns&action=api&method=create"

# Create an MX record
curl -s -X POST \
  -H "X-API-Key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"name": "@", "type": "MX", "content": "10 mail.example.com.", "ttl": 3600}' \
  "$BASE_URL?m=cranedns&action=api&method=create"

# Create a TXT record (SPF)
curl -s -X POST \
  -H "X-API-Key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"name": "@", "type": "TXT", "content": "v=spf1 include:_spf.google.com ~all", "ttl": 3600}' \
  "$BASE_URL?m=cranedns&action=api&method=create"

# Create a CNAME record
curl -s -X POST \
  -H "X-API-Key: $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"name": "blog", "type": "CNAME", "content": "example.com.", "ttl": 3600}' \
  "$BASE_URL?m=cranedns&action=api&method=create"
