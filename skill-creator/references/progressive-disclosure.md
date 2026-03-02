# Progressive Disclosure Patterns

Reference documentation for implementing progressive disclosure in skills. Read this when designing skill structure for context efficiency.

## Progressive Disclosure Design Principle

Skills use a three-level loading system to manage context efficiently:

1. **Metadata (name + description)** - Always in context (~100 words)
2. **SKILL.md body** - When skill triggers (<5k words)
3. **Bundled resources** - As needed by Codex (Unlimited because scripts can be executed without reading into context window)

---

## Progressive Disclosure Patterns

### Key Principle
When a skill supports multiple variations, frameworks, or options, keep only the core workflow and selection guidance in SKILL.md. Move variant-specific details (patterns, examples, configuration) into separate reference files.

Keep SKILL.md body to the essentials and under 500 lines to minimize context bloat. Split content into separate files when approaching this limit. When splitting out content into other files, it is very important to reference them from SKILL.md and describe clearly when to read them, to ensure the reader of the skill knows they exist and when to use them.

---

## Pattern 1: High-level guide with references

**Structure**:
```markdown
# PDF Processing

## Quick start

Extract text with pdfplumber:
[code example]

## Advanced features

- **Form filling**: See [references/forms.md](references/forms.md) for complete guide
- **API reference**: See [references/api-reference.md](references/api-reference.md) for all methods
- **Examples**: See [references/examples.md](references/examples.md) for common patterns
```

**How it works**:
- Core quick start in SKILL.md
- Advanced features linked to reference files
- Codex loads references only when needed

**When to use**:
- Skills with both basic and advanced usage
- Complex APIs with many methods
- Skills with lots of examples

---

## Pattern 2: Domain-specific organization

**Directory structure**:
```
bigquery-skill/
├── SKILL.md (overview and navigation)
└── references/
    ├── finance.md (revenue, billing metrics)
    ├── sales.md (opportunities, pipeline)
    ├── product.md (API usage, features)
    └── marketing.md (campaigns, attribution)
```

**SKILL.md excerpt**:
```markdown
# BigQuery Skill

## Overview
This skill helps with BigQuery queries across different business domains.

## Domain Guides

- **Finance**: See [references/finance.md](references/finance.md) for revenue and billing metrics
- **Sales**: See [references/sales.md](references/sales.md) for opportunities and pipeline
- **Product**: See [references/product.md](references/product.md) for API usage and features
- **Marketing**: See [references/marketing.md](references/marketing.md) for campaigns and attribution
```

**How it works**:
- SKILL.md provides overview and navigation
- Each domain has its own reference file
- When user asks about sales metrics, Codex only reads sales.md

**When to use**:
- Skills covering multiple distinct domains
- Skills with different use cases for different teams
- Large skills with organized sub-topics

---

## Pattern 3: Framework/Variant-specific organization

**Directory structure**:
```
cloud-deploy/
├── SKILL.md (workflow + provider selection)
└── references/
    ├── aws.md (AWS deployment patterns)
    ├── gcp.md (GCP deployment patterns)
    └── azure.md (Azure deployment patterns)
```

**SKILL.md excerpt**:
```markdown
# Cloud Deploy

## Overview
Deploy applications to major cloud providers.

## Provider Selection

Choose your cloud provider:

- **AWS**: See [references/aws.md](references/aws.md) for AWS deployment patterns
- **GCP**: See [references/gcp.md](references/gcp.md) for GCP deployment patterns
- **Azure**: See [references/azure.md](references/azure.md) for Azure deployment patterns

## Common Workflow

1. Choose provider (see above)
2. Configure credentials
3. Deploy application
```

**How it works**:
- Common workflow in SKILL.md
- Provider-specific details in separate files
- User chooses provider, Codex loads only that provider's guide

**When to use**:
- Skills supporting multiple frameworks
- Skills with different variants/options
- Skills with provider-specific implementations

---

## Pattern 4: Conditional details

**Structure**:
```markdown
# DOCX Processing

## Creating documents

Use docx-js for new documents. See [references/docx-js.md](references/docx-js.md).

## Editing documents

For simple edits, modify the XML directly.

**For tracked changes**: See [references/redlining.md](references/redlining.md)
**For OOXML details**: See [references/ooxml.md](references/ooxml.md)
```

**How it works**:
- Basic content shown directly
- Advanced content linked conditionally
- Codex reads advanced docs only when user needs those features

**When to use**:
- Skills with both simple and advanced features
- Complex features that are only needed occasionally
- Skills with deep technical details

---

## Important Guidelines

### Avoid deeply nested references
Keep references one level deep from SKILL.md. All reference files should link directly from SKILL.md.

**Good**:
```
SKILL.md → references/feature.md
```

**Bad**:
```
SKILL.md → references/section.md → references/subsection.md → references/detail.md
```

### Structure longer reference files
For files longer than 100 lines, include a table of contents at the top so Codex can see the full scope when previewing.

**Example TOC**:
```markdown
# AWS Deployment Guide

## Table of Contents
- Prerequisites
- Setup
- Deployment
- Troubleshooting
- Best Practices

... content ...
```
