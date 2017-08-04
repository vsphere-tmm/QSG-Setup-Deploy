Connect-VIServer mfoley-vcsa1.eng.vmware.com -User administrator@vsphere.local -Password VMware1!
#$vswitch = Get-VirtualSwitch -Name "vSwitch2"
Foreach ($vmhost in (get-vmhost))
{

 Get-VirtualSwitch -VMhost $vmhost -Name "vSwitch2" | New-VirtualPortGroup -Name LabNetwork1
 Get-VirtualSwitch -VMhost $vmhost -Name "vSwitch2" | New-VirtualPortGroup -Name LabNetwork2
Get-VirtualSwitch -VMhost $vmhost -Name "vSwitch2" | New-VirtualPortGroup -Name LabNetwork3
}