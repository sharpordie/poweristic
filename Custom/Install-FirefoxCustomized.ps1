#Requires -RunAsAdministrator

# Download and install Firefox silently.
$address = 'https://download.mozilla.org/?product=firefox-msi-latest-ssl&os=win64&lang=en-US'
$program = [System.IO.Path]::Combine($env:TEMP, 'FirefoxSetup.msi')
(New-Object System.Net.WebClient).DownloadFile($address, $program)
Start-Process -FilePath 'msiexec.exe' -ArgumentList "/i `"$program`" /qn DESKTOP_SHORTCUT=false INSTALL_MAINTENANCE_SERVICE=false" -NoNewWindow -Wait

# Edit the policies.json file.
New-Item -ItemType Directory -Path "$env:PROGRAMFILES\Mozilla Firefox\distribution" -Force
$settings = "$env:PROGRAMFILES\Mozilla Firefox\distribution\policies.json"
$policies = @"
{
  "policies":{
    "DisablePocket":true,
    "DisableFirefoxAccounts":true,
    "DisableFirefoxStudies":true,
    "DisableTelemetry":true,
    "DisplayMenuBar":"never",
    "DefaultDownloadDirectory":"${home}\\Downloads\\DDL",
    "NoDefaultBookmarks":true,
    "NewTabPage":false,
    "ExtensionSettings":{
      "ff2mpv@eastmarch.github.com":{
        "installation_mode":"normal_installed",
        "install_url":"https://addons.mozilla.org/firefox/downloads/latest/ff2mpv-for-windows/latest.xpi"
      },
      "jid1-OY8Xu5BsKZQa6A@jetpack":{
        "installation_mode":"normal_installed",
        "install_url":"https://extensions.jdownloader.org/firefox.xpi"
      },
      "uBlock0@raymondhill.net":{
        "installation_mode":"normal_installed",
        "install_url":"https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi"
      },
      "{8147ec6e-cedf-498d-9edc-571451b89a9f}":{
        "installation_mode":"normal_installed",
        "install_url":"https://addons.mozilla.org/firefox/downloads/latest/medium-unlimited-read-for-free/latest.xpi"
      }
    },
    "FirefoxHome":{
      "Search":false,
      "TopSites":false,
      "Highlights":false,
      "Pocket":false,
      "Snippets":false,
      "Locked":false
    },
    "Homepage":{
      "URL":"about:blank",
      "Locked":false,
      "StartPage":"none"
    }
  }
}
"@
$policies | Set-Content $settings -Force