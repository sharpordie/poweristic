function Add-KodiToWindowsStartup {
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Run' -Name 'Kodi' -Value "$env:ProgramFiles\Kodi\kodi.exe"
}

function Install-Kodi {
    $website = 'https://mirrors.kodi.tv/releases/windows/win64/?C=M&O=D'
    $content = (New-Object System.Net.WebClient).DownloadString($website)
    $pattern = 'kodi-([\w.-]+)-x64'
    $version = [Regex]::Matches($content, $pattern).Groups[1].Value
    $address = "https://mirrors.kodi.tv/releases/windows/win64/kodi-$version-x64.exe"
    $program = [System.IO.Path]::Combine($env:TEMP, [System.IO.Path]::GetFileName($address))
    (New-Object System.Net.WebClient).DownloadFile($address, $program)
    Start-Process -FilePath `"$program`" -ArgumentList '/S' -NoNewWindow -Wait
}

function Reset-KodiSettings {
    $settings = "$env:APPDATA\Kodi\userdata\guisettings.xml"
    Remove-Item -Path $settings -ErrorAction SilentlyContinue
    Start-Process -FilePath "$env:ProgramFiles\Kodi\kodi.exe" -WindowStyle Minimized
    Start-Sleep -Seconds 10
    Stop-Process -Name 'Kodi'
    Start-Sleep -Seconds 5
}

function Set-KodiCountry {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $Country
    )
    $settings = "$env:APPDATA\Kodi\userdata\guisettings.xml"
    [xml] $document = Get-Content -Path $settings
    try { $document.SelectSingleNode('//*[@id="locale.country"]').default = 'false' } catch {}
    $document.SelectSingleNode('//*[@id="locale.country"]').InnerText = "$Country"
    $document.Save($settings)
}

function Set-KodiDefaultSettings {
    Reset-KodiSettings
    $settings = "$env:APPDATA\Kodi\userdata\guisettings.xml"
    [xml] $document = Get-Content -Path $settings
    try { $document.SelectSingleNode('//*[@id="addons.unknownsources"]').default = 'false' } catch {}
    $document.SelectSingleNode('//*[@id="addons.unknownsources"]').InnerText = 'true'
    try { $document.SelectSingleNode('//*[@id="videoplayer.adjustrefreshrate"]').default = 'false' } catch {}
    $document.SelectSingleNode('//*[@id="videoplayer.adjustrefreshrate"]').InnerText = '2'
    try { $document.SelectSingleNode('//*[@id="videoplayer.usedisplayasclock"]').default = 'false' } catch {}
    $document.SelectSingleNode('//*[@id="videoplayer.usedisplayasclock"]').InnerText = 'true'
    $document.SelectSingleNode('/settings/defaultvideosettings/centermixlevel').InnerText = '5'
    $document.SelectSingleNode('/settings/defaultvideosettings/scalingmethod').InnerText = '9' # Lanczos3
    $document.SelectSingleNode('/settings/defaultvideosettings/tonemapmethod').InnerText = '3' # Hable
    $document.Save($settings)
}

