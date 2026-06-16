#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
config_file="$repo_root/.markdownlint.json"
apply_fix=false
show_help=false
raw_targets=()

action_usage() {
  cat <<'EOF'
Usage: scripts/fix-markdown.sh [--fix] [PATH...]

Lint one or more Markdown files using the repo markdownlint config.

Arguments:
  PATH            One or more Markdown files or directories.
                  Directories are searched recursively for *.md files.
                  If omitted, all *.md files under the repo root are used.

Options:
  --fix           Apply markdownlint auto-fixes when supported.
  -h, --help      Show this help text.

Examples:
  scripts/fix-markdown.sh
  scripts/fix-markdown.sh MarkdownDocs/setupForSetExampleProject.md MarkdownDocs/pullRequests.md
  scripts/fix-markdown.sh --fix scripts .
EOF
}

while (($# > 0)); do
  case "$1" in
    --fix)
      apply_fix=true
      ;;
    -h|--help)
      show_help=true
      ;;
    *)
      raw_targets+=("$1")
      ;;
  esac
  shift
done

if [[ "$show_help" == true ]]; then
  action_usage
  exit 0
fi

if [[ ! -f "$config_file" ]]; then
  echo "markdownlint config not found: $config_file" >&2
  exit 1
fi

if ! command -v markdownlint >/dev/null 2>&1; then
  echo "markdownlint was not found on PATH." >&2
  echo "Install it with: npm install -g markdownlint-cli" >&2
  exit 1
fi

collect_markdown_files() {
  local target="$1"

  if [[ -d "$target" ]]; then
    find "$target" -type f -name '*.md' -not -path '*/node_modules/*' -print
    return
  fi

  if [[ -f "$target" ]]; then
    printf '%s\n' "$target"
    return
  fi

  echo "Skipping missing path: $target" >&2
}

markdown_files=()

if ((${#raw_targets[@]} == 0)); then
  while IFS= read -r file_path; do
    markdown_files+=("$file_path")
  done < <(find "$repo_root" -type f -name '*.md' -not -path '*/node_modules/*' -print)
else
  for target in "${raw_targets[@]}"; do
    while IFS= read -r file_path; do
      [[ -n "$file_path" ]] && markdown_files+=("$file_path")
    done < <(collect_markdown_files "$target")
  done
fi

if ((${#markdown_files[@]} == 0)); then
  echo "No Markdown files found." >&2
  exit 1
fi

command_args=(--config "$config_file")
if [[ "$apply_fix" == true ]]; then
  command_args+=(--fix)
fi
command_args+=("${markdown_files[@]}")

cd "$repo_root"
markdownlint "${command_args[@]}"
