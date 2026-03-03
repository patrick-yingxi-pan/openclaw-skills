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
- [ ] Scan for personal file paths (pattern: `/home/patrick/` or similar)
- [ ] Scan for API keys, tokens, credentials
- [ ] Scan for internal hostnames, IP addresses

## PII Replacement Templates

Use these fake data templates to replace real PII:

| Type | Real Example | Fake Replacement |
|------|--------------|-----------------|
| Feishu Open ID | `ou_7c26f0e19219253829283b20e23a0a45` | `ou_1234567890abcdef1234567890abcdef` |
| Name (Chinese) | 潘颖曦 | 张小明 |
| Name (English) | Patrick Pan | Alex Chen |
| Email | patrick@example.com | user@example.com |
| Email (work) | yingxi.pan@company.com | employee@company-example.com |
| Phone | +86 138 0000 0000 | +86 138 1234 5678 |
| File Path | `/home/patrick/projects/` | `/home/user/projects/` |
| File Path (Windows) | `C:\Users\Patrick\` | `C:\Users\User\` |
| API Key | `sk-abc123def456` | `sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx` |
| IP Address (Internal) | `192.168.1.100` | `192.168.1.xxx` |
| Hostname | `patrick-laptop` | `user-desktop` |
| Company Name | ACME Corp | Example Company |

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
user_id = "ou_7c26f0e19219253829283b20e23a0a45"
email = "patrick@example.com"
```

**Good** (uses fake data):
```python
user_id = "ou_1234567890abcdef1234567890abcdef"
email = "user@example.com"
```

### File Paths in Examples

**Bad**:
```bash
cd /home/patrick/projects/my-project
```

**Good**:
```bash
cd /home/user/projects/my-project
```

### Configuration Examples

**Bad**:
```yaml
database:
  host: patrick-laptop
  user: patrick
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
