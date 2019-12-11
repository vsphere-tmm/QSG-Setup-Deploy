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
$vcname = "192.168.1.184"

#This is the name of your application group and will be used as the root name of the application group components and applications.
$ClientRoleIdentifier = "VC-ADFS-184"

# Creates a new GUID for use by the application group
$identifier = (New-Guid).Guid
# The following are the redirect URL's on vCenter. These should match the URLs in the UI setup.
$redirect1 = "https://$vcname/ui/login"
$redirect2 = "https://$vcname/ui/login/oauth2/authcode"

# The following are the AD over LDAP settings:
$users_base_dn = "CN=Users,DC=lab1,DC=local"
$groups_base_dn = "CN=Users,DC=lab1,DC=local"
$adusername = "CN=Administrator,CN=Users,DC=lab1,DC=local"
$adpassword = VMware1!
$CISserverUsername = "administrator@vsphere.local"
$CISserverPassword = "VMware1!"
$server_endpoint1 = "ldap://mgt-dc-01.lab1.local:389"
#$server_endpoint2 = "ldaps://FQDN2:636"
$cert_chain = ""
#$cert_chain = @(
#                "-----BEGIN CERTIFICATE-----....",
#                "-----BEGIN CERTIFICATE-----...."

#Connect to VAMI REST API
Connect-CisServer -server $vcname -User $CISserverUsername -Password $CISserverPassword -Force



#Create the new Application Group in ADFS
New-AdfsApplicationGroup -Name $ClientRoleIdentifier -ApplicationGroupIdentifier $ClientRoleIdentifier

#Create the ADFS Server Application and generate the client secret.
$ADFSApp = Add-AdfsServerApplication -Name "$ClientRoleIdentifier - Server app" -ApplicationGroupIdentifier $ClientRoleIdentifier -RedirectUri $redirect1,$redirect2  -Identifier $Identifier -GenerateClientSecret

#Create the ADFS Web API application and configure the policy name it should use
Add-AdfsWebApiApplication -ApplicationGroupIdentifier $ClientRoleIdentifier  -Name "VC Web API" -Identifier $identifier -AccessControlPolicyName "Permit everyone"

#Grant the ADFS Applciation the allatclaims and openid permissions
Grant-AdfsApplicationPermission -ClientRoleIdentifier $identifier -ServerRoleIdentifier $identifier -ScopeNames @('allatclaims', 'openid')

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

#Write out the tranform rules file

$transformrule |Out-File -FilePath .\issueancetransformrules.tmp -force -Encoding ascii

# Name the Web API Application and define its Issuance Transform Rules using an external file. 
Set-AdfsWebApiApplication -Name "$ClientRoleIdentifier - Web API" -TargetIdentifier $identifier -IssuanceTransformRulesFile .\issueancetransformrules.tmp

$report = ./report_(Get-Date -Format yyyyddmmm_hhmmtt).txt

Write-Output "Please write down and save the following Client Identifier" ($ClientRoleIdentifier)
Write-Output "Please write down and save the following Client Identifier UID" ($identifier)
Write-Output "Please write down and save the following Client Secret: "($ADFSApp.ClientSecret)

$openidurl = (Get-AdfsEndpoint -addresspath "/adfs/.well-known/openid-configuration")
write-output "OpenID URL is: " $openidurl.FullUrl.OriginalString



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


$s = Get-CisService "com.vmware.vcenter.identity.providers"
 
$adfsSpec = @{
    "name" = "Microsoft ADFS";
    "config_tag" = "Oidc";
    "upn_claim" = "upn";
    "groups_claim" = "group";
    "oidc" = @{
        "client_id" = $identifier;
        "client_secret" = ($ADFSApp.ClientSecret);
        "discovery_endpoint" = ($openidurl.FullUrl.OriginalString);
        "claim_map" = @{};
    };
    "idm_protocol" = "LDAP";
    "active_directory_over_ldap" = @{
        "users_base_dn" = $users_base_dn;
        "groups_base_dn" = $groups_base_dn;
        "user_name" = $adusername;
        "password" = $adpassword;
        "server_endpoints" = $server_endpoint1;
        "cert_chain" = ($cert_chain)
        }
    
    "is_default" = $true
}
$s.create($adfsSpec)
)