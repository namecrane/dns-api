# CraneDNS API Client Example - PowerShell
#
# This script demonstrates how to use all CraneDNS API methods.
#
# Usage:
#   1. Set your $ApiKey and $BaseUrl below
#   2. Run: .\cranedns-api.ps1

$ApiKey = "your-api-key"
$BaseUrl = "https://namecrane.org/index.php"

$headers = @{
    "X-API-Key" = $ApiKey
    "Content-Type" = "application/json"
}

<#
.SYNOPSIS
    List all DNS records
.DESCRIPTION
    Example Response:
    {
        "success": true,
        "records": [
            {"name": "@", "type": "A", "content": "192.168.1.1", "ttl": 3600},
            {"name": "www", "type": "CNAME", "content": "example.com.", "ttl": 3600}
        ]
    }
.PARAMETER Type
    Optional record type filter (A, AAAA, CNAME, etc.)
#>
function Get-DnsRecords {
    param([string]$Type)

    $uri = "$BaseUrl`?m=cranedns&action=api&method=list"
    if ($Type) {
        $uri += "&type=$Type"
    }

    Invoke-RestMethod -Uri $uri -Headers $headers
}

<#
.SYNOPSIS
    Create a new DNS record
.DESCRIPTION
    Example Response:
    {"success": true, "message": "Record created"}

    Error Response:
    {"success": false, "error": "Invalid IPv4 address format"}
#>
function New-DnsRecord {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Type,
        [Parameter(Mandatory)][string]$Content,
        [int]$Ttl = 3600
    )

    $body = @{
        name = $Name
        type = $Type
        content = $Content
        ttl = $Ttl
    } | ConvertTo-Json

    Invoke-RestMethod -Uri "$BaseUrl`?m=cranedns&action=api&method=create" -Method Post -Headers $headers -Body $body
}

<#
.SYNOPSIS
    Update an existing DNS record
.DESCRIPTION
    Example Response:
    {"success": true, "message": "Record updated"}

    Error Response:
    {"success": false, "error": "name, type, old_content, and content are required"}
#>
function Set-DnsRecord {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Type,
        [Parameter(Mandatory)][string]$OldContent,
        [Parameter(Mandatory)][string]$NewContent,
        [int]$Ttl = 3600
    )

    $body = @{
        name = $Name
        type = $Type
        old_content = $OldContent
        content = $NewContent
        ttl = $Ttl
    } | ConvertTo-Json

    Invoke-RestMethod -Uri "$BaseUrl`?m=cranedns&action=api&method=update" -Method Post -Headers $headers -Body $body
}

<#
.SYNOPSIS
    Delete a DNS record
.DESCRIPTION
    Example Response:
    {"success": true, "message": "Record deleted"}

    Error Response:
    {"success": false, "error": "name, type, and content are required"}
#>
function Remove-DnsRecord {
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string]$Type,
        [Parameter(Mandatory)][string]$Content
    )

    $body = @{
        name = $Name
        type = $Type
        content = $Content
    } | ConvertTo-Json

    Invoke-RestMethod -Uri "$BaseUrl`?m=cranedns&action=api&method=delete" -Method Post -Headers $headers -Body $body
}

<#
.SYNOPSIS
    DDNS update - update A/AAAA record with client's IP
.DESCRIPTION
    Example Response:
    {
        "success": true,
        "message": "DDNS updated",
        "name": "home",
        "type": "A",
        "content": "203.0.113.45"
    }

    Error Response:
    {"success": false, "error": "Could not detect a valid IPv6 address"}
#>
function Update-DdnsRecord {
    param(
        [Parameter(Mandatory)][string]$Name,
        [ValidateSet("A", "AAAA")][string]$Type = "A"
    )

    Invoke-RestMethod -Uri "$BaseUrl`?m=cranedns&action=api&method=ddns&name=$Name&type=$Type" -Headers $headers
}

# Example usage
Write-Host "=== List all records ===" -ForegroundColor Cyan
Get-DnsRecords | ConvertTo-Json -Depth 10

Write-Host "`n=== List only A records ===" -ForegroundColor Cyan
Get-DnsRecords -Type "A" | ConvertTo-Json -Depth 10

Write-Host "`n=== Create an A record ===" -ForegroundColor Cyan
New-DnsRecord -Name "api-test" -Type "A" -Content "10.0.0.1" -Ttl 300 | ConvertTo-Json

Write-Host "`n=== Update the record ===" -ForegroundColor Cyan
Set-DnsRecord -Name "api-test" -Type "A" -OldContent "10.0.0.1" -NewContent "10.0.0.2" -Ttl 300 | ConvertTo-Json

Write-Host "`n=== Delete the record ===" -ForegroundColor Cyan
Remove-DnsRecord -Name "api-test" -Type "A" -Content "10.0.0.2" | ConvertTo-Json

Write-Host "`n=== DDNS update ===" -ForegroundColor Cyan
Update-DdnsRecord -Name "home" | ConvertTo-Json
