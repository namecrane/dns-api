# CraneDNS API Examples

This folder contains working code examples for the CraneDNS API in multiple languages.

## Shell Scripts (cURL)

| File | Description |
|------|-------------|
| [list-records.sh](list-records.sh) | List all DNS records |
| [create-record.sh](create-record.sh) | Create A, MX, TXT, and CNAME records |
| [update-record.sh](update-record.sh) | Update existing records |
| [delete-record.sh](delete-record.sh) | Delete records |
| [ddns-update.sh](ddns-update.sh) | Dynamic DNS update (one-time) |
| [ddns-cron.sh](ddns-cron.sh) | Dynamic DNS cron script with logging |

## Full Client Libraries

| File | Language | Description |
|------|----------|-------------|
| [cranedns-api.py](cranedns-api.py) | Python | Complete client with all API methods |
| [cranedns-api.php](cranedns-api.php) | PHP | Complete client with all API methods |
| [cranedns-api.ps1](cranedns-api.ps1) | PowerShell | Complete client with all API methods |

## Quick Start

### 1. Get your API key

Generate an API key from the DNS management page in your WHMCS client area.

### 2. Configure the example

Edit the example file and set your API key and base URL:

```bash
API_KEY="your-64-character-api-key"
BASE_URL="https://namecrane.org/index.php"
```

### 3. Run the example

**Shell:**
```bash
chmod +x list-records.sh
./list-records.sh
```

**Python:**
```bash
pip install requests
python cranedns-api.py
```

**PHP:**
```bash
php cranedns-api.php
```

**PowerShell:**
```powershell
.\cranedns-api.ps1
```

## Setting Up DDNS

To automatically update your IP address, set up the cron script:

1. Copy and configure `ddns-cron.sh`:
   ```bash
   cp ddns-cron.sh /usr/local/bin/ddns-update.sh
   chmod +x /usr/local/bin/ddns-update.sh
   # Edit the file to set your API_KEY and ENDPOINT
   ```

2. Add to crontab (runs every 5 minutes):
   ```bash
   crontab -e
   # Add this line:
   */5 * * * * /usr/local/bin/ddns-update.sh >> /var/log/ddns.log 2>&1
   ```