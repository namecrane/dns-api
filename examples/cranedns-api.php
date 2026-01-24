<?php
/**
 * CraneDNS API Client Example - PHP
 *
 * This script demonstrates how to use all CraneDNS API methods.
 *
 * Usage:
 *   1. Set your $apiKey and $baseUrl below
 *   2. Run: php cranedns-api.php
 */

$apiKey = 'your-api-key';
$baseUrl = 'https://namecrane.org/index.php';

/**
 * Make an API request
 *
 * @param string $method HTTP method (GET or POST)
 * @param array $params Query parameters
 * @param array|null $body Request body for POST requests
 * @return array Decoded JSON response
 */
function apiRequest(string $method, array $params = [], ?array $body = null): array
{
    global $apiKey, $baseUrl;

    $params['m'] = 'cranedns';
    $params['action'] = 'api';
    $url = $baseUrl . '?' . http_build_query($params);

    $ch = curl_init();
    curl_setopt_array($ch, [
        CURLOPT_URL => $url,
        CURLOPT_RETURNTRANSFER => true,
        CURLOPT_HTTPHEADER => [
            'X-API-Key: ' . $apiKey,
            'Content-Type: application/json'
        ]
    ]);

    if ($body !== null) {
        curl_setopt($ch, CURLOPT_POST, true);
        curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($body));
    }

    $response = curl_exec($ch);
    $httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);

    return json_decode($response, true) ?? ['error' => 'Invalid response'];
}

/**
 * List all DNS records
 *
 * Example Response:
 * {
 *     "success": true,
 *     "records": [
 *         {"name": "@", "type": "A", "content": "192.168.1.1", "ttl": 3600},
 *         {"name": "www", "type": "CNAME", "content": "example.com.", "ttl": 3600}
 *     ]
 * }
 *
 * @param string|null $type Optional record type filter
 * @return array
 */
function listRecords(?string $type = null): array
{
    $params = ['method' => 'list'];
    if ($type) {
        $params['type'] = $type;
    }
    return apiRequest('GET', $params);
}

/**
 * Create a new DNS record
 *
 * Example Response:
 * {"success": true, "message": "Record created"}
 *
 * Error Response:
 * {"success": false, "error": "Invalid IPv4 address format"}
 *
 * @param string $name Record name (@ for root)
 * @param string $type Record type (A, AAAA, CNAME, etc.)
 * @param string $content Record value
 * @param int $ttl Time to live in seconds
 * @return array
 */
function createRecord(string $name, string $type, string $content, int $ttl = 3600): array
{
    return apiRequest('POST', ['method' => 'create'], [
        'name' => $name,
        'type' => $type,
        'content' => $content,
        'ttl' => $ttl
    ]);
}

/**
 * Update an existing DNS record
 *
 * Example Response:
 * {"success": true, "message": "Record updated"}
 *
 * Error Response:
 * {"success": false, "error": "name, type, old_content, and content are required"}
 *
 * @param string $name Record name
 * @param string $type Record type
 * @param string $oldContent Current record value
 * @param string $newContent New record value
 * @param int $ttl Time to live in seconds
 * @return array
 */
function updateRecord(string $name, string $type, string $oldContent, string $newContent, int $ttl = 3600): array
{
    return apiRequest('POST', ['method' => 'update'], [
        'name' => $name,
        'type' => $type,
        'old_content' => $oldContent,
        'content' => $newContent,
        'ttl' => $ttl
    ]);
}

/**
 * Delete a DNS record
 *
 * Example Response:
 * {"success": true, "message": "Record deleted"}
 *
 * Error Response:
 * {"success": false, "error": "name, type, and content are required"}
 *
 * @param string $name Record name
 * @param string $type Record type
 * @param string $content Record value
 * @return array
 */
function deleteRecord(string $name, string $type, string $content): array
{
    return apiRequest('POST', ['method' => 'delete'], [
        'name' => $name,
        'type' => $type,
        'content' => $content
    ]);
}

/**
 * DDNS update - update A/AAAA record with client's IP
 *
 * Example Response:
 * {
 *     "success": true,
 *     "message": "DDNS updated",
 *     "name": "home",
 *     "type": "A",
 *     "content": "203.0.113.45"
 * }
 *
 * Error Response:
 * {"success": false, "error": "Could not detect a valid IPv6 address"}
 *
 * @param string $name Record name
 * @param string $type A or AAAA
 * @return array
 */
function ddnsUpdate(string $name, string $type = 'A'): array
{
    return apiRequest('GET', ['method' => 'ddns', 'name' => $name, 'type' => $type]);
}

// Example usage
if (php_sapi_name() === 'cli') {
    echo "=== List all records ===\n";
    print_r(listRecords());

    echo "\n=== List only A records ===\n";
    print_r(listRecords('A'));

    echo "\n=== Create an A record ===\n";
    print_r(createRecord('api-test', 'A', '10.0.0.1', 300));

    echo "\n=== Update the record ===\n";
    print_r(updateRecord('api-test', 'A', '10.0.0.1', '10.0.0.2', 300));

    echo "\n=== Delete the record ===\n";
    print_r(deleteRecord('api-test', 'A', '10.0.0.2'));

    echo "\n=== DDNS update ===\n";
    print_r(ddnsUpdate('home'));
}
