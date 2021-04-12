#Requires -RunAsAdministrator

# Download and install Visual C++ 2010 Redistributable Package (x86) silently.
$address = 'http://download.microsoft.com/download/C/6/D/C6D0FD4E-9E53-4897-9B91-836EBA2AACD3/vcredist_x86.exe'
$program = [System.IO.Path]::Combine($env:TEMP, [System.IO.Path]::GetFileName($address))
(New-Object System.Net.WebClient).DownloadFile($address, $program)
Start-Process -FilePath $program -ArgumentList '/fo /quiet /norestart' -NoNewWindow -Wait

# Download and install Visual C++ 2010 Redistributable Package (x64) silently.
$address = 'http://download.microsoft.com/download/A/8/0/A80747C3-41BD-45DF-B505-E9710D2744E0/vcredist_x64.exe'
$program = [System.IO.Path]::Combine($env:TEMP, [System.IO.Path]::GetFileName($address))
(New-Object System.Net.WebClient).DownloadFile($address, $program)
Start-Process -FilePath $program -ArgumentList '/fo /quiet /norestart' -NoNewWindow -Wait