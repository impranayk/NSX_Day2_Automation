function Get-NsxService {
<#
.SYNOPSIS
    Look up NSX services and their IDs.
.DESCRIPTION
    Retrieves NSX services via the NSX-T Policy API and returns display name,
    id, and path. Optionally filter by name (wildcards supported).
.PARAMETER Name
    Optional name filter (supports * wildcards).
.EXAMPLE
    Get-NsxService
.EXAMPLE
    Get-NsxService -Name 'HTTPS*'
#>
    [CmdletBinding()]
    param(
        [string]$Name
    )

    $config = Get-NsxConfig
    $result = Invoke-NsxRestMethod -Method GET -Config $config -Path '/policy/api/v1/infra/services'

    $services = $result.results
    if ($Name) {
        $services = $services | Where-Object { $_.display_name -like $Name }
    }

    $services | Select-Object display_name, id, path
}
