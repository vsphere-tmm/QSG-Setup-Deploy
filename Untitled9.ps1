$esxihost = "192.168.8.30"
$esxusername = "root"
$esxpassword = "VMware1!"
Write-host "Connecting to: " $esxihost
Connect-VIServer -Server $esxihost -user $esxusername -Password $esxpassword |Select Id, Description
get-vmhostaccount -Server $esxihost  -ErrorAction SilentlyContinue