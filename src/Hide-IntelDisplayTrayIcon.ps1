#Requires -RunAsAdministrator

# Hide the Intel tray icon and disable the hotkey functionality.
Set-ItemProperty -Path 'HKLM:\Software\Intel\Display\igfxcui\igfxtray\TrayIcon' -Name 'ShowTrayIcon' -Value 0
Set-ItemProperty -Path 'HKLM:\Software\Intel\Display\igfxcui\HotKeys' -Name 'Enable' -Value 0