#Static Variables. Change as necessary

Param(
[string]$NetworkNumber        = "2",
[string]$SystemName           = "DC1",
[string]$DomainName           = "LAB",
[string]$SetDNSSuffix         = "lab2.local",
[string]$IPAddress            = "192.168."+$NetworkNumber+".10",
[string]$Gateway              = "192.168."+$NetworkNumber+".1",
[string]$DNSServerList        = "192.168."+$NetworkNumber+".1,127.0.0.1",
[string]$NetworkID            = “192.168."+$NetworkNumber+".0/24",
[string]$NetworkPrefixLength  = "24"
)

Write-Host "IP Address is " $IPAddress
Write-Host $DNSServerList
Write-Host $NetworkID
Write-Host $Gateway
