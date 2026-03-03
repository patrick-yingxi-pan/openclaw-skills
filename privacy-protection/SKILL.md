---
name: privacy-protection
description: Detect and remove personal identifiable information (PII) from skill files, documents, and code. Use when creating/committing skills, processing sensitive data, or publishing content publicly.
---

# Privacy Protection

Essential guidance for detecting and removing personal identifiable information (PII) from all skill files and content.

## 🚨 ALWAYS USE THIS BEFORE CREATING/COMMITTING ANY SKILL!

**Failure to remove PII can expose sensitive personal information.**

## PII Detection Checklist

**BEFORE creating/committing/publishing ANY skill or content, ALWAYS go through this complete checklist:**

### Personal Identifiers
- [ ] Scan for Feishu Open IDs (pattern: `ou_` followed by 32 hex characters)
  - Replace with: `ou_1234567890abcdef1234567890abcdef`
- [ ] Scan for user IDs (any 16-64 character alphanumeric IDs)
  - Replace with: `user_1234567890abcdef`

### Personal Information
- [ ] Scan for email addresses (pattern: `*@*.*`)
  - Replace with: `user@example.com`
- [ ] Scan for phone numbers (pattern: `+86` or `13x`/`15x`/17x`/18x` followed by 9 digits)
  - Replace with: `+86 138 1234 5678`
- [ ] Scan for Chinese names (2-4 Chinese characters)
  - Replace with: `张小明` or `Alex Chen`
- [ ] Scan for English names (first + last name combinations)
  - Replace with: `John Doe` or `Jane Smith`

### Location & Paths
- [ ] Scan for personal file paths (pattern: `/home/*/` or `/Users/*/`)
  - Replace with: `/home/user/`
- [ ] Scan for internal hostnames, IP addresses
  - Replace with generic placeholders or remove
- [ ] Scan for specific location references (cities, addresses, coordinates)
  - Replace with generic placeholders or remove

### Security & Credentials
- [ ] Scan for API keys, tokens, credentials
  - Replace with placeholder comments or remove entirely
- [ ] Scan for passwords, secrets, private keys
  - Remove entirely or replace with `[REDACTED]`
- [ ] Scan for database URLs, connection strings
  - Replace with placeholders or remove

### Business & Project Information
- [ ] Scan for internal project names, codenames
  - Replace with generic placeholders
- [ ] Scan for internal hostnames, server names
  - Replace with generic placeholders
- [ ] Scan for internal URLs, intranet references
  - Replace with generic placeholders or remove

### Content & Context
- [ ] Scan for conversation transcripts, chat histories
  - Anonymize or remove entirely
- [ ] Scan for personal opinions, sensitive comments
  - Anonymize or remove
- [ ] Scan for specific dates, timelines related to individuals
  - Generalize or remove

---

## Quick Reference: Fake Data Templates

| Type | Real Example | Fake Replacement |
|------|--------------|-----------------|
| Feishu ID | `ou_7c26f0e19219253829283b20e23a0a45` | `ou_1234567890abcdef1234567890abcdef` |
| User ID | `user_abc123def456` | `user_1234567890abcdef` |
| Name (Chinese) | 赵玉鹏 / Patrick Pan | 张小明 / Alex Chen |
| Name (English) | John Smith | John Doe |
| Email | patrick@example.com | user@example.com |
| Phone | +86 138 0000 0000 | +86 138 1234 5678 |
| Path | /home/patrick/ | /home/user/ |
| API Key | sk_live_abc123def456 | `[REDACTED]` or remove |
| Database URL | postgresql://user:pass@localhost/db | postgresql://user:password@localhost/database |

---

## Automated Detection Patterns

### Regular Expressions for Common PII

Use these regex patterns to scan for PII:

```python
# Feishu Open IDs
r'ou_[0-9a-f]{32}'

# Email addresses
r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'

# Phone numbers (Chinese)
r'\+86\s*1[3-9]\d{9}'
r'1[3-9]\d{9}'

# Chinese names (simplified)
r'[\u4e00-\u9fa5]{2,4}'

# File paths (home directories)
r'/home/[^/]+/'
r'/Users/[^/]+/'

# IP addresses
r'\b(?:\d{1,3}\.){3}\d{1,3}\b'
```

---

## Step-by-Step PII Removal Workflow

### 1. Scan
- Read through all content carefully
- Use regex patterns for automated scanning
- Check all files: SKILL.md, scripts/, references/, assets/

### 2. Identify
- Mark all PII occurrences
- Note context to understand what's sensitive
- Determine appropriate replacement strategy

### 3. Replace
- Use appropriate fake data from templates
- Keep structure consistent (e.g., don't change path structure)
- Maintain functionality where possible

### 4. Verify
- Scan again to ensure nothing was missed
- Check that functionality is preserved
- Confirm no sensitive information remains

### 5. Document (optional)
- Note what was removed if needed for context
- Keep a private record of original data if required
- Document replacement patterns for consistency

---

## Best Practices

### Always Remove
- Real names, email addresses, phone numbers
- Real user IDs, API keys, credentials
- Real file paths with personal information
- Real hostnames, IP addresses
- Real conversation content, chat histories

### Can Keep If Anonymized
- Technical content, code examples
- General workflows, processes
- Domain knowledge that's not personal
- Generic templates, patterns

### When In Doubt
- **Remove it!** It's safer than exposing PII
- When unsure, use a placeholder
- Ask the user if something is sensitive

---

## Common Edge Cases

### Mixed Content
When content has both sensitive and non-sensitive parts:
- Anonymize the sensitive parts
- Keep the non-sensitive parts intact
- Example: "Patrick fixed the bug" → "John fixed the bug"

### Contextual PII
Information that's not obviously PII but can identify someone:
- "The CEO of Company X said..." → "A company leader said..."
- "The team in Beijing office..." → "The team in an office..."
- "The project started on Patrick's birthday..." → "The project started on a special day..."

---

## Additional Resources

See [references/patterns.md](references/patterns.md) for:
- More detailed regex patterns
- PII detection examples
- Replacement strategy examples
- Automation scripts for common tasks

See [references/automation.md](references/automation.md) for:
- Automated scanning scripts
- Batch PII removal tools
- Integration with git pre-commit hooks

---

## Remember: PRIVACY FIRST!

**Always scan for and remove PII BEFORE:**
- Creating a new skill
- Committing to git
- Publishing content publicly
- Sharing with others

**When in doubt: REMOVE IT!**

It's better to have generic content than to expose someone's personal information.
