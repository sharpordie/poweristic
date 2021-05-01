function New-Shortcut {
    param(
        [Parameter(Mandatory)]
        [string]
        $ShortcutFile,

        [Parameter(Mandatory)]
        [string]
        $TargetPath,

        [Parameter(Mandatory = $false)]
        [string]
        $Description,

        [Parameter(Mandatory = $false)]
        [string]
        $IconLocation,

        [Parameter(Mandatory = $false)]
        [string]
        $WorkingDirectory
    )

    $shell = New-Object -ComObject WScript.Shell
    $shortcut = $shell.CreateShortcut($ShortcutFile)
    $shortcut.TargetPath = $TargetPath
    $shortcut.Description = $Description
    $shortcut.IconLocation = if ($IconLocation) { $IconLocation } else { $TargetPath }
    $shortcut.WorkingDirectory = if ($WorkingDirectory) { $WorkingDirectory } else { Split-Path $TargetPath }
    $shortcut.Save()
}

function New-TempDirectory {
    [System.IO.Directory]::CreateDirectory([System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), [System.Guid]::NewGuid().ToString())).FullName
}

function Expand-All {
    param(
        [Parameter(Mandatory)]
        [string]
        $Archive,

        [Parameter(Mandatory = $false)]
        [string]
        $Destination,

        [Parameter(Mandatory = $false)]
        [SecureString]
        $Password
    )

    # Downlaod the latest 7-Zip release.
    $content = (New-Object System.Net.WebClient).DownloadString('https://www.7-zip.org/download.html')
    $pattern = 'Download 7-Zip ([\d.]+)'
    $version = ([Regex]::Matches($content, $pattern).Groups[1].Value).Replace('.', '')
    $address = "https://7-zip.org/a/7z$version-x64.msi"
    $package = [System.IO.Path]::Combine($env:TEMP, [System.IO.Path]::GetFileName($address))
    (New-Object System.Net.WebClient).DownloadFile($address, $package)

    # Extract the content of the .msi package.
    $extractionDir = New-TempDirectory
    Start-Process -FilePath 'msiexec.exe' -ArgumentList "/a $package /qn TARGETDIR=$extractionDir" -NoNewWindow -Wait

    # Create a new destination directory if null.
    if (!$Destination) { $Destination = New-TempDirectory }

    # Extract all content from the targeted archive.
    $program = [System.IO.Directory]::GetFiles($extractionDir, '7z.exe', [System.IO.SearchOption]::AllDirectories)[0];
    $argList = if ($Password) { "x `"$Archive`" -o`"$Destination`" -p`"$Password`" -y -bso0 -bsp0" } else { "x `"$Archive`" -o`"$Destination`" -y -bso0 -bsp0" }
    Start-Process -FilePath $program -ArgumentList $argList -NoNewWindow -Wait
}

function Install-YtdlProtocol {
    param(
        [Parameter(Mandatory)]
        [string]
        $MpvDirectory
    )

    (New-Object System.Net.WebClient).DownloadFile('https://raw.githubusercontent.com/eastmarch/ff2mpv/master/ytdlProtocol.bat', "$MpvDirectory\ytdlProtocol.bat")
    (New-Object System.Net.WebClient).DownloadFile('https://raw.githubusercontent.com/eastmarch/ff2mpv/master/ytdlRemove.bat', "$MpvDirectory\ytdlRemove.bat")
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = "$MpvDirectory\ytdlProtocol.bat"
    $psi.UseShellExecute = $false
    $psi.RedirectStandardInput = $true
    $p = [System.Diagnostics.Process]::Start($psi)
    Start-Sleep -Seconds 2
    $p.StandardInput.WriteLine("`n")
}

# Download the latest release.
$website = 'https://sourceforge.net/projects/mpv-player-windows/files/64bit/'
$content = (New-Object System.Net.WebClient).DownloadString($website)
$pattern = 'mpv-x86_64-([\d]{8})-git-([\a-z]{7})\.7z'
$results = [Regex]::Matches($content, $pattern)
$address = [string]::Format('https://sourceforge.net/projects/mpv-player-windows/files/64bit/mpv-x86_64-{0}-git-{1}.7z', $results.Groups[1].Value, $results.Groups[2].Value)
$archive = [System.IO.Path]::Combine($env:TEMP, [System.IO.Path]::GetFileName($address))
(New-Object System.Net.WebClient).DownloadFile($address, $archive)

# Extract the archive.
$destination = [System.IO.Path]::Combine($env:LOCALAPPDATA, 'Programs', 'Mpv')
New-Item -ItemType Directory -Path $destination -Force | Out-Null
Expand-All $archive $destination

# Download the latest youtube-dl.exe release.
(New-Object System.Net.WebClient).DownloadFile('https://youtube-dl.org/downloads/latest/youtube-dl.exe', "$destination\youtube-dl.exe")

# Make sure Visual C++ 2010 Redistributable Package (x86) is installed.
$address = 'https://download.microsoft.com/download/1/6/5/165255E7-1014-4D0A-B094-B6A430A6BFFC/vcredist_x86.exe'
$program = [System.IO.Path]::Combine($env:TEMP, [System.IO.Path]::GetFileName($address))
(New-Object System.Net.WebClient).DownloadFile($address, $program)
Start-Process -FilePath $program -ArgumentList '/fo /quiet /norestart' -NoNewWindow -Wait

# Edit the mpv.conf file.
New-Item -Path "$destination\mpv\mpv.conf" -Force | Out-Null
Add-Content -Path "$destination\mpv\mpv.conf" -Value 'profile=gpu-hq'
Add-Content -Path "$destination\mpv\mpv.conf" -Value 'hwdec=auto'
Add-Content -Path "$destination\mpv\mpv.conf" -Value 'keep-open=yes'
Add-Content -Path "$destination\mpv\mpv.conf" -Value 'tls-verify=no'
Add-Content -Path "$destination\mpv\mpv.conf" -Value 'ytdl-format="bestvideo[height<=?2160][vcodec!=vp9]+bestaudio/best"'
Add-Content -Path "$destination\mpv\mpv.conf" -Value '[protocol.http]'
Add-Content -Path "$destination\mpv\mpv.conf" -Value 'cscale=bilinear'
Add-Content -Path "$destination\mpv\mpv.conf" -Value 'dscale=bilinear'
Add-Content -Path "$destination\mpv\mpv.conf" -Value 'force-window=immediate'
Add-Content -Path "$destination\mpv\mpv.conf" -Value '[protocol.https]'
Add-Content -Path "$destination\mpv\mpv.conf" -Value 'profile=protocol.http'
Add-Content -Path "$destination\mpv\mpv.conf" -Value '[protocol.ytdl]'
Add-Content -Path "$destination\mpv\mpv.conf" -Value 'profile=protocol.http'

# Add a new shortcut to the Start Menu directory.
$shortcut = [System.IO.Path]::Combine($env:APPDATA, 'Microsoft\Windows\Start Menu\Programs\mpv.lnk')
New-Shortcut -ShortcutFile $shortcut -TargetPath "$destination\mpv.exe"

# Make it as default video application.
Start-Process -FilePath "$destination\installer\mpv-install.bat" -ArgumentList '/u'

# Setup the ytdl:// protocol for Firefox.
Install-YtdlProtocol -MpvDirectory $destination