$hosts = "10.5.99.91", "10.5.99.92", "10.5.99.93"
$csvfile = "C:\Users\Mike\Documents\My Code Library\Vmware\bulk-create-vms\small-test.csv"
#
$num_vms_total = 55
$num_vms_per_host = $num_vms_total/$hosts.Count
$vm_prefix = "DEMO_VM"
#
$vm_count = 0
$vmname_count = 0
foreach ($host_system in $hosts) {
	write-host "---------------------------------Creating VM's on $host_system ------------------------------"
	while ($vm_count -le $num_vms_per_host) {
		#New-VM -Name $VM_Name -Template $template -VMHost $host -Datastore $Datastore -DiskStorageFormat Thin -RunAsync
		$vm_count++
		$vmname_count++
		Write-Host "The vmnamecount is" $vmname_count
		$VM_Name = $vm_prefix + $vmname_count
		Write-Host "The vm name is" $VM_Name
	} 
$vm_count = 0
}