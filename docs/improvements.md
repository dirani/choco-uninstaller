# Improvements & Best Practices

This document captures ideas to improve reliability, safety, and maintainability of the Chocolatey cleanup scripts. Use it as a living design log.

---

## 1) Pre‑checks & Safety

- **Detect running `choco.exe` or installers**  
  Before deletion, check for processes that may lock files:
  ```powershell
  $chocoProc = Get-Process choco -ErrorAction SilentlyContinue
  if ($chocoProc) { Write-Warning "choco.exe is running. Please close it before proceeding." }
  ```
- **Confirm intent** (optional, for interactive use)  
  Prompt the user before a destructive action:
  ```powershell
  $confirm = Read-Host "Proceed with uninstall/removal? (y/n)"
  if ($confirm -ne 'y') { return }
  ```

## 2) Logging & Auditing

- **Write to a log file** (include timestamps):
  ```powershell
  $log = Join-Path $env:TEMP "choco-cleanup_$(Get-Date -Format 'yyyyMMdd_HHmmss').log"
  Add-Content $log "[$(Get-Date)] Starting cleanup..."
  ```
- **Structured logs**  
  Consider CSV or JSON for machine‑readable logs when running in fleets.

## 3) Post‑Removal Verification

- **Verify PATH cleanup**  
  Re-read Machine/User PATH and ensure no `chocolatey` segments remain.
- **Check `choco.exe` absence**  
  ```powershell
  Get-Command choco -ErrorAction SilentlyContinue
  ```

## 4) Parameters & UX

Add parameters to make scripts flexible and CI‑friendly:

- `-NoPause` to skip waiting at the end.
- `-DryRun` to show actions without executing.
- `-Verbose` / `Write-Verbose` for detailed output.

Example parameter block:
```powershell
param(
  [switch]$DryRun,
  [switch]$NoPause
)
```

## 5) Error Handling & Exit Codes

- Use `try { } catch { } finally { }` with clear messages.
- Set meaningful exit codes (0 success; 1 elevation failed; 2 uninstall failure; 3 verification failed).

## 6) PATH Editing Best Practices

- **Backup PATH before changes**
- **Normalize separators & trim empties** when rejoining PATH segments.
- **Target specific Chocolatey entries** (e.g., `C:\ProgramData\chocolatey\bin`) when possible.

## 7) Support Non‑Default Installs

- Respect `$env:ChocolateyInstall` if set.
- Probe known alternate locations.

## 8) Idempotency & Re‑runs

- Scripts should be safe to run multiple times.

## 9) Documentation & Comments

- Explain **why** (not only **what**) for critical steps.

## 10) CI & Fleet Use

- Provide sample runbooks for automation (e.g., Intune/ConfigMgr).

---

### Appendix: Snippet Library

#### Safe PATH filter function (draft)
```powershell
function Remove-FromPath {
  param(
    [string]$Scope = "Machine",
    [string[]]$PatternsToRemove = @("C:\ProgramData\chocolatey\bin")
  )
  $path = [Environment]::GetEnvironmentVariable("Path", $Scope)
  if (-not $path) { return }
  $segments = $path -split ';' | Where-Object { $_ -and $_.Trim() -ne "" }
  $filtered = $segments | Where-Object { $_.ToLower() -notmatch "chocolatey" }
  $newPath = ($filtered) -join ';'
  [Environment]::SetEnvironmentVariable("Path", $newPath, $Scope)
}
```
