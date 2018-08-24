$DNSname = "lab2.local"
$NetworkID = "192.168.0/24"
$IPAddress = "192.168.2.11"
$newPSfile = @“
Write-host "Checking to see if AD Web Services is running, if not, start it"
`$service = "ADWS"
`$running = get-service `$service
Write-host "ADWS Status: "`$running
if (`$running.status -eq "Stopped"){start-service `$service }

Write-Host "Set up DNS"
Set-DnsServerForwarder -IPAddress 192.168.2.1 
Add-DnsServerPrimaryZone -Name $DNSname -ReplicationScope "Forest" -PassThru 
Add-DnsServerPrimaryZone -NetworkID $NetworkID -ReplicationScope "Forest"
Add-DNSServerResourceRecordA -ZoneName "lab2.local" -Name VCSA -IPv4Address $IPaddress -CreatePtr
”@

$newPSfile |out-file -filepath c:\temp\newpsfile.ps1 -force 
