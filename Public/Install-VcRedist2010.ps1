#Requires -RunAsAdministrator

# Download and install Visual C++ 2010 Redistributable Package (x86) silently.
$address = 'https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x86.exe'
$program = [System.IO.Path]::Combine($env:TEMP, [System.IO.Path]::GetFileName($address))
(New-Object System.Net.WebClient).DownloadFile($address, $program)
Start-Process -FilePath $program -ArgumentList '/fo /quiet /norestart' -NoNewWindow -Wait

# Download and install Visual C++ 2010 Redistributable Package (x64) silently.
$address = 'https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x64.exe'
$program = [System.IO.Path]::Combine($env:TEMP, [System.IO.Path]::GetFileName($address))
(New-Object System.Net.WebClient).DownloadFile($address, $program)
Start-Process -FilePath $program -ArgumentList '/fo /quiet /norestart' -NoNewWindow -Wait