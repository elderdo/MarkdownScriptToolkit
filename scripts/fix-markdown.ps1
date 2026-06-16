[CmdletBinding()]
param(
    # Use -Fix to let markdownlint apply automatic corrections where supported.
    [switch]$Fix,
    # ValueFromRemainingArguments captures every extra argument after named options.
    # Optional file or directory paths to lint. If omitted, the script lints the whole repo.
    [Parameter(ValueFromRemainingArguments = $true)]
    [string[]]$Path
)

# $PSScriptRoot is the folder of this .ps1 file, so path resolution works from any current directory.
# Resolve repository paths once so the script can be run from any current directory.
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

# Verify the markdownlint CLI is installed and reachable on PATH.
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

    # If a directory is passed, collect all Markdown files inside it recursively.
    $item = Get-Item -LiteralPath $Target
    if ($item.PSIsContainer) {
        return Get-ChildItem -LiteralPath $item.FullName -Recurse -File -Filter '*.md' |
            Where-Object { $_.FullName -notmatch '[\\/]node_modules[\\/]' } |
            Select-Object -ExpandProperty FullName
    }

    return $item.FullName
}

$markdownFiles = New-Object System.Collections.Generic.List[string]

# Build the file list either from explicit paths or from the whole repo.
if (-not $Path -or $Path.Count -eq 0) {
    Get-ChildItem -LiteralPath $RepoRoot -Recurse -File -Filter '*.md' |
        Where-Object { $_.FullName -notmatch '[\\/]node_modules[\\/]' } |
        # [void] discards Add()'s return value so we only keep side effects.
        ForEach-Object { [void]$markdownFiles.Add($_.FullName) }
}
else {
    foreach ($target in $Path) {
        foreach ($file in Get-MarkdownFiles -Target $target) {
            # [void] suppresses output from List.Add to keep pipeline output clean.
            [void]$markdownFiles.Add($file)
        }
    }
}

if ($markdownFiles.Count -eq 0) {
    throw 'No Markdown files found.'
}

# Compose markdownlint arguments in one place before executing the tool.
$commandArgs = @('--config', $ConfigFile)
if ($Fix) {
    $commandArgs += '--fix'
}
$commandArgs += $markdownFiles

# Run from repo root so relative paths and config behavior are consistent.
Push-Location $RepoRoot
try {
    & $markdownlint.Source @commandArgs
}
finally {
    Pop-Location
}
