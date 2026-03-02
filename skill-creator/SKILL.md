---
name: skill-creator
description: Create or update AgentSkills with proper structure, progressive disclosure, and bundled resources. Use when designing new skills, structuring existing skills, packaging skills for distribution, or when working with skill scripts, references, and assets. Follow this skill's guidance to create high-quality, maintainable, and publish-ready skills. IMPORTANT: ALWAYS check for and remove/replace personal identifiable information (PII) in skill files - names, user IDs, emails, phone numbers, addresses, etc. Use random placeholder data instead of real personal information.
---

# Skill Creator

This skill provides guidance for creating effective skills.

## 🚨 PRIVACY PROTECTION - IMPORTANT

### Critical Privacy Rule

**NEVER include personal identifiable information (PII) in skill files.**

When creating or updating skills, ALWAYS scan for and remove/replace:

- **Names** - Real names of users, contributors, or any individuals
- **User IDs** - Feishu Open IDs, Discord user IDs, Slack user IDs, etc.
- **Email addresses** - Any email addresses (personal or corporate)
- **Phone numbers** - Any phone numbers
- **Home addresses** - Physical addresses, locations
- **API keys** - Secrets, tokens, credentials
- **Account numbers** - Any account identifiers
- **IP addresses** - Internal or external IPs
- **Hostnames** - Internal server names
- **File paths** - Personal directory paths (use generic paths instead)

### How to Replace PII

Use realistic-looking but fake placeholder data instead:

**Instead of:**
- Real name: "Patrick Pan"
- Feishu ID: "ou_7c26f0e19219253829283b20e23a0a45"
- Email: "patrick@example.com"
- Phone: "+86 138 0000 0000"

**Use:**
- Fake name: "Alex Chen" or "User Name"
- Fake ID: "ou_1234567890abcdef1234567890abcdef"
- Fake email: "user@example.com" or "alex.chen@example.org"
- Fake phone: "+86 138 1234 5678"

### PII Check Checklist

**BEFORE creating/committing any skill, ALWAYS go through this checklist:**

- [ ] Scan for Feishu Open IDs (pattern: `ou_` followed by 32 hex characters)
  - Replace with: `ou_1234567890abcdef1234567890abcdef`
- [ ] Scan for email addresses (pattern: `*@*.*`)
  - Replace with: `user@example.com` or `alex.chen@example.org`
- [ ] Scan for phone numbers (pattern: `+86` or `13x`/`15x`/`17x`/`18x` followed by 9 digits)
  - Replace with: `+86 138 1234 5678` or `13812345678`
- [ ] Scan for Chinese names (2-4 Chinese characters)
  - Replace with: `张小明` or `Alex Chen`
- [ ] Scan for personal file paths (pattern: `/home/patrick/` or similar)
  - Replace with: `/home/user/` or generic paths
- [ ] Scan for API keys, tokens, credentials (long random strings)
  - Replace with placeholder comments or remove entirely
- [ ] Scan for internal hostnames, IP addresses
  - Replace with generic placeholders or remove
- [ ] Scan for any other personal identifiable information
  - When in doubt, replace with fake data

### Quick Reference: Fake Data Templates

| Type | Real Example | Fake Replacement |
|------|--------------|-----------------|
| Feishu ID | `ou_7c26f0e19219253829283b20e23a0a45` | `ou_1234567890abcdef1234567890abcdef` |
| Name | Patrick Pan | 张小明 / Alex Chen |
| Email | patrick@example.com | user@example.com |
| Phone | +86 138 0000 0000 | +86 138 1234 5678 |
| Path | /home/patrick/ | /home/user/ |

### Verification

Always manually verify after making changes:
1. Read through the skill files
2. Check that no real personal information remains
3. Confirm that placeholder data looks realistic
4. Test that the skill still works correctly

---

## About Skills

Skills are modular, self-contained packages that extend Codex's capabilities by providing
specialized knowledge, workflows, and tools. Think of them as "onboarding guides" for specific
domains or tasks—they transform Codex from a general-purpose agent into a specialized agent
equipped with procedural knowledge that no model can fully possess.

### What Skills Provide

1. Specialized workflows - Multi-step procedures for specific domains
2. Tool integrations - Instructions for working with specific file formats or APIs
3. Domain expertise - Company-specific knowledge, schemas, business logic
4. Bundled resources - Scripts, references, and assets for complex and repetitive tasks

## Core Principles

### Concise is Key

The context window is a public good. Skills share the context window with everything else Codex needs: system prompt, conversation history, other Skills' metadata, and the actual user request.

**Default assumption: Codex is already very smart.** Only add context Codex doesn't already have. Challenge each piece of information: "Does Codex really need this explanation?" and "Does this paragraph justify its token cost?"

