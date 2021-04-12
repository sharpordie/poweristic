#Requires -RunAsAdministrator

# Download and install .NET SDK silently.
$website = "https://dotnetcli.blob.core.windows.net/dotnet/release-metadata/releases-index.json"
$content = (New-Object System.Net.WebClient).DownloadString($website)
$pattern = "(?s)(?<rtv>[\d.]+)[^\d]*?([\d.]+)[^\d]*?(?:lts)"
$version = [Regex]::Matches($content, $pattern).Groups[1].Value
$address = "https://dotnetcli.blob.core.windows.net/dotnet/Sdk/$version/dotnet-sdk-$version-win-x64.exe"
$program = [System.IO.Path]::Combine($env:TEMP, [System.IO.Path]::GetFileName($address))
(New-Object System.Net.WebClient).DownloadFile($address, $program)
Start-Process -FilePath `"$program`" -ArgumentList "/install /quiet /norestart" -NoNewWindow -Wait

# Disable the telemetry.
Start-Process -FilePath "setx.exe" -ArgumentList 'DOTNET_CLI_TELEMETRY_OPTOUT /M "1"' -NoNewWindow -Wait