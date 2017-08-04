$hosts = Get-VMHost
foreach ($vhost in $hosts)
{
    $vpg = Get-VirtualPortGroup -VMhost $vhost | where {$_.Name -eq "DHCP01"}
    Remove-VirtualPortGroup -VirtualPortGroup $vpg -Confirm:$false -ErrorAction SilentlyContinue
}