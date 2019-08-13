# 06-Apr-2010, Mike Foley, A simple Powershell/PowerCLI script to create a bunch of VM's. Written from lots of examples
#
#You'll need to have the PowerCLI cmdlets installed. Get these from VMware.
#http://www.vmware.com/go/powercli
#
#Some variables you can change
$vchost = "10.5.99.90"
$template_name = "DSL-N"
$Datastore_name = "nfs-datastore-01"
$Resource_Pool = "Applications"
$csvfile = "C:\Users\Mike\Documents\My Code Library\Vmware\bulk-create-vms\small-test.csv"
#
# Example of the contents of the CSV file
#name	vmhost
#VM001	10.5.99.91
#VM002	10.5.99.91
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
Import-Csv $csvfile | %{
New-VM -Name $_.name -Template $template -VMHost $_.vmhost -Datastore $Datastore -ResourcePool $Resource_Pool -DiskStorageFormat Thin -RunAsync
}
#
Disconnect-VIserver -server $vchost -confirm:$false
