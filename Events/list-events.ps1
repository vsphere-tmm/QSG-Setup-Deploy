Connect-VIServer -user administrator@vsphere.local -Password VMware1! -Server vcsa.lab.local
$events = Get-VIEvent -MaxSamples 1000

foreach ($event in $events) {
if  ($event.fullFormattedMessage -match "User (.*)@\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b logged in") 
 {
 Write-Host ("User " + $matches[1] + " logged in at:" + $event.createdTime)
 } 
 }
 #Get-VIEvent -MaxSamples 100 |where $_.FullFormattedMessage -eq "User (.*)@\b\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}\b logged in"

 $events = Get-VIEvent -MaxSamples 1000 
 $events |where {$_.FullFormattedMessage -like "*logged in*"} |Select-Object Username,IpAddress,CreatedTime  | export-csv -path c:\Users\Administrator\file.csv 
