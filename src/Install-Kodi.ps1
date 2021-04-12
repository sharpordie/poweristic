#Requires -RunAsAdministrator

# Download and install Kodi silently.
$website = 'https://mirrors.kodi.tv/releases/windows/win64/?C=M&O=D'
$content = (New-Object System.Net.WebClient).DownloadString($website)
$pattern = 'kodi-([\w.-]+)-x64'
$version = [Regex]::Matches($content, $pattern).Groups[1].Value
$address = "https://mirrors.kodi.tv/releases/windows/win64/kodi-$version-x64.exe"
$program = [System.IO.Path]::Combine($env:TEMP, [System.IO.Path]::GetFileName($address))
(New-Object System.Net.WebClient).DownloadFile($address, $program)
Start-Process -FilePath `"$program`" -ArgumentList '/S' -NoNewWindow -Wait