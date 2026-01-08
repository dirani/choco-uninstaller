function Test-IsAdmin {
  return ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# 1. Self-elevation Check
if (-not (Test-IsAdmin)) {
  Write-Host "Requesting elevation..." -ForegroundColor Yellow
  $pwPath = (Get-Command powershell -ErrorAction SilentlyContinue).Source
  if (-not $pwPath) { Write-Error "Cannot locate powershell executable."; exit 2 }

  # Relaunch this script with 'RunAs' to trigger the UAC/Credential prompt
  try {
    Start-Process -FilePath $pwPath -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs -WindowStyle Normal -Wait
  } catch {
    Write-Error "Elevation failed or was cancelled: $_"
    exit 1
  }
  exit 0
}

# 2. Running Elevated Logic
Write-Host "Scanning for installed Chocolatey packages..." -ForegroundColor Cyan

# Get list in machine-readable format: name|version
$rawOutput = choco list --local-only --limit-output

if (-not $rawOutput) {
    Write-Host "No packages found." -ForegroundColor Yellow
    Pause
    exit
}

# Parse and filter list
$packagesToUninstall = @()
foreach ($line in $rawOutput) {
    $pkgName = $line.Split('|')[0]
    # We skip 'chocolatey' itself to avoid breaking the tool mid-run
    if ($pkgName -ne 'chocolatey') {
        $packagesToUninstall += $pkgName
    }
}

if ($packagesToUninstall.Count -eq 0) {
    Write-Host "No packages to uninstall (skipping 'chocolatey' base package)." -ForegroundColor Green
    Pause
    exit
}

Write-Host "Found $($packagesToUninstall.Count) packages to uninstall:" -ForegroundColor Cyan
$packagesToUninstall | ForEach-Object { Write-Host " - $_" }
Write-Host ""

# 3. Perform Uninstall
foreach ($pkg in $packagesToUninstall) {
    Write-Host "Uninstalling $pkg..." -ForegroundColor Yellow
    # --remove-dependencies ensures extensions/dependencies are cleaned up if unused
    choco uninstall $pkg -y --remove-dependencies
}

Write-Host "Uninstall process completed." -ForegroundColor Green
Pause
