# Provide the username and password of an account on your ESXi hosts.
# Provide the name of your vCenter Server
$esxusername = "root"
$esxpassword = "VMware1!"
$vCenterServer = "vcsa.lab.local"

#Ensure all connections are dropped.
Disconnect-VIServer -Force -server * -Confirm:$false

# You may need to provide the username and password of your vCenter server below
connect-viserver $vCenterServer
$esxihosts = get-vmhost

#
foreach ($esxihost in $esxihosts)
{
Write-Host "Host is: " $esxihost
Write-host "Exception Users from vCenter"
$myhost = Get-VMHost $esxihost | Get-View
$lockdown = Get-View $myhost.ConfigManager.HostAccessManager
$LDusers = $lockdown.QueryLockdownExceptions()
Write-host $LDusers

# Connect to each ESXi host in the cluster to retrieve the list of local users.
Write-Host "Lockdown user: " $LDuser
    Write-host "Connecting to: " $esxihost
    Connect-VIServer -Server $esxihost -user $esxusername -Password $esxpassword

#Loop through the list of Exception Users and check to see if they have accounts on
#the ESXi server and if that account in an administrator account.

foreach ($LDuser in $LDusers)
    {

    Write-host "Get-vmhostaccount"
    $hostaccountname = get-vmhostaccount   -ErrorAction SilentlyContinue  $LDuser
    write-host "Check to see if user exists"
    if ($hostaccountname.Name) {}
    Write-Host $hostaccountname.Name
        {
        Write-Host "Get-VIPermission"
        $isadmin = Get-VIPermission -Principal $LDuser -ErrorAction SilentlyContinue | Where {$_.Role –eq “Admin”} 
        Write-host "Admin Role: " $isadmin.Role
        Write-host ""
        if ($isadmin.Role -eq "Admin") {Write-Host $LDuser is an "Exception User with Admin accounts on " $esxihost}
        }
     Disconnect-VIServer -Server $global:DefaultVIServer -Force  -Confirm:$false
    
    }
}

