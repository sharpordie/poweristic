#Requires -RunAsAdministrator

# Download and install MPC-BE silently.
$website = 'https://www.videohelp.com/software/MPC-BE'
$content = (New-Object System.Net.WebClient).DownloadString($website)
$pattern = "class=`"toollink`" href=`"(.*)`">Download MPC-BE [\d.]+ Nightly 64-bit"
$website = [Regex]::Matches($content, $pattern).Groups[1].Value
$content = (New-Object System.Net.WebClient).DownloadString($website)
$pattern = "$website(.*)`">Download"
$suffixe = [Regex]::Matches($content, $pattern).Groups[1].Value
$address = $website + $suffixe
$archive = [System.IO.Path]::Combine($env:TEMP, [System.IO.Path]::GetFileName($website))
(New-Object System.Net.WebClient).DownloadFile($address, $archive)
$extractDir = [System.IO.Directory]::CreateDirectory([System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), [System.Guid]::NewGuid().ToString())).FullName
Expand-Archive -Path $archive -DestinationPath $extractDir
$program = (Get-ChildItem -Path $extractDir | Select-Object -First 1).FullName
Start-Process -FilePath `"$program`" -ArgumentList '/VERYSILENT /NORESTART /SUPPRESSMSGBOXES /SP- /COMPONENTS="main,mpciconlib,mpcberegvid,mpcberegpl"' -NoNewWindow -Wait
Start-Sleep -Seconds 5
Get-Process | Where-Object { $_.MainWindowTitle -eq "Settings" } | Stop-Process -Force

# Download the latest youtube-dl release.
$destination = "$env:PROGRAMFILES\MPC-BE x64"
(New-Object System.Net.WebClient).DownloadFile('https://youtube-dl.org/downloads/latest/youtube-dl.exe', "$destination\youtube-dl.exe")

# Create default registry keys by starting MPC-BE once.
Start-Process -FilePath "$env:PROGRAMFILES\MPC-BE x64\mpc-be64.exe" -WindowStyle Minimized
Start-Sleep -Seconds 10
Stop-Process -Name 'mpc-be64'
Start-Sleep -Seconds 2

# Edit the MPC-BE settings.
Set-ItemProperty -Path 'HKCU:\Software\MPC-BE\Settings' -Name 'YoutubePageParser' -Type DWord -Value 0
Set-ItemProperty -Path 'HKCU:\Software\MPC-BE\Settings' -Name 'YDLEnable' -Type DWord -Value 1
Set-ItemProperty -Path 'HKCU:\Software\MPC-BE\Settings' -Name 'YDLMaxHeight' -Type DWord -Value 438 # 1080P
# Set-ItemProperty -Path 'HKCU:\Software\MPC-BE\Settings' -Name 'YDLMaxHeight' -Type DWord -Value 870 # 2160P
Set-ItemProperty -Path 'HKCU:\Software\MPC-BE\Settings' -Name 'YDLMaximumQuality' -Type DWord -Value 1
Set-ItemProperty -Path 'HKCU:\Software\MPC-BE\Settings\Video' -Name 'SubpicMaxTexWidth' -Type DWord -Value 0
Set-ItemProperty -Path 'HKCU:\Software\MPC-BE\Settings\Video' -Name 'VideoRenderer' -Type DWord -Value 3 # EVRCP
# Set-ItemProperty -Path 'HKCU:\Software\MPC-BE\Settings\Video' -Name 'VideoRenderer' -Type DWord -Value 5 # MPCVR
# Set-ItemProperty -Path 'HKCU:\Software\MPC-BE\Settings\Video' -Name 'VideoRenderer' -Type DWord -Value 7 # MADVR

# Remove the shortcut from the desktop directory.
$shortcut = [System.IO.Path]::Combine([Environment]::GetFolderPath("Desktop"), "MPC*.lnk")
if (Test-Path -Path $shortcut) { Remove-Item -Path $shortcut }