Prefer concise examples over verbose explanations.

### Set Appropriate Degrees of Freedom

Match the level of specificity to the task's fragility and variability:

**High freedom (text-based instructions)**: Use when multiple approaches are valid, decisions depend on context, or heuristics guide the approach.

**Medium freedom (pseudocode or scripts with parameters)**: Use when a preferred pattern exists, some variation is acceptable, or configuration affects behavior.

**Low freedom (specific scripts, few parameters)**: Use when operations are fragile and error-prone, consistency is critical, or a specific sequence must be followed.

Think of Codex as exploring a path: a narrow bridge with cliffs needs specific guardrails (low freedom), while an open field allows many routes (high freedom).

### Anatomy of a Skill

Every skill consists of a required SKILL.md file and optional bundled resources:

```
skill-name/
├── SKILL.md (required)
│   ├── YAML frontmatter metadata (required)
│   │   ├── name: (required)
│   │   └── description: (required)
│   └── Markdown instructions (required)
└── Bundled Resources (optional)
    ├── scripts/          - Executable code (Python/Bash/etc.)
    ├── references/       - Documentation intended to be loaded into context as needed
    └── assets/           - Files used in output (templates, icons, fonts, etc.)
```

#### SKILL.md (required)

Every SKILL.md consists of:

- **Frontmatter** (YAML): Contains `name` and `description` fields. These are the only fields that Codex reads to determine when the skill gets used, thus it is very important to be clear and comprehensive in describing what the skill is, and when it should be used.
- **Body** (Markdown): Instructions and guidance for using the skill. Only loaded AFTER the skill triggers (if at all).

#### Bundled Resources (optional)

##### Scripts (`scripts/`)

Executable code (Python/Bash/etc.) for tasks that require deterministic reliability or are repeatedly rewritten.

- **When to include**: When the same code is being rewritten repeatedly or deterministic reliability is needed
- **Example**: `scripts/rotate_pdf.py` for PDF rotation tasks
- **Benefits**: Token efficient, deterministic, may be executed without loading into context
- **Note**: Scripts may still need to be read by Codex for patching or environment-specific adjustments

##### References (`references/`)

Documentation and reference material intended to be loaded as needed into context to inform Codex's process and thinking.

- **When to include**: For documentation that Codex should reference while working
- **Examples**: `references/finance.md` for financial schemas, `references/mnda.md` for company NDA template, `references/policies.md` for company policies, `references/api_docs.md` for API specifications
- **Use cases**: Database schemas, API documentation, domain knowledge, company policies, detailed workflow guides
- **Benefits**: Keeps SKILL.md lean, loaded only when Codex determines it's needed
- **Best practice**: If files are large (>10k words), include grep search patterns in SKILL.md
- **Avoid duplication**: Information should live in either SKILL.md or references files, not both. Prefer references files for detailed information unless it's truly core to the skill—this keeps SKILL.md lean while making information discoverable without hogging the context window. Keep only essential procedural instructions and workflow guidance in SKILL.md; move detailed reference material, schemas, and examples to references files.

##### Assets (`assets/`)

Files not intended to be loaded into context, but rather used within the output Codex produces.

- **When to include**: When the skill needs files that will be used in the final output
- **Examples**: `assets/logo.png` for brand assets, `assets/slides.pptx` for PowerPoint templates, `assets/frontend-template/` for HTML/React boilerplate, `assets/font.ttf` for typography
- **Use cases**: Templates, images, icons, boilerplate code, fonts, sample documents that get copied or modified
- **Benefits**: Separates output resources from documentation, enables Codex to use files without loading them into context

#### What to Not Include in a Skill

A skill should only contain essential files that directly support its functionality. Do NOT create extraneous documentation or auxiliary files, including:

- README.md
- INSTALLATION_GUIDE.md
- QUICK_REFERENCE.md
- CHANGELOG.md
- etc.

The skill should only contain the information needed for an AI agent to do the job at hand. It should not contain auxiliary context about the process that went into creating it, setup and testing procedures, user-facing documentation, etc. Creating additional documentation files just adds clutter and confusion.

### Progressive Disclosure Design Principle

Skills use a three-level loading system to manage context efficiently:

1. **Metadata (name + description)** - Always in context (~100 words)
2. **SKILL.md body** - When skill triggers (<5k words)
3. **Bundled resources** - As needed by Codex (Unlimited because scripts can be executed without reading into context window)

#### Progressive Disclosure Patterns

Keep SKILL.md body to the essentials and under 500 lines to minimize context bloat. Split content into separate files when approaching this limit. When splitting out content into other files, it is very important to reference them from SKILL.md and describe clearly when to read them, to ensure the reader of the skill knows they exist and when to use them.

