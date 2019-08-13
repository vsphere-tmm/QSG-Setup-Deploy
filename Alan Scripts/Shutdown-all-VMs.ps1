Connect-VIServer 10.144.106.81
 
# Get All the ESX Hosts
$ESXSRV = Get-VMHost
 
# For each of the VMs on the ESX hosts
Foreach ($VM in ($ESXSRV | Get-VM)){
    # Shutdown the guest cleanly
    $VM | Shutdown-VMGuest -Confirm:$false
}
 
# Set the amount of time to wait before assuming the remaining powered on guests are stuck
$waittime = 200 #Seconds
 
$Time = (Get-Date).TimeofDay
do {
    # Wait for the VMs to be Shutdown cleanly
    sleep 1.0
    $timeleft = $waittime - ($Newtime.seconds)
    $numvms = ($ESXSRV | Get-VM | Where { $_.PowerState -eq "poweredOn" }).Count
    Write "Waiting for shutdown of $numvms VMs or until $timeleft seconds"
    $Newtime = (Get-Date).TimeofDay - $Time
    } until ((@($ESXSRV | Get-VM | Where { $_.PowerState -eq "poweredOn" }).Count) -eq 0 -or ($Newtime).Seconds -ge $waittime)
 
# Shutdown the ESX Hosts
$ESXSRV | Foreach {Get-View $_.ID} | Foreach {$_.ShutdownHost_Task($TRUE)}
 
Write-Host "Shutdown Complete"