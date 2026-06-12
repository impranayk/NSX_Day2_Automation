#Requires -Version 5.1
<#
    One-click launcher for the NSX Day 2 Automation.
    Just run this and you get the menu. It handles execution policy, config,
    and importing the module for you.
#>

Set-Location $PSScriptRoot

# Allow scripts to run for THIS session only (does not change system settings)
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass -Force

# First run: create config.json from the template and let you fill it in
$config = Join-Path $PSScriptRoot 'config.json'
if (-not (Test-Path $config)) {
    Copy-Item (Join-Path $PSScriptRoot 'config.example.json') $config
    Write-Host "First run: created config.json." -ForegroundColor Yellow
    Write-Host "Opening it now - enter your NSX Manager URL, username and password, then save and close." -ForegroundColor Yellow
    Start-Process notepad.exe $config -Wait
}
$env:NSX_CONFIG = $config

# Import the module and open the menu
Import-Module (Join-Path $PSScriptRoot 'NsxDay2Automation.psd1') -Force
Start-NsxAutomationMenu
