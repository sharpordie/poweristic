#Requires -RunAsAdministrator

# Download and install Python 3.8.x silently.
$website = 'https://www.python.org/downloads/windows/'
$content = (New-Object System.Net.WebClient).DownloadString($website)
$pattern = 'python-(3\.8\.[\d.]+)-'
$version = [Regex]::Matches($content, $pattern).Groups[1].Value
$address = "https://www.python.org/ftp/python/$version/python-$version-amd64.exe"
$program = [System.IO.Path]::Combine($env:TEMP, [System.IO.Path]::GetFileName($address))
(New-Object System.Net.WebClient).DownloadFile($address, $program)
Start-Process -FilePath `"$program`" -ArgumentList '/quiet InstallAllUsers=1 AssociateFiles=0 PrependPath=1 Shortcuts=0 Include_launcher=0 InstallLauncherAllUsers=0' -NoNewWindow -Wait

# Update pip.
$env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path', 'User')
python -m pip install --upgrade pip

# Install poetry.
$env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path', 'User')
(Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/python-poetry/poetry/master/get-poetry.py' -UseBasicParsing).Content | python.exe

# Configure poetry.
$env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path', 'User')
poetry config virtualenvs.in-project true

# Add some environment variables.
Start-Process -FilePath 'setx.exe' -ArgumentList 'PYTHONDONTWRITEBYTECODE /M "1"' -NoNewWindow -Wait