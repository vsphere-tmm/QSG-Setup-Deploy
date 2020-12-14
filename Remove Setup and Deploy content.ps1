##
<#
.SYNOPSIS
    This script cleans up all the things that vSphere w-Tanzu QSG Setup and Deploy.ps1 set
    should you have entered in a wrong value when running it. This gets you back to your starting point where you
    can fix the values in the setup and deploy script and re-run it.
.DESCRIPTION

.EXAMPLE

.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
This WILL remove all the things the setup and deploy script created! Use wisely!
#>
$VMname = "haproxy-demo"
$datastore = Get-Datastore -Name  "vsanDatastore"
$StoragePolicyName = "kubernetes-demo-storage"
$StoragePolicyTagCategory = "kubernetes-demo-tag-category"
$StoragePolicyTagName = "kubernetes-gold-storage-tag"
#
Stop-VM -Confirm:$false -Kill (Get-VM $VMname)
Remove-VM -Confirm:$false (Get-VM $VMname)
#
Remove-ContentLibrary -Confirm:$false  (Get-ContentLibrary -Name "tkg-cl")
Remove-VDSwitch -Confirm:$false (Get-VDSwitch "Dswitch")
Remove-TagCategory $StoragePolicyTagCategory -Confirm:$false
Get-Tag $StoragePolicyTagName | Remove-Tag  -Confirm:$false
Get-Datastore -Name $datastore | Remove-TagAssignment -Confirm:$false
Remove-SpbmStoragePolicy $StoragePolicyName -Confirm:$false
