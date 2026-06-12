@{
    # Script module associated with this manifest
    RootModule        = 'NsxDay2Automation.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = 'c6b540fd-9398-46bc-bfae-6c6128b81369'

    Author            = 'Dr. Pranay Jha'
    CompanyName       = 'Dr. Pranay Jha'
    Copyright         = '(c) 2026 Dr. Pranay Jha. Released under the MIT License.'

    Description       = 'Menu-driven and scriptable PowerShell toolkit for automating VMware NSX Distributed Firewall (DFW) tasks: bulk-create services, groups, and firewall rules, and look up service/group IDs via the NSX-T Policy API.'

    PowerShellVersion = '5.1'

    # Public functions exported by this module
    FunctionsToExport = @(
        'New-NsxService',
        'New-NsxGroup',
        'New-NsxFirewallRule',
        'Get-NsxService',
        'Get-NsxGroup',
        'Start-NsxAutomationMenu'
    )
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()

    PrivateData = @{
        PSData = @{
            Tags         = @('NSX', 'VMware', 'DFW', 'Firewall', 'Automation', 'Networking', 'Security', 'Virtualization', 'PowerCLI', 'NSX-T')
            LicenseUri   = 'https://github.com/your-username/Nsx_Day2_Automation/blob/main/LICENSE'
            ProjectUri   = 'https://github.com/your-username/Nsx_Day2_Automation'
            ReleaseNotes = 'Initial release: bulk create NSX DFW services, groups, and rules; service/group ID lookups; interactive menu wrapper.'
        }
    }
}
