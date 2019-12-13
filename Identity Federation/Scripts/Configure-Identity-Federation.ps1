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
$AppGroupID = $ClientRoleIdentifier + "-groupID"

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
$CISserverUsername = "administrator@vsphere.local"
$CISserverPassword = "VMware1!"
$server_endpoint1 = "ldap://mgt-dc-01.lab1.local:389"
#$server_endpoint2 = "ldaps://FQDN2:636"
#$cert_chain = ""
$cert_chain = @("    -----BEGIN CERTIFICATE-----
MIIF5TCCBM2gAwIBAgITHgAAABW7IUji+Cn/lQAAAAAAFTANBgkqhkiG9w0BAQUF
ADBDMRUwEwYKCZImiZPyLGQBGRYFbG9jYWwxFDASBgoJkiaJk/IsZAEZFgRsYWIx
MRQwEgYDVQQDEwtOZXcgUm9vdCBDQTAeFw0xOTEwMDMwNDUxMjRaFw0yMDAxMjAx
NzEyMDlaMB8xHTAbBgNVBAMTFE1HVC1EQy0wMS5sYWIxLmxvY2FsMIIBIjANBgkq
hkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA01f6Fw7fJ0EwmJnxw9uudDTzLzq8JOVK
l+tL+TPXVVONbfmArGYGqJgIxKe5mESqRUPiXIY1yu6Atp9IX/A139v4v8mdu+Ex
I9ANPCB/Wrlj4YnGfYsLhOzJCjvZTZhtYJrQXJWTnaclG1QVgXlmLlI/cz8uhqcd
4xR3uVNkXggdMIfY1EXZXhksG9e7XNFHb2AB54j4/Lj5EimDDBAV504/SK3lUd7u
Ln3h3nSEuQgYJtqrpRpXU6JWBQbW95Coz+yZrGf++QBQRMyNj0y6FOzUwROO2bgP
olT64MQzNpUPMA0gNysGi+SV8WEFlCSLcnDfD7r0T92o7crkxWq0KwIDAQABo4IC
9DCCAvAwLwYJKwYBBAGCNxQCBCIeIABEAG8AbQBhAGkAbgBDAG8AbgB0AHIAbwBs
AGwAZQByMB0GA1UdJQQWMBQGCCsGAQUFBwMCBggrBgEFBQcDATAOBgNVHQ8BAf8E
BAMCBaAweAYJKoZIhvcNAQkPBGswaTAOBggqhkiG9w0DAgICAIAwDgYIKoZIhvcN
AwQCAgCAMAsGCWCGSAFlAwQBKjALBglghkgBZQMEAS0wCwYJYIZIAWUDBAECMAsG
CWCGSAFlAwQBBTAHBgUrDgMCBzAKBggqhkiG9w0DBzBABgNVHREEOTA3oB8GCSsG
AQQBgjcZAaASBBAE8Ku8fSipRrhG4pFYLQXyghRNR1QtREMtMDEubGFiMS5sb2Nh
bDAdBgNVHQ4EFgQUthPBVoMTWOheYP2R0PkgA/idbcswHwYDVR0jBBgwFoAUBFQL
x7BNlhZYL/Enbji3UfqhblQwgc4GA1UdHwSBxjCBwzCBwKCBvaCBuoaBt2xkYXA6
Ly8vQ049TmV3JTIwUm9vdCUyMENBLENOPU1HVC1EQy0wMSxDTj1DRFAsQ049UHVi
bGljJTIwS2V5JTIwU2VydmljZXMsQ049U2VydmljZXMsQ049Q29uZmlndXJhdGlv
bixEQz1sYWIxLERDPWxvY2FsP2NlcnRpZmljYXRlUmV2b2NhdGlvbkxpc3Q/YmFz
ZT9vYmplY3RDbGFzcz1jUkxEaXN0cmlidXRpb25Qb2ludDCBwAYIKwYBBQUHAQEE
gbMwgbAwga0GCCsGAQUFBzAChoGgbGRhcDovLy9DTj1OZXclMjBSb290JTIwQ0Es
Q049QUlBLENOPVB1YmxpYyUyMEtleSUyMFNlcnZpY2VzLENOPVNlcnZpY2VzLENO
PUNvbmZpZ3VyYXRpb24sREM9bGFiMSxEQz1sb2NhbD9jQUNlcnRpZmljYXRlP2Jh
c2U/b2JqZWN0Q2xhc3M9Y2VydGlmaWNhdGlvbkF1dGhvcml0eTANBgkqhkiG9w0B
AQUFAAOCAQEAyECcJwxGuA669KZOoNfPM+qliZXHjlPdPHLkmM7izEMtl/ZzM8Jt
gRVWI3qXWTZd5tY+xSIHXPhLE6vmbHDIWXpY8VaZf4cNJqxwhjBuKTMyxRQn3ndD
MH1cFf1QSyIc3wZwkpOdjm4It3fewrEruZqIrmSI2CNFJDy86ZIo+zSVbiTs2Qox
WPHgtJW5vKGuvO6+Nb4VsnGa1l6mWO5CEjyEIeKVUKYPoxyeZbBffJB6JZxtdmbr
NFUsn525n8tnhKphNKwnKvSOGpyqa37WFQAHpogfEMuvQunFe2oFKDbiFkTvLFA1
uymb122EOzrq7HI99gPJZeJeH4BFMP79yQ==
-----END CERTIFICATE-----"
)
#                "-----BEGIN CERTIFICATE-----....",
#                "-----BEGIN CERTIFICATE-----...."


Write-Output "Configuring ADFS"

#Create the new Application Group in ADFS
New-AdfsApplicationGroup -Name $ClientRoleIdentifier -ApplicationGroupIdentifier $AppGroupID

#Create the ADFS Server Application and generate the client secret.
$ADFSApp = Add-AdfsServerApplication -Name "$ClientRoleIdentifier - Server app" -ApplicationGroupIdentifier $AppGroupID -RedirectUri $redirect1,$redirect2  -Identifier $Identifier -GenerateClientSecr

#Create the client secret
$client_secret = $ADFSApp.ClientSecret
Write-Output "ADFS Secrect: " $ADFSApp.ClientSecret
Write-Output "Client Secret:" $client_secret 
$client_secret_string = [string]$client_secret
Write-Output "Client Secret String:" $client_secret_string
#Create the ADFS Web API application and configure the policy name it should use
Add-AdfsWebApiApplication -ApplicationGroupIdentifier $AppGroupID  -Name "VC Web API" -Identifier $identifier -AccessControlPolicyName "Permit everyone"

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

#$report = ./report_(Get-Date -Format yyyyddmmm_hhmmtt).txt

Write-Output "Please write down and save the following Client Identifier" ($ClientRoleIdentifier)

Write-Output "Please write down and save the following Client Identifier UID" ($identifier)

Write-Output "Please write down and save the following Client Secret: " $client_secret

$openidurl = (Get-AdfsEndpoint -addresspath "/adfs/.well-known/openid-configuration")
write-output "OpenID URL is: " $openidurl.FullUrl.OriginalString

#-----------------------------------------------------------------------
Write-Output "Configuring VC..."
#Connect to VAMI REST API
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

$s = Get-CisService "com.vmware.vcenter.identity.providers"
 
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
                $cert_chain
            )
        }
};
}
$s.create($adfsSpec)
