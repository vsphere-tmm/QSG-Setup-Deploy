Import-Module -Name ActiveDirectory

Get-ADComputer -filter * |

Foreach-Object {

$SecurityDescriptor = Get-Acl -Path "C:\ProgramData\VMware\VMware CAF"
$SecurityDescriptor.SetSecurityDescriptorSddlForm("D:P(A;OICI;0x1200a9;;;WD)(A;OICI;FA;;;SY)(A;OICI;FA;;;BA)")
Set-Acl -Path "C:\ProgramData\VMware\VMware CAF" -AclObject $SecurityDescriptor }
