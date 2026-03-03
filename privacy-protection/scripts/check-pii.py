#!/usr/bin/env python3
"""
PII Detection Script
Scans files for personal identifiable information.
"""

import re
import sys
from pathlib import Path

# PII Detection Patterns
PATTERNS = {
    'Feishu ID': r'ou_[0-9a-f]{32}',
    'Email': r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}',
    'Phone (CN)': r'\+86\s*1[3-9]\d{9}',
    'Phone (CN simple)': r'1[3-9]\d{9}',
    'Chinese Name': r'[\u4e00-\u9fa5]{2,4}',
    'Home Path (Linux)': r'/home/[^/]+/',
    'Home Path (macOS)': r'/Users/[^/]+/',
    'IP Address': r'\b(?:\d{1,3}\.){3}\d{1,3}\b',
    'API Key': r'sk_[a-zA-Z0-9_-]{32,}',
    'Database URL': r'(?:postgresql|mysql|mongodb)://[a-zA-Z0-9_-]+:[a-zA-Z0-9_-]+@[a-zA-Z0-9.-]+/[a-zA-Z0-9_-]+',
}

# Whitelisted content (not considered PII)
WHITELIST = {
    'user@example.com',
    '127.0.0.1',
    'localhost',
    'ou_1234567890abcdef1234567890abcdef',
    '张小明',
    'Alex Chen',
    'John Doe',
    'Jane Smith',
    '/home/user/',
}

def scan_file(file_path: Path) -> list[tuple[str, list[str]]]:
    """Scan a single file for PII."""
    findings = []

    try:
        content = file_path.read_text()

        for name, pattern in PATTERNS.items():
            matches = re.findall(pattern, content)
            # Filter out whitelisted content
            matches = [m for m in matches if m not in WHITELIST]
            if matches:
                findings.append((name, matches))

    except Exception as e:
        print(f"Error reading {file_path}: {e}", file=sys.stderr)

    return findings

def scan_directory(dir_path: Path) -> dict[Path, list[tuple[str, list[str]]]]:
    """Scan all files in a directory."""
    all_findings = {}

    for file_path in dir_path.rglob('*'):
        if file_path.is_file() and not file_path.name.startswith('.'):
            # Skip binary files
            if file_path.suffix in ['.png', '.jpg', '.jpeg', '.gif', '.pdf', '.zip', '.tar', '.gz']:
                continue

            findings = scan_file(file_path)
            if findings:
                all_findings[file_path] = findings

    return all_findings

def main():
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <directory>")
        sys.exit(1)

    dir_path = Path(sys.argv[1])

    if not dir_path.is_dir():
        print(f"Error: {dir_path} is not a directory", file=sys.stderr)
        sys.exit(1)

    print(f"Scanning {dir_path} for PII...\n")

    findings = scan_directory(dir_path)

    if not findings:
        print("✅ No PII detected!")
        sys.exit(0)

    print("⚠️ PII detected:\n")

    for file_path, file_findings in findings.items():
        print(f"📁 {file_path}")
        for name, matches in file_findings:
            print(f"  🔍 {name}: {len(matches)} matches")
            # Show first 3 matches
            for match in matches[:3]:
                print(f"     - {match}")
            if len(matches) > 3:
                print(f"     ... and {len(matches) - 3} more")
        print()

    sys.exit(1)

if __name__ == "__main__":
    main()
