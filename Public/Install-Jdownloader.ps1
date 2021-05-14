#Requires -RunAsAdministrator

# Download and install JDownloader silently.
$address = 'http://installer.jdownloader.org/ic/JD2SilentSetup_x64.exe'
$program = [System.IO.Path]::Combine($env:TEMP, [System.IO.Path]::GetFileName($address))
(New-Object System.Net.WebClient).DownloadFile($address, $program)
Start-Process -FilePath `"$program`" -ArgumentList '-q' -NoNewWindow -Wait

# Edit the general settings (twice to make it working).
Start-Process -FilePath "$env:ProgramFiles\JDownloader\JDownloader2.exe" -NoNewWindow
Start-Sleep -Seconds 25
Stop-Process -Name 'JDownloader2'
Start-Sleep -Seconds 2
New-Item -ItemType Directory -Path "$env:USERPROFILE\Downloads\JD2" -Force
$settings = "$env:ProgramFiles\JDownloader\cfg\org.jdownloader.settings.GeneralSettings.json"
$settingsJson = Get-Content $settings | ConvertFrom-Json
try { $settingsJson.defaultdownloadfolder = "$env:USERPROFILE\Downloads\JD2" } catch { $settingsJson | Add-Member -Type NoteProperty -Name 'defaultdownloadfolder' -Value "$env:USERPROFILE\Downloads\JD2" }
$settingsJson | ConvertTo-Json | Set-Content $settings
Start-Process -FilePath "$env:ProgramFiles\JDownloader\JDownloader2.exe" -NoNewWindow
Start-Sleep -Seconds 5
Stop-Process -Name 'JDownloader2'
Start-Sleep -Seconds 2
$settingsJson = Get-Content $settings | ConvertFrom-Json
try { $settingsJson.defaultdownloadfolder = "$env:USERPROFILE\Downloads\JD2" } catch { $settingsJson | Add-Member -Type NoteProperty -Name 'defaultdownloadfolder' -Value "$env:USERPROFILE\Downloads\JD2" }
$settingsJson | ConvertTo-Json | Set-Content $settings

# Edit the graphical settings (twice to make it working).
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
Start-Process -FilePath "$env:ProgramFiles\JDownloader\JDownloader2.exe" -NoNewWindow
Start-Sleep -Seconds 5
Stop-Process -Name 'JDownloader2'
Start-Sleep -Seconds 2
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

# Remove the shortcut from the desktop directory.
$shortcut = [System.IO.Path]::Combine([Environment]::GetFolderPath('Desktop'), 'JDownloader*.lnk')
if (Test-Path -Path $shortcut) { Remove-Item -Path $shortcut }

# TODO: Make high DPI scaling performed by Application, fix the blurry text.
$shortcut = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\JDownloader\JDownloader 2.lnk"