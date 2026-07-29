<#
.SYNOPSIS
Evaluates a synthetic endpoint inventory and produces a remediation plan.

.DESCRIPTION
This script reads exported inventory data. It does not contact, restart, patch,
retire or wipe devices.

.EXAMPLE
.\scripts\Get-EndpointCompliancePlan.ps1 -InputPath .\data\devices.csv -ReferenceDate 2026-07-29
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)][string]$InputPath,
    [Parameter()][datetime]$ReferenceDate = (Get-Date),
    [Parameter()][int]$MaxCheckInAgeDays = 7,
    [Parameter()][int]$MaxPatchAgeDays = 45,
    [Parameter()][string]$OutputPath = ".\output\compliance-plan.json"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

$devices = @(Import-Csv -Path $InputPath)
if (-not $devices.Count) { throw "No devices found." }

$results = foreach ($device in $devices) {
    $checkInAge = ($ReferenceDate.ToUniversalTime() - [datetime]$device.LastCheckInUtc).TotalDays
    $patchAge = ($ReferenceDate.ToUniversalTime() - [datetime]$device.LastQualityUpdateUtc).TotalDays
    $reasons = [System.Collections.Generic.List[string]]::new()

    if ($checkInAge -gt $MaxCheckInAgeDays) { $reasons.Add("Device has not checked in within policy") }
    if ($patchAge -gt $MaxPatchAgeDays) { $reasons.Add("Quality update age exceeds policy") }
    if ($device.BitLocker -ne "Enabled") { $reasons.Add("BitLocker not confirmed") }
    if ($device.Defender -ne "Healthy") { $reasons.Add("Endpoint protection requires attention") }
    if ($device.OSVersion -like "Windows 10*") { $reasons.Add("Operating-system lifecycle review required") }

    [pscustomobject]@{
        DeviceName = $device.DeviceName
        UpdateRing = $device.UpdateRing
        CheckInAgeDays = [math]::Round($checkInAge,1)
        PatchAgeDays = [math]::Round($patchAge,1)
        Compliant = $reasons.Count -eq 0
        Reasons = @($reasons)
        RecommendedAction = if ($reasons.Count) { "Investigate and remediate through approved endpoint process" } else { "No action" }
    }
}

$report = [pscustomobject]@{
    SchemaVersion = "1.0"
    Environment = "Synthetic lab"
    GeneratedAtUtc = (Get-Date).ToUniversalTime().ToString("o")
    DeviceCount = $results.Count
    CompliantCount = @($results | Where-Object Compliant).Count
    AttentionCount = @($results | Where-Object { -not $_.Compliant }).Count
    Devices = @($results)
}

$directory = Split-Path -Parent $OutputPath
if ($directory -and -not (Test-Path $directory)) { New-Item -ItemType Directory -Path $directory -Force | Out-Null }
$report | ConvertTo-Json -Depth 6 | Set-Content -Path $OutputPath -Encoding UTF8
Write-Output $report
