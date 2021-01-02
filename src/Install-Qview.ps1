#Requires -RunAsAdministrator

# Download and install qView silently.
# TODO: Set qView as default image viewer.
$website = 'https://api.github.com/repos/jurplel/qView/releases/latest'
$version = (Invoke-WebRequest -Uri $website -UseBasicParsing | ConvertFrom-Json)[0].tag_name
$address = "https://github.com/jurplel/qView/releases/download/$version/qView-$version-win64.exe"
$program = [System.IO.Path]::Combine($env:TEMP, [System.IO.Path]::GetFileName($address))
(New-Object System.Net.WebClient).DownloadFile($address, $program)
Start-Process -FilePath `"$program`" -ArgumentList '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART /TASKS="startentry,fileassociation"' -NoNewWindow -Wait