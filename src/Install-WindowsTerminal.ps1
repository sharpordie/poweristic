#Requires -RunAsAdministrator

# Download and install Windows Terminal silently.
$website = 'https://api.github.com/repos/microsoft/terminal/releases/latest'
$version = ((Invoke-WebRequest -Uri $website -UseBasicParsing | ConvertFrom-Json)[0].tag_name).Replace('v', '')
$address = "https://github.com/microsoft/terminal/releases/download/v$version/Microsoft.WindowsTerminal_${version}_8wekyb3d8bbwe.msixbundle"
$program = [System.IO.Path]::Combine($env:TEMP, [System.IO.Path]::GetFileName($address))
(New-Object System.Net.WebClient).DownloadFile($address, $program)
Add-AppxPackage -Path $program