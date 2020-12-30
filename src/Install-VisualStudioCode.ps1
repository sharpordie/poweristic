#Requires -RunAsAdministrator

# Download and install Visual Studio Code silently.
$address = 'https://aka.ms/win32-x64-user-stable'
$program = [System.IO.Path]::Combine($env:TEMP, 'VSCodeUserSetup-x64-Latest.exe')
(New-Object System.Net.WebClient).DownloadFile($address, $program)
Start-Process -FilePath `"$program`" -ArgumentList '/VERYSILENT /MERGETASKS="!runcode,addtopath"' -NoNewWindow -Wait

# Edit the settings.
$settings = [System.IO.Path]::Combine($env:APPDATA, 'Code\User\settings.json')
New-Item -Path $settings -ItemType 'file' -Force
$settingsJson = New-Object PSObject
$settingsJson | Add-Member -Type NoteProperty -Name 'editor.fontSize' -Value 14 -Force
$settingsJson | Add-Member -Type NoteProperty -Name 'editor.lineHeight' -Value 28 -Force
$settingsJson | Add-Member -Type NoteProperty -Name 'telemetry.enableCrashReporter' -Value $false -Force
$settingsJson | Add-Member -Type NoteProperty -Name 'telemetry.enableTelemetry' -Value $false -Force
$settingsJson | ConvertTo-Json | Set-Content $settings