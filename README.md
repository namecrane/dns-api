# CraneDNS API Documentation (DEVELOPMENT BETA)

The CraneDNS API allows you to programmatically manage DNS records for your domains.

## Table of Contents

- [Authentication](#authentication)
- [Endpoint](#endpoint)
- [Response Format](#response-format)
- [HTTP Status Codes](#http-status-codes)
- [API Methods](#api-methods)
  - [List Records](#list-records)
  - [Create Record](#create-record)
  - [Update Record](#update-record)
  - [Delete Record](#delete-record)
  - [DDNS Update](#ddns-update)
- [Record Type Formats](#record-type-formats)
- [Code Examples](#code-examples)
- [Error Reference](#error-reference)
- [Security Best Practices](#security-best-practices)

---

## Authentication

All API requests require authentication via the `X-API-Key` header. Generate an API key from the DNS management page in your client area by expanding the **API Access** section.

```
X-API-Key: your-64-character-api-key
```

---

## Endpoint

All requests use a single endpoint:

```
https://namecrane.org/index.php?m=cranedns&action=api&method=METHOD_NAME
```

Replace `METHOD_NAME` with: `list`, `create`, `update`, `delete`, or `ddns`.

---

## Response Format

All responses are JSON.

**Success:**

```json
{
    "success": true,
    "message": "Operation completed"
}
```

**Error:**

```json
{
    "success": false,
    "error": "Error description"
}
```

---

## HTTP Status Codes

| Code | Description |
|------|-------------|
| 200 | Success |
| 400 | Invalid request or parameters |
| 401 | Invalid or disabled API key |
| 403 | Record type not allowed |
| 500 | Server error |

---

## API Methods

### List Records

Retrieve all DNS records for your domain.

**Request:**

```http
GET /index.php?m=cranedns&action=api&method=list
```

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `type` | string | No | Filter by record type (e.g., `A`, `AAAA`, `CNAME`) |

**Example:**

```bash
curl -H "X-API-Key: your-api-key" \
  "https://namecrane.org/index.php?m=cranedns&action=api&method=list"
```

**Response:**

```json
{
    "success": true,
    "records": [
        {
            "name": "@",
            "type": "A",
            "content": "192.168.1.1",
            "ttl": 3600
        },
        {
            "name": "www",
            "type": "CNAME",
            "content": "namecrane.org.",
            "ttl": 3600
        },
        {
            "name": "@",
            "type": "MX",
            "content": "10 mail.namecrane.org.",
            "ttl": 3600
        }
    ]
}
```

> See [`examples/list-records.sh`](examples/list-records.sh) for more examples.

---

### Create Record

Add a new DNS record.

**Request:**

```http
POST /index.php?m=cranedns&action=api&method=create
Content-Type: application/json
```

**Body Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `name` | string | Yes | Record name (`@` for root, or subdomain) |
| `type` | string | Yes | Record type (`A`, `AAAA`, `CNAME`, `MX`, `TXT`, etc.) |
| `content` | string | Yes | Record value |
| `ttl` | integer | No | Time to live in seconds (default: `3600`) |

**Example:**

```bash
curl -X POST \
  -H "X-API-Key: your-api-key" \
  -H "Content-Type: application/json" \
  -d '{"name": "www", "type": "A", "content": "192.168.1.1", "ttl": 3600}' \
  "https://namecrane.org/index.php?m=cranedns&action=api&method=create"
```

**Response:**

```json
{
    "success": true,
    "message": "Record created"
}
```

**Error Response:**

```json
{
    "success": false,
    "error": "Invalid IPv4 address format"
}
```

> See [`examples/create-record.sh`](examples/create-record.sh) for more examples.

---

### Update Record

Modify an existing DNS record.

**Request:**

```http
POST /index.php?m=cranedns&action=api&method=update
Content-Type: application/json
```

**Body Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `name` | string | Yes | Record name |
| `type` | string | Yes | Record type |
| `old_content` | string | Yes | Current record value (identifies the record) |
| `content` | string | Yes | New record value |
| `ttl` | integer | No | New TTL in seconds (default: `3600`) |

**Example:**

```bash
curl -X POST \
  -H "X-API-Key: your-api-key" \
  -H "Content-Type: application/json" \
  -d '{
    "name": "www",
    "type": "A",
    "old_content": "192.168.1.1",
    "content": "192.168.1.100",
    "ttl": 3600
  }' \
  "https://namecrane.org/index.php?m=cranedns&action=api&method=update"
```

**Response:**

```json
{
    "success": true,
    "message": "Record updated"
}
```

**Error Response:**

```json
{
    "success": false,
    "error": "name, type, old_content, and content are required"
}
```

> See [`examples/update-record.sh`](examples/update-record.sh) for more examples.

---

### Delete Record

Remove a DNS record.

**Request:**

```http
POST /index.php?m=cranedns&action=api&method=delete
Content-Type: application/json
```

**Body Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `name` | string | Yes | Record name |
| `type` | string | Yes | Record type |
| `content` | string | Yes | Record value (identifies the record) |

**Example:**

```bash
curl -X POST \
  -H "X-API-Key: your-api-key" \
  -H "Content-Type: application/json" \
  -d '{"name": "www", "type": "A", "content": "192.168.1.1"}' \
  "https://namecrane.org/index.php?m=cranedns&action=api&method=delete"
```

**Response:**

```json
{
    "success": true,
    "message": "Record deleted"
}
```

**Error Response:**

```json
{
    "success": false,
    "error": "name, type, and content are required"
}
```

> See [`examples/delete-record.sh`](examples/delete-record.sh) for more examples.

---

### DDNS Update

Update an A or AAAA record with the client's current IP address. Ideal for dynamic DNS scenarios.

**Request:**

```http
GET /index.php?m=cranedns&action=api&method=ddns&name=RECORD_NAME
```

**Query Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `name` | string | Yes | Record name to update (e.g., `home`, `office`) |
| `type` | string | No | `A` (default) or `AAAA` |

**Example:**

```bash
curl -H "X-API-Key: your-api-key" \
  "https://namecrane.org/index.php?m=cranedns&action=api&method=ddns&name=home"
```

**Response:**

```json
{
    "success": true,
    "message": "DDNS updated",
    "name": "home",
    "type": "A",
    "content": "203.0.113.45"
}
```

**Error Responses:**

```json
{
    "success": false,
    "error": "name parameter is required"
}
```

```json
{
    "success": false,
    "error": "Could not detect a valid IPv6 address"
}
```

> See [`examples/ddns-update.sh`](examples/ddns-update.sh) and [`examples/ddns-cron.sh`](examples/ddns-cron.sh) for more examples.

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

Complete working examples in multiple languages are available in the [`examples/`](examples/) folder:

| File | Description |
|------|-------------|
| [`list-records.sh`](examples/list-records.sh) | List records with cURL |
| [`create-record.sh`](examples/create-record.sh) | Create records with cURL |
| [`update-record.sh`](examples/update-record.sh) | Update records with cURL |
| [`delete-record.sh`](examples/delete-record.sh) | Delete records with cURL |
| [`ddns-update.sh`](examples/ddns-update.sh) | DDNS update with cURL |
| [`ddns-cron.sh`](examples/ddns-cron.sh) | DDNS cron script for automated updates |
| [`cranedns-api.py`](examples/cranedns-api.py) | Python client with all methods |
| [`cranedns-api.php`](examples/cranedns-api.php) | PHP client with all methods |
| [`cranedns-api.ps1`](examples/cranedns-api.ps1) | PowerShell client with all methods |

### Quick Start

**cURL:**

```bash
# List records
curl -H "X-API-Key: your-api-key" \
  "https://namecrane.org/index.php?m=cranedns&action=api&method=list"
```

**Python:**

```python
import requests

response = requests.get(
    "https://namecrane.org/index.php",
    params={"m": "cranedns", "action": "api", "method": "list"},
    headers={"X-API-Key": "your-api-key"}
)
print(response.json())
```

**PHP:**

```php
$ch = curl_init('https://namecrane.org/index.php?m=cranedns&action=api&method=list');
curl_setopt_array($ch, [
    CURLOPT_RETURNTRANSFER => true,
    CURLOPT_HTTPHEADER => ['X-API-Key: your-api-key']
]);
$response = json_decode(curl_exec($ch), true);
print_r($response);
```

**PowerShell:**

```powershell
$response = Invoke-RestMethod -Uri "https://namecrane.org/index.php?m=cranedns&action=api&method=list" `
    -Headers @{"X-API-Key" = "your-api-key"}
$response | ConvertTo-Json
```

---

## Error Reference

| Error Message | Cause | Solution |
|--------------|-------|----------|
| `X-API-Key header is required` | Missing authentication | Add `X-API-Key` header |
| `Invalid API key` | Key doesn't exist or malformed | Verify your 64-character key |
| `API key is disabled` | Key disabled in client area | Re-enable in DNS management |
| `name, type, and content are required` | Missing required parameters | Include all required fields |
| `name, type, old_content, and content are required` | Missing update parameters | Include old_content for updates |
| `Record type X is not allowed` | Type not permitted | Use an allowed record type |
| `Invalid IPv4 address format` | Content format mismatch | Check content matches type format |
| `Could not detect a valid IPv6 address` | DDNS type mismatch | Use correct IP version for request |
| `DDNS only supports A and AAAA record types` | Invalid DDNS type | Use `type=A` or `type=AAAA` |
| `Unknown method` | Invalid method parameter | Use: list, create, update, delete, ddns |

---

## Best Practices

1. **Keep your API key secret** — Never commit to version control or share publicly. Use environment variables.

2. **Regenerate if compromised** — If exposed, regenerate immediately from the client area.

3. **Disable when not needed** — Disable the key without deleting if you temporarily don't need API access.

4. **Use low TTL for DDNS** — Use 300 seconds or less so IP changes propagate quickly.
