$level = New-Object VMware.Vim.HostLockdownMode
#Populate with level of lockdown:(lockdownDisabled,lockdownNormal,lockdownStrict)
$level = “lockdownStrict”
$esxihosts = get-vmhost
foreach ($esxihost in $esxihosts)
{
$myhost = Get-VMHost $esxihost | Get-View
$lockdown = Get-View $myhost.ConfigManager.HostAccessManager
Write-Host “——————————–”
Write-Host “Setting Lockdown mode to ” $level
$lockdown.ChangeLockdownMode($level)
$lockdown.UpdateViewData()
$lockdownstatus = $lockdown.LockdownMode
Write-Host “Lockdown mode on $esxihost is set to $lockdownstatus”
Write-Host “——————————–”
}
