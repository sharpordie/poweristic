#Requires -RunAsAdministrator

# Download and install 7-Zip silently.
$website = 'https://www.7-zip.org/download.html'
$content = (New-Object System.Net.WebClient).DownloadString($website)
$pattern = 'Download 7-Zip ([\d.]+)'
$version = ([Regex]::Matches($content, $pattern).Groups[1].Value).Replace('.', '')
$address = "https://7-zip.org/a/7z$version-x64.msi"
$program = [System.IO.Path]::Combine($env:TEMP, [System.IO.Path]::GetFileName($address))
(New-Object System.Net.WebClient).DownloadFile($address, $program)
Start-Process -FilePath 'msiexec.exe' -ArgumentList "/i `"$program`" /qn" -NoNewWindow -Wait