# 06-Apr-2010, Mike Foley, A simple Powershell/PowerCLI script to create a bunch of VM's. Written from lots of examples
#
#You'll need to have the PowerCLI cmdlets installed. Get these from VMware.
#http://www.vmware.com/go/powercli
#
#Some variables you can change
$vchost = "10.5.99.90"
$template_name = "DSL-N"
$Datastore_name = "nfs-datastore-01"
$hosts = "10.5.99.91", "10.5.99.92", "10.5.99.93"
#
$num_vms_total = 10
$num_vms_per_host = $num_vms_total/$hosts.Count
$vm_prefix = "DEMO_VM"
#

#
#
Add-PSSnapin -Name "VMware.VimAutomation.Core" -ErrorAction SilentlyContinue
#
#You'll be prompted via a dialog box for the vCenter credentials.
Connect-VIserver   $vchost
#
$template = get-template $template_name
$Datastore = get-datastore $Datastore_name
#
#
$vm_count = 0
$vmname_count = 0
foreach ($host_system in $hosts) {
	write-host "---------------------------------Creating VM's on $host_system ----------------------------- "
	while ($vm_count -le $num_vms_per_host) {
		$vm_count++
		$vmname_count++
		#Write-Host "The vmnamecount is" $vmname_count
		$VM_Name = $vm_prefix + $vmname_count
		Write-Host "The vm name is" $VM_Name
		New-VM -Name $VM_Name -Template $template -VMHost $host -Datastore $Datastore -DiskStorageFormat Thin -RunAsync
	} 
$vm_count = 0
}
#
Disconnect-VIserver -server $vchost -confirm:$false
