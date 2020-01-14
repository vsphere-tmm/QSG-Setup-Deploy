Write-Host "Checking to see if ADFS is running"
$adfsinstalled = Get-WindowsFeature |Where-Object {
    $_.Name -imatch "ADFS-Federation"
}
if ($adfsinstalled.installed -eq $true) {
    Write-Host "ADFS is installed. Script Continuing"
}
else { 
    Write-Host "ADFS not installed. You should run this on your ADFS server"
    Exit
}
#This is the name of your vCenter. IP address or FQDN
$vcname = "192.168.1.188"

Write-Host "Connecting to the VC VI Server" $vcname