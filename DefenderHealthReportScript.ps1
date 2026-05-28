$tenantId = "YOUR_TENANT_ID"
$clientId = "YOUR_CLIENT_ID"
$clientSecret = "YOUR_CLIENT_SECRET"
# Get OAuth token
$body = @{
   client_id     = $clientId
   client_secret = $clientSecret
   scope         = "https://api.securitycenter.microsoft.com/.default"
   grant_type    = "client_credentials"
}
$token = Invoke-RestMethod `
   -Method Post `
   -Uri "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token" `
   -Body $body
# Auth header
$headers = @{
   Authorization = "Bearer $($token.access_token)"
}
# Call Defender API
$result = Invoke-RestMethod `
   -Method Get `
   -Uri "https://api.security.microsoft.com/api/machines" `
   -Headers $headers
# Export raw JSON
$result | ConvertTo-Json -Depth 10 | Out-File "C:\DefenderHealthReport\DefenderMachines.json"
