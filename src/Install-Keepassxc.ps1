#Requires -RunAsAdministrator

# Download and install KeePassXC silently.
$website = 'https://api.github.com/repos/keepassxreboot/keepassxc/releases/latest'
$version = (Invoke-WebRequest -Uri $website -UseBasicParsing | ConvertFrom-Json)[0].tag_name
$address = "https://github.com/keepassxreboot/keepassxc/releases/download/$version/KeePassXC-$version-Win64.msi"
$program = [System.IO.Path]::Combine($env:TEMP, [System.IO.Path]::GetFileName($address))
(New-Object System.Net.WebClient).DownloadFile($address, $program)
Start-Process -FilePath 'msiexec.exe' -ArgumentList "/i `"$program`" /qn" -NoNewWindow -Wait

# Remove it from startup programs.
Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'KeePassXC'