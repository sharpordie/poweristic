#Requires -RunAsAdministrator

# Download and install Microsoft Edge silently.
$address = 'https://msedge.sf.dl.delivery.mp.microsoft.com/filestreamingservice/files/a175787f-65a6-4de9-aab9-8bf9c9654f10/MicrosoftEdgeEnterpriseX64.msi'
$program = [System.IO.Path]::Combine($env:TEMP, [System.IO.Path]::GetFileName($address))
(New-Object System.Net.WebClient).DownloadFile($address, $program)
Start-Process -FilePath 'msiexec.exe' -ArgumentList "/i `"$program`" /qn /norestart" -NoNewWindow -Wait

# Make sure the key exists.
New-Item -Path 'HKLM:\Software\Wow6432Node\Microsoft\Edge\Extensions'

# Install the uBlock Origin extension from the Microsoft Edge Web Store.
New-Item -Path 'HKLM:\Software\Wow6432Node\Microsoft\Edge\Extensions\odfafepnkmbhccpbejgmiehpchacaeak'
Set-ItemProperty -Path 'HKLM:\Software\Wow6432Node\Microsoft\Edge\Extensions\odfafepnkmbhccpbejgmiehpchacaeak' -Name 'update_url' -Value 'https://edge.microsoft.com/extensionwebstorebase/v1/crx'

# Install the Medium Hackd extension from the Chrome Web Store.
New-Item -Path 'HKLM:\Software\Wow6432Node\Microsoft\Edge\Extensions\fjjfjlecfadomdpeohehfhnbekekdild'
Set-ItemProperty -Path 'HKLM:\Software\Wow6432Node\Microsoft\Edge\Extensions\fjjfjlecfadomdpeohehfhnbekekdild' -Name 'update_url' -Value 'https://clients2.google.com/service/update2/crx'

# Remove the shortcut from the desktop directory.
$shortcut = [System.IO.Path]::Combine([Environment]::GetFolderPath("Desktop"), "*Edge*.lnk")
if (Test-Path -Path $shortcut) { Remove-Item -Path $shortcut }
$shortcut = [System.IO.Path]::Combine([Environment]::GetFolderPath("CommonDesktopDirectory"), "*Edge*.lnk")
if (Test-Path -Path $shortcut) { Remove-Item -Path $shortcut }