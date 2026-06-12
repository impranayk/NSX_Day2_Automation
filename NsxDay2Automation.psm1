#Requires -Version 5.1
<#
    NsxDay2Automation root module.
    Dot-sources every function in .\Public and .\Private, then exports the
    public functions. Keeping one function per file makes the module easy to
    maintain and test.
#>

$Public  = @( Get-ChildItem -Path (Join-Path $PSScriptRoot 'Public')  -Filter '*.ps1' -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path (Join-Path $PSScriptRoot 'Private') -Filter '*.ps1' -ErrorAction SilentlyContinue )

foreach ($file in @($Public + $Private)) {
    try {
        . $file.FullName
    } catch {
        Write-Error "Failed to import function '$($file.FullName)': $($_.Exception.Message)"
    }
}

if ($Public.Count -gt 0) {
    Export-ModuleMember -Function $Public.BaseName
}
