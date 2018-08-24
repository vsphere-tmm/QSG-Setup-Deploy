
#------------------------------------------------------------------------------
# 1st draft written by Mike Foley, @mikefoley, Virtualization Evangelist, RSA, The Security Division of EMC
# Contributions from Alan Renouf, @alanrenouf, EMC vSpecialist and PowerCLI guru
# Many thanks to those who's code we used, especially Luc Dekens, @LucD
#------------------------------------------------------------------------------
# All information, statements, and descriptions herein are offered AS IS
# only and are provided for informational purposes only. EMC Corporation
# does not guarantee the performance of, or offer a warranty of any kind,
# whether express, implied, or statutory, regarding the information herein
# or the compatibility of the information herein with EMC Corporation software
# or hardware products or other products.
#------------------------------------------------------------------------------
# 06-Apr-2010, Mike Foley, A simple Powershell/PowerCLI script to create a bunch of VM's. Written from lots of examples
# 20-Apr-2010, Alan Renouf, applied a different method of working out the numbers and re-wrote some of the code
# 21-Apr-2010, Alan Renouf, Fixed datastores which are used for deployment as per email from Mike.
#------------------------------------------------------------------------------
# You'll need to have the PowerCLI cmdlets installed. Get these from VMware.
# http://www.vmware.com/go/powercli

Add-PSSnapin -Name "VMware.VimAutomation.Core" -ErrorAction SilentlyContinue
#
#Things you can change
#------------------------------
$vchost = "10.5.103.185"
$num_vms_total = 4
$vm_prefix = "DEMO_VM_"
$Template_prefix = "tiny-ds-"
#-------------------------------
#Don't change below
$Template_Name = $vm_prefix + "*"

Connect-VIserver $vchost -user administrator -password emcworld

Write-Host "Collecting Template lists"
$Template_List = Get-Template $Template_Name | Select Name, @{N="Datastore";E={Get-VIObjectByVIView (Get-View ($_).DatastoreIdList)}} | Sort Name, Datastore

Write-Host "Collecting Datastore lists"
$Datastore_list = $Template_List | Select -Expand Datastore

Write-Host "Collecting Host lists"
$hosts = Get-VMHost | Sort Name

Write-Host "Collecting number of VMs per host"
$HostVMs = $hosts | Select Name, @{N="NumVM";E={@(($_ | Get-Vm ($vm_prefix + "*"))).Count}} | Sort NumVM, Name 

Write-Host "Collecting number of VMs per datastore"
$DSVMs = $Datastore_list | Select name, @{N="NumVM";E={@($_ | Get-VM ($vm_prefix + "*")).Count}} | Sort NumVM, Name

#Setup for Get-Random in the loop below
$min = [char]'a'
$max = [char]'z'
$alpha = [char[]]($min..$max)
$ofs = ''
$taskTab = @{}
$vm_count = 0

While ($vm_count -lt $num_vms_total){
	Write-Host "Finding host with least amount of $vm_prefix VMs on it"
	$LeastHost = $HostVMs | Sort NumVM | Select -First 1
	Write-Host "Finding datastore with least amount of $vm_prefix VMs on it"
	$LeastDatastore = $DSVMs | Sort NumVM | Select -First 1
	$ran_text = [string]( $alpha | Get-Random -Count 5 )
	$VM_Name = $vm_prefix + $ran_text + $vm_count
	$Template = ($Template_List | Where {$_.Datastore.Name -eq $LeastDatastore.Name}).Name
	Write "Create a virtual machine called $VM_Name on $($LeastHost.Name) using a template called $Template onto a datastore called $($LeastDatastore.Name)"
	$taskTab[(New-VM -Name $VM_Name -Template $template -VMHost (Get-VMhost $LeastHost.Name) -Datastore (Get-Datastore $LeastDatastore.Name) -DiskStorageFormat Thin -RunAsync ).Id] = $VM_Name
	$DSVMs | Where { $_.Name -eq $LeastDatastore.Name } | Foreach { $_.NumVM++ }
	$HostVMs | Where { $_.Name -eq $LeastHost.Name } | Foreach { $_.NumVM++ }
	$vm_count ++
}

Write-Host "-----------------------"
Write-Host "VM Deployment completed"
Write-Host "-----------------------"

Write-Host "-----------------------"
Write-Host "Starting VM's"
Write-Host "-----------------------"


#
## Start each VM that is completed
$runningTasks = $taskTab.Count
while($runningTasks -gt 0){
	Get-Task | % {
		if($taskTab.ContainsKey($_.Id) -and $_.State -eq "Success"){
			$xx = Get-VM $taskTab[$_.Id] 
           Write-Host "Starting VM " $xx.Name
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

#
#Disconnect-VIserver -server $vchost -confirm:$false
#
#
#
#foreach($Name in $newVmList){
#	$taskTab[(New-VM -VM (Get-VM $modelVm) -Name $Name -VMHost (Get-VMHost -Name $esxName) -RunAsync).Id] = $Name
#}