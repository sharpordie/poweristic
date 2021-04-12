#Requires -RunAsAdministrator

# Download and install Visual C++ 2015 Redistributable Package (x86) silently.
$address = 'https://download.visualstudio.microsoft.com/download/pr/cf2cc5ea-1976-4451-b226-e86508914f0f/B4D433E2F66B30B478C0D080CCD5217CA2A963C16E90CAF10B1E0592B7D8D519/VC_redist.x86.exe'
$program = [System.IO.Path]::Combine($env:TEMP, [System.IO.Path]::GetFileName($address))
(New-Object System.Net.WebClient).DownloadFile($address, $program)
Start-Process -FilePath $program -ArgumentList '/fo /quiet /norestart' -NoNewWindow -Wait

# Download and install Visual C++ 2015 Redistributable Package (x64) silently.
$address = 'https://download.visualstudio.microsoft.com/download/pr/fd5d2eea-32b8-4814-b55e-28c83dd72d9c/952A0C6CB4A3DD14C3666EF05BB1982C5FF7F87B7103C2BA896354F00651E358/VC_redist.x64.exe'
$program = [System.IO.Path]::Combine($env:TEMP, [System.IO.Path]::GetFileName($address))
(New-Object System.Net.WebClient).DownloadFile($address, $program)
Start-Process -FilePath $program -ArgumentList '/fo /quiet /norestart' -NoNewWindow -Wait