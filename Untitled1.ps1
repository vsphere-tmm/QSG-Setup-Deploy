Connect-VIServer mfoley-vcsa1.eng.vmware.com  -User administrator@vsphere.local -Password VMware1!
#get-vmhost -Name w3r6c1-tm-h360-03.pml.local | New-Datastore -Name mfoley-nfs-200gb-01 -path /mfoley-nfs-200gb-01 -NfsHost 10.144.102.169
get-vmhost -Name w3r6c1-tm-h360-03.pml.local | New-Datastore -Name CPBU_PM_PMM_4 -path /CPBU_PM_PMM_4 -NfsHost 192.168.104.251
