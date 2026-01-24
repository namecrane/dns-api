#!/bin/bash
# List all DNS records for your domain
#
# Example Response:
# {
#     "success": true,
#     "records": [
#         {
#             "name": "@",
#             "type": "A",
#             "content": "192.168.1.1",
#             "ttl": 3600
#         },
#         {
#             "name": "www",
#             "type": "CNAME",
#             "content": "example.com.",
#             "ttl": 3600
#         },
#         {
#             "name": "@",
#             "type": "MX",
#             "content": "10 mail.example.com.",
#             "ttl": 3600
#         }
#     ]
# }

API_KEY="your-api-key"
BASE_URL="https://namecrane.org/index.php"

# List all records
curl -s -H "X-API-Key: $API_KEY" \
  "$BASE_URL?m=cranedns&action=api&method=list"

# List only A records
curl -s -H "X-API-Key: $API_KEY" \
  "$BASE_URL?m=cranedns&action=api&method=list&type=A"
