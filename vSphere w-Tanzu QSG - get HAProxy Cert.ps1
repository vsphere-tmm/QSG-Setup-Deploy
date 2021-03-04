##
<#
.SYNOPSIS
    Retrieves the HAProxy certificate and formats it to be cut and pasted into the vSphere UI
.DESCRIPTION
    Introduced in vSphere 7 Update 1, vSphere with Tanzu can use HAProxy to provide load balancer services
    This script retrieves theHAProxy certificate and formats it to be cut and pasted into the vSphere UI
.EXAMPLE

.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES

#>
# Change the value of $vc, $vc_user, $vc_password and $VMname to match yours.
$vc = "10.174.71.163"
$vc_user = "administrator@vsphere.local"
$vc_password = "Admin!23"
Connect-VIServer -User $vc_user -Password $vc_password -Server $vc
$VMname = "haproxy-demo"
$AdvancedSettingName = "guestinfo.dataplaneapi.cacert"
$Base64cert = get-vm $VMname |Get-AdvancedSetting -Name $AdvancedSettingName
while ([string]::IsNullOrEmpty($Base64cert.Value)) {
Write-Host "Waiting for CA Cert Generation... This may take a under 5-10 minutes as the VM needs to boot and generate the CA Cert (if you haven't provided one already)."
$Base64cert = get-vm $VMname |Get-AdvancedSetting -Name $AdvancedSettingName
Start-sleep -seconds 2
}
Write-Host "CA Cert Found... Converting from BASE64"
$cert = [Text.Encoding]::Utf8.GetString([Convert]::FromBase64String($Base64cert.Value))
Write-Host $cert
