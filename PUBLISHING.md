# Publishing to the PowerShell Gallery

A short checklist to get this module published so people can run
`Install-Module NsxDay2Automation`.

## 1. One-time setup

1. Create a free account at https://www.powershellgallery.com (sign in with a
   Microsoft account).
2. Go to your account settings and copy your **API key**.

## 2. Validate the module locally

From the folder that contains the `NsxDay2Automation` directory:

```powershell
# Manifest is valid and lists the right functions
Test-ModuleManifest .\NsxDay2Automation\NsxDay2Automation.psd1

# Module imports cleanly and exports the expected commands
Import-Module .\NsxDay2Automation\NsxDay2Automation.psd1 -Force
Get-Command -Module NsxDay2Automation
```

> Tip: run `Install-Module PSScriptAnalyzer` then
> `Invoke-ScriptAnalyzer -Path .\NsxDay2Automation -Recurse` to catch style
> and best-practice issues before publishing.

## 3. Update the manifest before first publish

In `NsxDay2Automation.psd1`, set the real repo URLs:

- `ProjectUri` → your GitHub repo URL
- `LicenseUri` → link to the LICENSE in your repo

(The GUID is already generated — keep it the same across all future versions.)

## 4. Publish

```powershell
Publish-Module -Path .\NsxDay2Automation -NSGalleryApiKey '<YOUR_API_KEY>'
```

> The parameter is actually `-NuGetApiKey`. Example:
> ```powershell
> Publish-Module -Path .\NsxDay2Automation -NuGetApiKey '<YOUR_API_KEY>'
> ```

Within a few minutes it appears at
`https://www.powershellgallery.com/packages/NsxDay2Automation`.

## 5. Releasing updates

1. Bump `ModuleVersion` in the manifest (e.g. `1.0.0` → `1.1.0`).
2. Update `ReleaseNotes`.
3. Run `Publish-Module` again. The Gallery rejects re-publishing the same
   version, so the bump is required.

Users update with:

```powershell
Update-Module NsxDay2Automation
```

## Recommended companion steps (for adoption)

- Tag a GitHub release (e.g. `v1.0.0`) matching the module version.
- Write a short blog post on drpranayjha.com walking through a real use case.
- Record a brief YouTube demo of `Start-NsxAutomationMenu` in action.
- Announce on LinkedIn and in VMware / VMUG / PowerShell communities.
