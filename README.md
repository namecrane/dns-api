# CraneDNS API Documentation (DEVELOPEMENT)

The CraneDNS API allows you to programmatically manage DNS records for your domains.

## Table of Contents

- [Authentication](#authentication)
- [Endpoint](#endpoint)
- [Request Format](#request-format)
- [Response Format](#response-format)
- [HTTP Status Codes](#http-status-codes)
- [Record IDs](#record-ids)
- [API Actions](#api-actions)
  - [dns.list_zones](#dnslist_zones)
  - [dns.list](#dnslist)
  - [dns.create](#dnscreate)
  - [dns.update](#dnsupdate)
  - [dns.delete](#dnsdelete)
  - [dns.ddns](#dnsddns)
- [Record Type Formats](#record-type-formats)
- [Code Examples](#code-examples)
- [Error Reference](#error-reference)
- [Security Best Practices](#security-best-practices)

---

## Authentication

All API requests require authentication via one of these headers:

```
Authorization: Bearer YOUR_API_KEY
```

Or:

```
X-Api-Key: YOUR_API_KEY
```

Generate an API key from the client area. Keys can be configured with IP whitelists, domain restrictions, and read-only or read+write access.

---

## Endpoint

All requests use a single endpoint:

```
POST https://namecrane.org/index.php?m=craneapi
```

The action, domain, and parameters are all specified in the JSON request body.

---

## Request Format

Send a `POST` request with a JSON body. Every request must include an `action` and (for DNS actions) a `domain`:

```json
{
    "action": "dns.list",
    "domain": "namecrane.org"
}
```

---

## Response Format

All responses are JSON.

**Success:**

```json
{
    "success": true,
    "message": "Operation completed",
    "code": 200
}
```

**Error:**

```json
{
    "success": false,
    "error": "Error description",
    "code": 400
}
```

---

## HTTP Status Codes

| Code | Description |
|------|-------------|
| 200 | Success |
| 400 | Invalid request or parameters |
| 401 | Invalid or disabled API key |
| 403 | Forbidden (IP not whitelisted, domain not authorized, or insufficient access level) |
| 404 | Record or domain not found |
| 500 | Server error |

---

## Record IDs

Every DNS record has a unique ID (UUID). This ID is stable and does not change when the record's content, TTL, or other fields are updated.

- `dns.list` returns the `id` for each record
- `dns.create` returns the `id` of the newly created record
- `dns.update` and `dns.delete` require the record `id`
- `dns.ddns` is name-based and does not require an `id`, but returns one in the response

Use the record `id` for all update and delete operations instead of identifying records by name, type, and content.

---

## API Actions

### dns.list_zones

List all domains/zones accessible to the authenticated API key.

This is the only DNS action that does not require a `domain` parameter. Use it to discover which domains you can manage before calling other actions.

**Access:** Read

**Parameters:**

None required.

**Example:**

```bash
curl -X POST "https://namecrane.org/index.php?m=craneapi" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"action": "dns.list_zones"}'
```

**Response:**

```json
{
    "success": true,
    "zones": [
        {"domain": "namecrane.org", "status": "active"},
        {"domain": "example.com", "status": "available"}
    ],
    "code": 200
}
```

**Zone Status:**

| Status | Meaning |
|--------|---------|
| `active` | Zone exists in DNS — you can list and manage records |
| `available` | Domain is owned but no DNS zone yet — creating a record will initialize the zone |

If the API key has domain restrictions, only the allowed domains are returned.

---

### dns.list

Retrieve all DNS records for a domain, optionally filtered by type or fetched by ID.

**Access:** Read

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `domain` | string | Yes | Domain name |
| `type` | string | No | Filter by record type (e.g., `A`, `AAAA`, `CNAME`) |
| `id` | string | No | Fetch a single record by its UUID |

**Example — list all records:**

```bash
curl -X POST "https://namecrane.org/index.php?m=craneapi" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"action": "dns.list", "domain": "namecrane.org"}'
```

**Response:**

```json
{
    "success": true,
    "records": [
        {
            "id": "550e8400-e29b-41d4-a716-446655440000",
            "name": "@",
            "type": "A",
            "content": "192.168.1.1",
            "ttl": 3600
        },
        {
            "id": "6ba7b810-9dad-11d1-80b4-00c04fd430c8",
            "name": "www",
            "type": "CNAME",
            "content": "namecrane.org.",
            "ttl": 3600
        },
        {
            "id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
            "name": "@",
            "type": "MX",
            "content": "10 mail.namecrane.org.",
            "ttl": 3600
        }
    ],
    "code": 200
}
```

**Example — get a single record by ID:**

```bash
curl -X POST "https://namecrane.org/index.php?m=craneapi" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"action": "dns.list", "domain": "namecrane.org", "id": "550e8400-e29b-41d4-a716-446655440000"}'
```

---

### dns.create

Add a new DNS record. Returns the new record's ID.

**Access:** Write

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `domain` | string | Yes | Domain name |
| `name` | string | Yes | Record name (`@` for root, or subdomain) |
| `type` | string | Yes | Record type (`A`, `AAAA`, `CNAME`, `MX`, `TXT`, etc.) |
| `content` | string | Yes | Record value |
| `ttl` | integer | No | Time to live in seconds (default: `3600`) |

**Example:**

```bash
curl -X POST "https://namecrane.org/index.php?m=craneapi" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"action": "dns.create", "domain": "namecrane.org", "name": "www", "type": "A", "content": "192.168.1.1", "ttl": 3600}'
```

**Response:**

```json
{
    "success": true,
    "message": "Record created",
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "code": 200
}
```

---

### dns.update

Modify an existing DNS record by its ID. Only the fields you include will be changed — omitted fields keep their current values.

**Access:** Write

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `domain` | string | Yes | Domain name |
| `id` | string | Yes | Record UUID (from `dns.list` or `dns.create`) |
| `name` | string | No | New record name |
| `type` | string | No | New record type |
| `content` | string | No | New record value |
| `ttl` | integer | No | New TTL in seconds |

**Example — update content only:**

```bash
curl -X POST "https://namecrane.org/index.php?m=craneapi" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"action": "dns.update", "domain": "namecrane.org", "id": "550e8400-e29b-41d4-a716-446655440000", "content": "192.168.1.100"}'
```

**Example — update multiple fields:**

```bash
curl -X POST "https://namecrane.org/index.php?m=craneapi" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{
    "action": "dns.update",
    "domain": "namecrane.org",
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "mail",
    "content": "10.0.0.1",
    "ttl": 300
  }'
```

**Response:**

```json
{
    "success": true,
    "message": "Record updated",
    "code": 200
}
```

---

### dns.delete

Remove a DNS record by its ID.

**Access:** Write

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `domain` | string | Yes | Domain name |
| `id` | string | Yes | Record UUID (from `dns.list` or `dns.create`) |

**Example:**

```bash
curl -X POST "https://namecrane.org/index.php?m=craneapi" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"action": "dns.delete", "domain": "namecrane.org", "id": "550e8400-e29b-41d4-a716-446655440000"}'
```

**Response:**

```json
{
    "success": true,
    "message": "Record deleted",
    "code": 200
}
```

---

### dns.ddns

Update an A or AAAA record with the client's current IP address. Ideal for dynamic DNS scenarios.

Unlike other actions, DDNS is **name-based** — it does not require a record ID. If a matching record exists, it is updated. If not, one is created. The record ID is returned in the response.

If no `ip` is provided, the API automatically uses the requesting client's IP address.

**Access:** Write

**Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `domain` | string | Yes | Domain name |
| `name` | string | Yes | Record name to update (e.g., `home`, `office`) |
| `type` | string | No | `A` (default) or `AAAA` |
| `ip` | string | No | IP address (auto-detected from client if omitted) |

**Example:**

```bash
curl -X POST "https://namecrane.org/index.php?m=craneapi" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"action": "dns.ddns", "domain": "namecrane.org", "name": "home"}'
```

**Response:**

```json
{
    "success": true,
    "message": "DDNS updated",
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "home",
    "type": "A",
    "content": "203.0.113.45",
    "code": 200
}
```

---

## Record Type Formats

| Type | Content Format | Example |
|------|---------------|---------|
| A | IPv4 address | `192.168.1.1` |
| AAAA | IPv6 address | `2001:db8::1` |
| CNAME | Hostname (trailing dot) | `target.namecrane.org.` |
| MX | Priority + hostname | `10 mail.namecrane.org.` |
| TXT | Text string | `v=spf1 include:_spf.google.com ~all` |
| SRV | Priority weight port target | `10 5 443 server.namecrane.org.` |
| CAA | Flags tag value | `0 issue "letsencrypt.org"` |
| NS | Nameserver hostname | `ns1.namecrane.org.` |
| DS | Keytag algorithm digesttype digest | `12345 8 2 abcdef...` |
| DNSKEY | Flags protocol algorithm key | `257 3 8 AwEAAa...` |

---

## Code Examples

### cURL

```bash
# List all zones
curl -X POST "https://namecrane.org/index.php?m=craneapi" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"action": "dns.list_zones"}'

# List all records
curl -X POST "https://namecrane.org/index.php?m=craneapi" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"action": "dns.list", "domain": "namecrane.org"}'

# Create a record
curl -X POST "https://namecrane.org/index.php?m=craneapi" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"action": "dns.create", "domain": "namecrane.org", "name": "www", "type": "A", "content": "192.168.1.1"}'

# Update by ID
curl -X POST "https://namecrane.org/index.php?m=craneapi" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"action": "dns.update", "domain": "namecrane.org", "id": "550e8400-...", "content": "192.168.1.100"}'

# Delete by ID
curl -X POST "https://namecrane.org/index.php?m=craneapi" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"action": "dns.delete", "domain": "namecrane.org", "id": "550e8400-..."}'

# DDNS update (auto-detects IP)
curl -X POST "https://namecrane.org/index.php?m=craneapi" \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"action": "dns.ddns", "domain": "namecrane.org", "name": "home"}'
```

### Python

```python
import requests

URL = "https://namecrane.org/index.php?m=craneapi"
HEADERS = {
    "Authorization": "Bearer YOUR_API_KEY",
    "Content-Type": "application/json",
}

# List records
resp = requests.post(URL, headers=HEADERS, json={
    "action": "dns.list",
    "domain": "namecrane.org",
})
records = resp.json()["records"]

# Create a record
resp = requests.post(URL, headers=HEADERS, json={
    "action": "dns.create",
    "domain": "namecrane.org",
    "name": "www",
    "type": "A",
    "content": "192.168.1.1",
    "ttl": 3600,
})
record_id = resp.json()["id"]

# Update by ID
requests.post(URL, headers=HEADERS, json={
    "action": "dns.update",
    "domain": "namecrane.org",
    "id": record_id,
    "content": "192.168.1.100",
})

# Delete by ID
requests.post(URL, headers=HEADERS, json={
    "action": "dns.delete",
    "domain": "namecrane.org",
    "id": record_id,
})
```

### PHP

```php
$url = 'https://namecrane.org/index.php?m=craneapi';
$apiKey = 'YOUR_API_KEY';
$headers = [
    'Authorization: Bearer ' . $apiKey,
    'Content-Type: application/json',
];

function craneapi(string $url, array $headers, array $body): array {
    $ch = curl_init($url);
    curl_setopt_array($ch, [
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_POST => true,
        CURLOPT_HTTPHEADER => $headers,
        CURLOPT_POSTFIELDS => json_encode($body),
    ]);
    $result = json_decode(curl_exec($ch), true);
    curl_close($ch);
    return $result;
}

// List records
$records = craneapi($url, $headers, [
    'action' => 'dns.list',
    'domain' => 'namecrane.org',
]);

// Create a record
$result = craneapi($url, $headers, [
    'action' => 'dns.create',
    'domain' => 'namecrane.org',
    'name' => 'www',
    'type' => 'A',
    'content' => '192.168.1.1',
    'ttl' => 3600,
]);
$recordId = $result['id'];

// Update by ID
craneapi($url, $headers, [
    'action' => 'dns.update',
    'domain' => 'namecrane.org',
    'id' => $recordId,
    'content' => '192.168.1.100',
]);

// Delete by ID
craneapi($url, $headers, [
    'action' => 'dns.delete',
    'domain' => 'namecrane.org',
    'id' => $recordId,
]);
```

### PowerShell

```powershell
$url = "https://namecrane.org/index.php?m=craneapi"
$headers = @{ "Authorization" = "Bearer YOUR_API_KEY" }

# List records
$resp = Invoke-RestMethod -Uri $url -Method Post -Headers $headers `
    -ContentType "application/json" `
    -Body (@{action = "dns.list"; domain = "namecrane.org"} | ConvertTo-Json)

# Create a record
$body = @{
    action = "dns.create"; domain = "namecrane.org"
    name = "www"; type = "A"; content = "192.168.1.1"; ttl = 3600
} | ConvertTo-Json
$result = Invoke-RestMethod -Uri $url -Method Post -Headers $headers `
    -ContentType "application/json" -Body $body
$recordId = $result.id

# Update by ID
$body = @{
    action = "dns.update"; domain = "namecrane.org"
    id = $recordId; content = "192.168.1.100"
} | ConvertTo-Json
Invoke-RestMethod -Uri $url -Method Post -Headers $headers `
    -ContentType "application/json" -Body $body

# Delete by ID
$body = @{
    action = "dns.delete"; domain = "namecrane.org"
    id = $recordId
} | ConvertTo-Json
Invoke-RestMethod -Uri $url -Method Post -Headers $headers `
    -ContentType "application/json" -Body $body
```

### DDNS Cron Script

```bash
#!/bin/bash
# Add to crontab: */5 * * * * /path/to/ddns.sh
API_KEY="YOUR_API_KEY"
URL="https://namecrane.org/index.php?m=craneapi"

curl -s -X POST "$URL" \
  -H "Authorization: Bearer $API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"action": "dns.ddns", "domain": "namecrane.org", "name": "home"}' | jq .
```

---

## Error Reference

| Error Message | Cause | Solution |
|--------------|-------|----------|
| `API key is required` | Missing authentication header | Add `Authorization` or `X-Api-Key` header |
| `Invalid API key` | Key doesn't exist or malformed | Verify your API key |
| `API key is disabled` | Key disabled in client area | Re-enable in client area |
| `IP not authorized` | Client IP not in key's whitelist | Add your IP to the key's whitelist |
| `Domain not authorized for this key` | Key has domain restrictions | Add the domain to the key's allowed list |
| `Read-only key` | Key lacks write access | Use a read+write key for mutations |
| `Record ID is required` | Missing `id` for update/delete | Include the record `id` |
| `Record not found` | ID doesn't match any record | Verify the UUID via `dns.list` |
| `name, type, and content are required` | Missing required create parameters | Include all required fields |
| `Record type X is not allowed` | Type not permitted by server | Use an allowed record type |
| `Invalid IPv4 address format` | Content format mismatch | Check content matches type format |
| `Could not detect a valid IPv6 address` | DDNS type mismatch | Use correct IP version for request |
| `DDNS only supports A and AAAA record types` | Invalid DDNS type | Use `type=A` or `type=AAAA` |
| `Unknown action` | Invalid action name | Use: dns.list, dns.create, dns.update, dns.delete, dns.ddns |

---

## Security Best Practices

1. **Keep your API key secret** — Never commit to version control or share publicly. Use environment variables.

2. **Use HTTPS** — Always use HTTPS to encrypt requests and protect your API key.

3. **Restrict by IP** — Configure an IP whitelist on your API key to limit access to known addresses.

4. **Restrict by domain** — If a key only needs to manage specific domains, configure domain restrictions.

5. **Use read-only keys** — If you only need to read records (e.g., monitoring), use a read-only key.

6. **Regenerate if compromised** — If exposed, delete the key and create a new one immediately.

7. **Use low TTL for DDNS** — Use 300 seconds or less so IP changes propagate quickly.

8. **Monitor usage** — Check "Last Used" timestamp in client area to detect unauthorized access.
