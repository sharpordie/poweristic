#Requires -RunAsAdministrator

# Download and install Raven Reader silently.
$website = 'https://ravenreader.app/'
$content = (New-Object System.Net.WebClient).DownloadString($website)
$pattern = 'Download.*v([\d.]+)'
$version = [Regex]::Matches($content, $pattern).Groups[1].Value
$address = "https://download.helloefficiency.com/ravenreader/Raven Reader Setup $version.exe"
$program = [System.IO.Path]::Combine($env:TEMP, [System.IO.Path]::GetFileName($address))
(New-Object System.Net.WebClient).DownloadFile($address, $program)
Start-Process -FilePath `"$program`" -ArgumentList '/S' -NoNewWindow -Wait

# Remove the shortcut from the desktop directory.
$shortcut = [System.IO.Path]::Combine([Environment]::GetFolderPath('Desktop'), 'Raven*.lnk')
if (Test-Path -Path $shortcut) { Remove-Item -Path $shortcut }