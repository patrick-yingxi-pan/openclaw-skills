# /// script
# dependencies = []
# requires-python = ">=3.10"
# ///

"""
Create a new Agent Skill with proper structure.
"""

import argparse
import sys
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(
        description="Create a new Agent Skill directory with proper structure.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  scripts/create-skill.py my-new-skill
  scripts/create-skill.py my-new-skill --description "My awesome skill"
        """
    )
    parser.add_argument("skill_name", help="Name of the new skill (lowercase, hyphens only)")
    parser.add_argument("--description", "-d", 
                       default="Describe what this skill does and when to use it.",
                       help="Description for the skill")
    parser.add_argument("--author", "-a", default="OpenClaw", help="Author name")
    parser.add_argument("--license", "-l", default="Apache-2.0", help="License")
    
    args = parser.parse_args()
    
    # Validate skill name
    skill_name = args.skill_name.lower().strip()
    
    if not skill_name:
        print("Error: Skill name cannot be empty", file=sys.stderr)
        sys.exit(1)
    
    if len(skill_name) > 64:
        print("Error: Skill name cannot exceed 64 characters", file=sys.stderr)
        sys.exit(1)
    
    if skill_name.startswith("-") or skill_name.endswith("-"):
        print("Error: Skill name cannot start or end with a hyphen", file=sys.stderr)
        sys.exit(1)
    
    if "--" in skill_name:
        print("Error: Skill name cannot contain consecutive hyphens", file=sys.stderr)
        sys.exit(1)
    
    if not all(c.isalnum() or c == "-" for c in skill_name):
        print("Error: Skill name can only contain lowercase letters, numbers, and hyphens", file=sys.stderr)
        sys.exit(1)
    
    # Create directory structure
    skill_dir = Path(skill_name)
    
    if skill_dir.exists():
        print(f"Error: Directory already exists: {skill_dir}", file=sys.stderr)
        sys.exit(1)
    
    skill_dir.mkdir()
    (skill_dir / "scripts").mkdir(exist_ok=True)
    (skill_dir / "references").mkdir(exist_ok=True)
    (skill_dir / "assets").mkdir(exist_ok=True)
    
    # Create SKILL.md
    skill_md_content = f"""---
name: {skill_name}
description: "{args.description}"
license: {args.license}
metadata:
  author: {args.author}
  version: "0.1.0"
---

# {skill_name.replace('-', ' ').title()}

## Overview

Brief description of what this skill enables.

## When to Use

List specific scenarios when this skill should be activated.

## How to Use

Step-by-step instructions.
"""
    
    (skill_dir / "SKILL.md").write_text(skill_md_content)
    
    print(f"Created skill: {skill_dir}")
    print(f"  - SKILL.md")
    print(f"  - scripts/")
    print(f"  - references/")
    print(f"  - assets/")
    print()
    print(f"Next steps:")
    print(f"  1. Edit {skill_dir}/SKILL.md with your skill content")
    print(f"  2. Add scripts, references, or assets as needed")
    print(f"  3. Validate with: uv run skills-ref validate {skill_dir}")


if __name__ == "__main__":
    main()
