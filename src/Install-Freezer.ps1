#Requires -RunAsAdministrator

# Download and install Freezer silently.
$website = 'https://freezer.life/'
$content = (New-Object System.Net.WebClient).DownloadString($website)
$pattern = 'Freezer PC ([\d.]+):'
$version = [Regex]::Matches($content, $pattern).Groups[1].Value
$address = "https://files.freezer.life/0:/PC/$version/Freezer Setup $version.exe"
$program = [System.IO.Path]::Combine($env:TEMP, [System.IO.Path]::GetFileName($address))
(New-Object System.Net.WebClient).DownloadFile($address, $program)
Start-Process -FilePath `"$program`" -ArgumentList '/S' -NoNewWindow -Wait