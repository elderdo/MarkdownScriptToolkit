[CmdletBinding()]
param()

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path

& git -C $RepoRoot rev-parse --is-inside-work-tree *> $null
if ($LASTEXITCODE -ne 0) {
    throw "This repo is not initialized with git yet: $RepoRoot. Run: git init"
}

& bash -lc "chmod +x '$RepoRoot/.githooks/pre-commit'"
if ($LASTEXITCODE -ne 0) {
    throw 'Failed to mark pre-commit hook as executable.'
}

& git -C $RepoRoot config core.hooksPath .githooks
if ($LASTEXITCODE -ne 0) {
    throw 'Failed to configure git hooks path.'
}

Write-Host 'Configured git hooks path to .githooks'
Write-Host 'Markdown lint will run on staged .md files during commit.'