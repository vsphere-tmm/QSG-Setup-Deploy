Connect-VIServer mfoley-vcsa1.eng.vmware.com -User administrator@vsphere.local -Password VMware1!
Foreach ($vmhost in (get-vmhost)) 
{ 
 $vswitch3 = New-VirtualSwitch -VMHost $vmhost -Name vSwitch3
 New-VirtualPortGroup -VirtualSwitch $vswitch1 -Name IsolatedNetwork 
}