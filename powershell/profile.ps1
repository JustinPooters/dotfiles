# PowerShell Profile - Main File ($PROFILE)

# Define the base profile directory (same directory as your $PROFILE)
$profileDir = Split-Path -Path $PROFILE -Parent
$customProfilesDir = Join-Path -Path $profileDir -ChildPath "ProfileModules"

# Create the directory if it doesn't exist
if (-not (Test-Path -Path $customProfilesDir)) {
    Write-Host "Creating profile modules directory..."
    New-Item -ItemType Directory -Path $customProfilesDir -Force | Out-Null
}

# ---------------------------
# MODULE IMPORTS
# ---------------------------
oh-my-posh init pwsh --config "https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/refs/heads/main/themes/amro.omp.json" | Invoke-Expression

Import-Module -Name Terminal-Icons
Import-Module -Name PSReadLine

# ---------------------------
# FUNCTIONS
# ---------------------------
function dev {
    $username = $env:USERNAME
    $devPath = "C:\Users\$username\Development"
    
    if (-not (Test-Path -Path $devPath)) {
        Write-Host "Development folder doesn't exist. Creating it now..." -ForegroundColor Yellow
        New-Item -ItemType Directory -Path $devPath -Force | Out-Null
        Write-Host "Created Development folder at: $devPath" -ForegroundColor Green
    }
    
    Set-Location -Path $devPath
    Write-Host "Navigated to Development folder" -ForegroundColor Cyan
}

function whereami {
    Get-Location
}

function .. {
    cd ..
}

function notepad { 
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$false, Position=0)]
        [string]$file
    ) 
    & "C:\Program Files\Notepad++\notepad++.exe" $file
}

function touch { 
    [CmdletBinding()]
    Param
    (
        [Parameter(Mandatory=$true, Position=0)]
        [string]$file
    ) 
    New-Item -Path $file -ItemType File -Force
}

# ---------------------------
# SETTINGS
# ---------------------------
Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

# ---------------------------
# STARTUP COMMANDS
# ---------------------------

clear
screenfetch

Write-Host "PowerShell profile loaded" -ForegroundColor Green