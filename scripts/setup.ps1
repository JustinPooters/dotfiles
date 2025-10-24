<#
.SYNOPSIS
  One-shot setup for Justin's dev-configs on Windows (PowerShell 7).

.DESCRIPTION
  Installs core apps & modules, links dotfiles (PowerShell profile, Git),
  imports VS Code settings/extensions, and applies terminal config.
  Designed to be idempotent and safe to re-run.

.PARAMETER All
  Run all steps.

.PARAMETER Apps
  Install applications (winget): Git, VSCode, Oh-My-Posh, Windows Terminal, etc.

.PARAMETER Modules
  Install/update PowerShell modules (Terminal-Icons, PSReadLine).

.PARAMETER LinkProfiles
  Symlink PowerShell profile to repo + optional Windows Terminal settings.

.PARAMETER VSCode
  Apply VS Code settings and extensions from repo/vscode/.

.PARAMETER GitConfig
  Link ~/.gitconfig and ~/.gitignore_global from repo/git/.

.EXAMPLE
  pwsh -ExecutionPolicy Bypass -File .\scripts\setup.ps1 -All
#>

[CmdletBinding()]
param(
  [switch]$All,
  [switch]$Apps,
  [switch]$Modules,
  [switch]$LinkProfiles,
  [switch]$VSCode,
  [switch]$GitConfig
)

# ---------------------------
# Helpers
# ---------------------------
$ErrorActionPreference = 'Stop'

function Write-Step($msg) { Write-Host "`n=== $msg ===" -ForegroundColor Cyan }
function Write-Skip($msg) { Write-Host "↷ $msg" -ForegroundColor DarkGray }
function Write-OK($msg)   { Write-Host "✔ $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "⚠ $msg" -ForegroundColor Yellow }
function Write-Err($msg)  { Write-Host "✖ $msg" -ForegroundColor Red }

function Test-Command { param([Parameter(Mandatory)][string]$Name) [bool](Get-Command $Name -ErrorAction SilentlyContinue) }

function Ensure-Dir($path) {
  if (-not (Test-Path -LiteralPath $path)) {
    New-Item -ItemType Directory -Path $path -Force | Out-Null
  }
}

# Symlink with fallbacks (copy if symlink not allowed)
function Link-Or-Copy {
  param(
    [Parameter(Mandatory)][string]$Source,
    [Parameter(Mandatory)][string]$Target
  )
  Ensure-Dir (Split-Path -Parent $Target)
  if (Test-Path -LiteralPath $Target) {
    Remove-Item -LiteralPath $Target -Recurse -Force
  }
  try {
    New-Item -ItemType SymbolicLink -Path $Target -Target $Source | Out-Null
    Write-OK "Linked: $Target → $Source"
  } catch {
    Copy-Item -LiteralPath $Source -Destination $Target -Recurse -Force
    Write-Warn "Symlink failed; copied instead: $Target"
  }
}

function Require-Admin {
  $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()
    ).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
  if (-not $isAdmin) {
    Write-Err "Please run this script in an elevated PowerShell (Run as Administrator)."
    throw "Not elevated"
  }
}

# ---------------------------
# Resolve repo paths
# ---------------------------
# scripts/setup.ps1 → repo root
$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$TerminalDir = Join-Path $RepoRoot 'terminal'
$VSCodeDir   = Join-Path $RepoRoot 'vscode'
$GitDir      = Join-Path $RepoRoot 'git'

# Files we expect
$PwshProfileRepo = Join-Path $TerminalDir 'powershell-profile.ps1'  # from previous step
$OhMyPoshTheme   = Join-Path $TerminalDir 'oh-my-posh\theme.json'   # optional
$VSSettings      = Join-Path $VSCodeDir 'settings.json'
$VSKeys          = Join-Path $VSCodeDir 'keybindings.json'
$VSExtensions    = Join-Path $VSCodeDir 'extensions.txt'
$GitConfigFile   = Join-Path $GitDir '.gitconfig'
$GitIgnoreGlobal = Join-Path $GitDir '.gitignore_global'

# System paths
$PwshProfilePath = $PROFILE
$PwshProfileDir  = Split-Path -Path $PwshProfilePath -Parent

# Windows Terminal user settings
$WTUserSettings = Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'
$WTRepoSettings = Join-Path $TerminalDir 'windows-terminal.json' # optional

# ---------------------------
# Parameter routing
# ---------------------------
if ($All) {
  $Apps = $true
  $Modules = $true
  $LinkProfiles = $true
  $VSCode = $true
  $GitConfig = $true
}

