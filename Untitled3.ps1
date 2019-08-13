﻿#Set the Password Policy
$passwordpolicy = “retry=3 min=disabled,disabled,disabled,7,7”

#Get the list of connected ESXi hosts
$VMHosts = Get-VMHost | Where {$_.ConnectionState -eq "Connected"}

#Loop through the lists of hosts and set the Advanced Setting
foreach ($VMHost in $VMHosts) {
Set-VMHostAdvancedConfiguration -VMHost $VMHost -Name “Security.PasswordQualityControl" -Value $passwordpolicy
}
