#Get-NsxtService -name com.vmware.nsx.switching_profiles
#Get-NsxtService -name com.vmware.nsx.switching_profiles |get-member
#(Get-NsxtService -name com.vmware.nsx.switching_profiles).list().results

$cred = Get-Credential
Connect-NsxtServer -server 10.172.212.15 -Credential $cred
(Get-NsxtService -name com.vmware.nsx.switching_profiles).list().results |select id,display_name