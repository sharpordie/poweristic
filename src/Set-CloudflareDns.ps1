#Requires -RunAsAdministrator

# Use Cloudflare DNS with the first network adapter.
if ((Get-NetAdapter)[0]) {
    Set-DnsClientServerAddress -InterfaceIndex (Get-NetAdapter)[0].ifIndex -ServerAddresses ('1.1.1.1', '1.0.0.1')
}