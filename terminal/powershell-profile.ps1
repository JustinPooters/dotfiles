# ===============================
# PowerShell Profile (portable)
# Location in repo: terminal/powershell-profile.ps1
# ===============================

# Base paths
$profileDir        = Split-Path -Path $PROFILE -Parent
$customProfilesDir = Join-Path $profileDir 'ProfileModules'
$repoLocalDir      = Split-Path -Path $PSScriptRoot -Parent  # e.g., .../dev-configs
$ompLocalConfig    = Join-Path $PSScriptRoot 'oh-my-posh\theme.json'  # optional local theme

# Ensure module directory exists
if (-not (Test-Path -LiteralPath $customProfilesDir)) {
    New-Item -ItemType Directory -Path $customProfilesDir -Force | Out-Null
}

# ------------
# UTILITIES
# ------------
function Test-Command {
    param([Parameter(Mandatory)][string]$Name)
    return [bool](Get-Command -Name $Name -ErrorAction SilentlyContinue)
}

# ------------
# PROMPT / THEMING
# ------------
if (Test-Command 'oh-my-posh') {
    if (Test-Path -LiteralPath $ompLocalConfig) {
        oh-my-posh init pwsh --config $ompLocalConfig | Invoke-Expression
    } else {
        # Fallback to default theme if no local theme is present
        oh-my-posh init pwsh | Invoke-Expression
    }
}

# ------------
# MODULES (safe load)
# ------------
foreach ($m in @('Terminal-Icons','PSReadLine')) {
    try { Import-Module -Name $m -ErrorAction Stop } catch { }
}

# PSReadLine: predictions + history search on arrows
try {
    Set-PSReadLineOption -PredictionSource History -PredictionViewStyle ListView
    Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
    Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
} catch { }

# ------------
# FUNCTIONS
# ------------
function dev {
    # Portable dev folder at $HOME\Development
    $devPath = Join-Path $HOME 'Development'
    if (-not (Test-Path -LiteralPath $devPath)) {
        Write-Host "Creating $devPath ..." -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $devPath -Force | Out-Null
    }
    Set-Location -Path $devPath
    Write-Host "→ $devPath" -ForegroundColor Cyan
}

function whereami { Get-Location }

function .. { Set-Location .. }

function notepad {
    [CmdletBinding()]
    param([string]$File)
    $candidates = @(
        'C:\Program Files\Notepad++\notepad++.exe',
        'C:\Program Files (x86)\Notepad++\notepad++.exe'
    ) | Where-Object { Test-Path $_ }
    if ($candidates) { & $candidates[0] $File }
    else { & notepad.exe $File }  # fallback to Windows Notepad
}

function touch {
    [CmdletBinding()]
    param([Parameter(Mandatory)][string]$File)
    New-Item -Path $File -ItemType File -Force | Out-Null
}

function l { Get-ChildItem }

# Smarter .NET Target Framework detection:
# - Looks for closest *.csproj (current dir or one level down)
# - Parses XML, supports <TargetFrameworks> (plural) – picks highest
function Update-DotNetVersion {
    $current = Get-Location

    # If you're *exactly* at $HOME\Development, clear override
    $devRoot = Join-Path $HOME 'Development'
    if ([IO.Path]::GetFullPath($current.Path).TrimEnd('\') -ieq [IO.Path]::GetFullPath($devRoot).TrimEnd('\')) {
        $env:DOTNET_VERSION = $null
        return
    }

    $csproj = Get-ChildItem -Path . -Filter *.csproj -File -ErrorAction SilentlyContinue |
              Select-Object -First 1

    if (-not $csproj) {
        $csproj = Get-ChildItem -Path . -Directory -ErrorAction SilentlyContinue |
                  ForEach-Object { Get-ChildItem -Path $_.FullName -Filter *.csproj -File -ErrorAction SilentlyContinue } |
                  Select-Object -First 1
    }

    if (-not $csproj) {
        $env:DOTNET_VERSION = $null
        return
    }

    try {
        [xml]$xml = Get-Content -LiteralPath $csproj.FullName -Raw

        # Handle <TargetFramework> or <TargetFrameworks>
        $tfmSingle  = $xml.Project.PropertyGroup.TargetFramework
        $tfmPlural  = $xml.Project.PropertyGroup.TargetFrameworks

        $tfms = @()
        if ($tfmSingle) { $tfms += $tfmSingle.Trim() }
        if ($tfmPlural) { $tfms += ($tfmPlural.Trim() -split ';') }

        if ($tfms.Count -gt 0) {
            # Pick the “highest” TFM using a simple sort heuristic
            # (net8.0 > net7.0 > net6.0, etc.)
            $chosen = $tfms |
                Sort-Object -Descending -Property { $_ -replace '[^\d\.]', '' } |
                Select-Object -First 1
            $env:DOTNET_VERSION = $chosen
            return
        }
    } catch {
        # ignore parse errors
    }

    $env:DOTNET_VERSION = $null
}

# Make the prompt update DOTNET_VERSION before rendering
$OriginalPrompt = $function:prompt
function prompt {
    Update-DotNetVersion
    if ($OriginalPrompt) { & $OriginalPrompt } else { 'PS ' }
}

# ------------
# AUTOLOAD HELPERS FROM ProfileModules
# ------------
# Any *.ps1 you drop in $customProfilesDir will be dot-sourced automatically.
Get-ChildItem -Path $customProfilesDir -Filter '*.ps1' -File -ErrorAction SilentlyContinue |
    ForEach-Object { . $_.FullName }

# ------------
# SETTINGS
# ------------
# Keep execution policy relaxed only for the current session.
try { Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force } catch { }

# ------------
# STARTUP
# ------------
Clear-Host
Write-Host "PowerShell profile loaded ✔" -ForegroundColor Green
