# Defender Health Export

PowerShell script that connects to the Microsoft Defender API and exports Defender device health information to JSON.

---

## Overview

This script authenticates against Microsoft Defender for Endpoint / Microsoft Defender XDR APIs using a Microsoft Entra ID App Registration.

The script retrieves machine/device information from:

```http
GET https://api.security.microsoft.com/api/machines
```

The exported data can be used for:

- Security reporting
- Device inventory tracking
- Power BI dashboards
- SQL Server ingestion
- Historical Defender health snapshots
- Logic App workflows
- Security automation pipelines

---

## Requirements

- PowerShell 5.1 or later
- Microsoft Defender for Endpoint
- Microsoft Entra ID App Registration
- Defender API permissions
- Admin consent granted

---

## Creating the Entra ID App Registration

Go to:

```text
Microsoft Entra Admin Center
→ Identity
→ Applications
→ App registrations
→ New registration
```

After creating the application, save:

| Value | Location |
|---|---|
| Tenant ID | App Registration → Overview |
| Client ID | App Registration → Overview |
| Client Secret | Certificates & secrets |

---

## Required API Permissions

Go to:

```text
DefenderHealthExport
→ API permissions
→ Add permission
→ APIs my organization uses
→ WindowsDefenderATP
→ Application permissions
```

### Minimum Permission for This Script

```text
Machine.Read.All
```

This is required for:

```http
GET https://api.security.microsoft.com/api/machines
```

and:

```http
GET https://api.security.microsoft.com/api/deviceavinfo
```

### Recommended Reporting Permissions

For fuller Defender reporting, add:

```text
Machine.Read.All
Alert.Read.All
Software.Read.All
Vulnerability.Read.All
SecurityRecommendation.Read.All
AdvancedQuery.Read.All
```

| Permission | Purpose |
|---|---|
| `Machine.Read.All` | Read Defender machine/device information |
| `Alert.Read.All` | Read Defender security alerts |
| `Software.Read.All` | Read installed software inventory |
| `Vulnerability.Read.All` | Read vulnerability/CVE data |
| `SecurityRecommendation.Read.All` | Read Defender security recommendations |
| `AdvancedQuery.Read.All` | Run Advanced Hunting queries |

### Optional Read/Write Automation Permissions

Only add these if the app needs to take action, not just report:

```text
Machine.ReadWrite.All
Alert.ReadWrite.All
Ti.ReadWrite
```

| Permission | Purpose |
|---|---|
| `Machine.ReadWrite.All` | Read and perform actions against Defender devices |
| `Alert.ReadWrite.All` | Read and manage Defender alerts |
| `Ti.ReadWrite` | Read/write threat intelligence indicators |

### Grant Admin Consent

After adding permissions, click:

```text
Grant admin consent for <Tenant Name>
```

The status should change from:

```text
Not granted
```

to:

```text
Granted
```

A new OAuth token must be generated after granting permissions.

---

## PowerShell Script

```powershell
$tenantId = "TENANT_ID"
$clientId = "CLIENT_ID"
$clientSecret = "CLIENT_SECRET"

# OAuth token request body
$body = @{
   client_id     = $clientId
   client_secret = $clientSecret
   scope         = "https://api.securitycenter.microsoft.com/.default"
   grant_type    = "client_credentials"
}

# Request OAuth token
$token = Invoke-RestMethod `
   -Method Post `
   -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" `
   -Body $body

# Authorization header
$headers = @{
   Authorization = "Bearer $($token.access_token)"
}

# Call Defender API
$result = Invoke-RestMethod `
   -Method Get `
   -Uri "https://api.security.microsoft.com/api/machines" `
   -Headers $headers

# Ensure export directory exists
New-Item -ItemType Directory -Path "C:\Temp" -Force | Out-Null

# Export selected Defender fields to JSON
$result.value |
Select-Object computerDnsName, healthStatus, riskScore, lastSeen |
ConvertTo-Json -Depth 10 |
Out-File "C:\Temp\DefenderMachines.json"

## This also works
## $result | ConvertTo-Json -Depth 10 | Out-File "C:\DefenderHealthReport\DefenderMachines.json"
```

