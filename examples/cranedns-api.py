#!/usr/bin/env python3
"""
CraneDNS API Client Example - Python

This script demonstrates how to use all CraneDNS API methods.

Requirements:
    pip install requests

Usage:
    1. Set your API_KEY and BASE_URL below
    2. Run: python cranedns-api.py
"""

import requests
import json

# Configuration
API_KEY = "your-api-key"
BASE_URL = "https://namecrane.org/index.php"

headers = {
    "X-API-Key": API_KEY,
    "Content-Type": "application/json"
}


def list_records(record_type=None):
    """
    List all DNS records, optionally filtered by type.

    Example Response:
    {
        "success": true,
        "records": [
            {"name": "@", "type": "A", "content": "192.168.1.1", "ttl": 3600},
            {"name": "www", "type": "CNAME", "content": "example.com.", "ttl": 3600}
        ]
    }
    """
    params = {"m": "cranedns", "action": "api", "method": "list"}
    if record_type:
        params["type"] = record_type

    response = requests.get(BASE_URL, params=params, headers=headers)
    return response.json()


def create_record(name, record_type, content, ttl=3600):
    """
    Create a new DNS record.

    Example Response:
    {"success": true, "message": "Record created"}

    Error Response:
    {"success": false, "error": "Invalid IPv4 address format"}
    """
    response = requests.post(
        BASE_URL,
        params={"m": "cranedns", "action": "api", "method": "create"},
        headers=headers,
        json={
            "name": name,
            "type": record_type,
            "content": content,
            "ttl": ttl
        }
    )
    return response.json()


def update_record(name, record_type, old_content, new_content, ttl=3600):
    """
    Update an existing DNS record.

    Example Response:
    {"success": true, "message": "Record updated"}

    Error Response:
    {"success": false, "error": "name, type, old_content, and content are required"}
    """
    response = requests.post(
        BASE_URL,
        params={"m": "cranedns", "action": "api", "method": "update"},
        headers=headers,
        json={
            "name": name,
            "type": record_type,
            "old_content": old_content,
            "content": new_content,
            "ttl": ttl
        }
    )
    return response.json()


def delete_record(name, record_type, content):
    """
    Delete a DNS record.

    Example Response:
    {"success": true, "message": "Record deleted"}

    Error Response:
    {"success": false, "error": "name, type, and content are required"}
    """
    response = requests.post(
        BASE_URL,
        params={"m": "cranedns", "action": "api", "method": "delete"},
        headers=headers,
        json={
            "name": name,
            "type": record_type,
            "content": content
        }
    )
    return response.json()


def ddns_update(name, record_type="A"):
    """
    Update A/AAAA record with the client's current IP address.

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
    """
    response = requests.get(
        BASE_URL,
        params={
            "m": "cranedns",
            "action": "api",
            "method": "ddns",
            "name": name,
            "type": record_type
        },
        headers=headers
    )
    return response.json()


if __name__ == "__main__":
    # Example usage
    print("=== List all records ===")
    result = list_records()
    print(json.dumps(result, indent=2))

    print("\n=== List only A records ===")
    result = list_records("A")
    print(json.dumps(result, indent=2))

    print("\n=== Create an A record ===")
    result = create_record("api-test", "A", "10.0.0.1", 300)
    print(json.dumps(result, indent=2))

    print("\n=== Update the record ===")
    result = update_record("api-test", "A", "10.0.0.1", "10.0.0.2", 300)
    print(json.dumps(result, indent=2))

    print("\n=== Delete the record ===")
    result = delete_record("api-test", "A", "10.0.0.2")
    print(json.dumps(result, indent=2))

    print("\n=== DDNS update ===")
    result = ddns_update("home")
    print(json.dumps(result, indent=2))
