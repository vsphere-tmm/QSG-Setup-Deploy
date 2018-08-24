$hosts = Get-VMHost
foreach ($vhost in $hosts)
{
Add-VMHostNtpServer -VMHost $vhost -NtpServer "10.20.8.1" -ErrorAction SilentlyContinue
Add-VMHostNtpServer -VMHost $vhost -NtpServer "10.17.0.1" -ErrorAction SilentlyContinue
Get-VmHostService -VMHost $vhost | Where-Object {$_.key -eq "ntpd"} | Start-VMHostService -ErrorAction SilentlyContinue
Get-VmHostService -VMHost $vhost | Where-Object {$_.key -eq "ntpd"} | Set-VMHostService -policy "automatic" -ErrorAction SilentlyContinue
}

