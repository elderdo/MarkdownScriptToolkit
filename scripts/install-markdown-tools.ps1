[CmdletBinding()]
param(
    [string]$ProfilePath = $PROFILE
)

$RepoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$StartMarker = '# >>> markdown-script-toolkit >>>'
$EndMarker = '# <<< markdown-script-toolkit <<<'

if (-not $ProfilePath) {
    throw 'A PowerShell profile path is required.'
}

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

$Block = @"

$StartMarker
function fixmd {
    & '$RepoRoot\scripts\fix-markdown.ps1' @args
}
$EndMarker
"@

Add-Content -LiteralPath $ProfilePath -Value $Block

Write-Host "Installed fixmd into $ProfilePath"
Write-Host "Reload with: . `"$ProfilePath`""