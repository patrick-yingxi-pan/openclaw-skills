# /// script
# dependencies = [
#   "strictyaml>=1.7.3,<2",
# ]
# requires-python = ">=3.10"
# ///

"""
Skill validation script that integrates with skills-ref.
This provides both official specification validation and extended checks.
"""

import argparse
import re
import sys
import subprocess
from pathlib import Path
import strictyaml


MAX_SKILL_NAME_LENGTH = 64
MAX_DESCRIPTION_LENGTH = 1024
MAX_COMPATIBILITY_LENGTH = 500

ALLOWED_FIELDS = {
    "name",
    "description",
    "license",
    "allowed-tools",
    "metadata",
    "compatibility",
}

# PII patterns
PII_PATTERNS = {
    "feishu_open_id": re.compile(r"ou_[0-9a-f]{32}"),
    "email": re.compile(r"[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}"),
    "phone": re.compile(r"\+86[ -]?1[3-9][0-9]{9}"),
    "personal_path": re.compile(r"/home/[a-z]+"),
}


def validate_with_skills_ref(skill_dir: Path) -> tuple[bool, str]:
    """Validate using the official skills-ref validator."""
    skills_ref_dir = Path("/tmp/agentskills/skills-ref")
    
    if not skills_ref_dir.exists():
        return False, "skills-ref not found. Install it first: cd /tmp && git clone https://github.com/agentskills/agentskills.git"
    
    try:
        # Use absolute path
        skill_dir_abs = skill_dir.resolve()
        result = subprocess.run(
            ["uv", "run", "skills-ref", "validate", str(skill_dir_abs)],
            capture_output=True,
            text=True,
            timeout=30,
            cwd=skills_ref_dir
        )
        output = result.stdout + result.stderr
        # Check if it says "Valid skill"
        is_valid = "Valid skill" in output and result.returncode == 0
        return is_valid, output
    except FileNotFoundError:
        return False, "skills-ref not found. Install it first: cd /tmp/agentskills/skills-ref && uv pip install -e ."
    except subprocess.TimeoutExpired:
        return False, "skills-ref validation timed out"
    except Exception as e:
        return False, f"Error running skills-ref: {e}"


def validate_name(name: str, skill_dir: Path) -> list[str]:
    """Validate skill name."""
    errors = []
    
    if not name or not isinstance(name, str):
        errors.append("Field 'name' must be a non-empty string")
        return errors
    
    name = name.strip()
    
    if len(name) > MAX_SKILL_NAME_LENGTH:
        errors.append(f"Skill name exceeds {MAX_SKILL_NAME_LENGTH} chars")
    
    if name != name.lower():
        errors.append("Skill name must be lowercase")
    
    if name.startswith("-") or name.endswith("-"):
        errors.append("Skill name cannot start or end with hyphen")
    
    if "--" in name:
        errors.append("Skill name cannot contain consecutive hyphens")
    
    if not all(c.isalnum() or c == "-" for c in name):
        errors.append("Skill name contains invalid characters")
    
    # Get absolute path to handle '.' correctly
    skill_dir_abs = skill_dir.resolve()
    if skill_dir_abs.name != name:
        errors.append(f"Directory name '{skill_dir_abs.name}' must match skill name '{name}'")
    
    return errors


def validate_description(description: str) -> list[str]:
    """Validate description."""
    errors = []
    
    if not description or not isinstance(description, str):
        errors.append("Field 'description' must be a non-empty string")
        return errors
    
    if len(description) > MAX_DESCRIPTION_LENGTH:
        errors.append(f"Description exceeds {MAX_DESCRIPTION_LENGTH} chars")
    
    return errors


def scan_for_pii(file_path: Path) -> list[str]:
    """Scan a file for PII patterns."""
    findings = []
    
    try:
        content = file_path.read_text()
        
        for pii_type, pattern in PII_PATTERNS.items():
            matches = pattern.findall(content)
            for match in matches:
                # Skip known safe example values
                safe_values = {
                    "feishu_open_id": [
                        "ou_1234567890abcdef1234567890abcdef",
                        "ou_7c26f0e19219253829283b20e23a0a45"  # Example in docs
                    ],
                    "email": [
                        "user@example.com",
                        "employee@company-example.com",
                        "patrick@example.com",  # Example in docs
                        "yingxi.pan@company.com"  # Example in docs
                    ],
                    "phone": [
                        "+86 138 1234 5678",
                        "+86 138 0000 0000"  # Example in docs
                    ],
                    "personal_path": [
                        "/home/user",
                        "/home/patrick"  # Example in docs
                    ]
                }
                
                if pii_type in safe_values:
                    if any(safe in match for safe in safe_values[pii_type]):
                        continue
                
                findings.append(f"Potential {pii_type} in {file_path}: {match}")
    
    except Exception as e:
        findings.append(f"Could not read {file_path}: {e}")
    
    return findings


