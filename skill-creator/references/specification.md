# Agent Skills Specification Reference

Complete reference for the Agent Skills format specification.

## Directory Structure

A skill is a directory containing at minimum a `SKILL.md` file:

```
skill-name/
└── SKILL.md          # Required
```

Optional directories:
- `scripts/` - Executable code
- `references/` - Additional documentation
- `assets/` - Static files (templates, images, data)

## SKILL.md Format

The `SKILL.md` file must contain YAML frontmatter followed by Markdown content.

### Frontmatter Fields

| Field           | Required | Constraints                                                                 |
|-----------------|----------|-----------------------------------------------------------------------------|
| `name`          | Yes      | Max 64 chars. Lowercase letters, numbers, hyphens only. No leading/trailing hyphens. Must match directory name. |
| `description`   | Yes      | Max 1024 chars. Non-empty. Describes what the skill does AND when to use it. |
| `license`       | No       | License name or reference to bundled file.                                 |
| `compatibility` | No       | Max 500 chars. Environment requirements (product, packages, network).     |
| `metadata`      | No       | Arbitrary key-value mapping for additional metadata.                       |
| `allowed-tools` | No       | Space-delimited list of pre-approved tools (Experimental).                 |

### Name Field Requirements

- Must be 1-64 characters
- Only lowercase alphanumeric characters and hyphens (`a-z`, `0-9`, `-`)
- Must not start or end with `-`
- Must not contain consecutive hyphens (`--`)
- Must match the parent directory name

**Valid examples**:
- `pdf-processing`
- `data-analysis`
- `code-review`

**Invalid examples**:
- `PDF-Processing` (uppercase)
- `-pdf` (starts with hyphen)
- `pdf--processing` (consecutive hyphens)

### Description Field Best Practices

Good description includes:
1. What the skill does
2. When to use it
3. Specific keywords for triggering

**Good example**:
```yaml
description: "Extracts text and tables from PDF files, fills PDF forms, and merges multiple PDFs. Use when working with PDF documents or when the user mentions PDFs, forms, or document extraction."
```

**Poor example**:
```yaml
description: "Helps with PDFs."
```

### Frontmatter Example (Minimal)

```yaml
---
name: pdf-processing
description: "Extract text and tables from PDF files, fill forms, merge documents."
---
```

### Frontmatter Example (Complete)

```yaml
---
name: pdf-processing
description: "Extract text and tables from PDF files, fill forms, merge documents. Use when working with PDFs."
license: Apache-2.0
compatibility: "Requires Python 3.10+, poppler-utils, and internet access for OCR"
metadata:
  author: example-org
  version: "1.0"
  category: document-processing
---
```

## Optional Directories

### scripts/

Contains executable code that agents can run. Scripts should:
- Be self-contained or clearly document dependencies
- Include helpful error messages
- Handle edge cases gracefully

Supported languages depend on the agent implementation. Common options: Python, Bash, JavaScript.

### references/

Contains additional documentation that agents can read when needed:
- `REFERENCE.md` - Detailed technical reference
- `FORMS.md` - Form templates or structured data formats
- Domain-specific files (`finance.md`, `legal.md`, etc.)

Keep individual reference files focused. Agents load these on demand.

### assets/

Contains static resources:
- Templates (document templates, configuration templates)
- Images (diagrams, examples)
- Data files (lookup tables, schemas)

## Progressive Disclosure

Skills should be structured for efficient use of context:

1. **Metadata** (~100 tokens): `name` and `description` loaded at startup
2. **Instructions** (< 5000 tokens recommended): Full `SKILL.md` loaded when activated
3. **Resources** (as needed): Files loaded only when required

**Guideline**: Keep main `SKILL.md` under 500 lines. Move detailed reference material to separate files.

## File References

When referencing other files in your skill, use relative paths from the skill root:

```markdown
See [the reference guide](references/REFERENCE.md) for details.

Run the extraction script:
scripts/extract.py
```

Keep file references one level deep from `SKILL.md`. Avoid deeply nested reference chains.

## Validation

Use the `skills-ref` reference library to validate your skills:

```bash
skills-ref validate ./my-skill
```

This checks that your `SKILL.md` frontmatter is valid and follows all naming conventions.

## Installing skills-ref

```bash
cd /tmp && git clone https://github.com/agentskills/agentskills.git
cd agentskills/skills-ref && uv pip install -e .
```
