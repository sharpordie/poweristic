#Requires -RunAsAdministrator

# Download and install Brave silently.
$address = 'https://github.com/brave/brave-browser/releases/download/v1.21.77/BraveBrowserStandaloneSilentSetup.exe'
$program = [System.IO.Path]::Combine($env:TEMP, [System.IO.Path]::GetFileName($address))
(New-Object System.Net.WebClient).DownloadFile($address, $program)
Start-Process -FilePath `"$program`" -NoNewWindow
while (!(Get-Process -Name 'brave' -ErrorAction SilentlyContinue)) { Start-Sleep -Seconds 2 }
Start-Sleep -Seconds 5
Stop-Process -Name 'brave' -Force

# Remove the shortcut from the desktop directory.
$shortcut = [System.IO.Path]::Combine([Environment]::GetFolderPath('Desktop'), 'Brave*.lnk')
Remove-Item -Path $shortcut