#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
temp_dir="$(mktemp -d)"
temp_file="$temp_dir/markdownlint-demo.md"

cleanup() {
  rm -rf "$temp_dir"
}
trap cleanup EXIT

cat > "$temp_file" <<'EOF'
# Demo Heading  

This line has trailing spaces.  


This paragraph starts after multiple blank lines.  
EOF

echo "Created temp file: $temp_file"

if bash "$repo_root/scripts/fix-markdown.sh" "$temp_file"; then
  echo "Expected lint to fail before auto-fix, but it passed." >&2
  exit 1
fi

bash "$repo_root/scripts/fix-markdown.sh" --fix "$temp_file"
bash "$repo_root/scripts/fix-markdown.sh" "$temp_file"

echo "Markdown script self-test passed."