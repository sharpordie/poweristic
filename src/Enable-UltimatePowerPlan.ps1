#Requires -RunAsAdministrator

# Enable the Ultimate Performance power plan on the current machine.
$uuid = (powercfg -l | ForEach-Object { if ($_.contains('Ultimate Performance')) { $_.split()[3] } })
if ([string]::IsNullOrEmpty($uuid)) { Start-Process -FilePath 'powercfg.exe' -ArgumentList '-duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61' -NoNewWindow -Wait }
$uuid = (powercfg -l | ForEach-Object { if ($_.contains('Ultimate Performance')) { $_.split()[3] } })
Start-Process -FilePath 'powercfg.exe' -ArgumentList "-s $uuid" -NoNewWindow -Wait