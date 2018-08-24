$vcenterName = "mfoley-vcsa1.eng.vmware.com"
$clusterName = "Cluster"
$esxName = "w2-haas01-esx0117.eng.vmware.com"
$newName = "esxi-117.demo.vmware.com"
$hostname = "esxi-117"
$esxUser = "root"
$esxPswd = "VMware1!"
$domainname = "demo.vmware.com"
$dnspri = "10.144.119.231"

#Connect-VIServer mfoley-vcsa1.eng.vmware.com -user administrator@vsphere.local -password VMware1!
#Get-VMHost -Name $esxName | Set-VMHost -State Disconnected -Confirm:$false | Remove-VMHost -Confirm:$false

Connect-VIServer -Server $esxName -User $esxUser -Password $esxPswd
#$esxcli = Get-EsxCli -VMHost $esxName
#$esxcli.system.hostname.set($null,$newName,$null)
Get-VMHostNetwork -VMHost $esxname | Set-VMHostNetwork -HostName $hostname -DomainName $domainname -DNSAddress $dnspri -SearchDomain $domainname  -Confirm:$false
Disconnect-VIServer -Server $esxName -Confirm:$false

#Connect-VIServer mfoley-vcsa1.eng.vmware.com -user administrator@vsphere.local -password VMware1!
#$cluster = Get-Cluster -Name $clusterName
#Add-VMHost -Name $newName -Location $cluster -User $esxUser -Password $esxPswd -Force -Confirm:$false


