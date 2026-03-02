# Skill Structure Patterns

Reference documentation for different skill structure patterns. Read this when deciding which structure to use for your skill.

## Common Skill Structure Patterns

### 1. Workflow-Based (best for sequential processes)

**Best for**: When there are clear step-by-step procedures

**Example**: DOCX skill with "Workflow Decision Tree" -> "Reading" -> "Creating" -> "Editing"

**Structure**:
```
## Overview
## Workflow Decision Tree
## Step 1: [First Step]
## Step 2: [Second Step]
...
```

**When to use**:
- Multi-step processes that must be followed in order
- Tasks with clear decision points
- Sequential workflows with dependencies

---

### 2. Task-Based (best for tool collections)

**Best for**: When the skill offers different operations/capabilities

**Example**: PDF skill with "Quick Start" -> "Merge PDFs" -> "Split PDFs" -> "Extract Text"

**Structure**:
```
## Overview
## Quick Start
## Task Category 1: [Category Name]
### [Task 1]
### [Task 2]
## Task Category 2: [Category Name]
...
```

**When to use**:
- Skills that provide multiple independent operations
- Tool collections with different capabilities
- Tasks that can be performed in any order

---

### 3. Reference/Guidelines (best for standards or specifications)

**Best for**: Brand guidelines, coding standards, or requirements

**Example**: Brand styling with "Brand Guidelines" -> "Colors" -> "Typography" -> "Features"

**Structure**:
```
## Overview
## Guidelines
## Specifications
## Usage
...
```

**When to use**:
- Standards and specifications
- Brand guidelines
- Coding standards
- Policy documentation
- Requirements checklists

---

### 4. Capabilities-Based (best for integrated systems)

**Best for**: When the skill provides multiple interrelated features

**Example**: Product Management with "Core Capabilities" -> numbered capability list

**Structure**:
```
## Overview
## Core Capabilities
### 1. [Feature Name]
### 2. [Feature Name]
...
```

**When to use**:
- Integrated systems with multiple features
- Complex domains with interrelated capabilities
- Skills that provide a suite of functionality

---

## Mixing Patterns

Patterns can be mixed and matched as needed. Most skills combine patterns:

**Common combinations**:
- Start with task-based, add workflow for complex operations
- Start with capabilities-based, add reference sections for standards
- Start with workflow-based, add task-based sections for side operations

**Example mixed structure**:
```
## Overview
## Quick Start (task-based)
## Core Workflow (workflow-based)
### Step 1: ...
### Step 2: ...
## Reference Guidelines (reference-based)
## Advanced Tasks (task-based)
```

---

## Choosing the Right Pattern

Ask these questions to decide:

1. **Is there a clear sequence?** → Workflow-Based
2. **Are there multiple independent operations?** → Task-Based
3. **Is it mostly standards/policies?** → Reference/Guidelines
4. **Are there interrelated features?** → Capabilities-Based

When in doubt, start with Task-Based as it's the most flexible pattern.
