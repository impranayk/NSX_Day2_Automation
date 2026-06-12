function New-NsxService {
<#
.SYNOPSIS
    Bulk-create NSX services for use in Distributed Firewall rules.
.DESCRIPTION
    Creates NSX services from a CSV file or from pipeline input, using the
    NSX-T Policy API. Each service is created idempotently with PUT under
    /policy/api/v1/infra/services/{id}.

    The payload below is an example. Adjust it to match your CSV schema and
    NSX version, or drop in your existing tested logic.
.PARAMETER CsvPath
    Path to a CSV with columns: Name, Protocol (TCP/UDP), Port.
.PARAMETER InputObject
    Service object(s) from the pipeline (e.g. via Import-Csv).
.EXAMPLE
    New-NsxService -CsvPath .\samples\services.csv
.EXAMPLE
    Import-Csv .\services.csv | New-NsxService -WhatIf
#>
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Csv')]
    param(
        [Parameter(ParameterSetName = 'Csv', Mandatory)]
        [ValidateScript({ Test-Path $_ })]
        [string]$CsvPath,

        [Parameter(ParameterSetName = 'Pipeline', ValueFromPipeline, Mandatory)]
        [psobject]$InputObject
    )

    begin {
        $config = Get-NsxConfig
        $rows   = New-Object System.Collections.Generic.List[object]
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
            $serviceId = ($row.Name -replace '\s', '_')

            if ($PSCmdlet.ShouldProcess($row.Name, 'Create NSX service')) {
                $body = @{
                    resource_type   = 'Service'
                    display_name    = $row.Name
                    service_entries = @(
                        @{
                            resource_type     = 'L4PortSetServiceEntry'
                            display_name      = $row.Name
                            l4_protocol       = $row.Protocol          # TCP / UDP
                            destination_ports = @("$($row.Port)")
                        }
                    )
                }

                try {
                    Invoke-NsxRestMethod -Method PUT -Config $config `
                        -Path "/policy/api/v1/infra/services/$serviceId" -Body $body
                    Write-Host "Created service: $($row.Name)" -ForegroundColor Green
                } catch {
                    Write-Warning "Failed to create service '$($row.Name)': $($_.Exception.Message)"
                }
            }
        }
    }
}
