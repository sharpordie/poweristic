#Requires -RunAsAdministrator

# Download and install Corretto 15 silently.
$address = "https://corretto.aws/downloads/latest/amazon-corretto-15-x64-windows-jdk.msi"
$program = [System.IO.Path]::Combine($env:TEMP, [System.IO.Path]::GetFileName($address))
(New-Object System.Net.WebClient).DownloadFile($address, $program)
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$program`" INSTALLLEVEL=3 /quiet" -NoNewWindow -Wait