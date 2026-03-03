# Script Design Guide

How to design scripts for agentic use in Agent Skills.

## One-off Commands vs Bundled Scripts

### One-off Commands

Use when an existing package already does what you need:

**Python (uvx)**:
```bash
uvx ruff@0.8.0 check .
uvx black@24.10.0 .
```

**Python (pipx)**:
```bash
pipx run 'ruff==0.8.0' check .
```

**Node.js (npx)**:
```bash
npx eslint@9 --fix .
```

**Tips**:
- Pin versions for reproducibility
- State prerequisites in SKILL.md
- Move complex commands into scripts

### Referencing Scripts from SKILL.md

Use relative paths from the skill directory root:

```markdown
## Available scripts

- **`scripts/validate.sh`** — Validates configuration files
- **`scripts/process.py`** — Processes input data

## Workflow

1. Run the validation script:
   ```bash
   bash scripts/validate.sh "$INPUT_FILE"
   ```

2. Process the results:
   ```bash
   python3 scripts/process.py --input results.json
   ```
```

## Self-contained Scripts

### Python (PEP 723)

Declare dependencies inline using PEP 723:

```python
# /// script
# dependencies = [
#   "beautifulsoup4>=4.12,<5",
#   "requests>=2.31,<3",
# ]
# requires-python = ">=3.10"
# ///

from bs4 import BeautifulSoup
import requests

def main():
    response = requests.get("https://example.com")
    soup = BeautifulSoup(response.text, "html.parser")
    print(soup.title.string)

if __name__ == "__main__":
    main()
```

Run with:
```bash
uv run scripts/extract.py
```

Or with pipx:
```bash
pipx run scripts/extract.py
```

### Deno

```typescript
#!/usr/bin/env -S deno run

import * as cheerio from "npm:cheerio@1.0.0";

const html = `<html><body><h1>Welcome</h1></body></html>`;
const $ = cheerio.load(html);
console.log($("h1").text());
```

Run with:
```bash
deno run scripts/extract.ts
```

### Bun

```typescript
#!/usr/bin/env bun

import * as cheerio from "cheerio@1.0.0";

const html = `<html><body><h1>Welcome</h1></body></html>`;
const $ = cheerio.load(html);
console.log($("h1").text());
```

Run with:
```bash
bun run scripts/extract.ts
```

### Ruby

```ruby
require 'bundler/inline'

gemfile do
  source 'https://rubygems.org'
  gem 'nokogiri', '~> 1.16'
end

html = '<html><body><h1>Welcome</h1></body></html>'
doc = Nokogiri::HTML(html)
puts doc.at_css('h1').text
```

Run with:
```bash
ruby scripts/extract.rb
```

## Designing Scripts for Agentic Use

### 1. Avoid Interactive Prompts

Agents operate in non-interactive shells. They cannot respond to TTY prompts, password dialogs, or confirmation menus.

**Bad**:
```bash
$ python scripts/deploy.py
Target environment: _  # Hangs waiting for input
```

**Good**:
```bash
$ python scripts/deploy.py
Error: --env is required. Options: development, staging, production.
Usage: python scripts/deploy.py --env staging --tag v1.2.3
```

### 2. Document Usage with --help

`--help` output is the primary way an agent learns your script's interface.

```python
import argparse

def main():
    parser = argparse.ArgumentParser(
        description="Process input data and produce a summary report.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  scripts/process.py data.csv
  scripts/process.py --format csv --output report.csv data.csv
        """
    )
    parser.add_argument("INPUT_FILE", help="Input file to process")
    parser.add_argument("--format", choices=["json", "csv", "table"], 
                       default="json", help="Output format (default: json)")
    parser.add_argument("--output", help="Write output to FILE instead of stdout")
    parser.add_argument("--verbose", action="store_true", 
                       help="Print progress to stderr")
    
    args = parser.parse_args()
    # ... rest of implementation ...
```

### 3. Write Helpful Error Messages

When an agent gets an error, the message directly shapes its next attempt.

**Bad**:
```
Error: invalid input
```

**Good**:
```
Error: --format must be one of: json, csv, table.
       Received: "xml"
```

### 4. Use Structured Output

Prefer structured formats (JSON, CSV, TSV) over free-form text.

**Bad**:
```
NAME          STATUS    CREATED
my-service    running   2025-01-15
```

**Good**:
```json
{"name": "my-service", "status": "running", "created": "2025-01-15"}
```

**Separate data from diagnostics**:
- Send structured data to **stdout**
- Send progress messages, warnings, diagnostics to **stderr**

### 5. Additional Considerations

**Idempotency**: Agents may retry commands. "Create if not exists" is safer than "create and fail on duplicate."

**Input constraints**: Reject ambiguous input with a clear error rather than guessing. Use enums and closed sets where possible.

**Dry-run support**: For destructive or stateful operations, a `--dry-run` flag lets the agent preview what will happen.

**Meaningful exit codes**: Use distinct exit codes for different failure types (not found, invalid arguments, auth failure) and document them in your `--help` output.

**Safe defaults**: Consider whether destructive operations should require explicit confirmation flags (`--confirm`, `--force`) or other safeguards.

**Predictable output size**: If your script might produce large output, default to a summary and support flags like `--offset` or `--output FILE`.

## Complete Example: Python Script

```python
# /// script
# dependencies = [
#   "click>=8.0.0,<9",
#   "requests>=2.31.0,<3",
# ]
# requires-python = ">=3.10"
# ///

import click
import requests
import sys
import json

@click.command()
@click.argument('url')
@click.option('--output', '-o', help='Write output to file')
@click.option('--dry-run', is_flag=True, help='Show what would happen without doing it')
@click.option('--verbose', '-v', is_flag=True, help='Show verbose output')
def fetch(url, output, dry_run, verbose):
    """Fetch content from a URL and save as JSON."""
    
    if dry_run:
        click.echo(f"Would fetch: {url}", err=True)
        if output:
            click.echo(f"Would write to: {output}", err=True)
        return
    
    try:
        if verbose:
            click.echo(f"Fetching: {url}", err=True)
        
        response = requests.get(url, timeout=30)
        response.raise_for_status()
        
        result = {
            "url": url,
            "status_code": response.status_code,
            "content_type": response.headers.get("content-type", ""),
            "content": response.text[:1000]  # Truncate for safety
        }
        
        output_content = json.dumps(result, indent=2)
        
        if output:
            with open(output, 'w') as f:
                f.write(output_content)
            if verbose:
                click.echo(f"Wrote to: {output}", err=True)
        else:
            click.echo(output_content)
            
    except requests.exceptions.RequestException as e:
        click.echo(f"Error: {str(e)}", err=True)
        sys.exit(1)
    except IOError as e:
        click.echo(f"File error: {str(e)}", err=True)
        sys.exit(2)

if __name__ == '__main__':
    fetch()
```
