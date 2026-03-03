# PII Detection Patterns

Comprehensive regex patterns and detection strategies for personal identifiable information.

## Regex Patterns

### Personal Identifiers

```python
# Feishu Open IDs (32 hex chars after 'ou_')
PATTERN_FEISHU_ID = r'ou_[0-9a-f]{32}'

# Generic user IDs (16-64 alphanumeric)
PATTERN_USER_ID = r'[a-zA-Z0-9_-]{16,64}'

# Email addresses
PATTERN_EMAIL = r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'

# Phone numbers (Chinese format)
PATTERN_PHONE_CN = r'\+86\s*1[3-9]\d{9}'
PATTERN_PHONE_CN_SIMPLE = r'1[3-9]\d{9}'
```

### Personal Information

```python
# Chinese names (2-4 characters)
PATTERN_CHINESE_NAME = r'[\u4e00-\u9fa5]{2,4}'

# English names (first + last, simple pattern)
PATTERN_ENGLISH_NAME = r'[A-Z][a-z]+\s+[A-Z][a-z]+'

# File paths with home directories
PATTERN_HOME_PATH = r'/home/[^/]+/'
PATTERN_HOME_PATH_MAC = r'/Users/[^/]+/'
```

### Network & Security

```python
# IP addresses (IPv4)
PATTERN_IPV4 = r'\b(?:\d{1,3}\.){3}\d{1,3}\b'

# API keys/tokens (various patterns)
PATTERN_API_KEY = r'sk_[a-zA-Z0-9_-]{32,}'
PATTERN_TOKEN = r'token_[a-zA-Z0-9_-]{32,}'
PATTERN_BEARER_TOKEN = r'Bearer\s+[a-zA-Z0-9_-]{32,}'

# Database URLs
PATTERN_DB_URL = r'(?:postgresql|mysql|mongodb)://[a-zA-Z0-9_-]+:[a-zA-Z0-9_-]+@[a-zA-Z0-9.-]+/[a-zA-Z0-9_-]+'
```

### Internal Information

```python
# Internal hostnames
PATTERN_INTERNAL_HOST = r'[a-zA-Z0-9.-]+\.(internal|local|corp|lan)'

# Project codenames (common patterns)
PATTERN_PROJECT_CODE = r'[A-Z][a-zA-Z0-9_-]{3,20}'

# Internal URLs
PATTERN_INTERNAL_URL = r'https?://[a-zA-Z0-9.-]+\.(internal|local|corp|lan)/[a-zA-Z0-9/_-]*'
```

---

## Detection Strategy

### Multi-Pass Scanning

1. **First Pass**: Quick scan with broad patterns
2. **Second Pass**: Detailed scan with specific patterns
3. **Context Pass**: Analyze context to avoid false positives
4. **Final Pass**: Human review for edge cases

### False Positive Reduction

- Skip content in code blocks marked as examples
- Skip generic placeholders (`user@example.com`, `127.0.0.1`)
- Check context before flagging (e.g., "John" in a book quote is fine)
- Use whitelists for known safe content

---

## Replacement Strategy

### Keep Structure Consistent

```
# Original (bad)
/home/patrick/projects/secret-project

# Replacement (good)
/home/user/projects/generic-project
```

### Maintain Functionality

```
# Original (bad)
DATABASE_URL="postgresql://patrick:mypassword@localhost/mydb"

# Replacement (good)
DATABASE_URL="postgresql://user:password@localhost/database"
```

### Context-Aware Replacement

```
# Original (bad)
"Patrick said we should fix this bug"

# Replacement (good)
"A team member said we should fix this bug"
```

---

## Example Detection & Replacement

### Example 1: Feishu ID in Code

**Before:**
```python
# Real user ID
user_id = "ou_7c26f0e19219253829283b20e23a0a45"
```

**After:**
```python
# Placeholder ID
user_id = "ou_1234567890abcdef1234567890abcdef"
```

### Example 2: Email in Documentation

**Before:**
```markdown
Contact patrick@example.com for help.
```

**After:**
```markdown
Contact user@example.com for help.
```

### Example 3: Path in Script

**Before:**
```bash
cd /home/patrick/projects/my-project
```

**After:**
```bash
cd /home/user/projects/my-project
```

---

## Batch Processing Tips

### Git Pre-Commit Hook

Create a pre-commit hook that runs PII checks before allowing commits:

```bash
#!/bin/bash
# .git/hooks/pre-commit

echo "Checking for PII..."
# Run PII detection script
python scripts/check-pii.py

if [ $? -ne 0 ]; then
    echo "PII detected! Please remove before committing."
    exit 1
fi

exit 0
```

### Automated Scanning

Use scripts to scan entire directories:

```python
# scan-directory.py
import re
from pathlib import Path

def scan_directory(dir_path):
    patterns = [
        (r'ou_[0-9a-f]{32}', 'Feishu ID'),
        (r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}', 'Email'),
        # ... more patterns
    ]

    for file_path in Path(dir_path).rglob('*'):
        if file_path.is_file():
            content = file_path.read_text()
            for pattern, name in patterns:
                matches = re.findall(pattern, content)
                if matches:
                    print(f'{name} found in {file_path}: {matches[:3]}')

scan_directory('./skills')
```
