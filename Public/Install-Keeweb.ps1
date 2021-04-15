#Requires -RunAsAdministrator

# Download and install Keeweb silently.
$website = 'https://api.github.com/repos/keeweb/keeweb/releases/latest'
$version = ((Invoke-WebRequest -Uri $website -UseBasicParsing | ConvertFrom-Json)[0].tag_name).Replace('v', '')
$address = "https://github.com/keeweb/keeweb/releases/download/v$version/KeeWeb-$version.win.x64.exe"
$program = [System.IO.Path]::Combine($env:TEMP, [System.IO.Path]::GetFileName($address))
(New-Object System.Net.WebClient).DownloadFile($address, $program)
Start-Process -FilePath `"$program`" -ArgumentList '/S' -NoNewWindow -Wait