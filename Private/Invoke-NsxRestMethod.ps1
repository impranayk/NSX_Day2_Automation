function Invoke-NsxRestMethod {
<#
.SYNOPSIS
    Calls the NSX-T Policy API with auth, JSON body, and cert handling.
.DESCRIPTION
    Thin wrapper around Invoke-RestMethod that adds basic auth from the loaded
    config, serializes the body to JSON, and optionally skips certificate
    validation (controlled by config.validateCertificate).

    NOTE: This uses the NSX-T *Policy* API. If your environment or existing
    scripts use VMware PowerCLI or the Manager API instead, replace the body of
    this function accordingly — every public function calls through here, so it
    is the single place to swap the transport.
#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('GET', 'POST', 'PUT', 'PATCH', 'DELETE')]
        [string]$Method,

        [Parameter(Mandatory)]
        [string]$Path,                 # e.g. /policy/api/v1/infra/services

        [object]$Body,

        [object]$Config = (Get-NsxConfig)
    )

    $uri = "$($Config.nsxManager.TrimEnd('/'))$Path"

    $auth = [System.Convert]::ToBase64String(
        [System.Text.Encoding]::ASCII.GetBytes("$($Config.username):$($Config.password)")
    )

    $params = @{
        Method  = $Method
        Uri     = $uri
        Headers = @{
            Authorization  = "Basic $auth"
            'Content-Type' = 'application/json'
        }
    }

    if ($Body) {
        $params.Body = ($Body | ConvertTo-Json -Depth 10)
    }

    if ($Config.timeoutSeconds) {
        $params.TimeoutSec = $Config.timeoutSeconds
    }

    # Certificate validation toggle
    if (-not $Config.validateCertificate) {
        if ($PSVersionTable.PSVersion.Major -ge 6) {
            $params.SkipCertificateCheck = $true
        } else {
            # Windows PowerShell 5.1 has no -SkipCertificateCheck; relax globally.
            # Use only against trusted lab/managers.
            Add-Type -ErrorAction SilentlyContinue @"
using System.Net;
using System.Security.Cryptography.X509Certificates;
public class NsxTrustAllCerts : ICertificatePolicy {
    public bool CheckValidationResult(ServicePoint sp, X509Certificate cert, WebRequest req, int problem) { return true; }
}
"@
            [System.Net.ServicePointManager]::CertificatePolicy = New-Object NsxTrustAllCerts
            [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
        }
    }

    Invoke-RestMethod @params
}
