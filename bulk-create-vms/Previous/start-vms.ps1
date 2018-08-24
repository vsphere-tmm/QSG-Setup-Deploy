#
#Things to change
$vchost = "10.5.99.90"
$template_name = "DSL-N"
$num_vms_per_host = 2
#
#
Add-PSSnapin -Name "VMware.VimAutomation.Core" -ErrorAction SilentlyContinue
#
#
Connect-VIserver  $vchost
$template = get-template $template_name
$Datastore = get-datastore nfs-datastore-01
$csvfile = "C:\Users\Mike\Documents\My Code Library\Vmware\bulk-create-vms\test-test.csv"
#
#
#
$list = Import-Csv $csvfile  
foreach ($entry in $list){
$vm = Get-VM -Name $entry.name
if($vm.powerstate -eq "PoweredOff") {
Start-VM  -vm $vm -RunAsync -confirm:$false
ElseIf {write-host "$vm has already started"}
    }
    }
#
#
#
Disconnect-VIserver -server $vchost -confirm:$false
