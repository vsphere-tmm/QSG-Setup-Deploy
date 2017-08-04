$hosts = "10.5.99.91", "10.5.99.92", "10.5.99.93"
#
$num_vms_total = 50
$num_vms_per_host = $num_vms_total / $hosts.Count
$vm_prefix = "DEMO_VM"
#
$vm_prefix = "VM"
$count = 0
foreach ($host_system in $hosts) {

	while ($count -lt $num_vms_per_host){
	
		#New-VM -Name $VM_Name -Template $template -VMHost $host -Datastore $Datastore -DiskStorageFormat Thin -RunAsync
		$count++
		write-host "Host is: " $host_system
		$VM_Name = $vm_prefix + $count
		Write-Host "The vm name is" $VM_Name
	} 

}