# ---------------------------
# STEP: Install apps (winget)
# ---------------------------
if ($Apps) {
  Require-Admin
  Write-Step "Installing apps via winget"

  if (-not (Test-Command 'winget')) {
    Write-Err "winget not found. Install App Installer from Microsoft Store, then re-run."
    throw "winget missing"
  }

  $packages = @(
    #  Id                                               | Friendly name
    @{ id='Git.Git';                                    name='Git' },
    @{ id='Microsoft.VisualStudioCode';                 name='VS Code' },
    @{ id='JanDeDobbeleer.OhMyPosh';                    name='Oh My Posh' },
    @{ id='Microsoft.WindowsTerminal';                  name='Windows Terminal' }
    # Add more as you like:
    # @{ id='Microsoft.PowerShell';                     name='PowerShell 7' }
    # @{ id='JetBrains.Toolbox';                        name='JetBrains Toolbox' }
    # @{ id='Microsoft.VisualStudio.2022.Community';    name='Visual Studio 2022' }
  )

  foreach ($pkg in $packages) {
    try {
      Write-Host "→ $($pkg.name)" -ForegroundColor Magenta
      winget install --id $($pkg.id) -e --silent --accept-source-agreements --accept-package-agreements | Out-Null
      Write-OK "$($pkg.name) installed/verified"
    } catch {
      Write-Warn "Could not install $($pkg.name) (may already be installed)"
    }
  }
}

# ---------------------------
# STEP: PowerShell modules
# ---------------------------
if ($Modules) {
  Write-Step "Installing PowerShell modules"

  if (-not (Get-PSRepository -Name 'PSGallery' -ErrorAction SilentlyContinue)) {
    Register-PSRepository -Default
  }

  $modules = @(
    @{ name='Terminal-Icons'; minimumVersion='0.10.0' },
    @{ name='PSReadLine';     minimumVersion='2.3.0'  }
  )

  foreach ($m in $modules) {
    try {
      Install-Module -Name $m.name -Scope CurrentUser -Force -AllowClobber -ErrorAction Stop
      Write-OK "Module installed: $($m.name)"
    } catch {
      Write-Warn "Install failed (maybe already installed): $($m.name)"
    }
  }
}

# ---------------------------
# STEP: Link profiles (PowerShell + Windows Terminal)
# ---------------------------
if ($LinkProfiles) {
  Write-Step "Linking PowerShell profile (and Windows Terminal if present)"

  if (-not (Test-Path -LiteralPath $PwshProfileRepo)) {
    Write-Err "Repo profile not found at: $PwshProfileRepo"
    throw "Missing powershell-profile.ps1"
  }

  Ensure-Dir $PwshProfileDir
  Link-Or-Copy -Source $PwshProfileRepo -Target $PwshProfilePath

  if (Test-Path -LiteralPath $OhMyPoshTheme) {
    Write-OK "Oh-My-Posh theme found (will be used by profile): $OhMyPoshTheme"
  } else {
    Write-Skip "No oh-my-posh theme in repo (terminal/oh-my-posh/theme.json). Using OMP default."
  }

  if (Test-Path -LiteralPath $WTRepoSettings) {
    Link-Or-Copy -Source $WTRepoSettings -Target $WTUserSettings
  } else {
    Write-Skip "Windows Terminal settings not found in repo (terminal/windows-terminal.json)"
  }
}

# ---------------------------
# STEP: VS Code settings & extensions
# ---------------------------
if ($VSCode) {
  Write-Step "Applying VS Code settings and extensions"

  if (-not (Test-Command 'code')) {
    Write-Err "VS Code CLI (code) not found in PATH. Launch VS Code, run 'Shell Command: Install 'code' command' and re-run."
    throw "VS Code CLI missing"
  }

  # Resolve user settings folder
  if ($IsWindows) {
    $VSUser = Join-Path $env:APPDATA 'Code\User'
  } elseif ($IsMacOS) {
    $VSUser = "$HOME/Library/Application Support/Code/User"
  } else {
    $VSUser = "$HOME/.config/Code/User"
  }
  Ensure-Dir $VSUser

  if (Test-Path -LiteralPath $VSSettings)   { Link-Or-Copy -Source $VSSettings   -Target (Join-Path $VSUser 'settings.json') } else { Write-Skip "No vscode/settings.json in repo" }
  if (Test-Path -LiteralPath $VSKeys)       { Link-Or-Copy -Source $VSKeys       -Target (Join-Path $VSUser 'keybindings.json') } else { Write-Skip "No vscode/keybindings.json in repo" }

  if (Test-Path -LiteralPath $VSExtensions) {
    try {
      Get-Content -LiteralPath $VSExtensions | ForEach-Object {
        $ext = $_.Trim()
        if ($ext) { code --install-extension $ext --force | Out-Null }
      }
      Write-OK "VS Code extensions installed from extensions.txt"
    } catch {
      Write-Warn "Could not install some VS Code extensions"
    }
  } else {
    Write-Skip "No vscode/extensions.txt in repo"
  }
}

# ---------------------------
# STEP: Git config
# ---------------------------
if ($GitConfig) {
  Write-Step "Linking Git config"

  if (Test-Path -LiteralPath $GitConfigFile)   { Link-Or-Copy -Source $GitConfigFile   -Target (Join-Path $HOME '.gitconfig') }
  else { Write-Skip "git/.gitconfig not found in repo" }

  if (Test-Path -LiteralPath $GitIgnoreGlobal) { Link-Or-Copy -Source $GitIgnoreGlobal -Target (Join-Path $HOME '.gitignore_global') }
  else { Write-Skip "git/.gitignore_global not found in repo" }
}

Write-OK "Setup complete."
Write-Host "`nTip: Reopen your terminal to load the new profile." -ForegroundColor DarkCyan
