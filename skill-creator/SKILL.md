---
name: skill-creator
description: Create or update AgentSkills with proper structure, progressive disclosure, and bundled resources. Use when designing new skills, structuring existing skills, packaging skills for distribution, or when working with skill scripts, references, and assets. Follow this skill's guidance to create high-quality, maintainable, and publish-ready skills.
---

# Skill Creator

This skill provides guidance for creating effective skills.

## 🚨 PRIVACY PROTECTION - IMPORTANT

**BEFORE creating/committing any skill, ALWAYS use the privacy-protection skill!**

See the [privacy-protection skill](../privacy-protection/SKILL.md) for:
- Complete PII detection checklist
- PII detection patterns and automation scripts
- Fake data templates
- Git pre-commit hooks
- Privacy best practices

**Never include personal identifiable information (PII) in skill files.**

---

## About Skills

Skills are modular, self-contained packages that extend Codex's capabilities by providing specialized knowledge, workflows, and tools.

### What Skills Provide

1. Specialized workflows - Multi-step procedures for specific domains
2. Tool integrations - Instructions for working with specific file formats or APIs
3. Domain expertise - Company-specific knowledge, schemas, business logic
4. Bundled resources - Scripts, references, and assets for complex tasks

### Anatomy of a Skill

```
skill-name/
├── SKILL.md (required)
│   ├── YAML frontmatter (name + description)
│   └── Markdown instructions
└── Bundled Resources (optional)
    ├── scripts/    - Executable code
    ├── references/ - Documentation loaded as needed
    └── assets/     - Files used in output
```

**SKILL.md (required)**:
- Frontmatter (YAML): `name` and `description` (critical for skill triggering)
- Body (Markdown): Instructions, loaded only after skill triggers

**Bundled Resources (optional)**:
- **scripts/**: Executable code for repetitive tasks
- **references/**: Documentation loaded as needed (keeps SKILL.md lean)
- **assets/**: Files used in output (templates, images, etc.)

**What NOT to include**: README.md, INSTALLATION.md, CHANGELOG.md, etc.

---

## Core Principles

### Concise is Key
The context window is a public good. Only add context Codex doesn't already have. Prefer concise examples over verbose explanations.

### Set Appropriate Degrees of Freedom
- **High freedom**: Text-based instructions for flexible tasks
- **Medium freedom**: Pseudocode/scripts with parameters for preferred patterns
- **Low freedom**: Specific scripts for fragile operations requiring consistency

### Progressive Disclosure
Skills use 3-level loading:
1. **Metadata** (name + description) - Always in context (~100 words)
2. **SKILL.md body** - When skill triggers (<5k words)
3. **Bundled resources** - As needed (unlimited)

**See [references/progressive-disclosure.md](references/progressive-disclosure.md)** for detailed patterns and implementation guidance.

---

## Skill Creation Workflow

### Step 1: Create the Skill Directory

Directory name requirements:
- All lowercase, hyphens for spaces
- Descriptive and concise
- Max 64 characters

**Good**: `pdf-editor`, `feishu-channel`, `clawlist`
**Bad**: `PDF Editor`, `my_awesome_skill`, `too-long-skill-name`

```bash
mkdir my-new-skill
cd my-new-skill
```

### Step 2: Create SKILL.md from Template

```markdown
---
name: my-new-skill
description: [TODO: Complete and informative explanation of what the skill does and when to use it. Include WHEN to use this skill - specific scenarios, file types, or tasks that trigger it.]
---

# My New Skill

## 🚨 PRIVACY CHECK - BEFORE CONTINUING

**REMINDER: This skill MUST NOT contain any personal identifiable information (PII)!**

Before publishing or committing this skill, verify:
- [ ] No real names (use fake names like "张小明" or "Alex Chen")
- [ ] No Feishu Open IDs (use `ou_1234567890abcdef1234567890abcdef` instead)
- [ ] No email addresses (use `user@example.com` instead)
- [ ] No phone numbers (use `+86 138 1234 5678` instead)
- [ ] No personal file paths (use `/home/user/` instead)
- [ ] No API keys, tokens, or credentials
- [ ] No internal hostnames or IP addresses

---

## Overview

[TODO: 1-2 sentences explaining what this skill enables]

## When to Use This Skill

[TODO: List specific scenarios when this skill should be activated]

## How to Use This Skill

[TODO: Step-by-step instructions]

## Resources (Optional)

[Only include if needed]

### references/
[Documentation loaded as needed]

### scripts/
[Executable code for repetitive tasks]

### assets/
[Files used in output]
```

### Step 3: Customize the Template

Fill in all `[TODO]` sections:
1. **Description**: Clear, comprehensive, includes "when to use"
2. **Overview**: 1-2 sentences
3. **When to Use**: Specific scenarios
4. **How to Use**: Step-by-step instructions

**Choose a structure pattern**: See [references/structure-patterns.md](references/structure-patterns.md) for 4 common patterns (Workflow-Based, Task-Based, Reference/Guidelines, Capabilities-Based).

### Step 4: Add Resource Directories (If Needed)

Only create what's actually required:
```bash
mkdir references  # if needed
mkdir scripts     # if needed
mkdir assets      # if needed
```

### Step 5: Validate the Skill

Before publishing, verify:
- [ ] SKILL.md has valid YAML frontmatter with `name` and `description`
- [ ] Description is clear and comprehensive
- [ ] NO PII (names, IDs, emails, phone numbers, etc.)
- [ ] Skill directory name follows conventions
- [ ] No extraneous files (README.md, etc.)
- [ ] All resources are properly referenced from SKILL.md

### Step 6: Iterate

1. Use the skill on real tasks
2. Notice struggles or inefficiencies
3. Update SKILL.md or bundled resources
4. Test again

---

## References

- **[references/structure-patterns.md](references/structure-patterns.md)**: 4 common skill structure patterns with examples
- **[references/progressive-disclosure.md](references/progressive-disclosure.md)**: Progressive disclosure implementation patterns and guidelines
