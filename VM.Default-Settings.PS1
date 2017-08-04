#PowerCLI Command Assessment
$VMname = "Tiny Linux Template"

# List the VMs and their current settings
Get-VM -Name  $VMname  | Get-AdvancedSetting -Name "isolation.tools.copy.disable" | Select Entity, Name, Value
# List the VMs and their current settings
Get-VM -Name  $VMname  | Get-AdvancedSetting -Name "isolation.tools.dnd.disable" | Select Entity, Name, Value
# List the VMs and their current settings
Get-VM -Name  $VMname  | Get-AdvancedSetting -Name  "isolation.tools.setGUIOptions.enable"| Select Entity, Name, Value
# List the VMs and their current settings
Get-VM -Name  $VMname  | Get-AdvancedSetting -Name "isolation.tools.paste.disable"| Select Entity, Name, Value
# List the VMs and their current settings
Get-VM -Name  $VMname  | Get-AdvancedSetting -Name "isolation.tools.diskShrink.disable"| Select Entity, Name, Value
# List the VMs and their current settings
Get-VM -Name  $VMname  | Get-AdvancedSetting -Name "isolation.tools.diskWiper.disable"| Select Entity, Name, Value
# List the VMs and their current settings
Get-VM -Name  $VMname  | Get-AdvancedSetting -Name "tools.setInfo.sizeLimit" | Select Entity, Name, Value
# List the VMs and their current settings
Get-VM -Name  $VMname  | Get-AdvancedSetting -Name "isolation.device.connectable.disable" | Select Entity, Name, Value
# List the VMs and their current settings
Get-VM -Name  $VMname  | Get-AdvancedSetting -Name "isolation.device.edit.disable" | Select Entity, Name, Value
# List the VMs and their current settings
Get-VM -Name  $VMname  | Get-AdvancedSetting -Name  "ethernetn.filtern.name*" | Select Entity, Name, Value
# List the VMs and their current settings
Get-VM -Name  $VMname  | Get-AdvancedSetting -Name "RemoteDisplay.vnc.enabled" | Select Entity, Name, Value
# List the VMs and their current settings
Get-VM -Name  $VMname  | Get-AdvancedSetting -Name "sched.mem.pshare.salt"| Select Entity, Name, Value
