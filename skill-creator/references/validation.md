# Skill Validation Checklist

Complete validation criteria for Agent Skills.

## Automated Validation (skills-ref)

Use the `skills-ref` tool to validate your skill:

```bash
skills-ref validate ./my-skill
```

This checks:
- SKILL.md exists
- YAML frontmatter is valid
- Required fields are present (name, description)
- Name format is correct
- Name matches directory name
- Description length is within limits
- No extra fields in frontmatter

## Complete Validation Checklist

### 📁 Directory Structure

- [ ] Directory name follows conventions (lowercase, hyphens only, no leading/trailing hyphens)
- [ ] Directory name matches skill name in frontmatter
- [ ] SKILL.md exists
- [ ] No extraneous files (README.md, INSTALLATION.md, CHANGELOG.md, etc.)
- [ ] Only allowed subdirectories exist (scripts/, references/, assets/)

### 📄 SKILL.md Frontmatter

- [ ] Valid YAML frontmatter at the top of the file
- [ ] `name` field present and valid
- [ ] `description` field present and valid (<= 1024 chars)
- [ ] Description includes both "what it does" and "when to use it"
- [ ] No extra fields beyond allowed ones (name, description, license, compatibility, metadata, allowed-tools)
- [ ] If using `compatibility`, it's <= 500 chars
- [ ] Strings with special characters (colons, quotes) are properly quoted

### ✍️ SKILL.md Body

- [ ] Clear title at the top
- [ ] Overview section explaining what the skill does
- [ ] "When to Use" section listing specific scenarios
- [ ] Step-by-step instructions
- [ ] References to bundled resources (if any) are present
- [ ] Links to reference files use relative paths
- [ ] Content is under 500 lines (progressive disclosure)
- [ ] No PII (names, IDs, emails, phone numbers, etc.)

### 🔧 Scripts (if present)

- [ ] Scripts are in `scripts/` directory
- [ ] Each script has a clear purpose
- [ ] Scripts are non-interactive (no TTY prompts)
- [ ] Scripts have `--help` with usage examples
- [ ] Scripts produce helpful error messages
- [ ] Scripts use structured output (JSON/CSV preferred)
- [ ] Scripts are idempotent where possible
- [ ] Dependencies are declared inline (PEP 723 for Python) or documented
- [ ] No credentials or secrets in scripts

### 📚 References (if present)

- [ ] References are in `references/` directory
- [ ] Each reference file is focused on one topic
- [ ] Reference files are linked from SKILL.md
- [ ] Links use relative paths from skill root
- [ ] No deeply nested reference chains
- [ ] No PII in reference files

### 🖼️ Assets (if present)

- [ ] Assets are in `assets/` directory
- [ ] Assets are referenced from SKILL.md or scripts
- [ ] No large binary files without justification
- [ ] No PII in asset files

### 🔒 Security & Privacy

- [ ] No personal identifiable information (PII) anywhere
- [ ] No real names (use fake names like "张小明" or "Alex Chen")
- [ ] No real Feishu Open IDs (use `ou_1234567890abcdef1234567890abcdef`)
- [ ] No real email addresses (use `user@example.com`)
- [ ] No real phone numbers (use `+86 138 1234 5678`)
- [ ] No personal file paths (use `/home/user/`)
- [ ] No API keys, tokens, or credentials
- [ ] No internal hostnames or IP addresses
- [ ] No scripts that perform destructive operations without safeguards

### 📝 Documentation Quality

- [ ] Instructions are clear and unambiguous
- [ ] Examples are provided where helpful
- [ ] Common edge cases are covered
- [ ] Terminology is consistent throughout
- [ ] References to external tools include version pins where applicable

## Common Validation Issues and Fixes

### Issue: YAML Parse Error

**Problem**:
```
Invalid YAML in frontmatter: mapping values are not allowed here
```

**Cause**: Description contains a colon without quotes.

**Fix**: Wrap the description in quotes:
```yaml
description: "This is a description: it has a colon"
```

### Issue: Name Doesn't Match Directory

**Problem**:
```
Directory name 'my-skill' must match skill name 'MySkill'
```

**Fix**: Rename directory or change name in frontmatter to match (use lowercase, hyphens).

### Issue: Invalid Characters in Name

**Problem**:
```
Skill name 'my_skill' contains invalid characters
```

**Fix**: Use hyphens instead of underscores: `my-skill`

### Issue: Description Too Long

**Problem**:
```
Description exceeds 1024 character limit
```

**Fix**: Shorten the description or move details to SKILL.md body.

## Pre-publish Checklist

Before publishing a skill:

1. [ ] Run `skills-ref validate` and fix all errors
2. [ ] Go through the complete validation checklist above
3. [ ] Test the skill on a real task
4. [ ] Verify no PII slipped through
5. [ ] Check that all references work correctly
6. [ ] Ensure scripts (if any) run without errors
7. [ ] Verify progressive disclosure is applied correctly
8. [ ] Read SKILL.md one more time for clarity
