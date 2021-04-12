#Requires -RunAsAdministrator

# Download and install MPC-BE silently.
$website = "https://www.videohelp.com/software/MPC-BE"
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
$destination = "$env:ProgramFiles\MPC-BE x64"
(New-Object System.Net.WebClient).DownloadFile('https://youtube-dl.org/downloads/latest/youtube-dl.exe', "$destination\youtube-dl.exe")

# Edit the MPC-BE settings.
Set-ItemProperty -Path 'HKCU:\Software\MPC-BE\Settings' -Name 'YoutubePageParser' -Type DWord -Value 00000000
Set-ItemProperty -Path 'HKCU:\Software\MPC-BE\Settings' -Name 'YDLEnable' -Type DWord -Value 00000001
Set-ItemProperty -Path 'HKCU:\Software\MPC-BE\Settings' -Name 'YDLMaxHeight' -Type DWord -Value 00000438
Set-ItemProperty -Path 'HKCU:\Software\MPC-BE\Settings' -Name 'YDLMaximumQuality' -Type DWord -Value 00000001
Set-ItemProperty -Path 'HKCU:\Software\MPC-BE\Settings\Video' -Name 'SubpicMaxTexWidth' -Type DWord -Value 00000000
# Set-ItemProperty -Path 'HKCU:\Software\MPC-BE\Settings\Video' -Name 'VideoRenderer' -Type DWord -Value 00000005 # MPCVR
# Set-ItemProperty -Path 'HKCU:\Software\MPC-BE\Settings\Video' -Name 'VideoRenderer' -Type DWord -Value 00000007 # MADVR

# Remove the shortcut from the desktop directory.
$shortcut = [System.IO.Path]::Combine([Environment]::GetFolderPath("Desktop"), "MPC*.lnk")
if (Test-Path -Path $shortcut) { Remove-Item -Path $shortcut }