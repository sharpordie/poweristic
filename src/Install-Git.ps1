#Requires -RunAsAdministrator

# Download and install Git silently.
$website = 'https://git-scm.com/download/win'
$content = (New-Object System.Net.WebClient).DownloadString($website)
$pattern = '<strong>([\d.]+)</strong>'
$version = [Regex]::Matches($content, $pattern).Groups[1].Value
$address = "https://github.com/git-for-windows/git/releases/download/v$version.windows.1/Git-$version-64-bit.exe"
$program = [System.IO.Path]::Combine($env:TEMP, [System.IO.Path]::GetFileName($address))
(New-Object System.Net.WebClient).DownloadFile($address, $program)
Start-Process -FilePath `"$program`" -ArgumentList '/VERYSILENT /SUPPRESSMSGBOXES /NORESTART, /NOCANCEL, /SP- /COMPONENTS=""' -NoNewWindow -Wait

# Edit the settings.
$env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path', 'User')
git config --global credential.helper 'manager-core'
git config --global init.defaultBranch 'main'