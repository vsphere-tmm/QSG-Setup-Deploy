# 06-Apr-2010, Mike Foley, A simple Powershell/PowerCLI script to create a bunch of VM's. Written from lots of examples
#
#You'll need to have the PowerCLI cmdlets installed. Get these from VMware.
#http://www.vmware.com/go/powercli
#
#
Add-PSSnapin -Name "VMware.VimAutomation.Core" -ErrorAction SilentlyContinue
#
$vchost = "10.5.103.185"
Connect-VIserver   $vchost -user administrator -password emcworld
#
$Template_list = get-template tiny-ds-*
$Datastore_list = get-datastore vplex-ds-*
#$Resource_Pool = "Applications"
$hosts = Get-VMHost
$taskTab = @{}
#
$num_vms_total = 10
$num_vms_per_host = $num_vms_total/$hosts.Count
$vm_prefix = "DEMO_VM_"
#
#Setup for Get-Random in the loop below
$min = [int][char]'a'
$max = [int][char]'z'
$alpha = [char[]]($min..$max)
#$test = $alpha | Select-Object -First $hosts.Count
#Write-Host $test
#
#
#Code snippet: Get datastore of a template
#$template_datastore = get-viobjectbyviview (get-view (get-template $template_name).Datastoreidlist)
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
		$ofs = ''
		$ran_text = [string]( $alpha | Get-Random -Count 5 )
		$VM_Name = $vm_prefix + $ran_text + $vmname_count
		Write-Host "The vm is" $VM_Name "running on" $host_system #"in resource pool" $Resource_Pool
		Write-Host "The Template is" $template_name "and the Template Datastore is" $template_datastore
#
#		$taskTab[(New-VM -Name $VM_Name -Template $template_name -VMHost $host_system -Datastore $Datastore -DiskStorageFormat Thin -RunAsync).Id] = $VM_Name
	} 
	}
$vm_count = 0
}
#
## Start each VM that is completed
#$runningTasks = $taskTab.Count
#while($runningTasks -gt 0){
#	Get-Task | % {
#		if($taskTab.ContainsKey($_.Id) -and $_.State -eq "Success"){
#			Get-VM $taskTab[$_.Id] | Start-VM
#			$taskTab.Remove($_.Id)
#			$runningTasks--
#		}
#		elseif($taskTab.ContainsKey($_.Id) -and $_.State -eq "Error"){
#			$taskTab.Remove($_.Id)
#			$runningTasks--
#		}
#	}
#	Start-Sleep -Seconds 15
#}
#
##
#Disconnect-VIserver -server $vchost -confirm:$false
#
#
#
#foreach($Name in $newVmList){
#	$taskTab[(New-VM -VM (Get-VM $modelVm) -Name $Name -VMHost (Get-VMHost -Name $esxName) -RunAsync).Id] = $Name
#}