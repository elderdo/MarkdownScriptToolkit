[CmdletBinding()]
param()

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$TempDirectory = Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid().ToString())
$TempFile = Join-Path $TempDirectory 'markdownlint-demo.md'

New-Item -ItemType Directory -Path $TempDirectory -Force | Out-Null

try {
    @"
# Demo Heading  

This line has trailing spaces.  


This paragraph starts after multiple blank lines.  
"@ | Set-Content -LiteralPath $TempFile -NoNewline

    Write-Host "Created temp file: $TempFile"

    & "$RepoRoot\scripts\fix-markdown.ps1" $TempFile
    if ($LASTEXITCODE -eq 0) {
        throw 'Expected lint to fail before auto-fix, but it passed.'
    }

    & "$RepoRoot\scripts\fix-markdown.ps1" -Fix $TempFile
    if ($LASTEXITCODE -ne 0) {
        throw 'Auto-fix run failed.'
    }

    & "$RepoRoot\scripts\fix-markdown.ps1" $TempFile
    if ($LASTEXITCODE -ne 0) {
        throw 'Lint after auto-fix failed.'
    }

    Write-Host 'Markdown script self-test passed.'
}
finally {
    if (Test-Path -LiteralPath $TempDirectory) {
        Remove-Item -LiteralPath $TempDirectory -Recurse -Force
    }
}