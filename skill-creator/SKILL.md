---
name: skill-creator
description: "Create and maintain Agent Skills following the official specification. Use when designing new skills, structuring existing skills, or packaging skills for distribution. Includes validation with skills-ref and privacy protection checks."
license: Apache-2.0
compatibility: "Requires Python 3.10+ and uv for validation scripts"
metadata:
  author: OpenClaw
  version: "3.0"
  category: skill-development
---

# Skill Creator

Create and maintain Agent Skills that follow the official specification.

## Quick Start

### Create a New Skill

```bash
mkdir my-new-skill
cd my-new-skill
```

Create SKILL.md:
```markdown
---
name: my-new-skill
description: "Describe what this skill does and when to use it."
---

# My New Skill

Brief description and usage instructions.
```

### Validate Your Skill

First install skills-ref:
```bash
cd /tmp && git clone https://github.com/agentskills/agentskills.git
cd agentskills/skills-ref && uv pip install -e .
```

Validate with skills-ref:
```bash
uv run skills-ref validate ./my-new-skill
```

Also run the extended validation:
```bash
uv run scripts/validate-skill.py ./my-new-skill
```

## Skill Anatomy

```
skill-name/
├── SKILL.md              # Required: YAML frontmatter + Markdown
├── scripts/              # Optional: Executable code
├── references/           # Optional: Detailed documentation
└── assets/               # Optional: Static files
```

## Privacy Warning

**NEVER include PII in skill files.** Check:
- No real names, emails, phone numbers
- No Feishu Open IDs (use fake ones)
- No API keys or credentials
- No internal hostnames/IPs

See [references/privacy-guide.md](references/privacy-guide.md) for complete checklist.

## References

- **[references/specification.md](references/specification.md)**: Complete specification
- **[references/structure-patterns.md](references/structure-patterns.md)**: Structure patterns
- **[references/progressive-disclosure.md](references/progressive-disclosure.md)**: Progressive disclosure
- **[references/script-guide.md](references/script-guide.md)**: Script design guide
- **[references/validation.md](references/validation.md)**: Validation criteria
- **[references/privacy-guide.md](references/privacy-guide.md)**: PII checklist
