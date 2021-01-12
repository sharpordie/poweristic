#Requires -RunAsAdministrator

# Download and install Freezer silently.
$website = 'https://freezer.life/'
$content = (New-Object System.Net.WebClient).DownloadString($website)
$pattern = 'Freezer PC ([\d.]+):'
$version = [Regex]::Matches($content, $pattern).Groups[1].Value
$address = "https://files.freezer.life/0:/PC/$version/Freezer Setup $version.exe"
$program = [System.IO.Path]::Combine($env:TEMP, [System.IO.Path]::GetFileName($address))
(New-Object System.Net.WebClient).DownloadFile($address, $program)
Start-Process -FilePath `"$program`" -ArgumentList '/S' -NoNewWindow -Wait

# Create default settings.json file by starting Freezer once.
Start-Process -FilePath "$env:LOCALAPPDATA\Programs\freezer\Freezer.exe" -WindowStyle Minimized
Start-Sleep -Seconds 10
Stop-Process -Name 'Freezer'
Start-Sleep -Seconds 2

# Edit the settings.
$settings = "$env:APPDATA\freezer\settings.json"
$settingsJson = Get-Content $settings | ConvertFrom-Json
try { $settingsJson.streamQuality = 9 } catch { $settingsJson | Add-Member -Type NoteProperty -Name 'streamQuality' -Value 9 }
try { $settingsJson.downloadsQuality = 9 } catch { $settingsJson | Add-Member -Type NoteProperty -Name 'downloadsQuality' -Value 9 }
try { $settingsJson.minimizeToTray = $false } catch { $settingsJson | Add-Member -Type NoteProperty -Name 'minimizeToTray' -Value $false }
try { $settingsJson.closeOnExit = $true } catch { $settingsJson | Add-Member -Type NoteProperty -Name 'closeOnExit' -Value $true }
try { $settingsJson.forceWhiteTrayIcon = $true } catch { $settingsJson | Add-Member -Type NoteProperty -Name 'forceWhiteTrayIcon' -Value $true }
$settingsJson | ConvertTo-Json | Set-Content $settings

# Remove the shortcut from the desktop directory.
$shortcut = [System.IO.Path]::Combine([Environment]::GetFolderPath('Desktop'), 'Freezer*.lnk')
if (Test-Path -Path $shortcut) { Remove-Item -Path $shortcut }