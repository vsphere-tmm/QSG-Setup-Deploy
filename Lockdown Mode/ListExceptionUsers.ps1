#Run this at the vCenter level or against an individual host
$esxihosts = get-vmhost
foreach ($esxihost in $esxihosts)
 {
$myhost = Get-VMHost $esxihost | Get-View
$lockdown = Get-View $myhost.ConfigManager.HostAccessManager
Write-Host "--------------------------------"
#Get a list of the Exception Users
Write-Host "List of Exception Users on " $esxihost
$lockdown.QueryLockdownExceptions() 
Write-Host "--------------------------------"
 }