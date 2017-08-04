#
#Things to change
$vchost = "10.5.103.185"
$vm_prefix = "DEMO_VM_"
$VM_Name = $vm_prefix + "*"
#
#
Add-PSSnapin -Name "VMware.VimAutomation.Core" -ErrorAction SilentlyContinue
#
#
Connect-VIserver $vchost -user administrator -password emcworld
#
$list = Get-VM $VM_Name

foreach ($vm in $list){
	If ($vm.powerstate -eq "PoweredOff") {
	Write-Host "Removing PoweredOff VM " $vm
	Remove-VM -DeleteFromDisk -vm $vm -RunAsync -confirm:$false }
	ElseIf ($vm.powerstate -eq "PoweredOn"){
	Write-Host "Creating Hash Table and Stopping VM " $vm
	$taskTab[(Stop-VM  -vm $vm -RunAsync -confirm:$false).Id] = $vm}
	}



# Start each VM that is completed
$runningTasks = $taskTab.Count
while($runningTasks -gt 0){
	Get-Task | % {
		if($taskTab.ContainsKey($_.Id) -and $_.State -eq "Success"){
			$xx = Get-VM $taskTab[$_.Id] 
			Write-Host "Removing VM from Hash Table " $xx.Name
			Get-VM $taskTab[$_.Id] | Remove-VM -DeleteFromDisk -RunAsync -confirm:$false 
			$taskTab.Remove($_.Id)
			$runningTasks--
		}
		elseif($taskTab.ContainsKey($_.Id) -and $_.State -eq "Error"){
			$taskTab.Remove($_.Id)
			$runningTasks--
		}
	}
	Start-Sleep -Seconds 15
}

