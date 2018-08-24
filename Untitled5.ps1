Connect-VIServer mfoley-vcsa1.eng.vmware.com -User administrator@vsphere.local -Password VMware1!
$vmhost = "w2-haas01-esx0120.eng.vmware.com"
$esxcli= Get-Esxcli -vmHost $vmhost
$vibpath="/vmfs/volumes/CPBU_PM_PMM_4/Kits/lsi-mr3-6.606.12.00-1OEM.600.0.0.2159203.x86_64.vib"
$esxcli.software.vib.install($null,$null,$null,$null,$null,$null,$null,$null,$vibpath)