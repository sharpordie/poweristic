#Requires -RunAsAdministrator

# Enable the required features.
if ((Get-WindowsOptionalFeature -FeatureName Microsoft-Windows-Subsystem-Linux -Online).State -eq "Disabled") {
    Write-Host "Enabling the Microsoft-Windows-Subsystem-Linux feature..."
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart | Out-Null
    Write-Host "Enabling the VirtualMachinePlatform feature..."
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart | Out-Null
    # Register the scheduled task and restart.
    Register-ScheduledTask -TaskName "InstallDockerDesktop" -Trigger (New-ScheduledTaskTrigger -AtLogOn) -User ($env:USERNAME) -Action (New-ScheduledTaskAction -Execute "powershell.exe" -Argument ($MyInvocation.MyCommand).Path) -RunLevel Highest -Force
    Write-Host "Restarting the computer..."
    Restart-Computer
}

# Unregister the scheduled task.
Unregister-ScheduledTask -TaskName "InstallDockerDesktop" -Confirm:$false

# Download and install the Linux kernel update package silently.
Write-Host "Downloading and installing the Linux kernel update package..."
$address = "https://wslstorestorage.blob.core.windows.net/wslblob/wsl_update_x64.msi"
$program = [System.IO.Path]::Combine($env:TEMP, [System.IO.Path]::GetFileName($address))
(New-Object System.Net.WebClient).DownloadFile($address, $program)
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i `"$program`" /quiet /qn /norestart" -NoNewWindow -Wait

# Set WSL 2 as default version.
wsl --set-default-version 2

# Download and install Docker Desktop silently.
Write-Host "Downloading and installing the Docker Desktop package..."
$address = "https://desktop.docker.com/win/stable/Docker Desktop Installer.exe"
$program = [System.IO.Path]::Combine($env:TEMP, [System.IO.Path]::GetFileName($address))
(New-Object System.Net.WebClient).DownloadFile($address, $program)
Start-Process -FilePath `"$program`" -ArgumentList "install --quiet" -NoNewWindow -Wait

# Remove the shortcut from the desktop directory.
$shortcut = [System.IO.Path]::Combine([Environment]::GetFolderPath("Desktop"), "Docker*.lnk")
if (Test-Path -Path $shortcut) { Remove-Item -Path $shortcut }

# Restart once again.
Write-Host "Restarting the computer..."
Restart-Computer

# Remove it from startup.
Remove-ItemProperty -Path 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Run' -Name 'Docker Desktop'