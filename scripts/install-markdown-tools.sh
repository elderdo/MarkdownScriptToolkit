#!/usr/bin/env bash
set -euo pipefail

# Compute repository paths so profile functions point to this toolkit.
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
repo_parent="$(cd "$repo_root/.." && pwd)"
canonical_root="$repo_parent/MarkdownScriptToolkit"
profile_repo_root="$repo_root"

# Prefer the canonical folder path when it exists, so aliases remain stable.
if [[ -d "$canonical_root/scripts" ]]; then
  profile_repo_root="$canonical_root"
fi

# Default to the user's Bash profile in Git Bash.
profile_path="${HOME}/.bashrc"

usage() {
  cat <<'EOF'
Usage: scripts/install-markdown-tools.sh [--profile PATH]

Installs a fixmd shell function into your Bash profile so you can run the
Markdown helper from any Git Bash terminal.

Options:
  --profile PATH   Override the profile file to update.
  -h, --help       Show this help text.
EOF
}

while (($# > 0)); do
  case "$1" in
    --profile)
      shift
      if (($# == 0)); then
        echo "Missing value for --profile" >&2
        exit 1
      fi
      profile_path="$1"
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
  shift
done

# Create profile location if needed, then ensure file exists.
mkdir -p "$(dirname "$profile_path")"
touch "$profile_path"

# Markers let us detect and prevent duplicate profile blocks.
start_marker="# >>> markdown-script-toolkit >>>"
end_marker="# <<< markdown-script-toolkit <<<"

if grep -Fq "$start_marker" "$profile_path"; then
  echo "Profile already contains markdown-script-toolkit block: $profile_path"
  exit 0
fi

# Add a helper function named fixmd that forwards all arguments.
cat >> "$profile_path" <<EOF

$start_marker
fixmd() {
  bash "$profile_repo_root/scripts/fix-markdown.sh" "\$@"
}
$end_marker
EOF

echo "Installed fixmd into $profile_path"
echo "Reload with: source \"$profile_path\""