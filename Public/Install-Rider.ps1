#Requires -RunAsAdministrator

# Download and install Rider silently.
$website = 'https://data.services.jetbrains.com/products/releases?code=RD&latest=true&type=release'
$address = ((New-Object System.Net.WebClient).DownloadString($website) | ConvertFrom-Json).RD[0].downloads.windows.link
$program = [System.IO.Path]::Combine($env:TEMP, [System.IO.Path]::GetFileName($address))
(New-Object System.Net.WebClient).DownloadFile($address, $program)
Start-Process -FilePath `"$program`" -ArgumentList '/S' -NoNewWindow -Wait