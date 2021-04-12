# Hide the Realtek tray icon.
Set-ItemProperty -Path 'HKCU:\Software\Realtek\Audio\RtkNGUI64\General' -Name 'ShowTrayIcon' -Value 0