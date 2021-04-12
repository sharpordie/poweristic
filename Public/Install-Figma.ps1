#Requires -RunAsAdministrator

# Download and install Figma silently.
$address = 'https://www.figma.com/download/desktop/win'
$program = [System.IO.Path]::Combine($env:TEMP, 'FigmaSetup.exe')
(New-Object System.Net.WebClient).DownloadFile($address, $program)
Start-Process -FilePath `"$program`" -ArgumentList '/s /S /q /Q /quiet /silent /SILENT /VERYSILENT' -NoNewWindow -Wait

# Remove the shortcut from the desktop directory.
$shortcut = [System.IO.Path]::Combine([Environment]::GetFolderPath('Desktop'), 'Figma*.lnk')
while (!(Test-Path $shortcut)) { Start-Sleep -Seconds 2 }
Remove-Item -Path $shortcut