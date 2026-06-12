function Get-NsxConfig {
<#
.SYNOPSIS
    Loads NSX connection settings from JSON.
.DESCRIPTION
    Reads the config file pointed to by $env:NSX_CONFIG, or config.json in the
    module root if that variable is not set. Keeps NSX Manager address and
    credentials out of the code and out of source control.
.PARAMETER Path
    Optional explicit path to a config JSON file.
#>
    [CmdletBinding()]
    param(
        [string]$Path = $env:NSX_CONFIG
    )

    if (-not $Path) {
        $Path = Join-Path $PSScriptRoot '..\config.json'
    }

    if (-not (Test-Path $Path)) {
        throw "NSX config not found. Set `$env:NSX_CONFIG or create config.json (copy config.example.json)."
    }

    return Get-Content -Path $Path -Raw | ConvertFrom-Json
}
