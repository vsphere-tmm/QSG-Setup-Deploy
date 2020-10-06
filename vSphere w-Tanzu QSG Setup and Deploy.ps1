##
<#
.SYNOPSIS
    Deploys HAProxy and outputs all the data needed to copy/paste into the vSphere with Tanzu
    # Cluster Wizard
.DESCRIPTION
    Introduced in vSphere 7 Update 1, vSphere with Tanzu uses virtual distributed switches
    and an HAProxy VM to provide network isolation and load balancing for Kubernetes workloads.
    This script deploys the HAProxy Load Balancer VM and then generates a text output that you
    can copy/paste data from into the UI for setting up the vSphere with Tanzu Cluster deployment wizard.
.EXAMPLE

.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    vSphere with Tanzu cannot be installed on one /24 network due to technical limitations. For the
    purposes of a PoC or lab environment and in a "Default" configuration you need two subnets.
    These are the Management (VC/ESXi/etc) and Workload Networks. (TKG Clusters)

    You don't need a full /24 on each! See below for examples on using two /24's and one subnet for
    VC/ESXi and a small /27 for Workload Networks.

    Be sure to take note of the use of CIDR notation for $ovfConfig.loadbalance.service_ip_range.Value
    Later, when deploying the proxy you will be asked to supply a range of IP addresses. That's actual
    ranges and not CIDR. These ranges will come out of this CIDR. Read more below.

    Example: Below I have a /24 network of  10.174.72.0.  You could use a much smaller range, say a /27
    (giving you 30 addresses). The minimum is a /29. For the moment, let's stick with the /24.

    For $ovfConfig.loadbalance.service_ip_range.Value I have used a value of 10.174.72.208/28
    That means I have 14 addresses from which to use for Ingress/Egress. 10.174.72.209-.223
    In the UI under "IP Address Ranges for Virtual Servers" I can put all of them (10.174.72.209-10.174.72.223) or a subset of them. These are the addresses used for Ingress/Egress. In a "Default" setup they are on the same network as the workload network so it stands to reason that you would want to carve them out of the whole subnet you have been allocated. This frees up the rest of the subnet to be used by TKG cluster nodes and applications. In a Frontend configuration these addresses would be on a wholely separate subnet.

    Smaller Workload Networks:
    What if I don't have a full /24 to play with?  Let's say you were given a IP addresses for your
    VCSA and ESXi in one subnet (10.174.71.x) and a /27 for your workload network
    from your network team.
    Let's set $ovfConfig.network.workload_ip.Value = "10.174.72.50/27"
    That gives you 30 IP Address to use. We're going to set things up so that the Load Balancer gets
    6 IP addresses and the Workloads will get the remaining 24. This is good for a proof of concept but
    obviously more challenging if you were in production.

    Let's set $ovfConfig.loadbalance.service_ip_range.Value = "10.174.72.208/29"
    Now we have a range of 10.174.72.49-10.174.72.54 that we can add to
    "IP Address Ranges for Virtual Servers" in the UI.
    Note that HAProxy responds to a ping on all of the IP's in this range even if the address isn't being used for ingress or egress.

    The rest of the IP's, 10.174.72.33 to .48 and 10.174.72.50 to .62 will be used by workloads.

#>
#Check for the psnetaddressing module. Needed later.
$modcheck = get-module -listavailable -name psnetaddressing
if ($modcheck) {write-host "Module PSNetAddressing installed. Continuing..."}
else {
    Write-host @"
The Powershell Module PSNetAddressing is not installed.
This is needed to work out CIDR ranges. Please consider installing it
It is available from the Powershell Gallery and is open sourced
Install it by executing the following
Install-Module -Name PSNetAddressing -Scope CurrentUser
The website is: https://github.com/mdjx/PSNetAddressing
After installation you can re-run this script.
"@
Exit
}
#Connect to vCenter. Edit values as appropriate.
$vc = "10.174.71.178"
$vc_user = "administrator@vsphere.local"
$vc_password = "Admin!23"
Connect-VIServer -User $vc_user -Password $vc_password -Server $vc
$Cluster = Get-Cluster  -Name "vSAN-Cluster"
$datastore = Get-Datastore -Name  "vsanDatastore"
$vmhosts = Get-VMHost

#Set up the content library needed by vSphere with Tanzu
New-ContentLibrary -Datastore $datastore -name "tkg-cl" -AutomaticSync -SubscriptionUrl "http://wp-content.vmware.com/v2/latest/lib.json" -Confirm:$false

