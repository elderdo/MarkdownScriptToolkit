[CmdletBinding()]
param(
    # Where the helper function should be installed; defaults to the active PowerShell profile.
    [string]$ProfilePath = $PROFILE
)

# Compute repo paths so the profile function points at this toolkit.
$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$RepoParent = Split-Path -Parent $RepoRoot
$CanonicalRoot = Join-Path $RepoParent 'MarkdownScriptToolkit'
$ProfileRepoRoot = $RepoRoot

# If a canonical folder exists, prefer it so profile aliases stay stable after folder moves.
if (Test-Path -LiteralPath (Join-Path $CanonicalRoot 'scripts')) {
    $ProfileRepoRoot = $CanonicalRoot
}

# Markers let us detect an existing block and avoid duplicate profile entries.
$StartMarker = '# >>> markdown-script-toolkit >>>'
$EndMarker = '# <<< markdown-script-toolkit <<<'

if (-not $ProfilePath) {
    throw 'A PowerShell profile path is required.'
}

# Create the profile directory/file if this is a first-time PowerShell setup.
$ProfileDirectory = Split-Path -Parent $ProfilePath
if ($ProfileDirectory) {
    New-Item -ItemType Directory -Path $ProfileDirectory -Force | Out-Null
}

if (-not (Test-Path -LiteralPath $ProfilePath)) {
    New-Item -ItemType File -Path $ProfilePath -Force | Out-Null
}

$CurrentProfile = Get-Content -LiteralPath $ProfilePath -Raw
if ($CurrentProfile -like "*$StartMarker*") {
    Write-Host "Profile already contains markdown-script-toolkit block: $ProfilePath"
    exit 0
}

# Adds a convenience function named fixmd that forwards all arguments to fix-markdown.ps1.
$Block = @"

$StartMarker
function fixmd {
    & '$ProfileRepoRoot\scripts\fix-markdown.ps1' @args
}
$EndMarker
"@

Add-Content -LiteralPath $ProfilePath -Value $Block

Write-Host "Installed fixmd into $ProfilePath"
Write-Host "Reload with: . `"$ProfilePath`""