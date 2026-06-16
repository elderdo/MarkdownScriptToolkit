[CmdletBinding()]
param(
    [switch]$Fix,
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Path
)

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$ConfigFile = Join-Path $RepoRoot '.markdownlint.json'

function Show-Usage {
    @'
Usage: scripts/fix-markdown.ps1 [-Fix] [PATH...]

Lint one or more Markdown files using the repo markdownlint config.

Arguments:
  PATH            One or more Markdown files or directories.
                  Directories are searched recursively for *.md files.
                  If omitted, all *.md files under the repo root are used.

Options:
  -Fix            Apply markdownlint auto-fixes when supported.
  -Help           Show PowerShell help.

Examples:
  ./scripts/fix-markdown.ps1
    ./scripts/fix-markdown.ps1 MarkdownDocs/setupForSetExampleProject.md MarkdownDocs/pullRequests.md
  ./scripts/fix-markdown.ps1 -Fix scripts .
'@
}

if ($Path -contains '--help' -or $Path -contains '-h') {
    Show-Usage
    exit 0
}

if (-not (Test-Path -LiteralPath $ConfigFile)) {
    throw "markdownlint config not found: $ConfigFile"
}

$markdownlint = Get-Command markdownlint -ErrorAction SilentlyContinue
if (-not $markdownlint) {
    throw 'markdownlint was not found on PATH. Install it with: npm install -g markdownlint-cli'
}

function Get-MarkdownFiles {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Target
    )

    if (-not (Test-Path -LiteralPath $Target)) {
        Write-Warning "Skipping missing path: $Target"
        return @()
    }

    $item = Get-Item -LiteralPath $Target
    if ($item.PSIsContainer) {
        return Get-ChildItem -LiteralPath $item.FullName -Recurse -File -Filter '*.md' |
            Where-Object { $_.FullName -notmatch '[\\/]node_modules[\\/]' } |
            Select-Object -ExpandProperty FullName
    }

    return $item.FullName
}

$markdownFiles = New-Object System.Collections.Generic.List[string]

if (-not $Path -or $Path.Count -eq 0) {
    Get-ChildItem -LiteralPath $RepoRoot -Recurse -File -Filter '*.md' |
        Where-Object { $_.FullName -notmatch '[\\/]node_modules[\\/]' } |
        ForEach-Object { [void]$markdownFiles.Add($_.FullName) }
}
else {
    foreach ($target in $Path) {
        foreach ($file in Get-MarkdownFiles -Target $target) {
            [void]$markdownFiles.Add($file)
        }
    }
}

if ($markdownFiles.Count -eq 0) {
    throw 'No Markdown files found.'
}

$commandArgs = @('--config', $ConfigFile)
if ($Fix) {
    $commandArgs += '--fix'
}
$commandArgs += $markdownFiles

Push-Location $RepoRoot
try {
    & $markdownlint.Source @commandArgs
}
finally {
    Pop-Location
}
