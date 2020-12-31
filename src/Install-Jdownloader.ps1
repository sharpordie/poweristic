#Requires -RunAsAdministrator

# Download and install JDownloader silently.
$address = if ([System.Environment]::Is64BitOperatingSystem) { 'http://installer.jdownloader.org/ic/JD2SilentSetup_x64.exe' } else { 'http://installer.jdownloader.org/ic/JD2SilentSetup_x86.exe' }
$program = [System.IO.Path]::Combine($env:TEMP, [System.IO.Path]::GetFileName($address))
(New-Object System.Net.WebClient).DownloadFile($address, $program)
Start-Process -FilePath `"$program`" -ArgumentList '-q' -NoNewWindow -Wait

# Remove the shortcut from the desktop directory.
$shortcut = [System.IO.Path]::Combine([Environment]::GetFolderPath('Desktop'), 'JDownloader*.lnk')
if (Test-Path -Path $shortcut) { Remove-Item -Path $shortcut }

# Create default settings.json file by starting JDownloader once.
Start-Process -FilePath "$env:ProgramFiles\JDownloader\JDownloader2.exe" -NoNewWindow
Start-Sleep -Seconds 25
Stop-Process -Name 'JDownloader2'
Start-Sleep -Seconds 3

# Edit the settings.
$settings = "$env:ProgramFiles\JDownloader\cfg\org.jdownloader.settings.GraphicalUserInterfaceSettings.json"
$settingsJson = Get-Content $settings | ConvertFrom-Json
try { $settingsJson.premiumalerttaskcolumnenabled = $false } catch { $settingsJson | Add-Member -Type NoteProperty -Name 'premiumalerttaskcolumnenabled' -Value $false }
try { $settingsJson.premiumalertspeedcolumnenabled = $false } catch { $settingsJson | Add-Member -Type NoteProperty -Name 'premiumalertspeedcolumnenabled' -Value $false }
try { $settingsJson.premiumalertetacolumnenabled = $false } catch { $settingsJson | Add-Member -Type NoteProperty -Name 'premiumalertetacolumnenabled' -Value $false }
try { $settingsJson.specialdealoboomdialogvisibleonstartup = $false } catch { $settingsJson | Add-Member -Type NoteProperty -Name 'specialdealoboomdialogvisibleonstartup' -Value $false }
try { $settingsJson.specialdealsenabled = $false } catch { $settingsJson | Add-Member -Type NoteProperty -Name 'specialdealsenabled' -Value $false }
try { $settingsJson.donatebuttonstate = 'AUTO_HIDDEN' } catch { $settingsJson | Add-Member -Type NoteProperty -Name 'donatebuttonstate' -Value 'AUTO_HIDDEN' }
try { $settingsJson.bannerenabled = $false } catch { $settingsJson | Add-Member -Type NoteProperty -Name 'bannerenabled' -Value $false }
try { $settingsJson.myjdownloaderviewvisible = $false } catch { $settingsJson | Add-Member -Type NoteProperty -Name 'myjdownloaderviewvisible' -Value $false }
try { $settingsJson.speedmetervisible = $false } catch { $settingsJson | Add-Member -Type NoteProperty -Name 'speedmetervisible' -Value $false }
$settingsJson | ConvertTo-Json | Set-Content $settings