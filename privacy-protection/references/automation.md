# PII Automation Tools

Scripts and tools for automated PII detection and removal.

## PII Detection Script

### `check-pii.py` (Python)

```python
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
```

**Usage:**
```bash
# Scan a single directory
python3 check-pii.py ./my-skills

# Scan current directory
python3 check-pii.py .
```

---

## Git Pre-Commit Hook

### `.git/hooks/pre-commit`

```bash
#!/bin/bash
# Git pre-commit hook for PII detection
# Save as .git/hooks/pre-commit and make executable

echo "🔍 Checking for PII before commit..."

# Run PII detection
if [ -f "scripts/check-pii.py" ]; then
    python3 scripts/check-pii.py .
    if [ $? -ne 0 ]; then
        echo "❌ PII detected! Please remove before committing."
        exit 1
    fi
else
    echo "⚠️ check-pii.py not found, skipping PII check"
fi

echo "✅ PII check passed!"
exit 0
```

**Installation:**
```bash
# Make the hook executable
chmod +x .git/hooks/pre-commit
```

---

## Batch Replacement Script

### `replace-pii.py` (Python)

```python
#!/usr/bin/env python3
"""
Batch PII Replacement Script
Replaces PII with placeholder data.
"""

import re
import sys
from pathlib import Path

# Replacement mappings
REPLACEMENTS = {
    # Feishu IDs
    r'ou_[0-9a-f]{32}': 'ou_1234567890abcdef1234567890abcdef',

    # Emails
    r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}': 'user@example.com',

    # Phone numbers
    r'\+86\s*1[3-9]\d{9}': '+86 138 1234 5678',
    r'1[3-9]\d{9}': '138 1234 5678',

    # Chinese names (simple replacement)
    r'Patrick Pan': 'Alex Chen',
    r'赵玉鹏': '张小明',

    # Home paths
    r'/home/patrick/': '/home/user/',
    r'/Users/patrick/': '/Users/user/',
}

def replace_in_file(file_path: Path) -> bool:
    """Replace PII in a single file."""
    try:
        content = file_path.read_text()
        original_content = content

        for pattern, replacement in REPLACEMENTS.items():
            content = re.sub(pattern, replacement, content)

        if content != original_content:
            file_path.write_text(content)
            return True

        return False

    except Exception as e:
        print(f"Error processing {file_path}: {e}", file=sys.stderr)
        return False

def main():
    if len(sys.argv) < 2:
        print(f"Usage: {sys.argv[0]} <file-or-directory>")
        sys.exit(1)

    path = Path(sys.argv[1])

    if path.is_file():
        changed = replace_in_file(path)
        if changed:
            print(f"✅ Updated {path}")
        else:
            print(f"ℹ️ No changes to {path}")
    elif path.is_dir():
        changed_count = 0
        for file_path in path.rglob('*'):
            if file_path.is_file() and not file_path.name.startswith('.'):
                # Skip binary files
                if file_path.suffix in ['.png', '.jpg', '.jpeg', '.gif', '.pdf', '.zip', '.tar', '.gz']:
                    continue

                if replace_in_file(file_path):
                    changed_count += 1
                    print(f"✅ Updated {file_path}")

        print(f"\nTotal files updated: {changed_count}")
    else:
        print(f"Error: {path} is not a file or directory", file=sys.stderr)
        sys.exit(1)

if __name__ == "__main__":
    main()
```

**Usage:**
```bash
# Replace in a single file
python3 replace-pii.py ./skills/my-skill/SKILL.md

# Replace in a directory
python3 replace-pii.py ./skills
```

---

## Quick Reference

### Check PII
```bash
python3 check-pii.py ./skills
```

### Replace PII
```bash
python3 replace-pii.py ./skills/my-skill
```

### Enable Git Pre-Commit Hook
```bash
chmod +x .git/hooks/pre-commit
```

**Note**: Always review changes after automated replacement!
