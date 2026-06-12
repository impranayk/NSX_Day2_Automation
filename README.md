# NSX Day 2 Automation

A PowerShell **module** for automating common VMware NSX Distributed Firewall
(DFW) tasks — bulk-create services, groups, and firewall rules, and look up
service/group IDs. Works two ways: as **scriptable cmdlets** for automation, or
through a **friendly interactive menu** for day-to-day use.

> ⚠️ **Disclaimer:** These functions create and modify firewall objects in your
> NSX environment. A bad bulk change can disrupt production traffic. **Test in a
> non-production environment first.** Provided "as is", without warranty. Use
> `-WhatIf` on the create functions to preview changes safely.

---

## Install

Once published to the PowerShell Gallery:

```powershell
Install-Module NsxDay2Automation -Scope CurrentUser
```

Or run from source: clone the repo and import the module folder.

```powershell
git clone https://github.com/your-username/Nsx_Day2_Automation.git
Import-Module .\NsxDay2Automation\NsxDay2Automation.psd1
```

---

## Configure

Copy the example config and fill in your NSX Manager details:

```powershell
Copy-Item .\NsxDay2Automation\config.example.json .\config.json
$env:NSX_CONFIG = (Resolve-Path .\config.json)
```

`config.json` is git-ignored, so your credentials stay local. See the security
note below about avoiding plaintext passwords in production.

---

## Use it as a menu

```powershell
Start-NsxAutomationMenu
```

```
[1] Create NSX Services for DFW
[2] Create NSX Groups for DFW
[3] Create DFW Firewall Rules
[4] Check NSX Service ID Information
[5] Check NSX Group ID Information
[Q] Quit
```

Each run is recorded to a timestamped transcript in `.\Logs`.

---

## Use it in scripts

Every menu action is also a function, so you can automate or chain them:

```powershell
# Preview, then create services from a CSV
New-NsxService -CsvPath .\samples\services.csv -WhatIf
New-NsxService -CsvPath .\samples\services.csv

# Create groups and rules
New-NsxGroup        -CsvPath .\samples\groups.csv
New-NsxFirewallRule -CsvPath .\samples\rules.csv -SecurityPolicy 'App-Tier-Policy'

# Look up IDs
Get-NsxService -Name 'HTTPS*'
Get-NsxGroup   -Name 'Web*'

# Pipeline-friendly
Import-Csv .\services.csv | New-NsxService
```

### Exported functions

| Function | Purpose |
|---|---|
| `New-NsxService` | Bulk-create NSX services |
| `New-NsxGroup` | Bulk-create NSX (IP-based) groups |
| `New-NsxFirewallRule` | Bulk-create DFW rules |
| `Get-NsxService` | Look up service IDs |
| `Get-NsxGroup` | Look up group IDs |
| `Start-NsxAutomationMenu` | Interactive menu wrapper |

---

## Input formats

Sample CSVs are in `samples/`:

- **services.csv** — `Name, Protocol, Port`
- **groups.csv** — `Name, IPAddresses` (semicolon-separated)
- **rules.csv** — `Name, Source, Destination, Service, Action`

> 📝 Adjust columns to match your environment. The API payloads in each function
> are NSX-T Policy API examples — confirm them against your NSX version, or drop
> in your existing tested logic. All transport goes through one place
> (`Private/Invoke-NsxRestMethod.ps1`), so swapping to PowerCLI or the Manager
> API is a single-file change.

---

## Prerequisites

- Windows PowerShell 5.1+ or PowerShell 7+
- NSX-T / VCF — tested against `<ADD YOUR VERSION>`
- Network access to your NSX Manager and an account with DFW permissions

---

## Security note

Storing a plaintext password in `config.json` is convenient but not ideal for
production. Consider the Windows Credential Manager, a `PSCredential`, or a
secrets vault, and adapt `Get-NsxConfig` / `Invoke-NsxRestMethod` accordingly.

---

## License

MIT — see [LICENSE](LICENSE).

## Author

**Dr. Pranay Jha** — Cloud & AI Architect, VMware vExpert
Website: https://drpranayjha.com · LinkedIn: https://www.linkedin.com/in/impranayk/
