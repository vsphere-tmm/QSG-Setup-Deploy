#Connect to vCenter. Edit values as appropriate.
$vc = "192.168.111.143"
$vc_user = "administrator@vsphere.local"
$vc_password = "VMware1!"
Connect-VIServer -User $vc_user -Password $vc_password -Server $vc
$Cluster = Get-Cluster  -Name "cluster"
$datacenter = Get-Datacenter "datacenter"
$datastore = Get-Datastore -Name  "vsanDatastore"
$vmhosts = Get-VMHost
$tkgcl = "tkg-cl"
$ntpservers = @("time.vmware.com")
#
#

$header = 'Name','pgname','vmnic'
$newswitch_list = ConvertFrom-Csv -Header $header @'
WLN1,Workload24,vmnic4
WLN2,Workload25,vmnic5
'@

$workloadhosts = get-cluster $Cluster | get-vmhost
#
foreach ($newswitch in $newswitch_list) {
New-VDSwitch -Name $newswitch.Name -MTU 1600 -NumUplinkPorts 1 -location $datacenter
Get-VDSwitch $newswitch.Name | Add-VDSwitchVMHost -VMHost $workloadhosts
Get-VDSwitch $newswitch.Name | Add-VDSwitchPhysicalNetworkAdapter -VMHostNetworkAdapter ($workloadhosts | Get-VMHostNetworkAdapter -Name $newswitch.vmnic) -Confirm:$false
New-VDPortgroup -Name $newswitch.pgname -VDSwitch $newswitch.Name
}

#
