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

# Install the Blank New Tab Page extension from the Chrome Web Store.
New-Item -Path 'HKLM:\Software\Wow6432Node\Microsoft\Edge\Extensions\jaadjnlkjnhohljficgoddcjmndjfdmi'
Set-ItemProperty -Path 'HKLM:\Software\Wow6432Node\Microsoft\Edge\Extensions\jaadjnlkjnhohljficgoddcjmndjfdmi' -Name 'update_url' -Value 'https://clients2.google.com/service/update2/crx'

# Run it once.
Start-Process -FilePath "${env:ProgramFiles(x86)}\Microsoft\Edge\Application\msedge.exe" -NoNewWindow
Start-Sleep -Seconds 10
Stop-Process -Name 'msedge'
Start-Sleep -Seconds 2

# Disable the first run page.
New-Item -Path 'HKLM:\Software\Policies\Microsoft\MicrosoftEdge'
New-Item -Path 'HKLM:\Software\Policies\Microsoft\MicrosoftEdge\Main'
Set-ItemProperty -Path 'HKLM:\Software\Policies\Microsoft\MicrosoftEdge\Main' -Name 'PreventFirstRunPage' -Value '1'

# Remove the shortcut from the desktop directory.
$shortcut = [System.IO.Path]::Combine([Environment]::GetFolderPath("Desktop"), "*Edge*.lnk")
if (Test-Path -Path $shortcut) { Remove-Item -Path $shortcut }
$shortcut = [System.IO.Path]::Combine([Environment]::GetFolderPath("CommonDesktopDirectory"), "*Edge*.lnk")
if (Test-Path -Path $shortcut) { Remove-Item -Path $shortcut }