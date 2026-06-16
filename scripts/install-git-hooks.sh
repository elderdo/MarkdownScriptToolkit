#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if ! git -C "$repo_root" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  echo "This repo is not initialized with git yet: $repo_root" >&2
  echo "Run: git init" >&2
  exit 1
fi

chmod +x "$repo_root/.githooks/pre-commit"
git -C "$repo_root" config core.hooksPath .githooks
echo "Configured git hooks path to .githooks"
echo "Markdown lint will run on staged .md files during commit."