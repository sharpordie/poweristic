function Hide-ActionCenterSystemIcon {
    if (!(Test-Path -Path 'HKCU:\Software\Policies\Microsoft\Windows\Explorer')) {
        New-Item -Path 'HKCU:\Software\Policies\Microsoft\Windows\Explorer' | Out-Null
    }
    Set-ItemProperty -Path 'HKCU:\Software\Policies\Microsoft\Windows\Explorer' -Name 'DisableNotificationCenter' -Type DWord -Value 0
}

function Hide-MeetNowSystemIcon {
    if (!(Test-Path -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer')) {
        New-Item -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer' | Out-Null
    }
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer' -Name 'HideSCAMeetNow' -Value 1
}

###

function Hide-CortanaTaskbarIcon {
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'ShowCortanaButton' -Value 0
}

function Hide-SearchTaskbarIcon {
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Search' -Name 'SearchboxTaskbarMode' -Type DWord -Value 0
}

function Hide-TaskViewTaskbarIcon {
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'ShowTaskViewButton' -Type DWord -Value 0
}

###

function Hide-DesktopIcons {
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'HideIcons' -Type DWord -Value 1
}

function Hide-TrayIcons {
    Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Policies\Explorer' -Name 'NoAutoTrayNotify' -ErrorAction SilentlyContinue
}

function Show-FileExtensions {
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'HideFileExt' -Type DWord -Value 0
}

function Show-SmallTaskbarIcons {
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Advanced' -Name 'TaskbarSmallIcons' -Type DWord -Value 1
}

###

function Disable-AutoPlay {
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers' -Name 'DisableAutoplay' -Type DWord -Value 1
}

function Disable-ClipboardHistory {
    Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Clipboard' -Name 'EnableClipboardHistory' -ErrorAction SilentlyContinue
}

function Disable-OneDrive {
    if (!(Test-Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive')) {
        New-Item -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive' | Out-Null
    }
    Set-ItemProperty -Path 'HKLM:\SOFTWARE\Policies\Microsoft\Windows\OneDrive' -Name 'DisableFileSyncNGSC' -Type DWord -Value 1
}

function Disable-WallpaperCompression {
    if (!(Test-Path 'HKCU:\Control Panel\Desktop')) {
        New-Item -Path 'HKCU:\Control Panel\Desktop' | Out-Null
    }
    Set-ItemProperty -Path 'HKCU:\Control Panel\Desktop' -Name 'JPEGImportQuality' -Type DWord -Value '100'
}

###

function Clear-StartMenuTiles {
    $key = Get-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\CloudStore\Store\Cache\DefaultAccount\*start.tilegrid`$windows.data.curatedtilecollection.tilecollection\Current"
    $data = $key.Data[0..25] + ([byte[]](202, 50, 0, 226, 44, 1, 1, 0, 0))
    Set-ItemProperty -Path $key.PSPath -Name 'Data' -Type Binary -Value $data
    Stop-Process -Name 'ShellExperienceHost' -Force -ErrorAction SilentlyContinue
}

function Clear-TaskbarIcons {
    Set-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband' -Name 'Favorites' -Type Binary -Value ([byte[]](255))
    Remove-ItemProperty -Path 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\Taskband' -Name 'FavoritesResolve' -ErrorAction SilentlyContinue
}

###

function Limit-DefenderCpuUsage {
    Set-MpPreference -ScanAvgCPULoadFactor 30
}

function Restart-Explorer {
    Stop-Process -ProcessName 'explorer'
}

###

#Requires -RunAsAdministrator

Hide-ActionCenterSystemIcon
Hide-MeetNowSystemIcon
###
Hide-CortanaTaskbarIcon
Hide-SearchTaskbarIcon
Hide-TaskViewTaskbarIcon
###
Hide-DesktopIcons
Hide-TrayIcons
Show-FileExtensions
Show-SmallTaskbarIcons
###
Disable-AutoPlay
Disable-ClipboardHistory
Disable-OneDrive
Disable-WallpaperCompression
###
Clear-StartMenuTiles
Clear-TaskbarIcons
Restart-Explorer
###
Limit-DefenderCpuUsage
Rename-Computer -NewName 'ELITEDESK'
Set-TimeZone -Name 'Romance Standard Time'