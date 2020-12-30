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

# Download the latest release.
$website = 'https://sourceforge.net/projects/mpv-player-windows/files/64bit/'
$content = (New-Object System.Net.WebClient).DownloadString($website)
$pattern = 'mpv-x86_64-([\d]{8})-git-([\a-z]{7})\.7z'
$returns = [Regex]::Matches($content, $pattern)
$address = [string]::Format('https://sourceforge.net/projects/mpv-player-windows/files/64bit/mpv-x86_64-{0}-git-{1}.7z', $returns.Groups[1].Value, $returns.Groups[2].Value)
$archive = [System.IO.Path]::Combine($env:TEMP, [System.IO.Path]::GetFileName($address))
(New-Object System.Net.WebClient).DownloadFile($address, $archive)

# Extract the archive.
$destination = [System.IO.Path]::Combine($env:LOCALAPPDATA, 'Programs', 'Mpv')
New-Item -ItemType Directory -Path $destination -Force | Out-Null
Expand-All $archive $destination

# Download and install the latest "youtube-dl" release.
(New-Object System.Net.WebClient).DownloadFile('https://youtube-dl.org/downloads/latest/youtube-dl.exe', "$destination\youtube-dl.exe")

# Edit the mpv.conf file.
New-Item -Path "$destination\mpv\mpv.conf" -Force | Out-Null
Add-Content -Path "$destination\mpv\mpv.conf" -Value 'profile=gpu-hq'
Add-Content -Path "$destination\mpv\mpv.conf" -Value 'hwdec=auto'
Add-Content -Path "$destination\mpv\mpv.conf" -Value 'interpolation=yes'
Add-Content -Path "$destination\mpv\mpv.conf" -Value 'keep-open=yes'
Add-Content -Path "$destination\mpv\mpv.conf" -Value 'tscale=oversample'
Add-Content -Path "$destination\mpv\mpv.conf" -Value 'video-sync=display-resample'
Add-Content -Path "$destination\mpv\mpv.conf" -Value 'ytdl-format="bestvideo[height<=?2160]+bestaudio/best"'

# Add a new shortcut to the Start Menu directory.
$shortcut = [System.IO.Path]::Combine($env:APPDATA, 'Microsoft\Windows\Start Menu\Programs\Mpv.lnk')
New-Shortcut -ShortcutFile $shortcut -TargetPath "$destination\mpv.exe"