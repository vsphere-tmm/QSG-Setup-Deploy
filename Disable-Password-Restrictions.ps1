#Reset PAM to ignore the old password. Use "enforce=none"
$esxName = "w2-haas01-esx0118.eng.vmware.com"
$newName = "esxi-118.demo.vmware.com"
$hostname = "esxi-118"
$esxUser = "root"
$esxPswd = "VMware1!"
Connect-VIServer -Server $esxName -User $esxUser -Password $esxPswd
$passwordpolicy = “retry=3 min=disabled,disabled,disabled,7,7 enforce=none”
#Set-VMHostAdvancedConfiguration -VMHost $esxname -Name “Security.PasswordQualityControl" -Value $passwordpolicy
Get-AdvancedSetting -Entity $esxname -name Security.PasswordQualityControl |Set-AdvancedSetting -Value $passwordpolicy -Confirm:$false
