##
<#
.SYNOPSIS
    Sets up Microsoft ADFS and vCenter for use with VMware vCenter's Identity Federation.
.DESCRIPTION
    Introduced in vSphere 7, Identity Federation allows for an external identity provider,
    in this case Microsoft Active Directory Federation Services (a.k.a. ADFS) to authenticate a vCenter user.
    The user is then redirected to vCenter and logged in automatically.

    This script configured MS ADFS to work with vCenter. It adds an ADFS Application Group and server and API
    applications and configures them correctly.

    This script should be run from the ADFS server. That is where the ADFS cmdlets are installed.
.EXAMPLE

.INPUTS
    Inputs (if any)
.OUTPUTS
    Output (if any)
.NOTES
    This script should be run on the ADFS system you are connecting to.
#>

# Because we are using a PowerCLI datatype for the AD Password below, we need to ensure PowerCLI gets loaded.
# Changes to PowerShell meant that the module wouldn't load until the a command in that module was run
#Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false


param(
        [Parameter(Mandatory=$true)][string]$vc_server,
        [Parameter(Mandatory=$true)][String]$vc_username,
        [Parameter(Mandatory=$true)][String]$vc_password,
        [Parameter(Mandatory=$true)][String]$CISserverUsername,
        [Parameter(Mandatory=$true)][String]$CISserverPassword,
        [Parameter()][String]$users_base_dn = "CN=Users,DC=lab1,DC=local",
        [Parameter()][String]$groups_base_dn = "DC=lab1,DC=local",
        [Parameter()][String]$adusername = "CN=Administrator,CN=Users,DC=lab1,DC=local",
        [Parameter()][String]$adpasswordstring = "VMware1!",
        [Parameter()][String]$server_endpoint1 = "ldaps://mgt-dc-01.lab1.local:636",
        [Parameter()][String]$server_endpoint2


)
#This is the name of your vCenter. IP address or FQDN
#$vc_server = "192.168.1.188"

#$CISserverUsername = "administrator@vsphere.local"
#$CISserverPassword = "VMware1!"

# The following are the redirect URL's on vCenter. These should match the URLs in the UI setup.
$redirect1 = "https://$vcname/ui/login"
$redirect2 = "https://$vcname/ui/login/oauth2/authcode"

# The following are the AD over LDAP settings:
#$users_base_dn = "CN=Users,DC=lab1,DC=local"
#$groups_base_dn = "DC=lab1,DC=local"
#$adusername = "CN=Administrator,CN=Users,DC=lab1,DC=local"
#[VMware.VimAutomation.Cis.Core.Types.V1.Secret]$adpassword = "VMware1!"
#$server_endpoint1 = "ldaps://mgt-dc-01.lab1.local:636"
#$server_endpoint2 = "ldaps://FQDN2:636"

Write-Host "Checking to see if ADFS is running"
$adfsinstalled = Get-WindowsFeature |Where-Object {
    $_.Name -imatch "ADFS-Federation"
}
if ($adfsinstalled.installed -eq $true) {
    Write-Host "ADFS is installed. Script Continuing"
}
else {
    Write-Host "ADFS not installed. You should run this on your ADFS server"
    Exit
}
Write-Host "Connecting to the vCenter" $vcname
Connect-VIServer -Server $vcname -User $CISserverUsername -Password $CISserverPassword -Force

# Creates a new GUID for use by the application group
[string]$identifier = (New-Guid).Guid


Write-Host "Get CA Cert from ADFS server LocalMachine store"
# If you have a funky setup and this doesn't work for you then you may have to get the CA cert
# manually using openssl.
# e.g. openssl s_client -connect DC1.ad.local:636 -showcerts
# Replace "@($ad_cert_chain)" with "@("the actual cert content that begins with BEGIN CERTIFICATE
# and ends with END CERTIFICATE")

# Gets the FQDN
$fqdn = [System.Net.Dns]::GetHostByName((hostname)).HostName

# Then gets the cert issued to that FQDN (The ADFS server)
$cert = Get-ChildItem Cert:\LocalMachine\My |Where-Object {$_.Subject -match $fqdn.tolower()}

# Then gets who issued that cert (The CA)
$CAcert = Get-ChildItem Cert:\LocalMachine\CA | Where-Object { $_.Subject -imatch $cert.Issuer}

# Then gets the cert of the CA and converts it to Base64
$ad_cert_chain = [convert]::tobase64string($CAcert.export('Cert'),[system.base64formattingoptions]::insertlinebreaks)


Write-Host "Configuring ADFS"

# This is the name of your application group and will be used as the root name of the application group
# components and applications. In this example we'll use the FQDN of vCenter.
$ClientRoleIdentifier = $vcname

Write-Host ""

Write-Host "Create the new Application Group in ADFS"
New-AdfsApplicationGroup -Name $ClientRoleIdentifier

Write-Host ""

