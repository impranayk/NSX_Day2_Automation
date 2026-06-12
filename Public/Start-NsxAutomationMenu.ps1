function Start-NsxAutomationMenu {
<#
.SYNOPSIS
    Interactive menu for the NSX Day 2 Automation.
.DESCRIPTION
    A friendly press-a-number menu that calls the toolkit's functions. Each run
    is recorded to a timestamped transcript in the Logs folder. This is a
    convenience wrapper — every action is also available as its own function
    (New-NsxService, Get-NsxGroup, etc.) for scripting and automation.
.PARAMETER LogDirectory
    Where transcripts are written. Defaults to .\Logs under the current folder.
.EXAMPLE
    Start-NsxAutomationMenu
#>
    [CmdletBinding()]
    param(
        [string]$LogDirectory = (Join-Path (Get-Location) 'Logs')
    )

    if (-not (Test-Path $LogDirectory)) {
        New-Item -ItemType Directory -Path $LogDirectory -ErrorAction SilentlyContinue | Out-Null
    }

    $menuItems = @(
        @{ Key = '1'; Name = 'Create NSX Services for DFW' }
        @{ Key = '2'; Name = 'Create NSX Groups for DFW' }
        @{ Key = '3'; Name = 'Create DFW Firewall Rules' }
        @{ Key = '4'; Name = 'Check NSX Service ID Information' }
        @{ Key = '5'; Name = 'Check NSX Group ID Information' }
        @{ Key = 'Q'; Name = 'Quit' }
    )

    function Show-Menu {
        Clear-Host
        Write-Host "===================================" -ForegroundColor DarkCyan
        Write-Host " NSX Day 2 Automation"             -ForegroundColor Cyan
        Write-Host " Developed By: Dr. Pranay Jha"     -ForegroundColor Gray
        Write-Host " Contact: drpranayjha@gmail.com"   -ForegroundColor Gray
        Write-Host "===================================`n"
        foreach ($item in $menuItems) {
            Write-Host ("[{0}] {1}" -f $item.Key, $item.Name)
        }
        Write-Host ""
    }

    do {
        Show-Menu
        $choice = Read-Host "Enter your choice"

        $timestamp  = Get-Date -Format "yyyyMMdd-HHmmss"
        $transcript = Join-Path $LogDirectory "nsx-$timestamp.log"

        switch ($choice.ToUpper()) {

            '1' {
                $csv = Read-Host "Path to services CSV"
                Start-Transcript -Path $transcript | Out-Null
                try { New-NsxService -CsvPath $csv } catch { Write-Warning $_.Exception.Message }
                Stop-Transcript | Out-Null
            }
            '2' {
                $csv = Read-Host "Path to groups CSV"
                Start-Transcript -Path $transcript | Out-Null
                try { New-NsxGroup -CsvPath $csv } catch { Write-Warning $_.Exception.Message }
                Stop-Transcript | Out-Null
            }
            '3' {
                $csv    = Read-Host "Path to rules CSV"
                $policy = Read-Host "Target security policy ID"
                Start-Transcript -Path $transcript | Out-Null
                try { New-NsxFirewallRule -CsvPath $csv -SecurityPolicy $policy } catch { Write-Warning $_.Exception.Message }
                Stop-Transcript | Out-Null
            }
            '4' {
                $name = Read-Host "Service name filter (blank for all)"
                if ($name) { Get-NsxService -Name $name | Format-Table -AutoSize }
                else       { Get-NsxService          | Format-Table -AutoSize }
            }
            '5' {
                $name = Read-Host "Group name filter (blank for all)"
                if ($name) { Get-NsxGroup -Name $name | Format-Table -AutoSize }
                else       { Get-NsxGroup          | Format-Table -AutoSize }
            }
            'Q' { return }
            default {
                Write-Host "Invalid choice. Try again." -ForegroundColor Yellow
                Start-Sleep -Seconds 1
                continue
            }
        }

        Write-Host "`nPress Enter to continue..."
        Read-Host | Out-Null

    } while ($true)
}
