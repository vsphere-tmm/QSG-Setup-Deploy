#
#Things to change
$vchost = "10.5.99.90"
$template_name = "DSL-N"
$num_vms_per_host = 2
#
#
Add-PSSnapin -Name "VMware.VimAutomation.Core"
#
#
Connect-VIserver  $vchost
$template = get-template $template_name
#$hosts = "10.5.99.91", "10.5.99.92", "10.5.99.93"
$Datastore = get-datastore nfs-datastore-01
$csvfile = "C:\Users\Mike\Documents\My Code Library\Vmware\bulk-create-vms\test-csv.csv"
#
Import-Csv $csvfile |%{New-VM -Name $_.name -Template $template -VMHost $_.vmhost -Datastore $Datastore -DiskStorageFormat Thin}|Start-vm
#
#
#
Disconnect-VIserver -server $vchost
#
#
#foreach ($host in $hosts)  {
#write-host $host
#While $num_vms_per_host

#}

#
#
