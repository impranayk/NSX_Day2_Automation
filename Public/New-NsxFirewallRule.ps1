function New-NsxFirewallRule {
<#
.SYNOPSIS
    Bulk-create Distributed Firewall (DFW) rules.
.DESCRIPTION
    Creates DFW rules from a CSV file or pipeline input via the NSX-T Policy
    API, idempotently with PUT under
    /policy/api/v1/infra/domains/{domain}/security-policies/{policy}/rules/{id}.

    Adjust the rule body to match your CSV schema and NSX version, or drop in
    your existing tested logic.
.PARAMETER CsvPath
    Path to a CSV with columns: Name, Source, Destination, Service, Action.
    Source/Destination accept group paths or 'ANY'. Service accepts a service
    path or 'ANY'. Action is ALLOW, DROP, or REJECT.
.PARAMETER InputObject
    Rule object(s) from the pipeline.
.PARAMETER SecurityPolicy
    Target security policy ID the rules are added to.
.PARAMETER Domain
    NSX domain. Defaults to the config value or 'default'.
.EXAMPLE
    New-NsxFirewallRule -CsvPath .\samples\rules.csv -SecurityPolicy 'App-Tier-Policy'
#>
    [CmdletBinding(SupportsShouldProcess, DefaultParameterSetName = 'Csv')]
    param(
        [Parameter(ParameterSetName = 'Csv', Mandatory)]
        [ValidateScript({ Test-Path $_ })]
        [string]$CsvPath,

        [Parameter(ParameterSetName = 'Pipeline', ValueFromPipeline, Mandatory)]
        [psobject]$InputObject,

        [Parameter(Mandatory)]
        [string]$SecurityPolicy,

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
            $ruleId = ($row.Name -replace '\s', '_')

            if ($PSCmdlet.ShouldProcess($row.Name, "Create DFW rule in policy '$SecurityPolicy'")) {
                $body = @{
                    resource_type      = 'Rule'
                    display_name       = $row.Name
                    source_groups      = @(if ($row.Source)      { $row.Source }      else { 'ANY' })
                    destination_groups = @(if ($row.Destination) { $row.Destination } else { 'ANY' })
                    services           = @(if ($row.Service)     { $row.Service }     else { 'ANY' })
                    action             = if ($row.Action) { $row.Action.ToUpper() } else { 'ALLOW' }
                    scope              = @('ANY')
                }

                try {
                    Invoke-NsxRestMethod -Method PUT -Config $config `
                        -Path "/policy/api/v1/infra/domains/$Domain/security-policies/$SecurityPolicy/rules/$ruleId" `
                        -Body $body
                    Write-Host "Created rule: $($row.Name)" -ForegroundColor Green
                } catch {
                    Write-Warning "Failed to create rule '$($row.Name)': $($_.Exception.Message)"
                }
            }
        }
    }
}
