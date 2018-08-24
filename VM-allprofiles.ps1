#PowerCLI Command Assessment
$VMname = "Windows 2012 R2 Blank"
#PowerCLI Command Assessment
# List the VMs and their current settings
Get-VM -Name  $VMname  | Get-AdvancedSetting -Name  "isolation.tools.autoInstall.disable"| Select Entity, Name, Value
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
Get-VM -Name  $VMname  | Get-AdvancedSetting -Name "isolation.tools.hgfsServerSet.disable"| Select Entity, Name, Value
#List the VM's and their disk types
Get-VM -Name  $VMname  | Get-HardDisk | Select Parent, Name, Filename, DiskType, Persistence
# List the VMs and their current settings
Get-VM -Name  $VMname  | Get-AdvancedSetting -Name "isolation.tools.ghi.autologon.disable"| Select Entity, Name, Value
# List the VMs and their current settings
Get-VM -Name  $VMname  | Get-AdvancedSetting -Name "isolation.bios.bbs.disable"| Select Entity, Name, Value
# List the VMs and their current settings
Get-VM -Name  $VMname  | Get-AdvancedSetting -Name "isolation.tools.getCreds.disable"| Select Entity, Name, Value
# List the VMs and their current settings
Get-VM -Name  $VMname  | Get-AdvancedSetting -Name "isolation.tools.ghi.launchmenu.change" | Select Entity, Name, Value
# List the VMs and their current settings
Get-VM -Name  $VMname  | Get-AdvancedSetting -Name "isolation.tools.memSchedFakeSampleStats.disable" | Select Entity, Name, Value
# List the VMs and their current settings
Get-VM -Name  $VMname  | Get-AdvancedSetting -Name "isolation.tools.ghi.protocolhandler.info.disable" | Select Entity, Name, Value
# List the VMs and their current settings
Get-VM -Name  $VMname  | Get-AdvancedSetting -Name "isolation.ghi.host.shellAction.disable" | Select Entity, Name, Value
# List the VMs and their current settings
Get-VM -Name  $VMname  | Get-AdvancedSetting -Name "isolation.tools.dispTopoRequest.disable"| Select Entity, Name, Value
# List the VMs and their current settings
Get-VM -Name  $VMname  | Get-AdvancedSetting -Name "isolation.tools.trashFolderState.disable"| Select Entity, Name, Value
# List the VMs and their current settings
Get-VM -Name  $VMname  | Get-AdvancedSetting -Name "isolation.tools.ghi.trayicon.disable"| Select Entity, Name, Value
# List the VMs and their current settings
Get-VM -Name  $VMname  | Get-AdvancedSetting -Name "isolation.tools.unity.disable"| Select Entity, Name, Value
# List the VMs and their current settings
Get-VM -Name  $VMname  | Get-AdvancedSetting -Name "isolation.tools.unityInterlockOperation.disable"| Select Entity, Name, Value
# List the VMs and their current settings
Get-VM -Name  $VMname  | Get-AdvancedSetting -Name "isolation.tools.unity.taskbar.disable" | Select Entity, Name, Value
# List the VMs and their current settings
Get-VM -Name  $VMname  | Get-AdvancedSetting -Name "isolation.tools.unityActive.disable" | Select Entity, Name, Value
# List the VMs and their current settings
Get-VM -Name  $VMname  | Get-AdvancedSetting -Name "isolation.tools.unity.windowContents.disable" | Select Entity, Name, Value
# List the VMs and their current settings
Get-VM -Name  $VMname  | Get-AdvancedSetting -Name "isolation.tools.unity.push.update.disable" | Select Entity, Name, Value
# List the VMs and their current settings
Get-VM -Name  $VMname  | Get-AdvancedSetting -Name "isolation.tools.vmxDnDVersionGet.disable"| Select Entity, Name, Value
# List the VMs and their current settings
Get-VM -Name  $VMname  | Get-AdvancedSetting -Name "isolation.tools.guestDnDVersionSet.disable"| Select Entity, Name, Value
# List the VMs and their current settings
Get-VM -Name  $VMname  | Get-AdvancedSetting -Name "isolation.tools.vixMessage.disable"| Select Entity, Name, Value
# List the VMs and their current settings
Get-VM -Name  $VMname  | Get-AdvancedSetting -Name "tools.setInfo.sizeLimit" | Select Entity, Name, Value
# List the VMs and their current settings
Get-VM -Name  $VMname  | Get-AdvancedSetting -Name "isolation.device.connectable.disable" | Select Entity, Name, Value
# List the VMs and their current settings
Get-VM -Name  $VMname  | Get-AdvancedSetting -Name "isolation.device.edit.disable" | Select Entity, Name, Value
# List the VMs and their current settings
Get-VM -Name  $VMname  | Get-AdvancedSetting -Name  "tools.guestlib.enableHostInfo"| Select Entity, Name, Value
# List the VMs and their current settings
Get-VM -Name  $VMname  | Get-AdvancedSetting -Name  "ethernetn.filtern.name*" | Select Entity, Name, Value
# List the VMs and their current settings
Get-VM -Name  $VMname  | Get-AdvancedSetting -Name "RemoteDisplay.vnc.enabled" | Select Entity, Name, Value
# List the VMs and their current settings
Get-VM -Name  $VMname  | Get-AdvancedSetting -Name "sched.mem.pshare.salt"| Select Entity, Name, Value