---

## Output

Default export location:

```text
C:\Temp\DefenderMachines.json
```

Example JSON output:

```json
[
 {
   "computerDnsName": "DEVICE01.domain.local",
   "healthStatus": "Active",
   "riskScore": "Low",
   "lastSeen": "2026-05-27T18:30:00Z"
 }
]
```

---

## Understanding the PowerShell Objects

### `$result`

Contains the full Defender API response.

Example:

```json
{
 "@odata.context": "...",
 "value": [
   {
     "computerDnsName": "PC-01"
   }
 ]
}
```

### `$result.value`

Contains only the actual list of Defender devices/machines.

Example:

```json
[
 {
   "computerDnsName": "PC-01"
 }
]
```

---

## Understanding `Select-Object`

This line:

```powershell
Select-Object computerDnsName, healthStatus, riskScore, lastSeen
```

selects only specific properties from the Defender API response.

Equivalent SQL example:

```sql
SELECT computerDnsName, healthStatus, riskScore, lastSeen
FROM Machines
```

---

## Understanding `ConvertTo-Json -Depth 10`

The `-Depth` parameter controls how deeply nested PowerShell objects are converted into JSON.

It does **not** mean:

- top 10 devices
- first 10 rows
- first 10 records

It only controls JSON nesting depth.

---

## Troubleshooting

### Forbidden: Missing Application Roles

If you receive:

```text
Forbidden: Missing application roles
```

Verify:

- `Machine.Read.All` exists as an **Application** permission
- Admin consent has been granted
- A new OAuth token was requested after permissions were granted
- You are using the correct Tenant ID, Client ID, and Client Secret

---

### Export Path Errors

If the export path fails:

```powershell
New-Item -ItemType Directory -Path "C:\Temp" -Force
```

Or export to your Downloads folder:

```powershell
Out-File "$env:USERPROFILE\Downloads\DefenderMachines.json"
```

---

## Other Useful Defender APIs

### Machines API

```http
GET https://api.security.microsoft.com/api/machines
```

Required permission:

```text
Machine.Read.All
```

---

### Antivirus Health API

```http
GET https://api.security.microsoft.com/api/deviceavinfo
```

Required permission:

```text
Machine.Read.All
```

---

### Alerts API

```http
GET https://api.security.microsoft.com/api/alerts
```

Required permission:

```text
Alert.Read.All
```

---

### Vulnerabilities API

```http
GET https://api.security.microsoft.com/api/vulnerabilities
```

Required permission:

```text
Vulnerability.Read.All
```

---

### Advanced Hunting API

```http
POST https://api.security.microsoft.com/api/advancedqueries/run
```

Required permission:

```text
AdvancedQuery.Read.All
```

---

## Future Improvements

Possible future enhancements:

- CSV export support
- SQL Server ingestion
- Power BI dashboards
- Azure Logic App integration
- Scheduled Task automation
- SQL Agent scheduling
- Historical snapshot storage
- Defender AV health reporting using `/api/deviceavinfo`
- Advanced Hunting query support

---

## Example Use Cases

- Security Operations reporting
- Endpoint inventory auditing
- Risk score tracking
- Compliance reporting
- Historical device health analytics
- Internal SOC dashboards
- Device onboarding validation
- Endpoint monitoring automation

---

## References

- https://learn.microsoft.com/en-us/defender-endpoint/api/get-machines
- https://learn.microsoft.com/en-us/defender-endpoint/api/exposed-apis-create-app-webapp
- https://learn.microsoft.com/en-us/defender-endpoint/api/exposed-apis-list

---

## Author

Devon Nagy

Created for internal Microsoft Defender health reporting and automation workflows.
