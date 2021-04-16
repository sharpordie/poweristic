#Requires -RunAsAdministrator

# Download and install Brave silently.
$address = 'https://github.com/brave/brave-browser/releases/download/v1.21.77/BraveBrowserStandaloneSilentSetup.exe'
$program = [System.IO.Path]::Combine($env:TEMP, [System.IO.Path]::GetFileName($address))
(New-Object System.Net.WebClient).DownloadFile($address, $program)
Start-Process -FilePath `"$program`" -NoNewWindow
while (!(Get-Process -Name 'brave' -ErrorAction SilentlyContinue)) { Start-Sleep -Seconds 2 }
Start-Sleep -Seconds 5
Stop-Process -Name 'brave' -Force

# Install some extensions.
New-Item -Path 'HKLM:\Software\Policies\BraveSoftware\Brave' -ItemType RegistryKey -ErrorAction SilentlyContinue
New-Item -Path 'HKLM:\Software\Policies\BraveSoftware\Brave\ExtensionInstallForcelist' -ItemType RegistryKey -Force -ErrorAction SilentlyContinue
New-ItemProperty -Path 'HKLM:\Software\Policies\BraveSoftware\Brave\ExtensionInstallForcelist' -Name '1' -PropertyType 'String' -Value 'jaadjnlkjnhohljficgoddcjmndjfdmi;https://clients2.google.com/service/update2/crx' # Blank New Tab Page
New-ItemProperty -Path 'HKLM:\Software\Policies\BraveSoftware\Brave\ExtensionInstallForcelist' -Name '2' -PropertyType 'String' -Value 'cjpalhdlnbpafiamejdnhcphjbkeiagm;https://clients2.google.com/service/update2/crx' # uBlock Origin

# Setup extensions by starting Brave once.
Start-Process -FilePath "$env:LOCALAPPDATA\BraveSoftware\Brave-Browser\Application\brave.exe" -WindowStyle Minimized
Start-Sleep -Seconds 10
Stop-Process -Name 'brave' -Force

# Remove the shortcut from the desktop directory.
$shortcut = [System.IO.Path]::Combine([Environment]::GetFolderPath('Desktop'), 'Brave*.lnk')
Remove-Item -Path $shortcut