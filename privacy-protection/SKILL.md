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
| Feishu ID | `ou_1234567890abcdef1234567890abcdef` (example only) | `ou_1234567890abcdef1234567890abcdef` |
| User ID | `user_abc123def456` | `user_1234567890abcdef` |
| Name (Chinese) | 李小明 | 张小明 |
| Name (English) | John Doe | Alex Chen |
| Email | user@real-company.com | user@example.com |
| Phone | +86 138 8888 8888 | +86 138 1234 5678 |
| Path | /home/username/ | /home/user/ |
| API Key | `sk-abc123def456abc123def456` | `[REDACTED]` or remove |
| Database URL | postgresql://user:pass@localhost/db | postgresql://user:password@localhost/database |

---

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
- **Driver's License Number (generic format)**: `\b[A-Z]{1,2}[-\s]?\d{3,7}[-\s]?\d{3,7}\b`

### Location & Network
- **MAC Address**: `\b(?:[0-9A-Fa-f]{2}[:-]){5}[0-9A-Fa-f]{2}\b`
- **Hostname**: `\b(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}\b`

**Note**: Regex patterns can produce false positives. Always combine with manual review.

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
