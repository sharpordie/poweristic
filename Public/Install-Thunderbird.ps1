#Requires -RunAsAdministrator

# Download and install Thunderbird silently.
$website = 'https://www.thunderbird.net/thunderbird/all/'
$content = (New-Object System.Net.WebClient).DownloadString($website)
$pattern = 'thunderbird/([\d.]+)/'
$version = [Regex]::Matches($content, $pattern).Groups[1].Value
$address = "https://archive.mozilla.org/pub/thunderbird/releases/$version/win64/en-US/Thunderbird Setup $version.msi"
$program = [System.IO.Path]::Combine($env:TEMP, [System.IO.Path]::GetFileName($address))
(New-Object System.Net.WebClient).DownloadFile($address, $program)
Start-Process -FilePath 'msiexec.exe' -ArgumentList "/i `"$program`" /qn DESKTOP_SHORTCUT=false INSTALL_MAINTENANCE_SERVICE=false" -NoNewWindow -Wait