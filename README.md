# Endpoint Management & Patch Compliance Lab

A Windows endpoint-operations lab covering update-ring design, patch and security compliance, read-only local evidence collection, remediation planning and safe operational boundaries.

## What it demonstrates

- Windows device inventory analysis
- staged Preview, Pilot and Broad update rings
- check-in and patch-age thresholds
- BitLocker and Defender health signals
- operating-system lifecycle review
- read-only PowerShell evidence collection
- explicit handling of high-impact reset, retire and wipe actions
- automated PowerShell syntax validation

## Contents

```text
├── data/devices.csv
├── scripts/Get-EndpointCompliancePlan.ps1
├── scripts/Get-LocalUpdateEvidence.ps1
├── docs/update-rings.md
├── docs/remediation-runbook.md
└── .github/workflows/powershell-syntax.yml
```

## Generate a compliance plan

```powershell
.\scripts\Get-EndpointCompliancePlan.ps1 `
  -InputPath .\data\devices.csv `
  -ReferenceDate 2026-07-29 `
  -OutputPath .\output\compliance-plan.json
```

The inventory is synthetic. The resulting JSON separates compliant devices from those needing investigation and preserves the reason for each decision.

## Collect local update evidence

```powershell
.\scripts\Get-LocalUpdateEvidence.ps1 `
  -OutputPath .\output\local-update-evidence.json
```

The collector reads Windows version, build, recent hotfixes and a common pending-restart indicator. It does not install updates, restart the device or change policy.

## Operational approach

1. Establish device ownership and intended policy.
2. Collect evidence before remediation.
3. Distinguish stale inventory from an actual compliance failure.
4. Validate dependencies such as storage, power and network.
5. Pilot change before broad deployment.
6. Record exception owner and expiry.
7. Confirm build and business-application health after installation.

## Evidence boundary

This repository does not claim a live Intune or MECM deployment. Real device exports, policy screenshots and installation results will be added only after an authorised lab is configured and verified.

## Author

**Isaac Lovelace Yanney** — IT Support & Technical Operations  
[GitHub](https://github.com/isaacyanney) · [LinkedIn](https://www.linkedin.com/in/isaac-lovelace-yanney/)
