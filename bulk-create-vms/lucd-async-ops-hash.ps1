$esxName = "esx1.test.local"
$modelVm = "ModelVm"
$newVmList = "NewVm1","NewVm2"
$taskTab = @{}

# Create all the VMs specified in $newVmList
foreach($Name in $newVmList){
	$taskTab[(New-VM -VM (Get-VM $modelVm) -Name $Name -VMHost (Get-VMHost -Name $esxName) -RunAsync).Id] = $Name
}

# Start each VM that is completed
$runningTasks = $taskTab.Count
while($runningTasks -gt 0){
	Get-Task | % {
		if($taskTab.ContainsKey($_.Id) -and $_.State -eq "Success"){
			Get-VM $taskTab[$_.Id] | Start-VM
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