**Key principle:** When a skill supports multiple variations, frameworks, or options, keep only the core workflow and selection guidance in SKILL.md. Move variant-specific details (patterns, examples, configuration) into separate reference files.

**Pattern 1: High-level guide with references**

```markdown
# PDF Processing

## Quick start

Extract text with pdfplumber:
[code example]

## Advanced features

- **Form filling**: See [FORMS.md](FORMS.md) for complete guide
- **API reference**: See [REFERENCE.md](REFERENCE.md) for all methods
- **Examples**: See [EXAMPLES.md](EXAMPLES.md) for common patterns
```

Codex loads FORMS.md, REFERENCE.md, or EXAMPLES.md only when needed.

**Pattern 2: Domain-specific organization**

For Skills with multiple domains, organize content by domain to avoid loading irrelevant context:

```
bigquery-skill/
├── SKILL.md (overview and navigation)
└── reference/
    ├── finance.md (revenue, billing metrics)
    ├── sales.md (opportunities, pipeline)
    ├── product.md (API usage, features)
    └── marketing.md (campaigns, attribution)
```

When a user asks about sales metrics, Codex only reads sales.md.

Similarly, for skills supporting multiple frameworks or variants, organize by variant:

```
cloud-deploy/
├── SKILL.md (workflow + provider selection)
└── references/
    ├── aws.md (AWS deployment patterns)
    ├── gcp.md (GCP deployment patterns)
    └── azure.md (Azure deployment patterns)
```

When the user chooses AWS, Codex only reads aws.md.

**Pattern 3: Conditional details**

Show basic content, link to advanced content:

```markdown
# DOCX Processing

## Creating documents

Use docx-js for new documents. See [DOCX-JS.md](DOCX-JS.md).

## Editing documents

For simple edits, modify the XML directly.

**For tracked changes**: See [REDLINING.md](REDLINING.md)
**For OOXML details**: See [OOXML.md](OOXML.md)
```

Codex reads REDLINING.md or OOXML.md only when the user needs those features.

**Important guidelines:**

- **Avoid deeply nested references** - Keep references one level deep from SKILL.md. All reference files should link directly from SKILL.md.
- **Structure longer reference files** - For files longer than 100 lines, include a table of contents at the top so Codex can see the full scope when previewing.

---

## Skill Creation Workflow

Follow this step-by-step process to create a new skill:

### Step 1: Create the Skill Directory

Create a new directory for your skill. The directory name should be:
- All lowercase
- Use hyphens for spaces
- Descriptive and concise
- Maximum 64 characters

**Good examples:**
- `pdf-editor`
- `feishu-channel`
- `clawlist`

**Bad examples:**
- `PDF Editor` (spaces)
- `my_awesome_skill` (underscores)
- `this-is-a-very-long-skill-name-that-is-way-too-long` (too long)

Create the directory:
```bash
mkdir my-new-skill
cd my-new-skill
```

### Step 2: Create SKILL.md from Template

Create a `SKILL.md` file using this template:

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

If you find any PII, replace it with realistic fake data BEFORE continuing.

---

## Overview

[TODO: 1-2 sentences explaining what this skill enables]

## When to Use This Skill

[TODO: List specific scenarios when this skill should be activated]

## How to Use This Skill

[TODO: Step-by-step instructions for using the skill]

## Resources (Optional)

[Only include this section if you need additional resources]

### references/
[Documentation that should be loaded into context as needed]

### scripts/
[Executable code for repetitive tasks]

### assets/
[Files used in output (templates, images, etc.)]
```

### Step 3: Customize the Template

Fill in all the `[TODO]` sections:

1. **Name**: Already set from the directory name
2. **Description**: Write a clear, comprehensive description including:
   - What the skill does
   - When to use it (specific triggers/scenarios)
   - Any important context
3. **Overview**: 1-2 sentences explaining what the skill enables
4. **When to Use**: List specific scenarios
5. **How to Use**: Step-by-step instructions

### Step 4: Add Resource Directories (If Needed)

Only create resource directories that are actually required:

```bash
# Create references directory if needed
mkdir references

# Create scripts directory if needed
mkdir scripts

# Create assets directory if needed
mkdir assets
```

### Step 5: Validate the Skill

Before publishing, verify:

- [ ] SKILL.md has valid YAML frontmatter with `name` and `description`
- [ ] Description is clear and comprehensive
- [ ] No PII (names, IDs, emails, phone numbers, etc.)
- [ ] Skill directory name follows conventions
- [ ] No extraneous files (README.md, etc.)
- [ ] All resources are properly referenced from SKILL.md

### Step 6: Iterate and