[CmdletBinding()]
param()

# $PSScriptRoot is the directory containing this script file.
# Find the repository root relative to this script file.
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

# Guardrail: this script only works inside an initialized git repository.
# $null is PowerShell's null value; redirecting to it silences command output.
& git -C $RepoRoot rev-parse --is-inside-work-tree *> $null
# $LASTEXITCODE holds the native process exit code from the previous external command.
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