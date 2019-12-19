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

#This is the name of your vCenter. IP address or FQDN
$vcname = "192.168.1.188"

Write-Output "Connecting to the VC VI Server"
$CISserverUsername = "administrator@vsphere.local"
$CISserverPassword = "VMware1!"
Set-PowerCLIConfiguration -InvalidCertificateAction Ignore -Confirm:$false
Connect-VIServer -Server $vcname -User $CISserverUsername -Password $CISserverPassword -Force

# Creates a new GUID for use by the application group
[string]$identifier = (New-Guid).Guid
# The following are the redirect URL's on vCenter. These should match the URLs in the UI setup.
$redirect1 = "https://$vcname/ui/login"
$redirect2 = "https://$vcname/ui/login/oauth2/authcode"

# The following are the AD over LDAP settings:
$users_base_dn = "CN=Users,DC=lab1,DC=local"
$groups_base_dn = "DC=lab1,DC=local"
$adusername = "CN=Administrator,CN=Users,DC=lab1,DC=local"
[VMware.VimAutomation.Cis.Core.Types.V1.Secret]$adpassword = "VMware1!"
$server_endpoint1 = "ldaps://mgt-dc-01.lab1.local:636"
#$server_endpoint2 = "ldaps://FQDN2:636"

Write-Output "Get CA Cert from ADFS server LocalMachine store"
#If you have a funky setup and this doesn't work for you then you may have to get the CA cert
#manually using openssl. e.g. openssl s_client -connect DC1.ad.local:636 -showcerts
# Replace "@($base64Cert)" with "@("the contents that begins with BEGIN CERTIFICATE
# and ends with END CERTIFICATE"
$fqdn = [System.Net.Dns]::GetHostByName((hostname)).HostName
$cert = Get-ChildItem Cert:\LocalMachine\My |where {$_.Subject -match $fqdn.tolower()}
$CAcert = Get-ChildItem Cert:\LocalMachine\CA | where { $_.Subject -imatch $cert.Issuer}
$base64Cert = [convert]::tobase64string($CAcert.export('Cert'),[system.base64formattingoptions]::insertlinebreaks)
$ad_cert_chain = @($base64Cert)

Write-Output "Configuring ADFS"

#This is the name of your application group and will be used as the root name of the application group components and applications.
$ClientRoleIdentifier = $vcname

Write-Output ""

Write-Output "Create the new Application Group in ADFS"
New-AdfsApplicationGroup -Name $ClientRoleIdentifier #-ApplicationGroupIdentifier $identifier

Write-Output ""

Write-Output "Create the ADFS Server Application and generate the client secret"
$ADFSApp = Add-AdfsServerApplication -Name ($ClientRoleIdentifier + " VC - Server app") -ApplicationGroupIdentifier $ClientRoleIdentifier -RedirectUri $redirect1,$redirect2  -Identifier $Identifier -GenerateClientSecret

Write-Output ""

Write-Output "#Create the client secret"
$client_secret = $ADFSApp.ClientSecret

Write-Output ""

# Write-Output "Please write down and save the following Client Secret: " ($ADFSApp.ClientSecret)

Write-Output "Create the ADFS Web API application and configure the policy name it should use"
Add-AdfsWebApiApplication -ApplicationGroupIdentifier $ClientRoleIdentifier  -Name ($ClientRoleIdentifier + " VC Web API") -Identifier $identifier -AccessControlPolicyName "Permit everyone"

Write-Output ""

Write-Output "Grant the ADFS Application the allatclaims and openid permissions"
Grant-AdfsApplicationPermission -ClientRoleIdentifier $identifier -ServerRoleIdentifier $identifier -ScopeNames @('allatclaims', 'openid')

Write-Output ""

Write-Output "Build the transform rule for ADFS"

Write-Output ""

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

write-Output "Write out the tranform rules file"

$transformrule |Out-File -FilePath .\issueancetransformrules.tmp -force -Encoding ascii

Write-Output ""

Write-Output "Name the Web API Application and define its Issuance Transform Rules using an external file"

Set-AdfsWebApiApplication -Name "$ClientRoleIdentifier - Web API" -TargetIdentifier $identifier -IssuanceTransformRulesFile .\issueancetransformrules.tmp

Write-Output ""

$openidurl = (Get-AdfsEndpoint -addresspath "/adfs/.well-known/openid-configuration")

#-----------------------------------------------------------------------

Write-Output "Connect to VAMI REST API"
Connect-CisServer -server $vcname -User $CISserverUsername -Password $CISserverPassword -Force

# Change Identity Provider

# Configure the following:
#Client Identifier
#Shared Secret
#OpenID Address

#Configure/create spec for AD over LDAP so VC can look up user accounts to map permissions
# Required fields:
# Base distinguished Name for Users
# Base distinguished Name for Groups
# Username
# Password
# Primary Server URL (ldap://FQDN:389)
# Secondary Server URL (ldap://FQDN:389)
# Certificate if using LDAPS

# Inform user to add AD user permissions to VC
#Write-Output "Client Secret:" $client_secret
$client_secret_string = [string]$client_secret
#Write-Output "Client Secret String:" $client_secret_string

Write-Output "Connecting to the CIS Service"
$s = Get-CisService "com.vmware.vcenter.identity.providers"

Write-Output "Build the ADFS Spec"
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
Write-Output "Create the ADFS Spec on VC"
$s.create($adfsSpec)

Write-Output "Your vCenter and ADFS are now connected"
Write-Output "Please write down and save the following Client Identifier" ($ClientRoleIdentifier)

Write-Output ""

Write-Output "Please write down and save the following Client Identifier UID" ($identifier)

Write-Output ""

Write-Output "Please write down and save the following Client Secret: " ($client_secret)

Write-Output ""
write-output "OpenID URL is: " $openidurl.FullUrl.OriginalString
