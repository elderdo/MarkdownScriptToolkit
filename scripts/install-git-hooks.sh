#!/usr/bin/env bash
set -euo pipefail

# Find the repository root relative to this script file.
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Guardrail: this script requires an initialized git repository.
if ! git -C "$repo_root" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "This repo is not initialized with git yet: $repo_root" >&2
  echo "Run: git init" >&2
  exit 1
fi

# Make sure the pre-commit hook file is executable in bash environments.
chmod +x "$repo_root/.githooks/pre-commit"
# Configure git to use the shared .githooks directory for this repo.
git -C "$repo_root" config core.hooksPath .githooks
echo "Configured git hooks path to .githooks"
echo "Markdown lint will run on staged .md files during commit."