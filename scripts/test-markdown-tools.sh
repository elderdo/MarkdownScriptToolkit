#!/usr/bin/env bash
set -euo pipefail

# BASH_SOURCE[0] points to this script path, so temp tests can find repo scripts reliably.
# Build temporary test paths so we do not modify repository files.
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
temp_dir="$(mktemp -d)"
temp_file="$temp_dir/markdownlint-demo.md"

cleanup() {
  # Always remove temp artifacts, even if the script exits with an error.
  rm -rf "$temp_dir"
}
trap cleanup EXIT

# Intentionally create a Markdown file with lint violations.
cat > "$temp_file" <<'EOF'
# Demo Heading  

This line has trailing spaces.  


This paragraph starts after multiple blank lines.  
EOF

echo "Created temp file: $temp_file"

# First run should fail because file still has lint issues.
if bash "$repo_root/scripts/fix-markdown.sh" "$temp_file"; then
  echo "Expected lint to fail before auto-fix, but it passed." >&2
  exit 1
fi

# Second run applies auto-fixes, third run verifies clean lint result.
bash "$repo_root/scripts/fix-markdown.sh" --fix "$temp_file"
bash "$repo_root/scripts/fix-markdown.sh" "$temp_file"

echo "Markdown script self-test passed."