$workloadhosts = get-cluster $Cluster | get-vmhost
New-VDSwitch -Name "Dswitch" -MTU 9000 -NumUplinkPorts 1 -location vSAN-DC
Get-VDSwitch "Dswitch" | Add-VDSwitchVMHost -VMHost $workloadhosts
Get-VDSwitch "Dswitch" | Add-VDSwitchPhysicalNetworkAdapter -VMHostNetworkAdapter ($workloadhosts | Get-VMHostNetworkAdapter -Name vmnic2) -Confirm:$false
New-VDPortgroup -Name "Workload Network" -VDSwitch "Dswitch"
#
# Suppress shell warnings (Not recommended for production use!)
Get-VMHost | Get-AdvancedSetting UserVars.SuppressShellWarning | Set-AdvancedSetting -Value 1 -Confirm:$false
#
#  Set up tags for vSphere with  Tanzu
#
$StoragePolicyName = "kubernetes-demo-storage"
$StoragePolicyTagCategory = "kubernetes-demo-tag-category"
$StoragePolicyTagName = "kubernetes-gold-storage-tag"
New-TagCategory -Name $StoragePolicyTagCategory -Cardinality single -EntityType Datastore
New-Tag -Name $StoragePolicyTagName -Category $StoragePolicyTagCategory
Get-Datastore -Name $datastore | New-TagAssignment -Tag $StoragePolicyTagName
New-SpbmStoragePolicy -Name $StoragePolicyName -AnyOfRuleSets (New-SpbmRuleSet -Name "wcp-ruleset" -AllOfRules (New-SpbmRule -AnyOfTags (Get-Tag $StoragePolicyTagName)))
#
# Setup and deploy the HAProxy OVA
$DiskFormat = "Thin"
$VMname = "haproxy-demo"
# If you haven't downloaded the OVA you can change $ovfpath accordingly
#ovfPath = "http://storage.googleapis.com/load-balancer-api/ova/release/v0.1.6/haproxy-v0.1.6.ova"
$ovfPath =  "K:\Kits\VMware\vSphere\7U1\haproxy-v0.1.8.ova"
$ovfConfig = Get-OvfConfiguration -Ovf $ovfPath
#
$ovfConfig.network.hostname.Value = "haproxy.local"
$ovfConfig.network.nameservers.Value = "10.172.212.10"
$ovfConfig.network.management_ip.Value = "10.174.71.50/24"
$ovfConfig.network.management_gateway.Value = "10.174.71.253"
$ovfConfig.network.workload_ip.Value = "10.174.72.50/24"
$ovfConfig.network.workload_gateway.Value = "10.174.72.253"
#
#If left blank the HAProxy VM will generate its own. The script will print out the ca_cert value later for
#copy/pasting into the UI.
$ovfConfig.appliance.ca_cert.Value = ""
$ovfConfig.appliance.ca_cert_key.Value = ""
#Other option is Frontend. This script was not written to accomodate a Frontend style deployment.
$ovfConfig.DeploymentOption.Value = "default"
#
#Appliance specific settings
$ovfConfig.appliance.root_pwd.Value = "vmware"
$ovfConfig.appliance.permit_root_login.Value = "True"
#HAProxy specific settings
$ovfConfig.loadbalance.dataplane_port.Value = "5556"
$ovfConfig.loadbalance.haproxy_pwd.Value = "vmware"
$ovfConfig.loadbalance.haproxy_user.Value = "admin"
$ovfConfig.loadbalance.service_ip_range.Value = "10.174.72.208/28"
#The following are virtual switch portgroup names. Edit accordingly.
$ovfConfig.NetworkMapping.Management.Value = "VM Network"
$ovfConfig.NetworkMapping.Workload.Value = "Workload Network"
$ovfConfig.NetworkMapping.Frontend.Value = ""
#
# The Import-vApp cmdlet requires a value for an ESXi host. I just grab the 2nd one on the list.
# Certainly some logic could be added to randomize it.
$VMhost = get-vmhost $vmhosts[2]
#
# Deploy the OVA and start it up.
Import-VApp -Source $ovfpath -OvfConfiguration $ovfConfig -Name $VMName -VMHost $VMHost -Location $Cluster -Datastore $Datastore -DiskStorageFormat $DiskFormat -Confirm:$false
Start-VM $VMname
# Now start the build-out of the results to be put into the UI for setup of WCP
$Dataplane_ip = $ovfConfig.network.management_ip.Value
$Dataplane_ip = $Dataplane_ip -replace ".{3}$"
$Dataplane_prefix =  $ovfConfig.network.management_ip.Value.split("/")[1]
$Dataplane_Port = $ovfConfig.loadbalance.dataplane_port.Value
$Dataplane_IP_and_port = $Dataplane_ip+":"+$Dataplane_Port
$username = $ovfConfig.loadbalance.haproxy_user.Value
$Password = $ovfConfig.loadbalance.haproxy_pwd.Value
#Generate a list of IP Addresses.
 $ips = (get-ipnetwork -ipaddress $Dataplane_ip -PrefixLength $dataplane_prefix -ReturnAllIPs).allips
#Get the CA Cert from the guestinfo advanced settings
$AdvancedSettingName = "guestinfo.dataplaneapi.cacert"
$Base64cert = get-vm $VMname |Get-AdvancedSetting -Name $AdvancedSettingName
while ([string]::IsNullOrEmpty($Base64cert.Value)) {
            Write-Host "Waiting for CA Cert Generation... This may take a under 5-10 minutes as the VM needs to boot and generate the CA Cert (if you haven't provided one already)."
        $Base64cert = get-vm $VMname |Get-AdvancedSetting -Name $AdvancedSettingName
        Start-sleep -seconds 2
    }
    Write-Host "CA Cert Found... Converting from BASE64"
    $cert = [Text.Encoding]::Utf8.GetString([Convert]::FromBase64String($Base64cert.Value))

#Build range of IP's
$dataArr = $ips.Split("`n")
$nrColumns = 4
$range_of_ips = 1..($dataArr.Count/$nrColumns) | %{
    $dataArr[(($_ - 1) * $nrColumns)..(($_ * $nrColumns) - 1)] -join "`t"
}
    #Generate Copy/Paste Data
$dnsserver = $ovfConfig.network.nameservers.Value
$TextOut = @"
Name: <Enter a name in the UI. The name must be DNS Compliant. Use of periods won't work. use a - instead. e.g. haproxy-local
Type: HAProxy
Data Plane IP Address: $Dataplane_IP_and_port
Username: $username
Password: $password
DNS Server: $dnsserver
Server Certificate Authority:
$cert
Copy and Paste these values into the UI setup at
https://$vc/ui/app/workload-platform/appfx-enable-cluster-wizard
"@
$TextOut |Out-File configuration.txt
Write-Host $TextOut
Write-Host "The file 'configuration.txt' has been written to disk"
