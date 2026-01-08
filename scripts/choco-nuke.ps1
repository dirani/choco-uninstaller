function Test-IsAdmin {
  return ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

if (-not (Test-IsAdmin)) {
  Write-Host "Requesting elevation to remove Chocolatey system files..." -ForegroundColor Yellow
  $pwPath = (Get-Command powershell -ErrorAction SilentlyContinue).Source
  try {
    Start-Process -FilePath $pwPath -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs -WindowStyle Normal -Wait
  } catch {
    Write-Error "Elevation failed: $_"
  }
  exit
}

# 1. Detect Install Location
$chocoPath = $env:ChocolateyInstall
if (-not $chocoPath -or -not (Test-Path $chocoPath)) {
    $chocoPath = "C:\ProgramData\chocolatey"
}

# 2. Delete the folder
if (Test-Path $chocoPath) {
    Write-Host "Removing Chocolatey directory: $chocoPath" -ForegroundColor Cyan
    try {
        Remove-Item -Recurse -Force $chocoPath -ErrorAction Stop
        Write-Host "Directory removed." -ForegroundColor Green
    } catch {
        Write-Error "Could not completely remove folder (some files may be in use): $_"
    }
} else {
    Write-Host "Chocolatey directory not found." -ForegroundColor Yellow
}

# 3. Clean Environment Variables (Machine scope)
Write-Host "Cleaning Environment Variables..." -ForegroundColor Cyan

# Remove ChocolateyInstall variable
[Environment]::SetEnvironmentVariable("ChocolateyInstall", $null, "Machine")
[Environment]::SetEnvironmentVariable("ChocolateyInstall", $null, "User")

# Clean PATH (Machine)
$machinePath = [Environment]::GetEnvironmentVariable("Path", "Machine")
if ($machinePath -like "*chocolatey*") {
    $newPath = ($machinePath -split ';' | Where-Object { $_ -notlike "*chocolatey*" }) -join ';'
    [Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")
    Write-Host "Removed from Machine Path." -ForegroundColor Green
}

# Clean PATH (User)
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -like "*chocolatey*") {
    $newPath = ($userPath -split ';' | Where-Object { $_ -notlike "*chocolatey*" }) -join ';'
    [Environment]::SetEnvironmentVariable("Path", $newPath, "User")
    Write-Host "Removed from User Path." -ForegroundColor Green
}

Write-Host "Chocolatey has been removed from this system." -ForegroundColor Green
Pause
