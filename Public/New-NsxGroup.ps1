function New-NsxGroup {
<#
.SYNOPSIS
    Bulk-create NSX groups (IP-based) for use in DFW rules.
.DESCRIPTION
    Creates NSX groups from a CSV file or pipeline input via the NSX-T Policy
    API, idempotently with PUT under
    /policy/api/v1/infra/domains/{domain}/groups/{id}.

    Adjust the membership expression to match your needs (IP sets, tags,
    VMs, etc.) or drop in your existing tested logic.
.PARAMETER CsvPath
    Path to a CSV with columns: Name, IPAddresses (semicolon-separated).
.PARAMETER InputObject
    Group object(s) from the pipeline.
.PARAMETER Domain
    NSX domain. Defaults to the config value or 'default'.
.EXAMPLE
    New-NsxGroup -CsvPath .\samples\groups.csv
#>
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Csv')]
    param(
        [Parameter(ParameterSetName = 'Csv', Mandatory)]
        [ValidateScript({ Test-Path $_ })]
        [string]$CsvPath,

        [Parameter(ParameterSetName = 'Pipeline', ValueFromPipeline, Mandatory)]
        [psobject]$InputObject,

        [string]$Domain
    )

    begin {
        $config = Get-NsxConfig
        if (-not $Domain) { $Domain = if ($config.defaultDomain) { $config.defaultDomain } else { 'default' } }
        $rows = New-Object System.Collections.Generic.List[object]
    }
    process {
        if ($PSCmdlet.ParameterSetName -eq 'Csv') {
            Import-Csv -Path $CsvPath | ForEach-Object { $rows.Add($_) }
        } else {
            $rows.Add($InputObject)
        }
    }
    end {
        foreach ($row in $rows) {
            $groupId = ($row.Name -replace '\s', '_')
            $ips     = @($row.IPAddresses -split ';' | Where-Object { $_ })

            if ($PSCmdlet.ShouldProcess($row.Name, 'Create NSX group')) {
                $body = @{
                    resource_type = 'Group'
                    display_name  = $row.Name
                    expression    = @(
                        @{
                            resource_type = 'IPAddressExpression'
                            ip_addresses  = $ips
                        }
                    )
                }

                try {
                    Invoke-NsxRestMethod -Method PUT -Config $config `
                        -Path "/policy/api/v1/infra/domains/$Domain/groups/$groupId" -Body $body
                    Write-Host "Created group: $($row.Name)" -ForegroundColor Green
                } catch {
                    Write-Warning "Failed to create group '$($row.Name)': $($_.Exception.Message)"
                }
            }
        }
    }
}
