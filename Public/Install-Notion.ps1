# Download and install Notion silently.
$website = 'https://desktop-release.notion-static.com/latest.yml'
$content = (New-Object System.Net.WebClient).DownloadString($website)
$pattern = 'version:\s+([\d.]+)'
$version = [Regex]::Matches($content, $pattern).Groups[1].Value
$address = "https://desktop-release.notion-static.com/Notion Setup $version.exe"
$program = [System.IO.Path]::Combine($env:TEMP, [System.IO.Path]::GetFileName($address))
(New-Object System.Net.WebClient).DownloadFile($address, $program)
Start-Process -FilePath `"$program`" -ArgumentList '/S' -NoNewWindow -Wait

# Remove the shortcut from the desktop directory.
$shortcut = [System.IO.Path]::Combine([Environment]::GetFolderPath('Desktop'), 'Notion*.lnk')
if (Test-Path -Path $shortcut) { Remove-Item -Path $shortcut }