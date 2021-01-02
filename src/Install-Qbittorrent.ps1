#Requires -RunAsAdministrator

# Download and install qBittorrent silently.
$website = 'https://www.qbittorrent.org/download.php'
$content = (New-Object System.Net.WebClient).DownloadString($website)
$pattern = 'Latest:\s+v([\d.]+)'
$version = [Regex]::Matches($content, $pattern).Groups[1].Value
$address = "https://downloads.sourceforge.net/project/qbittorrent/qbittorrent-win32/qbittorrent-$version/qbittorrent_$($version)_x64_setup.exe"
$program = [System.IO.Path]::Combine($env:TEMP, [System.IO.Path]::GetFileName($address))
(New-Object System.Net.WebClient).DownloadFile($address, $program)
Start-Process -FilePath `"$program`" -ArgumentList '/S' -NoNewWindow -Wait