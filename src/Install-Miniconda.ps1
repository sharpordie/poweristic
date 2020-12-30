#Requires -RunAsAdministrator

# Download and install Miniconda silently.
$address = 'https://repo.anaconda.com/miniconda/Miniconda3-latest-Windows-x86_64.exe'
$program = [System.IO.Path]::Combine($env:TEMP, [System.IO.Path]::GetFileName($address))
$destination = [System.IO.Path]::Combine($env:LOCALAPPDATA, 'Programs', 'Miniconda')
(New-Object System.Net.WebClient).DownloadFile($address, $program)
Start-Process -FilePath `"$program`" -ArgumentList "/S /InstallationType=JustMe /RegisterPython=0 /AddToPath=1 /NoRegistry=1 /D=$destination" -NoNewWindow -Wait

# Edit the settings.
$env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path', 'User')
conda config --set auto_activate_base false
conda install -n base -c conda-forge pipenv -y
conda install -n base -c conda-forge poetry -y
$env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path', 'User')
poetry config virtualenvs.in-project true
conda update --all -y

# Add some environment variables.
Start-Process -FilePath 'setx.exe' -ArgumentList 'PYTHONDONTWRITEBYTECODE /M "1"' -NoNewWindow -Wait
Start-Process -FilePath 'setx.exe' -ArgumentList 'PIPENV_VENV_IN_PROJECT /M "1"' -NoNewWindow -Wait
    
# Fix the conda/venv incompatibility.
Copy-Item ([System.IO.Path]::Combine($destination, 'python.exe')) -Destination ([System.IO.Path]::Combine($destination, 'Lib', 'venv', 'scripts', 'nt'))
Copy-Item ([System.IO.Path]::Combine($destination, 'pythonw.exe')) -Destination ([System.IO.Path]::Combine($destination, 'Lib', 'venv', 'scripts', 'nt'))