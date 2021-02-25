#Connect to vCenter. Edit values as appropriate.
$vc = "10.174.71.178"
$vc_user = "administrator@vsphere.local"
$vc_password = "Admin!23"
Connect-VIServer -User $vc_user -Password $vc_password -Server $vc
$Cluster = Get-Cluster  -Name "vSAN-Cluster"
$datastore = Get-Datastore -Name  "vsanDatastore"
$vmhosts = Get-VMHost
$tkgcl = "tkg-cl"
$ntpservers = @("time.vmware.com")
#
#
$workloadhosts = get-cluster $Cluster | get-vmhost
New-VDSwitch -Name "WLN" -MTU 1600 -NumUplinkPorts 1 -location vSAN-DC
Get-VDSwitch "WLN" | Add-VDSwitchVMHost -VMHost $workloadhosts
Get-VDSwitch "WLN" | Add-VDSwitchPhysicalNetworkAdapter -VMHostNetworkAdapter ($workloadhosts | Get-VMHostNetworkAdapter -Name vmnic2) -Confirm:$false
New-VDPortgroup -Name "Workload Network" -VDSwitch "WLN"
#
