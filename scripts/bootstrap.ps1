$repo = (Resolve-Path "$PSScriptRoot\..").Path
$pwshProfileDir = Split-Path -Path $PROFILE -Parent
New-Item -ItemType Directory -Force -Path $pwshProfileDir | Out-Null
if (Test-Path $PROFILE) { Remove-Item $PROFILE -Force }
New-Item -ItemType SymbolicLink -Path $PROFILE -Target (Join-Path $repo 'terminal\powershell-profile.ps1') | Out-Null
Write-Host "Linked PowerShell profile → $PROFILE"