[CmdletBinding()]
param()

# Find the repository root relative to this script file.
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

# Guardrail: this script only works inside an initialized git repository.
& git -C $RepoRoot rev-parse --is-inside-work-tree *> $null
if ($LASTEXITCODE -ne 0) {
    throw "This repo is not initialized with git yet: $RepoRoot. Run: git init"
}

# Ensure the hook file can be executed by bash-based git hooks.
& bash -lc "chmod +x '$RepoRoot/.githooks/pre-commit'"
if ($LASTEXITCODE -ne 0) {
    throw 'Failed to mark pre-commit hook as executable.'
}

# Tell git to use the shared .githooks folder for this repository.
& git -C $RepoRoot config core.hooksPath .githooks
if ($LASTEXITCODE -ne 0) {
    throw 'Failed to configure git hooks path.'
}

Write-Host 'Configured git hooks path to .githooks'
Write-Host 'Markdown lint will run on staged .md files during commit.'