Write-Host "Create the ADFS Server Application and generate the client secret"
$ADFSApp = Add-AdfsServerApplication -Name ($ClientRoleIdentifier + " VC - Server app") -ApplicationGroupIdentifier $ClientRoleIdentifier -RedirectUri $redirect1,$redirect2  -Identifier $Identifier -GenerateClientSecret

Write-Host ""

Write-Host "#Create the client secret"
$client_secret = $ADFSApp.ClientSecret

Write-Host ""

Write-Host "Create the ADFS Web API application and configure the policy name it should use"
Add-AdfsWebApiApplication -ApplicationGroupIdentifier $ClientRoleIdentifier  -Name ($ClientRoleIdentifier + " VC Web API") -Identifier $identifier -AccessControlPolicyName "Permit everyone"

Write-Host ""

Write-Host "Grant the ADFS Application the allatclaims and openid permissions"
Grant-AdfsApplicationPermission -ClientRoleIdentifier $identifier -ServerRoleIdentifier $identifier -ScopeNames @('allatclaims', 'openid')

Write-Host ""

Write-Host "Build the transform rule for ADFS"

Write-Host ""

$transformrule = @"
@RuleTemplate = "LdapClaims"
@RuleName = "AD Groups with Qualified Long Name"
c:[Type == "http://schemas.microsoft.com/ws/2008/06/identity/claims/windowsaccountname", Issuer == "AD AUTHORITY"]
 => issue(store = "Active Directory", types = ("http://schemas.xmlsoap.org/claims/Group"), query = ";tokenGroups(longDomainQualifiedName);{0}", param = c.Value);

@RuleTemplate = "LdapClaims"
@RuleName = "Subject"
c:[Type == "http://schemas.microsoft.com/ws/2008/06/identity/claims/windowsaccountname", Issuer == "AD AUTHORITY"]
 => issue(store = "Active Directory", types = ("http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier"), query = ";userPrincipalName;{0}", param = c.Value);

@RuleTemplate = "LdapClaims"
@RuleName = "User Principal Name"
c:[Type == "http://schemas.microsoft.com/ws/2008/06/identity/claims/windowsaccountname", Issuer == "AD AUTHORITY"]
 => issue(store = "Active Directory", types = ("http://schemas.xmlsoap.org/ws/2005/05/identity/claims/upn"), query = ";userPrincipalName;{0}", param = c.Value);
"@

Write-Host "Write out the tranform rules file"

$transformrule |Out-File -FilePath $temp\issueancetransformrules.tmp -force -Encoding ascii

Write-Host "Name the Web API Application and define its Issuance Transform Rules using an external file"

Set-AdfsWebApiApplication -Name "$ClientRoleIdentifier - Web API" -TargetIdentifier $identifier -IssuanceTransformRulesFile $temp\issueancetransformrules.tmp

Write-Host ""

$openidurl = (Get-AdfsEndpoint -addresspath "/adfs/.well-known/openid-configuration")

#-----------------------------------------------------------------------

Write-Host "Connect to VAMI REST API"
Connect-CisServer -server $vcname -User $CISserverUsername -Password $CISserverPassword -Force

Write-Host "Connecting to the CIS Service"
$s = Get-CisService "com.vmware.vcenter.identity.providers"
$client_secret_string = [string]$client_secret

#Re-Cast the AD password to a PowerCLI secret so the ADFS spec works correctly.
# Doing this here because I can't do it as part of the param because PowerCLI isn't loaded yet
# Now that PowerCLI is loaded by the Connect-xxServer commands this re-casting will work.
[VMware.VimAutomation.Cis.Core.Types.V1.Secret]$adpassword = $adpasswordstring


Write-Host "Build the ADFS Spec"
$adfsSpec = @{
    "is_default" = $true;
    "name" = "Microsoft ADFS";
    "config_tag" = "Oidc";
    "upn_claim" = "upn";
    "groups_claim" = "group";
    "oidc" = @{
        "client_id" = $identifier;
        "client_secret" = $client_secret_string;
        "discovery_endpoint" = $openidurl.FullUrl.OriginalString;
        "claim_map" = @{};
};
    "idm_protocol" = "LDAP";
    "active_directory_over_ldap" = @{
        "users_base_dn" = $users_base_dn;
        "groups_base_dn" = $groups_base_dn;
        "user_name" = $adusername;
        "password" = $adpassword;
        "server_endpoints" = @($server_endpoint1);
        "cert_chain" =@{
            "cert_chain" = @(
                $ad_cert_chain
            )
        }
};
}
Write-Host "Create the ADFS Spec on VC"
try {
    $s.create($adfsSpec)

}
catch {
    $ErrorMessage = $_.Exception.Message
    $FailedItem = $_.Exception.ItemName
    Break
}

Write-Host @"
Your vCenter and ADFS are now connected!

 Please write down and save the following Client Identifier
($ClientRoleIdentifier)

Please write down and save the following Client Identifier UID
($identifier)

Please write down and save the following Client Secret:
($client_secret)

OpenID URL is:
($openidurl.FullUrl.OriginalString)
"@
