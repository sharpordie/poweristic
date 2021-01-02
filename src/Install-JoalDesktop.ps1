#Requires -RunAsAdministrator

# Download and install Joal Desktop silently.
$website = 'https://api.github.com/repos/anthonyraymond/joal-desktop/releases/latest'
$version = ((Invoke-WebRequest -Uri $website -UseBasicParsing | ConvertFrom-Json)[0].tag_name).Replace('v', '')
$address = "https://github.com/anthonyraymond/joal-desktop/releases/download/v$version/JoalDesktop-$version-win.exe"
$program = [System.IO.Path]::Combine($env:TEMP, [System.IO.Path]::GetFileName($address))
(New-Object System.Net.WebClient).DownloadFile($address, $program)
Start-Process -FilePath `"$program`" -ArgumentList '/S' -NoNewWindow -Wait

# Remove the shortcut from the desktop directory.
$shortcut = [System.IO.Path]::Combine([Environment]::GetFolderPath('Desktop'), 'Joal*.lnk')
if (Test-Path -Path $shortcut) { Remove-Item -Path $shortcut }