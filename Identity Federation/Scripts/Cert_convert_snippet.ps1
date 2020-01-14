$fqdn = [System.Net.Dns]::GetHostByName((hostname)).HostName
$cert = Get-ChildItem Cert:\LocalMachine\My |where {$_.Subject -match $fqdn.tolower()}
$CAcert = Get-ChildItem Cert:\LocalMachine\CA | where { $_.Subject -match $cert.Issuer}
$base64Cert = [convert]::tobase64string($CAcert.export('Cert'),[system.base64formattingoptions]::insertlinebreaks)
$ad_cert_chain = @($base64Cert)

Write-Output "AD Cert Chain"
$ad_cert_chain

Write-Output "Base64 Cert"
$base64Cert