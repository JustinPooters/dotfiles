# Script to copy content from local profile.ps1 to $PROFILE
# Check if ./profile.ps1 exists
if (-not (Test-Path -Path "./profile.ps1")) {
    Write-Error "The file ./profile.ps1 does not exist in the current directory."
    exit 1
}

# Check if $PROFILE destination directory exists
$profileDir = Split-Path -Parent $PROFILE
if (-not (Test-Path -Path $profileDir)) {
    Write-Host "Creating profile directory: $profileDir"
    New-Item -ItemType Directory -Path $profileDir -Force | Out-Null
}

# Check if $PROFILE already exists
if (Test-Path -Path $PROFILE) {
    $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $backupFile = "$PROFILE.$timestamp.backup"
    Write-Host "Backing up existing $PROFILE to $backupFile"
    Copy-Item -Path $PROFILE -Destination $backupFile
}

# Copy content from ./profile.ps1 to $PROFILE
try {
    Get-Content -Path "./profile.ps1" | Set-Content -Path $PROFILE
    Write-Host "Successfully copied ./profile.ps1 to $PROFILE"
} catch {
    Write-Error "Failed to copy profile: $_"
    exit 1
}

Write-Host "Profile has been updated successfully."