#Requires -RunAsAdministrator

# Download and install Node LTS silently.
$website = 'https://nodejs.org/en/download/'
$content = (New-Object System.Net.WebClient).DownloadString($website)
$pattern = 'LTS Version: <strong>([\d.]+)</strong>'
$version = [Regex]::Matches($content, $pattern).Groups[1].Value
$address = "https://nodejs.org/dist/v$version/node-v$version-x64.msi"
$program = [System.IO.Path]::Combine($env:TEMP, [System.IO.Path]::GetFileName($address))
(New-Object System.Net.WebClient).DownloadFile($address, $program)
Start-Process -FilePath 'msiexec.exe' -ArgumentList "/i `"$program`" /qn /norestart" -NoNewWindow -Wait