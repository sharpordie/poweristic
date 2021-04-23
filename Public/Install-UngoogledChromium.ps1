#Requires -RunAsAdministrator

# Download and install Ungoogled Chromium silently.
$website = 'https://ungoogled-software.github.io/ungoogled-chromium-binaries/releases/windows/64bit/'
$content = (New-Object System.Net.WebClient).DownloadString($website)
$pattern = '\d\">\s*([\d.-]+)<'
$version = [Regex]::Matches($content, $pattern).Groups[1].Value
$address = "https://github.com/tangalbert919/ungoogled-chromium-binaries/releases/download/$version/ungoogled-chromium_$version.1_installer-x64.exe"
$program = [System.IO.Path]::Combine($env:TEMP, [System.IO.Path]::GetFileName($address))
# (New-Object System.Net.WebClient).DownloadFile($address, $program)
if (Test-Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Chromium") {
    Start-Process -FilePath `"$program`" -ArgumentList '--do-not-launch-chrome' -NoNewWindow -Wait
}
else {
    Start-Process -FilePath `"$program`" -ArgumentList '--system-level --do-not-launch-chrome' -NoNewWindow -Wait
}

# Remove the shortcut from the public desktop directory.
$shortcut = [System.IO.Path]::Combine([Environment]::GetFolderPath("CommonDesktopDirectory"), "*Chromium*.lnk")
if (Test-Path -Path $shortcut) { Remove-Item -Path $shortcut }

# Start Ungoogled Chromium once.
Start-Process -FilePath "$env:PROGRAMFILES\Chromium\Application\chrome.exe" -WindowStyle Minimized
Start-Sleep -Seconds 3
Stop-Process -Name 'chrome'
Start-Sleep -Seconds 3

# Remove the shortcut from the desktop directory.
$shortcut = [System.IO.Path]::Combine([Environment]::GetFolderPath("Desktop"), "*Chromium*.lnk")
if (Test-Path -Path $shortcut) { Remove-Item -Path $shortcut }