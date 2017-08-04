
$AdminKey = "HKLM:" 
$WinLogonKey = $AdminKey + "\SOFTWARE\Microsoft\Windows NT\CurrentVersion\WinLogon" 
$RunOnceKey = $AdminKey + "\Software\Microsoft\Windows\CurrentVersion\RunOnce" 

Set-ItemProperty -Path $RunOncekey -Name Foo -Value "%systemroot%\system32\WindowsPowershell\v1.0\Powershell.exe -executionpolicy bypass -file \\10.144.107.17\vLAB\test-runonce.ps1 -NetworkNumber 3"
