# Privacy Protection Guide

Complete guide for removing and replacing PII (Personal Identifiable Information) in skills.

## 🚨 IMPORTANT - READ FIRST

**NEVER include personal identifiable information (PII) in skill files.**

Skills are often shared publicly or with other users. Always check for and remove PII before committing or publishing.

## PII Checklist

**BEFORE creating/committing any skill, ALWAYS go through this checklist:**

- [ ] Scan for Feishu Open IDs (pattern: `ou_` followed by 32 hex characters)
- [ ] Scan for email addresses (pattern: `*@*.*`)
- [ ] Scan for phone numbers (pattern: `+86` or `13x`/`15x`/`17x`/`18x` followed by 9 digits)
- [ ] Scan for Chinese names (2-4 Chinese characters)
- [ ] Scan for personal file paths (pattern: `/home/username/` or similar)
- [ ] Scan for API keys, tokens, credentials
- [ ] Scan for internal hostnames, IP addresses

## Universal PII Regex Patterns (Based on NIST and industry standards)

Use these universal regular expressions to detect PII:

### Personal Identifiers
- **Feishu Open ID**: `\bou_[0-9a-f]{32}\b`
- **Email Address**: `\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b`
- **Phone Number (US)**: `\b(?:\+1|1)?[-.\s]?\(?[2-9]\d{2}\)?[-.\s]?\d{3}[-.\s]?\d{4}\b`
- **Phone Number (Chinese)**: `\b\+86[ -]?1[3-9][0-9]{9}\b`
- **Social Security Number (US)**: `\b(?!000|666|9\d{2})([0-8]\d{2}|7([0-6]\d|7[012]))([-]?)\d{2}\3\d{4}\b`

### Financial & Account Information
- **Credit Card Number**: `\b(?:4[0-9]{12}(?:[0-9]{3})?|5[1-5][0-9]{14}|3[47][0-9]{13}|3(?:0[0-5]|[68][0-9])[0-9]{11}|6(?:011|5[0-9]{2})[0-9]{12}|(?:2131|1800|35\d{3})\d{11})\b`
- **IP Address (IPv4)**: `\b(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\b`

### Personal Information
- **Full Name (English)**: `\b([A-Z][a-z]+)\s([A-Z][a-z]+)(?:\s([A-Z][a-z]+))?\b`
- **Date of Birth (various formats)**: `\b(0[1-9]|1[0-2])[-/]\d{2}\b|\b(19|20)\d{2}[-/]\b`
- **Street Address (US)**: `\d{1,5}\s\w.\s(\b\w*\b\s){1,2}\w*.?\b`
- **Passport Number (US)**: `\b[A-Z]{1,2}[0-9]{6,9}\b`
- **Driver's License Number (generic)**: `\b[A-Z]{1,2}[-\s]?\d{3,7}[-\s]?\d{3,7}\b`

### Location & Network
- **MAC Address**: `\b(?:[0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}\b`
- **Hostname**: `\b(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}\b`

**Note**: Regex patterns can produce false positives. Always combine with manual review.

## PII Replacement Templates

Use these fake data templates to replace real PII:

| Type | Real Example | Fake Replacement |
|------|--------------|-----------------|
| Feishu Open ID | `ou_1234567890abcdef1234567890abcdef` (example only) | `ou_1234567890abcdef1234567890abcdef` |
| Name (Chinese) | 李小明 | 张小明 |
| Name (English) | John Doe | Alex Chen |
| Email | user@real-company.com | user@example.com |
| Email (work) | employee@real-company.com | employee@company-example.com |
| Phone | +86 138 8888 8888 | +86 138 1234 5678 |
| File Path | `/home/username/projects/` | `/home/user/projects/` |
| File Path (Windows) | `C:\Users\Username\` | `C:\Users\User\` |
| API Key | `sk-abc123def456abc123def456` | `sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx` |
| IP Address (Internal) | `192.168.1.42` | `192.168.1.xxx` |
| Hostname | `user-laptop` | `user-desktop` |
| Company Name | Real Company Inc | Example Company |

## How to Scan for PII

### Quick Manual Scan

1. Open all skill files in an editor
2. Search for these patterns:
   - `ou_` (Feishu Open IDs)
   - `@` (email addresses)
   - `+86` (phone country code)
   - `/home/` (personal paths)
   - `192.168.` (internal IPs)
   - `sk-` (API keys)

### Using Command Line Tools

**Search for Feishu Open IDs**:
```bash
grep -r "ou_[0-9a-f]\{32\}" ./skill-directory
```

**Search for email addresses**:
```bash
grep -r "[a-zA-Z0-9._%+-]\+@[a-zA-Z0-9.-]\+\.[a-zA-Z]\{2,\}" ./skill-directory
```

**Search for Chinese phone numbers**:
```bash
grep -r "\+86[ -]\?1[3-9][0-9]\{9\}" ./skill-directory
```

**Search for personal paths**:
```bash
grep -r "/home/[a-z]\+" ./skill-directory
```

## Common PII Sources to Watch For

### Example Code Snippets

**Bad** (contains real PII):
```python
user_id = "ou_1234567890abcdef1234567890abcdef"
email = "user@real-company.com"
```

**Good** (uses fake data):
```python
user_id = "ou_1234567890abcdef1234567890abcdef"
email = "user@example.com"
```

### File Paths in Examples

**Bad**:
```bash
cd /home/username/projects/my-project
```

**Good**:
```bash
cd /home/user/projects/my-project
```

### Configuration Examples

**Bad**:
```yaml
database:
  host: user-laptop
  user: username
  password: secret123
```

**Good**:
```yaml
database:
  host: database-server
  user: dbuser
  password: your-password-here
```

## Edge Cases

### Mixed Content

Sometimes PII is mixed with safe content. For example:

**Before**:
```
The team (including patrick@example.com) decided to...
```

**After**:
```
The team (including user@example.com) decided to...
```

### Placeholder Comments

When you need to indicate where a user should put their own information:

**Good**:
```python
# Replace with your actual API key
api_key = "your-api-key-here"
```

Or:
```python
# Get your API key from https://example.com/settings
api_key = "sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
```

### When in Doubt

If you're not sure whether something is PII:
1. Assume it is PII
2. Replace it with a placeholder
3. Add a comment explaining what should go there

## Post-replacement Check

After replacing PII:

1. [ ] Search again using the same patterns to ensure nothing was missed
2. [ ] Read through the files to make sure the replacements make sense
3. [ ] Verify that examples still work with the placeholder data
4. [ ] Check that comments still make sense after replacements

## Tools to Help

While manual review is always recommended, these tools can help:

- **VS Code Search**: Use regex search across files
- **grep**: Command line search (see examples above)
- **git diff**: Review changes before committing to catch accidental PII

Remember: No tool is perfect. Manual review is essential.
