<#
.SYNOPSIS
Collects read-only local Windows update evidence.
#>
[CmdletBinding()]
param([string]$OutputPath = ".\output\local-update-evidence.json")

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$os = Get-CimInstance Win32_OperatingSystem
$hotfixes = @(Get-HotFix | Sort-Object InstalledOn -Descending | Select-Object -First 15 HotFixID, Description, InstalledOn)

$report = [pscustomobject]@{
    CollectedAtUtc = (Get-Date).ToUniversalTime().ToString("o")
    ComputerName = $env:COMPUTERNAME
    OperatingSystem = $os.Caption
    Version = $os.Version
    BuildNumber = $os.BuildNumber
    RecentHotFixes = $hotfixes
    PendingWindowsUpdateReboot = Test-Path "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\RebootRequired"
}

$directory = Split-Path -Parent $OutputPath
if ($directory -and -not (Test-Path $directory)) { New-Item -ItemType Directory -Path $directory -Force | Out-Null }
$report | ConvertTo-Json -Depth 5 | Set-Content -Path $OutputPath -Encoding UTF8
Write-Output $report
