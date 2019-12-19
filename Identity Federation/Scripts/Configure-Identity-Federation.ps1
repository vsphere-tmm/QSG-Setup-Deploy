##
<#
.SYNOPSIS
    Sets up Microsoft ADFS for use by VMware vCenter's Identity Federation.
.DESCRIPTION
    Introduced in vSphere 7, Identity Federation allows for an external identity provider, 
    in this case Microsoft Active Directory Federation Services (a.k.a. ADFS) to authenticate a vCenter user.
    The user is then redirected to vCenter and logged in automatically. 

    This script configured MS ADFS to work with vCenter. It adds an ADFS Application Group and server and API
    applications and configures them correctly. 
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
#This is the name of your application group and will be used as the root name of the application group components and applications.
$ClientRoleIdentifier = "VC-ADFS-188"
$AppGroupID = $ClientRoleIdentifier + "-GID"

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
#$ad_cert_chain = ""
$ad_cert_chain = @("-----BEGIN CERTIFICATE-----
MIIDeTCCAmGgAwIBAgIQE7J8a+bxpbBMwk/H2a76EDANBgkqhkiG9w0BAQUFADBD
MRUwEwYKCZImiZPyLGQBGRYFbG9jYWwxFDASBgoJkiaJk/IsZAEZFgRsYWIxMRQw
EgYDVQQDEwtOZXcgUm9vdCBDQTAeFw0xNzAxMjAxNzAyMTNaFw0yMDAxMjAxNzEy
MDlaMEMxFTATBgoJkiaJk/IsZAEZFgVsb2NhbDEUMBIGCgmSJomT8ixkARkWBGxh
YjExFDASBgNVBAMTC05ldyBSb290IENBMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8A
MIIBCgKCAQEAyT3RSPM4JUjpDuYnr77YTieDvK0C5QC5wjLurxC4I2hNwjnnstJn
kqK0DNkQt0xKOD8l3fJ9XaHSVWCvoRVYmOAvInW8y6UVwNzlQ6w1zdNKG+VmT8Jy
3Hntq5IssvHg0tyfvkxa31BjwiMgAB36YDvFhv6BewueR96m3LY1V2GOwDn/0xfa
ZdbsnlNg4hFmwtm/WL4RABNO0I30qoPrdE73/8St1MJjkowzOHSww20Q2vwJJAQQ
+lec4fmkhOjNloIy4h8c/KICgJOik2QejprXXkFKt+gNCBhHqD/rIneyJldHQYEz
mlKZqrpDey5QLJ1fBafo06u9F7RwEi0aTQIDAQABo2kwZzATBgkrBgEEAYI3FAIE
Bh4EAEMAQTAOBgNVHQ8BAf8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAdBgNVHQ4E
FgQUBFQLx7BNlhZYL/Enbji3UfqhblQwEAYJKwYBBAGCNxUBBAMCAQAwDQYJKoZI
hvcNAQEFBQADggEBALgWRD3sqWqwTGAPBfFNrlArgO7M98ZEhBOHkSv0P76HR4ch
w4vQGcuXeJvr1bvSiH26gM5+ikqNSUSegzPQZAfwdvR89X5UtNxDYmjpD2mZBSen
7ixQgN2BV4tInfcJNQvd3ylTuP3pavETqxmRJwvsykeX9iIi5LpamU3aNOqRulcS
eU6xCSQguAmqi2SJY/H1n0eRgqHDFRLBhbK0sHhiyTtM7dG0S87QFKPtIPtAg8aA
8ahyZI/uqYMxFlRewIFNwLkKVNe/+Wj/WFS3rXSVK7m6KHYAKgNLG/uD769wg4UI
ybee27mHAyOC/WpwjF8g5RhP5ik4f5HC2Tkd1RE=
-----END CERTIFICATE-----"
)
#                "-----BEGIN CERTIFICATE-----....",
#                "-----BEGIN CERTIFICATE-----...."


Write-Output "Configuring ADFS"

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

Write-Output "Please write down and save the following Client Identifier" ($ClientRoleIdentifier)

Write-Output ""

Write-Output "Please write down and save the following Client Identifier UID" ($identifier)

Write-Output ""

Write-Output "Please write down and save the following Client Secret: " ($client_secret)

Write-Output ""

$openidurl = (Get-AdfsEndpoint -addresspath "/adfs/.well-known/openid-configuration")
write-output "OpenID URL is: " $openidurl.FullUrl.OriginalString

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
