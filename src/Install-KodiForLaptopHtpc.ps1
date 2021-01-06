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

function Set-KodiSettings {
    # Reset the default guisettings.xml file.
    $settings = "$env:APPDATA\Kodi\userdata\guisettings.xml"
    Remove-Item -Path $settings -ErrorAction SilentlyContinue
    Start-Process -FilePath "$env:ProgramFiles\Kodi\kodi.exe" -WindowStyle Minimized
    Start-Sleep -Seconds 10
    Stop-Process -Name 'Kodi'
    Start-Sleep -Seconds 5

    # Edit the guisettings.xml file.
    [xml] $document = Get-Content -Path $settings
    $document.SelectSingleNode('//*[@id="addons.unknownsources"]').default = 'false'
    $document.SelectSingleNode('//*[@id="addons.unknownsources"]').InnerText = 'true'
    $document.SelectSingleNode('//*[@id="locale.country"]').default = 'false'
    $document.SelectSingleNode('//*[@id="locale.country"]').InnerText = 'Belgique'
    $document.SelectSingleNode('//*[@id="locale.language"]').default = 'false'
    $document.SelectSingleNode('//*[@id="locale.language"]').InnerText = 'resource.language.fr_fr'
    $document.SelectSingleNode('//*[@id="videoplayer.adjustrefreshrate"]').default = 'false'
    $document.SelectSingleNode('//*[@id="videoplayer.adjustrefreshrate"]').InnerText = '2'
    $document.SelectSingleNode('//*[@id="videoplayer.usedisplayasclock"]').default = 'false'
    $document.SelectSingleNode('//*[@id="videoplayer.usedisplayasclock"]').InnerText = 'true'
    $document.SelectSingleNode('//*[@id="services.webserver"]').default = 'false'
    $document.SelectSingleNode('//*[@id="services.webserver"]').InnerText = 'true'
    $document.SelectSingleNode('//*[@id="services.webserverpassword"]').default = 'false'
    $document.SelectSingleNode('//*[@id="services.webserverpassword"]').InnerText = '1234'
    $document.SelectSingleNode('/settings/defaultvideosettings/centermixlevel').InnerText = '5'
    $document.SelectSingleNode('/settings/defaultvideosettings/scalingmethod').InnerText = '9' # Lanczos3
    $document.SelectSingleNode('/settings/defaultvideosettings/tonemapmethod').InnerText = '3' # Hable
    $document.Save($settings)
}

function Set-KodiSources {
    # Make sure to create the media directories.
    $rootMediaDirectory = 'C:\MyMedia\'
    $albumsMediaDirectory = 'C:\MyMedia\Albums\'
    $moviesMediaDirectory = 'C:\MyMedia\Movies\'
    $picturesMediaDirectory = 'C:\MyMedia\Pictures\'
    $seriesMediaDirectory = 'C:\MyMedia\Series\'
    New-Item -ItemType Directory -Force -Path $rootMediaDirectory
    New-Item -ItemType Directory -Force -Path $albumsMediaDirectory
    New-Item -ItemType Directory -Force -Path $moviesMediaDirectory
    New-Item -ItemType Directory -Force -Path $picturesMediaDirectory
    New-Item -ItemType Directory -Force -Path $seriesMediaDirectory

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

function Set-DoNothingAsCloseLidAction {
    powercfg -setdcvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0
    powercfg -setacvalueindex SCHEME_CURRENT 4f971e89-eebd-4455-a8de-9e59040e7347 5ca83367-6e45-459f-a27b-476b1d01c936 0
    powercfg -s SCHEME_CURRENT
}

function Set-UltimatePowerPlan {
    $uuid = (powercfg -l | ForEach-Object { if ($_.contains('Ultimate Performance')) { $_.split()[3] } })
    if ([string]::IsNullOrEmpty($uuid)) { Start-Process -FilePath 'powercfg.exe' -ArgumentList '-duplicatescheme e9a42b02-d5df-448d-aa00-03f14749eb61' -NoNewWindow -Wait }
    $uuid = (powercfg -l | ForEach-Object { if ($_.contains('Ultimate Performance')) { $_.split()[3] } })
    Start-Process -FilePath 'powercfg.exe' -ArgumentList "-s $uuid" -NoNewWindow -Wait
}

#Requires -RunAsAdministrator

# Rename-Computer -NewName 'HTPC'
Set-UltimatePowerPlan
Set-DoNothingAsCloseLidAction
Install-Kodi
Add-KodiToWindowsStartup
Set-KodiSettings
# Set-KodiSources