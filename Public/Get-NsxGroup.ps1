function Get-NsxGroup {
<#
.SYNOPSIS
    Look up NSX groups and their IDs.
.DESCRIPTION
    Retrieves NSX groups for a domain via the NSX-T Policy API and returns
    display name, id, and path. Optionally filter by name (wildcards supported).
.PARAMETER Name
    Optional name filter (supports * wildcards).
.PARAMETER Domain
    NSX domain. Defaults to the config value or 'default'.
.EXAMPLE
    Get-NsxGroup -Name 'Web*'
#>
    [CmdletBinding()]
    param(
        [string]$Name,
        [string]$Domain
    )

    $config = Get-NsxConfig
    if (-not $Domain) { $Domain = if ($config.defaultDomain) { $config.defaultDomain } else { 'default' } }

    $result = Invoke-NsxRestMethod -Method GET -Config $config `
        -Path "/policy/api/v1/infra/domains/$Domain/groups"

    $groups = $result.results
    if ($Name) {
        $groups = $groups | Where-Object { $_.display_name -like $Name }
    }

    $groups | Select-Object display_name, id, path
}