def validate_skill(skill_dir: Path, skip_skills_ref: bool = False) -> tuple[list[str], list[str], list[str]]:
    """Validate a skill directory."""
    errors = []
    warnings = []
    info = []
    
    if not skill_dir.exists():
        errors.append(f"Path does not exist: {skill_dir}")
        return errors, warnings, info
    
    if not skill_dir.is_dir():
        errors.append(f"Not a directory: {skill_dir}")
        return errors, warnings, info
    
    skill_md = skill_dir / "SKILL.md"
    if not skill_md.exists():
        errors.append("Missing required file: SKILL.md")
        return errors, warnings, info
    
    # Run skills-ref validation first
    if not skip_skills_ref:
        info.append("Running skills-ref validation...")
        skills_ref_valid, skills_ref_output = validate_with_skills_ref(skill_dir)
        if skills_ref_valid:
            info.append("✓ skills-ref validation passed")
        else:
            errors.append(f"skills-ref validation failed:\n{skills_ref_output}")
    
    # Parse frontmatter for extended checks
    try:
        content = skill_md.read_text()
        
        if not content.startswith("---"):
            errors.append("SKILL.md must start with YAML frontmatter (---)")
            return errors, warnings, info
        
        # Extract frontmatter
        end_idx = content.find("---", 3)
        if end_idx == -1:
            errors.append("Could not find end of YAML frontmatter (---)")
            return errors, warnings, info
        
        frontmatter_str = content[3:end_idx].strip()
        parsed = strictyaml.load(frontmatter_str)
        metadata = parsed.data
        
        # Validate fields
        extra_fields = set(metadata.keys()) - ALLOWED_FIELDS
        if extra_fields:
            warnings.append(f"Unexpected fields: {', '.join(sorted(extra_fields))}")
        
        if "name" not in metadata:
            errors.append("Missing required field: name")
        else:
            name_errors = validate_name(metadata["name"], skill_dir)
            if skip_skills_ref:
                errors.extend(name_errors)
            elif name_errors:
                warnings.append(f"Extended name checks (skills-ref already validated): {name_errors}")
        
        if "description" not in metadata:
            errors.append("Missing required field: description")
        else:
            desc_errors = validate_description(metadata["description"])
            if skip_skills_ref:
                errors.extend(desc_errors)
            elif desc_errors:
                warnings.append(f"Extended description checks (skills-ref already validated): {desc_errors}")
        
        if "compatibility" in metadata:
            if not isinstance(metadata["compatibility"], str):
                errors.append("Field 'compatibility' must be a string")
            elif len(metadata["compatibility"]) > MAX_COMPATIBILITY_LENGTH:
                errors.append(f"Compatibility exceeds {MAX_COMPATIBILITY_LENGTH} chars")
        
    except strictyaml.YAMLError as e:
        errors.append(f"Invalid YAML in frontmatter: {e}")
        return errors, warnings, info
    except Exception as e:
        errors.append(f"Error parsing SKILL.md: {e}")
        return errors, warnings, info
    
    # Check for extraneous files
    allowed_dirs = {"scripts", "references", "assets"}
    allowed_files = {"SKILL.md"}
    
    for item in skill_dir.iterdir():
        if item.is_dir():
            if item.name not in allowed_dirs:
                warnings.append(f"Unexpected directory: {item.name}")
        elif item.is_file():
            if item.name not in allowed_files and not item.name.startswith("."):
                # Allow dotfiles like .gitignore
                if not item.name.startswith("."):
                    warnings.append(f"Unexpected file: {item.name}")
    
    # Scan for PII
    for file_path in skill_dir.rglob("*"):
        if file_path.is_file() and file_path.suffix in {".md", ".py", ".sh", ".txt", ".json", ".yaml", ".yml"}:
            warnings.extend(scan_for_pii(file_path))
    
    return errors, warnings, info


def main():
    parser = argparse.ArgumentParser(
        description="Validate an Agent Skill directory (integrates with skills-ref).",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog="""
Examples:
  scripts/validate-skill.py ./my-skill
  scripts/validate-skill.py ./my-skill --skip-skills-ref
  scripts/validate-skill.py ./my-skill --verbose
        """
    )
    parser.add_argument("skill_dir", help="Path to skill directory")
    parser.add_argument("--skip-skills-ref", action="store_true", 
                       help="Skip skills-ref validation (use for extended checks only)")
    parser.add_argument("--verbose", "-v", action="store_true", help="Show verbose output")
    
    args = parser.parse_args()
    
    skill_path = Path(args.skill_dir)
    
    print(f"Validating skill: {skill_path}")
    print("-" * 60)
    
    errors, warnings, info = validate_skill(skill_path, skip_skills_ref=args.skip_skills_ref)
    
    if info and args.verbose:
        print("\nℹ️ Info:")
        for msg in info:
            print(f"  - {msg}")
    
    if errors:
        print("\n❌ Errors:")
        for error in errors:
            print(f"  - {error}")
    
    if warnings:
        print("\n⚠️ Warnings:")
        for warning in warnings:
            print(f"  - {warning}")
    
    if not errors and not warnings:
        print("\n✅ No issues found!")
    
    if errors:
        sys.exit(1)
    elif warnings:
        sys.exit(2)
    else:
        sys.exit(0)


if __name__ == "__main__":
    main()
