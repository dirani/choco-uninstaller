# Chocolatey Cleanup Scripts (PowerShell)

A collection of PowerShell scripts to help fully remove Chocolatey and its installed packages from Windows systems.

## Scripts

- **`scripts/choco-uninstall-all.ps1`**  
  Uninstalls all Chocolatey-installed packages (skips the `chocolatey` base package). Includes self‑elevation and removes unused dependencies.

- **`scripts/choco-nuke.ps1`**  
  Removes Chocolatey itself:
  - Detects install path via `$env:ChocolateyInstall` or defaults to `C:\ProgramData\chocolatey`
  - Deletes the Chocolatey folder
  - Cleans Machine/User `Path` and unsets `ChocolateyInstall`
  - Self‑elevates when required

> ⚠️ **Warning:** These scripts are destructive. Review and test before using in production.

---

## Prerequisites

- Windows PowerShell 5.1 or PowerShell 7+
- Chocolatey installed (for `choco-uninstall-all.ps1` to list/uninstall packages)
- Ability to run with elevated privileges (both scripts attempt self‑elevation for machine‑scope changes)

---

## Usage

### Uninstall all Chocolatey packages (except Chocolatey)
```powershell
# From an elevated PowerShell session (or allow the script to prompt for elevation)
.\scripts\choco-uninstall-all.ps1
```

### Remove Chocolatey itself
```powershell
# From an elevated PowerShell session (or allow the script to prompt for elevation)
.\scripts\choco-nuke.ps1
```

> Tip: Run `Get-Command choco -ErrorAction SilentlyContinue` after completion to confirm `choco.exe` is no longer available.

---

## Repository Structure

```
.
├── README.md
├── LICENSE                  # Optional but recommended (e.g., MIT)
├── .gitignore               # Optional
├── scripts/
│   ├── choco-uninstall-all.ps1
│   └── choco-nuke.ps1
└── docs/
    └── improvements.md      # Best practices, future enhancements, design notes
```

---

## Best Practices & Future Improvements

This README includes a short summary. For the full list with rationale and examples, see **[`docs/improvements.md`](docs/improvements.md)**.

- Pre‑check for running processes that may lock files (e.g., `choco.exe`).
- Logging to a file for auditability.
- Post‑removal verification (PATH and `choco.exe` presence).
- Parameterize behavior (e.g., `-NoPause`, `-DryRun`).
- Robust error handling and exit codes.
- Support non‑default install paths and portable installs.
- Safe PATH editing with backups and restore option.

---

## Contributing

Issues and pull requests are welcome. If you add new scripts or enhancements, please:
- Include comments explaining key steps.
- Add usage notes to this README.
- Update `docs/improvements.md` when introducing new best practices.

---

## License

This project is licensed under the terms of the [MIT License](LICENSE).