function Set-KodiLanguage {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $Language
    )
    # Get the latest release name.
    $website = 'http://mirrors.kodi.tv/addons/?C=M&O=D'
    $content = (New-Object System.Net.WebClient).DownloadString($website)
    $pattern = 'title="([\w]+)"'
    $release = [Regex]::Matches($content, $pattern).Groups[1].Value

    # Get the latest available language version.
    $website = "http://mirrors.kodi.tv/addons/$release/resource.language.$Language/?C=M&O=D"
    $content = (New-Object System.Net.WebClient).DownloadString($website)
    $pattern = "href=`"resource.language.$Language-([\d.]+).zip`""
    $version = [Regex]::Matches($content, $pattern).Groups[1].Value
    $address = "http://mirrors.kodi.tv/addons/$release/resource.language.$Language/resource.language.$Language-$version.zip"
    $archive = [System.IO.Path]::Combine($env:TEMP, [System.IO.Path]::GetFileName($address))
    (New-Object System.Net.WebClient).DownloadFile($address, $archive)

    # Extract to the addons directory
    Expand-Archive -Path $archive -DestinationPath "$env:APPDATA\Kodi\addons" -Force

    # Edit the guisettings.xml file.
    $settings = "$env:APPDATA\Kodi\userdata\guisettings.xml"
    [xml] $document = Get-Content -Path $settings
    try { $document.SelectSingleNode('//*[@id="locale.language"]').default = 'false' } catch {}
    $document.SelectSingleNode('//*[@id="locale.language"]').InnerText = "resource.language.$Language"
    $document.Save($settings)
}

function Set-KodiWebServerNoPassword {
    $settings = "$env:APPDATA\Kodi\userdata\guisettings.xml"
    [xml] $document = Get-Content -Path $settings
    try { $document.SelectSingleNode('//*[@id="services.webserver"]').default = 'false' } catch {}
    $document.SelectSingleNode('//*[@id="services.webserver"]').InnerText = 'true'
    try { $document.SelectSingleNode('//*[@id="services.webserverauthentication"]').default = 'false' } catch {}
    $document.SelectSingleNode('//*[@id="services.webserverauthentication"]').InnerText = 'false'
    $document.Save($settings)
}
function Set-KodiSources {
    # Make sure to create the media directories.
    $rootMediaDirectory = 'C:\MyMedia\'
    $albumsMediaDirectory = 'C:\MyMedia\Albums\'
    $moviesMediaDirectory = 'C:\MyMedia\Movies\'
    $picturesMediaDirectory = 'C:\MyMedia\Pictures\'
    $seriesMediaDirectory = 'C:\MyMedia\Series\'
    New-Item -ItemType Directory -Path $rootMediaDirectory -Force
    New-Item -ItemType Directory -Path $albumsMediaDirectory -Force
    New-Item -ItemType Directory -Path $moviesMediaDirectory -Force
    New-Item -ItemType Directory -Path $picturesMediaDirectory -Force
    New-Item -ItemType Directory -Path $seriesMediaDirectory -Force

    # Make sure to reset the xml file.
    $settings = "$env:APPDATA\Kodi\userdata\sources.xml"
    New-Item -Path $settings -ItemType File -Force | Out-Null
    Set-Content -Path $settings '<sources></sources>'

    # Add the master elements
    [xml] $document = Get-Content -Path $settings
    $sourcesNode = $document.DocumentElement
    $videoNode = $document.CreateElement('video')
    $musicNode = $document.CreateElement('music')
    $picturesNode = $document.CreateElement('pictures')
    $sourcesNode.AppendChild($videoNode)
    $sourcesNode.AppendChild($musicNode)
    $sourcesNode.AppendChild($picturesNode)

    # Add the Movies source.
    $newSource = $document.CreateElement('source')
    $newName = $document.CreateElement('name')
    $newName.InnerText = 'Movies'
    $newPath = $document.CreateElement('path')
    $newPathVersion = $document.CreateAttribute('pathversion');
    $newPathVersion.Value = '1'
    $newPath.Attributes.Append($newPathVersion)
    $newPath.InnerText = $moviesMediaDirectory
    $newSharing = $document.CreateElement('allowsharing')
    $newSharing.InnerText = 'true'
    $newSource.AppendChild($newName)
    $newSource.AppendChild($newPath)
    $newSource.AppendChild($newSharing)
    $videoNode.AppendChild($newSource)

    # Add the Series source.
    $newSource = $document.CreateElement('source')
    $newName = $document.CreateElement('name')
    $newName.InnerText = 'Series'
    $newPath = $document.CreateElement('path')
    $newPathVersion = $document.CreateAttribute('pathversion');
    $newPathVersion.Value = '1'
    $newPath.Attributes.Append($newPathVersion)
    $newPath.InnerText = $seriesMediaDirectory
    $newSharing = $document.CreateElement('allowsharing')
    $newSharing.InnerText = 'true'
    $newSource.AppendChild($newName)
    $newSource.AppendChild($newPath)
    $newSource.AppendChild($newSharing)
    $videoNode.AppendChild($newSource)

    # Add the Album source.
    $newSource = $document.CreateElement('source')
    $newName = $document.CreateElement('name')
    $newName.InnerText = 'Albums'
    $newPath = $document.CreateElement('path')
    $newPathVersion = $document.CreateAttribute('pathversion');
    $newPathVersion.Value = '1'
    $newPath.Attributes.Append($newPathVersion)
    $newPath.InnerText = $albumsMediaDirectory
    $newSharing = $document.CreateElement('allowsharing')
    $newSharing.InnerText = 'true'
    $newSource.AppendChild($newName)
    $newSource.AppendChild($newPath)
    $newSource.AppendChild($newSharing)
    $musicNode.AppendChild($newSource)

    # Add the Picture source.
    $newSource = $document.CreateElement('source')
    $newName = $document.CreateElement('name')
    $newName.InnerText = 'Pictures'
    $newPath = $document.CreateElement('path')
    $newPathVersion = $document.CreateAttribute('pathversion');
    $newPathVersion.Value = '1'
    $newPath.Attributes.Append($newPathVersion)
    $newPath.InnerText = $picturesMediaDirectory
    $newSharing = $document.CreateElement('allowsharing')
    $newSharing.InnerText = 'true'
    $newSource.AppendChild($newName)
    $newSource.AppendChild($newPath)
    $newSource.AppendChild($newSharing)
    $picturesNode.AppendChild($newSource)

    $document.Save($settings)
}

function Set-SystemDoNothingAsCloseLidAction {
    powercfg -setdcvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0
    powercfg -setacvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0
    powercfg -s SCHEME_CURRENT
}

function Set-SystemUltimatePowerPlan {
    $uuid = (powercfg -l | ForEach-Object { if ($_.contains('Ultimate Performance')) { $_.split()[3] } })
    if ([string]::IsNullOrEmpty($uuid)) { Start-Process -FilePath 'powercfg.exe' -ArgumentList '-duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61' -NoNewWindow -Wait }
    $uuid = (powercfg -l | ForEach-Object { if ($_.contains('Ultimate Performance')) { $_.split()[3] } })
    Start-Process -FilePath 'powercfg.exe' -ArgumentList "-s $uuid" -NoNewWindow -Wait
}

#Requires -RunAsAdministrator

# Rename-Computer -NewName 'HTPC'
Install-Kodi
Add-KodiToWindowsStartup
Set-KodiDefaultSettings
Set-KodiCountry -Country 'Belgique'
Set-KodiLanguage -Language 'fr_fr'
# Set-KodiSources
Set-KodiWebServerNoPassword
Set-SystemUltimatePowerPlan
Set-SystemDoNothingAsCloseLidAction
# Restart-Computer