[CmdletBinding()]
param()

# Build temporary paths used to test lint/fix behavior without touching repo files.
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$TempDirectory = Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid().ToString())
$TempFile = Join-Path $TempDirectory 'markdownlint-demo.md'

New-Item -ItemType Directory -Path $TempDirectory -Force | Out-Null

try {
    # Write intentionally bad Markdown so we can prove lint fails before -Fix.
    @"
# Demo Heading  

This line has trailing spaces.  


This paragraph starts after multiple blank lines.  
"@ | Set-Content -LiteralPath $TempFile -NoNewline

    Write-Host "Created temp file: $TempFile"

    # First pass should fail because the temp file includes rule violations.
    & "$RepoRoot\scripts\fix-markdown.ps1" $TempFile
    if ($LASTEXITCODE -eq 0) {
        throw 'Expected lint to fail before auto-fix, but it passed.'
    }

    # Second pass applies auto-fixes.
    & "$RepoRoot\scripts\fix-markdown.ps1" -Fix $TempFile
    if ($LASTEXITCODE -ne 0) {
        throw 'Auto-fix run failed.'
    }

    # Third pass should now succeed on the corrected file.
    & "$RepoRoot\scripts\fix-markdown.ps1" $TempFile
    if ($LASTEXITCODE -ne 0) {
        throw 'Lint after auto-fix failed.'
    }

    Write-Host 'Markdown script self-test passed.'
}
finally {
    # Always clean up temporary files, even if the test fails.
    if (Test-Path -LiteralPath $TempDirectory) {
        Remove-Item -LiteralPath $TempDirectory -Recurse -Force
    }
}